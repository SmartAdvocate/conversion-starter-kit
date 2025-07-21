 use [NeosBillEasterly]
 go

IF EXISTS (SELECT * FROM sys.objects where name='counsel_Indexed' and type='U')
BEGIN
	DROP TABLE [counsel_Indexed]
END
GO

CREATE TABLE [counsel_Indexed](
		 
		id	uniqueidentifier,
		entry_id	int,
		counselnamesid	uniqueidentifier,
		casesid	uniqueidentifier,
		representingnamesid	uniqueidentifier,
		comments	varchar(500),
		cert_of_srv_order	int,
		case_status	bit,
		TableIndex [int] IDENTITY(1,1) NOT NULL,
		CONSTRAINT IOC_Clustered_Index_counsel PRIMARY KEY CLUSTERED ( TableIndex )
)ON [PRIMARY]
GO

CREATE NONCLUSTERED INDEX IX_NonClustered_Index_counsel_Indexed ON [counsel_Indexed] (id);   
GO  

INSERT INTO [counsel_Indexed] (
		id,
		entry_id,
		counselnamesid,
		casesid,
		representingnamesid,
		comments,
		cert_of_srv_order,
		case_status 
		 
)
SELECT 
		id,
		entry_id,
		counselnamesid,
		casesid,
		representingnamesid,
		comments,
		cert_of_srv_order,
		case_status 
		 
FROM [Counsel]
GO

DBCC DBREINDEX('counsel_Indexed',' ',90) 
GO

----- select   *  from [counsel_Indexed]
