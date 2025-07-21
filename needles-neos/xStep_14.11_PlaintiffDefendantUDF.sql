USE   [SAbilleasterlyLaw]
GO

/*
SELECT pty.casesid as CasesID, td.partyid, pty.namesid as PartyNamesID, case when convert(varchar(50),td.[namesid]) IS NULL then td.[data] else convert(varchar(50),td.[namesid]) end as [data], ucf.field_title, prl.role, rol.[SA Party]
	from  [NeosBillEasterly]..user_Party_data td
	JOIN  [NeosBillEasterly]..Party_Indexed pty on pty.id = td.partyid
	JOIN [NeosBillEasterly]..party_role_list prl on prl.id = pty.partyrolelistid
	JOIN PartyRoles rol on rol.[Needles Roles] = prl.[role]
	JOIN  [NeosBillEasterly]..user_case_fields ucf on ucf.id = td.usercasefieldid
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
    rol.[SAParty] 		   as [udfsScreenName],
    nuf.UDFType			   as [udfsType],
    nuf.field_len		   as [udfsLength],
    1					   as [udfbIsActive],
	NULL				   as [udfnLevelNo],
	'user_party_Data: '+ ucf.[field_title]			as [udfshortName],
	nuf.dropdownValues	   as [udfsNewValues],
	DENSE_RANK() over( order by nuf.field_title)	as [udfnSortOrder]
--SELECT DISTINCT nuf.*, rol.SAParty
FROM [NeosBillEasterly]..user_Party_data td
JOIN [NeosBillEasterly]..Party_Indexed pty on pty.id = td.partyid
JOIN [NeosBillEasterly]..party_role_list prl on prl.id = pty.partyrolelistid
JOIN PartyRoles rol on rol.[BillEasterlyRole] = prl.[role]
JOIN [NeosBillEasterly]..user_case_fields ucf on ucf.id = td.usercasefieldid
JOIN NeosUserFields nuf on nuf.field_id = ucf.id
JOIN sma_trn_Cases cas on cas.Neos_Saga = convert(varchar(50),pty.casesid)
LEFT JOIN [sma_MST_UDFDefinition] def on def.[udfnRelatedPK] = cas.casnOrgCaseTypeID 
                                                                  and def.[udfsUDFName] = nuf.field_title
																  and def.[udfsScreenName] = rol.[SAParty]
 
order by nuf.field_title  
GO

----- select * from sma_mst_UDFDefinition
update sma_mst_UDFDefinition
set udfsType = 'Text'
where  udfsType = 'Contact'
 
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
	rol.[SAParty]			as [udvsScreenName],
	'C'						as [udvsUDFCtg],
	CAS.casnCaseID			as [udvnRelatedID],
	isnull(Pl.plnnPlaintiffID, df.defnDefendentID)	as[udvnSubRelatedID],
    case when ucf.field_Type = '14' then (select top 1 convert(varchar,UNQCID) from indvorgcontacts_Indexed where saga_ref = convert(varchar(50),td.[namesid])) else td.[data] end			as [udvsUDFValue],  
	368						as [udvnRecUserID],
	getdate()				as [udvdDtCreated],
	null					as [udvnModifyUserID],
	null					as [udvdDtModified],
	null					as [udvnLevelNo]
FROM  [NeosBillEasterly]..user_Party_data td
JOIN  [NeosBillEasterly]..Party_Indexed pty on pty.id = td.partyid
JOIN  [NeosBillEasterly]..party_role_list prl on prl.id = convert(varchar(50),pty.partyrolelistid)
JOIN PartyRoles rol on rol.[BillEasterlyRole] = prl.[role]
JOIN  [NeosBillEasterly]..user_case_fields ucf on ucf.id = convert(varchar(50),td.usercasefieldid)
--JOIN NeedlesUserFields nuf on nuf.field_id = ucf.id
JOIN sma_trn_Cases cas on cas.Neos_Saga = convert(varchar(50),pty.casesid)
 LEFT JOIN [sma_MST_UDFDefinition] def on def.[udfnRelatedPK] = cas.casnOrgCaseTypeID 
                                                                    and def.[udfsUDFName] = ucf.field_title
																	and def.[udfsScreenName] = rol.[SAParty]
LEFT JOIN sma_trn_Plaintiff Pl on pl.saga_party = convert(varchar(50),pty.id)
LEFT JOIN sma_trn_Defendants DF on DF.saga_party = convert(varchar(50),pty.id)
GO


----select * from sma_TRN_UDFValues where udvdDtCreated = '2025-05-14 16:46:00'

---------------
------01. preview what the updated values will look like before running the actual UPDATE:
--------------
SELECT   *
  /*  udvnPKID,
    udvsUDFValue AS OriginalValue,
    CONVERT(varchar(10), TRY_CAST(udvsUDFValue AS date), 101) AS ConvertedValue   */
FROM sma_TRN_UDFValues
WHERE 
    udvsScreenName  in ('Plaintiff', 'Defendant')
    AND ISDATE(udvsUDFValue) = 1
	   AND udvsUDFValue LIKE '[1-2][0-9][0-9][0-9]-%'
   /* AND LEN(udvsUDFValue) = 10
    AND SUBSTRING(udvsUDFValue, 5, 1) = '-'
    AND SUBSTRING(udvsUDFValue, 8, 1) = '-'  */



--------------------
-------update the udvsUDFValue column to MM/DD/YYYY format only for values matching the YYYY-MM-DD pattern:
------------------
UPDATE sma_TRN_UDFValues
SET udvsUDFValue = CONVERT(varchar(10), TRY_CAST(udvsUDFValue AS date), 101)
---- select   *  from sma_TRN_UDFValues
WHERE 
    udvsScreenName in  ('Plaintiff' ,  'Defendant')
    AND ISDATE(udvsUDFValue) = 1
    AND udvsUDFValue LIKE '[1-2][0-9][0-9][0-9]-%'


-----------------------------
-------check all rows where the date format is already in MM/DD/YYYY format,
------------------------------
SELECT 
     *
FROM sma_TRN_UDFValues
WHERE 
    udvsScreenName in ('Plaintiff' ,  'Defendant')
    AND udvsUDFValue LIKE '[0-1][0-9]/[0-3][0-9]/[1-2][0-9][0-9][0-9]'
------------------------------------------------