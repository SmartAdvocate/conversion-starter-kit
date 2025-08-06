use [BenAbbot_SA]
go

--set quoted_identifier on;

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
if not exists (
		select
			*
		from sys.columns
		where Name = N'source_id'
			and object_id = OBJECT_ID(N'sma_TRN_CalendarAppointments')
	)
begin
	alter table [sma_TRN_CalendarAppointments] add [source_id] [VARCHAR](100) null;
end

go


/* ------------------------------------------------------------------------------
Helper table [CalendarJudgeStaffCourt]
*/ ------------------------------------------------------------------------------
if exists (
		select
			*
		from sys.objects
		where name = 'CalendarJudgeStaffCourt'
			and type = 'U'
	)
begin
	drop table CalendarJudgeStaffCourt
end

go

-- Construct table
select
	cal.id		   as calendarid,
	cas.casnCaseID as caseid,
	0			   as judge_contact,
	0			   as staff_contact,
	0			   as court_contact,
	0			   as court_address,
	0			   as party_contact
into CalendarJudgeStaffCourt
from [BenAbbot_Needles].[dbo].[calendar] cal
join [sma_TRN_Cases] CAS
	on CAS.source_id = CONVERT(VARCHAR(50), CAL.casesid)
where
	ISNULL(CONVERT(VARCHAR(50), CAL.casesid), '') <> ''

-- Update Judge_Contact with cinnContactID from [sma_MST_IndvContacts]
-- calendar.judge_link = on [sma_MST_IndvContacts].saga
update CalendarJudgeStaffCourt
set judge_contact = I.cinnContactID
from [BenAbbot_Needles].[dbo].[calendar] cal
join [sma_TRN_Cases] CAS
	on CAS.source_id = CONVERT(VARCHAR(50), CAL.casesid)
join [sma_MST_IndvContacts] I
	on I.source_id = CONVERT(VARCHAR(50), CAL.judge_namesid)
	and ISNULL(CONVERT(VARCHAR(50), CAL.judge_namesid), '') <> ''
where CAL.id = ID

-- Set Staff_Contact [sma_MST_IndvContacts].cinnContactID
-- calendar.staff_id = [sma_MST_IndvContacts].cinsGrade
--update CalendarJudgeStaffCourt
--set Staff_Contact = J.cinnContactID
--from [BenAbbot_Needles].[dbo].[calendar] cal
--join [sma_TRN_Cases] cas
--	on cas.cassCaseNumber = cal.casenum
--join [sma_MST_IndvContacts] j
--	on j.source_id = cal.staff_id
--	and ISNULL(cal.staff_id, '') <> ''
--where cal.calendar_id = CalendarId

-- Set Court_Contact to [sma_MST_OrgContacts].connContactID 
-- Set Court_Address to [sma_MST_Address].addnAddressID
update CalendarJudgeStaffCourt
set court_contact = i.CID,
	court_address = i.aid
from [BenAbbot_Needles].[dbo].[calendar] cal
join [sma_TRN_Cases] CAS
	on CAS.source_id = CONVERT(VARCHAR(50), CAL.casesid)
join IndvOrgContacts_Indexed I
	on I.source_id = CONVERT(VARCHAR(50), CAL.court_namesid)
	and ISNULL(CONVERT(VARCHAR(50), CAL.court_namesid), '') <> ''
where CAL.id = ID

-- Set Party_Contact to [sma_MST_IndvContacts].cinnContactID
update CalendarJudgeStaffCourt
set party_contact = i.CID
from [BenAbbot_Needles].[dbo].[calendar] cal
join [sma_TRN_Cases] CAS
	on CAS.source_id = CONVERT(VARCHAR(50), CAL.casesid)
join IndvOrgContacts_Indexed I
	on I.source_id = CONVERT(VARCHAR(50), CAL.party_namesid)
	and ISNULL(CONVERT(VARCHAR(50), CAL.party_namesid), '') <> ''
where CAL.id = id


/* ------------------------------------------------------------------------------
Activity Types
*/ ------------------------------------------------------------------------------
insert into [sma_MST_ActivityType]
	(
		attsDscrptn,
		attnActivityCtg
	)
	select
		a.activitytype,
		(
			select
				atcnPKId
			from sma_MST_ActivityCategory
			where atcsDscrptn = 'Case-Related Appointment'
		)
	from (
		select distinct
			at.type as activitytype
		from [BenAbbot_Needles].[dbo].[calendar] cal
		join BenAbbot_Needles..appointment_type at
			on cal.appointmenttypeid = at.id
		where ISNULL(at.type, '') <> ''
		except
		select
			attsDscrptn as activitytype
		from sma_MST_ActivityType
		where attnActivityCtg = (
				select
					atcnPKId
				from sma_MST_ActivityCategory
				where atcsDscrptn = 'Case-Related Appointment'
			)
			and ISNULL(attsDscrptn, '') <> ''
	) a
go


/* ------------------------------------------------------------------------------
Calendar Appointments
*/ ------------------------------------------------------------------------------
alter table [sma_TRN_CalendarAppointments] disable trigger all

