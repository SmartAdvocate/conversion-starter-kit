/*---
description: Insert Users

steps: >
  - Disable triggers on [sma_MST_ContactNumbers]
  - Add breadcrumb columns to [sma_MST_ContactNumbers]
  - Insert Office Phone from [names].[home_phone]
  - Insert HQ/Main Office Phone from [names].[work_phone]
  - Insert Cell Phone from [names].[car_phone]
  - Insert Office Fax from [names].[fax_number]
  - Insert HQ/Main Office Fax from [names].[beeper_number]
  - Insert Other Phones from [names].[other_phone1]
  - Insert Other Phones from [names].[other_phone2]
  - Insert Other Phones from [names].[other_phone3]
  - Insert Other Phones from [names].[other_phone4]
  - Insert Other Phones from [names].[other_phone5]
  - Set the first contact number (by cnnnContactNumberID) as primary (cnnbPrimary = 1). All others are set to cnnbPrimary = 0.
  - Enable triggers on [sma_MST_ContactNumbers]

dependencies:
  - \conversion\1_contact\01__IndvContacts__names.sql
  - \conversion\1_contact\20__Address__IndvContacts.sql

notes: >
  - [saga] = names.names_id
  - [source_id] = null
  - [source_db] = 'needles'
  - [source_ref] = 'names'
  
---*/

use [SA]
go


---
alter table [sma_MST_ContactNumbers] disable trigger all
go

exec AddBreadcrumbsToTable 'sma_MST_ContactNumbers';
---


