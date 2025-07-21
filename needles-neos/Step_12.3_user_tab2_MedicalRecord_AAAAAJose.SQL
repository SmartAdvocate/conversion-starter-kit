use  [SAbilleasterlyLaw]
GO

 
alter table [sma_TRN_Hospitals] disable trigger all
delete from [sma_TRN_Hospitals]
DBCC CHECKIDENT ('[sma_TRN_Hospitals]', RESEED, 0);
alter table [sma_TRN_Hospitals] enable trigger all

/*select distinct g.*
from NeosBrianWhite..neosUsertab3 u
LEFT JOIN  [NeosBillEasterly]..mini_general_dir g on g.id = u.[Type of Record]
where isnull(g.code,'') IN ('', 'Medical Records w/Affidavit','Billing Records w/Affidavit','Medical Record and Bill w/Affidavit',
	'Record and Bill','Medical Record','Medical Record and Bill','Billing','Medical Bill','MRI Reports w/Affidavit','Authorization Request',
	'MRI Billing Records w/Affidavit' )   */
 
alter table  [sma_TRN_SpDamages]  disable trigger all
delete from  [sma_TRN_SpDamages] 
DBCC CHECKIDENT ('[sma_TRN_SpDamages]', RESEED, 0);
alter table [sma_TRN_SpDamages]   enable trigger all

alter table  [sma_TRN_Visits]    disable trigger all
delete from  [sma_TRN_Visits]   
DBCC CHECKIDENT ('[sma_TRN_Visits]', RESEED, 0);
alter table [sma_TRN_Visits]     enable trigger all    

------------------------------------
--ADD SAGA BILL ID TO SP DAMAGES
------------------------------------
IF NOT EXISTS (SELECT * FROM sys.columns WHERE Name = N'saga_bill_id' AND Object_ID = Object_ID(N'sma_TRN_SpDamages'))
BEGIN
    ALTER TABLE [sma_TRN_SpDamages] 
	ADD [saga_bill_id] [varchar](100) NULL; 
END
GO
 
------------------------------------
--ADD SAGA TO VISITS
------------------------------------
IF NOT EXISTS (SELECT * FROM sys.columns WHERE Name = N'saga' AND Object_ID = Object_ID(N'sma_TRN_Visits'))
BEGIN
    ALTER TABLE [sma_TRN_Visits] 
	ADD [saga] [varchar](100) NULL; 
END
GO
 
------------------------------------
--ADD SAGA TO HOSPITALS TABLE
------------------------------------
IF NOT EXISTS (SELECT * FROM sys.columns WHERE Name = N'saga' AND Object_ID = Object_ID(N'sma_TRN_Hospitals'))
BEGIN
    ALTER TABLE [sma_TRN_Hospitals] 
	ADD [saga] [varchar](100) NULL; 
END

------------------------------------
--ADD SAGA TO MEDICAL REQUESTS TABLE
------------------------------------
IF NOT EXISTS (SELECT * FROM sys.columns WHERE Name = N'saga' AND Object_ID = Object_ID(N'sma_trn_MedicalProviderRequest'))
BEGIN
    ALTER TABLE [sma_trn_MedicalProviderRequest] 
	ADD [saga] [varchar](50) NULL; 
END

------------------------------------
--RECORD REQUEST TYPES
------------------------------------
/*INSERT INTO sma_MST_Request_RecordTypes ( RecordType )
(	SELECT DISTINCT isnull(g.code ,'Other')
	FROM  [NeosBillEasterly]..neosUsertab2 u
	LEFT JOIN  [NeosBillEasterly]..mini_general_dir g on g.id = u.[Type of Record]
	WHERE isnull(g.code,'')  IN (
    'Medical Bill',
    'Medical Record',
    'Medical Record and Bill',
    'Medical Records',
    'Medical Release',
    'Medical Authorization SSA',
    'Surgery Cost Estimate',
    'Mileage Reimbursement',
    'Pharmacy Records',
    'Panel of Doctors',
    'Pain Disability Questionnaire',
    'Final Subrogation Itemization',
    'First Report of Injury',
    'Impairment Rating Report',
    'FCE',
    'Tenncare Subrogation'
 )
EXCEPT SELECT RecordType FROM sma_MST_Request_RecordTypes
 go   */

 INSERT INTO sma_MST_Request_RecordTypes (RecordType)
