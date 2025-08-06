use [SAbilleasterlyLaw]
go

 

--select * From   [NeosBillEasterly]..case_intake order by intake_taken
--select distinct deletedstaffid From   [NeosBillEasterly]..case_intake        There are row data

ALTER TABLE sma_trn_Cases
ALTER COLUMN saga int
GO

------- (0) -----  There is no row_ID at  [NeosBillEasterly].[dbo].[Case_intake], It should be added -----
ALTER TABLE [NeosBillEasterly].[dbo].[Case_intake]
ADD row_id INT;



WITH Numbered AS (
    SELECT 
         id,  -- replace this with your actual primary key or unique column
        ROW_NUMBER() OVER (ORDER BY id) + 00000 AS new_row_id
    FROM [NeosBillEasterly].[dbo].[Case_intake]
)
UPDATE CI
SET CI.row_id = N.new_row_id
FROM [NeosBillEasterly].[dbo].[Case_intake] CI
JOIN Numbered N ON CI.id = N.id;


INSERT INTO [dbo].[CaseTypeMixture](
	[matcode],
	[header],
	[description],
	[SmartAdvocate Case Type],
	[SmartAdvocate Case Sub Type]
)
SELECT '', '', '', 'Negligence', 'Unknown'
EXCEPT SELECT [matcode],[header],[description], [SmartAdvocate Case Type],[SmartAdvocate Case Sub Type] FROM CaseTypeMixture

--select * from [CaseTypeMixture]
----------------------------
--CASE SUB TYPES
----------------------------
INSERT INTO [sma_MST_CaseSubType]
(
       [cstsCode]
      ,[cstnGroupID]
      ,[cstsDscrptn]
      ,[cstnRecUserId]
      ,[cstdDtCreated]
      ,[cstnModifyUserID]
      ,[cstdDtModified]
      ,[cstnLevelNo]
      ,[cstbDefualt]
      ,[saga]
      ,[cstnTypeCode]
)
SELECT 	null				as [cstsCode],
		cstncasetypeid		as [cstnGroupID],
		MIX.[SmartAdvocate Case Sub Type] as [cstsDscrptn], 
		368 				as [cstnRecUserId],
		getdate()			as [cstdDtCreated],
		null				as [cstnModifyUserID],
		null				as [cstdDtModified],
		null				as [cstnLevelNo],
		1					as [cstbDefualt],
		null				as [saga],
		(select stcnCodeId from [sma_MST_CaseSubTypeCode] where stcsDscrptn=MIX.[SmartAdvocate Case Sub Type]) as [cstnTypeCode] 
--select mix.*
FROM [sma_MST_CaseType] CST 
JOIN [CaseTypeMixture] MIX on isnull(mix.[SmartAdvocate Case Type],'') = isnull(cst.cstsType,'') --MIX.matcode=CST.cstsCode  
LEFT JOIN [sma_MST_CaseSubType] sub on sub.[cstnGroupID] = cst.cstncasetypeid and isnull(sub.[cstsDscrptn],'') = isnull(mix.[SmartAdvocate Case Sub Type],'')
WHERE isnull(MIX.[SmartAdvocate Case Type],'')<>''
and sub.cstncasesubtypeid is null
and  isnull([SmartAdvocate Case Sub Type],'') <> ''


