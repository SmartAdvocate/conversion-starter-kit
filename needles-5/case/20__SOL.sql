use BenAbbot_SA
go


alter table [sma_TRN_SOLs] disable trigger all
go

-----

----(2)----
insert into [sma_TRN_SOLs]
	(
		[solnCaseID],
		[solnSOLTypeID],
		[soldSOLDate],
		[soldDateComplied],
		[soldSnCFilingDate],
		[soldServiceDate],
		[solnDefendentID],
		[soldToProcessServerDt],
		[soldRcvdDate],
		[solsType]
	)
	select distinct
		D.defnCaseID	  as [solnCaseID],
		(
			select
				sldnSOLDetID
			from sma_MST_SOLDetails
			where sldnSOLTypeID = 16
				and sldnCaseTypeID = -1
				and sldsDorP = 'D'
		)				  as [solnSOLTypeID],
		case
			when (C.[lim_date] not between '1900-01-01' and '2079-12-31')
				then null
			else C.[lim_date]
		end				  as [soldSOLDate],
		null			  as [soldDateComplied],
		null			  as [soldSnCFilingDate],
		null			  as [soldServiceDate],
		D.defnDefendentID as [solnDefendentID],
		null			  as [soldToProcessServerDt],
		null			  as [soldRcvdDate],
		'D'				  as [solsType]
	from [BenAbbot_Needles].[dbo].[cases_Indexed] C
	join [sma_TRN_Cases] CAS
		on CAS.source_id = CONVERT(VARCHAR(50), C.id)
	join [sma_TRN_Defendants] D
		on D.defnCaseID = CAS.casnCaseID
	where
		C.lim_date is not null
go

-----
alter table [sma_TRN_SOLs] enable trigger all
go

-----


----(Appendix)----
update sma_MST_SOLDetails
set sldnFromIncident = 0
where sldnFromIncident is null
and sldnRecUserID = 368




