
USE SA
GO
/*
alter table [sma_TRN_Depositions] disable trigger all
delete from [sma_TRN_Depositions] 
DBCC CHECKIDENT ('[sma_TRN_Depositions]', RESEED, 0);
alter table [sma_TRN_Depositions] enable trigger all
*/
/*
SELECT tl.casesid,td.tablistid, case when convert(varchar(50),td.[namesid]) IS NULL then td.[data] else convert(varchar(50),td.[namesid]) end as [data], ucf.field_title
	FROM [NeedlesNeosBisnarChase]..user_tab1_data td
	JOIN [NeedlesNeosBisnarChase]..user_tab1_list tl on tl.id = td.tablistid
	JOIN [NeedlesNeosBisnarChase]..user_case_fields ucf on ucf.id = td.usercasefieldid
	WHERE field_Title in ('Court Reporter', 'Court Reporter Cost', 'CV on File?', 'Depo Date', 'Depo Prep Date', 'Depo Prep Time', 'Depo Time', 'Expert Cost', 
					'Interpreter', 'Location of Deposition', 'Notes', 'Type of Expert', 'Type of Witness', 'Video?', 'Videographer Cost', 'Witness Name' )

*/

--------------------------
--DEPO PIVOT
--------------------------
IF EXISTS (SELECT * FROM sys.tables where name = 'DepoWitnessPivot')
BEGIN
	DROP TABLE DepoWitnessPivot
END


SELECT casesid, TabListID, [Court Reporter], [Court Reporter Cost], [CV on File?], [Depo Date], [Depo Prep Date], [Depo Prep Time], [Depo Time], [Expert Cost], [Interpreter], 
					[Location of Deposition], [Notes], [Type of Expert], [Type of Witness], [Video?], [Videographer Cost], [Witness Name]
