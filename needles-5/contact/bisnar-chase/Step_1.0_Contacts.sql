
USE [SA]
GO
/*
alter table [sma_MST_IndvContacts] disable trigger all
delete from [sma_MST_IndvContacts] 
DBCC CHECKIDENT ('[dbo].[sma_MST_IndvContacts]', RESEED, 0);
alter table [sma_MST_IndvContacts] enable trigger all

alter table [sma_MST_users] disable trigger all
delete from [sma_MST_users] 
DBCC CHECKIDENT ('[sma_MST_users]', RESEED, 0);
alter table [sma_MST_users] enable trigger all

alter table [sma_MST_OrgContacts] disable trigger all
delete from [sma_MST_OrgContacts] 
DBCC CHECKIDENT ('[sma_MST_OrgContacts]', RESEED, 0);
alter table [sma_MST_OrgContacts] enable trigger all
*/


--(0) saga field for needles names_id ---
ALTER TABLE [sma_MST_IndvContacts]
 ALTER COLUMN saga varchar(50)
ALTER TABLE [sma_MST_OrgContacts]
 ALTER COLUMN saga varchar(50)

 ALTER TABLE  [sma_MST_IndvContacts]
  ALTER COLUMN [cinsNickName] varchar(50)

 /*
--(0)---
INSERT INTO [sma_MST_Languages] ([lngsLanguageName])
SELECT race_name FROM [BenAbbot_Needles].[dbo].[race] WHERE isnull(race_name,'')<>''
EXCEPT
SELECT [lngsLanguageName] FROM [sma_MST_Languages]
GO
*/

--(0) construct [sma_MST_IndvContacts] special contacts
 
--SET IDENTITY_INSERT [sma_MST_IndvContacts] ON 
--GO

INSERT INTO [sma_MST_IndvContacts] (
	[cinbPrimary],[cinnContactTypeID],[cinnContactSubCtgID],[cinsPrefix],[cinsFirstName],[cinsMiddleName],[cinsLastName],[cinsSuffix],[cinsNickName],[cinbStatus],[cinsSSNNo],[cindBirthDate],
	[cinsComments],[cinnContactCtg],[cinnRefByCtgID],[cinnReferredBy],[cindDateOfDeath],[cinsCVLink],[cinnMaritalStatusID],[cinnGender],[cinsBirthPlace],[cinnCountyID],[cinsCountyOfResidence],
	[cinbFlagForPhoto],[cinsPrimaryContactNo],[cinsHomePhone],[cinsWorkPhone],[cinsMobile],[cinbPreventMailing],[cinnRecUserID],[cindDtCreated],[cinnModifyUserID],[cindDtModified],[cinnLevelNo],
	[cinsPrimaryLanguage],[cinsOtherLanguage],[cinbDeathFlag],[cinsCitizenship],[cinsHeight],[cinnWeight],[cinsReligion],[cindMarriageDate],[cinsMarriageLoc],[cinsDeathPlace],[cinsMaidenName],
	[cinsOccupation],[saga],[cinsSpouse],[cinsGrade]) 

--SELECT DISTINCT 8,1,10,null,'Mr.','Staff','','Unassigned',null,null,1,null,
--null,null,1,'','',null,'','',1,'',1,1,null,null,'','',null,0,368,GETDATE(),'',null,0,'','','','',null+null,null,'',Null,'','','','',-1,'',null
--UNION
SELECT DISTINCT 1,10,null,'Mr.','Individual','','Unidentified',null,null,1,null,
null,null,1,'','',null,'','',1,'',1,1,null,null,'','',null,0,368,GETDATE(),'',null,0,'','','','',null+null,null,'',Null,'','','','',0,'',null
UNION
SELECT DISTINCT 1,10,null,null,'Plaintiff','','Unidentified',null,null,1,null,
null,null,1,'','',null,'','',1,'',1,1,null,null,'','',null,0,368,GETDATE(),'',null,0,'','','','',null+null,null,'',Null,'','','','','','',null
UNION
SELECT DISTINCT 1,10,null,null,'Defendant','','Unidentified',null,null,1,null,
null,null,1,'','',null,'','',1,'',1,1,null,null,'','',null,0,368,GETDATE(),'',null,0,'','','','',null+null,null,'',Null,'','','','','','',null

