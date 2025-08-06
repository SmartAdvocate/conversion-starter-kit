USE [SA]
GO

/*
alter table [sma_TRN_InsuranceCoverage] disable trigger all
delete from [sma_TRN_InsuranceCoverage]
DBCC CHECKIDENT ('[sma_TRN_InsuranceCoverage]', RESEED, 0);
alter table [sma_TRN_InsuranceCoverage] disable trigger all

truncate table [sma_TRN_InsuranceCoverageAdjusters]
*/

---(0)---
IF NOT EXISTS (SELECT * FROM sys.columns WHERE Name = N'saga' AND Object_ID = Object_ID(N'sma_TRN_InsuranceCoverage'))
BEGIN
    ALTER TABLE [sma_TRN_InsuranceCoverage] 
	ADD [saga] varchar(50); 
END

---------------------------------------------------------------------------
-------------INSURANCE COMMENTS FROM USER_INSURANCE_DATA TABLE-------------
---------------------------------------------------------------------------
IF EXISTS (SELECT * FROM sys.objects WHERE name='Insurance_Comment_Helper' and type='U')
BEGIN
    DROP TABLE Insurance_Comment_Helper
END
GO

SELECT td.insuranceid, string_agg(ucf.field_title + ': '+ td.[data], char(10)+char(13)) as ins_comment
INTO Insurance_Comment_Helper
FROM [NeedlesNeosBisnarChase]..user_insurance_data td
JOIN [NeedlesNeosBisnarChase]..user_case_fields ucf on ucf.id = td.usercasefieldid
GROUP BY td.insuranceid

-------------------------------------------------------------------------------
---------------------------INSURANCE CONTACTS HELPER---------------------------
-------------------------------------------------------------------------------
IF EXISTS (SELECT * FROM sys.objects WHERE name='Insurance_Contacts_Helper' and type='U')
BEGIN
    DROP TABLE Insurance_Contacts_Helper
END
GO

