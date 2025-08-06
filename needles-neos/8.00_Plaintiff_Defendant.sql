
USE  [SAbilleasterlyLaw]
GO
 
alter table [sma_TRN_Defendants] disable trigger all
delete from [sma_TRN_Defendants] 
DBCC CHECKIDENT ('[sma_TRN_Defendants]', RESEED, 0);
alter table [sma_TRN_Defendants] enable trigger all

alter table [sma_TRN_Plaintiff] disable trigger all
delete from [sma_TRN_Plaintiff] 
DBCC CHECKIDENT ('[sma_TRN_Plaintiff]', RESEED, 0);
alter table [sma_TRN_Plaintiff] enable trigger all

 
 

---(0)---
IF NOT EXISTS (SELECT * FROM sys.columns WHERE Name = N'saga_party' AND Object_ID = Object_ID(N'sma_TRN_Plaintiff'))
BEGIN
    ALTER TABLE [sma_TRN_Plaintiff] ADD [saga_party] varchar(50) NULL; 
END

IF NOT EXISTS (SELECT * FROM sys.columns WHERE Name = N'source_ref' AND Object_ID = Object_ID(N'sma_TRN_Plaintiff'))
BEGIN
    ALTER TABLE [sma_TRN_Plaintiff] ADD [source_ref] varchar(50) NULL; 
END

IF NOT EXISTS (SELECT * FROM sys.columns WHERE Name = N'saga_party' AND Object_ID = Object_ID(N'sma_TRN_Defendants'))
BEGIN
    ALTER TABLE [sma_TRN_Defendants] ADD [saga_party] varchar(50) NULL; 
END

IF NOT EXISTS (SELECT * FROM sys.columns WHERE Name = N'source_ref' AND Object_ID = Object_ID(N'sma_TRN_Defendants'))
BEGIN
    ALTER TABLE [sma_TRN_Defendants] ADD [source_ref] varchar(50) NULL; 
END


---
ALTER TABLE [sma_TRN_Plaintiff] DISABLE TRIGGER ALL
GO
ALTER TABLE [sma_TRN_Defendants] DISABLE TRIGGER ALL
GO
---

-------(1) sma_TRN_Plaintiff
INSERT INTO [sma_TRN_Plaintiff]
(
 [plnnCaseID],[plnnContactCtg],[plnnContactID],[plnnAddressID],[plnnRole],[plnbIsPrimary],[plnbWCOut],[plnnPartiallySettled],[plnbSettled],[plnbOut],
 [plnbSubOut],[plnnSeatBeltUsed],[plnnCaseValueID],[plnnCaseValueFrom],[plnnCaseValueTo],[plnnPriority],[plnnDisbursmentWt],[plnbDocAttached],[plndFromDt],
 [plndToDt],[plnnRecUserID],[plndDtCreated],[plnnModifyUserID],[plndDtModified],[plnnLevelNo],[plnsMarked],[saga],[plnnNoInj],[plnnMissing],
 [plnnLIPBatchNo],[plnnPlaintiffRole],[plnnPlaintiffGroup],[plnnPrimaryContact],[plnsComments],[plnbIsClient],[saga_party], source_ref
)
SELECT distinct 
	CAS.casnCaseID			as [plnnCaseID],
	CIO.CTG					as [plnnContactCtg],
	CIO.CID					as [plnnContactID],
	CIO.AID					as [plnnAddressID],
	S.sbrnSubRoleId			as [plnnRole],
	case when 	pr.BillEasterlyRole in ( 'Plaintiff', 'Claimant' , 'Member')   then 1
	        when     pr.BillEasterlyRole ='Companion Pltf'  then 0   
	end as [plnbIsPrimary],
	0,0,0,0,0,0,null,null,null,null,null,null,GETDATE(),null,
	  cas.casnRecUserID 	as [plnnRecUserID],
	cas.casdOpeningDate			as [plndDtCreated],
	cas.casnModifyUserID 	as [plnnModifyUserID],
	cas.casdLastModifiedDate 			as [plndDtModified],
	null					as [plnnLevelNo],  
	null,'',null,null,null,null,null,
	1						as [plnnPrimaryContact],
	isnull('Relationship: ' + nullif(convert(varchar,p.relationship),'') + CHAR(13),'') +
	''						as [plnsComments],
	p.our_client			as [plnbIsClient],
	P.id					as [saga_party],
	'Neos..party_indexed.id'                      as source_ref
