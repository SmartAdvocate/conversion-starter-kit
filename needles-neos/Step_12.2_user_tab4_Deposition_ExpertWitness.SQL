
USE  [SAbilleasterlyLaw]
GO
 
alter table [sma_TRN_Depositions] disable trigger all
delete from [sma_TRN_Depositions] 
DBCC CHECKIDENT ('[sma_TRN_Depositions]', RESEED, 0);
alter table [sma_TRN_Depositions] enable trigger all

 alter table  sma_TRN_ExpertContacts disable trigger all
delete from  sma_TRN_ExpertContacts
DBCC CHECKIDENT ('sma_TRN_ExpertContacts', RESEED, 0);
alter table  sma_TRN_ExpertContacts enable trigger all

 alter table  sma_TRN_CaseWitness  disable trigger all
delete from  sma_TRN_CaseWitness 
DBCC CHECKIDENT ('sma_TRN_CaseWitness', RESEED, 0);
alter table  sma_TRN_CaseWitness   enable trigger all
 

 


IF NOT EXISTS(SELECT * FROM sys.columns 
            WHERE Name = N'saga' AND Object_ID = Object_ID(N'sma_TRN_Depositions'))
BEGIN
	ALTER TABLE sma_TRN_Depositions
	ADD saga varchar(50)
END
GO

IF NOT EXISTS(SELECT * FROM sys.columns WHERE Name = N'saga' AND Object_ID = Object_ID(N'sma_TRN_ExpertContacts'))
BEGIN
	ALTER TABLE sma_TRN_ExpertContacts
	ADD saga varchar(50) null
END
GO
---(0)---
IF EXISTS (select * from sys.objects where name='user_tab_contacts_helper' and type='U')
BEGIN
	DROP TABLE user_tab_contacts_helper
END 
GO

---(0)---
CREATE TABLE user_tab_contacts_helper (
    TableIndex			  int IDENTITY(1,1) NOT NULL,
    caseID				  varchar(50),
    tabID				  varchar(50),
     DeponentNameId		  int,
     DeponentName		  varchar(200),
    DeponentCID			  int,
    DeponentCTG			  int,
   DeponentAID			  int,
     DeponentUniqueID	  int,
	CourtReporterNameID	  varchar(50),
	CourtReporterName	  varchar(200),
    CourtReporterCID	  int,
    CourtReporterCTG	  int,
    CourtReporterAID	  int,
    CourtReporterUniqueID  int,
	WitnessNameID		  varchar(50), 
	WitnessName			  varchar(200),
    WitnessCID			  int,
    WitnessCTG			  int,
    WitnessAID			  int,
    WitnessUniqueID		  int,
 
	VideographerName	  varchar(200),
    VideographerCID		  int,
    VideographerCTG		  int,
    VideographerAID		  int,
    VideographerUniqueID  int,
	DepoLocationNameID	  varchar(50),
	DepoLocationName	  varchar(200),
	DepoLocationCID		  int,
	DepoLocationAID		  int,
	DepoLocationCTG		  int,
    casnCaseID			  int,
    ForWhichParty		  varchar(200),
    ServeByID			  int,
CONSTRAINT IOC_Clustered_Index_user_tab_contacts_helper PRIMARY KEY CLUSTERED ( TableIndex )
) ON [PRIMARY] 
GO


--Court Reporter
--Deposition Location
--Judge
--Name
--Videographer


---(0)--- INSERT PRIMARY FIELD
INSERT INTO user_tab_contacts_helper ( caseID,tabID
                                                           ,WitnessNameId
														   ,WitnessName
														   ,WitnessCID
														   ,WitnessCTG
														   ,WitnessAID
														   ,WitnessUniqueID
														   ,
--CourtReporterCID,CourtReporterCTG,CourtReporterAID,CourtReporterUniqueID, VideographerCID,VideographerCTG,VideographerAID,VideographerUniqueID,TranslatorCID,TranslatorCTG,TranslatorAID,TranslatorUniqueID,
	                                                       casnCaseID
														  ,ForWhichParty
														  ,ServeByID )
SELECT
    n.casesid		    as caseID,		-- needles case
    n.tablistid		    as tabID,		-- needles records TAB item
    n.[Witness Name]		as WitnessNameId,      ----IOC.saga_ref
    IOC.[Name]			as WitnessName,
    IOC.CID				as WitnessCID,  
    IOC.CTG				as WitnessCTG,
    IOC.AID				as WitnessAID,
    IOC.UNQCID		    as WitnessUniqueID,
    CAS.casnCaseID	    as casnCaseID,
    null			    as ForWhichParty,
    null			    as ServeByID  
