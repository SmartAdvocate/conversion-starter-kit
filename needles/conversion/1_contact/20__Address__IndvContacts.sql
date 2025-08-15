/*---
description: Insert addresses from [IndvContacts]

steps: >
  - Disable triggers on [sma_MST_Address]
  - Add breadcrumb columns to [sma_MST_Address]
  - Insert Home addresses from [multi_addresses]
  - Insert Business addresses from [multi_addresses]
  - Insert Other addresses from [multi_addresses]
  - Enable triggers on [sma_MST_Address]

dependencies:
  - \conversion\1_contact\01__IndvContacts__names.sql

notes: >
  - [saga] = multi_addresses.names_id
  - [source_id] = null
  - [source_db] = 'needles'
  - [source_ref] = 'multi_addresses.home', 'multi_addresses.business', 'multi_addresses.other'
  
---*/

use [SA]
go


---
alter table [sma_MST_Address] disable trigger all
go

exec AddBreadcrumbsToTable 'sma_MST_Address';
---


/* ------------------------------------------------------------------------------
Home from IndvContacts
*/ ------------------------------------------------------------------------------
insert into [sma_MST_Address]
	(
		[addnContactCtgID],
		[addnContactID],
		[addnAddressTypeID],
		[addsAddressType],
		[addsAddTypeCode],
		[addsAddress1],
		[addsAddress2],
		[addsAddress3],
		[addsStateCode],
		[addsCity],
		[addnZipID],
		[addsZip],
		[addsCounty],
		[addsCountry],
		[addbIsResidence],
		[addbPrimary],
		[adddFromDate],
		[adddToDate],
		[addnCompanyID],
		[addsDepartment],
		[addsTitle],
		[addnContactPersonID],
		[addsComments],
		[addbIsCurrent],
		[addbIsMailing],
		[addnRecUserID],
		[adddDtCreated],
		[addnModifyUserID],
		[adddDtModified],
		[addnLevelNo],
		[caseno],
		[addbDeleted],
		[addsZipExtn],
		[saga],
		[source_id],
		[source_db],
		[source_ref]
	) select
		i.cinnContactCtg	   as addncontactctgid,
		i.cinnContactID		   as addncontactid,
		t.addnAddTypeID		   as addnaddresstypeid,
		t.addsDscrptn		   as addsaddresstype,
		t.addsCode			   as addsaddtypecode,
		a.[address]			   as addsaddress1,
		a.[address_2]		   as addsaddress2,
		null				   as addsaddress3,
		a.[state]			   as addsstatecode,
		a.[city]			   as addscity,
		null				   as addnzipid,
		a.[zipcode]			   as addszip,
		a.[county]			   as addscounty,
		a.[country]			   as addscountry,
		null				   as addbisresidence,
		case
			when a.[default_addr] = 'Y'
				then 1
			else 0
		end					   as addbprimary,
		null,
		null,
		null,
		null,
		null,
		null,
		case
			when ISNULL(a.company, '') <> ''
				then (
					'Company : ' + CHAR(13) + a.company
					)
			else ''
		end					   as [addscomments],
		null,
		null,
		368					   as addnrecuserid,
		GETDATE()			   as addddtcreated,
		368					   as addnmodifyuserid,
		GETDATE()			   as addddtmodified,
		null,
		null,
		null,
		null,
		a.names_id			   as [saga],
		null				   as [source_id],
		'needles'			   as [source_db],
		'multi_addresses.home' as [source_ref]
	from [Needles].[dbo].[multi_addresses] a
	join [sma_MST_Indvcontacts] i
		on i.saga = a.names_id
	join [sma_MST_AddressTypes] t
		on t.addnContactCategoryID = i.cinnContactCtg
			and t.addsCode = 'HM'
	where
		(   a.[addr_type] = 'Home'
			and
			(   ISNULL(a.[address], '') <> ''
				or
				ISNULL(a.[address_2], '') <> ''
				or
				ISNULL(a.[city], '') <> ''
				or
				ISNULL(a.[state], '') <> ''
				or
				ISNULL(a.[zipcode], '') <> ''
				or
				ISNULL(a.[county], '') <> ''
				or
				ISNULL(a.[country], '') <> ''))

