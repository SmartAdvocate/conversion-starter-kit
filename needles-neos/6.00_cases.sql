use   [SAbilleasterlyLaw]
go
 
alter table [sma_TRN_Cases] disable trigger all
delete from [sma_TRN_Cases] 
DBCC CHECKIDENT ('[sma_TRN_Cases]', RESEED, 0); 
alter table [sma_TRN_Cases] enable trigger all

select * from [sma_MST_CaseType]
 


--ADD NEEDLES SAGA - CASE SAGA HAS TO BE INT TYPE
IF NOT EXISTS (SELECT * FROM sys.columns WHERE Name = N'Neos_saga' AND Object_ID = Object_ID(N'sma_trn_Cases'))
BEGIN
    ALTER TABLE [sma_trn_Cases] 
	ADD Neos_saga [varchar](50) NULL; 
END
GO

---(0)---cASE GROUPS
IF NOT EXISTS ( select * from [sma_MST_CaseGroup] where [cgpsDscrptn]='Neos' )
BEGIN

  INSERT INTO [sma_MST_CaseGroup]
  (
       [cgpsCode]
      ,[cgpsDscrptn]
      ,[cgpnRecUserId]
      ,[cgpdDtCreated]
      ,[cgpnModifyUserID]
      ,[cgpdDtModified]
      ,[cgpnLevelNo]
      ,[IncidentTypeID]
      ,[LimitGroupStatuses]
  )
  SELECT 
    NULL				as [cgpsCode],
    'Neos'				as [cgpsDscrptn],
    368					as [cgpnRecUserId],
    getdate()			as [cgpdDtCreated],
    null				as [cgpnModifyUserID],
    null				as [cgpdDtModified],
    null				as [cgpnLevelNo],
    (select IncidentTypeID from [sma_MST_IncidentTypes] where Description='General Negligence')  
						as [IncidentTypeID],
    null				as [LimitGroupStatuses]
END
GO
---------------------------
--INSERT OFFICE
---------------------------
INSERT INTO [sma_mst_offices]
	(
		   [office_status]
		  ,[office_name]
		  ,[state_id]
		  ,[is_default]
		  ,[date_created]
		  ,[user_created]
		  ,[date_modified]
		  ,[user_modified]
		  ,[Letterhead]
		  ,[UniqueContactId]
		  ,[PhoneNumber]
	)
SELECT 
		   1			    as [office_status],
		  sd.Firm_name		as [office_name],
		  (select sttnStateID from sma_MST_States where sttsCode= sd.[state]) as [state_id],
		  1					as [is_default],
		  getdate()			as [date_created],
		  368				as [user_created],
		  getdate()			as [date_modified],
		  368				as [user_modified],
		  'LetterheadUt.docx' as [Letterhead],
		  NULL				as [UniqueContactId],
		  sd.phone			as [PhoneNumber]
--Select *
FROM [NeosBillEasterly]..systemdata sd
LEFT JOIN [sma_mst_offices] o on o.office_name = sd.firm_name
WHERE o.office_id IS NULL
GO


-----(0)----- Lisa
IF NOT EXISTS(SELECT * FROM sys.columns WHERE Name = N'VenderCaseType' AND Object_ID = Object_ID(N'sma_MST_CaseType'))
BEGIN
	ALTER TABLE sma_MST_CaseType
	ADD VenderCaseType varchar(100)
END
GO

-------- (1) sma_MST_CaseType ----------------------
INSERT INTO [sma_MST_CaseType] (	   		
		 [cstsCode],
		 [cstsType],
		 [cstsSubType],
		 [cstnWorkflowTemplateID],
		 [cstnExpectedResolutionDays],
		 [cstnRecUserID],
		 [cstdDtCreated],
		 [cstnModifyUserID],
		 [cstdDtModified],
		 [cstnLevelNo],
		 [cstbTimeTracking],
		 [cstnGroupID],
		 [cstnGovtMunType],
		 [cstnIsMassTort],
		 [cstnStatusID],
		 [cstnStatusTypeID],
		 [cstbActive],
		 [cstbUseIncident1],
		 [cstsIncidentLabel1],
		 [VenderCaseType]
)
SELECT  distinct 
	NULL						as cstsCode,
	[SmartAdvocate Case Type]   as cstsType,
	NULL						as cstsSubType,
	NULL						as cstnWorkflowTemplateID,
	720							as cstnExpectedResolutionDays, -- ( Hardcode 2 years )
	368							as cstnRecUserID,
	getdate()					as cstdDtCreated,
	368							as cstnModifyUserID,
	getdate()					as cstdDtModified,
	0							as cstnLevelNo,
	null						as cstbTimeTracking,
     (select cgpnCaseGroupID from sma_MST_caseGroup where cgpsDscrptn='Neos') as cstnGroupID, 
     null						as cstnGovtMunType,
     null						as cstnIsMassTort,
	(select cssnStatusID FROM [sma_MST_CaseStatus] where csssDescription='Presign - Not Scheduled For Sign Up') as cstnStatusID,
	(select stpnStatusTypeID FROM [sma_MST_CaseStatusType] where stpsStatusType='Status')	as cstnStatusTypeID,
	1							as cstbActive,
	1							as cstbUseIncident1,
	'Incident 1'				as cstsIncidentLabel1,
	'NeosBillEasterlyCaseType'		as VenderCaseType