--SELECT     p.*  cas.casnCaseid, cassCaseNumber ,  pr.BillEasterlyRole, prl.[role]
FROM  [NeosBillEasterly].[dbo].[party_indexed] P 
JOIN [sma_TRN_Cases] CAS on CAS.Neos_saga = convert(varchar(50),P.casesid)
JOIN IndvOrgContacts_Indexed CIO on CIO.saga_ref = convert(varchar(50),P.namesid)
JOIN [NeosBillEasterly] ..party_role_list prl on prl.id = p.partyrolelistid
JOIN [PartyRoles] pr on pr.BillEasterlyRole = prl.[role]
JOIN [sma_MST_SubRole] S on CAS.casnOrgCaseTypeID = S.sbrnCaseTypeID and s.sbrsDscrptn = pr.SARole and  S.sbrnRoleID=4
WHERE pr.BillEasterlyRole in ( 'Plaintiff' ,   'Companion Pltf' , 'Claimant' , 'Member' ) and pr.SAParty = 'Plaintiff'
 order by cas.casnCaseid
GO
 
 ---- select * from [sma_MST_SubRole] where sbrnRoleID=4

-------- (1.1) Client requirement to put Criminal Defendants to Plaintiff 
INSERT INTO [sma_TRN_Plaintiff]
(
 [plnnCaseID],[plnnContactCtg],[plnnContactID],[plnnAddressID],[plnnRole],[plnbIsPrimary],[plnbWCOut],[plnnPartiallySettled],[plnbSettled],[plnbOut],
 [plnbSubOut],[plnnSeatBeltUsed],[plnnCaseValueID],[plnnCaseValueFrom],[plnnCaseValueTo],[plnnPriority],[plnnDisbursmentWt],[plnbDocAttached],[plndFromDt],
 [plndToDt],[plnnRecUserID],[plndDtCreated],[plnnModifyUserID],[plndDtModified],[plnnLevelNo],[plnsMarked],[saga],[plnnNoInj],[plnnMissing],
 [plnnLIPBatchNo],[plnnPlaintiffRole],[plnnPlaintiffGroup],[plnnPrimaryContact],[plnsComments],[plnbIsClient],[saga_party], source_ref
)
SELECT distinct 
	CAS.casnCaseID			as [plnnCaseID],
	CIO.CTG					as [plnnContactCtg],
	CIO.CID					as [plnnContactID],
	CIO.AID					as [plnnAddressID],
	 25396			as [plnnRole],
	 1         as  [plnbIsPrimary],
	0,0,0,0,0,0,null,null,null,null,null,null,GETDATE(),null,
	  cas.casnRecUserID 	as [plnnRecUserID],
	cas.casdOpeningDate			as [plndDtCreated],
	cas.casnModifyUserID 	as [plnnModifyUserID],
	cas.casdLastModifiedDate 			as [plndDtModified],
	null					as [plnnLevelNo],  
	null,'',null,null,null,null,null,
	1						as [plnnPrimaryContact],
	isnull('Relationship: ' + nullif(convert(varchar,p.relationship),'') + CHAR(13),'') +
	''						as [plnsComments],
	p.our_client			as [plnbIsClient],
	P.id					as [saga_party],
	'Neos..party_indexed.id'                      as source_ref
--SELECT     p.*              
    FROM  [NeosBillEasterly].[dbo].[party_indexed] P 
 join [sma_TRN_Cases] CAS on CAS.Neos_saga = convert(varchar(50),P.casesid)
   JOIN IndvOrgContacts_Indexed CIO on CIO.saga_ref = convert(varchar(50),P.namesid)
 JOIN [NeosBillEasterly] ..party_role_list prl on prl.id = p.partyrolelistid
 JOIN [PartyRoles] pr on pr.BillEasterlyRole = prl.[role]
 where cas.casnOrgCaseTypeID = 1577      and prl.role in (  'Defendant'  )
 
 


