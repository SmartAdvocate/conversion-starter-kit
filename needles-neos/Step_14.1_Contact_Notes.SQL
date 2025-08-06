
use  [SAbilleasterlyLaw]
go
 

 
 


---
ALTER TABLE [sma_TRN_Notes] DISABLE TRIGGER ALL
GO
---

----(1)----
INSERT INTO sma_TRN_Notes 
( 
    notnCaseID,
    notnNoteTypeID,
    notmDescription,
    notmPlainText,
    notnContactCtgID,
    notnContactId,
    notsPriority,
    notnFormID,
    notnRecUserID,
    notdDtCreated,
    notnModifyUserID,
    notdDtModified
)
SELECT 
    0					as notnCaseID,
    (select nttnNoteTypeID FROM sma_MST_NoteTypes where nttsCode='CONTACT') as notnNoteTypeID,
    case
	   when isnull(date_of_majority,'')='' then 'Date of Majority : N/A'
	   else  'Date of Majority : ' + convert(varchar,date_of_majority)
    end					as notmDescription,

    case
	   when isnull(date_of_majority,'')='' then 'Date of Majority : N/A'
	   else  'Date of Majority : ' + convert(varchar,date_of_majority)
    end					as notmPlainText,
    I.cinnContactCtg    as notnContactCtgID,
    I.cinnContactID	    as notnContactId,
    'Normal'		    as notsPriority,
    0					as notnFormID,
    368					as notnRecUserID,
    getdate()		    as notdDtCreated,
    NULL			    as notnModifyUserID,
    NULL			    as notdDtModified
FROM [NeosBillEasterly].[dbo].[party] P
JOIN sma_MST_IndvContacts I on I.saga_ref= convert(varchar(50),P.namesid)

----(2)----
INSERT INTO sma_TRN_Notes 
( 
    notnCaseID,
    notnNoteTypeID,
    notmDescription,
    notmPlainText,
    notnContactCtgID,
    notnContactId,
    notsPriority,
    notnFormID,
    notnRecUserID,
    notdDtCreated,
    notnModifyUserID,
    notdDtModified
) 
SELECT 
    0					as notnCaseID,
    (select nttnNoteTypeID FROM sma_MST_NoteTypes where nttsCode='CONTACT') as notnNoteTypeID,
    case
	   when isnull(minor,' ')=' ' then 'Minor : N'
	   else  'Minor : ' + convert(varchar,minor)
    end					as notmDescription,
    case
	   when isnull(minor,' ')=' ' then 'Minor : N'
	   else  'Minor : ' + convert(varchar,minor)
    end					as notmPlainText,
    I.cinnContactCtg    as notnContactCtgID,
    I.cinnContactID	    as notnContactId,
    'Normal'		    as notsPriority,
    0					as notnFormID,
    368					as notnRecUserID,
    getdate()		    as notdDtCreated,
    NULL			    as notnModifyUserID,
    NULL			    as notdDtModified
FROM [NeosBillEasterly].[dbo].[party] P
JOIN sma_MST_IndvContacts I on I.saga_ref= convert(varchar(50),P.namesid)


---(3)--- 
INSERT INTO sma_TRN_Notes 
( 
    notnCaseID,
    notnNoteTypeID,
    notmDescription,
    notmPlainText,
    notnContactCtgID,
    notnContactId,
    notsPriority,
    notnFormID,
    notnRecUserID,
    notdDtCreated,
    notnModifyUserID,
    notdDtModified
) 
SELECT 
    0			    as notnCaseID,
    (select nttnNoteTypeID FROM sma_MST_NoteTypes where nttsCode='CONTACT') as notnNoteTypeID,
    PN.note		    as notmDescription,
    PN.note		    as notmPlainText,
    IOC.CTG		    as notnContactCtgID,
    IOC.CID		    as notnContactId,
    'Normal'		as notsPriority,
    0			    as notnFormID,
    368			    as notnRecUserID,
    getdate()		as notdDtCreated,
    NULL			as notnModifyUserID,
    NULL			as notdDtModified
FROM [NeosBillEasterly].[dbo].[provider_notes] PN
JOIN IndvOrgContacts_Indexed IOC on IOC.saga_ref = convert(varchar(50),PN.providerid)

---
ALTER TABLE [sma_TRN_Notes] ENABLE TRIGGER ALL
GO
---

--- select * from [sma_TRN_Notes]