/* ------------------------------------------------------------------------------
Office Phone
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
		[saga],
		[source_id],
		[source_db],
		[source_ref]
	) select
		c.connContactCtg			as cnnncontactctgid,
		c.connContactID				as cnnncontactid,
		(
		 select
			 ctynContactNoTypeID
		 from sma_MST_ContactNoType
		 where ctysDscrptn = 'Office Phone'
			 and ctynContactCategoryID = 2
		)							as cnnnphonetypeid,
		dbo.FormatPhone(home_phone) as cnnscontactnumber,
		home_ext					as cnnsextension,
		1							as cnnbprimary,
		null						as cnnbvisible,
		a.addnAddressID				as cnnnaddressid,
		'Home'						as cnnslabelcaption,
		368							as cnnnrecuserid,
		GETDATE()					as cnnddtcreated,
		368							as cnnnmodifyuserid,
		GETDATE()					as cnnddtmodified,
		null						as cnnnlevelno,
		null						as caseno,
		n.names_id					as [saga],
		null						as [source_id],
		'needles'					as [source_db],
		'names.home_phone'			as [source_ref]
	from [Needles].[dbo].[names] n
	join [sma_MST_OrgContacts] c
		on c.saga = n.names_id
	join [sma_MST_Address] a
		on a.addnContactID = c.connContactID
			and a.addnContactCtgID = c.connContactCtg
			and a.addbPrimary = 1
	where
		ISNULL(home_phone, '') <> ''

/* ------------------------------------------------------------------------------
HQ/Main Office Phone
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
		[saga],
		[source_id],
		[source_db],
		[source_ref]
	) select
		c.connContactCtg			as cnnncontactctgid,
		c.connContactID				as cnnncontactid,
		(
		 select
			 ctynContactNoTypeID
		 from sma_MST_ContactNoType
		 where ctysDscrptn = 'HQ/Main Office Phone'
			 and ctynContactCategoryID = 2
		)							as cnnnphonetypeid,   -- Office Phone 
		dbo.FormatPhone(work_phone) as cnnscontactnumber,
		work_extension				as cnnsextension,
		1							as cnnbprimary,
		null						as cnnbvisible,
		a.addnAddressID				as cnnnaddressid,
		'Business'					as cnnslabelcaption,
		368							as cnnnrecuserid,
		GETDATE()					as cnnddtcreated,
		368							as cnnnmodifyuserid,
		GETDATE()					as cnnddtmodified,
		null,
		null						as caseno,
		n.names_id					as [saga],
		null						as [source_id],
		'needles'					as [source_db],
		'names.work_phone'			as [source_ref]
	from [Needles]..[names] n
	join [sma_MST_OrgContacts] c
		on c.saga = n.names_id
	join [sma_MST_Address] a
		on a.addnContactID = c.connContactID
			and a.addnContactCtgID = c.connContactCtg
			and a.addbPrimary = 1
	where
		ISNULL(work_phone, '') <> ''

/* ------------------------------------------------------------------------------
Cell Phone
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
		[saga],
		[source_id],
		[source_db],
		[source_ref]
	) select
		c.connContactCtg		   as cnnncontactctgid,
		c.connContactID			   as cnnncontactid,
		(
		 select
			 ctynContactNoTypeID
		 from sma_MST_ContactNoType
		 where ctysDscrptn = 'Cell'
			 and ctynContactCategoryID = 2
		)						   as cnnnphonetypeid,   -- Office Phone 
		dbo.FormatPhone(car_phone) as cnnscontactnumber,
		car_ext					   as cnnsextension,
		1						   as cnnbprimary,
		null					   as cnnbvisible,
		a.addnAddressID			   as cnnnaddressid,
		'Mobile'				   as cnnslabelcaption,
		368						   as cnnnrecuserid,
		GETDATE()				   as cnnddtcreated,
		368						   as cnnnmodifyuserid,
		GETDATE()				   as cnnddtmodified,
		null,
		null					   as caseno,
		n.names_id				   as [saga],
		null					   as [source_id],
		'needles'				   as [source_db],
		'names.car_phone'		   as [source_ref]
	from [Needles].[dbo].[names] n
	join [sma_MST_OrgContacts] c
		on c.saga = n.names_id
	join [sma_MST_Address] a
		on a.addnContactID = c.connContactID
			and a.addnContactCtgID = c.connContactCtg
			and a.addbPrimary = 1
	where
		ISNULL(car_phone, '') <> ''

/* ------------------------------------------------------------------------------
Office Fax
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
		[saga],
		[source_id],
		[source_db],
		[source_ref]
	) select
		c.connContactCtg			as cnnncontactctgid,
		c.connContactID				as cnnncontactid,
		(
		 select
			 ctynContactNoTypeID
		 from sma_MST_ContactNoType
		 where ctysDscrptn = 'Office Fax'
			 and ctynContactCategoryID = 2
		)							as cnnnphonetypeid,   -- Office Phone 
		dbo.FormatPhone(fax_number) as cnnscontactnumber,
		fax_ext						as cnnsextension,
		1							as cnnbprimary,
		null						as cnnbvisible,
		a.addnAddressID				as cnnnaddressid,
		'Fax'						as cnnslabelcaption,
		368							as cnnnrecuserid,
		GETDATE()					as cnnddtcreated,
		368							as cnnnmodifyuserid,
		GETDATE()					as cnnddtmodified,
		null,
		null						as caseno,
		n.names_id					as [saga],
		null						as [source_id],
		'needles'					as [source_db],
		'names.fax_number'			as [source_ref]
	from [Needles].[dbo].[names] n
	join [sma_MST_OrgContacts] c
		on c.saga = n.names_id
	join [sma_MST_Address] a
		on a.addnContactID = c.connContactID
			and a.addnContactCtgID = c.connContactCtg
			and a.addbPrimary = 1
	where
		ISNULL(fax_number, '') <> ''

/* ------------------------------------------------------------------------------
HQ/Main Office Fax
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
		[saga],
		[source_id],
		[source_db],
		[source_ref]
	) select
		c.connContactCtg			   as cnnncontactctgid,
		c.connContactID				   as cnnncontactid,
		(
		 select
			 ctynContactNoTypeID
		 from sma_MST_ContactNoType
		 where ctysDscrptn = 'HQ/Main Office Fax'
			 and ctynContactCategoryID = 2
		)							   as cnnnphonetypeid,   -- Office Phone 
		dbo.FormatPhone(beeper_number) as cnnscontactnumber,
		beeper_ext					   as cnnsextension,
		1							   as cnnbprimary,
		null						   as cnnbvisible,
		a.addnAddressID				   as cnnnaddressid,
		'Pager'						   as cnnslabelcaption,
		368							   as cnnnrecuserid,
		GETDATE()					   as cnnddtcreated,
		368							   as cnnnmodifyuserid,
		GETDATE()					   as cnnddtmodified,
		null,
		null						   as caseno,
		n.names_id					   as [saga],
		null						   as [source_id],
		'needles'					   as [source_db],
		'names.beeper_number'		   as [source_ref]
	from [Needles].[dbo].[names] n
	join [sma_MST_OrgContacts] c
		on c.saga = n.names_id
	join [sma_MST_Address] a
		on a.addnContactID = c.connContactID
			and a.addnContactCtgID = c.connContactCtg
			and a.addbPrimary = 1
	where
		ISNULL(beeper_number, '') <> ''

/* ------------------------------------------------------------------------------
Other 1
*/ ------------------------------------------------------------------------------
insert into [dbo].[sma_MST_ContactNumbers]
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
	) select
		c.connContactCtg			  as cnnncontactctgid,
		c.connContactID				  as cnnncontactid,
		(
		 select
			 ctynContactNoTypeID
		 from sma_MST_ContactNoType
		 where ctysDscrptn = 'Office Phone'
			 and ctynContactCategoryID = 2
		)							  as cnnnphonetypeid,   -- Office Phone 
		dbo.FormatPhone(other_phone1) as cnnscontactnumber,
		other1_ext					  as cnnsextension,
		0							  as cnnbprimary,
		null						  as cnnbvisible,
		a.addnAddressID				  as cnnnaddressid,
		phone_title1				  as cnnslabelcaption,
		368							  as cnnnrecuserid,
		GETDATE()					  as cnnddtcreated,
		368							  as cnnnmodifyuserid,
		GETDATE()					  as cnnddtmodified,
		null,
		null						  as caseno,
		n.names_id					  as [saga],
		null						  as [source_id],
		'needles'					  as [source_db],
		'names.other_phone1'		  as [source_ref]
	from [Needles].[dbo].[names] n
	join [sma_MST_OrgContacts] c
		on c.saga = n.names_id
	join [sma_MST_Address] a
		on a.addnContactID = c.connContactID
			and a.addnContactCtgID = c.connContactCtg
			and a.addbPrimary = 1
	where
		ISNULL(other_phone1, '') <> ''

