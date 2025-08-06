USE SA
GO
/*
alter table [sma_TRN_PlaintiffAttorney] disable trigger all
delete from [sma_TRN_PlaintiffAttorney] 
DBCC CHECKIDENT ('[sma_TRN_PlaintiffAttorney]', RESEED, 0);
alter table [sma_TRN_PlaintiffAttorney] enable trigger all

alter table [sma_TRN_LawFirms] disable trigger all
delete from [sma_TRN_LawFirms] 
DBCC CHECKIDENT ('[sma_TRN_LawFirms]', RESEED, 0);
alter table [sma_TRN_LawFirms] enable trigger all

alter table [sma_TRN_LawFirmAttorneys] disable trigger all
delete from [sma_TRN_LawFirmAttorneys] 
DBCC CHECKIDENT ('[sma_TRN_LawFirmAttorneys]', RESEED, 0);
alter table [sma_TRN_LawFirmAttorneys] enable trigger all
*/

/*
-----------------------------------------------------------------------------------
--INSERT ATTORNEY TYPES
-----------------------------------------------------------------------------------
INSERT INTO sma_MST_AttorneyTypes (atnsAtorneyDscrptn)
SELECT Distinct Type_OF_Attorney From NeedlesNeosBisnarChase..user_counsel_data where isnull(Type_of_attorney,'')<>''
EXCEPT
SELECT atnsAtorneydscrptn from sma_MST_AttorneyTypes
*/

---
ALTER TABLE [sma_TRN_PlaintiffAttorney] DISABLE TRIGGER ALL
GO
ALTER TABLE [sma_TRN_LawFirms] DISABLE TRIGGER ALL
GO
ALTER TABLE [sma_TRN_LawFirmAttorneys] DISABLE TRIGGER ALL
GO
---
--------------------------------------
--PLAINTIFF ATTONEYS
--------------------------------------
INSERT INTO [sma_TRN_PlaintiffAttorney]
(
       [planPlaintffID]
      ,[planCaseID]
      ,[planPlCtgID]
      ,[planPlContactID]
      ,[planLawfrmAddID]
      ,[planLawfrmContactID]
      ,[planAtorneyAddID]
      ,[planAtorneyContactID]
      ,[planAtnTypeID]
      ,[plasFileNo]
      ,[planRecUserID]
      ,[pladDtCreated]
      ,[planModifyUserID]
      ,[pladDtModified]
      ,[planLevelNo]
      ,[planRefOutID]
	  ,[plasComments]
)
SELECT DISTINCT
    T.plnnPlaintiffID		  as [planPlaintffID],
    CAS.casnCaseID			  as [planCaseID],
    T.plnnContactCtg		  as [planPlCtgID],
    T.plnnContactID			  as [planPlContactID],
    case when IOC.CTG=2 then IOC.AID
	   else null end		  as [planLawfrmAddID],
    case when IOC.CTG=2 then IOC.CID
	   else null end		  as [planLawfrmContactID],
    case when IOC.CTG=1 then IOC.AID
	   else null end		  as [planAtorneyAddID],
	case when IOC.CTG=1 then IOC.CID
	   else null end		  as [planAtorneyContactID],
    (select atnnAtorneyTypeID from sma_MST_AttorneyTypes where atnsAtorneyDscrptn = 'Plaintiff Attorney')	  as [planAtnTypeID],
    null					  as [plasFileNo], --	 UD.Their_File_Number
    (select usrnUserID from sma_mst_users where saga = convert(varchar(50),c.staffCreatedID))			  	  as [planRecUserID],
    c.date_created			  as [pladDtCreated],
    (select usrnUserID from sma_mst_users where saga = convert(varchar(50),c.staffmodifiedid))				  as [planModifyUserID],
    c.date_modified			  as [pladDtModified],
    0						  as [planLevelNo],
    null					  as [planRefOutID],
    isnull('comments : ' + nullif(convert(varchar(max),C.comments) ,'') + CHAR(13),'') +
    isnull('Attorney for party : ' + nullif(convert(varchar(max),IOCP.name) ,'') + CHAR(13),'') +
    ''						  as [plasComments]
--SELECT *
  FROM [NeedlesNeosBisnarChase]..[counsel_Indexed] C 
  --LEFT JOIN [NeedlesNeosBisnarChase].[dbo].[user_counsel_data] UD on UD.counsel_id=C.counsel_id and C.case_num=UD.casenum  
  JOIN [sma_TRN_Cases] CAS on CAS.Needles_saga = convert(varchar(50),C.casesid)
  JOIN IndvOrgContacts_Indexed IOC on IOC.SAGA = convert(varchar(50),C.counselnamesid) 
  JOIN IndvOrgContacts_Indexed IOCP on IOCP.SAGA = convert(varchar(50),C.representingnamesid) -- and isnull(C.party_id,0)<>0
  JOIN [sma_TRN_Plaintiff] T on T.plnnContactID = IOCP.CID and T.plnnContactCtg = IOCP.CTG and T.plnnCaseID=CAS.casnCaseID
GO
  
