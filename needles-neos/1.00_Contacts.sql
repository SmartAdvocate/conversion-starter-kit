
USE   [SAbilleasterlyLaw]
GO
 
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
 


--(0) saga field for needles names_id ---
ALTER TABLE [sma_MST_IndvContacts]
 ADD saga_ref varchar(50)
GO

ALTER TABLE [sma_MST_OrgContacts]
 ADD neos_saga varchar(50)
GO

  ALTER TABLE [sma_MST_Users]
 ADD saga  varchar(50)
GO

 /*ALTER TABLE  [sma_MST_IndvContacts]
 ALTER COLUMN [saga] int
 GO

 ALTER TABLE  [sma_MST_orgContacts]
 ALTER COLUMN [saga] int
 GO
 
--(0)---
INSERT INTO [sma_MST_Languages] ([lngsLanguageName])
SELECT race_name FROM [NeosBrianWhite].[dbo].[race] WHERE isnull(race_name,'')<>''
EXCEPT
SELECT [lngsLanguageName] FROM [sma_MST_Languages]
GO
*/

------------------------------------------
--ADD EMPTY / DEFAULT RECORDS
------------------------------------------
if not exists (Select * From sma_mst_Indvcontacts where [cinsFirstName] = 'Staff' and [cinsLastName] = 'Unassigned')
BEGIN
	INSERT INTO [sma_MST_IndvContacts]
	([cinbPrimary],[cinnContactTypeID],[cinnContactSubCtgID],[cinsPrefix],[cinsFirstName],[cinsMiddleName],[cinsLastName],[cinsSuffix],[cinsNickName],[cinbStatus],[cinsSSNNo],[cindBirthDate],
	[cinsComments],[cinnContactCtg],[cinnRefByCtgID],[cinnReferredBy],[cindDateOfDeath],[cinsCVLink],[cinnMaritalStatusID],[cinnGender],[cinsBirthPlace],[cinnCountyID],[cinsCountyOfResidence],
	[cinbFlagForPhoto],[cinsPrimaryContactNo],[cinsHomePhone],[cinsWorkPhone],[cinsMobile],[cinbPreventMailing],[cinnRecUserID],[cindDtCreated],[cinnModifyUserID],[cindDtModified],[cinnLevelNo],
	[cinsPrimaryLanguage],[cinsOtherLanguage],[cinbDeathFlag],[cinsCitizenship],[cinsHeight],[cinnWeight],[cinsReligion],[cindMarriageDate],[cinsMarriageLoc],[cinsDeathPlace],[cinsMaidenName],
	[cinsOccupation],[saga],[cinsSpouse],[cinsGrade]) 
   
	SELECT 1,10,null,'Mr.','Staff','','Unassigned',null,null,1,null,
	null,null,1,'','',null,'','',1,'',1,1,null,null,'','',null,0,368,GETDATE(),'',null,0,'','','','',null+null,null,'',Null,'','','','','','',null
END

if not exists (Select * From sma_mst_Indvcontacts where [cinsFirstName] = 'Individual' and [cinsLastName] = 'Unidentified')
BEGIN
	INSERT INTO [sma_MST_IndvContacts]
	([cinbPrimary],[cinnContactTypeID],[cinnContactSubCtgID],[cinsPrefix],[cinsFirstName],[cinsMiddleName],[cinsLastName],[cinsSuffix],[cinsNickName],[cinbStatus],[cinsSSNNo],[cindBirthDate],
	[cinsComments],[cinnContactCtg],[cinnRefByCtgID],[cinnReferredBy],[cindDateOfDeath],[cinsCVLink],[cinnMaritalStatusID],[cinnGender],[cinsBirthPlace],[cinnCountyID],[cinsCountyOfResidence],
	[cinbFlagForPhoto],[cinsPrimaryContactNo],[cinsHomePhone],[cinsWorkPhone],[cinsMobile],[cinbPreventMailing],[cinnRecUserID],[cindDtCreated],[cinnModifyUserID],[cindDtModified],[cinnLevelNo],
	[cinsPrimaryLanguage],[cinsOtherLanguage],[cinbDeathFlag],[cinsCitizenship],[cinsHeight],[cinnWeight],[cinsReligion],[cindMarriageDate],[cinsMarriageLoc],[cinsDeathPlace],[cinsMaidenName],
	[cinsOccupation],[saga],[cinsSpouse],[cinsGrade]) 
   
	SELECT 1,10,null,'Mr.','Individual','','Unidentified',null,null,1,null,
	null,null,1,'','',null,'','',1,'',1,1,null,null,'','',null,0,368,GETDATE(),'',null,0,'','','','',null+null,null,'',Null,'','','','Unknown','','',null
