use [BenAbbot_SA]
go

---
alter table [sma_MST_ContactNumbers] disable trigger all
---

/* ------------------------------------------------------------------------------
Home Primary Phone | Cell | HQ/Main Office | Fax
*/ ------------------------------------------------------------------------------
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
		[Comments],
		[saga],
		[source_id],
		[source_db],
		[source_ref]
	)
	select
		C.cinnContactCtg		  as cnnnContactCtgID,
		C.cinnContactID			  as cnnnContactID,
		ctynContactNoTypeID		  as cnnnPhoneTypeID,
		dbo.FormatPhone(n.number) as cnnsContactNumber,
		n.extension				  as cnnsExtension,
		case
			when n.sort_order = 1
				then 1
			else 0
		end						  as cnnbPrimary,
		null					  as cnnbVisible,
		A.addnAddressID			  as cnnnAddressID,
		ct.ctysDscrptn			  as cnnsLabelCaption,
		368						  as cnnnRecUserID,
		GETDATE()				  as cnndDtCreated,
		368						  as cnnnModifyUserID,
		GETDATE()				  as cnndDtModified,
		null,
		null,
		ISNULL('Phone Type: ' + NULLIF(CONVERT(VARCHAR, n.[title]), '') + CHAR(13), '') +
		''						  as [Comments],
		null					  as [saga],
		n.id					  as [source_id],
		'needles'				  as [source_db],
		'phone'					  as [source_ref]
	--select *
	from BenAbbot_Needles.[dbo].[phone] N
	join [sma_MST_IndvContacts] C
		on C.source_id = CONVERT(VARCHAR(50), N.namesid)
	left join sma_MST_ContactNoType ct
		on ctynContactCategoryID = 1
			and ct.ctysDscrptn = case
				when n.title = 'Mobile'
					then 'Cell'
				when n.title = 'Home'
					then 'Home Primary Phone'
				when n.title = 'Business'
					then 'HQ/Main Office Phone'
				when n.title = 'Fax'
					then 'Fax'
				else 'Other'
			end
	join [sma_MST_Address] A
		on A.addnContactID = C.cinnContactID
			and A.addnContactCtgID = C.cinnContactCtg
			and A.addbPrimary = 1
	where
		ISNULL(N.number, '') <> ''

/* ------------------------------------------------------------------------------
STAFF MAIN NUMBER
*/ ------------------------------------------------------------------------------
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
		[Comments],
		[saga],
		[source_id],
		[source_db],
		[source_ref]
	)
	select
		C.cinnContactCtg				as cnnnContactCtgID,
		C.cinnContactID					as cnnnContactID,
		ctynContactNoTypeID				as cnnnPhoneTypeID,
		dbo.FormatPhone(n.phone_number) as cnnsContactNumber,
		null							as cnnsExtension,
		1								as cnnbPrimary,
		null							as cnnbVisible,
		A.addnAddressID					as cnnnAddressID,
		ct.ctysDscrptn					as cnnsLabelCaption,
		368								as cnnnRecUserID,
		GETDATE()						as cnndDtCreated,
		368								as cnnnModifyUserID,
		GETDATE()						as cnndDtModified,
		null,
		null,
		--isnull('Phone Type: ' + nullif(convert(varchar,n.[title]),'') + CHAR(13),'') +
		''								as [Comments],
		null							as [saga],
		n.id							as [source_id],
		'needles'						as [source_db],
		'staff.phone_number'			as [source_ref]
	--select *
	from [BenAbbot_Needles].[dbo].[staff] N
	join [sma_MST_IndvContacts] C
		on C.source_id = CONVERT(VARCHAR(50), N.id)
	left join sma_MST_ContactNoType ct
		on ctynContactCategoryID = 1
			and ct.ctysDscrptn = 'HQ/Main Office Phone'
	join [sma_MST_Address] A
		on A.addnContactID = C.cinnContactID
			and A.addnContactCtgID = C.cinnContactCtg
			and A.addbPrimary = 1
	where
		ISNULL(N.phone_number, '') <> ''



