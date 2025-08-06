use [BenAbbot_SA]
go

insert into [sma_TRN_ReferredOut]
	(
		rfosType,
		rfonCaseID,
		rfonPlaintiffID,
		rfonLawFrmContactID,
		rfonLawFrmAddressID,
		rfonAttContactID,
		rfonAttAddressID,
		rfonGfeeAgreement,
		rfobMultiFeeStru,
		rfobComplexFeeStru,
		rfonReferred,
		rfonCoCouncil,
		rfonIsLawFirmUpdateToSend
	) select
		'G'			   as rfostype,
		cas.casnCaseID as rfoncaseid,
		-1			   as rfonplaintiffid,
		case
				when ioc.CTG = 2
					then ioc.CID
				else null
		end			   as rfonlawfrmcontactid,
		case
				when ioc.CTG = 2
					then ioc.AID
				else null
		end			   as rfonlawfrmaddressid,
		case
				when ioc.CTG = 1
					then ioc.CID
				else null
		end			   as rfonattcontactid,
		case
				when ioc.CTG = 1
					then ioc.AID
				else null
		end			   as rfonattaddressid,
		0			   as rfongfeeagreement,
		0			   as rfobmultifeestru,
		0			   as rfobcomplexfeestru,
		1			   as rfonreferred,
		0			   as rfoncocouncil,
		0			   as rfonislawfirmupdatetosend
	from [BenAbbot_Needles].[dbo].[cases_indexed] C
	join [sma_TRN_cases] CAS
		on CAS.source_id = CONVERT(VARCHAR(50), C.id)
	join [IndvOrgContacts_Indexed] IOC
		on IOC.source_id = CONVERT(VARCHAR(50), C.referredto_namesid)
	where
		ISNULL(CONVERT(VARCHAR(50), C.referredto_namesid), '') <> ''

--(2)--
update sma_MST_IndvContacts
set cinnContactTypeID = (select
	 octnOrigContactTypeID
 from [dbo].[sma_MST_OriginalContactTypes]
 where octsDscrptn = 'Attorney'
)
where cinnContactID in (select
	 rfonAttContactID
 from sma_TRN_ReferredOut
 where ISNULL(rfonAttContactID, '') <> ''
)