END

if not exists (Select * From sma_mst_Indvcontacts where [cinsFirstName] = 'Plaintiff' and [cinsLastName] = 'Unidentified')
BEGIN
	INSERT INTO [sma_MST_IndvContacts]
	([cinbPrimary],[cinnContactTypeID],[cinnContactSubCtgID],[cinsPrefix],[cinsFirstName],[cinsMiddleName],[cinsLastName],[cinsSuffix],[cinsNickName],[cinbStatus],[cinsSSNNo],[cindBirthDate],
	[cinsComments],[cinnContactCtg],[cinnRefByCtgID],[cinnReferredBy],[cindDateOfDeath],[cinsCVLink],[cinnMaritalStatusID],[cinnGender],[cinsBirthPlace],[cinnCountyID],[cinsCountyOfResidence],
	[cinbFlagForPhoto],[cinsPrimaryContactNo],[cinsHomePhone],[cinsWorkPhone],[cinsMobile],[cinbPreventMailing],[cinnRecUserID],[cindDtCreated],[cinnModifyUserID],[cindDtModified],[cinnLevelNo],
	[cinsPrimaryLanguage],[cinsOtherLanguage],[cinbDeathFlag],[cinsCitizenship],[cinsHeight],[cinnWeight],[cinsReligion],[cindMarriageDate],[cinsMarriageLoc],[cinsDeathPlace],[cinsMaidenName],
	[cinsOccupation],[saga],[cinsSpouse],[cinsGrade]) 
   
	SELECT 1,10,null,'','Plaintiff','','Unidentified',null,null,1,null,
	null,null,1,'','',null,'','',1,'',1,1,null,null,'','',null,0,368,GETDATE(),'',null,0,'','','','',null+null,null,'',Null,'','','','','','',null
END

IF NOT EXISTS (Select * From sma_mst_Indvcontacts where [cinsFirstName] = 'Defendant' and [cinsLastName] = 'Unidentified')
BEGIN
	INSERT INTO [sma_MST_IndvContacts]
	([cinbPrimary],[cinnContactTypeID],[cinnContactSubCtgID],[cinsPrefix],[cinsFirstName],[cinsMiddleName],[cinsLastName],[cinsSuffix],[cinsNickName],[cinbStatus],[cinsSSNNo],[cindBirthDate],
	[cinsComments],[cinnContactCtg],[cinnRefByCtgID],[cinnReferredBy],[cindDateOfDeath],[cinsCVLink],[cinnMaritalStatusID],[cinnGender],[cinsBirthPlace],[cinnCountyID],[cinsCountyOfResidence],
	[cinbFlagForPhoto],[cinsPrimaryContactNo],[cinsHomePhone],[cinsWorkPhone],[cinsMobile],[cinbPreventMailing],[cinnRecUserID],[cindDtCreated],[cinnModifyUserID],[cindDtModified],[cinnLevelNo],
	[cinsPrimaryLanguage],[cinsOtherLanguage],[cinbDeathFlag],[cinsCitizenship],[cinsHeight],[cinnWeight],[cinsReligion],[cindMarriageDate],[cinsMarriageLoc],[cinsDeathPlace],[cinsMaidenName],
	[cinsOccupation],[saga],[cinsSpouse],[cinsGrade]) 
   
	SELECT distinct 1,10,null,'','Defendant','','Unidentified',null,null,1,null,
	null,null,1,'','',null,'','',1,'',1,1,null,null,'','',null,0,368,GETDATE(),'',null,0,'','','','',null+null,null,'',Null,'','','','','','',null
END


------------------------------------------------------------------------------------------------
---------------------------------------BEGIN INSERT USERS---------------------------------------
------------------------------------------------------------------------------------------------
 
UPDATE [NeosBillEasterly].[dbo].[staff]
SET 
    first_name = 'Iva',
    last_name = 'Mackie'
