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
SELECT DISTINCT 1,10,
	null,'','','',left(INS.insured,40), 
	null,null,1,null,null,null,1,'','',null,'','',1,'',1,1,null,null,'','',null,0,368,GETDATE(),'',null,0,'','','','',null+null,null,'',Null,'','','','',-1,'',INS.insured
FROM [NeedlesNeosBisnarChase].[dbo].[insurance] INS
WHERE isnull(insured,'')<>''
GO

--
ALTER TABLE [sma_MST_IndvContacts] ENABLE TRIGGER ALL
GO