/* ------------------------------------------------------------------------------
Business from IndvContacts
*/ ------------------------------------------------------------------------------
insert into [sma_MST_Address]
	(
		[addnContactCtgID],
		[addnContactID],
		[addnAddressTypeID],
		[addsAddressType],
		[addsAddTypeCode],
		[addsAddress1],
		[addsAddress2],
		[addsAddress3],
		[addsStateCode],
		[addsCity],
		[addnZipID],
		[addsZip],
		[addsCounty],
		[addsCountry],
		[addbIsResidence],
		[addbPrimary],
		[adddFromDate],
		[adddToDate],
		[addnCompanyID],
		[addsDepartment],
		[addsTitle],
		[addnContactPersonID],
		[addsComments],
		[addbIsCurrent],
		[addbIsMailing],
		[addnRecUserID],
		[adddDtCreated],
		[addnModifyUserID],
		[adddDtModified],
		[addnLevelNo],
		[caseno],
		[addbDeleted],
		[addsZipExtn],
		[saga],
		[source_id],
		[source_db],
		[source_ref]
	) select
		i.cinnContactCtg		   as addncontactctgid,
		i.cinnContactID			   as addncontactid,
		t.addnAddTypeID			   as addnaddresstypeid,
		t.addsDscrptn			   as addsaddresstype,
		t.addsCode				   as addsaddtypecode,
		a.[address]				   as addsaddress1,
		a.[address_2]			   as addsaddress2,
		null					   as addsaddress3,
		a.[state]				   as addsstatecode,
		a.[city]				   as addscity,
		null					   as addnzipid,
		a.[zipcode]				   as addszip,
		a.[county]				   as addscounty,
		a.[country]				   as addscountry,
		null					   as addbisresidence,
		case
			when a.[default_addr] = 'Y'
				then 1
			else 0
		end						   as addbprimary,
		null,
		null,
		null,
		null,
		null,
		null,
		case
			when ISNULL(a.company, '') <> ''
				then (
					'Company : ' + CHAR(13) + a.company
					)
			else ''
		end						   as [addscomments],
		null,
		null,
		368						   as addnrecuserid,
		GETDATE()				   as addddtcreated,
		368						   as addnmodifyuserid,
		GETDATE()				   as addddtmodified,
		null,
		null,
		null,
		null,
		a.names_id				   as [saga],
		null					   as [source_id],
		'needles'				   as [source_db],
		'multi_addresses.business' as [source_ref]
	from [Needles].[dbo].[multi_addresses] a
	join [sma_MST_Indvcontacts] i
		on i.saga = a.names_id
	join [sma_MST_AddressTypes] t
		on t.addnContactCategoryID = i.cinnContactCtg
			and t.addsCode = 'WORK'
	where
		(   a.[addr_type] = 'Business'
			and
			(   ISNULL(a.[address], '') <> ''
				or
				ISNULL(a.[address_2], '') <> ''
				or
				ISNULL(a.[city], '') <> ''
				or
				ISNULL(a.[state], '') <> ''
				or
				ISNULL(a.[zipcode], '') <> ''
				or
				ISNULL(a.[county], '') <> ''
				or
				ISNULL(a.[country], '') <> ''))
/* ------------------------------------------------------------------------------
Other from IndvContacts
*/ ------------------------------------------------------------------------------
insert into [sma_MST_Address]
	(
		[addnContactCtgID],
		[addnContactID],
		[addnAddressTypeID],
		[addsAddressType],
		[addsAddTypeCode],
		[addsAddress1],
		[addsAddress2],
		[addsAddress3],
		[addsStateCode],
		[addsCity],
		[addnZipID],
		[addsZip],
		[addsCounty],
		[addsCountry],
		[addbIsResidence],
		[addbPrimary],
		[adddFromDate],
		[adddToDate],
		[addnCompanyID],
		[addsDepartment],
		[addsTitle],
		[addnContactPersonID],
		[addsComments],
		[addbIsCurrent],
		[addbIsMailing],
		[addnRecUserID],
		[adddDtCreated],
		[addnModifyUserID],
		[adddDtModified],
		[addnLevelNo],
		[caseno],
		[addbDeleted],
		[addsZipExtn],
		[saga],
		[source_id],
		[source_db],
		[source_ref]
	) select
		i.cinnContactCtg		as addncontactctgid,
		i.cinnContactID			as addncontactid,
		t.addnAddTypeID			as addnaddresstypeid,
		t.addsDscrptn			as addsaddresstype,
		t.addsCode				as addsaddtypecode,
		a.[address]				as addsaddress1,
		a.[address_2]			as addsaddress2,
		null					as addsaddress3,
		a.[state]				as addsstatecode,
		a.[city]				as addscity,
		null					as addnzipid,
		a.[zipcode]				as addszip,
		a.[county]				as addscounty,
		a.[country]				as addscountry,
		null					as addbisresidence,
		case
			when a.[default_addr] = 'Y'
				then 1
			else 0
		end						as addbprimary,
		null,
		null,
		null,
		null,
		null,
		null,
		case
			when ISNULL(a.company, '') <> ''
				then (
					'Company : ' + CHAR(13) + a.company
					)
			else ''
		end						as [addscomments],
		null,
		null,
		368						as addnrecuserid,
		GETDATE()				as addddtcreated,
		368						as addnmodifyuserid,
		GETDATE()				as addddtmodified,
		null,
		null,
		null,
		null,
		a.names_id				as [saga],
		null					as [source_id],
		'needles'				as [source_db],
		'multi_addresses.other' as [source_ref]
	from [Needles].[dbo].[multi_addresses] a
	join [sma_MST_Indvcontacts] i
		on i.saga = a.names_id
	join [sma_MST_AddressTypes] t
		on t.addnContactCategoryID = i.cinnContactCtg
			and t.addsCode = 'OTH'
	where
		(   a.[addr_type] = 'Other'
			and
			(   ISNULL(a.[address], '') <> ''
				or
				ISNULL(a.[address_2], '') <> ''
				or
				ISNULL(a.[city], '') <> ''
				or
				ISNULL(a.[state], '') <> ''
				or
				ISNULL(a.[zipcode], '') <> ''
				or
				ISNULL(a.[county], '') <> ''
				or
				ISNULL(a.[country], '') <> ''))


---
alter table [sma_MST_Address] enable trigger all
go
---



------------- Check Uniqueness------------
-- select I.cinnContactID
-- 	 from [SA].[dbo].[sma_MST_Indvcontacts] I 
--	 inner join [SA].[dbo].[sma_MST_Address] A on A.addnContactID=I.cinnContactID and A.addnContactCtgID=I.cinnContactCtg and A.addbPrimary=1 
--	 group by cinnContactID
--	 having count(cinnContactID)>1

-- select O.connContactID
-- 	 from [SA].[dbo].[sma_MST_OrgContacts] O 
--	 inner join [SA].[dbo].[sma_MST_Address] A on A.addnContactID=O.connContactID and A.addnContactCtgID=O.connContactCtg and A.addbPrimary=1 
--	 group by connContactID
--	 having count(connContactID)>1

