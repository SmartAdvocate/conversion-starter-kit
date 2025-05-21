use KurtYoung_SA
go

/*
Pivot Table
*/
if exists (
		select
			*
		from sys.tables
		where name = 'IncidentUDF'
			and type = 'U'
	)
begin
	drop table IncidentUDF
end

select
	casnCaseID,
	casnOrgCaseTypeID,
	fieldTitle,
	FieldVal
into IncidentUDF
from (
	select
		cas.casnCaseID,
		cas.casnOrgCaseTypeID,
		CONVERT(VARCHAR(MAX), ud.Location) as [Location],
		CONVERT(VARCHAR(MAX), ud.City)	   as [City]
	from KurtYoung_Needles..user_case_data ud
	join sma_TRN_Cases cas
		on cas.casnCaseID = CONVERT(VARCHAR, ud.casenum)
) pv
unpivot (FieldVal for FieldTitle in (
[Location], [City]
)) as unpvt;

---- Add Location to IncidentUDF from user_case_data
--insert into IncidentUDF
--	select
--		casnCaseID,
--		casnOrgCaseTypeID,
--		fieldTitle,
--		FieldVal
--	from (
--		select
--			cas.casnCaseID,
--			cas.casnOrgCaseTypeID,
--			CONVERT(VARCHAR(MAX), [Location])			  as [Location],
--			CONVERT(VARCHAR(MAX), [Caller_Phone_#_not_P]) as [Caller Phone # (not P)]
--		from KurtYoung_Needles..user_case_data ud
--		join KurtYoung_Needles..cases_Indexed c
--			on c.casenum = CONVERT(VARCHAR, ud.casenum)
--		join sma_TRN_Cases cas
--			on cas.cassCaseNumber = CONVERT(VARCHAR, ud.casenum)
--	) pv
--	unpivot (FieldVal for FieldTitle in (
--	[Location], [Caller Phone # (not P)]
--	)) as unpvt;

----------------------------
--UDF DEFINITION
----------------------------
--insert into [sma_MST_UDFDefinition]
--	(
--		[udfsUDFCtg],
--		[udfnRelatedPK],
--		[udfsUDFName],
--		[udfsScreenName],
--		[udfsType],
--		[udfsLength],
--		[udfbIsActive],
--		[UdfShortName],
--		[udfsNewValues],
--		[udfnSortOrder]
--	)
--	select distinct
--		'I'										   as [udfsUDFCtg],
--		cg.IncidentTypeID						   as [udfnRelatedPK],
--		M.field_title							   as [udfsUDFName],
--		'Incident Wizard'						   as [udfsScreenName],
--		ucf.UDFType								   as [udfsType],
--		ucf.field_len							   as [udfsLength],
--		1										   as [udfbIsActive],
--		'user_Case_Data' + ucf.column_name		   as [udfshortName],
--		ucf.DropDownValues						   as [udfsNewValues],
--		DENSE_RANK() over (order by M.field_title) as udfnSortOrder
--	from [sma_MST_CaseType] CST
--	join CaseTypeMixture mix
--		on mix.[SmartAdvocate Case Type] = cst.cstsType
--	join KurtYoung_Needles.[dbo].[user_case_matter] M
--		on M.mattercode = mix.matcode
--			and M.field_type <> 'label'
--	join (
--		select distinct
--			fieldTitle
--		from IncidentUDF
--	) vd
--		on vd.FieldTitle = m.field_title
--	join NeedlesUserFields ucf
--		on ucf.field_num = m.ref_num
--	join sma_MST_CaseGroup cg
--		on cgpnCaseGroupID = cst.cstnGroupID
--	left join [sma_MST_UDFDefinition] def
--		-- on def.[udfnRelatedPK] = cst.cstnCaseTypeID
--		on def.[udfnRelatedPK] = cg.IncidentTypeID		-- for Incidents, the [sma_mst_UDFDefinition].[udfnRelatedPK] references the [sma_mst_casegroup].[IncidentTypeID]
--			and def.[udfsUDFName] = m.field_title
--			and def.[udfsScreenName] = 'Incident Wizard'
--			and udfsType = ucf.UDFType
--	where
--		def.udfnUDFID is null
--	order by m.field_title



--select
--	*
--from sma_MST_UDFDefinition smu
--where
--	smu.udfsScreenName = 'Incident Wizard'
----------------------------
-- Values
----------------------------
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
		def.udfnUDFID	  as [udvnUDFID],
		'Incident Wizard' as [udvsScreenName],
		'I'				  as [udvsUDFCtg],
		casnCaseID		  as [udvnRelatedID],
		0				  as [udvnSubRelatedID],
		udf.FieldVal	  as [udvsUDFValue],
		368				  as [udvnRecUserID],
		GETDATE()		  as [udvdDtCreated],
		null			  as [udvnModifyUserID],
		null			  as [udvdDtModified],
		null			  as [udvnLevelNo]
	from IncidentUDF udf
	-- Link to CaseType to get CaseGroupID
	join sma_MST_CaseType ct
		on ct.cstnCaseTypeID = udf.casnOrgCaseTypeID
	-- Link to CaseGroup to get IncidentTypeID
	join sma_MST_CaseGroup cg
		on cg.cgpnCaseGroupID = ct.cstnGroupID
	left join sma_MST_UDFDefinition def
		on def.udfnRelatedPK = cg.IncidentTypeID
			and def.udfsUDFName = FieldTitle
			and def.udfsScreenName = 'Incident Wizard'

alter table sma_trn_udfvalues enable trigger all
go