/* ------------------------------------------------------------------------------
STAFF FAX NUMBER
*/ ------------------------------------------------------------------------------
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
		[Comments],
		[saga],
		[source_id],
		[source_db],
		[source_ref]
	)
	select
		C.cinnContactCtg			  as cnnnContactCtgID,
		C.cinnContactID				  as cnnnContactID,
		ctynContactNoTypeID			  as cnnnPhoneTypeID,
		dbo.FormatPhone(n.fax_number) as cnnsContactNumber,
		null						  as cnnsExtension,
		1							  as cnnbPrimary,
		null						  as cnnbVisible,
		A.addnAddressID				  as cnnnAddressID,
		ct.ctysDscrptn				  as cnnsLabelCaption,
		368							  as cnnnRecUserID,
		GETDATE()					  as cnndDtCreated,
		368							  as cnnnModifyUserID,
		GETDATE()					  as cnndDtModified,
		null,
		null,
		--isnull('Phone Type: ' + nullif(convert(varchar,n.[title]),'') + CHAR(13),'') +
		''							  as [Comments],
		null						  as [saga],
		n.id						  as [source_id],
		'needles'					  as [source_db],
		'staff.fax_number'			  as [source_ref]
	--select *
	from [BenAbbot_Needles].[dbo].[staff] N
	join [sma_MST_IndvContacts] C
		on C.source_id = CONVERT(VARCHAR(50), N.id)
	left join sma_MST_ContactNoType ct
		on ctynContactCategoryID = 1
			and ct.ctysDscrptn = 'Fax'
	join [sma_MST_Address] A
		on A.addnContactID = C.cinnContactID
			and A.addnContactCtgID = C.cinnContactCtg
			and A.addbPrimary = 1
	where
		ISNULL(N.fax_number, '') <> ''


/* ------------------------------------------------------------------------------
STAFF MOBILE NUMBER
*/ ------------------------------------------------------------------------------
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
		[Comments],
		[saga],
		[source_id],
		[source_db],
		[source_ref]
	)
	select
		C.cinnContactCtg				 as cnnnContactCtgID,
		C.cinnContactID					 as cnnnContactID,
		ctynContactNoTypeID				 as cnnnPhoneTypeID,
		dbo.FormatPhone(n.mobile_number) as cnnsContactNumber,
		null							 as cnnsExtension,
		1								 as cnnbPrimary,
		null							 as cnnbVisible,
		A.addnAddressID					 as cnnnAddressID,
		ct.ctysDscrptn					 as cnnsLabelCaption,
		368								 as cnnnRecUserID,
		GETDATE()						 as cnndDtCreated,
		368								 as cnnnModifyUserID,
		GETDATE()						 as cnndDtModified,
		null,
		null,
		--isnull('Phone Type: ' + nullif(convert(varchar,n.[title]),'') + CHAR(13),'') +
		''								 as [Comments],
		null							 as [saga],
		n.id							 as [source_id],
		'needles'						 as [source_db],
		'staff.mobile_number'			 as [source_ref]
	--select *
	from [BenAbbot_Needles].[dbo].[staff] N
	join [sma_MST_IndvContacts] C
		on C.source_id = CONVERT(VARCHAR(50), N.id)
	left join sma_MST_ContactNoType ct
		on ctynContactCategoryID = 1
			and ct.ctysDscrptn = 'Cell'
	join [sma_MST_Address] A
		on A.addnContactID = C.cinnContactID
			and A.addnContactCtgID = C.cinnContactCtg
			and A.addbPrimary = 1
	where
		ISNULL(N.mobile_number, '') <> ''

--update [sma_MST_ContactNumbers]
--set cnnbPrimary = 0
--from (
--	select
--		ROW_NUMBER() over (partition by cnnnContactID order by cnnnContactNumberID) as rownumber,
--		cnnnContactNumberID															as contactnumberid
--	from [sma_MST_ContactNumbers]
--	where cnnnContactCtgID = (
--			select
--				ctgnCategoryID
--			from [dbo].[sma_MST_ContactCtg]
--			where ctgsDesc = 'Individual'
--		)
--) a
--where a.rownumber <> 1
--and a.contactnumberid = cnnnContactNumberID


alter table [sma_MST_ContactNumbers] enable trigger all