select * from [sma_MST_SubRole]
---( Now. do special role assignment )
/* 
DECLARE @needles_role varchar(100);
DECLARE @sa_role varchar(100);
DECLARE role_cursor CURSOR FOR 
SELECT  BillEasterlyRole,[SARole] FROM   [PartyRoles] where [SAParty]='Plaintiff'
 
OPEN role_cursor 
FETCH NEXT FROM role_cursor INTO @needles_role,@sa_role
WHILE @@FETCH_STATUS = 0
BEGIN

    update [dbo].[sma_TRN_Plaintiff] set plnnRole=S.sbrnSubRoleId
	---select *
    from  [NeosBillEasterly].[dbo].[party_indexed] P 
    inner join  [sma_TRN_Cases] CAS on CAS.Neos_saga = P.casesid  
    inner join  [dbo].[sma_MST_SubRole] S on CAS.casnOrgCaseTypeID = S.sbrnCaseTypeID and S.sbrnRoleID=4 and S.sbrsDscrptn=@sa_role
    inner join IndvOrgContacts_Indexed CIO on CIO.SAGA = P.namesid
    where P.role=@needles_role
    and P.TableIndex=saga_party 

FETCH NEXT FROM role_cursor INTO @needles_role,@sa_role
END 
CLOSE role_cursor;
DEALLOCATE role_cursor;
GO
 */
  
-------(2) [sma_TRN_Defendants]
 ---select *  from [sma_TRN_Defendants] 

INSERT INTO [sma_TRN_Defendants]
(
    [defnCaseID], [defnContactCtgID], [defnContactID], [defnAddressID], [defnSubRole],
    [defbIsPrimary], [defbCounterClaim], [defbThirdParty], [defsThirdPartyRole], [defnPriority],
    [defdFrmDt], [defdToDt], [defnRecUserID], [defdDtCreated], [defnModifyUserID], [defdDtModified],
    [defnLevelNo], [defsMarked], [saga], [defsComments], [defbIsClient], [saga_party], source_ref
)
SELECT 
    CAS.casnCaseID,
    ACIO.CTG,
    ACIO.CID,
    ACIO.AID,
    S.sbrnSubRoleId,
    1,
    NULL, NULL, NULL, NULL,
    NULL, NULL,
    cas.casnRecUserID,
    cas.casdOpeningDate,
    cas.casnModifyUserID,
    cas.casdLastModifiedDate,
    NULL,
    NULL,
    NULL,
    ISNULL('Relationship: ' + NULLIF(CONVERT(varchar, p.relationship), '') + CHAR(13), '') + '',
    p.our_client,
    P.id,
	'Neos..party_indexed.id'
FROM [NeosBillEasterly].[dbo].[party_indexed] P
JOIN [sma_TRN_Cases] CAS ON CAS.Neos_saga = CONVERT(varchar(50), P.casesid)
JOIN IndvOrgContacts_Indexed ACIO ON ACIO.saga_ref = CONVERT(varchar(50), P.namesid)
JOIN [NeosBillEasterly]..party_role_list prl ON prl.id = p.partyrolelistid
JOIN [PartyRoles] pr ON pr.BillEasterlyRole = prl.[role]
JOIN [sma_MST_SubRole] S ON CAS.casnOrgCaseTypeID = S.sbrnCaseTypeID 
                         AND S.sbrsDscrptn = pr.SARole 
                         AND S.sbrnRoleID = 5
WHERE pr.BillEasterlyRole IN ('Defendant', 'Employer')
  AND pr.SAParty = 'Defendant'
  AND NOT EXISTS (
        SELECT 1
        FROM [sma_TRN_Plaintiff] pl
        WHERE pl.plnnCaseID = CAS.casnCaseID
          AND pl.plnnContactID = ACIO.CID
    )
ORDER BY cas.casnCaseID;



