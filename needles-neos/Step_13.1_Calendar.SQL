USE  [SAbilleasterlyLaw]
GO
 
alter table [sma_TRN_CalendarAppointments] disable trigger all
delete from [sma_TRN_CalendarAppointments]
DBCC CHECKIDENT ('[sma_TRN_CalendarAppointments]', RESEED, 0);
alter table [sma_TRN_CalendarAppointments] disable trigger all

alter table [sma_trn_AppointmentStaff] disable trigger all
delete from [sma_trn_AppointmentStaff]
DBCC CHECKIDENT ('[sma_trn_AppointmentStaff]', RESEED, 0);
alter table [sma_trn_AppointmentStaff] disable trigger all
 

--select * from  [NeosBillEasterly].[dbo].[calendar]

---(0)---
IF NOT EXISTS (SELECT * FROM sys.columns WHERE Name = N'saga' AND Object_ID = Object_ID(N'sma_TRN_CalendarAppointments'))
BEGIN
    ALTER TABLE [sma_TRN_CalendarAppointments] 
	ADD [saga] [varchar](50) NULL; 
END
GO

ALTER taBLE sma_TRN_CalendarAppointments
ALTER COLUMN [Address] varchar(300)
GO

----(0)----
IF EXISTS (SELECT * FROM sys.objects WHERE name='CalendarJudgeStaffCourt' and type='U' )
BEGIN
    DROP TABLE CalendarJudgeStaffCourt
END
GO

SELECT 
    CAL.id				as CalendarId,
    CAS.casnCaseID	    as CaseID, 
    0			    as Judge_Contact,
    0			    as Staff_Contact, 
    0			    as Court_Contact,
    0			    as Court_Address,
    0			    as Party_Contact
INTO CalendarJudgeStaffCourt
FROM [NeosBillEasterly].[dbo].[calendar] CAL
JOIN [sma_TRN_Cases] CAS on CAS.Neos_Saga = convert(varchar(50),CAL.casesid)
WHERE isnull(convert(varchar(50),CAL.casesid),'') <> ''

 UPDATE CalendarJudgeStaffCourt SET Judge_Contact=I.cinnContactID
FROM [NeosBillEasterly].[dbo].[calendar] CAL
JOIN [sma_TRN_Cases] CAS on CAS.Neos_Saga = convert(varchar(50),CAL.casesid)
JOIN [sma_MST_IndvContacts] I on I.saga_ref = convert(varchar(50),CAL.judge_namesid) and isnull(convert(varchar(50),CAL.judge_namesid),'') <> ''
WHERE CAL.id = ID
go  

/*UPDATE CalendarJudgeStaffCourt set Staff_Contact=J.cinnContactID
FROM  [NeosBillEasterly].[dbo].[calendar] CAL
JOIN [sma_TRN_Cases] CAS on CAS.Neos_Saga = convert(varchar(50),CAL.casesid)
JOIN [sma_MST_IndvContacts] J on J.cinsGrade = CAL.staff_id and isnull(CAL.staff_id,'')<>'' 
WHERE CAL.id = ID
*/
UPDATE CalendarJudgeStaffCourt 
SET Court_Contact = i.cid, 
	Court_Address = i.aid
FROM [NeosBillEasterly].[dbo].[calendar] CAL
JOIN [sma_TRN_Cases] CAS on CAS.Neos_Saga = convert(varchar(50),CAL.casesid)
JOIN IndvOrgContacts_Indexed I on I.saga_ref = convert(varchar(50),CAL.court_namesid) and isnull(convert(varchar(50),CAL.court_namesid),'') <> ''
WHERE CAL.id = ID

UPDATE CalendarJudgeStaffCourt 
SET		Party_Contact=i.cid
FROM  [NeosBillEasterly].[dbo].[calendar] CAL
JOIN [sma_TRN_Cases] CAS on CAS.Neos_Saga = convert(varchar(50),CAL.casesid)
JOIN IndvOrgContacts_Indexed I on I.saga_ref = convert(varchar(50),CAL.party_namesid) and isnull(convert(varchar(50),CAL.party_namesid),'') <> ''
WHERE CAL.id = id

---------------------------------------------
--ACTIVITY TYPES
---------------------------------------------
INSERT INTO [sma_MST_ActivityType] ( attsDscrptn, attnActivityCtg )  
SELECT A.ActivityType, (select atcnPKId FROM sma_MST_ActivityCategory where atcsDscrptn='Case-Related Appointment')
FROM
(
SELECT DISTINCT 
    [TYPE] as ActivityType 
FROM  [NeosBillEasterly].[dbo].[calendar] CAL 
JOIN  [NeosBillEasterly].[dbo].[appointment_type] ap on cal.appointmenttypeid = ap.id
WHERE isnull([TYPE],'') <> ''
EXCEPT
SELECT 
    attsDscrptn as ActivityType
FROM sma_MST_ActivityType 
WHERE attnActivityCtg = (select atcnPKId FROM sma_MST_ActivityCategory where atcsDscrptn='Case-Related Appointment')
and isnull(attsDscrptn,'') <> '' 
) A
GO