INTO DepoWitnessPivot
FROM
(
	SELECT tl.casesid as CasesID, td.tablistid, case when convert(varchar(50),td.[namesid]) IS NULL then td.[data] else convert(varchar(50),td.[namesid]) end as [data], ucf.field_title
	FROM [NeedlesNeosBisnarChase]..user_tab1_data td
	JOIN [NeedlesNeosBisnarChase]..user_tab1_list tl on tl.id = td.tablistid
	JOIN [NeedlesNeosBisnarChase]..user_case_fields ucf on ucf.id = td.usercasefieldid
	WHERE field_Title in ('Court Reporter', 'Court Reporter Cost', 'CV on File?', 'Depo Date', 'Depo Prep Date', 'Depo Prep Time', 'Depo Time', 'Expert Cost', 
					'Interpreter', 'Location of Deposition', 'Notes', 'Type of Expert', 'Type of Witness', 'Video?', 'Videographer Cost', 'Witness Name' )
) d
pivot
(
  max([data])
  for field_title in ([Court Reporter], [Court Reporter Cost], [CV on File?], [Depo Date], [Depo Prep Date], [Depo Prep Time], [Depo Time], [Expert Cost], [Interpreter], 
					[Location of Deposition], [Notes], [Type of Expert], [Type of Witness], [Video?], [Videographer Cost], [Witness Name], [Account Number], [Comments], 
					[Date Received], [Date Requested], [For Dates From], [Make Check Payable To], [Medical Record#], [Method], [No Records], [Ordered By], [Pre-Payment Required], 
					[Provider Name], [Through], [Type of Record], [Value Code] )
) piv;




ALTER TABLE [dbo].[sma_TRN_Depositions]
ALTER COLUMN [dpssComments] [varchar](MAX) NULL
GO


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
    --DeponentNameId		  int,
    --DeponentName		  varchar(200),
    --DeponentCID			  int,
    --DeponentCTG			  int,
    --DeponentAID			  int,
    --DeponentUniqueID	  int,
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
	--JudgeName			  varchar(200),
 --   JudgeCID			  int,
 --   JudgeCTG			  int,
 --   JudgeAID			  int,
 --   JudgeUniqueID		  int,
	--VideographerName	  varchar(200),
 --   VideographerCID		  int,
 --   VideographerCTG		  int,
 --   VideographerAID		  int,
 --   VideographerUniqueID  int,
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
INSERT INTO user_tab_contacts_helper ( caseID,tabID,WitnessNameId,WitnessName,WitnessCID,WitnessCTG,WitnessAID,WitnessUniqueID,
--CourtReporterCID,CourtReporterCTG,CourtReporterAID,CourtReporterUniqueID, VideographerCID,VideographerCTG,VideographerAID,VideographerUniqueID,TranslatorCID,TranslatorCTG,TranslatorAID,TranslatorUniqueID,
	casnCaseID,ForWhichParty,ServeByID )
SELECT
    n.casesid		    as caseID,		-- needles case
    n.tablistid		    as tabID,		-- needles records TAB item
    n.[Witness Name]		as WitnessNameId,  
    IOC.[Name]			as WitnessName,
    IOC.CID				as WitnessCID,  
    IOC.CTG				as WitnessCTG,
    IOC.AID				as WitnessAID,
    IOC.UNQCID		    as WitnessUniqueID,
    CAS.casnCaseID	    as casnCaseID,
    null			    as ForWhichParty,
    null			    as ServeByID  
--select *
FROM DepoWitnessPivot n
JOIN [IndvOrgContacts_Indexed] IOC on IOC.SAGA= convert(varchar(50),n.[Witness Name])
JOIN [sma_TRN_Cases] CAS on CAS.Needles_saga = convert(varchar(50),n.CasesID)
GO

-- UPDATE COURT REPORTER INFO
UPDATE user_tab_contacts_helper 
SET CourtReporterCID=IOC.CID,
	CourtReporterCTG=IOC.CTG,
	CourtReporterAID=IOC.AID,
	CourtReporterUniqueID=IOC.UNQCID,
	CourtReporterName = ioc.[name]
FROM DepoWitnessPivot n
JOIN [IndvOrgContacts_Indexed] IOC on IOC.SAGA= convert(varchar(50),n.[Court Reporter])
WHERE tabid= convert(varchar(50), n.tablistid)
GO


--UPDATE DEPO LOCATION INTO
UPDATE user_tab_contacts_helper 
SET DepoLocationNameID = [Location of Deposition],
	DepoLocationName = ioc.[name],
	DepoLocationCID = ioc.cid,
	DepoLocationAID = ioc.AID,
	DepoLocationCTG = ioc.CTG
FROM DepoWitnessPivot n
JOIN [IndvOrgContacts_Indexed] IOC on IOC.SAGA= convert(varchar(50),n.[Location of Deposition])
WHERE tabid= convert(varchar(50), n.tablistid)
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
    D.[Type of Witness]  as cntsDscrptn,
    'O'					 as cntsRoleGroup,
    1					 as cntbFlag
FROM DepoWitnessPivot D WHERE isnull(D.[Type of Witness],'')<>''
EXCEPT
SELECT cntnContactCtgID,cntsDscrptn,cntsRoleGroup,cntbFlag FROM sma_MST_ContactTypes
GO
-----------------------------------------------------
----------------- EXPERT SPECIALITY -----------------
-----------------------------------------------------
INSERT INTO sma_MST_Speciality ( splsSpeciality,splnContactTypeID )
SELECT DISTINCT UD.[Type of Expert],
	(SELECT cntnContactTypeID from sma_MST_ContactTypes where cntsDscrptn='Experts')
FROM DepoWitnessPivot UD where isnull(UD.[Type of Expert],'')<>''
EXCEPT
SELECT 
	splsSpeciality,
	(SELECT cntnContactTypeID FROM sma_MST_ContactTypes WHERE cntsDscrptn='Experts')
FROM sma_MST_Speciality
GO

-----------------------------------------------------
----------------- DEPOSITION TYPES -----------------
-----------------------------------------------------
INSERT INTO [sma_MST_DepositionType] ( dptsDescription )
SELECT DISTINCT
    D.[Type of Witness]   as cntsDscrptn
FROM DepoWitnessPivot D WHERE isnull(D.[Type of Witness],'')<>''
EXCEPT 
SELECT dptsDescription FROM [sma_MST_DepositionType]
GO

---------------------------------------------
--------------- WITNESS TYPES-- -------------
---------------------------------------------
INSERT INTO SMA_MST_WitnessType (WitnessType, CreatedBy, CreatedDate)
SELECT DISTINCT [Type of Witness], 368, GETDATE()
FROM DepoWitnessPivot D 
LEFT JOIN SMA_MST_WitnessType WT on WT.WitnessType = d.[Type of Witness]
WHERE d.[Type of Witness]  <> 'Expert'
and WT.ID IS NULL
GO

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
	(select ID from SMA_MST_WitnessType where witnesstype = UD.[Type of Witness])		as [witnRoleID],
	case when [Type of Witness] = 'Party' then 1
		else NULL end		as [witnFavorable],
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
JOIN DepoWitnessPivot UD on convert(varchar(50),UD.tablistid) = CH.tabID and convert(varchar(50),ud.CasesID) = ch.caseID
WHERE [Type of Witness] <> 'Expert'
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
	case when ud.[Type of Witness] = 'Party' then 0
		else 2 end				 as ectnExpertFor,  -- 0 for Plaintiff, 1 for Defendant, 2=neutral
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
FROM user_tab_contacts_helper MAP
JOIN DepoWitnessPivot UD on convert(varchar(50),UD.tablistid) = MAP.tabID
WHERE UD.[Type of Witness] = 'Expert'
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
		(SELECT splnSpecialityID FROM sma_MST_Speciality WHERE UD.[Type of Expert] = splsSpeciality)		as [ExpertSpecialtyID],
		null									as [ExpertSubSpecialtyID],
		map.WitnessCID							as [ExpertContactID],
		map.WitnessCTG							as [ExpertContactCtg],
		368										as [CreatedUserID],
		getdate()								as [CreatedDate],
		NULL									as [ModifiedUserID],
		NULL									as [ModifiedDate]
FROM user_tab_contacts_helper MAP
JOIN DepoWitnessPivot UD on convert(varchar(50),UD.tablistid) = MAP.tabID
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
    (select dptnDepositionTypeID FROM [dbo].[sma_MST_DepositionType] where dptsDescription=UD.[Type of Witness])		as [dpsnType],
    case when ud.[Depo Date] between '1/1/1900' and '6/6/2079' then ud.[Depo Date] else NULL end			as [dpsdOnDate],
    NULL						as [dpsdTrnscrptServedDt],
	NULL						as [dpsdTrnscrptRcvdDt],
	ISNULL(('Depo Time: ' + nullif(convert(varchar,UD.[Depo Time]),'') + CHAR(13)),'') + 
	ISNULL(('Notes: ' + nullif(convert(varchar(max),UD.Notes),'') + CHAR(13)),'') + 
	ISNULL(('Depo Prep Date: ' + nullif(convert(varchar,UD.[Depo Prep Date]),'') + CHAR(13)),'') + 
	ISNULL(('Interpreter?: ' + nullif(convert(varchar,UD.Interpreter),'') + CHAR(13)),'') + 
    ISNULL(('Depo Location: ' + nullif(Map.depoLocationName,'') + CHAR(13)),'') + 
	ISNULL(('Ct. Reporter Cost: ' + nullif(convert(varchar(max),UD.[court reporter cost]),'') + CHAR(13)),'') + 
	ISNULL(('CV on File?: ' + nullif(convert(varchar(max),UD.[CV on File?]),'') + CHAR(13)),'') + 
	ISNULL(('Expert Cost: ' + nullif(convert(varchar(max),UD.[Expert Cost]),'') + CHAR(13)),'') + 
	ISNULL(('Interpreter: ' + nullif(convert(varchar(max),UD.[Interpreter]),'') + CHAR(13)),'') + 
	ISNULL(('Videographer Cost: ' + nullif(convert(varchar(max),UD.[Videographer Cost]),'') + CHAR(13)),'') + 
    ''						  as [dpssComments],
    0,null,
    case when UD.[Video?] = 'Y' then 1 else 0 end	as [dpsbVideoTape],
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
    NULL 						as [VideoOperatorUID],
    NULL						as [VideoCompanyUID],
    NULL						as [TranslatorUID],
    null						as [TranslAgencyUID],
    UD.tablistid					as [saga]
--SELECT [Video?]
FROM DepoWitnessPivot UD
JOIN user_tab_contacts_helper MAP on MAP.caseID = convert(varchar(50),UD.CasesID) and MAP.tabID = convert(varchar(50),UD.tablistid)
GO

---
ALTER TABLE [dbo].[sma_TRN_Depositions] ENABLE TRIGGER ALL
GO
---


