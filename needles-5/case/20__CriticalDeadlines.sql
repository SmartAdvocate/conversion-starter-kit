use BenAbbot_SA
go

alter table [sma_TRN_CriticalDeadlines] disable trigger all
-----

/* ------------------------------------------------------------------------------
Critical Deadline Types
*/ ------------------------------------------------------------------------------
insert into [sma_MST_CriticalDeadlineTypes]
	(
		cdtsDscrptn,
		cdtbActive
	)
	select distinct
		[label],
		1
	from [BenAbbot_Needles]..[date_labels]
	except
	select
		cdtsDscrptn,
		cdtbActive
	from [sma_MST_CriticalDeadlineTypes]
	where
		cdtbActive = 1


/* ------------------------------------------------------------------------------
Critical Deadlines
*/ ------------------------------------------------------------------------------
insert into [sma_TRN_CriticalDeadlines]
	(
		[crdnCaseID],
		[crdnCriticalDeadlineTypeID],
		[crddDueDate],
		[crdsRequestFrom],
		[ResponderUID]
	)
	select
		CAS.casnCaseID								as [crdnCaseID],
		(
			select
				cdtnCriticalTypeID
			from [sma_MST_CriticalDeadlineTypes]
			where cdtbActive = 1
				and cdtsDscrptn = dl.[label]
		)											as [crdnCriticalDeadlineTypeID],
		case
			when C.casedate between '1900-01-01' and '2079-06-01'
				then C.casedate
			else null
		end											as [crddDueDate],
		CONVERT(VARCHAR, aci.UniqueContactId) + ';' as [crdsRequestFrom],
		CONVERT(VARCHAR, aci.UniqueContactId)		as [ResponderUID]
	from [BenAbbot_Needles]..[case_dates] C
	join [BenAbbot_Needles]..date_labels dl
		on c.datelabelid = dl.id
	join [sma_TRN_cases] CAS
		on CAS.source_id = CONVERT(VARCHAR(50), c.casesid)
	left join sma_TRN_Plaintiff p
		on p.plnnCaseID = cas.casncaseid
	join sma_MST_AllContactInfo aci
		on ContactCtg = plnnContactCtg
			and ContactId = plnnContactID
	where
		ISNULL(c.casedate, '') <> ''


-----
alter table [sma_TRN_CriticalDeadlines] enable trigger all
go

-----


---(Appendix)---
alter table sma_TRN_CriticalDeadlines disable trigger all
go

update [sma_TRN_CriticalDeadlines]
set crddCompliedDate = GETDATE()
where crddDueDate < GETDATE()
go

alter table sma_TRN_CriticalDeadlines enable trigger all
go