---- select * 
FROM [CaseTypeMixture] MIX 
LEFT JOIN [sma_MST_CaseType] ct on ct.cststype = mix.[SmartAdvocate Case Type]
WHERE ct.cstncasetypeid IS NULL
GO


UPDATE [sma_MST_CaseType] 
SET	VenderCaseType='NeosBillEasterlyCaseType'
---- select *
FROM [CaseTypeMixture] MIX 
JOIN [sma_MST_CaseType] ct on ct.cststype = mix.[SmartAdvocate Case Type]
WHERE isnull(VenderCaseType,' ') = ' '


---(0) sma_MST_CaseSubTypeCode
INSERT INTO [dbo].[sma_MST_CaseSubTypeCode] ( stcsDscrptn )
SELECT DISTINCT MIX.[SmartAdvocate Case Sub Type]
---- select *
FROM [CaseTypeMixture] MIX 
WHERE isnull(MIX.[SmartAdvocate Case Sub Type],'')<>''
    EXCEPT
SELECT stcsDscrptn from [dbo].[sma_MST_CaseSubTypeCode]


---(2.1) sma_MST_CaseSubType
INSERT INTO [sma_MST_CaseSubType] (
      [cstsCode], 
      [cstnGroupID], 
      [cstsDscrptn], 
      [cstnRecUserId], 
      [cstdDtCreated], 
      [cstnModifyUserID], 
      [cstdDtModified], 
      [cstnLevelNo], 
      [cstbDefualt], 
      [saga], 
      [cstnTypeCode]
)
SELECT   distinct 
		null				as [cstsCode],
		cstncasetypeid		as [cstnGroupID],
		[SmartAdvocate Case Sub Type]		     as [cstsDscrptn], 
		368 				as [cstnRecUserId],
		getdate()			as [cstdDtCreated],
		null				as [cstnModifyUserID],
		null				as [cstdDtModified],
		null				as [cstnLevelNo],
		1					as [cstbDefualt],
		null				as [saga],
		(select stcnCodeId from [sma_MST_CaseSubTypeCode] where stcsDscrptn=[SmartAdvocate Case Sub Type]) as [cstnTypeCode] 
FROM [sma_MST_CaseType] CST 
JOIN [CaseTypeMixture] MIX on MIX.[SmartAdvocate Case Type] = CST.cststype
LEFT JOIN [sma_MST_CaseSubType] sub on sub.[cstnGroupID] = cstncasetypeid and sub.[cstsDscrptn] = [SmartAdvocate Case Sub Type]
WHERE sub.cstncasesubtypeID is null
and isnull([SmartAdvocate Case Sub Type],'') <> ''

 
 
 
 ---- select * from partyroles

--- (3.0) sma_MST_SubRole ----
INSERT INTO [sma_MST_SubRole]
([sbrsCode],[sbrnRoleID],[sbrsDscrptn],[sbrnCaseTypeID],[sbrnPriority],[sbrnRecUserID],[sbrdDtCreated],[sbrnModifyUserID],[sbrdDtModified],[sbrnLevelNo],[sbrbDefualt],[saga])
SELECT 
	[sbrsCode]			as [sbrsCode],
	[sbrnRoleID]		as [sbrnRoleID],
	[sbrsDscrptn]		as [sbrsDscrptn],
	CST.cstnCaseTypeID	as [sbrnCaseTypeID],
	[sbrnPriority]		as [sbrnPriority],
	[sbrnRecUserID]		as [sbrnRecUserID],
	[sbrdDtCreated]		as [sbrdDtCreated],
	[sbrnModifyUserID]	as [sbrnModifyUserID],
	[sbrdDtModified]	as [sbrdDtModified],
	[sbrnLevelNo]		as [sbrnLevelNo],
	[sbrbDefualt]		as [sbrbDefualt],
	[saga]				as [saga] 
