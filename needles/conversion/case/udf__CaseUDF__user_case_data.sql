use KurtYoung_SA
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
join KurtYoung_Needles..user_case_fields ucf
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
    FROM KurtYoung_Needles..user_case_data ud
    JOIN sma_TRN_Cases cas ON cas.cassCaseNumber = CONVERT(VARCHAR, ud.casenum)
) pv
UNPIVOT (
    FieldVal FOR FieldTitle IN (
' + @unpivotList + '
    )
) AS unpvt;
';

-- Output or execute
--print @sql;
EXEC sp_executesql @sql;

--SELECT * FROM CaseUDF

--select
--	casnCaseID,
--	casnOrgCaseTypeID,
--	fieldTitle,
--	FieldVal
--into CaseUDF
--from (
--	select
--		cas.casnCaseID,
--		cas.casnOrgCaseTypeID,
--		CONVERT(VARCHAR(MAX), ud.Allowance)	  as [Allowance],
--		CONVERT(VARCHAR(MAX), ud.FWW)  as [FWW],
--		CONVERT(VARCHAR(MAX), ud.Treatment_History)					  as [Treatment History],
--		CONVERT(VARCHAR(MAX), ud.Employers_Premises)			  as [Employer's Premises?],
--		CONVERT(VARCHAR(MAX), ud.Incident_Reported)			  as [Incident Reported],
--		CONVERT(VARCHAR(MAX), ud.EMS)			  as [EMS?],
--		CONVERT(VARCHAR(MAX), ud.Witnesses)				  as [Ambulance?],
--		CONVERT(VARCHAR(MAX), ud.Incident_Rpt_Date)	  as [Days Before Treatment],
--		CONVERT(VARCHAR(MAX), ud.Temp_Employee)			  as [Treatment Gaps],
--		CONVERT(VARCHAR(MAX), ud.Place_of_Assignment)		  as [Treatment Duration],
--		CONVERT(VARCHAR(MAX), ud.If_yes_to_whom)		  as [Residual/Disability?],
--		CONVERT(VARCHAR(MAX), ud.VSSR)		  as [Type of Residual],
--		CONVERT(VARCHAR(MAX), ud.Third_Party)				  as [Job Status],
--		CONVERT(VARCHAR(MAX), ud.Attending_Physician)	  as [Property Damage Paid?],
--		CONVERT(VARCHAR(MAX), ud.PPThis_Claim)	  as [Property Damage - Plntf],
--		CONVERT(VARCHAR(MAX), ud.Referral_Fee)	  as [Property Damage - Def],
--		CONVERT(VARCHAR(MAX), ud.TT_Days)	  as [Traffic Court Outcome],
--		CONVERT(VARCHAR(MAX), ud.TT_Dollars)				  as [Passengers],
--		CONVERT(VARCHAR(MAX), ud.Fee_Arrangement)		  as [Total Meds to Date],
--		CONVERT(VARCHAR(MAX), ud.Initial_Appt)			  as [Where Treated],
--		CONVERT(VARCHAR(MAX), ud.Appt_Time)		  as [Last Treated On],
--		CONVERT(VARCHAR(MAX), ud.No_Show)	  as [Continuing Treatment?],
--		CONVERT(VARCHAR(MAX), ud.Appt_Date)		  as [Previous Attorney?],
--		CONVERT(VARCHAR(MAX), ud.Appt_Location)	  as [Previous Offer Amount],
--		CONVERT(VARCHAR(MAX), ud.Appt_Made)			  as [Time of Call],
--		CONVERT(VARCHAR(MAX), ud.Date_Application_Filed)		  as [Staff Taking Call],
--		CONVERT(VARCHAR(MAX), ud.SSISSDI)	  as [If Med Mal, Authority?],
--		CONVERT(VARCHAR(MAX), ud.Date_Last_Worked)	  as [Caller Phone # (not P)],
--		CONVERT(VARCHAR(MAX), ud.Doctor_Support_Claim)			  as [Previous Offer],
--		CONVERT(VARCHAR(MAX), ud.Date_Application_Denied)	  as [Emergency Room DOI?],
--		CONVERT(VARCHAR(MAX), ud.Status_Upon_Intake)		  as [Body Part Injured],
--		CONVERT(VARCHAR(MAX), ud.Treatment_Since_Injury)				  as [Injuy Type],
--		CONVERT(VARCHAR(MAX), ud.Occupation) as [Primary Medical Provider],
--		CONVERT(VARCHAR(MAX), ud.How_Many_Years_Worked)	  as [Premises Accident Type],
--		CONVERT(VARCHAR(MAX), ud.JURY)		  as [Defendant Ticketed?],
--		CONVERT(VARCHAR(MAX), ud.NON_JURY)			  as [Ticket Type]
--	from KurtYoung_Needles..user_case_data ud
--	join sma_TRN_Cases cas
--		on cas.cassCaseNumber = CONVERT(VARCHAR, ud.casenum)
--) pv
--unpivot (FieldVal for FieldTitle in (
--[Impact Speed - Client], [Impact Speed - Defendant], [Ticket], [Alcohol/Drugs?], [Vehicle Photos?], [Injury Photo?],
--[Ambulance?], [Days Before Treatment], [Treatment Gaps], [Treatment Duration], [Residual/Disability?], [Type of Residual],
--[Job Status], [Property Damage Paid?], [Property Damage - Plntf], [Property Damage - Def], [Traffic Court Outcome],
--[Passengers], [Total Meds to Date], [Where Treated], [Last Treated On], [Continuing Treatment?], [Previous Attorney?],
--[Previous Offer Amount], [Time of Call], [Staff Taking Call], [If Med Mal, Authority?], [Caller Phone # (not P)],
--[Previous Offer], [Emergency Room DOI?], [Body Part Injured], [Injuy Type], [Primary Medical Provider],
--[Premises Accident Type], [Defendant Ticketed?], [Ticket Type], [ER/Initial Doctors Bills], [Attorney Fee Received]
--)) as unpvt;


--/* ####################################
--1.1 - Insert into CaseUDF from user_party_data
--*/

-- INSERT INTO CaseUDF (casncaseid, casnorgcasetypeID, fieldTitle, FieldVal)
-- SELECT casncaseid, casnorgcasetypeID, fieldTitle, FieldVal
-- FROM ( 
--     SELECT cas.casnCaseID, cas.CasnOrgCaseTypeID, 
--         convert(varchar(max), [Employer_Type]) as [Employer Type], 
--         convert(varchar(max), [Rep]) as [Rep], 
--         convert(varchar(max), [Managed_Care]) as [Managed Care], 
--         convert(varchar(max), [Risk]) as [Risk], 
--         convert(varchar(max), [PP_Total]) as [PP Total], 
--         convert(varchar(max), [Marital_Status]) as [Marital Status], 
--         convert(varchar(max), [Dependents]) as [Dependents], 
--         convert(varchar(max), [Child_Support]) as [Child Support], 
--         convert(varchar(max), [Prior_Accidents]) as [Prior Accidents], 
--         convert(varchar(max), [Union]) as [Union], 
--         convert(varchar(max), [Receiving_Disability]) as [Receiving Disability], 
--         convert(varchar(max), [Type_of_Disability]) as [Type of Disability], 
--         convert(varchar(max), [Technical_Training]) as [Technical Training], 
--         convert(varchar(max), [Alt_Contact_Phone]) as [Alt Contact Phone], 
--         convert(varchar(max), [Handedness]) as [Handedness], 
--         convert(varchar(max), [File_ID]) as [File ID], 
--         convert(varchar(max), [CommentsConversion]) as [Comments-Conversion], 
--         convert(varchar(max), [File_Loc]) as [File Loc], 
--         convert(varchar(max), [How_Many]) as [How Many], 
--         convert(varchar(max), [Dependants]) as [Dependants], 
--         convert(varchar(max), [Age]) as [Age], 
--         convert(varchar(max), [Caller]) as [Caller], 
--         convert(varchar(max), [Spouses_SS#]) as [Spouse's SS#], 
--         convert(varchar(max), [Valid_DL]) as [Valid D.L.], 
--         convert(varchar(max), [Caller_Cell_Phone]) as [Caller Cell Phone], 
--         convert(varchar(max), [Caller_Home_Phone]) as [Caller Home Phone], 
--         convert(varchar(max), [Spouse_Deceased]) as [Spouse Deceased], 
--         convert(varchar(max), [Divorce_Decree_Provided]) as [Divorce Decree Provided], 
--         convert(varchar(max), [Are_You_a_US_Citizen]) as [Are You a US Citizen?], 
--         convert(varchar(max), [Specific_Bequest]) as [Specific Bequest], 
--         convert(varchar(max), [Employment]) as [Employment]
--     FROM NeedlesSLF..user_party_data ud
--     --JOIN NeedlesSLF..cases_Indexed c ON c.casenum = ud.case_id
--     JOIN sma_TRN_Cases cas ON cas.cassCaseNumber = CONVERT(VARCHAR, ud.case_id)
-- ) pv
-- UNPIVOT (FieldVal FOR FieldTitle IN (
-- 	[Employer Type], [Rep], [Managed Care], [Risk], [PP Total], [Marital Status], 
--     [Dependents], [Child Support], [Prior Accidents], [Union], [Receiving Disability], [Type of Disability], [Technical Training], 
--     [Alt Contact Phone], [Handedness], [File ID], [Comments-Conversion], [File Loc], [How Many], [Dependants], [Age], 
--     [Caller], [Spouse's SS#], [Valid D.L.], [Caller Cell Phone], [Caller Home Phone], [Spouse Deceased], [Divorce Decree Provided], 
--     [Are You a US Citizen?], [Specific Bequest], [Employment]
-- )) AS unpvt;



--/* ####################################
--1.2 - Insert into CaseUDF from user_tab_data
--*/

-- INSERT INTO CaseUDF (casncaseid, casnorgcasetypeID, fieldTitle, FieldVal)
-- SELECT casncaseid, casnorgcasetypeID, fieldTitle, FieldVal
-- FROM ( 
--     SELECT cas.casnCaseID, cas.CasnOrgCaseTypeID, 
--         convert(varchar(max), [Start_Date]) as [Start Date], 
--         convert(varchar(max), [End_Date]) as [End Date], 
--         convert(varchar(max), [Job_Title]) as [Job Title], 
--         convert(varchar(max), [Reason_for_leaving]) as [Reason for leaving], 
--         convert(varchar(max), [Rate_of_Pay]) as [Rate of Pay], 
--         convert(varchar(max), [FPT_Employment]) as [F/PT Employment?], 
--         convert(varchar(max), [Hours_Worked_per_week]) as [Hours Worked per week], 
--         convert(varchar(max), [Current_Medication]) as [Current Medication]
--     FROM NeedlesSLF..user_tab_data ud
--     --JOIN NeedlesSLF..cases_Indexed c ON c.casenum = ud.case_id
--     JOIN sma_TRN_Cases cas ON cas.cassCaseNumber = CONVERT(VARCHAR, ud.case_id)
-- ) pv
-- UNPIVOT (FieldVal FOR FieldTitle IN (
-- 	[Start Date], [End Date], [Job Title], [Reason for leaving], 
--     [Rate of Pay], [F/PT Employment?], [Hours Worked per week], [Current Medication]
-- )) AS unpvt;


/* ------------------------------------------------------------------------------
Create definitions
*/ ------------------------------------------------------------------------------

alter table [sma_MST_UDFDefinition] disable trigger all
go

insert into [sma_MST_UDFDefinition]
	(
		[udfsUDFCtg],
		[udfnRelatedPK],
		[udfsUDFName],
		[udfsScreenName],
		[udfsType],
		[udfsLength],
		[udfbIsActive],
		[UdfShortName],
		[udfsNewValues],
		[udfnSortOrder]
	)
	-- user_case_data
	select distinct
		'C'										   as [udfsUDFCtg],
		CST.cstnCaseTypeID						   as [udfnRelatedPK],
		M.field_title							   as [udfsUDFName],
		'Case'									   as [udfsScreenName],
		ucf.UDFType								   as [udfsType],
		ucf.field_len							   as [udfsLength],
		1										   as [udfbIsActive],
		'user_case_data' + ucf.column_name		   as [udfshortName],
		ucf.dropdownValues						   as [udfsNewValues],
		DENSE_RANK() over (order by M.field_title) as udfnSortOrder
	from [sma_MST_CaseType] CST
	join CaseTypeMixture mix
		on mix.[SmartAdvocate Case Type] = cst.cstsType
	join KurtYoung_Needles.[dbo].[user_case_matter] M
		on M.mattercode = mix.matcode
			and M.field_type <> 'label'
	join (
		select distinct
			fieldTitle
		from CaseUDF
	) vd
		on vd.FieldTitle = M.field_title
	join [NeedlesUserFields] ucf
		on ucf.field_num = M.ref_num
	--LEFT JOIN	(
	--				SELECT DISTINCT table_Name, column_name
	--				FROM [NeedlesSLF].[dbo].[document_merge_params]
	--				WHERE table_Name = 'user_case_data'
	--			) dmp
	--	ON dmp.column_name = ucf.field_Title
	left join [sma_MST_UDFDefinition] def
		on def.[udfnRelatedPK] = cst.cstnCaseTypeID
			and def.[udfsUDFName] = M.field_title
			and def.[udfsScreenName] = 'Case'
			and def.[udfsType] = ucf.UDFType
			and def.udfnUDFID is null

-- UNION

-- -- user_case_data
-- SELECT DISTINCT 
--     'C'													as [udfsUDFCtg]
-- 	,CST.cstnCaseTypeID									as [udfnRelatedPK]
-- 	,M.field_title										as [udfsUDFName]
-- 	,'Case'												as [udfsScreenName]
-- 	,ucf.UDFType										as [udfsType]
-- 	,ucf.field_len										as [udfsLength]
-- 	,1													as [udfbIsActive]
-- 	,'user_tab_data' + ucf.column_name					as [udfshortName]
-- 	,ucf.dropdownValues									as [udfsNewValues]
-- 	,DENSE_RANK() OVER (ORDER BY M.field_title)			as udfnSortOrder
-- FROM [sma_MST_CaseType] CST
-- 	JOIN CaseTypeMixture mix
-- 		ON mix.[SmartAdvocate Case Type] = cst.cstsType
-- 	JOIN [NeedlesSLF].[dbo].[user_tab_matter] M
-- 		ON M.mattercode = mix.matcode
-- 		AND M.field_type <> 'label'
-- 	JOIN	(
-- 				SELECT DISTINCT	fieldTitle
-- 				FROM CaseUDF
-- 			) vd
-- 		ON vd.FieldTitle = M.field_title
-- 	JOIN [SANeedlesSLF].[dbo].[NeedlesUserFields] ucf
-- 		ON ucf.field_num = M.ref_num
-- 	LEFT JOIN [sma_MST_UDFDefinition] def
-- 		ON def.[udfnRelatedPK] = cst.cstnCaseTypeID
-- 		AND def.[udfsUDFName] = M.field_title
-- 		AND def.[udfsScreenName] = 'Case'
-- 		AND def.[udfsType] = ucf.UDFType
-- 	AND def.udfnUDFID IS NULL

-- UNION

-- -- user_party_data
-- SELECT DISTINCT 
--     'C'													as [udfsUDFCtg]
-- 	,CST.cstnCaseTypeID									as [udfnRelatedPK]
-- 	,M.field_title										as [udfsUDFName]
-- 	,'Case'												as [udfsScreenName]
-- 	,ucf.UDFType										as [udfsType]
-- 	,ucf.field_len										as [udfsLength]
-- 	,1													as [udfbIsActive]
-- 	,'user_party_data' + ucf.column_name					as [udfshortName]
-- 	,ucf.dropdownValues									as [udfsNewValues]
-- 	,DENSE_RANK() OVER (ORDER BY M.field_title)			as udfnSortOrder
-- FROM [sma_MST_CaseType] CST
-- 	JOIN CaseTypeMixture mix
-- 		ON mix.[SmartAdvocate Case Type] = cst.cstsType
-- 	JOIN [NeedlesSLF].[dbo].[user_party_matter] M
-- 		ON M.mattercode = mix.matcode
-- 		AND M.field_type <> 'label'
-- 	JOIN	(
-- 				SELECT DISTINCT	fieldTitle
-- 				FROM CaseUDF
-- 			) vd
-- 		ON vd.FieldTitle = M.field_title
-- 	JOIN [SANeedlesSLF].[dbo].[NeedlesUserFields] ucf
-- 		ON ucf.field_num = M.ref_num
-- 	LEFT JOIN [sma_MST_UDFDefinition] def
-- 		ON def.[udfnRelatedPK] = cst.cstnCaseTypeID
-- 		AND def.[udfsUDFName] = M.field_title
-- 		AND def.[udfsScreenName] = 'Case'
-- 		AND def.[udfsType] = ucf.UDFType
-- 	AND def.udfnUDFID IS NULL

-- ORDER BY M.field_title


/* ------------------------------------------------------------------------------
Insert UDF values
*/ ------------------------------------------------------------------------------

alter table sma_trn_udfvalues disable trigger all
go

insert into [sma_TRN_UDFValues]
	(
		[udvnUDFID],
		[udvsScreenName],
		[udvsUDFCtg],
		[udvnRelatedID],
		[udvnSubRelatedID],
		[udvsUDFValue],
		[udvnRecUserID],
		[udvdDtCreated],
		[udvnModifyUserID],
		[udvdDtModified],
		[udvnLevelNo]
	)
	select
		def.udfnUDFID as [udvnUDFID],
		'Case'		  as [udvsScreenName],
		'C'			  as [udvsUDFCtg],
		casnCaseID	  as [udvnRelatedID],
		0			  as [udvnSubRelatedID],
		udf.FieldVal  as [udvsUDFValue],
		368			  as [udvnRecUserID],
		GETDATE()	  as [udvdDtCreated],
		null		  as [udvnModifyUserID],
		null		  as [udvdDtModified],
		null		  as [udvnLevelNo]
	from CaseUDF udf
	left join sma_MST_UDFDefinition def
		on def.udfnRelatedPK = udf.casnOrgCaseTypeID
			and def.udfsUDFName = FieldTitle
			and def.udfsScreenName = 'Case'

alter table sma_trn_udfvalues enable trigger all
go