--select *
FROM [NeosBillEasterly].[dbo].[NeosUserTab4]  n
JOIN [IndvOrgContacts_Indexed] IOC on IOC.SAGA_ref= convert(varchar(50),n.[Witness Name])
JOIN [sma_TRN_Cases] CAS on CAS.Neos_Saga = convert(varchar(50),n.CasesID)
GO

-- UPDATE COURT REPORTER INFO
UPDATE user_tab_contacts_helper 
SET CourtReporterCID=IOC.CID,
	CourtReporterCTG=IOC.CTG,
	CourtReporterAID=IOC.AID,
	CourtReporterUniqueID=IOC.UNQCID,
	CourtReporterName = ioc.[name]
FROM  [NeosBillEasterly].[dbo].[NeosUserTab4] n
JOIN [IndvOrgContacts_Indexed] IOC on IOC.SAGA_ref= convert(varchar(50),n.[Court Reporter])   ---court Report is namesid
WHERE  [tabID] = convert(varchar(50), n.tablistid)
GO


--UPDATE DEPO LOCATION INTO
UPDATE user_tab_contacts_helper 
SET DepoLocationNameID = [Location of Depo],
	DepoLocationName = ioc.[name],
	DepoLocationCID = ioc.cid,
	DepoLocationAID = ioc.AID,
	DepoLocationCTG = ioc.CTG
--- select  *
FROM  [NeosBillEasterly].[dbo].[NeosUserTab4] n
JOIN [IndvOrgContacts_Indexed] IOC on IOC.SAGA_ref= convert(varchar(50),n.[Location of Depo])    ---[Location of Depo] is namesid
WHERE  [tabID]  = convert(varchar(50), n.tablistid)
GO

 
---
DBCC DBREINDEX('user_tab_contacts_helper',' ',90)  WITH NO_INFOMSGS 
---
GO

-----------------------------------------------------
------------------- CONTACT TYPES-- -----------------
-----------------------------------------------------
INSERT INTO sma_MST_ContactTypes ( cntnContactCtgID,cntsDscrptn,cntsRoleGroup,cntbFlag )
SELECT DISTINCT
    1					 as cntnContactCtgID,
    g.code				 as cntsDscrptn,
    'O'					 as cntsRoleGroup,
    1					 as cntbFlag
FROM  [NeosBillEasterly]..NeosUserTab4 D 
JOIN  [NeosBillEasterly]..mini_general_dir g on g.id = d.[Type of Witness]
WHERE isnull(D.[Type of Witness],'')<>''
EXCEPT SELECT cntnContactCtgID,cntsDscrptn,cntsRoleGroup,cntbFlag FROM sma_MST_ContactTypes
GO

-----------------------------------------------------
----------------- EXPERT SPECIALITY -----------------
-----------------------------------------------------
INSERT INTO sma_MST_Speciality ( splsSpeciality,splnContactTypeID )
SELECT DISTINCT g.code,	(SELECT cntnContactTypeID from sma_MST_ContactTypes where cntsDscrptn='Experts')
FROM [NeosBillEasterly]..neosUsertab4 D 
JOIN  [NeosBillEasterly]..mini_general_dir g on g.id = d.[Type of Expert]
WHERE isnull(d.[Type of Expert],'')<>''
EXCEPT SELECT splsSpeciality, (SELECT cntnContactTypeID FROM sma_MST_ContactTypes WHERE cntsDscrptn='Experts') FROM sma_MST_Speciality
GO

-----------------------------------------------------
----------------- DEPOSITION TYPES -----------------
-----------------------------------------------------
INSERT INTO [sma_MST_DepositionType] ( dptsDescription )
SELECT DISTINCT
	g.code   as cntsDscrptn
FROM [NeosBillEasterly] ..NeosUserTab4 D 
JOIN [NeosBillEasterly]..mini_general_dir g on g.id = d.[Type of Witness]
WHERE isnull(D.[Type of Witness],'')<>''
EXCEPT 
SELECT dptsDescription FROM [sma_MST_DepositionType]
GO

---------------------------------------------
--------------- WITNESS TYPES-- ------------- asking Client
---------------------------------------------
 MERGE INTO SMA_MST_WitnessType AS target