CREATE TABLE Insurance_Contacts_Helper
(
    tableIndex				int IDENTITY(1,1) NOT NULL,
    insurance_id			varchar(50),		-- table id
    insurer_id				varchar(50),			-- insurance company
    adjuster_id				varchar(50),		-- adjuster
    insured					varchar(100),	-- a person or organization covered by insurance
    incnInsContactID		int, 
    incnInsAddressID		int,
    incnAdjContactId		int,
    incnAdjAddressID		int,
    incnInsured				int,
	pord					varchar(1),
	caseID					int,
	PlaintiffDefendantID	int
 CONSTRAINT IX_Insurance_Contacts_Helper PRIMARY KEY CLUSTERED 
(
	tableIndex
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY] 
GO

CREATE NONCLUSTERED INDEX IX_NonClustered_Index_insurance_id ON Insurance_Contacts_Helper (insurance_id);   
GO
CREATE NONCLUSTERED INDEX IX_NonClustered_Index_insurer_id ON Insurance_Contacts_Helper (insurer_id);   
GO
CREATE NONCLUSTERED INDEX IX_NonClustered_Index_adjuster_id ON Insurance_Contacts_Helper (adjuster_id); 
GO  

---(0)---
INSERT INTO Insurance_Contacts_Helper
(
    insurance_id,
    insurer_id,
    adjuster_id,
    insured,
    incnInsContactID,
    incnInsAddressID,
    incnAdjContactId,
    incnAdjAddressID,
    incnInsured,
	pord,
	caseID,
	PlaintiffDefendantID
) 
SELECT 
    convert(varchar(50),INS.id),
    convert(varchar(50),INS.insurer_namesid),
    convert(varchar(50),INS.adjuster_namesid),
    INS.insured,
    IOC1.CID				as incnInsContactID, 
    IOC1.AID				as incnInsAddressID,
    IOC2.CID				as incnAdjContactId,
    IOC2.AID				as incnAdjAddressID,
    INFO.UniqueContactId	as incnInsured,
    null					as pord,
    CAS.casnCaseID			as caseID,
	null					as PlaintiffDefendantID
--SELECT *
FROM [NeedlesNeosBisnarChase].[dbo].[insurance_Indexed] INS
JOIN [sma_TRN_Cases] CAS on CAS.Needles_saga=convert(varchar(50),INS.casesid)
JOIN IndvOrgContacts_Indexed IOC1 on IOC1.saga = convert(varchar(50),INS.insurer_namesid)
LEFT JOIN IndvOrgContacts_Indexed IOC2 on IOC2.saga = convert(varchar(50),INS.adjuster_namesid)
LEFT JOIN [sma_MST_IndvContacts] I on I.cinsLastName=INS.insured and I.cinsGrade=INS.insured and I.saga='-1'
LEFT JOIN [sma_MST_AllContactInfo] INFO on INFO.ContactId=I.cinnContactID and INFO.ContactCtg=I.cinnContactCtg 
GO

DBCC DBREINDEX('Insurance_Contacts_Helper',' ',90) WITH NO_INFOMSGS 
GO

---(0)--- (prepare for multiple party)
IF EXISTS (select * from sys.objects where Name='multi_party_helper_temp')
BEGIN
    DROP TABLE [multi_party_helper_temp]
END
GO

SELECT INS.id	as ins_id, T.plnnPlaintiffID
INTO [multi_party_helper_temp]
FROM [NeedlesNeosBisnarChase]..[insurance_Indexed] INS
JOIN [sma_TRN_cases] CAS on CAS.Needles_saga = convert(varchar(50),INS.casesid)
JOIN [sma_TRN_Plaintiff] T on t.saga_party = convert(varchar(50),ins.partyid)  
GO



UPDATE [Insurance_Contacts_Helper] 
SET pord='P', PlaintiffDefendantID=A.plnnPlaintiffID
FROM [multi_party_helper_temp] A
WHERE A.ins_id = insurance_id
GO

IF EXISTS (select * from sys.objects where Name='multi_party_helper_temp')
BEGIN
    DROP TABLE [multi_party_helper_temp]
END
GO

SELECT 
    INS.id	as ins_id,	
    D.defnDefendentID
INTO [multi_party_helper_temp]
FROM [NeedlesNeosBisnarChase].[dbo].[insurance_Indexed] INS
JOIN [sma_TRN_cases] CAS on CAS.Needles_saga = convert(varchar(50),INS.casesid)
JOIN [sma_TRN_Defendants] D on d.saga_party = convert(varchar(50),ins.partyid) 
GO

UPDATE [Insurance_Contacts_Helper] 
SET pord='D', PlaintiffDefendantID=A.defnDefendentID
FROM [multi_party_helper_temp] A
WHERE A.ins_id = insurance_id
GO
-------------------------------------------------------------------------------
-------------------------END INSURANCE CONTACTS HELPER-------------------------
-------------------------------------------------------------------------------

---------------------------------
--INSURANCE TYPES
---------------------------------
INSERT INTO [sma_MST_InsuranceType] (intsDscrptn ) 
SELECT 'Unspecified'
UNION
SELECT DISTINCT [type] FROM [NeedlesNeosBisnarChase].[dbo].[insurance] INS 
JOIN [NeedlesNeosBisnarChase].[dbo].[insurance_type] it on it.id = ins.insurancetypeid
EXCEPT
SELECT intsDscrptn FROM [sma_MST_InsuranceType]
GO

---
ALTER TABLE [sma_TRN_InsuranceCoverage] DISABLE TRIGGER ALL
GO

-------------------------------------
--PLAINTIFF INSURANCE
-------------------------------------
INSERT INTO [sma_TRN_InsuranceCoverage] 
(
	[incnCaseID],[incnInsContactID],[incnInsAddressID],[incbCarrierHasLienYN],[incnInsType],[incnAdjContactId],[incnAdjAddressID],[incsPolicyNo],[incsClaimNo],[incnStackedTimes],
	[incsComments],[incnInsured],[incnCovgAmt],[incnDeductible],[incnUnInsPolicyLimit],[incnUnderPolicyLimit],[incbPolicyTerm],[incbTotCovg],[incsPlaintiffOrDef],[incnPlaintiffIDOrDefendantID],
	[incnTPAdminOrgID],[incnTPAdminAddID],[incnTPAdjContactID],[incnTPAdjAddID],[incsTPAClaimNo],[incnRecUserID],[incdDtCreated],[incnModifyUserID],[incdDtModified],[incnLevelNo],
	[incnUnInsPolicyLimitAcc],[incnUnderPolicyLimitAcc],[incb100Per],[incnMVLeased],[incnPriority],[incbDelete],[incnauthtodefcoun],[incnauthtodefcounDt],[incbPrimary],[saga]
)
SELECT 
	MAP.caseID					    as [incnCaseID],
	MAP.incnInsContactID			as [incnInsContactID],
	MAP.incnInsAddressID			as [incnInsAddressID],
	null							as [incbCarrierHasLienYN],
	(select intnInsuranceTypeID from [sma_MST_InsuranceType] where intsDscrptn = case when isnull(It.[type],'')<>'' then it.[type] else 'Unspecified' end ) as [incnInsType], 
	MAP.incnAdjContactId			as [incnAdjContactId],
	MAP.incnAdjAddressID			as [incnAdjAddressID],
	INS.[policy]				    as [incsPolicyNo],
	INS.claim						as [incsClaimNo],
	null							as [incnStackedTimes],
   -- isnull('accept: ' + nullif(convert(varchar,INS.accept),'') + CHAR(13),'') +
	ud.ins_comment				    as [incsComments],
	MAP.incnInsured				    as [incnInsured],
	INS.actual					    as [incnCovgAmt], 
	null							as [incnDeductible],
	ins.maximum_amount				as [incnUnInsPolicyLimit],
	ins.minimum_amount				as [incnUnderPolicyLimit],
	0							    as [incbPolicyTerm],
	0							    as [incbTotCovg],
	'P'							    as [incsPlaintiffOrDef],
--    ( select plnnPlaintiffID from sma_TRN_Plaintiff where plnnCaseID=MAP.caseID and plnbIsPrimary=1 )  
	MAP.PlaintiffDefendantID	    as [incnPlaintiffIDOrDefendantID],
	null			    as [incnTPAdminOrgID], 
	null			    as [incnTPAdminAddID],
	null			    as [incnTPAdjContactID],
	null			    as [incnTPAdjAddID],
	null			    as [incsTPAClaimNo],
	368					as [incnRecUserID],
    getdate()		    as [incdDtCreated],
    null			    as [incnModifyUserID],
    null			    as [incdDtModified],
	null			    as [incnLevelNo],
	null			    as [incnUnInsPolicyLimitAcc],
	null			    as [incnUnderPolicyLimitAcc],
	0					as [incb100Per],
	null			    as [incnMVLeased],
	null			    as [incnPriority],
	0					as [incbDelete],
	0					as [incnauthtodefcoun],
	null			    as [incnauthtodefcounDt],
	0					as [incbPrimary],
	INS.id				as [saga]
--SELECT *
FROM [NeedlesNeosBisnarChase].[dbo].[insurance] INS 
LEFT JOIN [NeedlesNeosBisnarChase].[dbo].[insurance_type] it on it.id = ins.insurancetypeid
LEFT JOIN Insurance_Comment_Helper UD on convert(varchar(50),INS.id) = convert(varchar(50),UD.insuranceid)
JOIN [Insurance_Contacts_Helper] MAP on INS.id = MAP.insurance_id and MAP.pord='P'
GO



-------------------------------------
--DEFENDANT INSURANCE
-------------------------------------
INSERT INTO [sma_TRN_InsuranceCoverage] 
(
	[incnCaseID],[incnInsContactID],[incnInsAddressID],[incbCarrierHasLienYN],[incnInsType],[incnAdjContactId],[incnAdjAddressID],[incsPolicyNo],[incsClaimNo],[incnStackedTimes],
	[incsComments],[incnInsured],[incnCovgAmt],[incnDeductible],[incnUnInsPolicyLimit],[incnUnderPolicyLimit],[incbPolicyTerm],[incbTotCovg],[incsPlaintiffOrDef],[incnPlaintiffIDOrDefendantID],
	[incnTPAdminOrgID],[incnTPAdminAddID],[incnTPAdjContactID],[incnTPAdjAddID],[incsTPAClaimNo],[incnRecUserID],[incdDtCreated],[incnModifyUserID],[incdDtModified],[incnLevelNo],
	[incnUnInsPolicyLimitAcc],[incnUnderPolicyLimitAcc],[incb100Per],[incnMVLeased],[incnPriority],[incbDelete],[incnauthtodefcoun],[incnauthtodefcounDt],[incbPrimary],[saga]
)
SELECT DISTINCT 
	MAP.caseID					    as [incnCaseID],
	MAP.incnInsContactID			as [incnInsContactID],
	MAP.incnInsAddressID			as [incnInsAddressID],
	null							as [incbCarrierHasLienYN],
	(select intnInsuranceTypeID from [sma_MST_InsuranceType] where intsDscrptn = case when isnull(It.[type],'')<>'' then it.[type] else 'Unspecified' end ) as [incnInsType], 
	MAP.incnAdjContactId			as [incnAdjContactId],
	MAP.incnAdjAddressID			as [incnAdjAddressID],
	INS.[policy]				    as [incsPolicyNo],
	INS.claim						as [incsClaimNo],
	null							as [incnStackedTimes],
    -- isnull('accept: ' + nullif(convert(varchar,INS.accept),'') + CHAR(13),'') +
	ud.ins_comment				    as [incsComments],
    MAP.incnInsured					as [incnInsured],
    INS.actual					    as [incnCovgAmt], 
    null							as [incnDeductible],
	ins.maximum_amount				as [incnUnInsPolicyLimit],
	ins.minimum_amount				as [incnUnderPolicyLimit],
    0							    as [incbPolicyTerm],
    0							    as [incbTotCovg],
    'D'							    as [incsPlaintiffOrDef],
	MAP.PlaintiffDefendantID	    as [incnPlaintiffIDOrDefendantID],
    null							as [incnTPAdminOrgID], 
    null			    as [incnTPAdminAddID],
    null			    as [incnTPAdjContactID],
    null			    as [incnTPAdjAddID],
    null			    as [incsTPAClaimNo],
    368					as [incnRecUserID],
    getdate()		    as [incdDtCreated],
    null			    as [incnModifyUserID],
    null			    as [incdDtModified],
    null			    as [incnLevelNo],
	null			    as [incnUnInsPolicyLimitAcc],
    null			    as [incnUnderPolicyLimitAcc],
    0					as [incb100Per],
    null			    as [incnMVLeased],
    null			    as [incnPriority],
    0					as [incbDelete],
    0					as [incnauthtodefcoun],
    null			    as [incnauthtodefcounDt],
    0					as [incbPrimary],
	INS.id				as [saga]
FROM [NeedlesNeosBisnarChase].[dbo].[insurance_Indexed] INS
LEFT JOIN [NeedlesNeosBisnarChase].[dbo].[insurance_type] it on it.id = ins.insurancetypeid
LEFT JOIN Insurance_Comment_Helper UD on convert(varchar(50),INS.id) = convert(varchar(50),UD.insuranceid)
JOIN [Insurance_Contacts_Helper] MAP on INS.ID = MAP.insurance_id and MAP.pord='D'
GO
---
ALTER TABLE [sma_TRN_InsuranceCoverage] ENABLE TRIGGER ALL
GO
---


---(Adjuster/Insurer association)---
INSERT INTO [sma_MST_RelContacts]
(
       [rlcnPrimaryCtgID]
      ,[rlcnPrimaryContactID]
      ,[rlcnPrimaryAddressID]
      ,[rlcnRelCtgID]
      ,[rlcnRelContactID]
      ,[rlcnRelAddressID]
      ,[rlcnRelTypeID]
      ,[rlcnRecUserID]
      ,[rlcdDtCreated]
      ,[rlcnModifyUserID]
      ,[rlcdDtModified]
      ,[rlcnLevelNo]
      ,[rlcsBizFam]
      ,[rlcnOrgTypeID]
)
SELECT DISTINCT
	1						 as [rlcnPrimaryCtgID],
	IC.[incnAdjContactId]	 as [rlcnPrimaryContactID],
	IC.[incnAdjAddressID]	 as [rlcnPrimaryAddressID],
	2						 as [rlcnRelCtgID],
	IC.[incnInsContactID]	 as [rlcnRelContactID],
	IC.[incnAdjAddressID]	 as [rlcnRelAddressID],
	2						 as [rlcnRelTypeID],
	368						 as [rlcnRecUserID],
	getdate()				 as [rlcdDtCreated],
	null					 as [rlcnModifyUserID],
	null					 as [rlcdDtModified],
	null					 as [rlcnLevelNo],
	'Business'				 as [rlcsBizFam],
	null					 as [rlcnOrgTypeID]
FROM [sma_TRN_InsuranceCoverage] IC
WHERE isnull(IC.[incnAdjContactId],0)<>0 and isnull(IC.[incnInsContactID],0)<>0  


------------------------------
--INSURANCE ADJUSTERS
------------------------------
INSERT INTO [sma_TRN_InsuranceCoverageAdjusters] (insuranceCoverageID, AdjusterContactUID)
SELECT incnInsCovgID, ioc2.UNQCID
FROM sma_TRN_InsuranceCoverage ic
JOIN [NeedlesNeosBisnarChase].[dbo].[insurance_Indexed] INS on convert(varchar(50),INS.ID) = IC.SAGA
JOIN IndvOrgContacts_Indexed IOC2 on IOC2.saga = convert(varchar(50),ins.adjuster_namesid)
