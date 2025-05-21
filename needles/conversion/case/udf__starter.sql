use [SA]
go

if exists (
		select
			*
		from sys.tables
		where name = 'CaseUDF'
			and type = 'U'
	)
begin
	drop table CaseUDF
end

/* ------------------------------------------------------------------------------
create table to hold applicable fields
*/ ------------------------------------------------------------------------------
declare @fields table (
	column_name VARCHAR(100)
);

-- paste column_name values from mapping excel sheet
insert into @fields
	(
		column_name
	)
	values
	('Allowance'),
	('FWW'),
	('Treatment_History'),
	('Employers_Premises'),
	('Incident_Reported'),
	('EMS'),
	('Witnesses'),
	('Incident_Rpt_Date'),
	('Temp_Employee'),
	('Place_of_Assignment'),
	('If_yes_to_whom'),
	('VSSR'),
	('Third_Party'),
	('Attending_Physician'),
	('PPThis_Claim'),
	('Referral_Fee'),
	('TT_Days'),
	('TT_Dollars'),
	('Fee_Arrangement'),
	('Initial_Appt'),
	('Appt_Time'),
	('No_Show'),
	('Appt_Date'),
	('Appt_Location'),
	('Appt_Made'),
	('Date_Application_Filed'),
	('SSISSDI'),
	('Date_Last_Worked'),
	('Doctor_Support_Claim'),
	('Date_Application_Denied'),
	('Status_Upon_Intake'),
	('Treatment_Since_Injury'),
	('Occupation'),
	('How_Many_Years_Worked'),
	('JURY'),
	('NON_JURY');

/* ------------------------------------------------------------------------------
dynamic sql to create the pivot table
uses user_case_fields.field_title to populate aliases
*/ ------------------------------------------------------------------------------

declare @sql NVARCHAR(MAX) = '';
declare @selectList NVARCHAR(MAX) = '';	
declare @unpivotList NVARCHAR(MAX) = '';

-- Build SELECT list and UNPIVOT list
select
	@selectList	 += CONCAT('        CONVERT(VARCHAR(MAX), ud.', ucf.column_name, ') AS [', ucf.field_title, '],', CHAR(13)),
	@unpivotList += CONCAT('[', ucf.field_title, '],', CHAR(13))
from @fields f
join [Needles]..user_case_fields ucf
	on ucf.column_name = f.column_name
order by ucf.field_num;

-- Trim trailing commas
set @selectList = LEFT(@selectList, LEN(@selectList) - 2);
set @unpivotList = LEFT(@unpivotList, LEN(@unpivotList) - 2);

-- Final SQL block
set @sql = '
SELECT
    casnCaseID,
    casnOrgCaseTypeID,
    fieldTitle,
    FieldVal
INTO CaseUDF
FROM (
    SELECT
        cas.casnCaseID,
        cas.casnOrgCaseTypeID,
' + @selectList + '
    FROM [Needles]..user_case_data ud
    JOIN sma_TRN_Cases cas ON cas.cassCaseNumber = CONVERT(VARCHAR, ud.casenum)
) pv
UNPIVOT (
    FieldVal FOR FieldTitle IN (
' + @unpivotList + '
    )
) AS unpvt;
';

-- Output or execute
print @sql;
-- EXEC sp_executesql @sql;
