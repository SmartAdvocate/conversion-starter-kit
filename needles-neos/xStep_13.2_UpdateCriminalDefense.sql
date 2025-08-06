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
	neos_saga
  
)
SELECT 
    'STATE of TENNESSEE' AS [consName],
    NULL AS [consWorkPhone],
    'For Criminal Defense Cases ' AS [consComments],
    2 AS [connContactCtg],
    (SELECT octnOrigContactTypeID 
     FROM [sma_MST_OriginalContactTypes] 
     WHERE octsDscrptn = 'General' 
       AND octnContactCtgID = 2) AS [connContactTypeID],
    368 AS [connRecUserID],
    GETDATE() AS [condDtCreated],
    1 AS [conbStatus],    
    NULL AS [saga],
	''     as neos_saga
-----------------
select  * from sma_MST_OrgContacts where consName = 'STATE of TENNESSEE'             ------    connContactID = 7809

 
  select * from sma_MST_CaseType where cstsType ='Criminal Defense'        ------cstnCaseTypeID = 1577

 select  * from [sma_MST_CaseSubType]   where cstnGroupID = '1577'           cstnCaseSubTypeId = 11574
 
	select * from sma_trn_cases where casnCaseTypeID =  11574        --------11574        is select * from sma_MST_CaseType where cstsType ='Criminal Defense'

	select * from sma_TRN_CaseTypes

 UPDATE sma_trn_cases
SET cassCaseName = REPLACE(cassCaseName, 'Defendant Unidentified', 'STATE of TENNESSEE')
WHERE casnCaseTypeID =  11574  and cassCaseName LIKE '%Defendant Unidentified%';

 
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
where consName = 'STATE of TENNESSEE' and   connContactID  = '7809'
 
-----------------------------------
select * from sma_TRN_Plaintiff
select * from sma_TRN_Cases

 select def.*
 from   sma_TRN_Defendants Def
 join [sma_TRN_Cases]  cas      on   def.defnCaseID = cas.casnCaseID
 WHERE cas.casnCaseTypeID =  11574 and (cassCaseNumber not in  ('200638','200639','200569'))
   
 UPDATE def
SET  defnContactCtgID = 2,
         defnContactId  =  7809
FROM  sma_TRN_Defendants  def
JOIN [sma_TRN_Cases] cas
    ON  def.defnCaseID = cas.casnCaseID
WHERE cas.casnCaseTypeID = 11574 and (cassCaseNumber not in  ('200638','200639','200569'));