--SET IDENTITY_INSERT [sma_MST_IndvContacts] OFF
--GO
 
 /*
 INSERT INTO [sma_MST_IndvContacts]
([cinbPrimary],[cinnContactTypeID],[cinnContactSubCtgID],[cinsPrefix],[cinsFirstName],[cinsMiddleName],[cinsLastName],[cinsSuffix],[cinsNickName],[cinbStatus],[cinsSSNNo],[cindBirthDate],
[cinsComments],[cinnContactCtg],[cinnRefByCtgID],[cinnReferredBy],[cindDateOfDeath],[cinsCVLink],[cinnMaritalStatusID],[cinnGender],[cinsBirthPlace],[cinnCountyID],[cinsCountyOfResidence],
[cinbFlagForPhoto],[cinsPrimaryContactNo],[cinsHomePhone],[cinsWorkPhone],[cinsMobile],[cinbPreventMailing],[cinnRecUserID],[cindDtCreated],[cinnModifyUserID],[cindDtModified],[cinnLevelNo],
[cinsPrimaryLanguage],[cinsOtherLanguage],[cinbDeathFlag],[cinsCitizenship],[cinsHeight],[cinnWeight],[cinsReligion],[cindMarriageDate],[cinsMarriageLoc],[cinsDeathPlace],[cinsMaidenName],
[cinsOccupation],[saga],[cinsSpouse],[cinsGrade]) 
   
SELECT distinct 1,10,null,'Mr.','Staff','','Unassigned',null,null,1,null,
null,null,1,'','',null,'','',1,'',1,1,null,null,'','',null,0,368,GETDATE(),'',null,0,'','','','',null+null,null,'',Null,'','','','',-1,'',null
union
SELECT distinct 1,10,null,'Mr.','Individual','','Unidentified',null,null,1,null,
null,null,1,'','',null,'','',1,'',1,1,null,null,'','',null,0,368,GETDATE(),'',null,0,'','','','',null+null,null,'',Null,'','','','',0,'',null
union
SELECT distinct 1,10,null,null,'Plaintiff','','Unidentified',null,null,1,null,
null,null,1,'','',null,'','',1,'',1,1,null,null,'','',null,0,368,GETDATE(),'',null,0,'','','','',null+null,null,'',Null,'','','','','','',null
union
SELECT distinct 1,10,null,null,'Defendant','','Unidentified',null,null,1,null,
null,null,1,'','',null,'','',1,'',1,1,null,null,'','',null,0,368,GETDATE(),'',null,0,'','','','',null+null,null,'',Null,'','','','','','',null

*/

