/* ########################################################
This script populates UDF Other  with all columns from user_tab4_data
*/

USE  [SAbilleasterlyLaw]
GO
 
 

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
		   ,cas.casnOrgCaseTypeID					   AS [udfnRelatedPK]
		   ,ucf.field_title							   AS [udfsUDFName]
		   ,'Other4'								   AS [udfsScreenName]
		   ,nuf.UDFType								   AS [udfsType]
		   ,ucf.field_len							   AS [udfsLength]
		   ,1										   AS [udfbIsActive]
		   ,'user_tab4_data' + ucf.field_title		   AS [udfshortName]
		   ,nuf.dropdownValues						   AS [udfsNewValues]
		   ,DENSE_RANK() OVER (ORDER BY nuf.field_title) AS udfnSortOrder
----select *
FROM  [NeosBillEasterly]..user_tab4_data td
join  [NeosBillEasterly].[dbo].[user_tab4_list]  l on td.tablistid = l.id
JOIN  [NeosBillEasterly]..user_case_fields ucf on ucf.id = td.usercasefieldid
 JOIN  NeosUserFields nuf on nuf.field_title = ucf.field_title 
JOIN sma_trn_Cases cas on cas.Neos_Saga = convert(varchar(50), l.casesid)
 
LEFT JOIN [sma_MST_UDFDefinition] def on def.[udfnRelatedPK] = cas.casnOrgCaseTypeID 
                                                                  and def.[udfsUDFName] = ucf.field_title
																  and def.[udfsScreenName] = 'Other4'  and udfstype = nuf.UDFType
where ucf.field_title in (
                                           'Comments'
                                           ,'Contact'
                                           ,'Court Reporter'
                                           ,'Court Reporter Cost'
                                           ,'CV on File?'
                                           ,'Depo Date'
                                           , 'Depo Prep Date'
                                           ,'Depo Prep Time'
                                           ,'Depo Time'
                                           ,'Expert Cost'
                                           ,'Interpreter?'
                                           ,'Location'
                                           ,'Location of Depo'
                                           ,'Notes'
                                           ,'Reviewed'
                                           ,'Srvd on Def'
                                           ,'Srvd on Plt'
                                           ,'Type of Expert'
                                           ,'Type of Witness'
                                           ,'Witness Name'
                                      )
 ORDER BY ucf.field_title
GO	 

 update sma_MST_UDFDefinition
 set udfsType = 'Text'
 where udfnUDFID = 196

  update sma_MST_UDFDefinition
 set udfsType = 'Text'
 where udfnUDFID = 197

  update sma_MST_UDFDefinition
 set udfsType = 'Text'
 where udfnUDFID = 198

 update sma_MST_UDFDefinition
 set udfsType = 'Text'
 where udfnUDFID = 223

 update sma_MST_UDFDefinition
 set udfsType = 'Text'
 where udfnUDFID = 224

 update sma_MST_UDFDefinition
 set udfsType = 'Text'
 where udfnUDFID = 214



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
		SELECT distinct 
			def.udfnUDFID AS [udvnUDFID]
		   ,'Other4'	  AS [udvsScreenName]
		   ,'C'			  AS [udvsUDFCtg]
		   ,casnCaseID	  AS [udvnRelatedID]
	-----	   ,  cas.casnOrgCaseTypeID 
		   ,0			  AS [udvnSubRelatedID]
		   , td.data  AS [udvsUDFValue]
		   ,368			  AS [udvnRecUserID]
		   ,GETDATE()	  AS [udvdDtCreated]
		   ,NULL		  AS [udvnModifyUserID]
		   ,NULL		  AS [udvdDtModified]
		   ,NULL		  AS [udvnLevelNo]
---- select td.data
FROM  [NeosBillEasterly]..user_tab4_data  td
join  [NeosBillEasterly].[dbo].[user_tab4_list]  l on td.tablistid = l.id
JOIN  [NeosBillEasterly]..user_case_fields ucf on ucf.id = convert(varchar(50),td.usercasefieldid)
JOIN sma_trn_Cases cas on cas.Neos_Saga = convert(varchar(50), l.casesid)
JOIN [sma_MST_UDFDefinition] def on def.[udfnRelatedPK] = cas.casnOrgCaseTypeID 
                                                         and def.[udfsUDFName] = ucf.field_title 
														 and def.[udfsScreenName] = 'Other4' --and udfstype = nuf.UDFType
GO
 
 UPDATE sma_TRN_UDFValues
SET udvsUDFValue = CONVERT(varchar(10), TRY_CAST(udvsUDFValue AS date), 101)
---- select   *  from sma_TRN_UDFValues
WHERE 
    udvsScreenName = 'Other4'
    AND ISDATE(udvsUDFValue) = 1
    AND udvsUDFValue LIKE '[1-2][0-9][0-9][0-9]-%'



ALTER TABLE sma_trn_udfvalues ENABLE TRIGGER ALL
GO