USE   [SAbilleasterlyLaw]
GO

/*
SELECT td.casesid, case when convert(varchar(50),td.[namesid]) IS NULL then td.[data] else convert(varchar(50),td.[namesid]) end as [data], ucf.field_title
	FROM   [NeosBillEasterly]..user_case_data td
	JOIN  [NeosBillEasterly]..user_case_fields ucf on ucf.id = td.usercasefieldid
	WHERE field_Title in ('County of Suit', 'Defendant Caption','Judicial District','JURY','MDL Court','MDL Defendant Caption','MDL Docket',
					'MDL Judge','MDL Plaintiff Caption','Mediator','NON JURY','Plaintiff','Plaintiff Caption','State of Suit','Sub-Category',
					'Type of Court' )
*/

-----------------------------------------
--UDF DEFINITION
-----------------------------------------
INSERT INTO [sma_MST_UDFDefinition]
(
    [udfsUDFCtg]
    ,[udfnRelatedPK]
    ,[udfsUDFName]
    ,[udfsScreenName]
    ,[udfsType]
    ,[udfsLength]
    ,[udfbIsActive]
    ,[udfnLevelNo]
	,[UdfShortName]
	,[udfsNewValues]
    ,[udfnSortOrder]
)
SELECT DISTINCT
	'C'					   as [udfsUDFCtg],
    cas.casnOrgCaseTypeID  as [udfnRelatedPK],
    nuf.field_title		   as [udfsUDFName],   
    'Court'				   as [udfsScreenName],
    nuf.UDFType			   as [udfsType],
    nuf.field_len		   as [udfsLength],
    1					   as [udfbIsActive],
	NULL				   as [udfnLevelNo],
	'user_case_Data'+ ucf.[field_title]			as [udfshortName],
	nuf.dropdownValues	   as [udfsNewValues],
	DENSE_RANK() over( order by nuf.field_title)	as [udfnSortOrder]
--SELECT DISTINCT nuf.*
FROM  [NeosBillEasterly]..user_case_data td
JOIN [NeosBillEasterly]..user_case_fields ucf on ucf.id = td.usercasefieldid
JOIN NeosUserFields nuf on nuf.field_id = ucf.id
JOIN sma_trn_Cases cas on cas.Neos_Saga = convert(varchar(50),td.casesid)
LEFT JOIN [sma_MST_UDFDefinition] def on def.[udfnRelatedPK] = cas.casnOrgCaseTypeID and def.[udfsUDFName] = nuf.field_title and def.[udfsScreenName] = 'Court'
WHERE ucf.field_Title in ('County of Suit', 'Defendant','Defendant Caption','Judicial District','JURY','MDL Defendant Caption',
					'MDL Plaintiff Caption','Mediator','NON JURY','Plaintiff','Plaintiff Caption','State of Suit','Sub-Category',
					'Type of Court' )
AND def.udfnUDFID IS NULL


---------------------------------
--UDF VALUES
---------------------------------
ALTER TABLE sma_TRN_UDFVALUES DISABLE TRIGGER ALL
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
SELECT DISTINCT
	def.udfnUDFID 			as [udvnUDFID],
	'Court'					as [udvsScreenName],
	'C'						as [udvsUDFCtg],
	CAS.casnCaseID			as [udvnRelatedID],
	NULL					as [udvnSubRelatedID],
	td.[data]				as udvsUDFValue, 
    --case when def.udfsType = 'CheckBox' then (case when td.[data] = 'false' then 0 when td.[data] = 'true' then 0 end) 
		--	else td.[data] end	as [udvsUDFValue],
	368						as [udvnRecUserID],
	getdate()				as [udvdDtCreated],
	null					as [udvnModifyUserID],
	null					as [udvdDtModified],
	null					as [udvnLevelNo]
FROM  [NeosBillEasterly]..user_case_data td
JOIN  [NeosBillEasterly]..user_case_fields ucf on ucf.id = td.usercasefieldid
--JOIN NeedlesUserFields nuf on nuf.field_id = ucf.id
JOIN sma_trn_Cases cas on cas.Neos_Saga = convert(varchar(50),td.casesid)
JOIN [sma_MST_UDFDefinition] def on def.[udfnRelatedPK] = cas.casnOrgCaseTypeID and def.[udfsUDFName] = ucf.field_title and def.[udfsScreenName] = 'Court'
WHERE ucf.field_Title in ('County of Suit', 'Defendant','Defendant Caption','Judicial District','JURY','MDL Defendant Caption',
					'MDL Plaintiff Caption','Mediator','NON JURY','Plaintiff','Plaintiff Caption','State of Suit','Sub-Category',
					'Type of Court' )
GO

ALTER TABLE sma_TRN_UDFVALUES ENABLE TRIGGER ALL
GO