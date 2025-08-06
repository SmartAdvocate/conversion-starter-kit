
use [SA]
GO

/*
alter table [sma_TRN_TaskNew] disable trigger all
delete from [sma_TRN_TaskNew]
DBCC CHECKIDENT ('[sma_TRN_TaskNew]', RESEED, 0);
alter table [sma_TRN_TaskNew] disable trigger all

SELECT tl.casesid,td.tablistid, case when convert(varchar(50),td.[namesid]) IS NULL then td.[data] else convert(varchar(50),td.[namesid]) end as [data], ucf.field_title
	FROM [NeedlesNeosBisnarChase]..user_tab2_data td
	JOIN [NeedlesNeosBisnarChase]..user_tab2_list tl on tl.id = td.tablistid
	JOIN [NeedlesNeosBisnarChase]..user_case_fields ucf on ucf.id = td.usercasefieldid
	WHERE field_Title in ('Account Number', 'Comments', 'Date Received', 'Date Requested', 'For Dates From', 'Make Check Payable To', 'Medical Record#', 'Method', 
					'No Records','Ordered By', 'Pre-Payment Required', 'Provider Name', 'Through', 'Type of Record', 'Value Code' )
*/



----(0)----
INSERT INTO [sma_MST_TaskCategory] (tskCtgDescription)
SELECT DISTINCT isnull([Type of Record], 'Other')
FROM MedProvTaskPivot D
WHERE isnull(d.[Type of Record],'') not in ('Medical Bill', 'Medical Record', 'Medical Record and Bill', 'Hospital Bill', 
					'Hospital Record', 'Ambulance Record/Bill', 'Record and Bill', 'Radiology/Films', 'Pharmacy Record') 
EXCEPT
SELECT tskCtgDescription FROM [sma_MST_TaskCategory] 
GO
---(0)---
IF NOT EXISTS (SELECT * FROM sys.columns WHERE Name = N'saga' AND Object_ID = Object_ID(N'sma_TRN_TaskNew'))
BEGIN
    ALTER TABLE [sma_TRN_TaskNew] ADD [saga] varchar(50); 
END
GO

---(1)---
ALTER TABLE [sma_TRN_TaskNew] DISABLE TRIGGER ALL
GO

INSERT INTO [sma_TRN_TaskNew]
(
       [tskCaseID]
      ,[tskDueDate]
      ,[tskStartDate]
	  ,[tskCompletedDt]
      ,[tskRequestorID]
      ,[tskAssigneeId]
      ,[tskReminderDays]
      ,[tskDescription]
	  ,[tskCreatedDt]
      ,[tskCreatedUserID]
      ,[tskMasterID]
      ,[tskCtgID]
      ,[tskSummary]
      ,[tskPriority]
      ,[tskCompleted]
	 ,[saga]
)  
SELECT 
    CAS.casnCaseID																			as [tskCaseID],
    NULL																					as [tskDueDate], 
    case when d.[Date Requested] between '1900-01-01' and '2079-06-06' then d.[Date Requested] else null end					as [tskStartDate],
	case when D.[date received] between '1900-01-01' and '2079-06-06' then D.[date received] 
			 else null end																	as [tskCompletedDt],
    (select usrnUserID From sma_mst_users u join sma_MST_IndvContacts i on u.usrnContactID = i.cinnContactID where i.cinsGrade = d.[Ordered By])	as [tskRequestorID],
    (select usrnUserID From sma_mst_users u join sma_MST_IndvContacts i on u.usrnContactID = i.cinnContactID where i.cinsGrade = d.[Ordered By])	as [tskAssigneeId],
    null																					as [tskReminderDays],
    isnull('PrePayment Required: ' + NULLIF(convert(varchar,D.[pre-payment required]),'') + CHAR(13),'') + 
	isnull('Method: ' + NULLIF(convert(varchar,D.Method),'') + CHAR(13),'') + 
	isnull('Value Code: ' + NULLIF(convert(varchar,D.[value code]),'') + CHAR(13),'') + 
	isnull('No Records: ' + NULLIF(convert(varchar,D.[no records]),'') + CHAR(13),'') +
	isnull('Account Number: ' + NULLIF(convert(varchar,D.[Account number]),'') + CHAR(13),'') +
	isnull('Make Check Payable To: ' + NULLIF(convert(varchar,ioc.[name]),'') + CHAR(13),'') +
	isnull('Comments: ' + NULLIF(convert(varchar(max),D.Comments),'') + CHAR(13),'') +
	''																				    as [tskDescription],
    null																				as [tskCreatedDt],
    null																				as tskCreatedUserID,
    (select tskMasterID from sma_mst_Task_Template where tskMasterDetails = 'Custom Task')				as [tskMasterID], 
    (select tskCtgID from sma_MST_TaskCategory where tskCtgDescription = isnull(D.[type of record],'Other') )				as [tskCtgID], 
    iocp.[Name]																			as [tskSummary],  --task subject--
    (select uId from PriorityTypes where PriorityType = 'Normal')						as [tskPriority],
	case when D.[date received] between '1900-01-01' and '2079-06-06'  then (select StatusID from TaskStatusTypes where StatusType = 'Completed' )
	   else (select StatusID from TaskStatusTypes where StatusType = 'In Progress' ) end				as [tskCompleted], 
    'tab2: ' + convert(Varchar(50),D.tablistid)											as [saga]
--SELECT *
FROM MedProvTaskPivot D
JOIN [sma_TRN_Cases] CAS on CAS.Needles_saga = convert(varchar(50),D.casesid)
LEFT JOIN IndvOrgContacts_Indexed ioc on ioc.saga = convert(varchar(50),d.[make check payable to])
LEFT JOIN IndvOrgContacts_Indexed iocp on iocp.saga = convert(varchar(50),d.[provider name])
WHERE isnull(d.[Type of Record],'') NOT IN ('Medical Bill', 'Medical Record', 'Medical Record and Bill', 'Hospital Bill', 
					'Hospital Record', 'Ambulance Record/Bill', 'Record and Bill', 'Radiology/Films', 'Pharmacy Record') 
GO

ALTER TABLE [sma_TRN_TaskNew] ENABLE TRIGGER ALL
GO
	 
--select * from needlesgma..user_tab2_data where Second_Followed_Up_By