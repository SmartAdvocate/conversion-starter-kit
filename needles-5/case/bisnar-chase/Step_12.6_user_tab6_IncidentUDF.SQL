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


SELECT td.casesid, case when convert(varchar(50),td.[namesid]) IS NULL then td.[data] else convert(varchar(50),td.[namesid]) end as [data], ucf.field_title
	FROM [NeedlesNeosBisnarChase]..user_tab6_data td
	JOIN [NeedlesNeosBisnarChase]..user_case_fields ucf on ucf.id = td.usercasefieldid
	WHERE field_Title in ('Abdominal Pain', 'Accident Report?', 'Airbag Deployed', 'Animal Control Contacted?', 'Animal Restrained?', 'Any Witnesess?', 'Arb. Release Signed?', 
					'Caller Gender', 'Case Dismissed', 'Cause of Death', 'Chest Pain', 'Citation Info', 'Client Wear Glasses?', 'Clt Location in Vehicle', 'Coroner', 'County of Use', 
					'Date Administered?', 'Day of Week', 'Def on Cell Phone', 'Describe', 'Description', 'Description of Animal', 'Disposition of Animal', 'Doctor/Nurse Reviewing', 'Driveable?', 
					'Earnings Statement', 'Excessive Alcohol Use', 'Explain', 'Fainting', 'Following Directions?', 'Form of Pay', 'Gastrointestinal Problems', 'Headache', 'Heart Problems', 
					'High Blood Pressure', 'How Many Dogs?', 'How Soon After Receiving?', 'Increased Sweating', 'Kidney Problems', 'Lighting Conditions', 'Maintenance Schedule', 'Meal Break', 
					'Multiple Impact?', 'Nausea/Vomiting', 'Notes', 'Number of Vehicles', 'Organ Failure', 'Other Side Effects', 'Other Type of Claim?', 'Overtime', 'Overtime Rate', 'Physical Difficulties?', 
					'Plt on Cell Phone', 'Pregnant', 'Prior Complaint on Animal', 'Product', 'Product Expiration', 'Product Warnings', 'Property Damage Comments', 'Rate of Pay', 'Reading Only?', 
					'Reason on Property', 'Registered Owner', 'Rest Break', 'Seatbelt', 'Smoker', 'State of Use', 'Summary of Medical Review', 'Surface Conditions', 'Suspected Abuse', 'Suspected Malpractice', 
					'Tested for Rabies?', 'Throat Swelling', 'To Whom was it Reported', 'Total Class Members', 'Type Mass Tort Claim?', 'Type of Accident', 'Type of Damage', 'Type of Shoes Worn', 
					'Under the Effects Of?', 'Unlawful Wage Deductions', 'Unreimbursed Expenses', 'Warnings', 'What Did You Slip On?', 'What Kind?', 'Where Did It Come From?', 'Where is Product Now')
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
    'Case Wizard'			as [udfsScreenName],
    nuf.UDFType				as [udfsType],
    nuf.field_len			as [udfsLength],
    1						as [udfbIsActive],
	 'user_Tab6_Data'+ucf.field_title	as [udfshortName],
    nuf.dropdownValues		as [udfsNewValues],
    DENSE_RANK() over( order by cas.casnOrgCaseTypeID) as udfnSortOrder
FROM [NeedlesNeosBisnarChase]..user_tab6_data td
JOIN [NeedlesNeosBisnarChase]..user_case_fields ucf on ucf.id = td.usercasefieldid
JOIN NeedlesUserFields nuf on nuf.field_title = ucf.field_title 
JOIN sma_trn_Cases cas on cas.Needles_saga = convert(varchar(50), td.casesid)
--LEFT JOIN (select distinct table_Name, column_name From [NeedlesNeosBisnarChase]..[document_merge_params] where table_Name = 'user_Tab6_Data') dmp
												--on dmp.column_name = ucf.field_Title
