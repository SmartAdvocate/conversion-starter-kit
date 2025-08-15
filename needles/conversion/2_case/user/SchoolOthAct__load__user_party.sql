use Skolrood_SA
go

select
	upd.Education
from Skolrood_Needles..user_party_data upd
where
	ISNULL(upd.Education, '') <> ''


/* ------------------------------------------------------------------------------
Create missing [sma_MST_Grades]
*/

alter table [sma_MST_Grades] disable trigger all
go

insert into [sma_MST_Grades]
	(
		[grdsCode],
		[grdsDescription],
		[grdnRecUserID],
		[grddDtCreated],
		[grdnModifyUserID],
		[grddDtModified],
		[grdnLevelNo]
	)
	select distinct
		null		 as [grdsCode],
		ud.Education as [grdsDescription],
		368			 as [grdnRecUserID],
		GETDATE()	 as [grddDtCreated],
		null		 as [grdnModifyUserID],
		null		 as [grddDtModified],
		null		 as [grdnLevelNo]
	from [Skolrood_Needles].[dbo].[user_party_data] ud
	where
		ISNULL(ud.Education, '') <> ''
		and not exists (
			select
				1
			from [sma_MST_Grades] g
			where g.grdsDescription = ud.Education
		);
alter table [sma_MST_Grades] enable trigger all
go


/* ------------------------------------------------------------------------------
Insert school records
*/

alter table [sma_TRN_SchoolOthAct] disable trigger all
go

insert into [sma_TRN_SchoolOthAct]
	(
		[schnCaseID],
		[schnPlaintiffID],
		[schsType],
		[schdFromDate],
		[schdToDate],
		[schnDays],
		[schnActivityID],
		[schnOrgContactID],
		[schnOrgAddressID],
		[schnContactPersonID],
		[schnContactPersonAddID],
		[schnGradeID],
		[schbLimitedYN],
		[schdMDConfReqDt],
		[schdMDConfRcvdDt],
		[schdOrgConfReqDt],
		[schdOrgConfRcvdDt],
		[schbDocAttached],
		[schsComments],
		[schnLossAmount],
		[schnRecUserID],
		[schdDtCreated],
		[schnModifyUserID],
		[schdDtModified],
		[schnLevelNo],
		[schnauthtodefcoun],
		[schnauthtodefcounDt]
	)
	select
		cas.casnCaseID	  as [schnCaseID],
		pln.plnnContactID as [schnPlaintiffID],
		'S'				  as [schsType],
		null			  as [schdFromDate],
		null			  as [schdToDate],
		null			  as [schnDays],
		0				  as [schnActivityID],
		(
			select
				connContactID
			from [sma_MST_OrgContacts]
			where consName = 'Unidentified School'
		)				  as [schnOrgContactID],
		(
			select
				addnAddressID
			from [sma_MST_Address]
			where addnContactCtgID = 2
				and addnContactID = (
					select
						connContactID
					from [sma_MST_OrgContacts]
					where consName = 'Unidentified School'
				)
		)				  as [schnOrgAddressID],
		null			  as [schnContactPersonID],
		null			  as [schnContactPersonAddID],
		(
			select
				grdnGradeID
			from sma_MST_Grades
			where grdsDescription = ud.Education
		)				  as [schnGradeID],
		0				  as [schbLimitedYN],
		null			  as [schdMDConfReqDt],
		null			  as [schdMDConfRcvdDt],
		null			  as [schdOrgConfReqDt],
		null			  as [schdOrgConfRcvdDt],
		0				  as [schbDocAttached],
		null			  as [schsComments],
		null			  as [schnLossAmount],
		368				  as [schnRecUserID],
		GETDATE()		  as [schdDtCreated],
		null			  as [schdDtModified],
		null			  as [schnModifyUserID],
		1				  as [schnLevelNo],
		0				  as [schnauthtodefcoun],
		null			  as [schnauthtodefcounDt]
	from Skolrood_Needles..user_party_data ud
	join sma_TRN_Cases cas
		on cas.cassCaseNumber = CONVERT(VARCHAR, ud.case_id)
	join sma_TRN_Plaintiff pln
		on pln.plnnCaseID = cas.casnCaseID
			and pln.plnbIsPrimary = 1
	where
		ISNULL(ud.Education, '') <> ''

alter table [sma_TRN_SchoolOthAct] enable trigger all
go