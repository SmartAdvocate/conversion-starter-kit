use BenAbbot_SA
go

/*
alter table [sma_TRN_SOLs] disable trigger all
delete [sma_TRN_SOLs]
DBCC CHECKIDENT ('[sma_TRN_SOLs]', RESEED, 0);
alter table [sma_TRN_SOLs] enable trigger all
*/

---(1)---SOL for Defendant ---
alter table [sma_TRN_SOLs] disable trigger all
go

insert into [sma_TRN_SOLs]
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
	select distinct
		CAS.casnCaseID	  as [solnCaseID],
		(
			select
				sldnSOLDetID
			from sma_MST_SOLDetails
			where sldnSOLTypeID = 16
				and sldnCaseTypeID = -1
				and sldsDorP = 'D'
		)				  as [solnSOLTypeID],
		case
			when (CKL.due_date not between '1900-01-01' and '2079-12-31')
				then null
			else CKL.due_date
		end				  as [soldSOLDate],
		case
			when CKL.[status] = 'Done'
				then GETDATE()
			else null
		end				  as [soldDateComplied],
		null			  as [soldSnCFilingDate],
		null			  as [soldServiceDate],
		D.defnDefendentID as [solnDefendentID],
		null			  as [soldToProcessServerDt],
		null			  as [soldRcvdDate],
		'D'				  as [solsType],
		ISNULL('description : ' + NULLIF(CKL.[description], '') + CHAR(13), '') +
		-- isnull('staff assigned : ' + nullif(CKL.[staff_assigned],'') + CHAR(13) ,'') 
		''				  as [solsComments],
		(
			select
				usrnUserID
			from sma_MST_Users
			where source_id = CKL.staffassignedid
		)				  as [solnRecUserID],
		GETDATE()		  as [soldDtCreated],
		null			  as [solnModifyUserID],
		null			  as [soldDtModified]
	--SELECT *
	from [sma_TRN_Defendants] D
	join [sma_TRN_Cases] CAS
		on CAS.casnCaseID = D.defnCaseID
			and D.defbIsPrimary = 1
	--JOIN [sma_MST_SOLDetails] S on S.sldnCaseTypeID=CAS.casnOrgCaseTypeID and S.sldnStateID=CAS.casnStateID and S.sldnDefRole=D.defnSubRole
	join [BenAbbot_Needles].[dbo].[case_checklist] CKL
		on CONVERT(VARCHAR(50), CKL.casesid) = CAS.source_id
	where
		CKL.due_date between '1900-01-01' and '2079-06-06'
		and
		(
			select
				lim
			from [BenAbbot_Needles].[dbo].[checklist_dir]
			where ckl.checklistdirid = id
		) = 1
go

alter table [sma_TRN_SOLs] enable trigger all
go



