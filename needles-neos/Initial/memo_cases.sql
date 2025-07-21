 use [NeosBillEasterly]
go

IF EXISTS (SELECT * FROM sys.objects WHERE name='cases_Indexed' and type='U')
BEGIN
	DROP TABLE [dbo].[cases_Indexed]
END
GO

CREATE TABLE [cases_Indexed] (
		id	uniqueidentifier,
		casenum	int,
		alt_case_num	varchar(75),
		alt_case_num_2	varchar(75),
		date_of_incident	date,    -----5
		date_opened	date,
		close_date	date,
		dormant	bit,
		lim_date	date,
		lim_stat	char(1),         ----10
		intake_date	datetime2,
		staffintakeid	uniqueidentifier,
		synopsis	varchar(max),
		docket	varchar(35),
		case_title	varchar(1000),     -----15
		special_note	varchar(1000),
		import_date	datetime2,
		matterid	uniqueidentifier,
		classid	uniqueidentifier,
		referredby_namesid	uniqueidentifier,     -----20
		referredto_namesid	uniqueidentifier,
		reassign_date	date,
		court_namesid	uniqueidentifier,
		judge_namesid	uniqueidentifier,
		billto_namesid	uniqueidentifier,     ---25
		doc_default_path	varchar(255),
		open_status  bit,
		date_created	datetime2,
		staffcreatedid	uniqueidentifier,
		date_modified	datetime2,         ---30
		staffmodifiedid	uniqueidentifier,
		[last_modified] datetime2(7),
		requestcaseid	varchar(36),
		[TableIndex] [int] IDENTITY(1,1) NOT NULL,     ---34
		CONSTRAINT [IOC_Clustered_Index_cases_Indexed] PRIMARY KEY CLUSTERED 
(
	[TableIndex] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

CREATE NONCLUSTERED INDEX IX_NonClustered_Index_cases_Indexed ON [cases_Indexed] (id); 
GO


INSERT INTO [cases_Indexed] (		
		id,
		casenum,
		alt_case_num,
		alt_case_num_2,
		date_of_incident,   ------5
		date_opened,
		close_date,
		dormant,
		lim_date,
		lim_stat,          ---10
		intake_date,
		staffintakeid,
		synopsis,
		docket,
		case_title,     -----15
		special_note,
		import_date,
		matterid,
		classid,
		referredby_namesid,   -----20
		referredto_namesid,
		reassign_date,
		court_namesid,
		judge_namesid,
		billto_namesid,     ----25
		doc_default_path,
		open_status,
		date_created,
		staffcreatedid,
		date_modified,     ---30
		staffmodifiedid,
		
		requestcaseid 
		 
)
SELECT
		id,
		casenum,
		alt_case_num,
		alt_case_num_2,
		date_of_incident,    ----5
		date_opened,
		close_date,
		dormant,
		lim_date,
		lim_stat,     ---10
		intake_date,
		staffintakeid,
		synopsis,
		docket,
		case_title,     ----15
		special_note,
		import_date,
		matterid,
		classid,
		referredby_namesid,    ----20
		referredto_namesid,
		reassign_date,
		court_namesid,
		judge_namesid,
		billto_namesid,     ----25
		doc_default_path,
		open_status,
        date_created,
		staffcreatedid,
		date_modified,     ---30
		staffmodifiedid,
		
		requestcaseid 
		 
FROM [cases]
GO
  
DBCC DBREINDEX('cases_Indexed',' ',90) 
GO

