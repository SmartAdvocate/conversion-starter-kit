use  [NeosBillEasterly]
go

IF EXISTS (SELECT * FROM sys.objects WHERE name='party_Indexed' and type='U')
BEGIN
	DROP TABLE [Party_Indexed]
END
GO


CREATE TABLE [Party_Indexed] (
	id	uniqueidentifier,
	record_num	int	,
	namesid	uniqueidentifier,
	casesid	uniqueidentifier,
	partyrolelistid	uniqueidentifier,    -------5
	our_client	bit,
	minor	bit,
	incapacitated	bit,
	incapacity	varchar(30),
	responsibility	bit,         ------10
	relationship	varchar(100),
	date_of_majority	date,
    [pclaw_matter]  varchar(32) not null,
	 [case_status]  bit not null,
	TableIndex int IDENTITY(1,1) NOT NULL,     ----15
	CONSTRAINT IOC_Clustered_Index PRIMARY KEY CLUSTERED (TableIndex)
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX IX_NonClustered_Index_Party_ID ON [party_Indexed] (id);
GO

INSERT INTO [Party_Indexed]
(	id,
	record_num,
	namesid,
	casesid,
	partyrolelistid,
	our_client,
	minor,
	incapacitated,
	incapacity,
	responsibility,
	relationship,
	date_of_majority,
    [pclaw_matter],
	[case_status]
)
SELECT 
	id,
	record_num,
	namesid,
	casesid,
	partyrolelistid,
	our_client,
	minor,
	incapacitated,
	incapacity,
	responsibility,
	relationship,
	date_of_majority,
	 [pclaw_matter],
	[case_status]
FROM Party
GO

DBCC DBREINDEX('Party_Indexed',' ', 90)
GO


----- select * from [Party_Indexed]