USE SA
GO
/*
alter table [sma_TRN_SOLs] disable trigger all
delete [sma_TRN_SOLs]
DBCC CHECKIDENT ('[sma_TRN_SOLs]', RESEED, 0);
alter table [sma_TRN_SOLs] enable trigger all
*/

---(1)---SOL for Defendant ---
ALTER TABLE [sma_TRN_SOLs] DISABLE TRIGGER ALL
GO
INSERT INTO [sma_TRN_SOLs]
(
	[solnCaseID],
	[solnSOLTypeID],
	[soldSOLDate],
	[soldDateComplied],
	[soldSnCFilingDate],
	[soldServiceDate],
	[solnDefendentID],
	[soldToProcessServerDt],
	[soldRcvdDate],
	[solsType],
     [solsComments],
     [solnRecUserID],
     [soldDtCreated],
     [solnModifyUserID],
     [soldDtModified]

)
SELECT DISTINCT
    CAS.casnCaseID		as [solnCaseID],
    (select sldnSOLDetID From sma_MST_SOLDetails where sldnSOLTypeID = 16 and sldnCaseTypeID = -1 and sldsDorP = 'D' )		as [solnSOLTypeID],
    case when ( CKL.due_date not between '1900-01-01' and '2079-12-31' )  then null else CKL.due_date end as [soldSOLDate],
    case when CKL.[status]='Done' then getdate()
	   else null end	as [soldDateComplied],
    null			    as [soldSnCFilingDate],
    null			    as [soldServiceDate],
    D.defnDefendentID	as [solnDefendentID],
    null				as [soldToProcessServerDt],
    null			    as [soldRcvdDate],
    'D'					as [solsType],
    isnull('description : ' + nullif(CKL.[description],'') + CHAR(13) ,'') +
   -- isnull('staff assigned : ' + nullif(CKL.[staff_assigned],'') + CHAR(13) ,'') 
    ''				    as [solsComments],
    (SELECT usrnUserID FROM sma_MST_Users WHERE saga=CKL.staffassignedid)			     
						as [solnRecUserID],
    getdate()		    as [soldDtCreated],
    null			    as [solnModifyUserID],
    null			    as [soldDtModified]
--SELECT *
  FROM [sma_TRN_Defendants] D
  JOIN [sma_TRN_Cases] CAS on CAS.casnCaseID = D.defnCaseID and D.defbIsPrimary=1
 --JOIN [sma_MST_SOLDetails] S on S.sldnCaseTypeID=CAS.casnOrgCaseTypeID and S.sldnStateID=CAS.casnStateID and S.sldnDefRole=D.defnSubRole
  JOIN [NeedlesNeosBisnarChase].[dbo].[case_checklist] CKL on convert(varchar(50),CKL.casesid) = CAS.Needles_saga
  WHERE CKL.due_date between '1900-01-01' and '2079-06-06'
	and (select lim FROM [NeedlesNeosBisnarChase].[dbo].[checklist_dir] where ckl.checklistdirid = id)= 1
GO

ALTER TABLE [sma_TRN_SOLs] ENABLE TRIGGER ALL
GO



