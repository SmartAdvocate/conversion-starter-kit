select
	cfu.[tablename],
	[caseid] as case_link,
	cfu.[column_name],
	[field_title],
	[field_type],
	[mini_dir_title],
	[field_len],
	[ValueCount] as count,
	CFSD.field_value as [Sample Data]
from [Needles]..CustomFieldUsage CFU
left join [Needles]..CustomFieldSampleData CFSD
	on CFU.column_name = CFSD.column_name
		and CFU.tablename = CFSD.tablename
where
	CFU.tablename = 'user_tab10_data'
		and ValueCount > 0
order by CFU.tablename, CFU.field_num