SELECT DISTINCT ISNULL(g.code, 'Other')
FROM [NeosBillEasterly]..neosUsertab2 u
LEFT JOIN [NeosBillEasterly]..mini_general_dir g 
    ON g.id = u.[Type of Record]
WHERE ISNULL(g.code, '') IN (
    'Medical Bill',    
    'Medical Record',    
    'Medical Record and Bill',    
    'Medical Records',    
    'Medical Release',    
    'Medical Authorization SSA',    
    'Surgery Cost Estimate',    
    'Mileage Reimbursement',    
    'Pharmacy Records',    
    'Panel of Doctors',     
    'Pain Disability Questionnaire',
    'Final Subrogation Itemization',
    'First Report of Injury',   
    'Impairment Rating Report',   
    'FCE',  
    'Tenncare Subrogation',     
	'TDOL Medical Waiver',     
	'Patient Intake Forms'     
) 
AND ISNULL(g.code, 'Other') NOT IN (
    SELECT RecordType FROM sma_MST_Request_RecordTypes
);

------------------------------------
--REQUEST STATUS
------------------------------------
INSERT INTO sma_MST_RequestStatus ( Status, Description )
SELECT 'No Record Available','No Record Available'
EXCEPT
SELECT Status,Description FROM sma_MST_RequestStatus
GO

------------------------------------
--MEDICAL PROVIDER HELPER
------------------------------------
IF EXISTS (select * from sys.objects where name='user_tab2_MedicalProvider_Helper' and type='U')
BEGIN
	drop table user_tab2_MedicalProvider_Helper
END 
GO

---(0)---
CREATE TABLE user_tab2_MedicalProvider_Helper (
    TableIndex [int] IDENTITY(1,1) NOT NULL,
	case_id				varchar(50),
	tab_id				varchar(50),
	ProviderNameId		varchar(50),
	ProviderName		varchar(200),
	ProviderCID			int,
	ProviderCTG			int,
	ProviderAID			int,
	--CounselOrderingCID		int,
	--CounselOrderingCTG		int,
	--CounselOrderingAID		int,
	casnCaseID			int,
CONSTRAINT IOC_Clustered_Index_user_tab2_MedicalProvider_Helper PRIMARY KEY CLUSTERED ( TableIndex )
) ON [PRIMARY] 
GO

CREATE NONCLUSTERED INDEX IX_NonClustered_Index_user_tab2_MedicalProvider_Helper_case_id ON [user_tab2_MedicalProvider_Helper] (case_id);   
CREATE NONCLUSTERED INDEX IX_NonClustered_Index_user_tab2_MedicalProvider_Helper_tab_id ON [user_tab2_MedicalProvider_Helper] (tab_id);   
CREATE NONCLUSTERED INDEX IX_NonClustered_Index_user_tab2_MedicalProvider_Helper_ProviderNameId ON [user_tab2_MedicalProvider_Helper] (ProviderNameId);   
GO

---(0)---
INSERT INTO user_tab2_MedicalProvider_Helper ( case_id,tab_id,ProviderNameId,ProviderName,ProviderCID,ProviderCTG,ProviderAID,casnCaseID )
SELECT
    u.CasesID			   as case_id,		
    u.tablistid			   as tab_id,		--NEEDLES RECORDS TAB ITEM
    u.[Provider Name]	   as ProviderNameId,  
    IOC.[Name]			   as ProviderName,
    IOC.CID				   as ProviderCID,  
    IOC.CTG				   as ProviderCTG,
    IOC.AID				   as ProviderAID,
    CAS.casnCaseID		   as casnCaseID  
