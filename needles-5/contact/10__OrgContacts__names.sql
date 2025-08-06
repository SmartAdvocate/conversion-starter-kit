use BenAbbot_SA
go

/* --------------------------------------------------------------------------------------------------------------
Insert Org Contacts from [names]
*/

insert into [sma_MST_OrgContacts]
	(
		[consName],
		[consWorkPhone],
		[consComments],
		[connContactCtg],
		[connContactTypeID],
		[connRecUserID],
		[condDtCreated],
		[conbStatus],
		[saga],
		[source_id],
		[source_db],
		[source_ref]
	)
	select
		N.[last_long_name] as [consName],
		null			   as [consWorkPhone],
		ISNULL('AKA: ' + NULLIF(CONVERT(VARCHAR, n.aka_full), '') + CHAR(13), '') +
		''				   as [consComments],
		2				   as [connContactCtg],
		(
			select
				octnOrigContactTypeID
			from [BenAbbot_SA].[dbo].[sma_MST_OriginalContactTypes]
			where octsDscrptn = 'General'
				and octnContactCtgID = 2
		)				   as [connContactTypeID],
		(
			select
				usrnUserID
			from sma_mst_Users u
			where u.source_id = CONVERT(VARCHAR(MAX), n.staffcreatedid)
		)				   as [connRecUserID],
		date_created	   as [condDtCreated],
		1				   as [conbStatus],		-- Hardcode Status as ACTIVE
		null			   as [saga],
		N.[id]			   as [source_id],
		'needles'		   as [source_db],
		'names'			   as [source_ref]
	from [BenAbbot_Needles].[dbo].[names] n
	where
		n.[person] <> 1
go