/*
from [NeosBrianWhite].[dbo].[party_indexed] P 
inner join [SANeosBrianWhite].[dbo].[sma_TRN_Cases] C on C.cassCaseNumber = P.case_id  
inner join [SANeosBrianWhite].[dbo].[sma_MST_SubRole] S on C.casnOrgCaseTypeID = S.sbrnCaseTypeID
inner join IndvOrgContacts_Indexed ACIO on ACIO.SAGA_REF = P.party_id
where S.sbrnRoleID=5 and S.sbrsDscrptn='(D)-Default Role'
and P.role in (SELECT [Needles Roles] FROM [SANeosBrianWhite].[dbo].[PartyRoles] where [SA Party]='Defendant')
GO

---( Now. do special role assignment )
DECLARE @needles_role varchar(100);
DECLARE @sa_role varchar(100);
DECLARE role_cursor CURSOR FOR 
SELECT [Needles Roles],[SA Roles] FROM [SANeosBrianWhite].[dbo].[PartyRoles] where [SA Party]='Defendant'
 
OPEN role_cursor 
FETCH NEXT FROM role_cursor INTO @needles_role,@sa_role
WHILE @@FETCH_STATUS = 0
BEGIN


    update [SANeosBrianWhite].[dbo].[sma_TRN_Defendants] set defnSubRole=S.sbrnSubRoleId
    from [NeosBrianWhite].[dbo].[party_indexed] P 
    inner join [SANeosBrianWhite].[dbo].[sma_TRN_Cases] C on C.cassCaseNumber = P.case_id  
    inner join [SANeosBrianWhite].[dbo].[sma_MST_SubRole] S on C.casnOrgCaseTypeID = S.sbrnCaseTypeID and S.sbrnRoleID=5 and S.sbrsDscrptn=@sa_role
    inner join IndvOrgContacts_Indexed ACIO on ACIO.SAGA_REF = P.party_id
    where P.role=@needles_role
    and P.TableIndex=saga_party 

FETCH NEXT FROM role_cursor INTO @needles_role,@sa_role
END 
CLOSE role_cursor;
DEALLOCATE role_cursor;
GO
*/
---(Appendix A)-- every case need at least one plaintiff
INSERT INTO [sma_TRN_Plaintiff]
(
 [plnnCaseID],[plnnContactCtg],[plnnContactID],[plnnAddressID],[plnnRole],[plnbIsPrimary],[plnbWCOut],[plnnPartiallySettled],[plnbSettled],[plnbOut],
 [plnbSubOut],[plnnSeatBeltUsed],[plnnCaseValueID],[plnnCaseValueFrom],[plnnCaseValueTo],[plnnPriority],[plnnDisbursmentWt],[plnbDocAttached],[plndFromDt],
 [plndToDt],[plnnRecUserID],[plndDtCreated],[plnnModifyUserID],[plndDtModified],[plnnLevelNo],[plnsMarked],[saga],[plnnNoInj],[plnnMissing],
 [plnnLIPBatchNo],[plnnPlaintiffRole],[plnnPlaintiffGroup],[plnnPrimaryContact]
)

SELECT 
	casnCaseID		   as [plnnCaseID],
	1				   as [plnnContactCtg],
	(Select cinncontactid from sma_MST_IndvContacts where cinsFirstName = 'Plaintiff' and cinsLastName = 'Unidentified')   as [plnnContactID],   -- Unidentified Plaintiff
	NULL			   as [plnnAddressID],
	(select sbrnSubRoleId from sma_MST_SubRole S inner join sma_MST_SubRoleCode C on C.srcnCodeId = S.sbrnTypeCode and C.srcsDscrptn='(P)-Default Role'
	where S.sbrnCaseTypeID=CAS.casnOrgCaseTypeID)	 as plnnRole,
	1				   as [plnbIsPrimary],
	0,0,0,0,0,0,null,null,null,null,null,null,GETDATE(),null,
	368				   as [plnnRecUserID],
	GETDATE()		   as [plndDtCreated],
	null,null,'',null,'',null,null,null,null,null,
	1				   as [plnnPrimaryContact] 
