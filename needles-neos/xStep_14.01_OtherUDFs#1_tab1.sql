/* ########################################################
This script populates UDF Other  with all columns from user_tab1_data
*/

USE  [SAbilleasterlyLaw]
GO
 
 /*alter table [sma_MST_UDFDefinition] disable trigger all
delete [sma_MST_UDFDefinition]
DBCC CHECKIDENT ('[sma_MST_UDFDefinition]', RESEED, 0);
alter table [sma_MST_UDFDefinition] enable trigger all

alter table [sma_TRN_UDFValues] disable trigger all
delete [sma_TRN_UDFValues]
DBCC CHECKIDENT ('[sma_TRN_UDFValues]', RESEED, 0);
alter table [sma_TRN_UDFValues] enable trigger all   */

-----select * from [sma_MST_CaseType]
------- select * from sma_MST_UDFDefinition
----------------------------
--UDF DEFINITION
----------------------------
ALTER TABLE [sma_MST_UDFDefinition] DISABLE TRIGGER ALL
GO
 
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
			'C'										   AS [udfsUDFCtg]
		   ,cas.casnOrgCaseTypeID						   AS [udfnRelatedPK]
		   ,ucf.field_title							   AS [udfsUDFName]
		   ,'Other1'								   AS [udfsScreenName]
		   ,nuf.UDFType								   AS [udfsType]
		   ,ucf.field_len							   AS [udfsLength]
		   ,1										   AS [udfbIsActive]
		   ,'user_tab1_data' + ucf.field_title		   AS [udfshortName]
		   ,nuf.dropdownValues						   AS [udfsNewValues]
		   ,DENSE_RANK() OVER (ORDER BY nuf.field_title) AS udfnSortOrder
----select *
FROM  [NeosBillEasterly]..user_tab1_data td
join  [NeosBillEasterly].[dbo].[user_tab1_list]  l on td.tablistid = l.id
JOIN  [NeosBillEasterly]..user_case_fields ucf on ucf.id = td.usercasefieldid
 JOIN  NeosUserFields nuf on nuf.field_title = ucf.field_title 
JOIN sma_trn_Cases cas on cas.Neos_Saga = convert(varchar(50), l.casesid)
--LEFT JOIN (select distinct table_Name, column_name From [NeosBillEasterly]..[document_merge_params] where table_Name = 'user_Tab6_Data') dmp
												--on dmp.column_name = ucf.field_Title
LEFT JOIN [sma_MST_UDFDefinition] def on def.[udfnRelatedPK] = cas.casnOrgCaseTypeID 
                                                                  and def.[udfsUDFName] = ucf.field_title
																  and def.[udfsScreenName] = 'Other1'  and udfstype = nuf.UDFType
WHERE ucf.field_title  in (
                                'Comments'
                                ,'Contact'
                                ,'Current Medication'
                                ,'Date First Prescribed'
                                , 'Dosage'
                                , 'Frequency'
                                ,'Medication'
                                ,'Our Office'
                                ,'Physician Prescribed'
                               ,'Reason for Medication'
                               ,'Relationship to Client'
                               ,'Side Effects'
                              , 'We Get Ct. Rptr'
                             )
ORDER BY udfnRelatedPK,    ucf.field_title
GO
 


ALTER TABLE [sma_MST_UDFDefinition] ENABLE TRIGGER ALL
GO


---------------------------------------------
 

----- select * from sma_trn_udfvalues


ALTER TABLE sma_trn_udfvalues DISABLE TRIGGER ALL
GO

-- Table will not exist if it's empty or only contains ExlucedColumns
 
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
		SELECT  distinct 
			def.udfnUDFID AS [udvnUDFID]
		   ,'Other1'	  AS [udvsScreenName]
		   ,'C'			  AS [udvsUDFCtg]
		   ,casnCaseID	  AS [udvnRelatedID]
		   ,0			  AS [udvnSubRelatedID]
		   , td.data  AS [udvsUDFValue]
		   ,368			  AS [udvnRecUserID]
		   ,GETDATE()	  AS [udvdDtCreated]
		   ,NULL		  AS [udvnModifyUserID]
		   ,NULL		  AS [udvdDtModified]
		   ,NULL		  AS [udvnLevelNo]
---- select td.*
FROM  [NeosBillEasterly]..user_tab1_data  td
join  [NeosBillEasterly].[dbo].[user_tab1_list]  l on td.tablistid = l.id
JOIN  [NeosBillEasterly]..user_case_fields ucf on ucf.id = convert(varchar(50),td.usercasefieldid)
JOIN sma_trn_Cases cas on cas.Neos_Saga = convert(varchar(50), l.casesid)
JOIN [sma_MST_UDFDefinition] def on def.[udfnRelatedPK] = cas.casnOrgCaseTypeID 
                                                         and def.[udfsUDFName] = ucf.field_title 
														 and def.[udfsScreenName] = 'Other1' --and udfstype = nuf.UDFType
WHERE ucf.field_title  in (
                                'Comments'
                                ,'Contact'
                                ,'Current Medication'
                                ,'Date First Prescribed'
                                , 'Dosage'
                                , 'Frequency'
                                ,'Medication'
                                ,'Our Office'
                                ,'Physician Prescribed'
                               ,'Reason for Medication'
                               ,'Relationship to Client'
                               ,'Side Effects'
                              , 'We Get Ct. Rptr'
                             )
order by cas.casnCaseID

GO
 
 ---select * from sma_trn_udfvalues
---------------
------01. preview what the updated values will look like before running the actual UPDATE:
--------------
SELECT   *
  /*  udvnPKID,
    udvsUDFValue AS OriginalValue,
    CONVERT(varchar(10), TRY_CAST(udvsUDFValue AS date), 101) AS ConvertedValue   */
FROM sma_TRN_UDFValues
WHERE 
    udvsScreenName = 'Other1'
    AND ISDATE(udvsUDFValue) = 1
    AND LEN(udvsUDFValue) = 10
    AND SUBSTRING(udvsUDFValue, 5, 1) = '-'
    AND SUBSTRING(udvsUDFValue, 8, 1) = '-'



--------------------
-------02. update the udvsUDFValue column to MM/DD/YYYY format only for values matching the YYYY-MM-DD pattern:
------------------
UPDATE sma_TRN_UDFValues
SET udvsUDFValue = CONVERT(varchar(10), TRY_CAST(udvsUDFValue AS date), 101)
---- select   *  from sma_TRN_UDFValues
WHERE 
    udvsScreenName = 'Other1'
    AND ISDATE(udvsUDFValue) = 1
    AND udvsUDFValue LIKE '[1-2][0-9][0-9][0-9]-%'


-----------------------------
-------03. check all rows where the date format is already in MM/DD/YYYY format,
------------------------------
SELECT 
     *
FROM sma_TRN_UDFValues
WHERE 
    udvsScreenName = 'Other1'
    AND udvsUDFValue LIKE '[0-1][0-9]/[0-3][0-9]/[1-2][0-9][0-9][0-9]'


ALTER TABLE sma_trn_udfvalues ENABLE TRIGGER ALL
GO




ALTER TABLE sma_trn_udfvalues ENABLE TRIGGER ALL
GO