WHERE 
    full_name = 'Iva Mackie';

UPDATE [NeosBillEasterly].[dbo].[staff]
SET 
    first_name = 'Paige',
    last_name = 'Dabbs'
WHERE 
    full_name = 'Paige Dabbs';

UPDATE [NeosBillEasterly].[dbo].[staff]
SET 
    first_name = 'Ilanna',
    last_name = 'Perkins'
WHERE 
    full_name = 'Ilanna Perkins';

UPDATE [NeosBillEasterly].[dbo].[staff]
SET 
    first_name = 'Kelly',
	middle_name = 'A.',
    last_name = 'Byrnes'
WHERE 
    full_name = 'Kelly A. Byrnes';

UPDATE [NeosBillEasterly].[dbo].[staff]
SET 
    middle_name = 'N.'
 WHERE 
    full_name = 'Jessica N. Long';

UPDATE [NeosBillEasterly].[dbo].[staff]
SET 
    first_name = 'Ilanna',
 
    last_name = 'Perkins'
WHERE 
    full_name = 'Ilanna Perkins';

UPDATE [NeosBillEasterly].[dbo].[staff]
SET 
    first_name = 'Annbern',
    last_name = 'Holliman'
WHERE 
    full_name = 'Annbern Holliman';

UPDATE [NeosBillEasterly].[dbo].[staff]
SET 
    first_name = 'Bethany',
    last_name = 'Jackson'
WHERE 
    full_name = 'Bethany Jackson';

UPDATE [NeosBillEasterly].[dbo].[staff]
SET 
    middle_name = 'B.'
 WHERE 
    full_name = 'James B. Lewis';

UPDATE [NeosBillEasterly].[dbo].[staff]
SET 
    middle_name = 'A.'
 WHERE 
    full_name = 'Michael A. Colavecchio';

UPDATE [NeosBillEasterly].[dbo].[staff]
SET 
    first_name = 'Mikela',
    last_name = 'White'
WHERE 
    full_name = 'Mikela White';

UPDATE [NeosBillEasterly].[dbo].[staff]
SET 
    first_name = 'Gregg',
    last_name = 'Punger'
WHERE 
    full_name = 'Gregg Punger';

UPDATE [NeosBillEasterly].[dbo].[staff]
SET 
    first_name = 'Heather',
    last_name = 'Massey'
WHERE 
    full_name = 'Heather Massey';

UPDATE [NeosBillEasterly].[dbo].[staff]
SET 
    first_name = 'Melissa',
	middle_name = 'M.',
    last_name = 'Medley'
WHERE 
    full_name = 'Melissa M. Medley';

UPDATE [NeosBillEasterly].[dbo].[staff]
SET 
    first_name = 'Jonathan',
    last_name = 'Lawrence'
WHERE 
    full_name = 'Jonathan Lawrence';

UPDATE [NeosBillEasterly].[dbo].[staff]
SET 
    first_name = 'Adam',
    last_name = 'Sheets'
WHERE 
    full_name = 'Adam Sheets';


UPDATE [NeosBillEasterly].[dbo].[staff]
SET 
    first_name = 'KC',
    last_name = 'Meyer'
WHERE 
    full_name = 'KC Meyer';

UPDATE [NeosBillEasterly].[dbo].[staff]
SET 
    first_name = 'Sara',
    last_name = 'Pate'
WHERE 
    full_name = 'Sara Pate';

 
UPDATE [NeosBillEasterly].[dbo].[staff]
SET 
    first_name = 'Jessica',
	middle_name = 'L.',
    last_name = 'Weiss'
WHERE 
    full_name = 'Jessica L. Weiss';

UPDATE [NeosBillEasterly].[dbo].[staff]
SET 
    first_name = 'Megan',
	middle_name = 'E.',
    last_name = 'Morelock'
WHERE 
    full_name = 'Megan E. Morelock';

UPDATE [NeosBillEasterly].[dbo].[staff]
SET 
    first_name = 'Erika',
    last_name = 'Holmes'
WHERE 
    full_name = 'Erika Holmes';

UPDATE [NeosBillEasterly].[dbo].[staff]
SET 
    first_name = 'Christina',
	middle_name = 'L.',
    last_name = 'Colavecchio'
