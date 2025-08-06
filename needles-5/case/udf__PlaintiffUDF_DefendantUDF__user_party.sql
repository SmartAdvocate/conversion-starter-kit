/* ########################################################
This script populates UDF Other1 with all columns from user_tab_data
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
		role.[SA Party]								 as [udfsScreenName],
		nuf.UDFType									 as [udfsType],
		ucf.field_len								 as [udfsLength],
		1											 as [udfbIsActive],
		'user_party_data.' + ucf.field_title		 as [udfshortName],
		nuf.DropDownValues							 as [udfsNewValues],
		DENSE_RANK() over (order by ucf.field_title) as udfnSortOrder
	from BenAbbot_Needles..user_party_data upd
	join BenAbbot_Needles..party_Indexed pi
		on pi.id = upd.partyid
	join BenAbbot_Needles..party_role_list prl
		on prl.id = pi.partyrolelistid
	join [PartyRoles] role
		on role.[Needles Roles] = prl.role
	join BenAbbot_Needles..user_case_fields ucf
		on upd.usercasefieldid = ucf.id
	join NeedlesUserFields nuf
		on nuf.field_id = ucf.id
	join sma_trn_Cases cas
		on cas.source_id = CONVERT(VARCHAR(50), pi.casesid)
	left join sma_MST_UDFDefinition def
		on def.udfnRelatedPK = cas.casnOrgCaseTypeID
			and def.udfsUDFName = ucf.field_title
			and def.udfsScreenName = role.[SA Party]
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
		def.udfnUDFID								   as [udvnUDFID],
		role.[SA Party]								   as [udvsScreenName],
		'C'											   as [udvsUDFCtg],
		cas.casnCaseID								   as [udvnRelatedID],
		ISNULL(Pl.plnnPlaintiffID, df.defnDefendentID) as [udvnSubRelatedID],
		ISNULL(ioc.name, upd.data)					   as [udvsUDFValue],
		368											   as [udvnRecUserID],
		GETDATE()									   as [udvdDtCreated],
		null										   as [udvnModifyUserID],
		null										   as [udvdDtModified],
		null										   as [udvnLevelNo]
	from BenAbbot_Needles..user_party_data upd
	join BenAbbot_Needles..party_Indexed pi
		on pi.id = upd.partyid
	join BenAbbot_Needles..party_role_list prl
		on prl.id = pi.partyrolelistid
	join [PartyRoles] role
		on role.[Needles Roles] = prl.role
	join BenAbbot_Needles..user_case_fields ucf
		on upd.usercasefieldid = ucf.id
	join NeedlesUserFields nuf
		on nuf.field_id = ucf.id
	join sma_trn_Cases cas
		on cas.source_id = CONVERT(VARCHAR(50), pi.casesid)
	left join sma_MST_UDFDefinition def
		on def.udfnRelatedPK = cas.casnOrgCaseTypeID
			and def.udfsUDFName = ucf.field_title
			and def.udfsScreenName = role.[SA Party]
			and def.udfsType = nuf.UDFType
	left join IndvOrgContacts_Indexed ioc
		on ioc.source_id = CONVERT(VARCHAR(50), upd.partyid)
	left join sma_trn_Plaintiff Pl
		on pl.saga_party = pi.id
	left join sma_trn_Defendants DF
		on DF.saga_party = pi.id
go

alter table sma_trn_udfvalues enable trigger all
go

