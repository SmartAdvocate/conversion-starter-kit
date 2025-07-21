
use  [SAbilleasterlyLaw]
GO

 
alter table [sma_TRN_TaskNew] disable trigger all
delete from [sma_TRN_TaskNew]
DBCC CHECKIDENT ('[sma_TRN_TaskNew]', RESEED, 0);
alter table [sma_TRN_TaskNew] disable trigger all

 ----- select * from sma_TRN_TaskNew


---(0)---
IF NOT EXISTS (SELECT * FROM sys.columns WHERE Name = N'saga' AND Object_ID = Object_ID(N'sma_TRN_TaskNew'))
BEGIN
    ALTER TABLE  [sma_TRN_TaskNew] ADD [saga] varchar(50); 
END
GO

----------------------------------
--TASK CATEGORY
----------------------------------
INSERT INTO [sma_MST_TaskCategory] (tskCtgDescription)
SELECT DISTINCT isnull(g.code, 'Other')
FROM  [NeosBillEasterly]..neosUsertab2 u
LEFT JOIN  [NeosBillEasterly]..mini_general_dir g on g.id = u.[Type of Record]
WHERE isnull(g.code,'')  <> ''
EXCEPT SELECT tskCtgDescription FROM [sma_MST_TaskCategory] 
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
    case when u.[Date Requested] between '1900-01-01' and '2079-06-06' then u.[Date Requested] else null end					as [tskStartDate],
	case when u.[date received] between '1900-01-01' and '2079-06-06' then u.[date received] 
			 else null end																	as [tskCompletedDt],
    (select usrnUserID From sma_mst_users where saga = convert(varchar(50),u.[Ordered By]))	as [tskRequestorID],
    (select usrnUserID From sma_mst_users where saga = convert(varchar(50),u.[Ordered By]))	as [tskAssigneeId],
    null																					as [tskReminderDays],
    isnull('PrePayment Required: ' + NULLIF(convert(varchar,u.[pre-payment required]),'') + CHAR(13),'') + 
	isnull('Method: ' + NULLIF(convert(varchar,me.code),'') + CHAR(13),'') + 
	isnull('Value Code: ' + NULLIF(convert(varchar,vc.[Description]),'') + CHAR(13),'') + 
    ''																				    as [tskDescription],
    null																				as [tskCreatedDt],
    null																				as tskCreatedUserID,
    (select tskMasterID from sma_mst_Task_Template where tskMasterDetails = 'Custom Task')				as [tskMasterID], 
    (select tskCtgID from sma_MST_TaskCategory where tskCtgDescription = isnull(g.[code],'Other') )				as [tskCtgID], 
    iocp.[Name]																			as [tskSummary],  --task subject--
    (select uId from PriorityTypes where PriorityType = 'Normal')						as [tskPriority],
	case when u.[date received] between '1900-01-01' and '2079-06-06'  then (select StatusID from TaskStatusTypes where StatusType = 'Completed' )
	   else (select StatusID from TaskStatusTypes where StatusType = 'In Progress' ) end				as [tskCompleted], 
    'tab2: ' + convert(Varchar(50),u.tablistid)											as [saga]
--SELECT *
FROM  [NeosBillEasterly]..neosUsertab2 u
LEFT JOIN  [NeosBillEasterly]..mini_general_dir g on g.id = u.[Type of Record]
JOIN [sma_TRN_Cases] CAS on CAS.Neos_Saga = convert(varchar(50),u.casesid)
LEFT JOIN  [NeosBillEasterly]..value_code vc on vc.id = TRY_CAST([value Code] AS UNIQUEIDENTIFIER)
LEFT JOIN  [NeosBillEasterly]..mini_general_dir me on me.id = u.[method]
LEFT JOIN IndvOrgContacts_Indexed iocp on iocp.saga_ref = convert(varchar(50),u.[provider name])
 
--WHERE isnull(g.code,'') IN ('Investigation Report','Declaration Page','Curriculum Vitae','Itemized Subrogation Lien','Video Preservation',
				--			'Policy Limits','Open Records','Osha - California','Maintenance Report','Police Report','Lost Wages','Prior Claim(s) Report' )
GO

ALTER TABLE [sma_TRN_TaskNew] ENABLE TRIGGER ALL
GO

--select * from needlesgma..user_tab2_data where Second_Followed_Up_By