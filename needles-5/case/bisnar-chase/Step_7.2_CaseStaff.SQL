
USE [SA]
GO
/*
alter table [sma_TRN_caseStaff] disable trigger all
delete [sma_TRN_caseStaff]
DBCC CHECKIDENT ('[sma_TRN_caseStaff]', RESEED, 0);
alter table [sma_TRN_caseStaff] enable trigger all

select * 
From NeedlesNeosBisnarChase..case_staff cs
JOIN NeedlesNeosBisnarChase..matter_staff ms on ms.id = cs.matterstaffid
JOIN NeedlesNeosBisnarChase..staff_Role sr on sr.id = ms.staffroleid
*/


----(0) staff roles ----
INSERT INTO [sma_MST_SubRoleCode] ( srcsDscrptn, srcnRoleID )
SELECT CASE WHEN [role] = 'Assigned Attorney' THEN 'Primary Attorney' else [role] end, 10
FROM NeedlesNeosBisnarChase..staff_Role --where active = 1
EXCEPT SELECT srcsDscrptn, srcnRoleID from [sma_MST_SubRoleCode]


----(1)-----
---
ALTER TABLE [sma_TRN_caseStaff] DISABLE TRIGGER ALL
GO
---

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
	U.usrnContactID		      as [cssnStaffID],
	(select sbrnSubRoleId from sma_MST_SubRole where sbrsDscrptn=CASE WHEN [role] = 'Assigned Attorney' THEN 'Primary Attorney' else [role] end and sbrnRoleID=10 )	 as [cssnRoleID],
	null					  as [csssComments],
	null					  as cssdFromDate,
	null					  as cssdToDate,
	(Select usrnUserID from sma_mst_users where saga = cs.staffcreatedid)  as cssnRecUserID,
	cs.date_created			  as [cssdDtCreated],
	null					  as [cssnModifyUserID],
	null					  as [cssdDtModified],
	0					  as cssnLevelNo
--SELECT *
FROM NeedlesNeosBisnarChase..case_staff cs
JOIN NeedlesNeosBisnarChase..matter_staff ms on ms.id = cs.matterstaffid
JOIN NeedlesNeosBisnarChase..staff_Role sr on sr.id = ms.staffroleid
JOIN [sma_TRN_cases] CAS on CAS.Needles_Saga = convert(varchar(50), cs.casesid)
JOIN [sma_MST_Users] U on ( U.saga = convert(varchar(50), cs.staffid) )
GO

---
ALTER TABLE [sma_TRN_caseStaff] ENABLE TRIGGER ALL
GO
---