--------------------------------------
--DEFENSE ATTORNEYS
--------------------------------------
INSERT INTO [sma_TRN_LawFirms]
(
       [lwfnLawFirmContactID]
      ,[lwfnLawFirmAddressID]
      ,[lwfnAttorneyContactID]
      ,[lwfnAttorneyAddressID]
      ,[lwfnAttorneyTypeID]
      ,[lwfsFileNumber]
      ,[lwfnRoleType]
      ,[lwfnContactID]
      ,[lwfnRecUserID]
      ,[lwfdDtCreated]
      ,[lwfnModifyUserID]
      ,[lwfdDtModified]
      ,[lwfnLevelNo]
      ,[lwfnAdjusterID]
	  ,[lwfsComments]
)
SELECT DISTINCT
    case when IOC.CTG = 2 then IOC.CID
	   else null end					as [lwfnLawFirmContactID],
    case when IOC.CTG = 2 then IOC.AID
	   else null end					as [lwfnLawFirmAddressID],
    case when IOC.CTG = 1 then IOC.CID
	   else null end					as [lwfnAttorneyContactID],
    case when IOC.CTG = 1 then IOC.AID
	   else null end					as [lwfnAttorneyAddressID] ,
    (select atnnAtorneyTypeID FROM [sma_MST_AttorneyTypes] where atnsAtorneyDscrptn='Defense Attorney')   as [lwfnAttorneyTypeID],
    null								as [lwfsFileNumber],
    2									as [lwfnRoleType], 
    D.defnDefendentID   				as [lwfnContactID],
    (select usrnUserID from sma_mst_users where saga = convert(varchar(50),c.staffCreatedID))				as [lwfnRecUserID],
    c.date_created	    				as [lwfdDtCreated],
    (select usrnUserID from sma_mst_users where saga = convert(varchar(50),c.staffmodifiedid))				as [lwfnModifyUserID],
    c.date_modified	    				as[lwfdDtModified],
    null			    				as [lwfnLevelNo],
    null			    				as [lwfnAdjusterID],
	isnull('comments : ' + nullif(convert(varchar(max),C.comments) ,'') + CHAR(13),'') +
	isnull('Attorney for party : ' + nullif(convert(varchar(max),IOCD.name) ,'') + CHAR(13),'') +
    ''			    					as [lwfsComments]
  FROM [NeedlesNeosBisnarChase].[dbo].[counsel_Indexed] C 
  --LEFT JOIN [NeedlesNeosBisnarChase].[dbo].[user_counsel_data] UD on UD.counsel_id=C.counsel_id and C.case_num=UD.casenum
  JOIN [sma_TRN_Cases] CAS on CAS.Needles_saga = convert(varchar(50),C.casesid)
  JOIN IndvOrgContacts_Indexed IOC on IOC.SAGA = convert(Varchar(50),C.counselnamesid) 
  JOIN IndvOrgContacts_Indexed IOCD on IOCD.SAGA = convert(varchar(50),C.representingnamesid) 
  JOIN [sma_TRN_Defendants] D on D.defnContactID = IOCD.CID and D.defnContactCtgID = IOCD.CTG and D.defnCaseID=CAS.casnCaseID
GO


----(3)---- Plaintiff Attorney list
INSERT INTO sma_TRN_LawFirmAttorneys (SourceTableRowID,UniqueContactID,IsDefendant,IsPrimary)
SELECT 
    A.LawFirmID				as SourceTableRowID,
    A.AttorneyContactID		as UniqueAontactID,
    0						as IsDefendant, --0:Plaintiff
    case when A.SequenceNumber=1 then 1
	   else 0 end			as IsPrimary
FROM (
	SELECT 
		F.planAtnID				as LawFirmID,
		AC.UniqueContactId		as AttorneyContactID,
		ROW_NUMBER() OVER (Partition BY F.planCaseID order by F.planAtnID) as SequenceNumber     
	FROM [sma_TRN_PlaintiffAttorney] F
	LEFT JOIN sma_MST_AllContactInfo AC on AC.ContactCtg=1 and AC.ContactId=F.planAtorneyContactID
) A
WHERE A.AttorneyContactID is not null
GO


----(4)---- Defense Attorney list
INSERT INTO sma_TRN_LawFirmAttorneys (SourceTableRowID,UniqueContactID,IsDefendant,IsPrimary)
SELECT 
    A.LawFirmID				as SourceTableRowID,
    A.AttorneyContactID		as UniqueAontactID,
    1						as IsDefendant,
    case when A.SequenceNumber=1 then 1
	   else 0 end			as IsPrimary
FROM (
	SELECT 
		F.lwfnLawFirmID			  as LawFirmID,
		AC.UniqueContactId		  as AttorneyContactID,
		ROW_NUMBER() OVER (Partition BY F.lwfnModifyUserID order by F.lwfnLawFirmID) as SequenceNumber     
	FROM [sma_TRN_LawFirms] F
	LEFT JOIN sma_MST_AllContactInfo AC on AC.ContactCtg=1 and AC.ContactId=F.lwfnAttorneyContactID
) A
WHERE A.AttorneyContactID is not null
GO
  

---(Appendix)----
UPDATE sma_MST_IndvContacts 
SET cinnContactTypeID=(select octnOrigContactTypeID FROM [sma_MST_OriginalContactTypes] where octsDscrptn='Attorney' and octnContactCtgID=1)
FROM (
  SELECT I.cinnContactID as ID
  --select *
  FROM [NeedlesNeosBisnarChase].[dbo].[counsel_Indexed] C 
  JOIN [NeedlesNeosBisnarChase].[dbo].[names] L on C.counselnamesid = L.id
  JOIN [dbo].[sma_MST_IndvContacts] I on saga = convert(varchar(50),L.id)
  WHERE L.person= 1
  ) A
WHERE cinnContactID=A.ID
GO
---
ALTER TABLE [sma_TRN_PlaintiffAttorney] ENABLE TRIGGER ALL
GO
ALTER TABLE [sma_TRN_LawFirms] ENABLE TRIGGER ALL
GO
ALTER TABLE [sma_TRN_LawFirmAttorneys] ENABLE TRIGGER ALL
GO
---