---- select *
from [NeosBillEasterly]..neosUsertab2 u
LEFT JOIN  [NeosBillEasterly]..mini_general_dir g on g.id = u.[Type of Record]
JOIN [IndvOrgContacts_Indexed] IOC on IOC.SAGA_ref= convert(varchar(50),u.[Provider Name])
JOIN [sma_TRN_Cases] CAS on CAS.Neos_Saga = u.casesid
WHERE isnull(g.code,'') IN  (
        'Medical Bill',    
    'Medical Record',    
    'Medical Record and Bill',    
    'Medical Records',    
    'Medical Release',    
    'Medical Authorization SSA',    
    'Surgery Cost Estimate',    
    'Mileage Reimbursement',    
    'Pharmacy Records',    
    'Panel of Doctors',     
    'Pain Disability Questionnaire',
    'Final Subrogation Itemization',
    'First Report of Injury',   
    'Impairment Rating Report',   
    'FCE',  
    'Tenncare Subrogation',     
	'TDOL Medical Waiver',     
	'Patient Intake Forms'     
 )


---(0)---
DBCC DBREINDEX('user_tab2_MedicalProvider_Helper',' ',90)  WITH NO_INFOMSGS 
GO

---
ALTER TABLE [sma_TRN_Hospitals] DISABLE TRIGGER ALL
GO
ALTER TABLE [sma_trn_MedicalProviderRequest] DISABLE TRIGGER ALL
GO
--alter table [sma_TRN_SpDamages] disable trigger all
--GO
--alter table [sma_TRN_Visits] disable trigger all
--GO

--------------------------------------------------------------------------
---------------------------- MEDICAL PROVIDERS ---------------------------
--------------------------------------------------------------------------
INSERT INTO [sma_TRN_Hospitals]
 (	[hosnCaseID], 
	[hosnContactID], 
	[hosnContactCtg],
	[hosnAddressID], 
	[hossMedProType], 
	[hosdStartDt],
	[hosdEndDt],
	[hosnPlaintiffID],
	[hosnComments], 
	[hosnHospitalChart], 
	[hosnRecUserID],
	[hosdDtCreated], 
	[hosnModifyUserID],
	[hosdDtModified],
	[saga]
)
SELECT DISTINCT
    casnCaseID				as [hosnCaseID], 
    ProviderCID				as [hosnContactID],
    ProviderCTG				as [hosnContactCtg],
    ProviderAID				as [hosnAddressID], 
     'M' 					as [hossMedProType],			--M or P (P for Prior Medical Provider)
    NULL 					as [hosdStartDt],
    NULL 					as [hosdEndDt],
    ( select top 1 plnnPlaintiffID FROM [sma_TRN_Plaintiff] WHERE plnnCaseID = MAP.casnCaseID and plnbIsPrimary=1) 
							as hosnPlaintiffID,
	''						as [hosnComments],
	null					as [hosnHospitalChart],
    368						as [hosnRecUserID],
    getdate()				as [hosdDtCreated],
    null					as [hosnModifyUserID],
    null					as [hosdDtModified],
    'tab2'					as [saga]
	--'tab2:'+convert(varchar,UD.tab_id)	as [saga]
----select *
FROM  [NeosBillEasterly]..neosUsertab2 d
JOIN user_tab2_MedicalProvider_Helper MAP on MAP.case_id = convert(varchar(50),D.casesid) and MAP.tab_id= convert(varchar(50),D.tablistid)
LEFT JOIN [sma_TRN_Hospitals] H on H.hosnCaseID=MAP.casnCaseID and H.hosnContactID=MAP.ProviderCID and H.hosnContactCtg=MAP.ProviderCTG and H.hosnAddressID=MAP.ProviderAID 
WHERE H.hosnHospitalID is null	--only add the hospital if it does not already exist
GO

