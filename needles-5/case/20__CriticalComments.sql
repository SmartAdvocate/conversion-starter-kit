use [BenAbbot_SA]
go

insert into [sma_TRN_CriticalComments]
	(
		[ctcnCaseID],
		[ctcnCommentTypeID],
		[ctcsText],
		[ctcbActive],
		[ctcnRecUserID],
		[ctcdDtCreated],
		[ctcnModifyUserID],
		[ctcdDtModified],
		[ctcnLevelNo],
		[ctcsCommentType]
	)
	select
		cas.casnCaseID as [ctcncaseid],
		0			   as [ctcncommenttypeid],
		special_note   as [ctcstext],
		1			   as [ctcbactive],
		(
			select
				usrnUserID
			from sma_MST_Users
			where source_id = CONVERT(VARCHAR(50), staffcreatedid)
		)			   as [ctcnRecUserID],
		date_created   as [ctcdDtCreated],
		(
			select
				usrnUserID
			from sma_MST_Users
			where source_id = CONVERT(VARCHAR(50), staffmodifiedid)
		)			   as [ctcnModifyUserID],
		date_modified  as [ctcdDtModified],
		null		   as [ctcnlevelno],
		null		   as [ctcscommenttype]
	from [BenAbbot_Needles].[dbo].[cases_Indexed] c
	join [sma_trn_cases] CAS
		on CAS.source_id = CONVERT(VARCHAR(50), C.id)
	where
		ISNULL(special_note, '') <> ''