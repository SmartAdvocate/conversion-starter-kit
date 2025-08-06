use [BenAbbot_SA]
go


---
alter table [sma_MST_ContactNumbers] disable trigger all
---

------------------------------------
--ORG CONTACT PHONE NUMBERS 
------------------------------------
insert into [sma_MST_ContactNumbers]
	(
		[cnnnContactCtgID],
		[cnnnContactID],
		[cnnnPhoneTypeID],
		[cnnsContactNumber],
		[cnnsExtension],
		[cnnbPrimary],
		[cnnbVisible],
		[cnnnAddressID],
		[cnnsLabelCaption],
		[cnnnRecUserID],
		[cnndDtCreated],
		[cnnnModifyUserID],
		[cnndDtModified],
		[cnnnLevelNo],
		[caseNo],
		[saga],
		[source_id],
		[source_db],
		[source_ref]
	)
	select
		C.connContactCtg		  as cnnnContactCtgID,
		C.connContactID			  as cnnnContactID,
		ctynContactNoTypeID		  as cnnnPhoneTypeID,   -- Office Phone 
		dbo.FormatPhone(n.number) as cnnsContactNumber,
		null					  as cnnsExtension,
		case
			when n.sort_order = 1
				then 1
			else 0
		end						  as cnnbPrimary,
		null					  as cnnbVisible,
		A.addnAddressID			  as cnnnAddressID,
		ct.ctysDscrptn			  as cnnsLabelCaption,
		368						  as cnnnRecUserID,
		null					  as cnndDtCreated,
		368						  as cnnnModifyUserID,
		GETDATE()				  as cnndDtModified,
		null					  as [cnnnLevelNo],
		null					  as [caseNo],
		null					  as [saga],
		n.id					  as [source_id],
		'needles'				  as [source_db],
		'phone'					  as [source_ref]
	from [BenAbbot_Needles].[dbo].[phone] N
	join [sma_MST_OrgContacts] C
		on C.source_id = CONVERT(VARCHAR(50), N.namesid)
	left join sma_MST_ContactNoType ct
		on ctynContactCategoryID = 2
			and ct.ctysDscrptn = case
				when n.title = 'Mobile'
					then 'Cell'
				when n.title = 'Home'
					then 'Home Phone'
				when n.title = 'Business'
					then 'Office Phone'
				when n.title = 'Fax'
					then 'Office Fax'
				else 'Other'
			end
	join [sma_MST_Address] A
		on A.addnContactID = C.connContactID
			and A.addnContactCtgID = C.connContactCtg
			and A.addbPrimary = 1
	where
		ISNULL(n.number, '') <> ''


update [sma_MST_ContactNumbers]
set cnnbPrimary = 0
from (
	select
		ROW_NUMBER() over (partition by cnnnContactID order by cnnnContactNumberID) as RowNumber,
		cnnnContactNumberID															as ContactNumberID
	from [sma_MST_ContactNumbers]
	where cnnnContactCtgID = (
			select
				ctgnCategoryID
			from [dbo].[sma_MST_ContactCtg]
			where ctgsDesc = 'Organization'
		)
) A
where A.RowNumber <> 1
and A.ContactNumberID = cnnnContactNumberID

alter table [sma_MST_ContactNumbers] enable trigger all