------------------------------------------------------------------------------------------------
---------------------------------------BEGIN INSERT USERS---------------------------------------
------------------------------------------------------------------------------------------------
INSERT INTO [sma_MST_IndvContacts] (
		[cinsPrefix],
		[cinsSuffix],
		[cinsFirstName],
		[cinsLastName],
		[cinsHomePhone],
		[cinsWorkPhone],
		[cinsSSNNo],
		[cindBirthDate],
		[cindDateOfDeath],
		[cinnGender],
		[cinsMobile],
		[cinsComments],
		[cinnContactCtg],
		[cinnContactTypeID],	
		[cinnRecUserID],		
		[cindDtCreated],
		[cinbStatus],			
		[cinbPreventMailing],
		[cinsNickName],
		[cinsOccupation],
		[saga],
		[cinsGrade]				-- remember the [staff_code]
)
SELECT 
		p.[name]							as [cinsPrefix],
		s.[name]							as [cinsSuffix],
		case when isnull(stf.first_name,'') = '' then left(isnull(first_name,dbo.get_firstword(full_name)),30)
			else stf.first_name end			as [cinsFirstName],
		case when isnull(stf.last_name,'') = '' then left(isnull(last_name,dbo.get_lastword(full_name)),40)
			else stf.last_name end			as [cinsLastName],
		NULL								as [cinsHomePhone],
		left(phone_number,20)				as [cinsWorkPhone],
		NULL								as [cinsSSNNo],
		NULL								as [cindBirthDate],
		NULL								as [cindDateOfDeath],
		case [gender] 
				when 1 then 1
				when 2 then 2
				else 0
		end									as [cinnGender],
		left(mobile_number,20) 				as [cinsMobile],
		isnull('Supervisor: ' + nullif(convert(varchar,stf.supervisor),'') + CHAR(13),'') +
		isnull('Bar1: ' + nullif(convert(varchar,stf.Bar1),'') + CHAR(13),'') +
		isnull('Bar1 State: ' + nullif(convert(varchar,stf.Bar_State1),'') + CHAR(13),'') +
		isnull('Bar2: ' + nullif(convert(varchar,stf.Bar2),'') + CHAR(13),'') +
		isnull('Bar2 State: ' + nullif(convert(varchar,stf.Bar_State2),'') + CHAR(13),'') +
		isnull('Bar3: ' + nullif(convert(varchar,stf.Bar3),'') + CHAR(13),'') +
		isnull('Bar3 State: ' + nullif(convert(varchar,stf.Bar_State3),'') + CHAR(13),'') +
		'Works on Cases: ' + case when stf.works_on_cases = 1 then 'Yes' else 'No' end + CHAR(13) +
		''									as [cinsComments],
		1									as [cinnContactCtg],
		(select octnOrigContactTypeID from sma_MST_OriginalContactTypes where octsDscrptn='General' and octnContactCtgID=1) as [cinnContactTypeID],
		368, 
		stf.Date_Created,
		1									as [cinbStatus],
		0,
		convert(varchar(15),full_name)		as [cinsNickName],
		stf.job_title						as [cinsOccupation],
		stf.id								as [saga],
		stf.staff_code						as [cinsGrade] -- Remember it to go to sma_MST_Users
--SELECT *
FROM [BenAbbot_Needles].[dbo].[staff] stf
LEFT JOIN [BenAbbot_Needles]..[prefix] p on stf.prefixid = p.id
LEFT JOIN [BenAbbot_Needles]..[suffix] s on s.id = stf.suffixid
LEFT JOIN sma_MST_IndvContacts ind on ind.saga = convert(Varchar(max),stf.id)
WHERE ind.cinnContactID IS NULL



-- (3.2) construct [sma_MST_Users]
IF (select count(*) from sma_mst_users where usrsloginid = 'aadmin') =0
BEGIN
	SET IDENTITY_INSERT sma_mst_users ON

	INSERT INTO [sma_MST_Users]
	(usrnuserid,[usrnContactID],[usrsLoginID],[usrsPassword],[usrsBackColor],[usrsReadBackColor],[usrsEvenBackColor],[usrsOddBackColor],[usrnRoleID],[usrdLoginDate],[usrdLogOffDate],[usrnUserLevel],[usrsWorkstation],[usrnPortno],[usrbLoggedIn],
	[usrbCaseLevelRights],[usrbCaseLevelFilters],[usrnUnsuccesfulLoginCount],[usrnRecUserID],[usrdDtCreated],[usrnModifyUserID],[usrdDtModified],[usrnLevelNo],[usrsCaseCloseColor],[usrnDocAssembly],[usrnAdmin],[usrnIsLocked], [usrbActiveState])     
	SELECT DISTINCT 368,8,'aadmin','2/',null,null,null,null,33,null,null,null,null,null,null,null,null,null,1,GETDATE(),null,null,null,null,null,null,null,1

	SET IDENTITY_INSERT sma_mst_users OFF
END

IF NOT EXISTS (SELECT * FROM sys.columns WHERE Name = N'saga' AND Object_ID = Object_ID(N'sma_MST_Users'))
BEGIN
    ALTER TABLE [sma_MST_Users] ADD [saga] [varchar](50) NULL; 
END
GO

