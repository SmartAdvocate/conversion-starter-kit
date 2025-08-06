USE SA
GO


INSERT INTO sma_MST_UDFDefinition (
		udfsUDFCtg, udfnRelatedPK, udfsUDFName, 
		udfsScreenName, udfsType, udfsLength, 
		udfnSortOrder, udfbIsActive, udfnRecUserID, 
		udfnDtCreated
)
SELECT 
		'C'						as udfsUDFCtg, 
		ct.cstnCaseTypeID		as udfnRelatedPK, 
		u.udf					as udfsUDFName, 
		'Case Wizard'		as udfsScreenName, 
		'Text'					as udfsType, 
		100						as udfsLength, 
		0						as udfnSortOrder, 
		1						as udfbIsActive, 
		368						as udfnRecUserID, 
		getdate()				as udfnDtCreated
FROM (SELECT 'Location' as udf
	UNION SELECT 'City' as udf
	UNION SELECT 'State' as udf
	UNION SELECT 'County' as udf) u
CROSS JOIN (Select cstnCaseTypeID from sma_mst_Casetype where VenderCaseType = 'BisnarChaseCaseType') ct
LEFT JOIN sma_MST_UDFDefinition udf on udf.udfnRelatedPK = ct.cstnCaseTypeID and udf.udfsUDFName = 'Location' and udf.udfsScreenName = 'Case Wizard'
WHERE udf.udfnUDFID IS NULL


--INCIDENT LOCATION
---LOCATION---
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
SELECT  
    (select udfnUDFID from sma_MST_UDFDefinition 
	   where udfnRelatedPK=cas.casnOrgCaseTypeID
	   and udfsScreenName='Case Wizard'
	   and udfsUDFName='Location')
    						  as [udvnUDFID],
    'Case Wizard'		  as [udvsScreenName],
    'C'						  as [udvsUDFCtg],
    CAS.casnCaseID			  as [udvnRelatedID],
    0						  as[udvnSubRelatedID],
    u.[data]		 	  as [udvsUDFValue], 
    368						  as [udvnRecUserID],
    getdate()				  as [udvdDtCreated],
    null					  as [udvnModifyUserID],
    null					  as [udvdDtModified],
    null					  as [udvnLevelNo]
FROM [NeedlesNeosBisnarChase].[dbo].[cases] C
LEFT JOIN (SELECT td.casesid, td.[data]
		FROM [NeedlesNeosBisnarChase]..user_tab6_data td
		JOIN [NeedlesNeosBisnarChase]..user_case_fields ucf on ucf.id = td.usercasefieldid
		WHERE field_title = 'Location of Accident') u on u.casesid = c.id
JOIN [sma_TRN_cases] CAS on CAS.Needles_Saga = convert(varchar(50),C.[id])



---CITY---
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
SELECT  
    (select udfnUDFID from sma_MST_UDFDefinition 
	   where udfnRelatedPK=cas.casnOrgCaseTypeID
	   and udfsScreenName='Case Wizard'
	   and udfsUDFName='City')
    						  as [udvnUDFID],
    'Case Wizard'		  as [udvsScreenName],
    'C'						  as [udvsUDFCtg],
    CAS.casnCaseID			  as [udvnRelatedID],
    0						  as[udvnSubRelatedID],
    u.[data]				  as [udvsUDFValue], 
    368						  as [udvnRecUserID],
    getdate()				  as [udvdDtCreated],
    null					  as [udvnModifyUserID],
    null					  as [udvdDtModified],
    null					  as [udvnLevelNo]
FROM [NeedlesNeosBisnarChase].[dbo].[cases] C
LEFT JOIN (SELECT td.casesid, td.[data]
		FROM [NeedlesNeosBisnarChase]..user_tab6_data td
		JOIN [NeedlesNeosBisnarChase]..user_case_fields ucf on ucf.id = td.usercasefieldid
		WHERE field_title = 'City') u on u.casesid = c.id
JOIN [sma_TRN_cases] CAS on CAS.Needles_Saga = convert(varchar(50),C.[id])

---COUNTY---
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
SELECT  
    (select udfnUDFID from sma_MST_UDFDefinition 
	   where udfnRelatedPK=cas.casnOrgCaseTypeID
	   and udfsScreenName='Case Wizard'
	   and udfsUDFName='County')
    						  as [udvnUDFID],
    'Case Wizard'		  as [udvsScreenName],
    'C'						  as [udvsUDFCtg],
    CAS.casnCaseID			  as [udvnRelatedID],
    0						  as [udvnSubRelatedID],
    u.[data]				  as [udvsUDFValue], 
    368						  as [udvnRecUserID],
    getdate()				  as [udvdDtCreated],
    null					  as [udvnModifyUserID],
    null					  as [udvdDtModified],
    null					  as [udvnLevelNo]
FROM [NeedlesNeosBisnarChase].[dbo].[cases] C
LEFT JOIN (SELECT td.casesid, td.[data]
		FROM [NeedlesNeosBisnarChase]..user_tab6_data td
		JOIN [NeedlesNeosBisnarChase]..user_case_fields ucf on ucf.id = td.usercasefieldid
		WHERE field_title = 'County') u on u.casesid = c.id
JOIN [sma_TRN_cases] CAS on CAS.Needles_Saga = convert(varchar(50),C.[id])


---STATE---
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
SELECT  
    (select udfnUDFID from sma_MST_UDFDefinition 
	   where udfnRelatedPK=cas.casnOrgCaseTypeID
	   and udfsScreenName='Case Wizard'
	   and udfsUDFName='State')
    						  as [udvnUDFID],
    'Case Wizard'		  as [udvsScreenName],
    'C'						  as [udvsUDFCtg],
    CAS.casnCaseID			  as [udvnRelatedID],
    0						  as [udvnSubRelatedID],
    u.[data]				  as [udvsUDFValue], 
    368						  as [udvnRecUserID],
    getdate()				  as [udvdDtCreated],
    null					  as [udvnModifyUserID],
    null					  as [udvdDtModified],
    null					  as [udvnLevelNo]
FROM [NeedlesNeosBisnarChase].[dbo].[cases] C
LEFT JOIN (SELECT td.casesid, td.[data]
		FROM [NeedlesNeosBisnarChase]..user_tab6_data td
		JOIN [NeedlesNeosBisnarChase]..user_case_fields ucf on ucf.id = td.usercasefieldid
		WHERE field_title = 'State') u on u.casesid = c.id
JOIN [sma_TRN_cases] CAS on CAS.Needles_Saga = convert(varchar(50),C.[id])