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
    ucf.field_Title			as [udfsUDFName],   
    'Case'					as [udfsScreenName],
    nuf.UDFType				as [udfsType],
    ucf.field_len			as [udfsLength],
    1						as [udfbIsActive],
	 'user_Tab7_Data'+ucf.field_Title	as [udfshortName],
    nuf.dropdownValues		as [udfsNewValues],
    DENSE_RANK() over( order by ucf.field_Title) as udfnSortOrder
FROM [NeedlesNeosBisnarChase]..user_tab7_data td
JOIN [NeedlesNeosBisnarChase]..user_case_fields ucf on ucf.id = td.usercasefieldid
JOIN NeedlesUserFields nuf on nuf.field_title = ucf.field_title 
JOIN sma_trn_Cases cas on cas.Needles_saga = convert(varchar(50), td.casesid)
LEFT JOIN [sma_MST_UDFDefinition] def on def.[udfnRelatedPK] = cas.casnOrgCaseTypeID and def.[udfsUDFName] = ucf.field_title and def.[udfsScreenName] = 'Case' and udfstype = nuf.UDFType
WHERE def.udfnUDFID IS NULL
and ucf.field_Title in ('Agreement Sent', 'Caller Gender', 'Case Accepted By', 'Date Dropped', 'Date Interview Returned', 'Date Rejected', 'Date Sent to Client', 'Dropped By', 'Fee Agreement', 
					'Fee Terms', 'Intake Call?', 'Intake Form?', 'Internal Referral Source', 'Method of Sending', 'Method of Sign Up', 'Reason Dropped', 'Reason for Acceptance', 'Reason for Rejection', 
					'Received Signed Agreement', 'Refer To?', 'Referral Decision', 'Referral Decision Date', 'Referral Gift Sent?', 'Referral Source Code', 'Referred To Date', 'Referring Attorney', 
					'Rejected By', 'Second Attempt', 'Second Method of Sending', 'Second Sent By:', 'Sent By:', 'Sent to Marketing', 'SOL Issue', 'Star Case', 'Third Attempt', 'Third Method of Sending', 
					'Third Sent By:', 'Want Case Reason', 'Want Case?', 'What Gift?' )
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
SELECT 
	def.udfnUDFID		as [udvnUDFID],
	'Case'				as [udvsScreenName],
	'C'					as [udvsUDFCtg],
	casnCaseID			as [udvnRelatedID],
	0					as [udvnSubRelatedID],
	--isnull(nm.UNQCID, udf.FieldVal)		as [udvsUDFValue],  --IF field is a Name, then use unique ID for "Contact" Types
	case when isnull(convert(varchar(50),td.namesid),'') = '' then td.[data] else ioc.[name] end		as [udvsUDFValue],  --IF field is a Name, then use unique ID for "Contact" Types
	368					as [udvnRecUserID],
	getdate()			as [udvdDtCreated],
	null				as [udvnModifyUserID],
	null				as [udvdDtModified],
	null				as [udvnLevelNo]
--select *
FROM [NeedlesNeosBisnarChase]..user_tab7_data td
JOIN [NeedlesNeosBisnarChase]..user_case_fields ucf on ucf.id = td.usercasefieldid
JOIN NeedlesUserFields nuf on nuf.field_title = ucf.field_title 
LEFT JOIN IndvOrgContacts_Indexed ioc on ioc.saga = convert(varchar(50),td.namesid)
JOIN sma_trn_Cases cas on cas.Needles_saga = convert(varchar(50), td.casesid)
JOIN [sma_MST_UDFDefinition] def on def.[udfnRelatedPK] = cas.casnOrgCaseTypeID and def.[udfsUDFName] = ucf.field_title and def.[udfsScreenName] = 'Case' and udfstype = nuf.UDFType
WHERE ucf.field_Title in ('Agreement Sent', 'Caller Gender', 'Case Accepted By', 'Date Dropped', 'Date Interview Returned', 'Date Rejected', 'Date Sent to Client', 'Dropped By', 'Fee Agreement', 
					'Fee Terms', 'Intake Call?', 'Intake Form?', 'Internal Referral Source', 'Method of Sending', 'Method of Sign Up', 'Reason Dropped', 'Reason for Acceptance', 'Reason for Rejection', 
					'Received Signed Agreement', 'Refer To?', 'Referral Decision', 'Referral Decision Date', 'Referral Gift Sent?', 'Referral Source Code', 'Referred To Date', 'Referring Attorney', 
					'Rejected By', 'Second Attempt', 'Second Method of Sending', 'Second Sent By:', 'Sent By:', 'Sent to Marketing', 'SOL Issue', 'Star Case', 'Third Attempt', 'Third Method of Sending', 
					'Third Sent By:', 'Want Case Reason', 'Want Case?', 'What Gift?' )
GO

ALTER TABLE sma_trn_udfvalues ENABLE TRIGGER ALL
GO