INSERT INTO [sma_MST_Users] (
[usrnContactID],[usrsLoginID],[usrsPassword],[usrsBackColor],[usrsReadBackColor],[usrsEvenBackColor],[usrsOddBackColor],[usrnRoleID],[usrdLoginDate],[usrdLogOffDate],[usrnUserLevel],[usrsWorkstation],[usrnPortno],[usrbLoggedIn],
[usrbCaseLevelRights],[usrbCaseLevelFilters],[usrnUnsuccesfulLoginCount],[usrnRecUserID],[usrdDtCreated],[usrnModifyUserID],[usrdDtModified],[usrnLevelNo],[usrsCaseCloseColor],[usrnDocAssembly],[usrnAdmin],[usrnIsLocked],[saga])     

SELECT cinncontactid, convert(varchar(20),staff_code),'#',null,null,null,null,33,null,null,null,null,null,null,null,null,null,1,GETDATE(),null,null,null,null,null,null,null,stf.[id]
--SELECT *
FROM [BenAbbot_Needles].[dbo].[staff] STF
JOIN sma_MST_IndvContacts INDV on INDV.cinsGrade = STF.staff_code
LEFT JOIN [sma_MST_Users] u on u.saga = STF.[id]
WHERE u.usrsLoginID is null

-----------------------------------------------------------

DECLARE @UserID int

DECLARE staff_cursor CURSOR FAST_FORWARD FOR SELECT usrnuserid from sma_mst_users

OPEN staff_cursor 

FETCH NEXT FROM staff_cursor INTO @UserID

SET NOCOUNT ON;
WHILE @@FETCH_STATUS = 0
BEGIN

INSERT INTO sma_TRN_CaseBrowseSettings (cbsnColumnID,cbsnUserID,cbssCaption,cbsbVisible,cbsnWidth,cbsnOrder,cbsnRecUserID,cbsdDtCreated,cbsn_StyleName)
 SELECT DISTINCT cbcnColumnID,@UserID,cbcscolumnname,'True',200,cbcnDefaultOrder,@UserID,GETDATE(),'Office2007Blue' FROM [sma_MST_CaseBrowseColumns]
 WHERE cbcnColumnID not in (1,18,19,20,21,22,23,24,25,26,27,28,29,30,33)

FETCH NEXT FROM staff_cursor INTO  @UserID
END

CLOSE staff_cursor 
DEALLOCATE staff_cursor


---- Appendix ----
INSERT INTO Account_UsersInRoles ( user_id,role_id)
SELECT usrnUserID as user_id,2 as role_id 
FROM sma_MST_Users

UPDATE Account_UsersInRoles 
SET role_id=1 
WHERE user_id=368 

