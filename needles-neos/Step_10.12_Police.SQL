
USE  [SAbilleasterlyLaw]
GO
 
alter table [sma_TRN_PoliceReports] disable trigger all
delete from [sma_TRN_PoliceReports]
DBCC CHECKIDENT ('[sma_TRN_PoliceReports]', RESEED, 0);
alter table [sma_TRN_PoliceReports] enable trigger all
 

-- ALTER TABLE [sma_TRN_PoliceReports]
---ALTER COLUMN porsComments varchar(max)
GO      
 

---(0)---
 IF EXISTS (select * from sys.objects where [name]='Officer_Helper' and type='U')
BEGIN
	DROP TABLE Officer_Helper
END 
GO

CREATE TABLE Officer_Helper (
	OfficerCID int,
	OfficerCTG int,
	OfficerAID int,
	officerUNQCID INT,
	cinsGrade varchar(400)
)
GO
----
CREATE NONCLUSTERED INDEX IX_NonClustered_Index_Officer_Helper ON [Officer_Helper] (cinsGrade);   
----
GO
---(0)---
INSERT INTO Officer_Helper ( OfficerCID,OfficerCTG,OfficerAID,officerUNQCID,cinsGrade )
SELECT DISTINCT 
	I.cinnContactID	   as OfficerCID,
	I.cinnContactCtg	   as OfficerCTG,
	A.addnAddressID	   as OfficerAID, 
	convert(varchar,cinnContactCtg)+convert(varchar,i.cinnContactID)	as officerUNQCID,
	I.cinsGrade
----- select *
FROM  [NeosBillEasterly]..Police P   
JOIN [sma_MST_IndvContacts] I on I.saga_ref=convert(varchar(50),P.namesid )
JOIN [sma_MST_Address] A on A.addnContactID=I.cinnContactID and A.addnContactCtgID=I.cinnContactCtg and A.addbPrimary=1 
GO

DBCC DBREINDEX('Officer_Helper',' ',90)  WITH NO_INFOMSGS   


---(0)---
IF EXISTS (select * from sys.objects where name='Police_Helper' and type='U')
BEGIN
	DROP TABLE Police_Helper
END 
GO

CREATE TABLE Police_Helper (
	PoliceCID		int,
	PoliceCTG		int,
	PoliceAID		int,
	PoliceUNQCID	int,
	police_id		varchar(50),
	case_num		varchar(50),
	casnCaseID	int,	
	officerCID	int,
	officerAID	int,
	officerUNQcid	int
)
GO
----
CREATE NONCLUSTERED INDEX IX_NonClustered_Index_Police_Helper ON [Police_Helper] (police_id);   
----
GO

INSERT INTO Police_Helper 
(
	PoliceCID,
	PoliceCTG,
	PoliceAID,
	PoliceUNQCID,
	police_id,
	case_num,
	casnCaseID,
	officerCID,
	officerAID,
	officerUNQcid
)
SELECT 
	IOC.CID		    as PoliceCID,
	IOC.CTG		    as PoliceCTG,
	IOC.AID		    as PoliceAID,
	ioc.unqcid		as PoliceUNQCID,
	 ' '	as police_id,
	pd.casesid,
	CAS.casnCaseID	    as casnCaseID,
	( select H.OfficerCID from Officer_Helper H where H.cinsGrade =pd.officer )		as officerCID,
	( select H.OfficerAID from Officer_Helper H where H.cinsGrade =pd.officer )		as officerAID,
	( select H.officerUNQCID from Officer_Helper H where H.cinsGrade =pd.officer )	as officerUNQCID
----- select *
FROM [NeosBillEasterly]..police pd 
JOIN [sma_TRN_cases] CAS on CAS.Neos_saga = convert(varchar(50),pd.casesid)
JOIN [IndvOrgContacts_Indexed] IOC on IOC.SAGA_ref = convert(varchar(50),Pd.namesid )
GO

DBCC DBREINDEX('Police_Helper',' ',90)  WITH NO_INFOMSGS 
GO

---
ALTER TABLE [sma_TRN_PoliceReports] DISABLE TRIGGER ALL
GO
---
---(2)---
INSERT INTO [sma_TRN_PoliceReports]
(
       [pornCaseID]
      ,[pornPoliceID]
      ,[pornPoliceAdID]
      ,[porsReportNo]
      ,[porsComments]
      ,[pornPOContactID]
      ,[pornPOCtgID]
      ,[pornPOAddressID]
)
SELECT 
    MAP.casnCaseID			as pornCaseID,
    MAP.officerCID			as pornPoliceID,
    MAP.officerAID			as pornPoliceAdID,
    p.report_num	as porsReportNo,
	''						as porsComments,
    MAP.PoliceCID			as [pornPOContactID],
    MAP.PoliceCTG			as [pornPOCtgID],
    MAP.PoliceAID			as [pornPOAddressID]
--select max(len([statement context]))
FROM [NeosBillEasterly]..police  p
JOIN Police_Helper MAP on MAP.case_num = convert(varchar(50),P.casesid)
 
GO

---
ALTER TABLE [sma_TRN_PoliceReports] ENABLE TRIGGER ALL
GO
---
------- select * from sma_TRN_PoliceReports
------------------------------------------------------------
--INSERT BADGE NUMBER INTO POLICE OFFICER CONTACT UDF
------------------------------------------------------------
INSERT INTO sma_TRN_UDFValues ( udvnUDFID, udvsScreenName, udvsUDFCtg, udvnRelatedID, udvnSubRelatedID, udvsUDFValue, udvnRecUserID, udvdDtCreated)
SELECT DISTiNCT
	(select udfnUDFID from sma_MST_UDFDefinition where udfsUDFName like '%Badge #%' 
			and udfnRelatedPK = (select octnOrigContactTypeID from [dbo].[sma_MST_OriginalContactTypes] where octsDscrptn='Police Officer') ) AS udvnUDFID,
	''					as udvsScreenName,
	'R'					as udvsUDFCtg, 
	map.officerCID		as udvnRelatedID,
	1					as udvnSubRelatedID,
	p.Badge				as udvsUDFValue,
	368					as udvnRecUserID,
	getdate()			as udvdDtCreated
FROM [NeosBillEasterly]..police p
JOIN Police_Helper MAP on MAP.case_num= convert(varchar(50),P.casesid)
WHERE  isnull(officer,'') NOT IN ('','N/A','?','NONE')
and isnull(Badge,'')<> ''