ALTER TABLE [sma_TRN_CalendarAppointments] DISABLE TRIGGER ALL
GO

--sp_help [sma_TRN_CalendarAppointments]
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
	(select ID FROM [sma_MST_CalendarAppointmentType] where AppointmentType='Case-related')		as [AppointmentTypeID],
	case
	   when isnull(ap.[type],'') <> '' then 
			 (	select attnActivityTypeID from sma_MST_ActivityType 
				where attnActivityCtg=(select atcnPKId FROM sma_MST_ActivityCategory where atcsDscrptn='Case-Related Appointment') 
				and attsDscrptn = ap.[type] )
	   else	 (	select attnActivityTypeID from [sma_MST_ActivityType] 
				where attnActivityCtg=(select atcnPKId FROM sma_MST_ActivityCategory where atcsDscrptn='Case-Related Appointment') 
				and attsDscrptn = 'Appointment' )
	end					      as [ActivityTypeID], 
	CAS.casnCaseID			  as [CaseID],
	MAP.Court_Contact		  as [LocationContactID],
	2					      as [LocationContactGtgID],
	MAP.Judge_Contact		  as [JudgeID],
	isnull('party name: ' + nullif(CAL.[party_name],'') + CHAR(13),'') +
	isnull('short notes: ' + nullif(CAL.[short_notes],'') + CHAR(13),'') +
	isnull('Location: ' + nullif(CAL.[Location],'') + CHAR(13),'') +
	isnull('Docket: ' + nullif(CAL.[docket],'') + CHAR(13),'') +
	''						  as [Comments],
	case 
		when stat.[name] = 'Canceled'	then (select [StatusId] from [sma_MST_AppointmentStatus] where [StatusName]='Canceled')
		when stat.[name] = 'Done'		then (select [StatusId] from [sma_MST_AppointmentStatus] where [StatusName]='Completed')
		when stat.[name] = 'No Show'	then (select [StatusId] from [sma_MST_AppointmentStatus] where [StatusName]='Open')
		when stat.[name] = 'Open'		then (select [StatusId] from [sma_MST_AppointmentStatus] where [StatusName]='Open')
		when stat.[name] = 'Postponed'	then (select [StatusId] from [sma_MST_AppointmentStatus] where [StatusName]='Adjourned')
		when stat.[name] = 'Rescheduled' then (select [StatusId] from [sma_MST_AppointmentStatus] where [StatusName]='Adjourned')
		else (select [StatusId] from [sma_MST_AppointmentStatus] where [StatusName]='Open')
	end						  as [StatusID],
	cal.[Location]			  as [Address],	--200
	left(CAL.[subject],120)	  as [Subject],	--nvarchar 240
	null,null,
	(Select usrnUserID From sma_mst_users where saga = convert(varchar(50),cal.staffcreatedid))		  as [RecUserID],
	CAL.[date_created]		  as [DtCreated],
	(Select usrnUserID From sma_mst_users where saga = convert(varchar(50),cal.staffmodifiedid))	  as [ModifyUserID],
	cal.[date_created]		  as [DtModified],
	null,null,null,null,null,null,null,null,null,
	convert(varchar(50),CAL.id)		as [saga]
--select max(len(cal.location))
FROM  [NeosBillEasterly].[dbo].[calendar] CAL
LEFT JOIN  [NeosBillEasterly].[dbo].[appointment_type] ap on cal.appointmenttypeid = ap.id
LEFT JOIN  [NeosBillEasterly].[dbo].[appointment_status] stat on cal.appointmentstatusid = stat.id
JOIN [sma_TRN_Cases] CAS on CAS.Neos_Saga = convert(varchar(50),CAL.casesid)
JOIN CalendarJudgeStaffCourt MAP on MAP.CalendarId = convert(varchar(50),CAL.id)
WHERE isnull(convert(varchar(50),CAL.casesid),'') <> ''
GO

ALTER TABLE [sma_TRN_CalendarAppointments] ENABLE TRIGGER ALL
GO


----(2)-----
INSERT INTO [sma_trn_AppointmentStaff] ( [AppointmentId] ,[StaffContactId], StaffContactCtg ) 
SELECT DISTINCT APP.AppointmentID, ind.cinnContactID, ind.cinnContactCtg
FROM [sma_TRN_CalendarAppointments] APP
JOIN  [NeosBillEasterly].[dbo].[calendar] CAL on APP.saga=convert(varchar(50),CAL.id)
CROSS APPLY (select [data] from dbo.Split(cal.staff,';') ) x
LEFT JOIN sma_MST_IndvContacts ind on ind.cinsGrade = x.data
WHERE isnull( convert(varchar(50),cal.casesid),'') <> ''