----select t.* 
FROM sma_trn_cases CAS
left   JOIN [sma_TRN_Plaintiff] T on T.plnnCaseID=CAS.casnCaseID
WHERE plnnCaseID is null
GO

/*UPDATE sma_TRN_Plaintiff set plnbIsPrimary=1

 UPDATE sma_TRN_Plaintiff
SET plnbIsPrimary = 0
WHERE PlnnPlaintiffID IN (
    SELECT pl.plnnPlaintiffID
    FROM sma_TRN_Plaintiff pl
    LEFT JOIN [NeosBillEasterly]..Party_Indexed p ON pl.saga_party = p.id
    JOIN [NeosBillEasterly]..party_role_list pr ON p.partyrolelistid = pr.id
    WHERE pr.role = 'Companion Pltf'
);

 FROM
(
SELECT DISTINCT 
	   T.plnnCaseID, ROW_NUMBER() OVER (Partition BY T.plnnCaseID order by P.record_num) as RowNumber,
	   T.plnnPlaintiffID as ID  
    FROM sma_TRN_Plaintiff T
    LEFT JOIN  [NeosBillEasterly].[dbo].[party_indexed] P on P.[namesid]=T.saga_party
) A
WHERE A.RowNumber=1
and plnnPlaintiffID = A.ID       */



---(Appendix B)-- every case need at least one defendant
INSERT INTO [sma_TRN_Defendants]
   (
	[defnCaseID],[defnContactCtgID],[defnContactID],[defnAddressID],[defnSubRole],[defbIsPrimary],[defbCounterClaim],[defbThirdParty],
    [defsThirdPartyRole],[defnPriority],[defdFrmDt],[defdToDt],[defnRecUserID],[defdDtCreated],[defnModifyUserID],[defdDtModified],
    [defnLevelNo],[defsMarked],[saga]
   )
SELECT 
	casnCaseID	    as [defnCaseID],
	1			    as [defnContactCtgID],
	(Select cinncontactid from sma_MST_IndvContacts where cinsFirstName = 'Defendant' and cinsLastName = 'Unidentified')			    as [defnContactID],
	null		    as [defnAddressID],
	(select sbrnSubRoleId from sma_MST_SubRole S inner join sma_MST_SubRoleCode C on C.srcnCodeId = S.sbrnTypeCode and C.srcsDscrptn='(D)-Default Role' 
	where S.sbrnCaseTypeID=CAS.casnOrgCaseTypeID)	 as [defnSubRole],
	1			    as [defbIsPrimary], -- reexamine??
	null,null,null,null,null,null,
	368			    as [defnRecUserID],
	GETDATE()	    as [defdDtCreated],
	368			    as [defnModifyUserID],
	GETDATE()	    as [defdDtModified],
	null,null,null
FROM sma_trn_cases CAS
LEFT JOIN [sma_TRN_Defendants] D on D.defnCaseID=CAS.casnCaseID
WHERE D.defnCaseID is null

----
UPDATE sma_TRN_Defendants SET defbIsPrimary=0

UPDATE sma_TRN_Defendants SET defbIsPrimary=1
FROM (
    SELECT DISTINCT 
		D.defnCaseID, 
		ROW_NUMBER() OVER (Partition BY D.defnCaseID order by P.record_num) as RowNumber,
		D.defnDefendentID as ID  
    FROM sma_TRN_Defendants D
    LEFT JOIN  [NeosBillEasterly].[dbo].[party_indexed] P on P.[id]=D.saga_party
) A
WHERE A.RowNumber=1
and defnDefendentID = A.ID

GO

---
ALTER TABLE [sma_TRN_Defendants] ENABLE TRIGGER ALL
GO
ALTER TABLE [sma_TRN_Plaintiff] ENABLE TRIGGER ALL
GO
---






select def.defnContactCtgID, def.defnContactID, def.defnAddressID, def.*
from sma_TRN_Defendants def
join sma_trn_cases  cas   on cas.casnCaseID = def.defnCaseID
  where casnCaseTypeID =  11573
