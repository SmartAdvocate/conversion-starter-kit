 use [SAbilleasterlyLaw]

/*
alter table [sma_MST_UDFDefinition] disable trigger all
delete [sma_MST_UDFDefinition]
DBCC CHECKIDENT ('[sma_MST_UDFDefinition]', RESEED, 721);
alter table [sma_MST_UDFDefinition] enable trigger all

alter table [sma_TRN_UDFValues] disable trigger all
delete [sma_TRN_UDFValues]
DBCC CHECKIDENT ('[sma_TRN_UDFValues]', RESEED, 206141);
alter table [sma_TRN_UDFValues] enable trigger all

SELECT td.casesid, case when convert(varchar(50),td.[namesid]) IS NULL then td.[data] else convert(varchar(50),td.[namesid]) end as [data], ucf.field_title
	FROM [NeosBrianWhite]..user_tab6_data td
	JOIN [NeosBrianWhite]..user_case_fields ucf on ucf.id = td.usercasefieldid
*/

----------------------------
--UDF DEFINITION
----------------------------
INSERT INTO [sma_MST_UDFDefinition]
(
    [udfsUDFCtg]
    ,[udfnRelatedPK]
    ,[udfsUDFName]
    ,[udfsScreenName]
    ,[udfsType]
    ,[udfsLength]
    ,[udfbIsActive]
	,[udfshortName]
	,[udfsNewValues]
    ,[udfnSortOrder]
)
SELECT DISTINCT 
    'C'						as [udfsUDFCtg],
    cas.casnOrgCaseTypeID	as [udfnRelatedPK],
    ucf.field_title			as [udfsUDFName],   
    'Case Wizard'			as [udfsScreenName],
	 
   nuf.UDFType				as [udfsType],
      ucf.field_len			as [udfsLength],
    1						as [udfbIsActive],
	 'user_Tab6_Data: '+ucf.field_title	as [udfshortName],
    nuf.dropdownValues		as [udfsNewValues],
    DENSE_RANK() over( order by cas.casnOrgCaseTypeID) as udfnSortOrder
--select td.*
FROM  [NeosBillEasterly]..user_tab6_data td
JOIN  [NeosBillEasterly]..user_case_fields ucf on ucf.id = td.usercasefieldid
 JOIN  NeosUserFields nuf on nuf.field_title = ucf.field_title 
JOIN sma_trn_Cases cas on cas.Neos_Saga = convert(varchar(50), td.casesid)
---- LEFT JOIN (select distinct table_Name, column_name From [NeosBillEasterly]..[document_merge_params] where table_Name = 'user_Tab6_Data') dmp
												--on dmp.column_name = ucf.field_Title
LEFT JOIN [sma_MST_UDFDefinition] def on def.[udfnRelatedPK] = cas.casnOrgCaseTypeID 
                                                                  and def.[udfsUDFName] = ucf.field_title 
																  and def.[udfsScreenName] = 'Case Wizard'  
																  and udfstype = nuf.UDFType
where ucf.field_title not in ('City', 'County', 'Location', 'State', 'Amount Settled For')
 ORDER BY ucf.field_title
GO

--------------------------------------
--UDF VALUES
--------------------------------------
ALTER TABLE sma_trn_udfvalues DISABLE TRIGGER ALL
GO
INSERT INTO [sma_TRN_UDFValues]
(
       [udvnUDFID]
      ,[udvsScreenName]
      ,[udvsUDFCtg]
      ,[udvnRelatedID]
      ,[udvnSubRelatedID]
      ,[udvsUDFValue]
      ,[udvnRecUserID]
      ,[udvdDtCreated]
      ,[udvnModifyUserID]
      ,[udvdDtModified]
      ,[udvnLevelNo]
)
select --fieldtitle, udf.casnOrgCaseTypeID,
	def.udfnUDFID		as [udvnUDFID],
	'Case Wizard'		as [udvsScreenName],
	'C'					as [udvsUDFCtg],
	casnCaseID			as [udvnRelatedID],
	0					as [udvnSubRelatedID],
	case when ucf.field_Type = '14' then (select top 1 convert(varchar,UNQCID) from indvorgcontacts_Indexed where saga_ref = convert(varchar(50),td.[namesid])) else td.[data] end			as [udvsUDFValue],  
	368					as [udvnRecUserID],
	getdate()			as [udvdDtCreated],
	null				as [udvnModifyUserID],
	null				as [udvdDtModified],
	null				as [udvnLevelNo]
--select *
FROM  [NeosBillEasterly]..user_tab6_data td
JOIN  [NeosBillEasterly]..user_case_fields ucf on ucf.id = convert(varchar(50),td.usercasefieldid)
JOIN sma_trn_Cases cas on cas.Neos_Saga = convert(varchar(50), td.casesid)
JOIN [sma_MST_UDFDefinition] def on def.[udfnRelatedPK] = cas.casnOrgCaseTypeID 
                                                         and def.[udfsUDFName] = ucf.field_title
														 and def.[udfsScreenName] = 'Case Wizard' --and udfstype = nuf.UDFType
where ucf.field_title not in ('City', 'County', 'Location', 'State', 'Amount Settled For')
GO

ALTER TABLE sma_trn_udfvalues ENABLE TRIGGER ALL
GO
