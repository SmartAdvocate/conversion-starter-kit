USE [SA]
GO

/*
alter table [sma_MST_UDFDefinition] disable trigger all
delete [sma_MST_UDFDefinition]
DBCC CHECKIDENT ('[sma_MST_UDFDefinition]', RESEED, 0);
alter table [sma_MST_UDFDefinition] enable trigger all

alter table [sma_TRN_UDFValues] disable trigger all
delete [sma_TRN_UDFValues]
DBCC CHECKIDENT ('[sma_TRN_UDFValues]', RESEED, 0);
alter table [sma_TRN_UDFValues] enable trigger all
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
    'Other1'			as [udfsScreenName],
    nuf.UDFType				as [udfsType],
    nuf.field_len			as [udfsLength],
    1						as [udfbIsActive],
	 'user_Tab8_Data'+ucf.field_title	as [udfshortName],
    nuf.dropdownValues		as [udfsNewValues],
    DENSE_RANK() over( order by cas.casnOrgCaseTypeID) as udfnSortOrder
FROM [NeedlesNeosBisnarChase]..user_tab8_data td
JOIN [NeedlesNeosBisnarChase]..user_case_fields ucf on ucf.id = td.usercasefieldid
JOIN NeedlesUserFields nuf on nuf.field_title = ucf.field_title 
JOIN sma_trn_Cases cas on cas.Needles_saga = convert(varchar(50), td.casesid)
--LEFT JOIN (select distinct table_Name, column_name From [NeedlesNeosBisnarChase]..[document_merge_params] where table_Name = 'user_Tab8_Data') dmp
												--on dmp.column_name = ucf.field_Title
LEFT JOIN [sma_MST_UDFDefinition] def on def.[udfnRelatedPK] = cas.casnOrgCaseTypeID and def.[udfsUDFName] = ucf.field_title and def.[udfsScreenName] = 'Other1' and udfstype = nuf.UDFType
WHERE def.udfnUDFID IS NULL
and ucf.field_Title in ('Fact Sheet Status', 'FS Completed', 'FS Due to Court', 'FS Printed', 'FS Produced', 
					'FS Received from Client', 'FS Sent to Client', 'Notes')
ORDER BY ucf.field_title


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
	'Other1'		as [udvsScreenName],
	'C'					as [udvsUDFCtg],
	casnCaseID			as [udvnRelatedID],
	0					as [udvnSubRelatedID],
	case when isnull(convert(varchar(50),td.namesid),'') = '' then td.[data] else ioc.[name] end		as [udvsUDFValue],  
	368					as [udvnRecUserID],
	getdate()			as [udvdDtCreated],
	null				as [udvnModifyUserID],
	null				as [udvdDtModified],
	null				as [udvnLevelNo]
--select *
FROM [NeedlesNeosBisnarChase]..user_tab8_data td
JOIN [NeedlesNeosBisnarChase]..user_case_fields ucf on ucf.id = td.usercasefieldid
JOIN NeedlesUserFields nuf on nuf.field_title = ucf.field_title 
LEFT JOIN IndvOrgContacts_Indexed ioc on ioc.saga = convert(varchar(50),td.namesid)
JOIN sma_trn_Cases cas on cas.Needles_saga = convert(varchar(50), td.casesid)
JOIN [sma_MST_UDFDefinition] def on def.[udfnRelatedPK] = cas.casnOrgCaseTypeID and def.[udfsUDFName] = ucf.field_title and def.[udfsScreenName] = 'Other1' and udfstype = nuf.UDFType
WHERE ucf.field_Title in ('Fact Sheet Status', 'FS Completed', 'FS Due to Court', 'FS Printed', 'FS Produced', 
					'FS Received from Client', 'FS Sent to Client', 'Notes')
GO

ALTER TABLE sma_trn_udfvalues ENABLE TRIGGER ALL
GO
