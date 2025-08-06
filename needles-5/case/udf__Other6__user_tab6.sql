/* ########################################################
This script populates UDF Other6 with all columns from user_tab_data
*/

use BenAbbot_SA
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
		[udfshortName],
		[udfsNewValues],
		[udfnSortOrder]
	) select distinct
		'C'											 as [udfsUDFCtg],
		cas.casnOrgCaseTypeID						 as [udfnRelatedPK],
		ucf.field_title								 as [udfsUDFName],
		'Other6'									 as [udfsScreenName],
		nuf.UDFType									 as [udfsType],
		ucf.field_len								 as [udfsLength],
		1											 as [udfbIsActive],
		'user_tab6_data.' + ucf.field_title			 as [udfshortName],
		nuf.DropDownValues							 as [udfsNewValues],
		DENSE_RANK() over (order by ucf.field_title) as udfnSortOrder
	from BenAbbot_Needles..user_tab6_data utd
	join BenAbbot_Needles..user_tab6_list utl
		on utd.tablistid = utl.id
	join BenAbbot_Needles..user_case_fields ucf
		on utd.usercasefieldid = ucf.id
	join NeedlesUserFields nuf
		on nuf.field_title = ucf.field_title
	join sma_trn_Cases cas
		on cas.source_id = CONVERT(VARCHAR(50), utl.casesid)
	left join sma_MST_UDFDefinition def
		on def.udfnRelatedPK = cas.casnOrgCaseTypeID
			and def.udfsUDFName = ucf.field_title
			and def.udfsScreenName = 'Other6'
			and def.udfsType = nuf.UDFType
	where
		def.udfnUDFID is null



alter table sma_trn_udfvalues disable trigger all
go

insert into sma_TRN_UDFValues
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
	) select
		def.udfnUDFID			   as [udvnUDFID],
		'Other6'				   as [udvsScreenName],
		'C'						   as [udvsUDFCtg],
		cas.casnCaseID			   as [udvnRelatedID],
		0						   as [udvnSubRelatedID],
		ISNULL(ioc.name, utd.data) as [udvsUDFValue],
		368						   as [udvnRecUserID],
		GETDATE()				   as [udvdDtCreated],
		null					   as [udvnModifyUserID],
		null					   as [udvdDtModified],
		null					   as [udvnLevelNo]
	from BenAbbot_Needles..user_tab6_data utd
	join BenAbbot_Needles..user_tab6_list utl
		on utd.tablistid = utl.id
	join BenAbbot_Needles..user_case_fields ucf
		on utd.usercasefieldid = ucf.id
	join sma_trn_Cases cas
		on cas.source_id = CONVERT(VARCHAR(50), utl.casesid)
	join NeedlesUserFields nuf
		on nuf.field_title = ucf.field_title
	join sma_MST_UDFDefinition def
		on def.udfnRelatedPK = cas.casnOrgCaseTypeID
			and def.udfsUDFName = ucf.field_title
			and def.udfsScreenName = 'Other6'
			and def.udfstype = nuf.UDFType
	left join IndvOrgContacts_Indexed ioc
		on ioc.source_id = CONVERT(VARCHAR(50), utd.namesid)
go

alter table sma_trn_udfvalues enable trigger all
go

