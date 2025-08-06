USE  [SAbilleasterlyLaw]
GO

 alter table sma_TRN_PlaintiffInjury disable trigger all
delete from sma_TRN_PlaintiffInjury
DBCC CHECKIDENT ('sma_TRN_PlaintiffInjury', RESEED, 0);
alter table sma_TRN_PlaintiffInjury enable trigger all
go



/*select  td.casesid, ucf.field_title, ucf.field_type, ucf.field_len, td.[data] as FieldData
from user_tab_data td
JOIN user_case_fields ucf on ucf.id = td.usercasefieldid
WHERE field_title in ('Injuries','Injuries from Accident')
order by td.casesid   */

----------------------
--TAB 7 INJURIES
----------------------
/*INSERT INTO [dbo].[sma_TRN_PlaintiffInjury]
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
FROM [NeosBillEasterly]..user_tab7_Data td
JOIN [NeosBillEasterly]..user_case_fields ucf on ucf.id = td.usercasefieldid
JOIN sma_trn_cases cas on convert(varchar(50),td.casesid) = cas.Neos_Saga
 WHERE field_title in ('Injuries','Injured Body Part(s)')    */

 WITH RankedPlaintiffs AS (
    SELECT 
        plnnPlaintiffID, 
        plnnCaseID, 
        ROW_NUMBER() OVER (PARTITION BY plnnCaseID ORDER BY plnnPlaintiffID) AS RowNum
    FROM sma_TRN_Plaintiff
    WHERE plnbIsPrimary = 1
)
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
           rp.plnnPlaintiffID,			-- (<plinPlaintiffID, int,>)
           cas.casnCaseID,				-- (<plinCaseID, int,>)
           td.[data] AS plisInjuriesSummary,	-- Injuries Summary
           NULL,						-- (<plisPleadingsSummary, ntext>)
           NULL,						-- (<plisConfinementHospital, varchar(1000>)
           NULL,						-- (<plisConfinementBed, varchar(1000>)
           NULL,						-- (<plisConfinementHome, varchar(1000>)
           NULL,						-- (<plisConfinementIncapacitated, varchar(1000>)
           NULL,						-- (<plisComment, varchar(1000>)
           368,							-- (<plinRecUserID, int>)
           GETDATE(),					-- (<plidDtCreated, smalldatetime>)
           NULL,						-- (<plinModifyUserID, int>)
           NULL							-- (<plidDtModified, smalldatetime>)
FROM [NeosBillEasterly]..user_tab7_Data td
JOIN [NeosBillEasterly]..user_case_fields ucf ON ucf.id = td.usercasefieldid
JOIN sma_trn_cases cas ON CONVERT(VARCHAR(50), td.casesid) = cas.Neos_Saga
JOIN RankedPlaintiffs rp ON rp.plnnCaseID = cas.casnCaseID AND rp.RowNum = 1
WHERE field_title IN ('Injuries', 'Injured Body Part(s)');



select * from [NeosBillEasterly]..user_case_fields