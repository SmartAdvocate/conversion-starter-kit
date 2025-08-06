
use [SA]
go
/*
alter table [sma_TRN_PoliceReports] disable trigger all
delete from [sma_TRN_PoliceReports]
DBCC CHECKIDENT ('[sma_TRN_PoliceReports]', RESEED, 0);
alter table [sma_TRN_PoliceReports] enable trigger all
*/
/*
select  td.casesid, ucf.field_title, ucf.field_type, ucf.field_len, td.[data] as FieldData, td.[namesid] FieldNamesID
from [NeedlesNeosBisnarChase]..user_tab6_data td
JOIN [NeedlesNeosBisnarChase]..user_case_fields ucf on ucf.id = td.usercasefieldid
where field_Title in ('Officer','Police Dept','Police Report Scanned?','Police Report?','Report Number','Badge','Statement Taken?','Statement Context')
order by ucf.field_title
*/

ALTER TABLE [sma_TRN_PoliceReports]
ALTER COLUMN porsComments varchar(max)
GO

---------------------------------------
--POLICE OFFICER PIVOT TABLE
---------------------------------------
IF EXISTS (SELECT * FROM sys.tables where name = 'PoliceOfficerPivot')
BEGIN
	DROP TABLE PoliceOfficerPivot
END


SELECT casesid, Officer, [Police Dept], [Police Report Scanned?], [Police Report?],[Report Number], Badge,[Statement Taken?],[Statement Context],[Photographs],[Photos Taken At Accident]
INTO PoliceOfficerPivot
FROM
(
	SELECT td.casesid, case when convert(varchar(50),td.[namesid]) IS NULL then td.[data] else convert(varchar(50),td.[namesid]) end as [data], ucf.field_title
	FROM [NeedlesNeosBisnarChase]..user_tab6_data td
	JOIN [NeedlesNeosBisnarChase]..user_case_fields ucf on ucf.id = td.usercasefieldid
	WHERE field_Title in ('Officer','Police Dept','Police Report Scanned?','Police Report?','Report Number','Badge','Statement Taken?','Statement Context','Photographs','Photos Taken At Accident')
) d
pivot
(
  max([data])
  for field_title in (Officer, [Police Dept], [Police Report Scanned?], [Police Report?],[Report Number], Badge,[Statement Taken?],[Statement Context],[Photographs],[Photos Taken At Accident])
) piv;


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
FROM PoliceOfficerPivot P   --SCHECHTER POLICE DATA COMES FROM TAB6, NOT THE POLICE TABLE
JOIN [sma_MST_IndvContacts] I on I.cinsGrade=P.officer and I.cinsPrefix='Officer' 
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
	convert(varchar(50),PD.[Police Dept])	as police_id,
	pd.casesid,
	CAS.casnCaseID	    as casnCaseID,
	( select H.OfficerCID from Officer_Helper H where H.cinsGrade =pd.officer )		as officerCID,
	( select H.OfficerAID from Officer_Helper H where H.cinsGrade =pd.officer )		as officerAID,
	( select H.officerUNQCID from Officer_Helper H where H.cinsGrade =pd.officer )	as officerUNQCID
FROM PoliceOfficerPivot pd
JOIN [sma_TRN_cases] CAS on CAS.Needles_saga = convert(varchar(50),pd.casesid)
JOIN [IndvOrgContacts_Indexed] IOC on IOC.SAGA = convert(varchar(50),Pd.[Police Dept])
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
    left(P.[Report Number],30)	as porsReportNo,
    isnull('Badge: ' + nullif(P.badge,'') +CHAR(13),'' )  +
	isnull('Police Report? ' + nullif(P.[Police Report?],'') +CHAR(13),'' )  +
	isnull('Police Report Scanned? ' + nullif(P.[Police Report Scanned?],'') +CHAR(13),'' )  +
	isnull('Statement Taken? ' + nullif(P.[statement taken?],'') +CHAR(13),'' )  +
	isnull('Statement Context: ' + nullif(P.[statement context],'') +CHAR(13),'' )  +
	isnull('Photographs: ' + nullif(P.[Photographs],'') +CHAR(13),'' )  +
	isnull('Photos Taken at Accident: ' + nullif(P.[Photos Taken At Accident],'') +CHAR(13),'' )  +
	''						as porsComments,
    MAP.PoliceCID			as [pornPOContactID],
    MAP.PoliceCTG			as [pornPOCtgID],
    MAP.PoliceAID			as [pornPOAddressID]
--select max(len([statement context]))
FROM PoliceOfficerPivot p
JOIN Police_Helper MAP on MAP.case_num = convert(varchar(50),P.casesid)
WHERE isnull([Police Dept],'') <> ''
or isnull([Police Report?],'')<> ''
or isnull(Badge,'')<> ''
or isnull(p.[statement taken?],'')<> ''
or isnull(p.[statement context],'')<>''
GO

---
ALTER TABLE [sma_TRN_PoliceReports] ENABLE TRIGGER ALL
GO
---
/*
select * from sma_MST_UDFDefinition
where udfsUDFName like '%Badge #%'

select octnOrigContactTypeID from [dbo].[sma_MST_OriginalContactTypes] where octsDscrptn='Police Officer'
*/
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
FROM PoliceOfficerPivot p
JOIN Police_Helper MAP on MAP.case_num= convert(varchar(50),P.casesid)
WHERE isnull(Officer,'') <> ''
and isnull(Badge,'')<> ''

