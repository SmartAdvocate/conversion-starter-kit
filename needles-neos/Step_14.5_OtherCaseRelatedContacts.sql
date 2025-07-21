use [SAbilleasterlyLaw]
go

alter table sma_MST_OtherCasesContact disable trigger all
delete from sma_MST_OtherCasesContact 
DBCC CHECKIDENT ('sma_MST_OtherCasesContact ', RESEED, 0); 
alter table sma_MST_OtherCasesContact  enable trigger all

INSERT sma_MST_OtherCasesContact 
( 
		OtherCasesID, 
		OtherCasesContactID, 
		OtherCasesContactCtgID, 
		OtherCaseContactAddressID, 
		OtherCasesContactRole, 
		OtherCasesCreatedUserID, 
		OtherCasesContactCreatedDt
)
SELECT DISTINCT
		cas.casnCaseID			as OtherCasesID, 
		ioc.CID					as OtherCasesContactID, 
		ioc.CTG					as OtherCasesContactCtgID, 
		ioc.AID					as OtherCaseContactAddressID, 
		PR.role			as OtherCasesContactRole, 
		368						as OtherCasesCreatedUserID, 
		NULL 					as OtherCasesContactCreatedDt
 FROM  [NeosBillEasterly].[dbo].[party_Indexed] P 
JOIN  [NeosBillEasterly].[dbo].[party_role_list] PR on pr.id = p.[partyrolelistid]
JOIN [sma_TRN_Cases] CAS on CAS.Neos_Saga = convert(varchar(50),p.casesid)
JOIN IndvOrgContacts_Indexed IOC on IOC.SAGA_ref = convert(varchar(50),P.namesid)
WHERE Pr.[role] in
(
     'Parent',
    'Guardian',
    'Spouse',
    'Interpreter',
    'Staff',
    'Lien Holder',
    'Other',
    'Subrogation Carrier',
    'Conservator',
    'Witness',
    'Mediator',
    'Office Matter',
    'Administrator',
    'Trustee'
)