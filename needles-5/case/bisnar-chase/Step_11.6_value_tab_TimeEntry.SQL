USE SA
GO

--select * From sma_MST_ActivityCodes
---(0)---
INSERT INTO sma_MST_ActivityCodes ( ActivityCodeDescription )
(
	SELECT DISTINCT VC.[description] 
		FROM [NeedlesNeosBisnarChase].[dbo].[value] V
		JOIN [NeedlesNeosBisnarChase].[dbo].[value_code] VC on VC.id = V.valuecodeid
		WHERE isnull(Vc.code,'') in ( 'TIME' ) 
	EXCEPT 
	SELECT ActivityCodeDescription FROM sma_MST_ActivityCodes
)
GO

---(0)---
INSERT INTO sma_MST_CaseTypeActivityCodeRelationship ( CaseTypeID,ActivityCodeID )
SELECT DISTINCT 0, (select ActivityCodeID from sma_MST_ActivityCodes where ActivityCodeDescription=vc.[description])
FROM [NeedlesNeosBisnarChase].[dbo].[value] V
JOIN [NeedlesNeosBisnarChase].[dbo].[value_code] VC on VC.id = V.valuecodeid
WHERE isnull(VC.code,'') in ( 'TIME' ) 
EXCEPT 
SELECT CaseTypeID,ActivityCodeID FROM sma_MST_CaseTypeActivityCodeRelationship 
GO

---(1)---
ALTER TABLE [sma_TRN_CaseUserTime] DISABLE TRIGGER ALL
GO
  
INSERT INTO [sma_TRN_CaseUserTime] (      
	  [cutnCaseID]
      ,[cutnStaffID]
      ,[cutnActivityID]
      ,[cutdFromDtTime]
      ,[cutdToDtTime]
      ,[cutsDuration]
      ,[cutnBillingRate]
      ,[cutnBillingAmt]
      ,[cutsComments]
      ,[cutnRecUserID]
      ,[cutdDtCreated]
      ,[cutnModifyUserID]
      ,[cutdDtModified]
      ,[cutnLevelNo]
      ,[cutnAddTime]
	 ,[cutnPlaintiffID]
)
SELECT 
	   CAS.casnCaseID		as cutnCaseID,
	   ( select U.usrnUserID from sma_MST_Users U where U.usrsLoginID= convert(varchar(50),v.staffcreatedid) )	   as cutnStaffID ,
	   (select ActivityCodeID from sma_MST_ActivityCodes where ActivityCodeDescription=vc.[description])
							as cutnActivityID,
	   case
		  when v.[start_date] between '1900-01-01' and '2079-06-06' then  convert(datetime,v.[start_date]) 
		  else null
	   end					as cutdFromDtTime,

	   case
		  when v.[stop_date] between '1900-01-01' and '2079-06-06' then  convert(datetime,v.[stop_date]) 
		  else null
	   end					as cutdToDtTime,
	   v.num_periods		as cutsDuration, 
	   v.Rate				as cutnBillingRate,
	   null					as cutnBillingAmt,
	   left(convert(varchar(2000),v.[memo]),2000) 
							as cutsComments,
	   368					as cutnRecUserID,
	   getdate()			as [cutdDtCreated],
	   null					as cutnModifyUserID,
	   null					as cutdDtModified,
	   0					as cutnLevelNo,
	   0				    as cutnAddTime,
	   T.plnnPlaintiffID	as cutnPlaintiffID
--select *
FROM [NeedlesNeosBisnarChase].[dbo].[value] V
JOIN [NeedlesNeosBisnarChase].[dbo].[value_code] VC on VC.id = V.valuecodeid
JOIN [sma_TRN_Cases] CAS on CAS.Needles_saga = convert(varchar(50),v.casesid )
LEFT JOIN [NeedlesNeosBisnarChase].[dbo].Party_Indexed pty on pty.id = v.partyid and v.casesid = pty.casesid
LEFT JOIN [sma_TRN_Plaintiff] T on T.[saga_party]=convert(varchar(50),Pty.TableIndex)
WHERE vc.code = 'TIME'
GO
--
ALTER TABLE [sma_TRN_CaseUserTime] ENABLE TRIGGER ALL
GO