/* ------------------------------------------------------------------------------
Other 2
*/ ------------------------------------------------------------------------------
insert into [dbo].[sma_MST_ContactNumbers]
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
	) select
		c.connContactCtg			  as cnnncontactctgid,
		c.connContactID				  as cnnncontactid,
		(
		 select
			 ctynContactNoTypeID
		 from sma_MST_ContactNoType
		 where ctysDscrptn = 'Office Phone'
			 and ctynContactCategoryID = 2
		)							  as cnnnphonetypeid,   -- Office Phone 
		dbo.FormatPhone(other_phone2) as cnnscontactnumber,
		other2_ext					  as cnnsextension,
		0							  as cnnbprimary,
		null						  as cnnbvisible,
		a.addnAddressID				  as cnnnaddressid,
		phone_title2				  as cnnslabelcaption,
		368							  as cnnnrecuserid,
		GETDATE()					  as cnnddtcreated,
		368							  as cnnnmodifyuserid,
		GETDATE()					  as cnnddtmodified,
		null,
		null						  as caseno,
		n.names_id					  as [saga],
		null						  as [source_id],
		'needles'					  as [source_db],
		'names.other_phone2'		  as [source_ref]
	from [Needles].[dbo].[names] n
	join [sma_MST_OrgContacts] c
		on c.saga = n.names_id
	join [sma_MST_Address] a
		on a.addnContactID = c.connContactID
			and a.addnContactCtgID = c.connContactCtg
			and a.addbPrimary = 1
	where
		ISNULL(other_phone2, '') <> ''