WHERE 
    full_name = 'Christina L. Colavecchio';

UPDATE [NeosBillEasterly].[dbo].[staff]
SET 
    first_name = 'Jenna',
    last_name = 'Voor'
WHERE 
    full_name = 'Jenna Voor';

UPDATE [NeosBillEasterly].[dbo].[staff]
SET 
    first_name = 'Staff',
    last_name = 'Inserted from 5.x conversion'
WHERE 
    full_name = 'Inserted from 5.x conversion';

UPDATE [NeosBillEasterly].[dbo].[staff]
SET 
    first_name = 'Peggy',
    last_name = 'Hayden'
WHERE 
    full_name = 'Peggy Hayden';

UPDATE [NeosBillEasterly].[dbo].[staff]
SET 
    first_name = 'Katherine',
    last_name = 'Harris'
WHERE 
    full_name = 'Katherine Harris';

UPDATE [NeosBillEasterly].[dbo].[staff]
SET 
    first_name = 'Pamela',
    last_name = 'Wallace'
WHERE 
    full_name = 'Pamela Wallace';


----------------------------
INSERT INTO [sma_MST_IndvContacts] (
		[cinsPrefix],
		[cinsSuffix],
		[cinsFirstName],
		cinsMiddleName,
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
		[cinsGrade],				-- remember the [staff_code]
		[saga_ref]
)
SELECT 
		p.[name]							as [cinsPrefix],
		s.[name]							as [cinsSuffix],
		 stf.first_name	as [cinsFirstName],
		 stf.middle_name   as cinsMiddleName,
		 stf.last_name     as cinsLastName,
			 
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
 
        ''									as [cinsComments],
		1									as [cinnContactCtg],
		(select octnOrigContactTypeID from sma_MST_OriginalContactTypes where octsDscrptn='General' and octnContactCtgID=1) as [cinnContactTypeID],
		368, 
		NULL,        ------stf.Date_Created,
		1									as [cinbStatus],
		0,
		convert(varchar(15),full_name)		as [cinsNickName],
		stf.job_title						as [cinsOccupation],
		NULL								as [saga],
		stf.staff_code						as [cinsGrade], -- Remember it to go to sma_MST_Users
		stf.id								as [saga_ref]
--SELECT  stf.full_name, stf.last_name
FROM  [NeosBillEasterly].[dbo].[staff] stf
LEFT JOIN [NeosBillEasterly]..[prefix] p on stf.prefixid = p.id
LEFT JOIN [NeosBillEasterly]..[suffix] s on s.id = stf.suffixid
where   stf.full_name NOT IN ('S', '', 'Used for case import')    ---and stf.full_name = 'Inserted from 5.x conversion'
     and  stf.first_name  not in ( select cinsFirstName from sma_MST_IndvContacts) 
	 and  stf.last_name not in (select cinsLastName from sma_MST_IndvContacts)

---- select * from  [sma_MST_IndvContacts]

-- (3.2) construct [sma_MST_Users]
IF (select count(*) from sma_mst_users where usrsloginid = 'aadmin') =0
BEGIN
	SET IDENTITY_INSERT sma_mst_users ON

	alter table  [sma_MST_Users]  disable trigger all

 	INSERT INTO [sma_MST_Users]
	(usrnuserid,[usrnContactID],[usrsLoginID],[usrsPassword],[usrsBackColor],[usrsReadBackColor],[usrsEvenBackColor],[usrsOddBackColor],[usrnRoleID],[usrdLoginDate],[usrdLogOffDate],[usrnUserLevel],[usrsWorkstation],[usrnPortno],[usrbLoggedIn],
	[usrbCaseLevelRights],[usrbCaseLevelFilters],[usrnUnsuccesfulLoginCount],[usrnRecUserID],[usrdDtCreated],[usrnModifyUserID],[usrdDtModified],[usrnLevelNo],[usrsCaseCloseColor],[usrnDocAssembly],[usrnAdmin],[usrnIsLocked], [usrbActiveState])     
	SELECT DISTINCT 368, (select cinncontactid FROM sma_mst_Indvcontacts where [cinsFirstName]='Staff' and cinsLastName = 'Unassigned'),'aadmin','2/',null,null,null,null,33,null,null,null,null,null,null,null,null,null,1,GETDATE(),null,null,null,null,null,null,null,1
 
 

	SET IDENTITY_INSERT sma_mst_users OFF
