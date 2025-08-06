use [SAbilleasterlyLaw]
go


-----------------
---------- 'FEDERAL GOVERNMENT' for 'Social Security Disability'
----------------
alter table [sma_MST_OrgContacts] disable trigger all
 INSERT INTO [sma_MST_OrgContacts] (
    [consName],
    [consWorkPhone],
    [consComments],
    [connContactCtg],
    [connContactTypeID],    
    [connRecUserID],        
    [condDtCreated],
    [conbStatus],            
    [saga],
	saga_ref
  
)
SELECT 
    'FEDERAL GOVERNMENT' AS [consName],
    NULL AS [consWorkPhone],
    'SA  Added Note: For Social Security Disability cases ' AS [consComments],
    2 AS [connContactCtg],
    (SELECT octnOrigContactTypeID 
     FROM [sma_MST_OriginalContactTypes] 
     WHERE octsDscrptn = 'General' 
       AND octnContactCtgID = 2) AS [connContactTypeID],
    368 AS [connRecUserID],
    GETDATE() AS [condDtCreated],
    1 AS [conbStatus],    
    NULL AS [saga],
	''     as saga_ref
-----------------
select  * from sma_MST_OrgContacts

/*
--- select * from sma_MST_CaseType where cstsType ='Social Security Disability'

 select  * from [sma_MST_CaseSubType]   where cstnGroupID = '1586'           cstnCaseSubTypeId = 11583
*/
	select * from sma_trn_cases where casnCaseTypeID =  11583        --------11583        is select * from sma_MST_CaseType where cstsType ='Social Security Disability'

	select * from sma_MST_CaseType 

 UPDATE sma_trn_cases
SET cassCaseName = REPLACE(cassCaseName, 'Defendant Unidentified', 'FEDERAL GOVERNMENT')
WHERE casnCaseTypeID =  11573  and cassCaseName LIKE '%Defendant Unidentified%';


----------------

 INSERT INTO [dbo].[sma_MST_AllContactInfo]
           ([UniqueContactId]
           ,[ContactId]
           ,[ContactCtg]
           ,[Name]
		   ,[NameForLetters]
           ,[FirstName]
           ,[LastName]
	       ,[OtherName]
           ,[AddressId]
           ,[Address1]
           ,[Address2]
           ,[Address3]
           ,[City]
           ,[State]
           ,[Zip]
           ,[ContactNumber]
           ,[ContactEmail]
           ,[ContactTypeId]
           ,[ContactType]
           ,[Comments]
           ,[DateModified]
           ,[ModifyUserId]
           ,[IsDeleted]
           ,[IsActive])
SELECT convert(bigint, ('2' + convert(varchar(30),sma_MST_OrgContacts.connContactID))) as UniqueContactId,
		convert(bigint,sma_MST_OrgContacts.connContactID)		as ContactId,
		2														as ContactCtg ,
		sma_MST_OrgContacts.consName							as Name,
		sma_MST_OrgContacts.consName							as [NameForLetters],
		null													as FirstName,
		null 													as LastName, 
        null 													as OtherName, 
        null 													as AddressId,
        null 													as Address1,
        null 													as Address2,
        null 													as Address3,
        null 													as City,
        null 													as State,
        null 													as Zip,
        null 													as ContactNumber,
        null 													as ContactEmail,
        sma_MST_OrgContacts.connContactTypeID					as ContactTypeId,
        sma_MST_OriginalContactTypes.octsDscrptn				as ContactType,
        sma_MST_OrgContacts.consComments						as Comments, 
        getDate()												as DateModified,
        347														as ModifyUserId,
        0														as IsDeleted,
        [conbStatus]
----- select * 
FROM sma_MST_OrgContacts
LEFT JOIN sma_MST_OriginalContactTypes on sma_MST_OriginalContactTypes.octnOrigContactTypeID = sma_MST_OrgContacts.connContactTypeID
where consName = 'FEDERAL GOVERNMENT'  
 ------------------------

 select *  from sma_MST_AllContactInfo where uniqueContactId  in ('28942')      
-----------------------------------
select * from sma_TRN_Defendants
select * from sma_TRN_Cases  where casnCaseTypeID = 11573

select * from sma_MST_OrgContacts

 select Def.*
 from   sma_TRN_Defendants Def
 join [sma_TRN_Cases]  cas      on   def.defnCaseID = cas.casnCaseID
 WHERE cas.casnCaseTypeID =  11586  

 UPDATE def 
SET  defnContactCtgID = 2,
         defnContactId  = 7808
FROM sma_TRN_Defendants  def
JOIN [sma_TRN_Cases] cas
    ON  def.defnCaseID = cas.casnCaseID
WHERE cas.casnCaseTypeID = 11583

 
 
GO