--------------------------------------------------------------------------
---------------------------- MEDICAL REQUESTS ----------------------------
--------------------------------------------------------------------------
INSERT INTO [sma_trn_MedicalProviderRequest]
(
    MedPrvCaseID,
    MedPrvPlaintiffID,
    MedPrvhosnHospitalID,
    MedPrvRecordType,
    MedPrvRequestdate,
    MedPrvAssignee,
    MedPrvAssignedBy,
	MedPrvHighPriority,
    MedPrvFromDate,
    MedPrvToDate,
    MedPrvComments,
	MedPrvNotes,
    MedPrvCompleteDate,
    MedPrvStatusId,
    MedPrvFollowUpDate,
	MedPrvStatusDate,
	OrderAffidavit,
	FollowUpNotes,		--Retrieval Provider Notes
	SAGA
)
SELECT 
    hosnCaseID					 as MedPrvCaseID,
    hosnPlaintiffID				 as MedPrvPlaintiffID,
    H.hosnHospitalID			 as MedPrvhosnHospitalID,
    (select uId from sma_MST_Request_RecordTypes where RecordType = isnull(g.code ,'Other')) 	   							 as MedPrvRecordType,
    case when ( UD.[Date Requested] between '1900-01-01' and '2079-06-06') then UD.[Date Requested]  else null end	 as MedPrvRequestdate,
    null						 as MedPrvAssignee,
    (select usrnUserID From sma_mst_users u join sma_MST_IndvContacts i on u.usrnContactID = i.cinnContactID where i.cinsGrade = ud.[Ordered By])			 as MedPrvAssignedBy,
    0							 as MedPrvHighPriority,		--1=high priority; 0=Normal
    NULL						 as MedPrvFromDate,
    NULL						 as MedPrvToDate,
    
	''																											as MedPrvComments,
 
	''																											as MedPrvNotes,
    case when ( UD.[Date Received] between '1900-01-01' and '2079-06-06') then UD.[Date Received] else null end		as MedPrvCompleteDate,
    case when (UD.[Date Received] between '1900-01-01' and '2079-06-06') then (select uId from [sma_MST_RequestStatus] where [status]='Received')
	   else null end							as MedPrvStatusId,
    NULL										as MedPrvFollowUpDate,
	case when (UD.[Date Received] between '1900-01-01' and '2079-06-06') 
				then (select uId from [sma_MST_RequestStatus] where [status]='Received')						 
	   else null end			as MedPrvStatusDate,
	NULL						as OrderAffidavit,	--bit
	''												as FollowUpNotes,	--Retreival Provider Notes
	'tab2: '+convert(varchar(50),UD.tablistid)			as SAGA
--select *
FROM  [NeosBillEasterly]..neosUsertab2 UD
JOIN [NeosBillEasterly] ..mini_general_dir g on g.id = convert(varchar(50),  ud.[Type of Record])             
 LEFT JOIN  [NeosBillEasterly]..value_code vc on convert(varchar(50), vc.id) = convert(varchar(50),  ud.[value Code])
  LEFT JOIN  [NeosBillEasterly]..mini_general_dir me on me.id = convert(varchar(50),  ud.[method])
 JOIN user_tab2_MedicalProvider_Helper MAP on MAP.case_id= convert(varchar(50),UD.caseSid) and MAP.tab_id = convert(varchar(50),UD.tablistid)
---- LEFT JOIN IndvOrgContacts_Indexed iocalt on iocalt.saga_ref = convert(varchar(50),ud.[Alternate Provider])
 JOIN [sma_TRN_Hospitals] H on H.hosnContactID= convert(varchar(50),  MAP.ProviderCID) and H.hosnContactCtg=MAP.ProviderCTG and H.hosnCaseID=MAP.casnCaseID
GO


 
--------------------------------------------------------------------------
------------------------------ MEDICAL VISITS -----------------------------
--------------------------------------------------------------------------
/* insert into   [dbo].[sma_TRN_Visits]
(
       [vissRefTable]
      ,[visnRecordID]
      ,[visdAdmissionDt]
      ,[visnAdmissionTypeID]
      ,[visdDischargeDt]
      ,[vissAccountNo]
	  ,[vissComplaint]
	  ,[vissDiagnosis]
      ,[visnRecUserID]
      ,[visdDtCreated]
      ,[visnModifyUserID]
      ,[visdDtModified]
	  ,[vissTreatmentPlan]
	  ,[vissComments]
)
select 
    'Hospitals'			  as [vissRefTable],
    H.hosnHospitalID	   as [visnRecordID],
    NULL				   as [visdAdmissionDt],
    (select amtnAdmsnTypeID from sma_MST_AdmissionType where amtsDscrptn='Office Visit')  as [visnAdmissionTypeID],
    NULL				   as [visdDischargeDt],
    NULL				   as [vissAccountNo],
    NULL				   as [vissComplaint],
    d.Findings			   as [vissDiagnosis],
    368					   as [visnRecUserID],
    getdate()			   as [visdDtCreated],
    NULL				   as [visnModifyUserID],
    NULL				   as [visdDtModified],
    d.Treatment_Received		   as [vissTreatmentPlan],
    null				   as [vissComments]
from [NeosBillEasterly] .[dbo].[user_tab2_data] d
inner join user_tab2_MedicalProvider_Helper MAP on MAP.tab_ID=d.tab_id
inner join   [dbo].[sma_TRN_Hospitals] H on H.hosnCaseID=MAP.casnCaseID and H.hosnContactID=MAP.ProviderCID and H.hosnContactCtg=MAP.ProviderCTG and H.hosnAddressID=MAP.ProviderAID 
WHERE isnull(Treatment_Received,'')<> '' or
isnull(findings,'')<>''  */

