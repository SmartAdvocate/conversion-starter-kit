USE SA
GO

/*
SELECT pty.casesid as CasesID, td.partyid, pty.namesid as PartyNamesID, case when convert(varchar(50),td.[namesid]) IS NULL then td.[data] else convert(varchar(50),td.[namesid]) end as [data], ucf.field_title, prl.role, rol.[SA Party]
	from [NeedlesNeosBisnarChase]..user_Party_data td
	JOIN [NeedlesNeosBisnarChase]..Party_Indexed pty on pty.id = td.partyid
	JOIN [NeedlesNeosBisnarChase]..party_role_list prl on prl.id = pty.partyrolelistid
	JOIN PartyRoles rol on rol.[Needles Roles] = prl.[role]
	JOIN [NeedlesNeosBisnarChase]..user_case_fields ucf on ucf.id = td.usercasefieldid
	WHERE field_Title in ('Accidents/Injuries', 'Agent for Service', 'Been Convicted of a Crime', 'Business Type', 'Client Insured?', 'Contact', 'Contact Address', 'Contact Phone', 'Currently Treating?', 
					'Days Absent', 'Defendant Insured?', 'Details', 'Drivers License No.', 'Drivers License State', 'Education', 'Employer Name', 'Health Insurance?', 'Job Duties', 'Language', 'Marital Status', 
					'Minor Children', 'Missed Time from Work', 'Name of Court', 'Name of Employer', 'Name of Spouse', 'Occupation', 'Other Employment', 'Parent/Guardian', 'Pending Bankruptcy?', 'Previous Complaints', 
					'Prior Accidents/Injuries', 'Priors/Subsequents', 'Rate of Pay', 'Relationship', 'Role in Accident', 'Scope of Employment', 'Type of Crime', 'Type of Health Insurance', 'Workers'' Comp Claim?' )
ORDER BY rol.[SA Party]
*/

-------------------------------------------------------------------------
--PLAINTIFF AND DEFENDANT UDFS
-------------------------------------------------------------------------
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
    rol.[SA Party]		   as [udfsScreenName],
    nuf.UDFType			   as [udfsType],
    nuf.field_len		   as [udfsLength],
    1					   as [udfbIsActive],
	NULL				   as [udfnLevelNo],
	'user_party_Data'+ ucf.[field_title]			as [udfshortName],
	nuf.dropdownValues	   as [udfsNewValues],
	DENSE_RANK() over( order by nuf.field_title)	as [udfnSortOrder]
--SELECT DISTINCT nuf.*
FROM [NeedlesNeosBisnarChase]..user_Party_data td
JOIN [NeedlesNeosBisnarChase]..Party_Indexed pty on pty.id = td.partyid
JOIN [NeedlesNeosBisnarChase]..party_role_list prl on prl.id = pty.partyrolelistid
JOIN PartyRoles rol on rol.[Needles Roles] = prl.[role]
JOIN [NeedlesNeosBisnarChase]..user_case_fields ucf on ucf.id = td.usercasefieldid
JOIN NeedlesUserFields nuf on nuf.field_id = ucf.id
JOIN sma_trn_Cases cas on cas.Needles_saga = convert(varchar(50),pty.casesid)
LEFT JOIN [sma_MST_UDFDefinition] def on def.[udfnRelatedPK] = cas.casnOrgCaseTypeID and def.[udfsUDFName] = nuf.field_title and def.[udfsScreenName] = rol.[SA Party]
WHERE ucf.field_Title in ('Accidents/Injuries', 'Agent for Service', 'Been Convicted of a Crime', 'Business Type', 'Client Insured?', 'Contact', 'Contact Address', 'Contact Phone', 'Currently Treating?', 
					'Days Absent', 'Defendant Insured?', 'Details', 'Drivers License No.', 'Drivers License State', 'Education', 'Employer Name', 'Health Insurance?', 'Job Duties', 'Language', 'Marital Status', 
					'Minor Children', 'Missed Time from Work', 'Name of Court', 'Name of Employer', 'Name of Spouse', 'Occupation', 'Other Employment', 'Parent/Guardian', 'Pending Bankruptcy?', 'Previous Complaints', 
					'Prior Accidents/Injuries', 'Priors/Subsequents', 'Rate of Pay', 'Relationship', 'Role in Accident', 'Scope of Employment', 'Type of Crime', 'Type of Health Insurance', 'Workers'' Comp Claim?' )

---------------------------------
--UDF VALUES
---------------------------------
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
	rol.[SA Party]			as [udvsScreenName],
	'C'						as [udvsUDFCtg],
	CAS.casnCaseID			as [udvnRelatedID],
	isnull(Pl.plnnPlaintiffID, df.defnDefendentID)	as[udvnSubRelatedID],
    td.[data]				as [udvsUDFValue],
	368						as [udvnRecUserID],
	getdate()				as [udvdDtCreated],
	null					as [udvnModifyUserID],
	null					as [udvdDtModified],
	null					as [udvnLevelNo]
FROM [NeedlesNeosBisnarChase]..user_Party_data td
JOIN [NeedlesNeosBisnarChase]..Party_Indexed pty on pty.id = td.partyid
JOIN [NeedlesNeosBisnarChase]..party_role_list prl on prl.id = pty.partyrolelistid
JOIN PartyRoles rol on rol.[Needles Roles] = prl.[role]
JOIN [NeedlesNeosBisnarChase]..user_case_fields ucf on ucf.id = td.usercasefieldid
--JOIN NeedlesUserFields nuf on nuf.field_id = ucf.id
JOIN sma_trn_Cases cas on cas.Needles_saga = convert(varchar(50),pty.casesid)
LEFT JOIN [sma_MST_UDFDefinition] def on def.[udfnRelatedPK] = cas.casnOrgCaseTypeID and def.[udfsUDFName] = ucf.field_title and def.[udfsScreenName] = rol.[SA Party]
LEFT JOIN sma_trn_Plaintiff Pl on pl.saga_party = pty.id
LEFT JOIN sma_trn_Defendants DF on DF.saga_party = pty.id
WHERE ucf.field_Title in ('Accidents/Injuries', 'Agent for Service', 'Been Convicted of a Crime', 'Business Type', 'Client Insured?', 'Contact', 'Contact Address', 'Contact Phone', 'Currently Treating?', 
					'Days Absent', 'Defendant Insured?', 'Details', 'Drivers License No.', 'Drivers License State', 'Education', 'Employer Name', 'Health Insurance?', 'Job Duties', 'Language', 'Marital Status', 
					'Minor Children', 'Missed Time from Work', 'Name of Court', 'Name of Employer', 'Name of Spouse', 'Occupation', 'Other Employment', 'Parent/Guardian', 'Pending Bankruptcy?', 'Previous Complaints', 
					'Prior Accidents/Injuries', 'Priors/Subsequents', 'Rate of Pay', 'Relationship', 'Role in Accident', 'Scope of Employment', 'Type of Crime', 'Type of Health Insurance', 'Workers'' Comp Claim?' )
