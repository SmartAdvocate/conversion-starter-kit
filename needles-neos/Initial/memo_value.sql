use [NeedlesBillEasterly]
go

IF EXISTS (SELECT * FROM sys.objects WHERE name='value_Indexed' and type='U')
BEGIN
	DROP TABLE [value_Indexed]
END
GO


CREATE TABLE [value_Indexed](
    
	id	uniqueidentifier,
	entry_id	int,
	[start_date]	date,
	stop_date	date,
	total_value	decimal(9),     ----5
	reduction	decimal(9),
	due	decimal(9), 
	lien	bit,
	valuecodeid	uniqueidentifier,
	partyid	uniqueidentifier,     ----10
	casesid	uniqueidentifier,
	namesid	uniqueidentifier,
	memo	varchar(5000),
	settlement_memo	varchar(60),
	report_pending	bit,      ----15
	date_requested	date,
	submitted_for_payment	bit,
	submitted_date	date,
	valuereportcategoryid	uniqueidentifier,
	value_reference	varchar(50),     ---20
	value_reference2	varchar(50),
	num_periods	decimal(9),
	rate	decimal(9),
	amount_requested	decimal(9),
	[period]	int,         -----25
    [app_created] varchar(20) null,
	date_created	datetime2,
	staffcreatedid	uniqueidentifier,
	 [app_modified] varchar(20) null,
	date_modified	datetime2,       ---30
	staffmodifiedid	uniqueidentifier,
	case_status	bit,
	TableIndex [int] IDENTITY(1,1) NOT NULL,    ---33
	CONSTRAINT IOC_Clustered_Index_value_Indexed PRIMARY KEY CLUSTERED ( TableIndex )
) ON [PRIMARY]
GO

CREATE NONCLUSTERED INDEX IX_NonClustered_Index_value_Indexed ON [value_Indexed] (id);  
GO

INSERT INTO [Value_Indexed](
	id,
	entry_id,
	[start_date],
	stop_date,
	total_value,    ----5
	reduction,
	due,
	lien,
	valuecodeid,
	partyid,      -----10
	casesid,
	namesid,
	memo,
	settlement_memo,
	report_pending,     ----15
	date_requested,
	submitted_for_payment,
	submitted_date,
	valuereportcategoryid,
	value_reference,     ---20
	value_reference2,
	num_periods,
	rate,
	amount_requested,
	[period],        ----25
    [app_created],
	date_created,
	staffcreatedid,
    [app_modified],
	date_modified,      ---30
	staffmodifiedid,
	case_status 
  )
SELECT 
	id,
	entry_id,
	[start_date],
	stop_date,
	total_value,    ----5
	reduction,
	due,
	lien,
	valuecodeid,
	partyid,      ----10
	casesid,
	namesid,
	memo,
	settlement_memo,
	report_pending,     -----15
	date_requested,
	submitted_for_payment,
	submitted_date,
	valuereportcategoryid,
	value_reference,      ---20
	value_reference2,
	num_periods,
	rate,
	amount_requested,
	[period],        ----25
    [app_created],
	date_created,
	staffcreatedid,
    [app_modified],
	date_modified,     ---30
	staffmodifiedid,
	case_status 
	 
FROM [Value]


---- select * from [Value_Indexed]