insert into [sma_TRN_CalendarAppointments]
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
		[subject],
		[RecurranceParentID],
		[AdjournedID],
		[RecUserID],
		[DtCreated],
		[ModifyUserID],
		[DtModified],
		[DepositionType],
		[Deponants],
		[OriginalAppointmentID],
		[OriginalAdjournedID],
		[RecurrenceId],
		[WorkPlanItemId],
		[AutoUpdateAppId],
		[AutoUpdated],
		[AutoUpdateProviderId],
		[source_id]
	)
	select
		case
			when CAL.[start_date] between '1900-01-01' and '2079-06-06'
				then cal.[start_date]
			else '1900-01-01'
		end							 as [FromDate],
		case
			when CAL.[stop_date] between '1900-01-01' and '2079-06-06'
				then cal.stop_date
			else '1900-01-01'
		end							 as [ToDate],
		cal.[all_day_event]			 as [AllDayEvent],
		(
			select
				ID
			from [sma_MST_CalendarAppointmentType]
			where AppointmentType = 'Case-related'
		)							 as [appointmenttypeid],
		case
			when ISNULL(ap.[type], '') <> ''
				then (
						select
							attnActivityTypeID
						from sma_MST_ActivityType
						where attnActivityCtg = (
								select
									atcnPKId
								from sma_MST_ActivityCategory
								where atcsDscrptn = 'Case-Related Appointment'
							)
							and attsDscrptn = ap.[type]
					)
			else (
					select
						attnActivityTypeID
					from [sma_MST_ActivityType]
					where attnActivityCtg = (
							select
								atcnPKId
							from sma_MST_ActivityCategory
							where atcsDscrptn = 'Case-Related Appointment'
						)
						and attsDscrptn = 'Appointment'
				)
		end							 as [ActivityTypeID],
		cas.casnCaseID				 as [caseid],
		map.court_contact			 as [locationcontactid],
		2							 as [locationcontactgtgid],
		map.judge_contact			 as [judgeid],
		ISNULL('party name: ' + NULLIF(CAL.[party_name], '') + CHAR(13), '') +
		ISNULL('short notes: ' + NULLIF(CAL.[short_notes], '') + CHAR(13), '') +
		ISNULL('Location: ' + NULLIF(CAL.[location], '') + CHAR(13), '') +
		ISNULL('Docket: ' + NULLIF(CAL.[docket], '') + CHAR(13), '') +
		''							 as [Comments],
		case
			when stat.[name] = 'Canceled'
				then (
						select
							[StatusId]
						from [sma_MST_AppointmentStatus]
						where [StatusName] = 'Canceled'
					)
			when stat.[name] = 'Done'
				then (
						select
							[StatusId]
						from [sma_MST_AppointmentStatus]
						where [StatusName] = 'Completed'
					)
			when stat.[name] = 'No Show'
				then (
						select
							[StatusId]
						from [sma_MST_AppointmentStatus]
						where [StatusName] = 'Open'
					)
			when stat.[name] = 'Open'
				then (
						select
							[StatusId]
						from [sma_MST_AppointmentStatus]
						where [StatusName] = 'Open'
					)
			when stat.[name] = 'Postponed'
				then (
						select
							[StatusId]
						from [sma_MST_AppointmentStatus]
						where [StatusName] = 'Adjourned'
					)
			when stat.[name] = 'Rescheduled'
				then (
						select
							[StatusId]
						from [sma_MST_AppointmentStatus]
						where [StatusName] = 'Adjourned'
					)
			else (
					select
						[StatusId]
					from [sma_MST_AppointmentStatus]
					where [StatusName] = 'Open'
				)
		end							 as [StatusID],
		null						 as [address],
		LEFT(cal.[subject], 120)	 as [subject],
		null,
		null,
		(
			select
				usrnUserID
			from sma_mst_users
			where source_id = CONVERT(VARCHAR(50), cal.staffcreatedid)
		)							 as [RecUserID],
		cal.[date_created]			 as [dtcreated],
		(
			select
				usrnUserID
			from sma_mst_users
			where source_id = CONVERT(VARCHAR(50), cal.staffmodifiedid)
		)							 as [ModifyUserID],
		cal.date_modified			 as [dtmodified],
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		CONVERT(VARCHAR(50), cal.id) as source_id
	from [BenAbbot_Needles].[dbo].[calendar] cal
	left join [BenAbbot_Needles].[dbo].[appointment_type] ap
		on cal.appointmenttypeid = ap.id
	left join [BenAbbot_Needles].[dbo].[appointment_status] stat
		on cal.appointmentstatusid = stat.id
	join [sma_TRN_Cases] CAS
		on CAS.source_id = CONVERT(VARCHAR(50), CAL.casesid)
	join CalendarJudgeStaffCourt MAP
		on MAP.calendarid = CONVERT(VARCHAR(50), CAL.id)
	where
		ISNULL(CONVERT(VARCHAR(50), CAL.casesid), '') <> ''
go

alter table [sma_TRN_CalendarAppointments] enable trigger all

/* ------------------------------------------------------------------------------
Appointment Staff
*/ ------------------------------------------------------------------------------
insert into [sma_trn_AppointmentStaff]
	(
		[AppointmentId],
		[StaffContactId],
		StaffContactCtg
	)
	select distinct
		APP.AppointmentID,
		ind.cinnContactID,
		ind.cinnContactCtg
	from [sma_TRN_CalendarAppointments] APP
	join [BenAbbot_Needles].[dbo].[calendar] CAL
		on APP.source_id = CONVERT(VARCHAR(50), CAL.id)
	cross apply (
		select
			[data]
		from dbo.Split(cal.staff, ';')
	) x
	left join sma_MST_IndvContacts ind
		on ind.source_id = x.data
	where
		ISNULL(CONVERT(VARCHAR(50), cal.casesid), '') <> ''



/*
----(3)-----
insert into [SA].[dbo].[sma_trn_AppointmentStaff] ( [AppointmentId] ,[StaffContactId] ) 
select APP.AppointmentID, MAP.Party_Contact
from [SA].[dbo].[sma_TRN_CalendarAppointments] APP
inner join [BenAbbot_Needles].[dbo].[calendar] CAL on APP.saga='Case-related:'+convert(varchar,CAL.calendar_id)
inner join CalendarJudgeStaffCourt MAP on MAP.CalendarId=CAL.calendar_id
*/
