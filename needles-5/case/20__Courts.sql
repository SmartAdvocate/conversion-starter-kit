use BenAbbot_SA
go

---
alter table [sma_trn_caseJudgeorClerk] disable trigger all
go

alter table [sma_TRN_CourtDocket] disable trigger all
go

alter table [sma_TRN_Courts] disable trigger all
go
---

/*
select * 
FROM [NeedlesNeosBisnarChase].[dbo].[cases] C
WHERE isnull(convert(varchar(50),court_namesid),'')<>''
or isnull(convert(varchar(50),judge_namesid),'')<>''
or isnull(docket,'') <> ''
*/


/* ------------------------------------------------------------------------------
Courts
*/ ------------------------------------------------------------------------------
insert into [sma_TRN_Courts]
	(
		crtnCaseID,
		crtnCourtID,
		crtnCourtAddId,
		crtnIsActive,
		--crtnLevelNo,
		source_id,
		source_db,
		source_ref
	)
	select
		a.casnCaseID as crtncaseid,
		a.CID		 as crtncourtid,
		a.AID		 as crtncourtaddid,
		1			 as crtnisactive,
		--a.judge_link as crtnlevelno, -- remembering judge_link
		null		 as source_id,
		'needles'	 as source_db,
		null		 as source_ref
	from (
		select
			cas.casnCaseID,
			ioc.CID,
			ioc.AID
		--c.judge_link
		from [BenAbbot_Needles].[dbo].[cases] c
		join [sma_TRN_cases] cas
			on cas.source_id = CONVERT(VARCHAR(50), c.id)
		join IndvOrgContacts_Indexed ioc
			on ioc.source_id = CONVERT(VARCHAR(50), c.court_namesid)
		where ISNULL(CONVERT(VARCHAR(50), C.court_Namesid), '') <> ''

		union

		select
			cas.casnCaseID,
			ioc.CID,
			ioc.AID
		--c.judge_link
		from [BenAbbot_Needles].[dbo].[cases] c
		join [sma_TRN_cases] cas
			on cas.source_id = CONVERT(VARCHAR(50), c.id)
		join IndvOrgContacts_Indexed ioc
			on ioc.CTG = 2
			and ioc.[Name] = 'Unidentified Court'
		where ISNULL(CONVERT(VARCHAR(50), court_namesid), '') = ''
			and (ISNULL(CONVERT(VARCHAR(50), judge_namesid), '') <> ''
			or ISNULL(docket, '') <> '')
	) a
go

/* ------------------------------------------------------------------------------
Court Dockets
*/ ------------------------------------------------------------------------------
insert into [sma_TRN_CourtDocket]
	(
		crdnCourtsID,
		crdnIndexTypeID,
		crdnDocketNo,
		crdnPrice,
		crdbActiveInActive,
		crdsEfile,
		crdsComments
	)
	select
		crtnPKCourtsID as crdncourtsid,
		(
			select
				idtnIndexTypeID
			from sma_MST_IndexType
			where idtsDscrptn = 'Index Number'
		)			   as crdnindextypeid,
		case
			when ISNULL(c.docket, '') <> ''
				then LEFT(c.docket, 30)
			else 'Case-' + cas.cassCaseNumber
		end			   as crdndocketno,
		0			   as crdnprice,
		1			   as crdbactiveinactive,
		0			   as crdsefile,
		'Docket Number:' + LEFT(c.docket, 30)
		as crdscomments
	from [sma_TRN_Courts] crt
	join [sma_TRN_cases] cas
		on cas.casnCaseID = crt.crtnCaseID
	join [BenAbbot_Needles].[dbo].[cases] c
		on cas.source_id = CONVERT(VARCHAR(50), c.id)
go

/* ------------------------------------------------------------------------------
Judges
*/ ------------------------------------------------------------------------------
insert into [sma_trn_caseJudgeorClerk]
	(
		crtDocketID,
		crtJudgeorClerkContactID,
		crtJudgeorClerkContactCtgID,
		crtJudgeorClerkRoleID
	)
	select distinct
		crd.crdnCourtDocketID as crtdocketid,
		ioc.CID				  as crtjudgeorclerkcontactid,
		ioc.CTG				  as crtjudgeorclerkcontactctgid,
		(
			select
				octnOrigContactTypeID
			from sma_MST_OriginalContactTypes
			where octsDscrptn = 'Judge'
		)					  as crtjudgeorclerkroleid
	from [sma_TRN_CourtDocket] CRD
	join [sma_TRN_Courts] CRT
		on CRT.crtnPKCourtsID = CRD.crdnCourtsID
	join sma_trn_Cases cas
		on cas.casnCaseID = crt.crtnCaseID
	join [BenAbbot_Needles].[dbo].[cases_indexed] ci
		on CONVERT(VARCHAR(50), ci.id) = cas.source_id
	join IndvOrgContacts_Indexed IOC
		on IOC.source_id = CONVERT(VARCHAR(50), ci.judge_namesid)