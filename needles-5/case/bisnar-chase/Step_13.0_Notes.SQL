USE [SA]
GO

/*
alter table [sma_TRN_Notes] disable trigger all
delete from [sma_TRN_Notes] 
DBCC CHECKIDENT ('[sma_TRN_Notes]', RESEED, 0);
alter table [sma_TRN_Notes] enable trigger all
*/

IF NOT EXISTS (select * From sys.tables t join sys.columns c on t.object_id = c.object_id where t.name = 'sma_trn_notes' and c.name = 'saga')
BEGIN
	alter table sma_trn_notes
	add SAGA varchar(50)
END
GO

----(0)----
INSERT INTO [sma_MST_NoteTypes] ( nttsDscrptn, nttsNoteText )
SELECT DISTINCT 
    topic as nttsDscrptn,
    topic as nttsNoteText
FROM [NeedlesNeosBisnarChase].[dbo].[case_notes_Indexed] cn
JOIN [NeedlesNeosBisnarChase]..[case_note_topic] t on cn.casenotetopicid = t.id
    EXCEPT
SELECT nttsDscrptn, nttsNoteText FROM [sma_MST_NoteTypes]
GO

---
ALTER TABLE [sma_TRN_Notes] disable trigger all
GO
---
----(1)----
INSERT INTO [sma_TRN_Notes]
(
      [notnCaseID],[notnNoteTypeID],[notmDescription],[notmPlainText],[notnContactCtgID],[notnContactId],[notsPriority],[notnFormID],[notnRecUserID],
      [notdDtCreated],[notnModifyUserID],[notdDtModified],[notnLevelNo],[notdDtInserted],[WorkPlanItemId],[notnSubject], SAGA
)
SELECT 
    casnCaseID							as [notnCaseID],
    (select min(nttnNoteTypeID) from [sma_MST_NoteTypes] where nttsDscrptn=t.topic) as [notnNoteTypeID],
    note								as [notmDescription],
    replace(note, char(10), '<br>')		as [notmPlainText],
    0									as [notnContactCtgID],
    null								as [notnContactId],
    null								as [notsPriority],
    null								as [notnFormID],
    U.usrnUserID						as [notnRecUserID],
    CASE WHEN N.note_date between '1900-01-01' and '2079-06-06' THEN n.note_date
	   ELSE '1900-01-01' end			as notdDtCreated,
    null								as [notnModifyUserID],
    null								as notdDtModified,
    null								as [notnLevelNo],
    null								as [notdDtInserted],
    null		 						as [WorkPlanItemId],
    null		 						as [notnSubject],
	convert(varchar(50),n.ID)			as SAGA
--select *
FROM [NeedlesNeosBisnarChase].[dbo].[case_notes_Indexed] N
LEFT JOIN [NeedlesNeosBisnarChase]..[case_note_topic] t on n.casenotetopicid = t.id
JOIN [sma_TRN_Cases] C on C.Needles_saga = convert(varchar(50),N.casesid)
LEFT JOIN [sma_MST_Users] U on U.saga = convert(varchar(50),N.staffcreatedid)
LEFT JOIN [sma_TRN_Notes] ns on ns.saga = convert(varchar(50),n.ID)
WHERE ns.notnNoteID IS NULL
GO


---
ALTER TABLE [sma_TRN_Notes] enable trigger all
GO
---

