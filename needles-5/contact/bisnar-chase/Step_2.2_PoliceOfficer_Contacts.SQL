USE SA
GO

--
ALTER TABLE [sma_MST_IndvContacts] DISABLE TRIGGER ALL
GO
--

INSERT INTO [sma_MST_IndvContacts] (
	[cinbPrimary],[cinnContactTypeID],[cinnContactSubCtgID],[cinsPrefix],[cinsFirstName],[cinsMiddleName],[cinsLastName],[cinsSuffix],[cinsNickName],[cinbStatus],[cinsSSNNo],[cindBirthDate],
	[cinsComments],[cinnContactCtg],[cinnRefByCtgID],[cinnReferredBy],[cindDateOfDeath],[cinsCVLink],[cinnMaritalStatusID],[cinnGender],[cinsBirthPlace],[cinnCountyID],[cinsCountyOfResidence],
	[cinbFlagForPhoto],[cinsPrimaryContactNo],[cinsHomePhone],[cinsWorkPhone],[cinsMobile],[cinbPreventMailing],[cinnRecUserID],[cindDtCreated],[cinnModifyUserID],[cindDtModified],[cinnLevelNo],
	[cinsPrimaryLanguage],[cinsOtherLanguage],[cinbDeathFlag],[cinsCitizenship],[cinsHeight],[cinnWeight],[cinsReligion],[cindMarriageDate],[cinsMarriageLoc],[cinsDeathPlace],[cinsMaidenName],
	[cinsOccupation],[saga],[cinsSpouse],[cinsGrade]) 
SELECT DISTINCT 
    1								as cinbPrimary,
    (select octnOrigContactTypeID from [dbo].[sma_MST_OriginalContactTypes] where octsDscrptn='Police Officer') as cinnContactTypeID,
    null,
    'Officer'						as cinsPrefix,
    dbo.get_firstword(p.[data])	as cinsFirstName,
    ''								as cinsMiddleName,
    dbo.get_lastword(p.[data])		as cinsLastName,
    null							as cinsSuffix,
    null							as cinsNickName, 
    1,null,null,null,1,'','',null,'','',1,'',1,1,null,null,'','',null,0,368,GETDATE(),'',null,0,'','','','',null+null,null,'',Null,'','','','',-1,'',
    p.[data]						as cinsGrade
--select p.[data]
FROM [NeedlesNeosBisnarChase].[dbo].[user_tab6_data] P 
JOIN [NeedlesNeosBisnarChase].[dbo].[user_case_fields] ucf on ucf.id = p.usercasefieldid
WHERE ucf.field_title = 'Officer'
and isnull(p.[data],'')<>''
GO

--
ALTER TABLE [sma_MST_IndvContacts] ENABLE TRIGGER ALL
GO
--