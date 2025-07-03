--IF OBJECT_ID('plaintiff_user_party_data', 'U') IS NOT NULL
--	DROP TABLE plaintiff_user_party_data;

IF OBJECT_ID('plaintiffUDF2', 'U') IS NOT NULL
    DROP TABLE plaintiffUDF2;

DECLARE @cols NVARCHAR(MAX);
DECLARE @sql NVARCHAR(MAX);
DECLARE @unpivot_sql NVARCHAR(MAX);
DECLARE @select_expr NVARCHAR(MAX);

-- Get distinct column names from NeedlesUserFields filtered by party role,
-- but only keep those columns that exist in user_party_data table.
SELECT @cols = STRING_AGG(QUOTENAME(column_name), ', ')
FROM (
    SELECT DISTINCT F.column_name
    FROM NeedlesUserFields F
    JOIN kurtyoung_needles..user_party_matter M ON F.field_num = M.ref_num
    JOIN PartyRoles R ON R.[Needles Roles] = M.party_role
    WHERE R.[SA Party] = 'Plaintiff'
) AS FilteredCols
WHERE FilteredCols.column_name IN (
    SELECT COLUMN_NAME
    FROM KurtYoung_Needles.INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = 'dbo'
      AND TABLE_NAME = 'user_party_data'
);

-- Check the output before executing
-- PRINT @cols;

-- Compose dynamic SQL
--SET @sql = '
--SELECT party_id, case_id, ' + @cols + '
--INTO plaintiff_user_party_data
--FROM KurtYoung_Needles.dbo.user_party_data ud
--JOIN sma_TRN_Cases cas ON cas.cassCaseNumber = CONVERT(VARCHAR, ud.case_id);
--';

-- Print the SQL to debug if needed
--PRINT @sql;

-- Execute
--EXEC sp_executesql @sql;

---- Now query the result
---- includes field values for plaintiff roles
--SELECT * FROM plaintiff_user_party_data


-- Use @cols to generate expressions like: CONVERT(VARCHAR(MAX), [ColumnName]) AS [ColumnName]
SELECT @select_expr = STRING_AGG(
    CAST('CONVERT(VARCHAR(MAX), ' + LTRIM(value) + ') AS ' + LTRIM(value) AS NVARCHAR(MAX)),
    ', '
)
FROM STRING_SPLIT(@cols, ',');

-- Use same list for UNPIVOT
SET @unpivot_sql = @cols;

-- Final dynamic SQL
SET @sql = '
SELECT casnCaseID, casnOrgCaseTypeID, FieldTitle, FieldVal
INTO plaintiffUDF2
FROM ( 
    SELECT 
        cas.casnCaseID, 
        cas.casnOrgCaseTypeID, ' + @select_expr + '
    FROM plaintiff_user_party_data ud
    JOIN sma_TRN_Cases cas ON cas.cassCaseNumber = CONVERT(VARCHAR, ud.case_id)
) pv
UNPIVOT (FieldVal FOR FieldTitle IN (' + @unpivot_sql + ')) AS unpvt;
';

--PRINT @sql; -- optional debug
EXEC sp_executesql @sql;

-- Optional: View results
SELECT * FROM plaintiffUDF2;

--IF EXISTS (
--		SELECT
--			*
--		FROM sys.tables
--		WHERE name = 'plaintiffUDF2'
--			AND type = 'U'
--	)
--BEGIN
--	DROP TABLE plaintiffUDF2
--END


---- Dynamically get all columns from KurtYoung_Needles..user_tab_data for unpivoting
--DECLARE @sql2 NVARCHAR(MAX) = N'';
--SELECT
--	@sql2 = STRING_AGG(CONVERT(VARCHAR(MAX),
--	N'CONVERT(VARCHAR(MAX), ' + QUOTENAME(column_name) + N') AS ' + QUOTENAME(column_name)
--	), ', ')
--FROM KurtYoung_Needles.INFORMATION_SCHEMA.COLUMNS
--WHERE table_name = 'user_party_data'
--	--AND column_name NOT IN (
--	--	SELECT
--	--		column_name
--	--	FROM #ExcludedColumns
--	--);


---- Dynamically create the UNPIVOT list
--DECLARE @unpivot_list NVARCHAR(MAX) = N'';
--SELECT
--	@unpivot_list = STRING_AGG(QUOTENAME(column_name), ', ')
--FROM KurtYoung_Needles.INFORMATION_SCHEMA.COLUMNS
--WHERE table_name = 'user_party_data'
--	--AND column_name NOT IN (
--	--	SELECT
--	--		column_name
--	--	FROM #ExcludedColumns
--	--);


---- Generate the dynamic SQL for creating the pivot table
--SET @sql2 = N'
--SELECT casnCaseID, casnOrgCaseTypeID, FieldTitle, FieldVal
--INTO plaintiffUDF2
--FROM ( 
--    SELECT 
--        cas.casnCaseID, 
--        cas.casnOrgCaseTypeID, ' + @sql2 + N'
--    FROM plaintiff_user_party_data ud
--    JOIN sma_TRN_Cases cas ON cas.cassCaseNumber = CONVERT(VARCHAR, ud.case_id)
--) pv
--UNPIVOT (FieldVal FOR FieldTitle IN (' + @unpivot_list + N')) AS unpvt;';

--EXEC sp_executesql @sql2;
--GO

--select * from plaintiffUDF2