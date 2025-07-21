
USE  [SAbilleasterlyLaw]
GO
 
alter table [sma_MST_ContactNumbers] disable trigger all
delete from [sma_MST_ContactNumbers] 
DBCC CHECKIDENT ('[sma_MST_ContactNumbers]', RESEED, 0);
alter table [sma_MST_ContactNumbers] enable trigger all
 


---(0)---
INSERT INTO sma_MST_ContactNoType ( ctysDscrptn,ctynContactCategoryID, ctysDefaultTexting, ctydDtCreated, ctydDtModified )
SELECT 'Fax',1, 0, getdate(), getdate()
UNION
SELECT 'Other',1, 0, getdate(), getdate()
UNION
SELECT 'Home Phone',2, 0, getdate(), getdate()
UNION
SELECT 'Other',2, 0, getdate(), getdate()
EXCEPT
SELECT ctysDscrptn,ctynContactCategoryID, ctysDefaultTexting, getdate(), getdate()  FROM sma_MST_ContactNoType 


---(0)----
IF OBJECT_ID (N'dbo.FormatPhone', N'FN') IS NOT NULL
    DROP FUNCTION FormatPhone;
GO
CREATE FUNCTION dbo.FormatPhone(@phone varchar(MAX) )
RETURNS varchar(MAX) 
AS 
BEGIN
    if len(@phone)=10 and ISNUMERIC(@phone)=1 
    begin
	   return '(' + Substring(@phone,1,3) + ') ' + Substring(@phone,4,3) + '-' + Substring(@phone,7,4)  
    end
    return @phone;
END;
GO

---
ALTER TABLE [sma_MST_ContactNumbers] DISABLE TRIGGER ALL
GO
---

INSERT INTO [sma_MST_ContactNumbers]
(     
       [cnnnContactCtgID],[cnnnContactID],[cnnnPhoneTypeID],[cnnsContactNumber],[cnnsExtension],[cnnbPrimary],[cnnbVisible],[cnnnAddressID],[cnnsLabelCaption]
	   ,[cnnnRecUserID],[cnndDtCreated],[cnnnModifyUserID],[cnndDtModified],[cnnnLevelNo],[caseNo], [Comments], [cnnsTextEnabledNo]
)
SELECT distinct 
		C.cinnContactCtg			as cnnnContactCtgID,
		C.cinnContactID				as cnnnContactID,
		ctynContactNoTypeID			as cnnnPhoneTypeID,  
		dbo.FormatPhone(n.number)	as cnnsContactNumber,
		n.extension					as cnnsExtension,
		case when n.sort_order = 1 then 1 else 0 end	as cnnbPrimary,
		null						as cnnbVisible,
		A.addnAddressID				as cnnnAddressID,
		ct.ctysDscrptn				as cnnsLabelCaption,
		 c.cinnRecUserID   	as cnnnRecUserID,
		 c.cindDtCreated			as cnndDtCreated,
		368							as cnnnModifyUserID,
		getdate()					as cnndDtModified,
		null,null,	
		isnull('Phone Type: ' + nullif(convert(varchar,n.[title]),'') + CHAR(13),'') +
		''	 						as [Comments], 
		case when n.title like '%Mobile%'  or n.title  like '%cell%'     then       1
		       else  0
		end  as cnnsTextEnabledNo
--select distinct *
FROM  [NeosBillEasterly].[dbo].[phone] N 
JOIN [sma_MST_IndvContacts] c on c.saga_ref = convert(varchar(50),N.namesid)
 JOIN sma_MST_ContactNoType ct on ctynContactCategoryID=1 
								and ct.ctysDscrptn = case
								                        WHEN n.title LIKE '%Mobile%' OR n.title LIKE '%cell%' THEN 'Cell'
														when n.title like '%Home%' then 'Home Primary Phone'
														when n.title like '%Business%' then 'HQ/Main Office Phone'
														when n.title like '%Fax' then 'Fax%' 
														else 'Other' end
JOIN [sma_MST_Address] A on A.addnContactID=C.cinnContactID and A.addnContactCtgID=C.cinnContactCtg and A.addbPrimary=1 
WHERE isnull(N.number,'') <> ''  