USING (
    SELECT DISTINCT g.code AS WitnessType, 368 AS CreatedBy, GETDATE() AS CreatedDate
    FROM [NeosBillEasterly]..neosUsertab4 D
    JOIN [NeosBillEasterly]..mini_general_dir g ON g.id = d.[Type of Witness]
    WHERE g.[code] IN ('Treating Physician', 'Fact', 'Pltf Fact', 'Pltf Expert', 'Plt/Fact', 'Eyewitness', 'Def Fact', 'Before and After' , 'Before and After' )
) AS source
ON target.WitnessType = source.WitnessType
WHEN NOT MATCHED BY TARGET THEN
    INSERT (WitnessType, CreatedBy, CreatedDate)
    VALUES (source.WitnessType, source.CreatedBy, source.CreatedDate);

 
---------------------------------------------
------------- WITNESS CONTACTS -------------
---------------------------------------------
INSERT INTO [dbo].[sma_TRN_CaseWitness]
           ([witnCaseID]
           ,[witnWitnesContactID]
           ,[witnWitnesAdID]
           ,[witnRoleID]
           ,[witnFavorable]
           ,[witnTestify]
           ,[witdStmtReqDate]
           ,[witdStmtDate]
           ,[witbHasRec]
           ,[witsDoc]
           ,[witsComment]
           ,[witnRecUserID]
           ,[witdDtCreated]
           ,[witnModifyUserID]
           ,[witdDtModified]
           ,[witnLevelNo])
SELECT
	casnCaseid				as [witnCaseID],
	WitnessUniqueID			as [witnWitnesContactID],
	WitnessAID				as [witnWitnesAdID],
	(select ID from SMA_MST_WitnessType where witnesstype = d.code)		as [witnRoleID],
	case when d.code  in ('Pltf Fact',    'Plt/Fact',  'Pltf Expert' , 'Treating Physician') then 1
		else 0 end		as [witnFavorable],
	NULL			as [witnTestify],
	NULL			as [witdStmtReqDate],
	NULL			as [witdStmtDate],
	NULL			as [witbHasRec],
	NULL			as [witsDoc],
	--ISNULL(('Statement Context : ' + nullif(UD.[Statement_Context],'') + CHAR(13)),'') + 
	''				as [witsComment],
	368				as [witnRecUserID],
	getdate()		as [witdDtCreated],
	NULL			as [witnModifyUserID],
	NULL			as [witdDtModified],
	1				as [witnLevelNo]
--select *
FROM user_tab_contacts_helper CH
JOIN [NeosBillEasterly]..NeosUserTab4 UD on convert(varchar(50),UD.tablistid) = CH.tabID and convert(varchar(50),ud.CasesID) = ch.caseID
JOIN [NeosBillEasterly]..mini_general_dir d on d.id = ud.[Type of Witness]
where   [code] IN ('Treating Physician', 'Fact', 'Pltf Fact', 'Pltf Expert', 'Plt/Fact', 'Eyewitness', 'Def Fact', 'Before and After' , 'Before and After' ) 

GO


---------------------------------------------
-------------- EXPERT CONTACTS -------------- 
---------------------------------------------
ALTER TABLE [dbo].[sma_TRN_ExpertContacts] DISABLE TRIGGER ALL
GO

---(1)---
INSERT INTO [dbo].[sma_TRN_ExpertContacts]
(
	 [ectnCaseID]
	,[ectnExpContactID]
	,[ectnExpContactCtgId]
	,[ectnExpAddressID]
	,[ectnExpertFor]
	,[ectnExpertTypeID]
	,[ectdDisclosureDt]
	,[ectsComment]
    ,[ectnRecUserID]
    ,[ectdDtCreated]
    ,[ectbDocAttached]
	--,[ectnSpeciality]
	--,[ectnSubspeciality]
 )
SELECT
	MAP.casnCaseID				 as [ectnCaseID],
	MAP.WitnessCID				 as [ectnExpContactID],
	MAP.WitnessCTG				 as [ectnExpContactCtgId],
	MAP.WitnessAID				 as [ectnExpAddressID],
/*	case when ud.[Type of Witness] = 'Party' then 0
		else 2 end				 as ectnExpertFor,  -- 0 for Plaintiff, 1 for Defendant, 2=neutral    */
	case  when d.[code] = 'Expert - Pltf'   then 0
	         when  d.[code] =  'Expert - Def.'   then 1
			 else 0
	end  as ectnExpertFor,
	null						 as ectnExpertTypeID,
	getdate()					 as [ectdDisclosureDt],
    isnull('Type of Witness: ' + NULLIF(convert(varchar,UD.[Type of Witness]),'')  + CHAR(13) + CHAR(10),'') + 
	isnull('Type of Expert: ' + NULLIF(convert(varchar,UD.[Type of Expert]),'')  + CHAR(13) + CHAR(10),'') + 
    	''						 as [ectsComment],
	368							 as [ectnRecUserID],
	getdate()					 as [ectdDtCreated],
	0							 as [ectbDocAttached]
	--(select splnSpecialityID from sma_MST_Speciality where UD.Type_of_Expert = splsSpeciality)			as [ectnSpeciality],
	--(select splnSpecialityID from sma_MST_Speciality where UD.Type_of_Expert = splsSpeciality)			as [ectnSubspeciality]