--- select   distinct  s.*, MIX.matcode,CST.cstsCode
FROM sma_MST_CaseType CST
LEFT JOIN sma_mst_subrole S on CST.cstnCaseTypeID=S.sbrnCaseTypeID 
JOIN [CaseTypeMixture] MIX on MIX.matcode=CST.cstsCode  
WHERE VenderCaseType='NeosBillEasterlyCaseType'
and isnull(MIX.[SmartAdvocate Case Type], ' ')= ' '

---- (3.1) sma_MST_SubRole : use the sma_MST_SubRole.sbrsDscrptn value to set the sma_MST_SubRole.sbrnTypeCode field ---
UPDATE sma_MST_SubRole SET sbrnTypeCode=A.CodeId
FROM
(	SELECT
	S.sbrsDscrptn		as sbrsDscrptn,
	S.sbrnSubRoleId	as SubRoleId, 
	(select max(srcnCodeId) from sma_MST_SubRoleCode where srcsDscrptn=S.sbrsDscrptn) as CodeId
	FROM sma_MST_SubRole S
	JOIN sma_MST_CaseType CST on CST.cstnCaseTypeID=S.sbrnCaseTypeID and CST.VenderCaseType='NeosBillEasterlyCaseType'
) A
WHERE A.SubRoleId = sbrnSubRoleId


---- (4) specific plaintiff and defendant party roles ----
INSERT INTO [sma_MST_SubRoleCode] ( srcsDscrptn, srcnRoleID )
(
	 select  SARole, 4 from  PartyRoles where SAParty = 'Plaintiff'
     union all
     select SARole, 5 from PartyRoles  where SAParty = 'Defendant'
     union all
    select '(P)-Default Role', 4 
     union all 
    select  '(D)-Default Role', 5
   union all
   select  distinct SARole, 10 from  PartyRoles where isnull(SAParty, '' ) = ''
)
EXCEPT SELECT srcsDscrptn, srcnRoleID FROM [sma_MST_SubRoleCode]



---- (4.1) Not already in sma_MST_SubRole-----
INSERT INTO sma_MST_SubRole ( sbrnRoleID,sbrsDscrptn,sbrnCaseTypeID,sbrnTypeCode)

SELECT T.sbrnRoleID,T.sbrsDscrptn,T.sbrnCaseTypeID,T.sbrnTypeCode
FROM 
(	SELECT 
		R.PorD			    as sbrnRoleID,
		R.[role]			    as sbrsDscrptn,
		CST.cstnCaseTypeID	    as sbrnCaseTypeID,
		(select srcnCodeId from sma_MST_SubRoleCode where srcsDscrptn = R.role and srcnRoleID = R.PorD) as sbrnTypeCode
	FROM sma_MST_CaseType CST
CROSS JOIN 
(
	SELECT '(P)-Default Role' as role, 4 as PorD
		UNION ALL
	SELECT '(D)-Default Role' as role, 5 as PorD
		UNION ALL
	SELECT SARole as role, 4 as PorD from [PartyRoles] where SAParty='Plaintiff'
		UNION ALL
	SELECT SARole  as role, 5 as PorD from [PartyRoles] where SAParty='Defendant'
	    union all
    select   SARole as role, 10  as PorD from  PartyRoles where isnull(SAParty, '' ) = ''
) R
WHERE CST.VenderCaseType='NeosBillEasterlyCaseType'
) T
EXCEPT SELECT sbrnRoleID,sbrsDscrptn,sbrnCaseTypeID,sbrnTypeCode FROM sma_MST_SubRole



 
/*---Checking---
SELECT CST.cstnCaseTypeID,CST.cstsType,sbrsDscrptn
FROM sma_MST_SubRole S
INNER JOIN sma_MST_CaseType CST on CST.cstnCaseTypeID=S.sbrnCaseTypeID
WHERE CST.VenderCaseType='NeosBillEasterlyCaseType'
and sbrsDscrptn='(D)-Default Role'
ORDER BY CST.cstnCaseTypeID   */
 


-------- (5) sma_TRN_cases ----------------------
ALTER TABLE [sma_TRN_Cases] DISABLE TRIGGER ALL
GO

