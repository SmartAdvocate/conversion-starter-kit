 use [NeosBillEasterly]
 go

IF EXISTS (SELECT * FROM sys.objects WHERE name='case_notes_Indexed' and type='U')
BEGIN
	DROP TABLE [dbo].[case_notes_Indexed]
END
GO


CREATE TABLE [dbo].[case_notes_Indexed](
		id	uniqueidentifier,
		entry_id	int,
		note	varchar(max),
		note_date	datetime2,
		staffid	uniqueidentifier,
		casesid	uniqueidentifier,
		casenotetopicid	uniqueidentifier,
		plaintext	bit,
		date_created	datetime2,
		staffcreatedid	uniqueidentifier,
		date_modified	datetime2,
		staffmodifiedid	uniqueidentifier,
		last_modified   datetime2,
		case_status	bit,
		communicationid	uniqueidentifier,
		[TableIndex] [int] IDENTITY(1,1) NOT NULL,
 CONSTRAINT [IOC_Clustered_Index_case_notes_Indexed] PRIMARY KEY CLUSTERED 
(
	[TableIndex] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

CREATE NONCLUSTERED INDEX IX_NonClustered_Index_case_notes_Indexed ON [case_notes_Indexed] (casesid);  
GO

INSERT INTO [case_notes_Indexed] (
		id,
		entry_id,
		note,
		note_date,
		staffid,
		casesid,
		casenotetopicid,
		plaintext,
		date_created,
		staffcreatedid,
		date_modified,
		staffmodifiedid,
		last_modified,
		case_status,
		communicationid 
)
SELECT 
		id,
		entry_id,
		note,
		note_date,
		staffid,
		casesid,
		casenotetopicid,
		plaintext,
		date_created,
		staffcreatedid,
		date_modified,
		staffmodifiedid,
		last_modified,
		case_status,
		communicationid 
FROM [case_notes]
GO


DBCC DBREINDEX('case_notes_Indexed',' ',90) 
GO

------
select * from [case_notes_Indexed]