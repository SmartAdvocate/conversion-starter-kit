use  [SAbilleasterlyLaw]
go

/*select  * from  [sma_MST_EmailWebsite]       ------ At initial, it shuld be empty
select *from  [NeosBillEasterly].[dbo].[staff] where isnull(email, '')<>''       */

/*alter table  [sma_MST_EmailWebsite] disable trigger all
delete from  [sma_MST_EmailWebsite] 
DBCC CHECKIDENT ('[sma_MST_EmailWebsite]', RESEED, 0);
alter table  [sma_MST_EmailWebsite] enable trigger all   */

 INSERT INTO [sma_MST_EmailWebsite]
  ( [cewnContactCtgID],[cewnContactID],[cewsEmailWebsiteFlag],[cewsEmailWebSite],[cewbDefault],[cewnRecUserID],[cewdDtCreated],[cewnModifyUserID],[cewdDtModified],[cewnLevelNo],[saga],[cewnComments] )
SELECT 
		C.cinnContactCtg	as cewnContactCtgID,
		C.cinnContactID		as cewnContactID,
		'E'					as cewsEmailWebsiteFlag,
		N.email				as cewsEmailWebSite,
		1					as cewbDefault,
		368					as cewnRecUserID,
		getdate()			as cewdDtCreated,
		368					as cewnModifyUserID,
		getdate()			as cewdDtModified,
		null,
		1					as saga, -- indicate email
		--isnull('Type: ' + nullif(convert(varchar,n.[type]),'') + CHAR(13),'') +
		''					as [cewnComments] 
--select *
FROM  [NeosBillEasterly].[dbo].[staff] N
JOIN [sma_MST_IndvContacts] C on C.saga_ref = convert(varchar(50),N.id)
WHERE isnull(email,'') <> ''
       and email not in (select cewsEmailWebSite from sma_MST_EmailWebsite )


    -- select * from  [NeosBillEasterly]..CommunicationsEmailAddresses
   ---  select *  from [NeosBillEasterly]..names where id = '0BEA5396-23D3-4BC7-B35A-AA4600FF540D'
--------------------------------------------------------------------
 INSERT INTO [sma_MST_EmailWebsite]
  ( [cewnContactCtgID],[cewnContactID],[cewsEmailWebsiteFlag],[cewsEmailWebSite],[cewbDefault],[cewnRecUserID],[cewdDtCreated],[cewnModifyUserID],[cewdDtModified],[cewnLevelNo],[saga],[cewnComments] )
SELECT 
		C.cinnContactCtg	as cewnContactCtgID,
		C.cinnContactID		as cewnContactID,
		'E'					as cewsEmailWebsiteFlag,
		N.account			as cewsEmailWebSite,
		1					as cewbDefault,
		368					as cewnRecUserID,
		getdate()			as cewdDtCreated,
		368					as cewnModifyUserID,
		getdate()			as cewdDtModified,
		null,
		1					as saga, -- indicate email
		isnull('Type: ' + nullif(convert(varchar,n.[type]),'') + CHAR(13),'') +
		''					as [cewnComments] 
--select *
FROM  [NeosBillEasterly]..online_accounts N
JOIN [sma_MST_IndvContacts] C on C.saga_ref = convert(varchar(50),  n.namesid)
-----WHERE  n.onlineaccountcategoryid in ( 'B1176987-77FA-4A7E-AA37-AB1A01235CE7 ' , 'DE4084AE-B02A-4676-8E9F-A58A011ABE63' )


---------------
 INSERT INTO [sma_MST_EmailWebsite]
  ( [cewnContactCtgID],[cewnContactID],[cewsEmailWebsiteFlag],[cewsEmailWebSite],[cewbDefault],[cewnRecUserID],[cewdDtCreated],[cewnModifyUserID],[cewdDtModified],[cewnLevelNo],[saga],[cewnComments] )
SELECT 
		C.connContactCtg	as cewnContactCtgID,
		C.connContactID		as cewnContactID,
		'W'					as cewsEmailWebsiteFlag,
		N.account			as cewsEmailWebSite,
		1					as cewbDefault,
		368					as cewnRecUserID,
		getdate()			as cewdDtCreated,
		368					as cewnModifyUserID,
		getdate()			as cewdDtModified,
		null,
		1					as saga, -- indicate email
		isnull('Type: ' + nullif(convert(varchar,n.[type]),'') + CHAR(13),'') +
		''					as [cewnComments] 
--select *
FROM  [NeosBillEasterly]..online_accounts N
JOIN sma_MST_OrgContacts C on C.neos_saga = convert(varchar(50),  n.namesid)
----WHERE  n.onlineaccountcategoryid  = '19866382-3760-402A-81ED-A58A011ABE8C'
-------------


INSERT INTO [sma_MST_EmailWebsite]
  ( [cewnContactCtgID],[cewnContactID],[cewsEmailWebsiteFlag],[cewsEmailWebSite],[cewbDefault],[cewnRecUserID],[cewdDtCreated],[cewnModifyUserID],[cewdDtModified],[cewnLevelNo],[saga],[cewnComments] )
SELECT 
    RankedEmails.cinnContactCtg as  cewnContactCtgID,
	RankedEmails.cinnContactID  as  cewnContactID,
    'E'              as  cewsEmailWebsiteFlag,
    RankedEmails.EmailAddress  as  cewsEmailWebSite, 
    1                as  cewbDefault,
	368              as  cewnRecUserID,
	getdate()        as  cewdDtCreated,
	368              as  cewnModifyUserID,
	getdate()        as  cewdDtModified,
	null,
	1                as  saga,
	''               as  cewncomments
 
FROM (
    SELECT 
        ce.EmailAddress,
        c.NameId,
        c.id,
        ce.CommunicationsId,
		i.cinnContactCtg,
		i.cinnContactID,
        ROW_NUMBER() OVER (PARTITION BY ce.EmailAddress, c.NameId ORDER BY ce.EmailAddress DESC) AS RowNum
    FROM 
        [NeosBillEasterly]..CommunicationsEmailAddresses ce
    JOIN 
        [NeosBillEasterly].[dbo].[Communications] c ON c.id = ce.CommunicationsId
    JOIN 
        [NeosBillEasterly]..names n ON c.NameId = n.id
    JOIN 
        [sma_MST_IndvContacts] i ON CONVERT(varchar(50), n.id) = i.saga_ref
) RankedEmails
WHERE RowNum = 1
 ;


 




