use [BenAbbot_SA]
go

/*
alter table [sma_TRN_PoliceReports] disable trigger all
delete from [sma_TRN_PoliceReports]
DBCC CHECKIDENT ('[sma_TRN_PoliceReports]', RESEED, 0);
alter table [sma_TRN_PoliceReports] enable trigger all

*/

---
alter table [sma_TRN_PoliceReports] disable trigger all
go

---

/* ------------------------------------------------------------------------------
Helper table [officer_helper]
*/ ------------------------------------------------------------------------------
--if exists (
--		select
--			*
--		from sys.objects
--		where [name] = 'officer_helper'
--			and type = 'U'
--			and schema_id = SCHEMA_ID('conversion')
--	)
--begin
--	drop table conversion.officer_helper
--end

--go

--create table conversion.officer_helper (
--	OfficerCID INT,
--	OfficerCTG INT,
--	OfficerAID INT,
--	source_id  VARCHAR(400)
--)
--go

--create nonclustered index IX_NonClustered_Index_Officer_Helper on [conversion].[officer_helper] (source_id);
--go

---- populate helper
--insert into conversion.officer_helper
--	(
--		OfficerCID,
--		OfficerCTG,
--		OfficerAID,
--		source_id
--	)
--	select distinct
--		i.cinnContactID	 as officercid,
--		i.cinnContactCtg as officerctg,
--		a.addnAddressID	 as officeraid,
--		i.source_id		 as saga
--	--select *
--	from [BenAbbot_Needles].[dbo].[police] p
--	join [sma_MST_IndvContacts] i
--		--ON I.cinsGrade = P.officer
--		--	AND I.cinsPrefix = 'Officer'
--		on i.source_id = p.officer
--			and i.cinsPrefix = 'Officer'
--	join [sma_MST_Address] a
--		on a.addnContactID = i.cinnContactID
--			and a.addnContactCtgID = i.cinnContactCtg
--			and a.addbPrimary = 1

--go

--dbcc dbreindex ('conversion.officer_helper', ' ', 90) with no_infomsgs


-----(0)---
--if exists (
--		select
--			*
--		from sys.objects
--		where name = 'police_helper'
--			and type = 'U'
--			and schema_id = SCHEMA_ID('conversion')
--	)
--begin
--	drop table conversion.police_helper
--end

--go

--create table conversion.police_helper (
--	PoliceCID  INT,
--	PoliceCTG  INT,
--	PoliceAID  INT,
--	police_id  INT,
--	case_num   INT,
--	casnCaseID INT,
--	officerCID INT,
--	officerAID INT
--)
--go

------
--create nonclustered index IX_NonClustered_Index_Police_Helper on [conversion].[police_helper] (police_id);
------
--go

--insert into conversion.police_helper
--	(
--		PoliceCID,
--		PoliceCTG,
--		PoliceAID,
--		police_id,
--		case_num,
--		casnCaseID,
--		officerCID,
--		officerAID
--	)
--	select
--		ioc.CID		   as policecid,
--		ioc.CTG		   as policectg,
--		ioc.AID		   as policeaid,
--		p.police_id	   as police_id,
--		p.case_num,
--		cas.casncaseid as casncaseid,
--		(
--			select
--				h.officercid
--			from conversion.officer_helper h
--			--WHERE H.cinsGrade = P.officer
--			where h.saga = p.officer
--		)			   as officercid,
--		(
--			select
--				h.officeraid
--			from conversion.officer_helper h
--			--WHERE H.cinsGrade = P.officer
--			where h.saga = p.officer
--		)			   as officeraid
--	from [BenAbbot_Needles].[dbo].[police] p
--	join [sma_TRN_cases] cas
--		on cas.cassCaseNumber = p.case_num
--	join [IndvOrgContacts_Indexed] ioc
--		on ioc.SAGA = p.police_id
--go

--dbcc dbreindex ('conversion.Police_Helper', ' ', 90) with no_infomsgs
--go


---(2)---
insert into [sma_TRN_PoliceReports]
	(
		[pornCaseID],
		[porsDepartment],
		[pornPoliceID],
		[pornPoliceAdID],
		[pornReportTypeID],
		[porsReportNo],
		[porsComments],
		[pornPOContactID],
		[pornPOCtgID],
		[pornPOAddressID]
	)

	select
		cas.casnCaseID		   as [pornCaseID],
		ioci_department.Name   as [porsDepartment],
		ioci_officer.CID	   as [pornPoliceID],
		ioci_officer.AID	   as [pornPoliceAdID],
		(
			select
				rt.rptnReportTypeID
			from sma_MST_ReportTypes rt
			where rt.rptsDscrptn = 'Accident Report'
		)					   as [pornReportTypeID],
		LEFT(p.report_num, 30) as [porsReportNo],
		ISNULL('Badge:' + NULLIF(p.badge, '') + CHAR(13), '')
		as [porsComments],
		null				   as [pornPOContactID],		-- obtained from CID
		null				   as [pornPOCtgID],			-- obtained from CTG
		null				   as [pornPOAddressID]			-- obtained from AID
	from [BenAbbot_Needles].[dbo].[police] p
	join sma_TRN_Cases cas
		on cas.source_id = CONVERT(VARCHAR(50), p.casesid)
	join IndvOrgContacts_Indexed ioci_department
		on ioci_department.source_id = CONVERT(VARCHAR(50), p.namesid)
	join IndvOrgContacts_Indexed ioci_officer
		on ioci_officer.source_id = p.officer
			and ioci_officer.source_ref = 'police'

go

---
alter table [sma_TRN_PoliceReports] enable trigger all
go
---