---------------------------------------
--INSERT INTAKE INTO CASES
---------------------------------------
INSERT INTO [sma_TRN_Cases]
( 
  [cassCaseNumber],[casbAppName],[cassCaseName],[casnCaseTypeID],[casnState],[casdStatusFromDt],[casnStatusValueID],[casdsubstatusfromdt],[casnSubStatusValueID],[casdOpeningDate],
  [casdClosingDate],[casnCaseValueID],[casnCaseValueFrom],[casnCaseValueTo],[casnCurrentCourt],[casnCurrentJudge],[casnCurrentMagistrate],[casnCaptionID],[cassCaptionText],
  [casbMainCase],[casbCaseOut],[casbSubOut],[casbWCOut],[casbPartialOut],[casbPartialSubOut],[casbPartiallySettled],[casbInHouse],[casbAutoTimer],[casdExpResolutionDate],
  [casdIncidentDate],[casnTotalLiability],[cassSharingCodeID],[casnStateID],[casnLastModifiedBy],[casdLastModifiedDate],[casnRecUserID],[casdDtCreated],[casnModifyUserID],
  [casdDtModified],[casnLevelNo],[cassCaseValueComments],[casbRefIn],[casbDelete],[casbIntaken],[casnOrgCaseTypeID],[CassCaption],[cassMdl],[office_id],saga, 
  [LIP],[casnSeriousInj],[casnCorpDefn],[casnWebImporter],[casnRecoveryClient],[cas],[ngage],[casnClientRecoveredDt],[CloseReason], Neos_saga
)
SELECT DISTINCT
    'Intake '+ RIGHT('00000' + convert(varchar,row_Id), 5 )	    as cassCaseNumber,
    '' 										as casbAppName,
    ''										as cassCaseName,
    ( select top 1 cstnCaseSubTypeID from [sma_MST_CaseSubType] ST where ST.cstnGroupID = CST.cstnCaseTypeID and ST.cstsDscrptn=MIX.[SmartAdvocate Case Sub Type] )
						as casnCaseTypeID,
    (select [sttnStateID] from [sma_MST_States] where [sttsDescription]='Tennessee')     as casnState,
    isnull(rejected_date, GETDATE())			as casdStatusFromDt,
    NULL									as casnStatusValueID,
    NULL									as casdsubstatusfromdt,
    NULL								    as casnSubStatusValueID,
    case when ( C.intake_taken not between '1900-01-01' and '2079-12-31' )  then getdate() else C.intake_taken end						 
											as casdOpeningDate,
    case when ( C.rejected_date between '1900-01-01' and '2079-12-31' ) then C.rejected_date else NULL end	    as casdClosingDate, 
	null,null,null,null,null,null,0,
	''										as cassCaptionText,
	1,0,0,0,0,0,0,1,null,null,null,0,0,
    (select [sttnStateID] from [sma_MST_States] where [sttsDescription]='Tennessee')	    as casnStateID,
    null,null,
    (select usrnUserID from sma_MST_Users where saga=C.takenbystaffid )	 as casnRecUserID,
    case when C.intake_taken between '1900-01-01' and '2079-06-06' then c.intake_taken 
	   else null end						as casdDtCreated,
    null,null,'','',null,null,null,
    cstnCaseTypeID							as casnOrgCaseTypeID,
    ''										as CassCaption,
    0										as cassMdl,
    (select office_id from sma_MST_Offices where office_name='Bill Easterly & Associates') 
											as office_id,
    row_id									as  saga,			
	null,null,null,null,null,null,null,null,
    0										as CloseReason,
	c.id             as neos_saga
--select c.matcode, name_id, mix.matcode, mix.header, mix.description, mix.[smartadvocate case type], cst.*
FROM  [NeosBillEasterly].[dbo].[Case_intake] C
left join [NeosBillEasterly]..matter  mat on c.matterid = mat.id
LEFT JOIN [CaseTypeMixture] MIX on MIX.matcode= replace(mat.matcode, ' ', '')
LEFT JOIN sma_MST_CaseType CST on isnull(CST.cstsType,'') = isnull(mix.[SmartAdvocate Case Type],'') 
 


--select * FROM [NeedlesSamElderLaw].[dbo].[Case_intake] C

