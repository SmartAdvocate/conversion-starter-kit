use [BenAbbot_SA]
go

alter table [sma_MST_IndvContacts] disable trigger all
go

/* --------------------------------------------------------------------------------------------------------------
Insert Individual Contacts from [staff]
*/
insert into [sma_MST_IndvContacts]
	(
		[cinsPrefix],
		[cinsSuffix],
		[cinsFirstName],
		[cinsLastName],
		[cinsHomePhone],
		[cinsWorkPhone],
		[cinsSSNNo],
		[cindBirthDate],
		[cindDateOfDeath],
		[cinnGender],
		[cinsMobile],
		[cinsComments],
		[cinnContactCtg],
		[cinnContactTypeID],
		[cinnRecUserID],
		[cindDtCreated],
		[cinbStatus],
		[cinbPreventMailing],
		[cinsNickName],
		[cinsOccupation],
		[saga],
		[source_id],
		[source_db],
		[source_ref]
	)
	select
		p.[name]						as [cinsPrefix],
		s.[name]						as [cinsSuffix],
		case
			when stf.first_name = ''
				then LEFT(dbo.get_firstword(full_name), 30)
			else stf.first_name
		end								as [cinsFirstName],
		case
			when stf.last_name = ''
				then LEFT(dbo.get_lastword(full_name), 40)
			else stf.last_name
		end								as [cinsLastName],
		null							as [cinsHomePhone],
		LEFT(phone_number, 20)			as [cinsWorkPhone],
		null							as [cinsSSNNo],
		null							as [cindBirthDate],
		null							as [cindDateOfDeath],
		case [gender]
			when 1
				then 1
			when 2
				then 2
			else 0
		end								as [cinnGender],
		LEFT(mobile_number, 20)			as [cinsMobile],
		ISNULL('Supervisor: ' + NULLIF(CONVERT(VARCHAR, stf.supervisor), '') + CHAR(13), '') +
		ISNULL('Bar1: ' + NULLIF(CONVERT(VARCHAR, stf.bar1), '') + CHAR(13), '') +
		ISNULL('Bar1 State: ' + NULLIF(CONVERT(VARCHAR, stf.bar_state1), '') + CHAR(13), '') +
		ISNULL('Bar2: ' + NULLIF(CONVERT(VARCHAR, stf.bar2), '') + CHAR(13), '') +
		ISNULL('Bar2 State: ' + NULLIF(CONVERT(VARCHAR, stf.bar_state2), '') + CHAR(13), '') +
		ISNULL('Bar3: ' + NULLIF(CONVERT(VARCHAR, stf.bar3), '') + CHAR(13), '') +
		ISNULL('Bar3 State: ' + NULLIF(CONVERT(VARCHAR, stf.bar_state3), '') + CHAR(13), '') +
		--'Works on Cases: ' + case when stf.works_on_cases = 1 then 'Yes' else 'No' end + CHAR(13) +
		''								as [cinsComments],
		1								as [cinnContactCtg],
		(
			select
				octnOrigContactTypeID
			from sma_MST_OriginalContactTypes
			where octsDscrptn = 'General'
				and octnContactCtgID = 1
		)								as [cinnContactTypeID],
		368,
		GETDATE()						as [cindDtCreated], -- no created field
		1								as [cinbStatus],
		0								as [cinbPreventMailing],
		CONVERT(VARCHAR(15), full_name) as [cinsNickName],
		stf.job_title					as [cinsOccupation],
		null							as [saga],
		stf.id							as [source_id],
		'needles'						as [source_db],
		'staff_' + stf.staff_code		as [source_ref]
	from [BenAbbot_Needles].[dbo].[staff] stf
	left join [BenAbbot_Needles]..[prefix] p
		on stf.prefixid = p.id
	left join [BenAbbot_Needles]..[suffix] s
		on s.id = stf.suffixid
	left join sma_MST_IndvContacts ind
		on ind.source_id = CONVERT(VARCHAR(MAX), stf.id)
	where
		ind.cinnContactID is null



----select *
--from [BenAbbot_Needles]..staff s
--left join conversion.imp_user_map m
--	on s.staff_code = m.StaffCode
--left join [sma_MST_IndvContacts] ind
--	on m.SAContactID = ind.cinnContactID
--where
--	m.StaffCode is null  -- Staff does not exist in imp_user_map
--	and (ind.cinnContactID is null or m.SAContactID is null)  -- No contact in sma_MST_IndvContacts
--	and s.staff_code not in ('aadmin');  -- Exclude 'aadmin'

/* ds 2025-02-07
Identify staff members that are not in imp_user_map and do not have an individual contact


from [BenAbbot_Needles].[dbo].[staff] s
left join [sma_MST_IndvContacts] indv
on indv.source_id = s.staff_code
where cinnContactID is null
*/
go

alter table [sma_MST_IndvContacts] enable trigger all
go