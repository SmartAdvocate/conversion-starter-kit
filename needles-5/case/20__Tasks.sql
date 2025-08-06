use [BenAbbot_SA]
go


/* ------------------------------------------------------------------------------
Insert Task Category
*/ ------------------------------------------------------------------------------

--select * from sma_MST_TaskCategory smtc

insert into [sma_MST_TaskCategory]
	(
		tskCtgDescription
	)

	select
		'Checklist'

	--union

	--select distinct
	--	description
	--from VanceLawFirm_Needles..case_checklist cc
	--join sma_TRN_Cases cas
	--	on cas.cassCaseNumber = CONVERT(VARCHAR, cc.case_id)

	except
	select
		tskCtgDescription
	from [sma_MST_TaskCategory]
go


/* ------------------------------------------------------------------------------
Insert Tasks
*/ ------------------------------------------------------------------------------
alter table [sma_TRN_TaskNew] disable trigger all
go

insert into [dbo].[sma_TRN_TaskNew]
	(
		[tskCaseID],
		[tskDueDate],
		[tskStartDate],
		[tskRequestorID],
		[tskAssigneeId],
		[tskReminderDays],
		[tskDescription],
		[tskCreatedDt],
		[tskCreatedUserID],
		[tskMasterID],
		[tskCtgID],
		[tskSummary],
		[tskPriority],
		[tskCompleted],
		[saga],
		[source_id],
		[source_db],
		[source_ref]
	)
	select distinct
		CAS.casnCaseID			 as [tskCaseID],
		case
			when CKL.due_date between '1900-01-01' and '2079-06-06'
				then CKL.due_date
			else '1900-01-01'
		end						 as [tskDueDate],
		null					 as [tskStartDate],
		null					 as [tskRequestorID],
		(
			select
				usrnUserID
			from sma_MST_Users
			where source_id = CONVERT(VARCHAR(50), CKL.staffassignedid)
		)						 as [tskAssigneeId],
		null					 as [tskReminderDays],
		--ltrim(CKL.[description])																as [tskDescription],
		null					 as [tskDescription],
		ckl.date_created		 as [tskCreatedDt],
		(
			select
				usrnUserID
			from sma_mst_Users
			where source_id = ckl.staffcreatedid
		)						 as tskCreatedUserID,
		(
			select
				tskMasterID
			from sma_mst_Task_Template
			where tskMasterDetails = 'Custom Task'
		)						 as [tskMasterID],
		(
			select
				tskCtgID
			from sma_MST_TaskCategory
			where tskCtgDescription = 'Checklist'
		)						 as [tskCtgID],
		LTRIM(CKL.[description]) as [tskSummary],  --task subject--
		(
			select
				uId
			from PriorityTypes
			where PriorityType = 'Normal'
		)						 as [tskPriority],
		case
			when CKL.[status] = 'Done'
				then (
						select
							StatusID
						from TaskStatusTypes
						where StatusType = 'Completed'
					)
			when CKL.[status] = 'Open'
				then (
						select
							StatusID
						from TaskStatusTypes
						where StatusType = 'In Progress'
					)
			when CKL.[status] = 'N/A'
				then (
						select
							StatusID
						from TaskStatusTypes
						where StatusType = 'Cancelled'
					)
			else (
					select
						StatusID
					from TaskStatusTypes
					where StatusType = 'Not Started'
				)
		end						 as [tskCompleted],
		null					 as [saga],
		ckl.id					 as [source_id],
		'needles'				 as [source_db],
		'case_checklist'		 as [source_ref]
	-- select * 
	from [BenAbbot_Needles].[dbo].[case_checklist] CKL
	join [sma_TRN_Cases] CAS
		on CAS.source_id = CONVERT(VARCHAR(50), CKL.casesid)
	where
		ISNULL(CAS.casdClosingDate, '') = ''
		and
		CKL.due_date between '1900-01-01' and '2079-06-06'
go


alter table [sma_TRN_TaskNew] enable trigger all
go