END
alter table dbo.sma_MST_users   enable trigger all
 

INSERT INTO [sma_MST_Users] (
[usrnContactID],[usrsLoginID],[usrsPassword],[usrsBackColor],[usrsReadBackColor],[usrsEvenBackColor],[usrsOddBackColor],[usrnRoleID],[usrdLoginDate],[usrdLogOffDate],[usrnUserLevel],[usrsWorkstation],[usrnPortno],[usrbLoggedIn],
[usrbCaseLevelRights],[usrbCaseLevelFilters],[usrnUnsuccesfulLoginCount],[usrnRecUserID],[usrdDtCreated],[usrnModifyUserID],[usrdDtModified],[usrnLevelNo],[usrsCaseCloseColor],[usrnDocAssembly],[usrnAdmin],[usrnIsLocked],[usrbActiveState],[saga])     

SELECT 
	cinncontactid		as [usrnContactID], 
	convert(varchar(20),staff_code)	as [usrsLoginID],
	'#'				as [usrsPassword],
	null,null,null,null,
	33					as [usrnRoleID],
	null,null,null,null,null,null,null,null,null,
	1					as [usrnRecUserID],
	GETDATE()			as [usrdDtCreated],
	null,null,null,null,null,null,null,
	stf.active			as [usrbActiveState], 
	stf.[id]			as [saga ]
--SELECT  cinnContactID, stf.*
FROM  [NeosBillEasterly].[dbo].[staff] STF
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
	[saga],
	[saga_ref]
)
SELECT										 
	   p.[name]									 as [cinsPrefix],
	   LEFT(s.name, 10)  						 as [cinsSuffix],
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
	    CASE 
           WHEN LEN(s.name) > 10 THEN 'Exceeding Character limit Suffix: ' + s.name   
           ELSE ''   
        END AS [cinsComments],  
        1										 as [cinnContactCtg],
	   (select octnOrigContactTypeID FROM [sma_MST_OriginalContactTypes] where octsDscrptn='General' and octnContactCtgID=1) 
												 as [cinnContactTypeID],
	   case when N.[deceased] = 1 
				    then (select cscnContactSubCtgID from [sma_MST_ContactSubCategory] where cscsDscrptn='Deceased')
			when exists (select * from  [NeosBillEasterly].[dbo].[party] P where P.[namesid] = N.[id] and P.incapacitated = 1) 
				    then (select cscnContactSubCtgID from [sma_MST_ContactSubCategory] where cscsDscrptn='Incompetent')
			when exists (select * from  [NeosBillEasterly].[dbo].[party] P where P.[namesid] = N.[id] and P.minor= 1) 
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
	   NULL										 as saga,
	   n.id										as [saga_ref]
--SELECT max(len( isnull(aka_first,'') + ' ' + isnull(aka_last,'') ))
FROM [NeosBillEasterly]..[names] N
LEFT JOIN  [NeosBillEasterly]..[prefix] p on n.prefixid = p.id
LEFT JOIN  [NeosBillEasterly]..[suffix] s on s.id = n.suffixid
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
		[saga],
		[neos_saga]
	)
SELECT 
    N.[last_long_name]					  as [consName],
    NULL								  as [consWorkPhone],
    isnull('AKA: ' + nullif(convert(varchar,n.aka_full),'') + CHAR(13),'') +
	''									  as [consComments],
    2									  as [connContactCtg],
    (select octnOrigContactTypeID FROM   [sma_MST_OriginalContactTypes] where octsDscrptn='General' and octnContactCtgID=2) as [connContactTypeID],
    (Select usrnUserID from sma_mst_Users u where u.saga = n.staffcreatedid)	  as [connRecUserID],
    date_created						  as [condDtCreated],
    1									  as [conbStatus],		-- Hardcode Status as ACTIVE
    NULL								  as [saga],
	n.id								  as [neos_saga]
--SELECT *
FROM  [NeosBillEasterly].[dbo].[names] N
WHERE N.[person] <> 1


------------------------------------------------------------------------------------------------
---------------------------------------END INSERT CONTACTS--------------------------------------
------------------------------------------------------------------------------------------------