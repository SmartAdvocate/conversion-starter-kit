
USE SA
GO
/*
alter table [sma_TRN_Defendants] disable trigger all
delete from [sma_TRN_Defendants] 
DBCC CHECKIDENT ('[sma_TRN_Defendants]', RESEED, 0);
alter table [sma_TRN_Defendants] enable trigger all

alter table [sma_TRN_Plaintiff] disable trigger all
delete from [sma_TRN_Plaintiff] 
DBCC CHECKIDENT ('[sma_TRN_Plaintiff]', RESEED, 0);
alter table [sma_TRN_Plaintiff] enable trigger all

select * from [sma_TRN_Plaintiff] enable trigger all
*/

---(0)---
IF NOT EXISTS (SELECT * FROM sys.columns WHERE Name = N'saga_party' AND Object_ID = Object_ID(N'sma_TRN_Plaintiff'))
BEGIN
    ALTER TABLE [sma_TRN_Plaintiff] ADD [saga_party] varchar(50) NULL; 
END

IF NOT EXISTS (SELECT * FROM sys.columns WHERE Name = N'saga_party' AND Object_ID = Object_ID(N'sma_TRN_Defendants'))
BEGIN
    ALTER TABLE [sma_TRN_Defendants] ADD [saga_party] varchar(50) NULL; 
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
 [plnnLIPBatchNo],[plnnPlaintiffRole],[plnnPlaintiffGroup],[plnnPrimaryContact],[plnsComments],[plnbIsClient],[saga_party]
)
SELECT 
	CAS.casnCaseID			as [plnnCaseID],
	CIO.CTG					as [plnnContactCtg],
	CIO.CID					as [plnnContactID],
	CIO.AID					as [plnnAddressID],
	S.sbrnSubRoleId			as [plnnRole],
	1						as [plnbIsPrimary],
	0,0,0,0,0,0,null,null,null,null,null,null,GETDATE(),null,
	(select usrnUserID from sma_mst_users where saga = p.staffcreatedid) 	as [plnnRecUserID],
	p.date_created			as [plndDtCreated],
	(select usrnUserID from sma_mst_users where saga = p.staffmodifiedid)	as [plnnModifyUserID],
	p.date_modified			as [plndDtModified],
	null					as [plnnLevelNo],  
	null,'',null,null,null,null,null,
	1						as [plnnPrimaryContact],
	isnull('Relationship: ' + nullif(convert(varchar,p.relationship),'') + CHAR(13),'') +
	''						as [plnsComments],
	p.our_client			as [plnbIsClient],
	P.id					as [saga_party]
--SELECT *
FROM [NeedlesNeosBisnarChase].[dbo].[party_indexed] P 
JOIN [sma_TRN_Cases] CAS on CAS.Needles_saga = convert(varchar(50),P.casesid)
JOIN IndvOrgContacts_Indexed CIO on CIO.SAGA = convert(varchar(50),P.namesid)
JOIN [NeedlesNeosBisnarChase]..party_role_list prl on prl.id = p.partyrolelistid
JOIN [PartyRoles] pr on pr.[Needles Roles] = prl.[role]
JOIN [sma_MST_SubRole] S on CAS.casnOrgCaseTypeID = S.sbrnCaseTypeID and s.sbrsDscrptn = [sa roles] and  S.sbrnRoleID=4
WHERE pr.[sa party] = 'Plaintiff' 
GO

/*
select * from [sma_MST_SubRole]
---( Now. do special role assignment )
DECLARE @needles_role varchar(100);
DECLARE @sa_role varchar(100);
DECLARE role_cursor CURSOR FOR 
SELECT [Needles Roles],[SA Roles] FROM [SA].[dbo].[PartyRoles] where [SA Party]='Plaintiff'
 
OPEN role_cursor 
FETCH NEXT FROM role_cursor INTO @needles_role,@sa_role
WHILE @@FETCH_STATUS = 0
BEGIN

    update [SA].[dbo].[sma_TRN_Plaintiff] set plnnRole=S.sbrnSubRoleId
    from [NeedlesNeosBisnarChase].[dbo].[party_indexed] P 
    inner join [SA].[dbo].[sma_TRN_Cases] CAS on CAS.cassCaseNumber = P.case_id  
    inner join [SA].[dbo].[sma_MST_SubRole] S on CAS.casnOrgCaseTypeID = S.sbrnCaseTypeID and S.sbrnRoleID=4 and S.sbrsDscrptn=@sa_role
    inner join IndvOrgContacts_Indexed CIO on CIO.SAGA = P.party_id
    where P.role=@needles_role
    and P.TableIndex=saga_party 

FETCH NEXT FROM role_cursor INTO @needles_role,@sa_role
END 
CLOSE role_cursor;
DEALLOCATE role_cursor;
GO
*/

