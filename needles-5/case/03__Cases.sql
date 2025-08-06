use [BenAbbot_SA]
go

alter table [sma_TRN_Cases] disable trigger all
go

insert into [sma_TRN_Cases]
	(
		[cassCaseNumber],
		[casbAppName],
		[cassCaseName],
		[casnCaseTypeID],
		[casnState],
		[casdStatusFromDt],
		[casnStatusValueID],
		[casdsubstatusfromdt],
		[casnSubStatusValueID],
		[casdOpeningDate],
		[casdClosingDate],
		[casnCaseValueID],
		[casnCaseValueFrom],
		[casnCaseValueTo],
		[casnCurrentCourt],
		[casnCurrentJudge],
		[casnCurrentMagistrate],
		[casnCaptionID],
		[cassCaptionText],
		[casbMainCase],
		[casbCaseOut],
		[casbSubOut],
		[casbWCOut],
		[casbPartialOut],
		[casbPartialSubOut],
		[casbPartiallySettled],
		[casbInHouse],
		[casbAutoTimer],
		[casdExpResolutionDate],
		[casdIncidentDate],
		[casnTotalLiability],
		[cassSharingCodeID],
		[casnStateID],
		[casnLastModifiedBy],
		[casdLastModifiedDate],
		[casnRecUserID],
		[casdDtCreated],
		[casnModifyUserID],
		[casdDtModified],
		[casnLevelNo],
		[cassCaseValueComments],
		[casbRefIn],
		[casbDelete],
		[casbIntaken],
		[casnOrgCaseTypeID],
		[CassCaption],
		[cassMdl],
		[office_id],
		[LIP],
		[casnSeriousInj],
		[casnCorpDefn],
		[casnWebImporter],
		[casnRecoveryClient],
		[cas],
		[ngage],
		[casnClientRecoveredDt],
		[CloseReason],
		[saga],
		[source_id],
		[source_db],
		[source_ref]
	)
	select
		c.casenum			  as casscasenumber,
		''					  as casbappname,
		LEFT(case_title, 200) as casscasename,
		(
			select top 1
				cstnCaseSubTypeID
			from [sma_MST_CaseSubType] st
			where st.cstnGroupID = cst.cstnCaseTypeID
				and st.cstsDscrptn = mix.[SmartAdvocate Case Sub Type]
		)					  as casncasetypeid,
		(
			select
				[sttnStateID]
			from [sma_MST_States]
			where [sttsDescription] = (
					select
						StateName
					from conversion.office
				)
		)					  as casnstate,
		GETDATE()			  as casdstatusfromdt,
		(
			select
				cssnStatusID
			from [sma_MST_CaseStatus]
			where csssDescription = 'Presign - Not Scheduled For Sign Up'
		)					  as casnstatusvalueid,
		GETDATE()			  as casdsubstatusfromdt,
		(
			select
				cssnStatusID
			from [sma_MST_CaseStatus]
			where csssDescription = 'Presign - Not Scheduled For Sign Up'
		)					  as casnsubstatusvalueid,
		case
			when (c.date_opened not between '1900-01-01' and '2079-12-31')
				then GETDATE()
			else c.date_opened
		end					  as casdopeningdate,
		case
			when (c.close_date not between '1900-01-01' and '2079-12-31')
				then GETDATE()
			else c.close_date
		end					  as casdclosingdate,
		null				  as [casncasevalueid],
		null				  as [casncasevaluefrom],
		null				  as [casncasevalueto],
		null				  as [casncurrentcourt],
		null				  as [casncurrentjudge],
		null				  as [casncurrentmagistrate],
		0					  as [casncaptionid],
		case_title			  as casscaptiontext,
		1					  as [casbmaincase],
		0					  as [casbcaseout],
		0					  as [casbsubout],
		0					  as [casbwcout],
		0					  as [casbpartialout],
		0					  as [casbpartialsubout],
		0					  as [casbpartiallysettled],
		1					  as [casbinhouse],
		null				  as [casbautotimer],
		null				  as [casdexpresolutiondate],
		null				  as [casdincidentdate],
		0					  as [casntotalliability],
		0					  as [casssharingcodeid],
		(
			select top 1
				[sttnStateID]
			from [sma_MST_States]
			where [sttsDescription] = (
					select
						StateName
					from conversion.office
				)
		)					  as [casnstateid],
		null				  as [casnlastmodifiedby],
		null				  as [casdlastmodifieddate],
		u.usrnUserID		  as casnrecuserid,
		case
			when c.intake_date between '1900-01-01' and '2079-06-06'
				then (
						select
							CAST(CONVERT(DATE, c.intake_date) as DATETIME) + CAST(CONVERT(TIME, c.intake_date) as DATETIME)
					)
			else null
		end					  as casddtcreated,
		null				  as casnmodifyuserid,
		null				  as casddtmodified,
		''					  as casnlevelno,
		''					  as casscasevaluecomments,
		null				  as casbrefin,
		null				  as casbdelete,
		null				  as casbintaken,
		cstnCaseTypeID		  as casnorgcasetypeid -- actual case type
		,
		''					  as casscaption,
		0					  as cassmdl,
		(
			select
				office_id
			from sma_MST_Offices
			where office_name = (
					select
						OfficeName
					from conversion.office
				)
		)					  as office_id,
		null				  as [lip],
		null				  as [casnseriousinj],
		null				  as [casncorpdefn],
		null				  as [casnwebimporter],
		null				  as [casnrecoveryclient],
		null				  as [cas],
		null				  as [ngage],
		null				  as [casnclientrecovereddt],
		null				  as [closereason],
		null				  as [saga],
		c.id				  as [source_id],
		'needles'			  as [source_db],
		'cases_indexed'		  as [source_ref]
	--select *
	from [BenAbbot_Needles].[dbo].[cases_Indexed] c
	--left join [BenAbbot_Needles].[dbo].[user_case_data] u
	--	on u.casenum = c.casenum
	left join [BenAbbot_Needles]..[matter] m
		on m.id = c.matterid
	join caseTypeMixture mix
		on mix.matcode = m.matcode
	left join sma_MST_Users u
		on u.source_id = CONVERT(VARCHAR(MAX), c.staffintakeid)

	left join sma_MST_CaseType cst
		on cst.cststype = mix.[SmartAdvocate Case Type]
			and VenderCaseType = (
				select
					VenderCaseType
				from conversion.office
			)
	order by c.casenum
go

---
alter table [sma_TRN_Cases] enable trigger all
go
---
