use   [SAbilleasterlyLaw]
go
---
ALTER TABLE [sma_TRN_Notes] DISABLE TRIGGER ALL
GO
---

----(1)----
INSERT INTO [sma_TRN_Notes]
(
      [notnCaseID],[notnNoteTypeID],[notmDescription],[notmPlainText],[notnContactCtgID],[notnContactId],[notsPriority],[notnFormID],[notnRecUserID],
      [notdDtCreated],[notnModifyUserID],[notdDtModified],[notnLevelNo],[notdDtInserted],[WorkPlanItemId],[notnSubject]
)
SELECT distinct 
    casnCaseID	 as [notnCaseID],
    (select min(nttnNoteTypeID) from [sma_MST_NoteTypes] where nttsDscrptn='Intake') as [notnNoteTypeID],
    ISNULL(('Intake taken Date: ' + nullif(convert(varchar(max),n.[intake_taken]),'') + CHAR(13)),'') +
	---ISNULL(('Date of  Incident: ' + nullif(convert(varchar(max),n.[date_of_incident]),'') + CHAR(13)),'') +
	---ISNULL(('Comments: ' + nullif(convert(varchar(max),n.[comments]),'') + CHAR(13)),'') +
	---ISNULL(('Referred By: ' + nullif(convert(varchar(max),n.[referred_by]),'') + CHAR(13)),'') +
	ISNULL(('Rejected: ' + nullif(convert(varchar(max),n.[rejected]),'') + CHAR(13)),'') +
	ISNULL(('Date of Rejected: ' + nullif(convert(varchar(max),n.[rejected_date]),'') + CHAR(13)),'') +
     ''																												as [notmDescription],
    ISNULL(('Intake taken Date: ' + nullif(convert(varchar(max),n.[intake_taken]),'') + CHAR(13)),'') +
--	ISNULL(('Date of  Incident: ' + nullif(convert(varchar(max),n.[date_of_incident]),'') + CHAR(13)),'') +
---	ISNULL(('Comments: ' + nullif(convert(varchar(max),n.[comments]),'') + CHAR(13)),'') +
--	ISNULL(('Referred By: ' + nullif(convert(varchar(max),n.[referred_by]),'') + CHAR(13)),'') +
	ISNULL(('Rejected: ' + nullif(convert(varchar(max),n.[rejected]),'') + CHAR(13)),'') +
	ISNULL(('Date of Rejected: ' + nullif(convert(varchar(max),n.[rejected_date]),'') + CHAR(13)),'') +
    ''																												as [notmPlainText],
    0			 as [notnContactCtgID],
    null		 as [notnContactId],
    null		 as [notsPriority],
    null		 as [notnFormID],
    368			 as [notnRecUserID],
    case when N.intake_taken between '1900-01-01' and '2079-06-06' then n.intake_taken
	   else getdate() end		 as notdDtCreated,
    null		 as [notnModifyUserID],
    null		 as notdDtModified,
    null		 as [notnLevelNo],
    null		 as [notdDtInserted],
    null		 as [WorkPlanItemId],
    null		 as [notnSubject]
------ select *
FROM   [NeosBillEasterly].[dbo].case_intake N
JOIN [sma_TRN_Cases] C on C.saga = N.ROW_ID
GO

---
alter table [sma_TRN_Notes] enable trigger all
GO
---