/* ------------------------------------------------------------------------------
Other 3
*/ ------------------------------------------------------------------------------
insert into [dbo].[sma_MST_ContactNumbers]
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
	) select
		c.connContactCtg			  as cnnncontactctgid,
		c.connContactID				  as cnnncontactid,
		(
		 select
			 ctynContactNoTypeID
		 from sma_MST_ContactNoType
		 where ctysDscrptn = 'Office Phone'
			 and ctynContactCategoryID = 2
		)							  as cnnnphonetypeid,   -- Office Phone 
		dbo.FormatPhone(other_phone3) as cnnscontactnumber,
		other3_ext					  as cnnsextension,
		0							  as cnnbprimary,
		null						  as cnnbvisible,
		a.addnAddressID				  as cnnnaddressid,
		phone_title3				  as cnnslabelcaption,
		368							  as cnnnrecuserid,
		GETDATE()					  as cnnddtcreated,
		368							  as cnnnmodifyuserid,
		GETDATE()					  as cnnddtmodified,
		null,
		null						  as caseno,
		n.names_id					  as [saga],
		null						  as [source_id],
		'needles'					  as [source_db],
		'names.other_phone3'		  as [source_ref]
	from [Needles].[dbo].[names] n
	join [sma_MST_OrgContacts] c
		on c.saga = n.names_id
	join [sma_MST_Address] a
		on a.addnContactID = c.connContactID
			and a.addnContactCtgID = c.connContactCtg
			and a.addbPrimary = 1
	where
		ISNULL(other_phone3, '') <> ''

/* ------------------------------------------------------------------------------
Other 4
*/ ------------------------------------------------------------------------------
insert into [dbo].[sma_MST_ContactNumbers]
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
	) select
		c.connContactCtg			  as cnnncontactctgid,
		c.connContactID				  as cnnncontactid,
		(
		 select
			 ctynContactNoTypeID
		 from sma_MST_ContactNoType
		 where ctysDscrptn = 'Office Phone'
			 and ctynContactCategoryID = 2
		)							  as cnnnphonetypeid,   -- Office Phone 
		dbo.FormatPhone(other_phone4) as cnnscontactnumber,
		other4_ext					  as cnnsextension,
		0							  as cnnbprimary,
		null						  as cnnbvisible,
		a.addnAddressID				  as cnnnaddressid,
		phone_title4				  as cnnslabelcaption,
		368							  as cnnnrecuserid,
		GETDATE()					  as cnnddtcreated,
		368							  as cnnnmodifyuserid,
		GETDATE()					  as cnnddtmodified,
		null,
		null						  as caseno,
		n.names_id					  as [saga],
		null						  as [source_id],
		'needles'					  as [source_db],
		'names.other_phone4'		  as [source_ref]
	from [Needles].[dbo].[names] n
	join [sma_MST_OrgContacts] c
		on c.saga = n.names_id
	join [sma_MST_Address] a
		on a.addnContactID = c.connContactID
			and a.addnContactCtgID = c.connContactCtg
			and a.addbPrimary = 1
	where
		ISNULL(other_phone4, '') <> ''


/* ------------------------------------------------------------------------------
Other 5
*/ ------------------------------------------------------------------------------
insert into [dbo].[sma_MST_ContactNumbers]
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
	) select
		c.connContactCtg			  as cnnncontactctgid,
		c.connContactID				  as cnnncontactid,
		(
		 select
			 ctynContactNoTypeID
		 from sma_MST_ContactNoType
		 where ctysDscrptn = 'Office Phone'
			 and ctynContactCategoryID = 2
		)							  as cnnnphonetypeid,   -- Office Phone 
		dbo.FormatPhone(other_phone5) as cnnscontactnumber,
		other5_ext					  as cnnsextension,
		0							  as cnnbprimary,
		null						  as cnnbvisible,
		a.addnAddressID				  as cnnnaddressid,
		phone_title5				  as cnnslabelcaption,
		368							  as cnnnrecuserid,
		GETDATE()					  as cnnddtcreated,
		368							  as cnnnmodifyuserid,
		GETDATE()					  as cnnddtmodified,
		null,
		null						  as caseno,
		n.names_id					  as [saga],
		null						  as [source_id],
		'needles'					  as [source_db],
		'names.other_phone5'		  as [source_ref]
	from [Needles].[dbo].[names] n
	join [sma_MST_OrgContacts] c
		on c.saga = n.names_id
	join [sma_MST_Address] a
		on a.addnContactID = c.connContactID
			and a.addnContactCtgID = c.connContactCtg
			and a.addbPrimary = 1
	where
		ISNULL(other_phone5, '') <> ''

---
update [sma_MST_ContactNumbers]
set cnnbPrimary = 0
from (
 select
	 ROW_NUMBER() over (partition by cnnnContactID order by cnnnContactNumberID) as RowNumber,
	 cnnnContactNumberID														 as ContactNumberID
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

---
alter table [sma_MST_ContactNumbers] enable trigger all