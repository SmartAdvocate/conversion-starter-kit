Use  [SAbilleasterlyLaw]
GO

/******************************************
 * FIELD TYPES
 *-------------------------
 * 1	Alpha
 * 5	true/false
 * 7	Date
 * 12	mini-dir picklist
 * 13	Money
 * 14	Name
 * 16	Number
 * 27	Staff/User
 * 29	State
 * 31	Time
 * 33	Value Code
 * 35	Y/N/?
 * 41 Alpha
 *****************************************/

IF EXISTS (Select * From sys.tables where name = 'NeosUserFields' and type = 'U')
BEGIN
		DROP TABLE NeosUserFields
END
-------------------------------------------
--CREATE TABLE NEOS USER FIELDS
-------------------------------------------
CREATE TABLE NeosUserFields ( 
		field_id varchar(50),
		field_title varchar(30),
		--column_name varchar(30),
		field_Type int, --varchar(20),
		field_len varchar(10),
		mini_Dir varchar(50),
		UDFType varchar(30),
		DropDownValues varchar(max))
-------------------------------------------------------------------
--BUILD USER FIELDS PLUS DROP DOWNS FOR UDF DEFINITION PURPOSES
-------------------------------------------------------------------
INSERT INTO NeosUserFields (field_id, field_title, field_Type, field_len, mini_Dir, UDFType)
SELECT ucf.id, field_title, field_type, 
case when field_Type in (13, 16) then convert(varchar,field_len) + ',2'
	else convert(varchar,field_len) end,
	minidirlistid,
case when field_Type in (1, 29,33,27,41) then 'Text'
	when field_Type = 14 then 'Contact'  --for new SA version
	when field_Type in (13,16) then 'Number'
	when field_Type = 5 then 'CheckBox'
	when field_Type IN (12, 35) then 'Dropdown'
	when field_Type = 7 then 'Date'
	when field_Type = 31 then 'Time'
	else NULL end
--Select *
FROM  [NeosBillEasterly]..[user_case_fields] ucf
 LEFT JOIN  [NeosBillEasterly]..[mini_dir_list] dl on ucf.minidirlistid = dl.id

-----------------------------------------------------
--CURSOR TO FILL IN DROP DOWN VALUES FOR MINI DIRS
-----------------------------------------------------
DECLARE @miniDir varchar(50),
		@numberCt int,
		@code varchar(30)

DECLARE userFields_cursor CURSOR FOR
SELECT Mini_Dir from NeosUserFields where isnull(Mini_Dir,'') <> ''

OPEN userFields_Cursor
FETCH NEXT FROM userFields_Cursor INTO @miniDir
WHILE @@FETCH_STATUS = 0
BEGIN

	SELECT identity(int,1,1) as Number, gd.code
	INTO #values
	--select *
	FROM  [NeosBillEasterly]..mini_general_dir gd
	JOIN  [NeosBillEasterly]..mini_dir_list dl on gd.minidirlistid = dl.id 
	WHERE gd.minidirlistid = @miniDir  

	SET @numberCt = (select max(number) from #values)

	WHILE @numberCt >= 1
	BEGIN
		
		SET @code = (select code from #values where Number = @numberCt)

		UPDATE NeosUserFields
		SET DropDownValues = case when dropDownValues is null then @code else DropDownValues + '~'+@code end
		WHERE Mini_Dir = @miniDir

		SET @numberCt = @numberCt - 1
		
	END
	
	DROP TABLE #values

FETCH NEXT FROM userFields_Cursor INTO @miniDir
END
CLOSE userFields_Cursor;
DEALLOCATE userFields_Cursor;

--------------------------------------------------------
--UPDATE DROPDOWN VALUES WHERE FIELD TYPE = 35 (Y/N/?)
--------------------------------------------------------
UPDATE NeosUserFields
SET DropDownValues = 'Y~N~?'
WHERE field_Type = 35

