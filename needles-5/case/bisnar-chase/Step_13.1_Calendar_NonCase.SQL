
use [SA]
GO
/*
alter table [sma_TRN_CalendarAppointments] disable trigger all
delete from [sma_TRN_CalendarAppointments]
DBCC CHECKIDENT ('[sma_TRN_CalendarAppointments]', RESEED, 0);
alter table [sma_TRN_CalendarAppointments] disable trigger all

alter table [sma_trn_AppointmentStaff] disable trigger all
delete from [sma_trn_AppointmentStaff]
DBCC CHECKIDENT ('[sma_trn_AppointmentStaff]', RESEED, 0);
alter table [sma_trn_AppointmentStaff] disable trigger all
*/

---(0)---
INSERT INTO [sma_MST_ActivityType] ( attsDscrptn, attnActivityCtg )  
SELECT A.ActivityType, (select atcnPKId FROM sma_MST_ActivityCategory where atcsDscrptn='Non-Case Related Appointment')
FROM
( SELECT DISTINCT 
    [TYPE] as ActivityType 
	FROM [NeedlesNeosBisnarChase].[dbo].[calendar] CAL 
	JOIN [NeedlesNeosBisnarChase].[dbo].[appointment_type] ap on cal.appointmenttypeid = ap.id
	WHERE isnull([TYPE],'') <> '' and isnull(convert(varchar(50),cal.casesid),'') = ''
EXCEPT
SELECT attsDscrptn as ActivityType FROM sma_MST_ActivityType 
	WHERE attnActivityCtg = (select atcnPKId FROM sma_MST_ActivityCategory where atcsDscrptn='Non-Case Related Appointment')
	and isnull(attsDscrptn,'') <> '' 
) A
GO

---(0)---
IF NOT EXISTS (SELECT * FROM sys.columns WHERE Name = N'saga' AND Object_ID = Object_ID(N'sma_TRN_CalendarAppointments'))
BEGIN
    ALTER TABLE [sma_TRN_CalendarAppointments] 
	ADD [saga] [varchar](50) NULL; 
END
GO


----(1)-----
INSERT INTO [sma_TRN_CalendarAppointments]
(
	[FromDate],
	[ToDate],
	[AllDayEvent],
	[AppointmentTypeID],
	[ActivityTypeID],
	[CaseID],
	[LocationContactID],
	[LocationContactGtgID],
	[JudgeID],
	[Comments],
	[StatusID],
	[Address],
	[Subject],
	[RecurranceParentID],[AdjournedID],[RecUserID],[DtCreated],[ModifyUserID],[DtModified],[DepositionType],[Deponants],
	[OriginalAppointmentID],[OriginalAdjournedID],[RecurrenceId],[WorkPlanItemId],[AutoUpdateAppId],[AutoUpdated],[AutoUpdateProviderId],[saga]
)

SELECT 
    case when CAL.[start_date] between '1900-01-01' and '2079-06-06' then cal.[start_date]
	   else '1900-01-01' end																	as [FromDate],
    case when CAL.[stop_date] between '1900-01-01' and '2079-06-06' then cal.stop_date
	   else '1900-01-01' end																	as [ToDate],
	cal.[all_Day_event]																			as [AllDayEvent],
	(select ID FROM [sma_MST_CalendarAppointmentType] WHERE AppointmentType='Non-Case related Office') as [AppointmentTypeID],
	case when isnull(ap.[type],'') <> '' then 
			 (	select attnActivityTypeID from sma_MST_ActivityType 
				where attnActivityCtg=(select atcnPKId FROM sma_MST_ActivityCategory where atcsDscrptn='Non-Case Related Appointment') 
				and attsDscrptn =ap.[type] )
	   else	 (	select attnActivityTypeID from [sma_MST_ActivityType] 
				where attnActivityCtg=(select atcnPKId FROM sma_MST_ActivityCategory where atcsDscrptn='Non-Case Related Appointment') 
				and attsDscrptn = 'Appointment' )
	end					  as [ActivityTypeID], 
	null				  as [CaseID],
	null				  as [LocationContactID],
	null				  as [LocationContactGtgID],
    null				  as [JudgeID],
	isnull('party name: ' + nullif(CAL.[party_name],'') + CHAR(13),'') +
	isnull('short notes: ' + nullif(CAL.[short_notes],'') + CHAR(13),'') +
	isnull('Location: ' + nullif(CAL.[Location],'') + CHAR(13),'') +
	isnull('Docket: ' + nullif(CAL.[docket],'') + CHAR(13),'') +
	''					  as [Comments],
	case 
		when stat.[name] = 'Canceled'	then (select [StatusId] from [sma_MST_AppointmentStatus] where [StatusName]='Canceled')
		when stat.[name] = 'Done'		then (select [StatusId] from [sma_MST_AppointmentStatus] where [StatusName]='Completed')
		when stat.[name] = 'No Show'	then (select [StatusId] from [sma_MST_AppointmentStatus] where [StatusName]='Open')
		when stat.[name] = 'Open'		then (select [StatusId] from [sma_MST_AppointmentStatus] where [StatusName]='Open')
		when stat.[name] = 'Postponed'	then (select [StatusId] from [sma_MST_AppointmentStatus] where [StatusName]='Adjourned')
		when stat.[name] = 'Rescheduled' then (select [StatusId] from [sma_MST_AppointmentStatus] where [StatusName]='Adjourned')
		else (select [StatusId] from [sma_MST_AppointmentStatus] where [StatusName]='Open')
	end					  as [StatusID],
	cal.location		  as [Address],
	left(CAL.subject,120) as [Subject],
	null,null,
	(Select usrnUserID From sma_mst_users where saga = convert(varchar(50),cal.staffcreatedid))		  as [RecUserID],
	CAL.[date_created]		  as [DtCreated],
	(Select usrnUserID From sma_mst_users where saga = convert(varchar(50),cal.staffmodifiedid))	  as [ModifyUserID],
	cal.[date_created]		  as [DtModified],
	null,null,null,null,null,null,null,null,null,
     convert(varchar(50),CAL.id)	  as [SAGA]
FROM [NeedlesNeosBisnarChase].[dbo].[calendar] CAL
LEFT JOIN [NeedlesNeosBisnarChase].[dbo].[appointment_type] ap on cal.appointmenttypeid = ap.id
LEFT JOIN [NeedlesNeosBisnarChase].[dbo].[appointment_status] stat on cal.appointmentstatusid = stat.id
WHERE isnull(convert(varchar(50),CAL.casesid),'') = ''

------(2)-----
INSERT INTO [sma_trn_AppointmentStaff] ( [AppointmentId] ,[StaffContactId], StaffContactCtg ) 
SELECT DISTINCT APP.AppointmentID, ind.cinnContactID, ind.cinnContactCtg
FROM [sma_TRN_CalendarAppointments] APP
JOIN [NeedlesNeosBisnarChase].[dbo].[calendar] CAL on APP.saga=convert(varchar(50),CAL.id)
CROSS APPLY (select [data] from dbo.Split(cal.staff,';') ) x
LEFT JOIN sma_MST_IndvContacts ind on ind.cinsGrade = x.data
WHERE isnull( convert(varchar(50),cal.casesid),'') = ''
