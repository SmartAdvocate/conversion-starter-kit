use [BenAbbot_SA]
go


alter table [sma_MST_EmailWebsite] disable trigger all
go


insert into [sma_MST_EmailWebsite]
	(
		[cewnContactCtgID],
		[cewnContactID],
		[cewsEmailWebsiteFlag],
		[cewsEmailWebSite],
		[cewbDefault],
		[cewnRecUserID],
		[cewdDtCreated],
		[cewnModifyUserID],
		[cewdDtModified],
		[cewnLevelNo],
		[cewnComments],
		[saga],
		[source_id],
		[source_db],
		[source_ref]
	)
	select
		C.cinnContactCtg  as cewnContactCtgID,
		C.cinnContactID	  as cewnContactID,
		'E'				  as cewsEmailWebsiteFlag,
		oa.account		  as cewsEmailWebSite,
		case
			when [sort_order] = 0
				then 1
			else 0
		end				  as cewbDefault,
		368				  as cewnRecUserID,
		GETDATE()		  as cewdDtCreated,
		368				  as cewnModifyUserID,
		GETDATE()		  as cewdDtModified,
		null,
		ISNULL('Type: ' + NULLIF(CONVERT(VARCHAR, oac.title), '') + CHAR(13), '') +
		''				  as [cewnComments],
		1				  as saga, -- indicate email
		oa.id			  as [source_id],
		'needles'		  as [source_db],
		'online_accounts' as [source_ref]
	from [BenAbbot_Needles].[dbo].[online_accounts] oa
	join [sma_MST_IndvContacts] C
		on C.source_id = CONVERT(VARCHAR(50), oa.namesId)
	left join BenAbbot_Needles..online_account_category oac
		on oac.id = oa.onlineaccountcategoryid
	where
		ISNULL(oa.account, '') <> ''


------------------------------
--INSERT EMAIL FOR STAFF
------------------------------
insert into [sma_MST_EmailWebsite]
	(
		[cewnContactCtgID],
		[cewnContactID],
		[cewsEmailWebsiteFlag],
		[cewsEmailWebSite],
		[cewbDefault],
		[cewnRecUserID],
		[cewdDtCreated],
		[cewnModifyUserID],
		[cewdDtModified],
		[cewnLevelNo],
		[cewnComments],
		[saga],
		[source_id],
		[source_db],
		[source_ref]
	)
	select
		C.cinnContactCtg  as cewnContactCtgID,
		C.cinnContactID	  as cewnContactID,
		'E'				  as cewsEmailWebsiteFlag,
		N.email			  as cewsEmailWebSite,
		1				  as cewbDefault,
		368				  as cewnRecUserID,
		GETDATE()		  as cewdDtCreated,
		368				  as cewnModifyUserID,
		GETDATE()		  as cewdDtModified,
		null,
		--isnull('Type: ' + nullif(convert(varchar,n.[type]),'') + CHAR(13),'') +
		''				  as [cewnComments],
		1				  as saga, -- indicate email
		n.id			  as [source_id],
		'needles'		  as [source_db],
		'staff' as [source_ref]
	--select *
	from [BenAbbot_Needles].[dbo].[staff] N
	join [sma_MST_IndvContacts] C
		on C.source_id = CONVERT(VARCHAR(50), N.id)
	where
		ISNULL(email, '') <> ''
