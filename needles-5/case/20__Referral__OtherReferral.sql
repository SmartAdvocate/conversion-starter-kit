use BenAbbot_SA
go

/*
alter table [sma_TRN_OtherReferral] disable trigger all
delete [sma_TRN_OtherReferral]
DBCC CHECKIDENT ('[sma_TRN_OtherReferral]', RESEED, 0);
alter table [sma_TRN_OtherReferral] enable trigger all
*/

--(1)--

insert into [sma_TRN_OtherReferral]
	(
		[otrnCaseID],
		[otrnRefContactCtg],
		[otrnRefContactID],
		[otrnRefAddressID],
		[otrnPlaintiffID],
		[otrsComments],
		[otrnUserID],
		[otrdDtCreated]
	) select
		CAS.casnCaseID as [otrnCaseID],
		IOC.CTG		   as [otrnRefContactCtg],
		IOC.CID		   as [otrnRefContactID],
		IOC.AID		   as [otrnRefAddressID],
		-1			   as [otrnPlaintiffID],
		null		   as [otrsComments],
		368			   as [otrnUserID],
		GETDATE()	   as [otrdDtCreated]
	from [BenAbbot_Needles].[dbo].[cases_indexed] C
	join [sma_TRN_cases] CAS
		on CAS.source_id = C.id
	join IndvOrgContacts_Indexed ioc
		on CONVERT(VARCHAR(100), c.referredby_namesid) = ioc.source_id
	where
		ISNULL(CONVERT(VARCHAR(50), C.referredby_namesid), '') <> ''