use   [SAbilleasterlyLaw]
GO

 
alter table [sma_TRN_SOLs] disable trigger all
delete [sma_TRN_SOLs]
DBCC CHECKIDENT ('[sma_TRN_SOLs]', RESEED, 0);
alter table [sma_TRN_SOLs] enable trigger all

 alter table [sma_MST_SOLDetails] disable trigger all
delete [sma_MST_SOLDetails]
DBCC CHECKIDENT ('[sma_MST_SOLDetails]', RESEED, 0);
alter table [sma_MST_SOLDetails] enable trigger all   

 
---------------------------------------------------------------------------------
--INSERT SOL 000 FOR CONVERSION ONLY - DO NOT ADD FOR EVERY SINGLE CASE TYPE
---------------------------------------------------------------------------------
IF NOT EXISTS (select * from [sma_MST_SOLDetails] where sldnSOLTypeID = 16 and sldnCaseTypeID = -1 and sldsDorP= 'D')
BEGIN
	INSERT INTO [dbo].[sma_MST_SOLDetails]
			   ([sldnSOLTypeID]
			   ,[sldnCaseTypeID]
			   ,[sldnDefRole]
			   ,[sldnStateID]
			   ,[sldnYears]
			   ,[sldnMonths]
			   ,[sldnDays]
			   ,[sldnSOLDays]
			   ,[sldnRecUserID]
			   ,[slddDtCreated]
			   ,[sldnModifyUserID]
			   ,[slddDtModified]
			   ,[sldnLevelNo]
			   ,[sldsDorP]
			   ,[sldsSOLName]
			   ,[sldbIsIncidDtEffect]
			   ,[sldbDefualt]
			   ,[sldnFromIncident])
	SELECT 16,-1,-1,-1,0,0,0,null,368,getdate(),null,null,null,'D','SOL',0,0,0
END
GO


-----
ALTER TABLE [sma_TRN_SOLs] disable trigger all
GO
-----

----(2)----
INSERT INTO [sma_TRN_SOLs]
(
	[solnCaseID],
	[solnSOLTypeID],
	[soldSOLDate],
	[soldDateComplied],
	[soldSnCFilingDate],
	[soldServiceDate],
	[solnDefendentID],
	[soldToProcessServerDt],
	[soldRcvdDate],
	[solsType]
)
SELECT DISTINCT
    D.defnCaseID		   as [solnCaseID],
    (select sldnSOLDetID From sma_MST_SOLDetails where sldnSOLTypeID = 16 and sldnCaseTypeID = -1 and sldsDorP = 'D' ),			--[solnSOLTypeID],
    case when ( C.[lim_date] not between '1900-01-01' and '2079-12-31' ) then null else C.[lim_date] end as [soldSOLDate],
    null				   as [soldDateComplied],
    NULL				   as [soldSnCFilingDate],
    null				   as [soldServiceDate],
    D.defnDefendentID	   as [solnDefendentID],
    null				   as [soldToProcessServerDt],
    null				   as [soldRcvdDate],
    'D'					   as [solsType]
FROM  [NeosBillEasterly].[dbo].[cases_Indexed] C 
JOIN [sma_TRN_Cases] CAS on CAS.Neos_Saga = convert(varchar(50),C.id)
JOIN [sma_TRN_Defendants] D on D.defnCaseID=CAS.casnCaseID 
WHERE C.lim_date is not null
GO

-----
ALTER TABLE [sma_TRN_SOLs] ENABLE TRIGGER ALL
GO
-----


----(Appendix)----
UPDATE sma_MST_SOLDetails 
SET sldnFromIncident=0
WHERE sldnFromIncident is NULL
and sldnRecUserID=368

---select * from sma_TRN_SOLs