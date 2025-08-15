/*
user_party_data.Contact_Person
*/

use Skolrood_SA
go

select top 5
	stc.casnCaseID,
	stc.cassCaseNumber,
	upd.case_id,
	upd.party_id,
	ioci.SAGA,
	ioci.CID,
	ioci.Name,
	upd.Contact_Person,
	upd.Relationship_to_Plaintiff
from Skolrood_Needles..user_party_data upd
join sma_TRN_Cases stc
	on stc.cassCaseNumber = CONVERT(VARCHAR, upd.case_id)
join IndvOrgContacts_Indexed ioci
	on upd.party_id = ioci.SAGA
		and ioci.CTG = 1
join sma_TRN_Plaintiff stp
	on stp.plnnContactID = ioci.CID
		and stp.plnnContactCtg = ioci.CTG
		and stp.plnbIsPrimary = 1
where
	ISNULL(upd.Contact_Person, '') <> ''
	and ISNULL(upd.Relationship_to_Plaintiff, '') <> ''
	and stc.casdClosingDate is null

/* ------------------------------------------------------------------------------
[sma_MST_OtherCasesContact] schema
*/

-- saga
if not exists (
		select
			*
		from sys.columns
		where Name = N'saga'
			and Object_ID = OBJECT_ID(N'sma_MST_OtherCasesContact')
	)
begin
	alter table [sma_MST_OtherCasesContact] add [saga] INT null;
end

go

-- source_id
if not exists (
		select
			*
		from sys.columns
		where Name = N'source_id'
			and Object_ID = OBJECT_ID(N'sma_MST_OtherCasesContact')
	)
begin
	alter table [sma_MST_OtherCasesContact] add [source_id] VARCHAR(MAX) null;
end

go

-- source_db
if not exists (
		select
			*
		from sys.columns
		where Name = N'source_db'
			and Object_ID = OBJECT_ID(N'sma_MST_OtherCasesContact')
	)
begin
	alter table [sma_MST_OtherCasesContact] add [source_db] VARCHAR(MAX) null;
end

go

-- source_ref
if not exists (
		select
			*
		from sys.columns
		where Name = N'source_ref'
			and Object_ID = OBJECT_ID(N'sma_MST_OtherCasesContact')
	)
begin
	alter table [sma_MST_OtherCasesContact] add [source_ref] VARCHAR(MAX) null;
end

go


/* ------------------------------------------------------------------------------
Create All Contact records
*/

alter table [sma_MST_OtherCasesContact] disable trigger all
go

insert into [sma_MST_OtherCasesContact]
	(
		[OtherCasesID],
		[OtherCasesContactID],
		[OtherCasesContactCtgID],
		[OtherCaseContactAddressID],
		[OtherCasesContactRole],
		[OtherCasesCreatedUserID],
		[OtherCasesContactCreatedDt],
		[OtherCasesModifyUserID],
		[OtherCasesContactModifieddt],
		[saga],
		[source_id],
		[source_db],
		[source_ref]
	)
	select distinct
		cas.casnCaseID					 as [OtherCasesID],
		ioc.CID							 as [OtherCasesContactID],
		ioc.CTG							 as [OtherCasesContactCtgID],
		ioc.AID							 as [OtherCaseContactAddressID],
		ud.Relationship_to_Plaintiff	 as [OtherCasesContactRole],
		368								 as [OtherCasesCreatedUserID],
		GETDATE()						 as [OtherCasesContactCreatedDt],
		null							 as [OtherCasesModifyUserID],
		null							 as [OtherCasesContactModifieddt],
		null							 as [saga],
		ud.Contact_Person				 as [source_id],
		'needles'						 as [source_db],
		'user_party_data.Contact_Person' as [source_ref]
	--select *
	from Skolrood_Needles.[dbo].user_party_data ud
	join sma_TRN_Cases cas
		on cas.cassCaseNumber = CONVERT(VARCHAR, ud.case_id)
	-- Make sure we have the right plaintiff (ud.party_id)
	join IndvOrgContacts_Indexed ioci
		on ud.party_id = ioci.SAGA
			and ioci.CTG = 1
	join sma_TRN_Plaintiff stp
		on stp.plnnContactID = ioci.CID
			and stp.plnnContactCtg = ioci.CTG
			and stp.plnbIsPrimary = 1
	-- get the contact for Contact_Person
	-- see D:\skolrood\needles\conv\1_contact\1.07_contact_indv_ContactPerson.sql
	join IndvOrgContacts_Indexed ioc
		on ioc.source_id = ud.Contact_Person
			and ioc.source_ref = 'user_party_data.Contact_Person'
			and ioc.CTG = 1
	where
		ISNULL(ud.Contact_Person, '') <> ''
go

alter table [sma_MST_OtherCasesContact] enable trigger all
go

/* ------------------------------------------------------------------------------
Insert comment
*/
                
-- INSERT INTO [sma_TRN_CaseContactComment]
-- (
-- 	[CaseContactCaseID]
-- 	,[CaseRelContactID]
-- 	,[CaseRelContactCtgID]
-- 	,[CaseContactComment]
-- 	,[CaseContactCreaatedBy]
-- 	,[CaseContactCreateddt]
-- 	,[caseContactModifyBy]
-- 	,[CaseContactModifiedDt]
-- )
-- SELECT
-- 	cas.casnCaseID	as [CaseContactCaseID]
-- 	,ioc.CID		as [CaseRelContactID]
-- 	,ioc.CTG		as [CaseRelContactCtgID]
-- 	,isnull(('Spouse: '+ nullif(convert(varchar(max),ud.spouse),'')+char(13)),'') +
-- 	isnull(('Alternate Contact: '+ nullif(convert(varchar(max),ud.Alternate_Contact),'')+char(13)),'') +
-- 	isnull(('Contact Relationship: '+ nullif(convert(varchar(max),ud.Contact_Relationship),'')+char(13)),'') +
-- 	''				as [CaseContactComment]
-- 	,368			as [CaseContactCreaatedBy]
-- 	,getdate()		as [CaseContactCreateddt]
-- 	,null			as [caseContactModifyBy]
-- 	,null			as [CaseContactModifiedDt]
-- FROM Skolrood_Needles.[dbo].user_party_data ud
-- join sma_TRN_Cases cas
-- 	on cas.cassCaseNumber = ud.case_id
-- join Skolrood_Needles..names n
-- 	on n.names_id = ud.party_id
-- join IndvOrgContacts_Indexed ioc
-- 	on ioc.SAGA = n.names_id
-- where isnull(ud.Spouse,'') <> '' or isnull(ud.Alternate_Contact,'') <> '' or isnull(ud.Contact_Relationship,'') <> ''