---select *
FROM user_tab_contacts_helper MAP
JOIN  [NeosBillEasterly]..NeosUserTab4 UD on convert(varchar(50),UD.tablistid) = map.tabID and convert(varchar(50),ud.CasesID) = map.caseID
JOIN   [NeosBillEasterly]..mini_general_dir d on d.id = ud.[Type of Witness]
---WHERE d.[code]  in ( 'Pltf Expert.', 'Def Expert ')
GO

ALTER TABLE [sma_TRN_ExpertContacts] ENABLE TRIGGER ALL
GO

------------------------------------------------------------------------
------------ UPDATE CONTACT TYPE TO EXPERT IN CONTACT CARDS ------------
------------------------------------------------------------------------
UPDATE sma_MST_IndvContacts
SET cinnContactTypeID = (select octnOrigContactTypeID From sma_MST_OriginalContactTypes where octsDscrptn = 'Expert' and octnContactCtgID = 1)
--select * 
FROM [sma_TRN_ExpertContacts] EC
JOIN sma_MST_IndvContacts IND ON EC.ectnExpContactID =  IND.cinnContactID and EC.ectnExpContactCtgId = IND.cinnContactCtg
GO 

UPDATE sma_MST_OrgContacts
SET connContactTypeID = (select octnOrigContactTypeID From sma_MST_OriginalContactTypes where octsDscrptn = 'Expert' and octnContactCtgID = 2)
--select * 
FROM [sma_TRN_ExpertContacts] EC
JOIN sma_MST_OrgContacts Org ON EC.ectnExpContactID =  Org.connContactID and EC.ectnExpContactCtgId = Org.connContactCtg
GO 


------------------------------------------------------------------------
--INSERT SPECIALTY TO CONTACT CARDS
------------------------------------------------------------------------
INSERT INTO sma_TRN_ExpertSpecialtySubSpecialty (
			[ExpertSpecialtyID]
           ,[ExpertSubSpecialtyID]
           ,[ExpertContactID]
           ,[ExpertContactCtg]
           ,[CreatedUserID]
           ,[CreatedDate]
           ,[ModifiedUserID]
           ,[ModifiedDate])
SELECT DISTINCT 
		(SELECT splnSpecialityID FROM sma_MST_Speciality WHERE d.code = splsSpeciality)		as [ExpertSpecialtyID],
		null									as [ExpertSubSpecialtyID],
		map.WitnessCID							as [ExpertContactID],
		map.WitnessCTG							as [ExpertContactCtg],
		368										as [CreatedUserID],
		getdate()								as [CreatedDate],
		NULL									as [ModifiedUserID],
		NULL									as [ModifiedDate]
FROM user_tab_contacts_helper MAP
JOIN  [NeosBillEasterly]..NeosUserTab4 UD on convert(varchar(50),UD.tablistid) = map.tabID and convert(varchar(50),ud.CasesID) = map.caseID
JOIN  [NeosBillEasterly]..mini_general_dir d on d.id = ud.[Type of Expert]
WHERE isnull([Type of Expert],'')<>''
GO


-----------------------------------------------
-- POPULATE DEPOSITIONS
-----------------------------------------------
ALTER TABLE [sma_TRN_Depositions] DISABLE TRIGGER ALL
GO
--- 

INSERT INTO [dbo].[sma_TRN_Depositions] (
    [dpsnCaseId]
    ,[dscdEnteredDt]
    ,[dpsnType]
    ,[dpsdOnDate]
    ,[dpsdTrnscrptServedDt]  --Transcript Requested
    ,[dpsdTrnscrptRcvdDt]
    ,[dpssComments]
    ,[dpsnExecutedWaived]
    ,[dpsdExecDt]
    ,[dpsbVideoTape]
    ,[dpsnRecUserID]
    ,[dpsdDtCreated]
    ,[dpsnModifyUserID]
    ,[dpsdDtModified]
    ,[dpsbTranslator]
    ,[ServedByUniqueID]
    ,[DeponentUID]
    ,[TestifyForUniqueID]
    ,[CourtReporterUID]
    ,[CourtAgencyUID]
    ,[VideoOperatorUID]
    ,[VideoCompanyUID]
    ,[TranslatorUID]
    ,[TranslAgencyUID]
    ,[saga]
 ) 
