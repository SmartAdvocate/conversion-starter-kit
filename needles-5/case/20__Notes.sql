use BenAbbot_SA
go

/* ------------------------------------------------------------------------------
Create Note Types
*/
insert into [sma_MST_NoteTypes]
	(
		nttsDscrptn,
		nttsNoteText
	)

	-- from [case_notes].[topic]
	select distinct
		cnt.topic as nttsdscrptn,
		cnt.topic as nttsnotetext
	from [BenAbbot_Needles].[dbo].[case_notes_Indexed] cn
	join BenAbbot_Needles..case_note_topic cnt
		on cnt.id = cn.casenotetopicid
	union all

	-- from [value_notes].[topic]
	select distinct
		vnt.topic,
		vnt.topic
	from [BenAbbot_Needles]..value_notes vn
	join BenAbbot_Needles..value_note_topic vnt
		on vnt.id = vn.valuenotetopicid
	except
	select
		nttsDscrptn,
		nttsNoteText
	from [sma_MST_NoteTypes]
go

/* ------------------------------------------------------------------------------
Insert Notes 
*/
alter table [sma_TRN_Notes] disable trigger all
go

-- from [case_notes_indexed]
insert into [sma_TRN_Notes]
	(
		[notnCaseID],
		[notnNoteTypeID],
		[notmDescription],
		[notmPlainText],
		[notnContactCtgID],
		[notnContactId],
		[notsPriority],
		[notnFormID],
		[notnRecUserID],
		[notdDtCreated],
		[notnModifyUserID],
		[notdDtModified],
		[notnLevelNo],
		[notdDtInserted],
		[WorkPlanItemId],
		[notnSubject],
		[saga],
		[source_id],
		[source_db],
		[source_ref]
	)
	select
		casnCaseID						as [notncaseid],
		(
			select
				MIN(nttnNoteTypeID)
			from [sma_MST_NoteTypes]
			where nttsDscrptn = cnt.topic
		)								as [notnnotetypeid],
		note							as [notmdescription],
		REPLACE(note, CHAR(10), '<br>') as [notmplaintext],
		0								as [notncontactctgid],
		null							as [notncontactid],
		null							as [notspriority],
		null							as [notnformid],
		u.usrnUserID					as [notnrecuserid],
		case
			when N.note_date between '1900-01-01' and '2079-06-06'
				then n.note_date
			else '1900-01-01'
		end								as notdDtCreated,
		(
			select
				usrnUserID
			from sma_MST_Users
			where source_id = CONVERT(VARCHAR(50), n.staffmodifiedid)
		)								as [notnmodifyuserid],
		n.date_modified					as notddtmodified,
		null							as [notnlevelno],
		null							as [notddtinserted],
		null							as [workplanitemid],
		null							as [notnsubject],
		null							as saga,
		n.id							as [source_id],
		'needles'						as [source_db],
		'case_notes_indexed'			as [source_ref]
	from [BenAbbot_Needles].[dbo].[case_notes_Indexed] n
	join [sma_TRN_Cases] C
		on C.source_id = CONVERT(VARCHAR(50), N.casesid)
	left join [BenAbbot_Needles]..[case_note_topic] cnt
		on n.casenotetopicid = cnt.id
	left join [sma_MST_Users] u
		on u.source_id = n.staffcreatedid
	left join [sma_TRN_Notes] ns
		on ns.source_id = n.id
	where
		ns.notnNoteID is null
go

-------------------------------------------------
-- from [value_notes]
insert into [sma_TRN_Notes]
	(
		[notnCaseID],
		[notnNoteTypeID],
		[notmDescription],
		[notmPlainText],
		[notnContactCtgID],
		[notnContactId],
		[notsPriority],
		[notnFormID],
		[notnRecUserID],
		[notdDtCreated],
		[notnModifyUserID],
		[notdDtModified],
		[notnLevelNo],
		[notdDtInserted],
		[WorkPlanItemId],
		[notnSubject],
		[saga],
		[source_id],
		[source_db],
		[source_ref]
	)
	select
		casnCaseID						as [notncaseid],
		(
			select
				MIN(nttnNoteTypeID)
			from [sma_MST_NoteTypes]
			where nttsDscrptn = vnt.topic
		)								as [notnnotetypeid],
		note							as [notmdescription],
		REPLACE(note, CHAR(10), '<br>') as [notmplaintext],
		0								as [notncontactctgid],
		null							as [notncontactid],
		null							as [notspriority],
		null							as [notnformid],
		u.usrnUserID					as [notnrecuserid],
		case
			when vn.note_date between '1900-01-01' and '2079-06-06'
				then vn.note_date
			else '1900-01-01'
		end								as notdDtCreated,
		(
			select
				usrnUserID
			from sma_MST_Users
			where source_id = CONVERT(VARCHAR(50), vn.staffmodifiedid)
		)								as [notnmodifyuserid],
		vn.date_modified				as notddtmodified,
		null							as [notnlevelno],
		null							as [notddtinserted],
		null							as [workplanitemid],
		null							as [notnsubject],
		null							as saga,
		vn.id							as [source_id],
		'needles'						as [source_db],
		'valuenotes'					as [source_ref]
	from [BenAbbot_Needles].[dbo].value_notes vn
	join BenAbbot_Needles..value v
		on v.id = vn.valueid
	join [sma_TRN_Cases] C
		on C.source_id = CONVERT(VARCHAR(50), v.casesid)
	left join [BenAbbot_Needles]..[value_note_topic] vnt
		on vn.valuenotetopicid = vnt.id
	left join [sma_MST_Users] u
		on u.source_id = vn.staffcreatedid
	left join [sma_TRN_Notes] ns
		on ns.source_id = vn.id
	where
		ns.notnNoteID is null
go

---
alter table [sma_TRN_Notes] enable trigger all
go

/* ------------------------------------------------------------------------------
Insert "Related To"
*/ ------------------------------------------------------------------------------
--insert into sma_TRN_NoteContacts
--	(
--		NoteID,
--		UniqueContactID
--	)
--	select distinct
--		note.notnNoteID,
--		ioc.UNQCID
--	--select v.provider, ioc.*, n.note, note.*
--	from [BenAbbot_Needles]..[value_notes] n
--	join [BenAbbot_Needles]..value_Indexed v
--		on v.value_id = n.value_num
--	join sma_trn_Cases cas
--		on cas.cassCaseNumber = v.case_id
--	join IndvOrgContacts_Indexed ioc
--		on ioc.saga = v.[provider]
--	join [sma_TRN_Notes] note
--		on note.saga = n.note_key
--			and note.[notnNoteTypeID] = (
--				select top 1
--					nttnNoteTypeID
--				from [sma_MST_NoteTypes]
--				where nttsDscrptn = n.topic
--			)