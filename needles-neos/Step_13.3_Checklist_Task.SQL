
USE   [SAbilleasterlyLaw]
GO

 
alter table [sma_TRN_TaskNew] disable trigger all
delete from [sma_TRN_TaskNew]
DBCC CHECKIDENT ('[sma_TRN_TaskNew]', RESEED, 0);
alter table [sma_TRN_TaskNew] disable trigger all
 

----(0)----
INSERT INTO [sma_MST_TaskCategory] (tskCtgDescription)
SELECT 'Checklist'
EXCEPT
SELECT tskCtgDescription FROM [sma_MST_TaskCategory] 

/*
select distinct (select top 1 replace(ltrim(DIR.[description]),'>','')) 
FROM [NeosBrianWhite].[dbo].[checklist_dir] DIR 
inner join [NeosBrianWhite].[dbo].[case_checklist] LST on DIR.code=LST.code
where isnull(DIR.[description],'')<>''
except
select tskCtgDescription from [SANeosBrianWhite].[dbo].[sma_MST_TaskCategory] 
GO
*/
---(0)---
if not exists (SELECT * FROM sys.columns WHERE Name = N'saga' AND Object_ID = Object_ID(N'sma_TRN_TaskNew'))
begin
    ALTER TABLE [sma_TRN_TaskNew] ADD [saga] int NULL; 
end
GO

---(1)---
ALTER TABLE [sma_TRN_TaskNew] DISABLE TRIGGER ALL
GO

INSERT INTO [sma_TRN_TaskNew]
(
       [tskCaseID]
      ,[tskDueDate]
      ,[tskStartDate]
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
SELECT DISTINCT
    CAS.casnCaseID																			as [tskCaseID],
    case when CKL.due_date between '1900-01-01' and '2079-06-06' then CKL.due_date else '1900-01-01' end		as [tskDueDate],
    null																					as [tskStartDate],
    null																					as [tskRequestorID],
    (select usrnUserID from sma_MST_Users where saga= convert(varchar(50),CKL.staffassignedid))		as [tskAssigneeId],
  null																					as [tskReminderDays],
     ltrim(CKL.[description])																as [tskDescription],
    ckl.date_created																		as [tskCreatedDt],
    (select usrnUserID from sma_mst_Users where saga = ckl.staffcreatedid)					as tskCreatedUserID,
    (select tskMasterID from sma_mst_Task_Template where tskMasterDetails = 'Custom Task')	as [tskMasterID],
	(select tskCtgID from sma_MST_TaskCategory where tskCtgDescription = 'Checklist')		as [tskCtgID], 
    ltrim(CKL.[description])																as [tskSummary],  --task subject--
    (select uId from PriorityTypes where PriorityType = 'Normal')							as [tskPriority],
	case     
		when CKL.[status]='Done' then (select StatusID from TaskStatusTypes where StatusType = 'Completed' )		
		when CKL.[status]='Open' then (select StatusID from TaskStatusTypes where StatusType = 'In Progress')					
		when CKL.[status]='N/A' then (select StatusID from TaskStatusTypes where StatusType = 'Cancelled')					
		else (select StatusID from TaskStatusTypes where StatusType = 'Not Started')					
	end																						as [tskCompleted], 
    convert(varchar(50),CKL.id)																as [saga]
--SELECT *
FROM [NeosBillEasterly].[dbo].[case_checklist] CKL
JOIN [sma_TRN_Cases] CAS on CAS.Neos_Saga = convert(varchar(50),CKL.casesid)
WHERE isnull(CAS.casdClosingDate,'') = ''
and CKL.due_date between '1900-01-01' and '2079-06-06'
GO

ALTER TABLE [sma_TRN_TaskNew] ENABLE TRIGGER ALL
GO

