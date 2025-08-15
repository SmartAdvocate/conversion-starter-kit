use Skolrood_SA
go

/* ####################################
1.0 -- Prior/Subsequent Injuries
*/

alter table sma_TRN_PriorInjuries disable trigger all
go

insert into sma_TRN_PriorInjuries
	(
		[prlnInjuryID],
		[prldPrAccidentDt],
		[prldDiagnosis],
		[prlsDescription],
		[prlsComments],
		[prlnPlaintiffID],
		[prlnCaseID],
		[prlnInjuryType],
		[prlnParentInjuryID],
		[prlsInjuryDesc],
		[prlnRecUserID],
		[prldDtCreated],
		[prlnModifyUserID],
		[prldDtModified],
		[prlnLevelNo],
		[prlbCaseRelated],
		[prlbFirmCase],
		[prlsPrCaseNo],
		[prlsInjury]
	)
	select
		null								  as [prlnInjuryID],
		null								  as [prldPrAccidentDt],
		null								  as [prldDiagnosis],
		null								  as [prlsDescription],
		null								  as [prlsComments],
		pln.plnnContactID					  as [prlnPlaintiffID],
		cas.casnCaseID						  as [prlnCaseID],
		3									  as [prlnInjuryType],
		null								  as [prlnParentInjuryID],
		null								  as [prlsInjuryDesc],
		368									  as [prlnRecUserID],
		GETDATE()							  as [prldDtCreated],
		null								  as [prlnModifyUserID],
		null								  as [prldDtModified],
		1									  as [prlnLevelNo],
		0									  as [prlbCaseRelated],
		0									  as [prlbFirmCase],
		null								  as [prlsPrCaseNo],
		'Prior Injuries:' + ud.prior_injuries as [prlsInjury]
	from Skolrood_Needles..user_case_data ud
	join sma_TRN_Cases cas
		on cas.cassCaseNumber = convert(varchar,ud.casenum)
	join sma_TRN_Plaintiff pln
		on pln.plnnCaseID = cas.casnCaseID
		and pln.plnbIsPrimary = 1
	where
		ISNULL(ud.Prior_Injuries, '') <> ''

alter table sma_TRN_PriorInjuries enable trigger all
go