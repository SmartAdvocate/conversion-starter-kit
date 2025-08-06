use  [NeosBillEasterly]
go


IF EXISTS (SELECT * FROM sys.objects WHERE name='checklist_dir_indexed' and type='U')
BEGIN
	DROP TABLE [checklist_dir_indexed]
END
GO



CREATE TABLE [checklist_dir_indexed](
		 
		id	uniqueidentifier,
		code	varchar(10),
		[description]	varchar(200),
		phase	int,
		ref	 varchar(20),           --------5
		repeat_period	 int,
		auto_repeat	bit,
		repeat_days	int,
		lim	bit,
		matterid	uniqueidentifier,     --------10
		litigationtitleid	uniqueidentifier,
		staffroleid	uniqueidentifier,
		datelabelid	uniqueidentifier,
		wpdocumentsid	uniqueidentifier,
		pdfdocumentsid	uniqueidentifier,     ---------15
		parent	bit,
		referencechecklistid	uniqueidentifier,
		case_status	bit,
		text_color	char(9),
		background_color	char(9),         ----20
		active	bit,
		auxiliary bit,
		[TableIndex] [int] IDENTITY(1,1) NOT NULL,
		CONSTRAINT IOC_Clustered_Index_checklist_dir PRIMARY KEY CLUSTERED ( [TableIndex]  )
)ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX IX_NonClustered_Index_checklist_dir_indexed ON [checklist_dir_indexed] ([TableIndex]);   

CREATE NONCLUSTERED INDEX IX_NonClustered_Index_checklist_dir_indexed_Matcode ON [checklist_dir_indexed] (matterid);   
GO

INSERT INTO [checklist_dir_indexed] (
		id,
		code,
		[description],
		phase,
		ref,          -------5
		repeat_period,
		auto_repeat,
		repeat_days,
		lim,
		matterid,     ------10
		litigationtitleid,
		staffroleid,
		datelabelid,
		wpdocumentsid,
		pdfdocumentsid,     ------15
		parent,
		referencechecklistid,
		case_status,
		text_color,
		background_color,     ----20
		active,
		auxiliary
		 
)
SELECT 
		id,
		code,
		[description],
		phase,
		ref,        ---5
		repeat_period,
		auto_repeat,
		repeat_days,
		lim,
		matterid,     ----10
		litigationtitleid,
		staffroleid,
		datelabelid,
		wpdocumentsid,
		pdfdocumentsid,     ------15
		parent,
		referencechecklistid,
		case_status,
		text_color,
		background_color,    ---20
		active,
		auxiliary 
		 
FROM [checklist_dir]
GO


DBCC DBREINDEX('checklist_dir_indexed',' ',90)
GO

-----select * from [checklist_dir_indexed]