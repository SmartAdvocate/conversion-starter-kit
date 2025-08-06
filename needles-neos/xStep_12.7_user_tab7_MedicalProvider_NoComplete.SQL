USE   [SAbilleasterlyLaw]
GO

/*alter table [sma_TRN_Hospitals] disable trigger all
delete from [sma_TRN_Hospitals]
DBCC CHECKIDENT ('sma_TRN_Hospitals', RESEED, 0);
alter table [sma_TRN_Hospitals] enable trigger all   */



ALTER TABLE [sma_TRN_Hospitals] DISABLE TRIGGER ALL
GO

---(1)---
INSERT INTO [sma_TRN_Hospitals]
 (	[hosnCaseID], 
	[hosnContactID], 
	[hosnContactCtg],
	[hosnAddressID], 
	[hossMedProType], 
	[hosdStartDt],
	[hosdEndDt],
	[hosnPlaintiffID],
	[hosnComments], 
	[hosnHospitalChart], 
	[hosnRecUserID],
	[hosdDtCreated], 
	[hosnModifyUserID],
	[hosdDtModified],
	[saga]
)
SELECT distinct 
    cas.casnCaseID		as [hosnCaseID], 
    ioc.CID				as [hosnContactID],
    ioc.CTG				as [hosnContactCtg],
    ioc.AID				as [hosnAddressID], 
    'M'					as [hossMedProType],
    null				as [hosdStartDt],
    null				as [hosdEndDt],
    (select plnnPlaintiffID From sma_trn_Plaintiff where plnnCaseID = cas.casncaseid and plnbIsPrimary =1)		as hosnPlaintiffID,
    null				as [hosnComments],
    null				as [hosnHospitalChart],
    368				    as [hosnRecUserID],
    getdate()			as [hosdDtCreated],
    null				as [hosnModifyUserID],
    null				as [hosdDtModified],
    'Tab7'			    as [saga]
---- select * 
FROM [NeosBillEasterly]..user_tab7_data n
join [NeosBillEasterly]..user_case_fields f on n.usercasefieldid =f.id 
JOIN sma_trn_Cases cas on cas.Neos_saga = convert(varchar(36),n.casesid)
LEFT JOIN IndvOrgContacts_Indexed ioc on ioc.saga_ref = convert(varchar(36),n.namesid)
WHERE TRY_CONVERT(UNIQUEIDENTIFIER, n.namesid) IS NOT NULL 
  AND f.field_title in ( 'Ambulance', 'Hospital Admission', 'Surgery')
 

ALTER TABLE [sma_TRN_Hospitals] ENABLE TRIGGER ALL
GO

 --------------------------------
--UPDATE CONTACT TYPE
--------------------------------
--INDIVIDUAL CONTACTS
UPDATE sma_MST_IndvContacts 
set cinnContactTypeID = (select octnOrigContactTypeID From sma_MST_OriginalContactTypes where octnContactCtgID = 1 and octsDscrptn = 'Doctor')
FROM  [NeosBillEasterly]..user_tab7_data n
JOIN  [NeosBillEasterly]..user_case_fields   f   on f.id = convert(varchar(36), n.usercasefieldid)
--JOIN IndvOrgContacts_Indexed ioc on ioc.saga_ref = n.[user_name]
JOIN sma_MST_IndvContacts ind on ind.saga = n.[namesid]
WHERE TRY_CONVERT(UNIQUEIDENTIFIER, n.namesid) IS NOT NULL   AND f.field_title = 'Ambulance'

/*--ORGANIZATION CONTACTS
UPDATE sma_MST_orgContacts 
set connContactTypeID = (select octnOrigContactTypeID From sma_MST_OriginalContactTypes where octnContactCtgID = 2 and octsDscrptn = 'Hospital')
FROM  [NeosBillEasterly]..User_Tab6_Matter m
JOIN NeosBrianWhite..user_Tab6_Name n on m.ref_num = n.ref_num
--JOIN IndvOrgContacts_Indexed ioc on ioc.saga = n.[user_name]
JOIN sma_MST_orgContacts org on org.saga = n.[user_name]
WHERE n.[user_name] <> 0
and m.field_title = 'Ambulance/Rescue'

----------------------------------------------------
--ADD AMBULANCE AS SPECIALTY TO CONTACT RECORD
----------------------------------------------------
INSErT INTO sma_TRN_MedicalProviderSpecialitySubSpeciality (mdprvspeID, mdprvContactID, mdprvContactctgID)
SELECT DISTINCT (select splID From sma_MST_MedicalProvideSpeciality where spDescription = 'Ambulance'),
	ioc.cid, ioc.CTG
FROM [NeosBrianWhite]..User_Tab6_Matter m
JOIN NeosBrianWhite..user_Tab6_Name n on m.ref_num = n.ref_num
JOIN IndvOrgContacts_Indexed ioc on ioc.saga = n.[user_name]
WHERE n.[user_name] <> 0
and m.field_title = 'Ambulance/Rescue'   */