LEFT JOIN [sma_MST_UDFDefinition] def on def.[udfnRelatedPK] = cas.casnOrgCaseTypeID and def.[udfsUDFName] = ucf.field_title and def.[udfsScreenName] = 'Case Wizard' and udfstype = nuf.UDFType
WHERE def.udfnUDFID IS NULL
and ucf.field_Title in ('Abdominal Pain', 'Accident Report?', 'Airbag Deployed', 'Animal Control Contacted?', 'Animal Restrained?', 'Any Witnesess?', 'Arb. Release Signed?', 
					'Caller Gender', 'Case Dismissed', 'Cause of Death', 'Chest Pain', 'Citation Info', 'Client Wear Glasses?', 'Clt Location in Vehicle', 'Coroner', 'County of Use', 
					'Date Administered?', 'Day of Week', 'Def on Cell Phone', 'Describe', 'Description', 'Description of Animal', 'Disposition of Animal', 'Doctor/Nurse Reviewing', 'Driveable?', 
					'Earnings Statement', 'Excessive Alcohol Use', 'Explain', 'Fainting', 'Following Directions?', 'Form of Pay', 'Gastrointestinal Problems', 'Headache', 'Heart Problems', 
					'High Blood Pressure', 'How Many Dogs?', 'How Soon After Receiving?', 'Increased Sweating', 'Kidney Problems', 'Lighting Conditions', 'Maintenance Schedule', 'Meal Break', 
					'Multiple Impact?', 'Nausea/Vomiting', 'Notes', 'Number of Vehicles', 'Organ Failure', 'Other Side Effects', 'Other Type of Claim?', 'Overtime', 'Overtime Rate', 'Physical Difficulties?', 
					'Plt on Cell Phone', 'Pregnant', 'Prior Complaint on Animal', 'Product', 'Product Expiration', 'Product Warnings', 'Property Damage Comments', 'Rate of Pay', 'Reading Only?', 
					'Reason on Property', 'Registered Owner', 'Rest Break', 'Seatbelt', 'Smoker', 'State of Use', 'Summary of Medical Review', 'Surface Conditions', 'Suspected Abuse', 'Suspected Malpractice', 
					'Tested for Rabies?', 'Throat Swelling', 'To Whom was it Reported', 'Total Class Members', 'Type Mass Tort Claim?', 'Type of Accident', 'Type of Damage', 'Type of Shoes Worn', 
					'Under the Effects Of?', 'Unlawful Wage Deductions', 'Unreimbursed Expenses', 'Warnings', 'What Did You Slip On?', 'What Kind?', 'Where Did It Come From?', 'Where is Product Now')
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
	'Case Wizard'		as [udvsScreenName],
	'C'					as [udvsUDFCtg],
	casnCaseID			as [udvnRelatedID],
	0					as [udvnSubRelatedID],
	td.[data]		as [udvsUDFValue],  
	368					as [udvnRecUserID],
	getdate()			as [udvdDtCreated],
	null				as [udvnModifyUserID],
	null				as [udvdDtModified],
	null				as [udvnLevelNo]
--select *
FROM [NeedlesNeosBisnarChase]..user_tab6_data td
JOIN [NeedlesNeosBisnarChase]..user_case_fields ucf on ucf.id = td.usercasefieldid
JOIN sma_trn_Cases cas on cas.Needles_saga = convert(varchar(50), td.casesid)
JOIN [sma_MST_UDFDefinition] def on def.[udfnRelatedPK] = cas.casnOrgCaseTypeID and def.[udfsUDFName] = ucf.field_title and def.[udfsScreenName] = 'Case Wizard' --and udfstype = nuf.UDFType
WHERE ucf.field_Title in ('Abdominal Pain', 'Accident Report?', 'Airbag Deployed', 'Animal Control Contacted?', 'Animal Restrained?', 'Any Witnesess?', 'Arb. Release Signed?', 
					'Caller Gender', 'Case Dismissed', 'Cause of Death', 'Chest Pain', 'Citation Info', 'Client Wear Glasses?', 'Clt Location in Vehicle', 'Coroner', 'County of Use', 
					'Date Administered?', 'Day of Week', 'Def on Cell Phone', 'Describe', 'Description', 'Description of Animal', 'Disposition of Animal', 'Doctor/Nurse Reviewing', 'Driveable?', 
					'Earnings Statement', 'Excessive Alcohol Use', 'Explain', 'Fainting', 'Following Directions?', 'Form of Pay', 'Gastrointestinal Problems', 'Headache', 'Heart Problems', 
					'High Blood Pressure', 'How Many Dogs?', 'How Soon After Receiving?', 'Increased Sweating', 'Kidney Problems', 'Lighting Conditions', 'Maintenance Schedule', 'Meal Break', 
					'Multiple Impact?', 'Nausea/Vomiting', 'Notes', 'Number of Vehicles', 'Organ Failure', 'Other Side Effects', 'Other Type of Claim?', 'Overtime', 'Overtime Rate', 'Physical Difficulties?', 
					'Plt on Cell Phone', 'Pregnant', 'Prior Complaint on Animal', 'Product', 'Product Expiration', 'Product Warnings', 'Property Damage Comments', 'Rate of Pay', 'Reading Only?', 
					'Reason on Property', 'Registered Owner', 'Rest Break', 'Seatbelt', 'Smoker', 'State of Use', 'Summary of Medical Review', 'Surface Conditions', 'Suspected Abuse', 'Suspected Malpractice', 
					'Tested for Rabies?', 'Throat Swelling', 'To Whom was it Reported', 'Total Class Members', 'Type Mass Tort Claim?', 'Type of Accident', 'Type of Damage', 'Type of Shoes Worn', 
					'Under the Effects Of?', 'Unlawful Wage Deductions', 'Unreimbursed Expenses', 'Warnings', 'What Did You Slip On?', 'What Kind?', 'Where Did It Come From?', 'Where is Product Now')
GO

ALTER TABLE sma_trn_udfvalues ENABLE TRIGGER ALL
GO