--STAFF MAIN NUMBER
INSERT INTO [sma_MST_ContactNumbers]
(     
       [cnnnContactCtgID],[cnnnContactID],[cnnnPhoneTypeID],[cnnsContactNumber],[cnnsExtension],[cnnbPrimary],[cnnbVisible],[cnnnAddressID],[cnnsLabelCaption]
	   ,[cnnnRecUserID],[cnndDtCreated],[cnnnModifyUserID],[cnndDtModified],[cnnnLevelNo],[caseNo], [Comments], cnnsTextEnabledNo
)
SELECT 
		C.cinnContactCtg			as cnnnContactCtgID,
		C.cinnContactID				as cnnnContactID,
		ctynContactNoTypeID			as cnnnPhoneTypeID,  
		dbo.FormatPhone(n.phone_number)	as cnnsContactNumber,
		''   					as cnnsExtension,
		1							as cnnbPrimary,
		null						as cnnbVisible,
		A.addnAddressID				as cnnnAddressID,
		ct.ctysDscrptn				as cnnsLabelCaption,
		 c.cinnRecUserID 	as cnnnRecUserID,
		 c.cindDtCreated			as cnndDtCreated,
		368							as cnnnModifyUserID,
		getdate()					as cnndDtModified,
		null,null,	
		--isnull('Phone Type: ' + nullif(convert(varchar,n.[title]),'') + CHAR(13),'') +
		''	 						as [Comments],
		 0                        as cnnsTextEnabledNo
--select *
FROM [NeosBillEasterly] .[dbo].[staff] N 
JOIN [sma_MST_IndvContacts] C on C.saga_ref = convert(varchar(50),N.id)
LEFT JOIN sma_MST_ContactNoType ct on ctynContactCategoryID=1 
								and ct.ctysDscrptn = 'HQ/Main Office Phone'
JOIN [sma_MST_Address] A on A.addnContactID=C.cinnContactID and A.addnContactCtgID=C.cinnContactCtg and A.addbPrimary=1 
WHERE isnull(N.phone_number,'') <> ''  



--STAFF FAX NUMBER
INSERT INTO [sma_MST_ContactNumbers]
(     
       [cnnnContactCtgID],[cnnnContactID],[cnnnPhoneTypeID],[cnnsContactNumber],[cnnsExtension],[cnnbPrimary],[cnnbVisible],[cnnnAddressID],[cnnsLabelCaption]
	   ,[cnnnRecUserID],[cnndDtCreated],[cnnnModifyUserID],[cnndDtModified],[cnnnLevelNo],[caseNo], [Comments], cnnsTextEnabledNo
)
SELECT 
		C.cinnContactCtg			as cnnnContactCtgID,
		C.cinnContactID				as cnnnContactID,
		ctynContactNoTypeID			as cnnnPhoneTypeID,  
		dbo.FormatPhone(n.fax_number)	as cnnsContactNumber,
		null						as cnnsExtension,
		1							as cnnbPrimary,
		null						as cnnbVisible,
		A.addnAddressID				as cnnnAddressID,
		ct.ctysDscrptn				as cnnsLabelCaption,
		 c.cinnRecUserID      as cnnnRecUserID,
		  c.cindDtCreated			as cnndDtCreated,
		368							as cnnnModifyUserID,
		getdate()					as cnndDtModified,
		null,null,	
		--isnull('Phone Type: ' + nullif(convert(varchar,n.[title]),'') + CHAR(13),'') +
		''	 						as [Comments],
		0                        as cnnsTextEnabledNo
--select *
FROM [NeosBillEasterly].[dbo].[staff] N 
JOIN [sma_MST_IndvContacts] C on C.saga_ref =convert(varchar(50), N.id)
LEFT JOIN sma_MST_ContactNoType ct on ctynContactCategoryID=1 
								and ct.ctysDscrptn = 'Fax'
JOIN [sma_MST_Address] A on A.addnContactID=C.cinnContactID and A.addnContactCtgID=C.cinnContactCtg and A.addbPrimary=1 
WHERE isnull(N.fax_number,'') <> ''  


--STAFF MOBILE NUMBER
INSERT INTO [sma_MST_ContactNumbers]
(     
       [cnnnContactCtgID],[cnnnContactID],[cnnnPhoneTypeID],[cnnsContactNumber],[cnnsExtension],[cnnbPrimary],[cnnbVisible],[cnnnAddressID],[cnnsLabelCaption]
	   ,[cnnnRecUserID],[cnndDtCreated],[cnnnModifyUserID],[cnndDtModified],[cnnnLevelNo],[caseNo], [Comments],cnnsTextEnabledNo
)
SELECT 
		C.cinnContactCtg			as cnnnContactCtgID,
		C.cinnContactID				as cnnnContactID,
		ctynContactNoTypeID			as cnnnPhoneTypeID,  
		dbo.FormatPhone(n.mobile_number)	as cnnsContactNumber,
		null						as cnnsExtension,
		1							as cnnbPrimary,
		null						as cnnbVisible,
		A.addnAddressID				as cnnnAddressID,
		ct.ctysDscrptn				as cnnsLabelCaption,
		 c.cinnRecUserID   	as cnnnRecUserID,
		  c.cindDtCreated			as cnndDtCreated,
		368							as cnnnModifyUserID,
		getdate()					as cnndDtModified,
		null,null,	
		--isnull('Phone Type: ' + nullif(convert(varchar,n.[title]),'') + CHAR(13),'') +
		''	 						as [Comments],
		1                          as cnnsTextEnabledNo