--------------------------------------------------------------------------
------------------------------ MEDICAL BILLS -----------------------------
--------------------------------------------------------------------------
 
 WITH SourceData AS (
    SELECT 
        D.*, 
        H.hosnHospitalID 
    FROM [NeosBillEasterly].[dbo].[user_tab2_data] D
    INNER JOIN user_tab2_MedicalProvider_Helper MAP 
        ON MAP.tab_id = D.tablistid
    INNER JOIN [sma_TRN_Hospitals] H 
        ON H.hosnContactID = MAP.ProviderCID
        AND H.hosnContactCtg = MAP.ProviderCTG
        AND H.hosnAddressID = MAP.ProviderAID
        AND H.hosnCaseID = MAP.casnCaseID
)

insert into   [SAbilleasterlyLaw].[dbo].[sma_TRN_SpDamages]
(
     [spdsRefTable]
    ,[spdnRecordID]
    ,[spdnBillAmt]
    ,[spdsAccntNo]
    ,[spddNegotiatedBillAmt]
    ,[spddDateFrom]
    ,[spddDateTo]
    ,[spddDamageSubType]
    ,[spdnVisitId]
    ,[spdsComments]
    ,[spdnRecUserID]
    ,[spddDtCreated]
    ,[spdnModifyUserID]
    ,[spddDtModified]
    ,[spdnBalance]
    ,[spdbLienConfirmed]
    ,[spdbDocAttached]
    ,[saga_bill_id]
)
SELECT 
    'Hospitals'                             AS spdsRefTable,
    hosnHospitalID                          AS spdnRecordID,
    null                                   AS spdnBillAmt,
    NULL                                    AS spdsAccntNo,
    NULL                                    AS spdNegotiatedBillAmt,
    NULL                                    AS spddDateFrom,
    NULL                                    AS spddDateTo,
    NULL                                    AS spddDamageSubType,
    NULL                                    AS spdnVisitId,
    ''                                      AS spdsComments,
    368                                     AS spdnRecordID,
    GETDATE()                               AS spddDtCreated,
    NULL                                    AS spdnModifyUserID,
    NULL                                    AS spddDtModified,
    NULL                                    AS spdnBalance,
    0                                       AS spdbLienConfirmed,
    0                                       AS spdbDocAttached,
    'tab2:' + CAST(tablistid AS VARCHAR(36)) AS saga_bill_id

FROM SourceData;

---(Appendix)--- Update hospital TotalBill from Bill section
UPDATE [sma_TRN_Hospitals]
SET hosnTotalBill = (SELECT SUM(spdnBillAmt) 
                                  FROM sma_TRN_SpDamages
								  WHERE sma_TRN_SpDamages.spdsRefTable='Hospitals' 
								        AND sma_TRN_SpDamages.spdnRecordID = hosnHospitalID)

UPDATE [sma_TRN_Hospitals]
SET hosnTotalMedicalVisits = (SELECT count(*) 
                                                    FROM sma_TRN_Visits
												 WHERE sma_TRN_Visits.vissRefTable='Hospitals' 
												      AND sma_TRN_Visits.visnRecordID = hosnHospitalID)

 


---
ALTER TABLE [sma_trn_MedicalProviderRequest] ENABLE TRIGGER ALL
GO
ALTER TABLE [sma_TRN_Hospitals] ENABLE TRIGGER ALL
GO
--alter table [sma_TRN_SpDamages] enable trigger all
--GO
--alter table [sma_TRN_Visits] enable trigger all
--GO



