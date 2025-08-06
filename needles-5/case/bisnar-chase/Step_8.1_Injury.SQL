USE SA
GO

/*
select  td.casesid, ucf.field_title, ucf.field_type, ucf.field_len, td.[data] as FieldData
from user_tab6_data td
JOIN user_case_fields ucf on ucf.id = td.usercasefieldid
WHERE field_title in ('Injuries','Injuries from Accident')
order by td.casesid

*/

----------------------
--TAB 6 INJURIES
----------------------
INSERT INTO [dbo].[sma_TRN_PlaintiffInjury]
           ([plinPlaintiffID]
           ,[plinCaseID]
           ,[plisInjuriesSummary]
           ,[plisPleadingsSummary]
           ,[plisConfinementHospital]
           ,[plisConfinementBed]
           ,[plisConfinementHome]
           ,[plisConfinementIncapacitated]
           ,[plisComment]
           ,[plinRecUserID]
           ,[plidDtCreated]
           ,[plinModifyUserID]
           ,[plidDtModified])
SELECT DISTINCT 
           (Select plnnPlaintiffID from sma_TRN_Plaintiff where plnnCaseID = cas.casnCaseID and plnbIsPrimary = 1),			--(<plinPlaintiffID, int,>
           --PL.plnnPlaintiffID				as plinPlaintiffID,
		   cas.casnCaseID					as plinCaseID,
		  -- isnull('Injuries: ' + nullif(convert(varchar(max),ud.Injuries),'') + CHAR(13),'') +
		   td.[data]						as plisInjuriesSummary,
           null,						--,<plisPleadingsSummary, ntext,>
           NULL,						--,<plisConfinementHospital, varchar(1000),>
           NULL,						--,<plisConfinementBed, varchar(1000),>
           NULL,						--,<plisConfinementHome, varchar(1000),>
           NULL,						--,<plisConfinementIncapacitated, varchar(1000),>
           NULL,						--,<plisComment, varchar(1000),>
           368,							--,<plinRecUserID, int,>
           getdate(),					--,<plidDtCreated, smalldatetime,>
           NULL,						--,<plinModifyUserID, int,>
           NULL							--,<plidDtModified, smalldatetime,>)
--select *
FROM [NeedlesNeosBisnarChase]..user_tab6_Data td
JOIN [NeedlesNeosBisnarChase]..user_case_fields ucf on ucf.id = td.usercasefieldid
JOIN sma_trn_cases cas on convert(varchar(50),td.casesid) = cas.Needles_saga
WHERE field_title in ('Injuries','Injuries from Accident')

/*
----------------------------------
--PREVIOUS INJURY
----------------------------------
INSERT INTO [dbo].[sma_TRN_PriorInjuries]
           ([prlnInjuryID]
           ,[prldPrAccidentDt]
           ,[prldDiagnosis]
           ,[prlsDescription]
           ,[prlsComments]
           ,[prlnPlaintiffID]
           ,[prlnCaseID]
           ,[prlnInjuryType]
           ,[prlnParentInjuryID]
           ,[prlsInjuryDesc]
           ,[prlnRecUserID]
           ,[prldDtCreated]
           ,[prlnModifyUserID]
           ,[prldDtModified]
           ,[prlnLevelNo]
           ,[prlbCaseRelated]
           ,[prlbFirmCase]
           ,[prlsPrCaseNo]
           ,[prlsInjury])
SELECT 
			NULL				as [prlnInjuryID],
			NULL				as [prldPrAccidentDt],	--accident date
           	NULL				as [prldDiagnosis],		--diagnosis date
           	isnull('Prior Injuries: ' + nullif(convert(varchar(max),ud.Prior_Injuries),'') + CHAR(13),'') +
            '' 					as [prlsDescription],	--description	nvarchar -1
           	''					as [prlsComments],		--comments  nvarchar -1
           	(Select plnnPlaintiffID from sma_TRN_Plaintiff where plnnCaseID = cas.casnCaseID and plnbIsPrimary = 1)		as [prlnPlaintiffID],		--plaintiffid
           	cas.casnCaseID		as [prlnCaseID],		--caseid
           	3					as [prlnInjuryType],		
           	NULL				as [prlnParentInjuryID],
           	NULL				as [prlsInjuryDesc],
           	368					as [prlnRecUserID],
           	getdate()			as [prldDtCreated],
           	NULL				as [prlnModifyUserID],
           	NULL				as [prldDtModified],
           	NULL				as [prlnLevelNo],
           	NULL				as [prlbCaseRelated],	--bit
           	NULL				as [prlbFirmCase],		--bit
           	NULL				as [prlsPrCaseNo],
           	NULL				as [prlsInjury]			--Injury nvarchar -1
--select *
FROM [NeedlesNeosBisnarChase]..user_tab10_data ud
JOIN sma_trn_cases cas on convert(varchar,UD.case_id) = cas.cassCaseNumber
WHERE isnull(Prior_Injuries,'') <>''
*/