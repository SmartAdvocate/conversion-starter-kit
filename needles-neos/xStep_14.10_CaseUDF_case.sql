USE   [SAbilleasterlyLaw]
GO


 /*alter table [sma_MST_UDFDefinition] disable trigger all
delete [sma_MST_UDFDefinition]
DBCC CHECKIDENT ('[sma_MST_UDFDefinition]', RESEED, 0);
alter table [sma_MST_UDFDefinition] enable trigger all

alter table [sma_TRN_UDFValues] disable trigger all
delete [sma_TRN_UDFValues]
DBCC CHECKIDENT ('[sma_TRN_UDFValues]', RESEED, 0);
alter table [sma_TRN_UDFValues] enable trigger all   */


----------------------------
--CASE UDF DEFINITION
----------------------------
ALTER TABLE sma_MST_UDFDefinition DISABLE TRIGGER ALL
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
	,udfnDtCreated
)
SELECT DISTINCT 
    'C'						as [udfsUDFCtg],
    cas.casnOrgCaseTypeID	as [udfnRelatedPK],
    ucf.field_title			as [udfsUDFName],   
    'Case'					as [udfsScreenName],
    nuf.UDFType				as [udfsType],
    nuf.field_len			as [udfsLength],
    1						as [udfbIsActive],
	 'user_Case_Data'+ucf.field_title	as [udfshortName],
    nuf.dropdownValues		as [udfsNewValues],
    DENSE_RANK() over( order by cas.casnOrgCaseTypeID) as udfnSortOrder,
	getdate()
--select td.*
FROM  [NeosBillEasterly]..user_case_data td
JOIN  [NeosBillEasterly]..user_case_fields ucf on ucf.id = td.usercasefieldid
JOIN NeosUserFields nuf on nuf.field_title = ucf.field_title 
JOIN sma_trn_Cases cas on cas.Neos_Saga = convert(varchar(50), td.casesid)
LEFT JOIN [sma_MST_UDFDefinition] def on def.[udfnRelatedPK] = cas.casnOrgCaseTypeID
                                                                  and def.[udfsUDFName] = ucf.field_title 
																  and def.[udfsScreenName] = 'Case'
																  and udfstype = nuf.UDFType
WHERE ucf.field_title  in (
                                '2nd Class Code'
                                ,'As Of'
                                , 'Date Last Worked'
                                ,'Date of Last Appointment'
                                ,'Doctor Support Claim?'
                                ,'If Other, Please Explain'
                                ,'Last Doctor Seen'
                                ,'Onset Date'
                                ,'Presently in jail?'
                                ,'Prior WC Claims?'
                               , 'Prompting Reconsideration'
                                ,'Reconsideration Case?'
                                ,'Regarding Comp Rate'
                                ,'SSI/SSDI'
                                ,'Status Upon Intake'
                                ,'Un-Injured Caller'
                             ----   What are the charges?
                               )
ORDER BY udfnRelatedPK,    ucf.field_title
GO


update sma_mst_UDFDefinition
set udfsType = 'Text'
where udfnUDFID = 6

update sma_mst_UDFDefinition
set udfsType = 'Text'
where udfnUDFID = 23


ALTER TABLE sma_MST_UDFDefinition  ENABLE TRIGGER ALL
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
select    distinct     --fieldtitle, udf.casnOrgCaseTypeID,
	def.udfnUDFID		as [udvnUDFID],
	'Case'		as [udvsScreenName],
	'C'					as [udvsUDFCtg],
	casnCaseID			as [udvnRelatedID],
	0					as [udvnSubRelatedID],
	  td.[data]  		as [udvsUDFValue],  
	368					as [udvnRecUserID],
	getdate()			as [udvdDtCreated],
	null				as [udvnModifyUserID],
	null				as [udvdDtModified],
	null				as [udvnLevelNo]
--select *
FROM [NeosBillEasterly] ..user_case_data td
JOIN  [NeosBillEasterly]..user_case_fields ucf on ucf.id = td.usercasefieldid
JOIN sma_trn_Cases cas on cas.Neos_Saga = convert(varchar(50), td.casesid)
JOIN [sma_MST_UDFDefinition] def on def.[udfnRelatedPK] = cas.casnOrgCaseTypeID 
                                                         and def.[udfsUDFName] = ucf.field_title
														 and def.[udfsScreenName] = 'Case' --and udfstype = nuf.UDFType
 WHERE ucf.field_title  in (

                                '2nd Class Code'
                                ,'As Of'
                                , 'Date Last Worked'
                                ,'Date of Last Appointment'
                                ,'Doctor Support Claim?'
                                ,'If Other, Please Explain'
                                ,'Last Doctor Seen'
                                ,'Onset Date'
                                ,'Presently in jail?'
                                ,'Prior WC Claims?'
                               , 'Prompting Reconsideration'
                                ,'Reconsideration Case?'
                                ,'Regarding Comp Rate'
                                ,'SSI/SSDI'
                                ,'Status Upon Intake'
                                ,'Un-Injured Caller'
                             ----   What are the charges?
                               )

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
    udvsScreenName = 'Case'
    AND ISDATE(udvsUDFValue) = 1
    AND LEN(udvsUDFValue) = 10
    AND SUBSTRING(udvsUDFValue, 5, 1) = '-'
    AND SUBSTRING(udvsUDFValue, 8, 1) = '-'



--------------------
-------update the udvsUDFValue column to MM/DD/YYYY format only for values matching the YYYY-MM-DD pattern:
------------------
UPDATE sma_TRN_UDFValues
SET udvsUDFValue = CONVERT(varchar(10), TRY_CAST(udvsUDFValue AS date), 101)
---- select   *  from sma_TRN_UDFValues
WHERE 
    udvsScreenName = 'Case'
    AND ISDATE(udvsUDFValue) = 1
    AND udvsUDFValue LIKE '[1-2][0-9][0-9][0-9]-%'


-----------------------------
-------check all rows where the date format is already in MM/DD/YYYY format,
------------------------------
SELECT 
     *
FROM sma_TRN_UDFValues
WHERE 
    udvsScreenName = 'Case'
    AND udvsUDFValue LIKE '[0-1][0-9]/[0-3][0-9]/[1-2][0-9][0-9][0-9]'
------------------------------------------------
 



ALTER TABLE sma_trn_udfvalues ENABLE TRIGGER ALL
GO