USE  [SAbilleasterlyLaw]
GO

SET IDENTITY_INSERT sma_mst_SubRoleCode ON;

INSERT INTO [sma_MST_SubRoleCode] ( srcnCodeId, srcsDscrptn, srcnRoleID )
select 429, 'Rejected By (Staff)', 10
union 
select 430, 'Deleted By (Staff)', 10


SET IDENTITY_INSERT sma_mst_SubRoleCode OFF;


--case staff
------------------
--STAFF 1
------------------
insert into sma_TRN_caseStaff 
(
       [cssnCaseID]
      ,[cssnStaffID]
      ,[cssnRoleID]
      ,[csssComments]
      ,[cssdFromDate]
      ,[cssdToDate]
      ,[cssnRecUserID]
      ,[cssdDtCreated]
      ,[cssnModifyUserID]
      ,[cssdDtModified]
      ,[cssnLevelNo]
)
select    distinct 
	CAS.casnCaseID			  as [cssnCaseID],
	U.usrnContactID		  as [cssnStaffID],
    case when  u.usrsLoginID = 'BE'  then (select sbrnSubRoleId from sma_MST_SubRole where sbrsDscrptn='Primary Attorney' and sbrnRoleID=10 )	
	        when   u.usrsloginID = 'WL'  then (select sbrnSubRoleId from sma_MST_SubRole where sbrsDscrptn='Primary Attorney' and sbrnRoleID=10 )	
			when  u.usrsloginID = 'BG'   then (select sbrnSubRoleId from sma_MST_SubRole where sbrsDscrptn='Paralegal' and sbrnRoleID=10 )	
			when  u.usrsloginID = 'ES'   then (select sbrnSubRoleId from sma_MST_SubRole where sbrsDscrptn='Case Manager II' and sbrnRoleID=10 )	
			when  u.usrsloginID = 'AM' then (select sbrnSubRoleId from sma_MST_SubRole where sbrsDscrptn='Primary Paralegal' and sbrnRoleID=10 )	 
			when  u.usrsloginID = 'KW' then (select sbrnSubRoleId from sma_MST_SubRole where sbrsDscrptn='Paralegal' and sbrnRoleID=10 )	
			 when  u.usrsloginID = 'PW' then (select sbrnSubRoleId from sma_MST_SubRole where sbrsDscrptn='Paralegal' and sbrnRoleID=10 )	
	        else   '33'
	end as [cssnRoleID],
	null					  as [csssComments],
	null					  as cssdFromDate,
	null					  as cssdToDate,
	368					  as cssnRecUserID,
	getdate()				  as [cssdDtCreated],
	null					  as [cssnModifyUserID],
	null					  as [cssdDtModified],
	0					  as cssnLevelNo
---- select  c.*
FROM   [NeosBillEasterly].[dbo].[case_intake] c
JOIN [sma_TRN_cases] CAS on CAS.saga = C.row_ID
left JOIN [sma_MST_Users] U on ( U.saga =  convert(varchar(50), C.primarystaffid))
LEFT JOIN sma_TRN_caseStaff cs on cs.[cssnStaffID] = u.usrnContactID
                                                        and cs.[cssnCaseID] = CAS.casnCaseID  
										--- 	 and [cssnRoleID] = (select sbrnSubRoleId from sma_MST_SubRole where sbrsDscrptn='Staff' and sbrnRoleID=10 )
WHERE  isnull(convert(varchar(50), C.primarystaffid), '')<>''
 





--Intake Staff
INSERT INTO sma_TRN_caseStaff 
(
       [cssnCaseID]
      ,[cssnStaffID]
      ,[cssnRoleID]
      ,[csssComments]
      ,[cssdFromDate]
      ,[cssdToDate]
      ,[cssnRecUserID]
      ,[cssdDtCreated]
      ,[cssnModifyUserID]
      ,[cssdDtModified]
      ,[cssnLevelNo]
)
SELECT DISTINCT
	CAS.casnCaseID			  as [cssnCaseID],
	U.usrnContactID		  as [cssnStaffID],
	(select sbrnSubRoleId from sma_MST_SubRole where sbrsDscrptn='Intake Staff' and sbrnRoleID=10 )	 as [cssnRoleID],
	null					  as [csssComments],
	null					  as cssdFromDate,
	null					  as cssdToDate,
	368					  as cssnRecUserID,
	getdate()				  as [cssdDtCreated],
	null					  as [cssnModifyUserID],
	null					  as [cssdDtModified],
	0					  as cssnLevelNo
