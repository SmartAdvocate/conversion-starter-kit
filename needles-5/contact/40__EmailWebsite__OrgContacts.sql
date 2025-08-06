use [BenAbbot_SA]
go

/*
alter table [sma_MST_EmailWebsite] disable trigger all
delete from [sma_MST_EmailWebsite] 
DBCC CHECKIDENT ('[sma_MST_EmailWebsite]', RESEED, 0);
alter table [sma_MST_EmailWebsite] enable trigger all
*/

---
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
		C.connContactCtg  as cewnContactCtgID,
		C.connContactID	  as cewnContactID,
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
	join sma_MST_OrgContacts C
		on C.source_id = CONVERT(VARCHAR(50), oa.namesId)
	left join BenAbbot_Needles..online_account_category oac
		on oac.id = oa.onlineaccountcategoryid
	where
		ISNULL(oa.account, '') <> ''

---
alter table [sma_MST_EmailWebsite] enable trigger all
go
 