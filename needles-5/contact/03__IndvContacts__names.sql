use BenAbbot_SA
go

/* --------------------------------------------------------------------------------------------------------------
Insert [sma_Mst_ContactRace] from [race]
*/

--insert into sma_MST_ContactRace
--	(
--		RaceDesc
--	)
--	select distinct
--		race_name
--	from [BenAbbot_Needles]..race
--	except
--	select
--		RaceDesc
--	from sma_Mst_ContactRace
--go

/* --------------------------------------------------------------------------------------------------------------
Insert Individual Contacts from [names]
*/

alter table [sma_MST_IndvContacts] disable trigger all
go

insert into [sma_MST_IndvContacts]
	(
		[cinsPrefix],
		[cinsSuffix],
		[cinsFirstName],
		[cinsMiddleName],
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
		[cinnContactSubCtgID],
		[cinnRecUserID],
		[cindDtCreated],
		[cinbStatus],
		[cinbPreventMailing],
		[cinsNickName],
		[cinsPrimaryLanguage],
		[cinsOtherLanguage],
		[saga],
		[source_id],
		[source_db],
		[source_ref]
	)
	select
		p.[name]										   as [cinsPrefix],
		s.[name]										   as [cinsSuffix],
		CONVERT(VARCHAR(30), N.[first_name])			   as [cinsFirstName],
		CONVERT(VARCHAR(30), N.[initial])				   as [cinsMiddleName],
		CONVERT(VARCHAR(40), N.[last_long_name])		   as [cinsLastName],
		null											   as [cinsHomePhone],
		null											   as [cinsWorkPhone],
		LEFT(n.[ss_number], 20)							   as [cinsssnno],
		case
			when (n.[date_of_birth] not between '1900-01-01' and '2079-12-31')
				then GETDATE()
			else n.[date_of_birth]
		end												   as [cindbirthdate],
		case
			when (n.[date_of_death] not between '1900-01-01' and '2079-12-31')
				then GETDATE()
			else n.[date_of_death]
		end												   as [cinddateofdeath],
		case
			when N.[gender] = 1
				then 1
			when N.[gender] = 2
				then 2
			else 0
		end												   as [cinnGender],
		null											   as [cinsmobile],
		''												   as [cinscomments],
		1												   as [cinncontactctg],
		(
			select
				octnOrigContactTypeID
			from [sma_MST_OriginalContactTypes]
			where octsDscrptn = 'General'
				and octnContactCtgID = 1
		)												   as [cinncontacttypeid],
		case
			when N.[deceased] = 1
				then (
						select
							cscnContactSubCtgID
						from [sma_MST_ContactSubCategory]
						where cscsDscrptn = 'Deceased'
					)
			when exists (
					select
						*
					from [BenAbbot_Needles].[dbo].[party] P
					where P.[namesid] = N.[id]
						and P.incapacitated = 1
				)
				then (
						select
							cscnContactSubCtgID
						from [sma_MST_ContactSubCategory]
						where cscsDscrptn = 'Incompetent'
					)
			when exists (
					select
						*
					from [BenAbbot_Needles].[dbo].[party] P
					where P.[namesid] = N.[id]
						and P.minor = 1
				)
				then (
						select
							cscnContactSubCtgID
						from [sma_MST_ContactSubCategory]
						where cscsDscrptn = 'Infant'
					)
			else (
					select
						cscnContactSubCtgID
					from [sma_MST_ContactSubCategory]
					where cscsDscrptn = 'Adult'
				)
		end												   as cinnContactSubCtgID,
		(
			select
				usrnUserID
			from sma_mst_Users u
			where u.source_id = CONVERT(VARCHAR(MAX), n.staffcreatedid)
		)												   as cinnRecUserID,
		n.date_created									   as cinddtcreated,
		1												   as [cinbstatus],
		0												   as [cinbpreventmailing],
		ISNULL(aka_first, '') + ' ' + ISNULL(aka_last, '') as [cinsNickName],
		null											   as [cinsprimarylanguage],
		null											   as [cinsotherlanguage],
		null											   as saga,
		n.[id]											   as source_id,
		'needles'										   as source_db,
		'names'											   as source_ref
	from [BenAbbot_Needles]..[names] n
	left join [BenAbbot_Needles]..[prefix] p
		on n.prefixid = p.id
	left join [BenAbbot_Needles]..[suffix] s
		on s.id = n.suffixid
	where
		N.[person] = 1

go

alter table [sma_MST_IndvContacts] enable trigger all
go