-------(2) [sma_TRN_Defendants]
INSERT INTO [sma_TRN_Defendants]
   (
	[defnCaseID],[defnContactCtgID],[defnContactID],[defnAddressID],[defnSubRole],[defbIsPrimary],[defbCounterClaim],[defbThirdParty],
    [defsThirdPartyRole],[defnPriority],[defdFrmDt],[defdToDt],[defnRecUserID],[defdDtCreated],[defnModifyUserID],[defdDtModified],
    [defnLevelNo],[defsMarked],[saga],[defsComments],[defbIsClient],[saga_party]
   )
SELECT 
	casnCaseID				as [defnCaseID],
	ACIO.CTG				as [defnContactCtgID],
	ACIO.CID				as [defnContactID],
	ACIO.AID				as [defnAddressID],
	sbrnSubRoleId			as [defnSubRole],
	1						as [defbIsPrimary], 
	null,null,null,null,null,null,
	(select usrnUserID from sma_mst_users where saga = p.staffcreatedid) 	as [defnRecUserID],
	p.date_created			as [defdDtCreated],
	(select usrnUserID from sma_mst_users where saga = p.staffmodifiedid)	as [defnModifyUserID],
	p.date_modified			as [defdDtModified],
     null					as [defnLevelNo],	 
	null,null,
	isnull('Relationship: ' + nullif(convert(varchar,p.relationship),'') + CHAR(13),'') +
	''						as [defsComments],
	p.our_client			as [defbIsClient],
	P.[id]				    as [saga_party]
FROM [NeedlesNeosBisnarChase].[dbo].[party_indexed] P 
JOIN [sma_TRN_Cases] CAS on CAS.Needles_saga = convert(varchar(50),P.casesid)
JOIN IndvOrgContacts_Indexed ACIO on ACIO.SAGA = convert(varchar(50),P.namesid)
JOIN [NeedlesNeosBisnarChase]..party_role_list prl on prl.id = p.partyrolelistid
JOIN [PartyRoles] pr on pr.[Needles Roles] = prl.[role]
JOIN [sma_MST_SubRole] S on CAS.casnOrgCaseTypeID = S.sbrnCaseTypeID and s.sbrsDscrptn = [sa roles] and  S.sbrnRoleID=5
WHERE pr.[sa party] = 'Defendant' 
GO
/*
from [NeedlesNeosBisnarChase].[dbo].[party_indexed] P 
inner join [SA].[dbo].[sma_TRN_Cases] C on C.cassCaseNumber = P.case_id  
inner join [SA].[dbo].[sma_MST_SubRole] S on C.casnOrgCaseTypeID = S.sbrnCaseTypeID
inner join IndvOrgContacts_Indexed ACIO on ACIO.SAGA = P.party_id
where S.sbrnRoleID=5 and S.sbrsDscrptn='(D)-Default Role'
and P.role in (SELECT [Needles Roles] FROM [SA].[dbo].[PartyRoles] where [SA Party]='Defendant')
GO

---( Now. do special role assignment )
DECLARE @needles_role varchar(100);
DECLARE @sa_role varchar(100);
DECLARE role_cursor CURSOR FOR 
SELECT [Needles Roles],[SA Roles] FROM [SA].[dbo].[PartyRoles] where [SA Party]='Defendant'
 
OPEN role_cursor 
FETCH NEXT FROM role_cursor INTO @needles_role,@sa_role
WHILE @@FETCH_STATUS = 0
BEGIN


    update [SA].[dbo].[sma_TRN_Defendants] set defnSubRole=S.sbrnSubRoleId
    from [NeedlesNeosBisnarChase].[dbo].[party_indexed] P 
    inner join [SA].[dbo].[sma_TRN_Cases] C on C.cassCaseNumber = P.case_id  
    inner join [SA].[dbo].[sma_MST_SubRole] S on C.casnOrgCaseTypeID = S.sbrnCaseTypeID and S.sbrnRoleID=5 and S.sbrsDscrptn=@sa_role
    inner join IndvOrgContacts_Indexed ACIO on ACIO.SAGA = P.party_id
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
FROM sma_trn_cases CAS
LEFT JOIN [sma_TRN_Plaintiff] T on T.plnnCaseID=CAS.casnCaseID
WHERE plnnCaseID is null
GO

UPDATE sma_TRN_Plaintiff set plnbIsPrimary=0

UPDATE sma_TRN_Plaintiff set plnbIsPrimary=1
FROM
(
SELECT DISTINCT 
	   T.plnnCaseID, ROW_NUMBER() OVER (Partition BY T.plnnCaseID order by P.record_num) as RowNumber,
	   T.plnnPlaintiffID as ID  
    FROM sma_TRN_Plaintiff T
    LEFT JOIN [NeedlesNeosBisnarChase].[dbo].[party_indexed] P on P.[id]=T.saga_party
) A
WHERE A.RowNumber=1
and plnnPlaintiffID = A.ID



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
    LEFT JOIN [NeedlesNeosBisnarChase].[dbo].[party_indexed] P on P.[id]=D.saga_party
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