INSERT INTO [sma_TRN_Cases]
( 
  [AutoUpdateName],[Locked],[cassCaseNumber]  ,[casbAppName],[cassCaseName],[casnCaseTypeID]  ,[casnState],[casdStatusFromDt],[casnStatusValueID],[casdsubstatusfromdt],[casnSubStatusValueID],[casdOpeningDate],
  [casdClosingDate],[casnCaseValueID],[casnCaseValueFrom],[casnCaseValueTo],[casnCurrentCourt],[casnCurrentJudge],[casnCurrentMagistrate],[casnCaptionID],[cassCaptionText],
  [casbMainCase],[casbCaseOut],[casbSubOut],[casbWCOut],[casbPartialOut],[casbPartialSubOut],[casbPartiallySettled],[casbInHouse],[casbAutoTimer],[casdExpResolutionDate],
  [casdIncidentDate],[casnTotalLiability],[cassSharingCodeID],[casnStateID],[casnLastModifiedBy],[casdLastModifiedDate],[casnRecUserID],[casdDtCreated],[casnModifyUserID],
  [casdDtModified],[casnLevelNo],[cassCaseValueComments],[casbRefIn],[casbDelete],[casbIntaken],[casnOrgCaseTypeID],[CassCaption],[cassMdl],[office_id],[saga],
  [LIP],[casnSeriousInj],[casnCorpDefn],[casnWebImporter],[casnRecoveryClient],[cas],[ngage],[casnClientRecoveredDt],[CloseReason], [Neos_saga]   
)
SELECT  distinct 
    1    as AutoUpdateName,
	0    as Locked    ,
    C.casenum		    as cassCaseNumber  ,
    ''					as casbAppName,
    case when (case_title LIKE '%vs.%'  or  case_title LIKE '%v.%' or case_title like '% vs %'  or case_title like '% v %') then left(case_title, 200)
	        else ''
	end   as cassCaseName,
    ( select cstnCaseSubTypeID from [sma_MST_CaseSubType] ST where ST.cstnGroupID = CST.cstnCaseTypeID and ST.cstsDscrptn=MIX.[SmartAdvocate Case Sub Type] ) 
						as casnCaseTypeID   ,
   (select [sttnStateID] from [sma_MST_States] where [sttsCode]=isnull(s.[data], 'TN'))		as casnState,   
    GETDATE()		    as casdStatusFromDt,
    (select cssnStatusID FROM [sma_MST_CaseStatus] where csssDescription='')
						as casnStatusValueID,
    GETDATE()		    as casdsubstatusfromdt,
    (select cssnStatusID FROM [sma_MST_CaseStatus] where csssDescription='Presign - Not Scheduled For Sign Up')
						as casnSubStatusValueID,
    case when ( C.date_opened not between '1900-01-01' and '2079-12-31' )  then getdate() 
	          else  isnull(isnull(C.date_opened, c.date_created), '1922-1-1') 
	end		as casdOpeningDate,
    case when ( C.close_date not between '1900-01-01' and '2079-12-31' )  then getdate() else C.close_date end						 
						as casdClosingDate, 
	null,null,null,null,null,null,0,
	case_title			as cassCaptionText,
	1,0,0,0,0,0,0,1,null,null,null,0,0,
    (select [sttnStateID] from [sma_MST_States] where [sttsCode]=isnull(s.[data], 'TN'))		as casnStateID,     
    null,null,
    (select usrnUserID from sma_MST_Users where saga=C.staffintakeid )	 as casnRecUserID,
    case when C.intake_date between '1900-01-01' and '2079-06-06' --and C.intake_time between '1900-01-01' and '2079-06-06' 
			THEN ( select cast(convert(date,C.intake_date) as datetime) + cast(convert(time,C.intake_date) as datetime))
	   else null end	as casdDtCreated,
    null,null,'','',null,null,null,
    cstnCaseTypeID	    as casnOrgCaseTypeID,
    ''					as CassCaption,
    0					as cassMdl,
    (select office_id from sma_MST_Offices where office_name= (select firm_name from  [NeosBillEasterly]..systemdata)) 
						as office_id,
    '',null,null,null,null,null,null,null,null,
    0					as CloseReason,
	c.[id]				as [Neos_saga]    
--SELECT *
FROM  [NeosBillEasterly].[dbo].[cases_Indexed] C
LEFT JOIN (SELECT td.casesid , td.[data]
		        FROM  [NeosBillEasterly]..user_case_data td
		       JOIN  [NeosBillEasterly]..user_case_fields ucf on ucf.id = td.usercasefieldid
		       WHERE field_title = 'State') s on s.casesid = c.id                               ----------
LEFT JOIN [NeosBillEasterly] ..[matter] m on m.id = c.matterid
JOIN caseTypeMixture mix on mix.matcode = m.matcode
LEFT JOIN sma_MST_CaseType CST on CST.cstsType = mix.[SmartAdvocate Case Type] and VenderCaseType='NeosBillEasterlyCaseType'
ORDER BY C.casenum
GO

---
ALTER TABLE [sma_TRN_Cases] ENABLE TRIGGER ALL
GO



---- select * from sma_trn_cases