------------------------------------------
--INTAKE STATUS
------------------------------------------
INSERT INTO [sma_TRN_CaseStatus] (
		[cssnCaseID],
		[cssnStatusTypeID],
		[cssnStatusID],
		[cssnExpDays],
		[cssdFromDate],
		[cssdToDt],
		[csssComments],
		[cssnRecUserID],
		[cssdDtCreated],
		[cssnModifyUserID],
		[cssdDtModified],
		[cssnLevelNo],
		[cssnDelFlag]
)
SELECT 
    CAS.casnCaseID,
    (select stpnStatusTypeID from sma_MST_CaseStatusType where stpsStatusType='Status') as [cssnStatusTypeID],
    case
	   when C.rejected_date between '1900-01-01' and '2079-06-06' 
		  then (select cssnStatusID from sma_MST_CaseStatus where csssDescription='Closed Case')
	   else (select cssnStatusID from sma_MST_CaseStatus where csssDescription='Presign - Not scheduled for Sign Up')
    end		 as [cssnStatusID],
    ''		 as [cssnExpDays],
    case when C.rejected_date between '1900-01-01' and '2079-06-06' 
		 then convert(date,C.rejected_date)   
	   else getdate()    end		 as [cssdFromDate],
    null		 as [cssdToDt],
    case when c.rejected_date is not null then 'Rejected' else '' end		 as [csssComments],
    368,
    GETDATE(),
    null,null,null,null 
FROM [sma_trn_cases] CAS
JOIN   [NeosBillEasterly]..case_intake C on C.ROW_ID = CAS.saga
GO

------------------------------
--INCIDENT
------------------------------
---
ALTER TABLE [sma_TRN_Incidents] DISABLE TRIGGER ALL
GO
ALTER TABLE [sma_TRN_Cases] DISABLE TRIGGER ALL
GO
---
INSERT INTO [sma_TRN_Incidents] (
		[CaseId],
		[IncidentDate],
		[StateID],
		[LiabilityCodeId],
		[IncidentFacts],
		[MergedFacts],
		[Comments],
		[IncidentTime],
		[RecUserID],
		[DtCreated],
		[ModifyUserID],
		[DtModified]
)
SELECT  distinct 
		CAS.casnCaseID		  as CaseId,
	 
			  null    as IncidentDate,
		(select sttnStateID from sma_MST_States where sttsCode='TN')	as [StateID],
		0					 as LiabilityCodeId, 
		STRING_AGG( REPLACE(REPLACE(d.data, CHAR(13), ''), CHAR(10), '<br>'), '<br>')  		 as IncidentFacts,
		 STRING_AGG( REPLACE(REPLACE(d.data, CHAR(13), ''), CHAR(10), '<br>'), '<br>') 				 as [MergedFacts],
		STRING_AGG( REPLACE(REPLACE(d.data, CHAR(13), ''), CHAR(10), '<br>'), '<br>') 			 as [Comments],
		null				 as [IncidentTime],
		368					 as [RecUserID],
		getdate()			 as [DtCreated],
		null				 as [ModifyUserID],
		null				 as [DtModified]
--Select *
FROM  [NeosBillEasterly]..case_intake    ink
 left join       [NeosBillEasterly]..case_intake_data d  on  ink.id = d.caseintakeid
JOIN [NeosBillEasterly]..user_case_intake_matter c ON d.usercaseintakematterid = c.id
JOIN [NeosBillEasterly]..matter m ON m.id = c.matterid
join  [sma_TRN_cases] CAS on  ink.ROW_ID = CAS.saga 
WHERE ISNULL(d.data, '') <> ''
GROUP BY CAS.casnCaseID	,d.caseintakeid   
 


UPDATE CAS
SET CAS.casdIncidentDate=INC.IncidentDate,
    CAS.casnStateID=INC.StateID,
    CAS.casnState=INC.StateID
FROM sma_trn_cases as CAS
LEFT JOIN sma_TRN_Incidents as INC on casnCaseID=caseid
WHERE INC.CaseId=CAS.casncaseid 

 