------------------------------------------------------------------------------------------------
----------------------------------------END INSERT USERS----------------------------------------
------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------
--------------------------------------BEGIN INSERT CONTACTS-------------------------------------
------------------------------------------------------------------------------------------------
--INDV CONTACTS
INSERT INTO [sma_MST_IndvContacts] (
	[cinsPrefix],
	[cinsSuffix],
	[cinsFirstName],
	[cinsMiddleName],
	[cinsLastName],
	[cinsHomePhone],
	[cinsWorkPhone],
	[cinsSSNNo],
	[cindBirthDate],
	[cindDateOfDeath],
	[cinnGender],
	[cinsMobile],
	[cinsComments],
	[cinnContactCtg],
	[cinnContactTypeID],	
	[cinnContactSubCtgID],
	[cinnRecUserID],		
	[cindDtCreated],
	[cinbStatus],			
	[cinbPreventMailing],
	[cinsNickName],
	[cinsPrimaryLanguage],
    [cinsOtherLanguage],
	[saga]					
)
SELECT										 
	   p.[name]									 as [cinsPrefix],
	   s.[name]									 as [cinsSuffix],
	   convert(varchar(30),N.[first_name])		 as [cinsFirstName],
	   convert(varchar(30),N.[initial])			 as [cinsMiddleName],
	   convert(varchar(40),N.[last_long_name])	 as [cinsLastName],
	   NULL										 as [cinsHomePhone],
	   NULL										 as [cinsWorkPhone],
	   left(N.[ss_number],20)					 as [cinsSSNNo],
	   case when ( N.[date_of_birth] not between '1900-01-01' and '2079-12-31' )  then getdate() else N.[date_of_birth] end	
												 as [cindBirthDate],
	   case when ( N.[date_of_death] not between '1900-01-01' and '2079-12-31' )  then getdate() else N.[date_of_death] end	
												 as [cindDateOfDeath],
	   case when N.[gender]=1 then 1
			when N.[gender]=2 then 2
			else 0  end							 as [cinnGender],
	   NULL										 as [cinsMobile],
	   ''										 as [cinsComments],
	   1										 as [cinnContactCtg],
	   (select octnOrigContactTypeID FROM [sma_MST_OriginalContactTypes] where octsDscrptn='General' and octnContactCtgID=1) 
												 as [cinnContactTypeID],
	   case when N.[deceased] = 1 
				    then (select cscnContactSubCtgID from [sma_MST_ContactSubCategory] where cscsDscrptn='Deceased')
			when exists (select * from [BenAbbot_Needles].[dbo].[party] P where P.[namesid] = N.[id] and P.incapacitated = 1) 
				    then (select cscnContactSubCtgID from [sma_MST_ContactSubCategory] where cscsDscrptn='Incompetent')
			when exists (select * from [BenAbbot_Needles].[dbo].[party] P where P.[namesid] = N.[id] and P.minor= 1) 
				    then (select cscnContactSubCtgID from [sma_MST_ContactSubCategory] where cscsDscrptn='Infant')
			else (select cscnContactSubCtgID from [sma_MST_ContactSubCategory] where cscsDscrptn='Adult')
	   end										 as cinnContactSubCtgID,
	   (Select usrnUserID from sma_mst_Users u where u.saga = n.staffcreatedid)		 as cinnRecUserID,
	   n.date_created							 as cindDtCreated,
	   1										 as [cinbStatus],			-- Hardcode Status as ACTIVE 
	   0		 								 as [cinbPreventMailing], 
	   isnull(aka_first,'') + ' ' + isnull(aka_last,'') 		 as [cinsNickName],
	   NULL										 as [cinsPrimaryLanguage],
	   null										 as [cinsOtherLanguage],
	   N.[id]									 as saga 
--SELECT max(len( isnull(aka_first,'') + ' ' + isnull(aka_last,'') ))
FROM [BenAbbot_Needles]..[names] N
LEFT JOIN [BenAbbot_Needles]..[prefix] p on n.prefixid = p.id
LEFT JOIN [BenAbbot_Needles]..[suffix] s on s.id = n.suffixid
WHERE N.[person]= 1

-----------------
--ORG CONTACTS
-----------------
INSERT INTO [sma_MST_OrgContacts] (
		[consName],
		[consWorkPhone],
		[consComments],
		[connContactCtg],
		[connContactTypeID],	
		[connRecUserID],		
		[condDtCreated],
		[conbStatus],			
		[saga]					
	)
SELECT 
    N.[last_long_name]					  as [consName],
    NULL								  as [consWorkPhone],
    isnull('AKA: ' + nullif(convert(varchar,n.aka_full),'') + CHAR(13),'') +
	''									  as [consComments],
    2									  as [connContactCtg],
    (select octnOrigContactTypeID FROM [SA].[dbo].[sma_MST_OriginalContactTypes] where octsDscrptn='General' and octnContactCtgID=2) as [connContactTypeID],
    (Select usrnUserID from sma_mst_Users u where u.saga = n.staffcreatedid)	  as [connRecUserID],
    date_created						  as [condDtCreated],
    1									  as [conbStatus],		-- Hardcode Status as ACTIVE
    N.[id]								  as [saga]			
--SELECT *
FROM [BenAbbot_Needles].[dbo].[names] N
WHERE N.[person] <> 1


------------------------------------------------------------------------------------------------
---------------------------------------END INSERT CONTACTS--------------------------------------
------------------------------------------------------------------------------------------------