SELECT 
    MAP.casnCaseID				as [dpsnCaseId],
    null						as [dscdEnteredDt],
    (select dptnDepositionTypeID FROM [dbo].[sma_MST_DepositionType] where dptsDescription=g.code)		as [dpsnType],
    case when ud.[Depo Date] between '1/1/1900' and '6/6/2079' then ud.[Depo Date] else NULL end			as [dpsdOnDate],
    NULL						as [dpsdTrnscrptServedDt],
	NULL						as [dpsdTrnscrptRcvdDt],
	ISNULL(('Comments: ' + nullif(convert(varchar,UD.[Comments]),'') + CHAR(13)),'') + 
	ISNULL(('Contact:  ' + nullif(convert(varchar(max),UD.Contact),'') + CHAR(13)),'') + 
	ISNULL(('Court Reporter:  ' + nullif(convert(varchar(max),UD.[Court Reporter]),'') + CHAR(13)),'') + 
	ISNULL(('Court Reporter Cost :  ' + nullif(convert(varchar(max),UD.[Court Reporter Cost]),'') + CHAR(13)),'') + 
	ISNULL(('CV on File?:  ' + nullif(convert(varchar(max),UD.[CV on File?]),'') + CHAR(13)),'') + 
	ISNULL(('Depo Prep Date: ' + nullif(convert(varchar,UD.[Depo Prep Date]),'') + CHAR(13)),'') + 
	ISNULL(('Depo Prep Time: ' + nullif(convert(varchar,UD.[Depo Prep Time]),'') + CHAR(13)),'') + 
	ISNULL(('Depo Date: ' + nullif(convert(varchar,UD.[Depo Date]),'') + CHAR(13)),'') + 
	ISNULL(('Depo Time: ' + nullif(convert(varchar,UD.[Depo Time]),'') + CHAR(13)),'') + 
	ISNULL(('Interpreter?: ' + nullif(convert(varchar,UD.[Interpreter?]),'') + CHAR(13)),'') + 
     ISNULL(('Location of Depo: ' + nullif(convert(varchar,UD.[Location of Depo]),'') + CHAR(13)),'') + 
	ISNULL(('Notes: ' + nullif(convert(varchar(max),UD.[Notes]),'') + CHAR(13)),'') + 
	ISNULL(('Reviewed: ' + nullif(convert(varchar(max),UD.[Reviewed]),'') + CHAR(13)),'') + 
	ISNULL(('Srvd on Def: ' + nullif(convert(varchar(max),UD.[Srvd on Def]),'') + CHAR(13)),'') + 
	ISNULL(('Srvd on Plt: ' + nullif(convert(varchar(max),UD.[Srvd on Plt]),'') + CHAR(13)),'') + 
		ISNULL(('Srvd on Plt: ' + nullif(convert(varchar(max),UD.[Srvd on Plt]),'') + CHAR(13)),'') + 
-----	ISNULL(('Video?: ' + nullif(convert(varchar(max),UD.[Video?]),'') + CHAR(13)),'') + 
    ''						  as [dpssComments],
    0,null,
    ''	as [dpsbVideoTape],
    368							as [dpsnRecUserID],
    getdate()					as [dpsdDtCreated],
    null						as [dpsnModifyUserID],
    null						as [dpsdDtModified],
	NULL						as [dpsbTranslator],
    null						as [ServedByUniqueID],
    MAP.WitnessUniqueID			as [DeponentUID],
    null						as [TestifyForUniqueID],
    map.CourtReporterUniqueID	as [CourtReporterUID],
    null						as [CourtAgencyUID],
    map.VideographerUniqueID	as [VideoOperatorUID],
    NULL						as [VideoCompanyUID],
    NULL						as [TranslatorUID],
    null						as [TranslAgencyUID],
    UD.tablistid					as [saga]
--SELECT  ud.[Type of Witness], g.code
FROM  [NeosBillEasterly]..NeosUserTab4 UD
JOIN user_tab_contacts_helper MAP on MAP.caseID = convert(varchar(50),UD.CasesID) and MAP.tabID = convert(varchar(50),UD.tablistid)
JOIN [NeosBillEasterly]..mini_general_dir g on g.id = ud.[Type of Witness]   and isnull([Type of Witness],'')<>''
GO

---
ALTER TABLE [dbo].[sma_TRN_Depositions] ENABLE TRIGGER ALL
GO
---