UPDATE sma_TRN_Incidents
SET IncidentFacts = REPLACE(IncidentFacts, '<br>', CHAR(10))
WHERE IncidentFacts LIKE '%<br>%';


UPDATE sma_TRN_Incidents
SET MergedFacts = REPLACE(MergedFacts, '<br>', CHAR(10))
WHERE MergedFacts LIKE '%<br>%'
 

 UPDATE sma_TRN_Incidents
SET Comments = REPLACE(Comments, '<br>', CHAR(10))
WHERE Comments LIKE '%<br>%'
 


---
ALTER TABLE [sma_TRN_Incidents] ENABLE TRIGGER ALL
GO
ALTER TABLE [sma_TRN_Cases] ENABLE TRIGGER ALL
GO
--






--------------------------
--INCIDENT LOCATION
--------------------------
--INCIDENT LOCATION UDF IF NOT EXISTS
INSERT INTO [dbo].[sma_MST_UDFDefinition] (
		[udfsUDFCtg],
		[udfnRelatedPK],
		[udfsUDFName],
		[udfsScreenName],
		[udfsType],
		[udfsLength],
		[udfsFormat],
		[udfsTableName],
		[udfsNewValues],
		[udfsDefaultValue],
		[udfnSortOrder],
		[udfbIsActive],
		[udfnRecUserID],
		[udfnDtCreated],
		[udfnModifyUserID],
		[udfnDtModified],
		[udfnLevelNo],
		[udfbIsSystem],
		[UdfShortName],
		[DisplayInSingleColumn]  )
SELECT DISTINCT 
		'C'						as [udfsUDFCtg],
		casnOrgCaseTypeID		as [udfnRelatedPK],
		'Location'				as [udfsUDFName],
		'Incident Wizard'		as [udfsScreenName],
		'Text'					as [udfsType],
		100						as [udfsLength],
		null,null,null,null,
		0						as [udfnSortOrder],
		1						as [udfbIsActive],
		368						as [udfnRecUserID],
		getdate()				as [udfnDtCreated],
		null,null,0,0,null,0 
FROM sma_trn_Cases CAS 
LEFT JOIN sma_MST_UDFDefinition UD on UD.udfnRelatedPK=cas.casnOrgCaseTypeID and UD.udfsScreenName='Incident Wizard' and udfsUDFName= 'Location'
WHERE UD.udfnUDFID IS NULL
and cas.cassCaseNumber like 'Intake%'
and isnull(casnOrgCaseTypeID,'') <> ''

--------------------------
---LOCATION UDF VALUES---
--------------------------
 
INSERT INTO [sma_TRN_UDFValues] (
       [udvnUDFID]
      ,[udvsScreenName]
      ,[udvsUDFCtg]
      ,[udvnRelatedID]
      ,[udvnSubRelatedID]            -----5
      ,[udvsUDFValue]
      ,[udvnRecUserID]
      ,[udvdDtCreated]
      ,[udvnModifyUserID]
      ,[udvdDtModified]               ----10
      ,[udvnLevelNo]
)
SELECT DISTINCT
    (select udfnUDFID from sma_MST_UDFDefinition 
	   where udfnRelatedPK= cas.casnOrgCaseTypeID
	   and udfsScreenName='Incident Wizard'
	   and udfsUDFName='Location')
    						  as [udvnUDFID],
    'Incident Wizard'		  as [udvsScreenName],
    'I'						  as [udvsUDFCtg],
    CAS.casnCaseID			  as [udvnRelatedID],
	''     as   [udvnSubRelatedID] ,
     ''		  as [udvsUDFValue], 
    368						  as [udvnRecUserID],
    getdate()				  as [udvdDtCreated],
    null					  as [udvnModifyUserID],
    null					  as [udvdDtModified],
    null					  as [udvnLevelNo]
FROM [sma_TRN_Cases] CAS
JOIN   [NeosBillEasterly]..case_intake C on C.ROW_ID = CAS.saga 
 