----- select *
FROM   [NeosBillEasterly].[dbo].[case_intake] c
JOIN [sma_TRN_cases] CAS on CAS.saga = C.row_ID
left JOIN [sma_MST_Users] U on ( U.saga =  convert(varchar(50), C.takenbystaffid))
LEFT JOIN sma_TRN_caseStaff cs on cs.[cssnStaffID] = u.usrnContactID 
            and cs.[cssnCaseID] = CAS.casnCaseID 
			and [cssnRoleID] = (select sbrnSubRoleId from sma_MST_SubRole where sbrsDscrptn='Intake Staff' and sbrnRoleID=10 )
WHERE  isnull(convert(varchar(50), C.takenbystaffid), '')<>''
----------------

------ deleted by staff
INSERT INTO sma_TRN_caseStaff 
(
       [cssnCaseID]
      ,[cssnStaffID]
      ,[cssnRoleID]
      ,[csssComments]
      ,[cssdFromDate]
      ,[cssdToDate]
      ,[cssnRecUserID]
      ,[cssdDtCreated]
      ,[cssnModifyUserID]
      ,[cssdDtModified]
      ,[cssnLevelNo]
)
SELECT DISTINCT
	CAS.casnCaseID			  as [cssnCaseID],
	U.usrnContactID		  as [cssnStaffID],
	(select sbrnSubRoleId from sma_MST_SubRole where sbrsDscrptn='Deleted By (Staff)' and sbrnRoleID=10 )	 as [cssnRoleID],
	null					  as [csssComments],
	null					  as cssdFromDate,
	null					  as cssdToDate,
	368					  as cssnRecUserID,
	getdate()				  as [cssdDtCreated],
	null					  as [cssnModifyUserID],
	null					  as [cssdDtModified],
	0					  as cssnLevelNo
---- select *  
FROM   [NeosBillEasterly].[dbo].[case_intake] c
JOIN [sma_TRN_cases] CAS on CAS.saga = C.row_ID
JOIN [sma_MST_Users] U on ( U.saga = convert(varchar(50), C.deletedstaffid ))
LEFT JOIN sma_TRN_caseStaff cs on cs.[cssnStaffID] = u.usrnContactID
                                                        and cs.[cssnCaseID] = CAS.casnCaseID 
														and [cssnRoleID] = (select sbrnSubRoleId from sma_MST_SubRole where sbrsDscrptn='Deleted By (Staff)' and sbrnRoleID=10 )
WHERE isnull(convert(varchar(50), C.deletedstaffid ),'') <> ''
 

-- Rejected by Staff
INSERT INTO sma_TRN_caseStaff 
(
       [cssnCaseID]
      ,[cssnStaffID]
      ,[cssnRoleID]
      ,[csssComments]
      ,[cssdFromDate]
      ,[cssdToDate]
      ,[cssnRecUserID]
      ,[cssdDtCreated]
      ,[cssnModifyUserID]
      ,[cssdDtModified]
      ,[cssnLevelNo]
)
SELECT DISTINCT
	CAS.casnCaseID			  as [cssnCaseID],
	U.usrnContactID		  as [cssnStaffID],
	(select sbrnSubRoleId from sma_MST_SubRole where sbrsDscrptn='Rejected By (Staff)' and sbrnRoleID=10 )	 as [cssnRoleID],
	null					  as [csssComments],
	null					  as cssdFromDate,
	null					  as cssdToDate,
	368					  as cssnRecUserID,
	getdate()				  as [cssdDtCreated],
	null					  as [cssnModifyUserID],
	null					  as [cssdDtModified],
	0					  as cssnLevelNo
---- select *  
FROM   [NeosBillEasterly].[dbo].[case_intake] c
JOIN [sma_TRN_cases] CAS on CAS.saga = C.row_ID
JOIN [sma_MST_Users] U on ( U.saga = convert(varchar(50), C.rejectedstaffid ))
LEFT JOIN sma_TRN_caseStaff cs on cs.[cssnStaffID] = u.usrnContactID
                                                        and cs.[cssnCaseID] = CAS.casnCaseID 
														and [cssnRoleID] = (select sbrnSubRoleId from sma_MST_SubRole where sbrsDscrptn='Rejected By (Staff)' and sbrnRoleID=10 )
WHERE isnull(convert(varchar(50), C.rejectedstaffid ),'') <> ''
 