--select *
FROM  [NeosBillEasterly].[dbo].[staff] N 
JOIN [sma_MST_IndvContacts] C on C.saga_ref = convert(varchar(50),N.id)
LEFT JOIN sma_MST_ContactNoType ct on ctynContactCategoryID=1 
								and ct.ctysDscrptn = 'Cell'
JOIN [sma_MST_Address] A on A.addnContactID=C.cinnContactID and A.addnContactCtgID=C.cinnContactCtg and A.addbPrimary=1 
WHERE isnull(N.mobile_number,'') <> ''  

------------------------------------
--ORG CONTACT PHONE NUMBERS 
------------------------------------
INSERT INTO [sma_MST_ContactNumbers]
(     
       [cnnnContactCtgID],[cnnnContactID],[cnnnPhoneTypeID],[cnnsContactNumber],[cnnsExtension],[cnnbPrimary],[cnnbVisible],[cnnnAddressID],[cnnsLabelCaption]
	   ,[cnnnRecUserID],[cnndDtCreated],[cnnnModifyUserID],[cnndDtModified],[cnnnLevelNo],[caseNo], cnnsTextEnabledNo
)
SELECT 
		C.connContactCtg			as cnnnContactCtgID,
		C.connContactID				as cnnnContactID,
		ctynContactNoTypeID			as cnnnPhoneTypeID,   -- Office Phone 
		dbo.FormatPhone(n.number)	as cnnsContactNumber,
		extension					as cnnsExtension,
		case when n.sort_order = 1 then 1 else 0 end	as cnnbPrimary,
		null						as cnnbVisible,
		A.addnAddressID				as cnnnAddressID,
		ct.ctysDscrptn				as cnnsLabelCaption,
		 c.connRecUserID   	as cnnnRecUserID,
		 c.condDtCreated				as cnndDtCreated,
		368							as cnnnModifyUserID,
		getdate()					as cnndDtModified,
		null,null,
		0                              as cnnsTextEnabledNo
--- select *
FROM  [NeosBillEasterly].[dbo].[phone] N
JOIN [sma_MST_OrgContacts] C on C.neos_saga = convert(varchar(50),N.namesid)
LEFT JOIN sma_MST_ContactNoType ct on ctynContactCategoryID= 2
								and ct.ctysDscrptn = case when n.title like  '%Mobile%'     then 'Cell' 
														when n.title like  '%Home%' then 'Home Phone'
														when n.title like '%Business%' then 'Office Phone'
														when n.title like  '%Fax%' then 'Office Fax' 
														else 'Other' end
JOIN [sma_MST_Address] A on A.addnContactID=C.connContactID and A.addnContactCtgID=C.connContactCtg and A.addbPrimary=1
WHERE isnull(n.number,'') <> ''




 
 ---(Appendix) Finally, only one phone number as primary---
UPDATE [sma_MST_ContactNumbers] set cnnbPrimary=0
FROM (
	SELECT 
		ROW_NUMBER() OVER (Partition BY cnnnContactID order by cnnnContactNumberID )  as RowNumber,
		cnnnContactNumberID as ContactNumberID  
	FROM [sma_MST_ContactNumbers] 
	WHERE cnnnContactCtgID = (select ctgnCategoryID FROM   [sma_MST_ContactCtg] where ctgsDesc='Individual')
) A
WHERE A.RowNumber <> 1
and A.ContactNumberID=cnnnContactNumberID


UPDATE [sma_MST_ContactNumbers] set cnnbPrimary=0
FROM (
	SELECT 
		ROW_NUMBER() OVER (Partition BY cnnnContactID order by cnnnContactNumberID )  as RowNumber,
		cnnnContactNumberID as ContactNumberID  
	FROM [sma_MST_ContactNumbers] 
	WHERE cnnnContactCtgID = (select ctgnCategoryID FROM  [sma_MST_ContactCtg] where ctgsDesc='Organization')
) A
WHERE A.RowNumber <> 1
and A.ContactNumberID=cnnnContactNumberID
 
---
ALTER TABLE [sma_MST_ContactNumbers] ENABLE TRIGGER ALL
GO
--- 
