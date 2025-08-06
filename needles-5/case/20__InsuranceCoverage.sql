use BenAbbot_SA
go


/* ------------------------------------------------------------------------------
INSURANCE COMMENTS FROM USER_INSURANCE_DATA TABLE
*/ ------------------------------------------------------------------------------
--IF EXISTS (SELECT * FROM sys.objects WHERE name='Insurance_Comment_Helper' and type='U')
--BEGIN
--    DROP TABLE Insurance_Comment_Helper
--END
--GO

--SELECT td.insuranceid, string_agg(ucf.field_title + ': '+ td.[data], char(10)+char(13)) as ins_comment
--INTO Insurance_Comment_Helper
--FROM [BenAbbot_Needles]..user_insurance_data td
--JOIN [BenAbbot_Needles]..user_case_fields ucf on ucf.id = td.usercasefieldid
--GROUP BY td.insuranceid


/* ------------------------------------------------------------------------------
Insurance Contacts Helper
*/ ------------------------------------------------------------------------------

if OBJECT_ID('conversion.insurance_contacts_helper', 'U') is not null
begin
	drop table conversion.insurance_contacts_helper
end

create table conversion.insurance_contacts_helper (
	tableIndex			 INT identity (1, 1) not null,
	insurance_id		 varchar(50),					-- table id
	insurer_id			 varchar(50),					-- insurance company
	adjuster_id			 varchar(50),					-- adjuster
	insured				 VARCHAR(100),			-- a person or organization covered by insurance
	incnInsContactID	 INT,
	incnInsAddressID	 INT,
	incnAdjContactId	 INT,
	incnAdjAddressID	 INT,
	incnInsured			 INT,
	pord				 VARCHAR(1),
	caseID				 INT,
	PlaintiffDefendantID INT 
	constraint IX_Insurance_Contacts_Helper primary key clustered
	(
	tableIndex
	) with (pad_index = off, statistics_norecompute = off, ignore_dup_key = off, allow_row_locks = on, allow_page_locks = on, fillfactor = 80) on [PRIMARY]
) on [PRIMARY]
go

create nonclustered index IX_NonClustered_Index_insurance_id on conversion.insurance_contacts_helper (insurance_id);
create nonclustered index IX_NonClustered_Index_insurer_id on conversion.insurance_contacts_helper (insurer_id);
create nonclustered index IX_NonClustered_Index_adjuster_id on conversion.insurance_contacts_helper (adjuster_id);
go

-- populate helper
insert into conversion.insurance_contacts_helper
	(
		insurance_id,
		insurer_id,
		adjuster_id,
		insured,
		incnInsContactID,
		incnInsAddressID,
		incnAdjContactId,
		incnAdjAddressID,
		incnInsured,
		pord,
		caseID,
		PlaintiffDefendantID
	)
	select
		CONVERT(VARCHAR(50), INS.id),
		CONVERT(VARCHAR(50), INS.insurer_namesid),
		CONVERT(VARCHAR(50), INS.adjuster_namesid),
		ins.insured,
		ioc1.CID			 as incninscontactid,
		ioc1.AID			 as incninsaddressid,
		ioc2.CID			 as incnadjcontactid,
		ioc2.AID			 as incnadjaddressid,
		info.UniqueContactId as incninsured,
		null				 as pord,
		cas.casnCaseID		 as caseid,
		null				 as plaintiffdefendantid
	--select *
	from [BenAbbot_Needles].[dbo].[insurance_Indexed] ins
	join [sma_TRN_Cases] CAS
		on CAS.source_id = CONVERT(VARCHAR(50), INS.casesid)
	join IndvOrgContacts_Indexed IOC1
		on IOC1.source_id = CONVERT(VARCHAR(50), INS.insurer_namesid)
	left join IndvOrgContacts_Indexed IOC2
		on IOC2.source_id = CONVERT(VARCHAR(50), INS.adjuster_namesid)
	left join [sma_MST_IndvContacts] I
		on I.source_id = INS.insured
			and i.source_ref = 'insurance'
	left join [sma_MST_AllContactInfo] INFO
		on INFO.ContactId = I.cinnContactID
			and INFO.ContactCtg = I.cinnContactCtg


--join [sma_TRN_Cases] cas
--	on cas.cassCaseNumber = CONVERT(VARCHAR, ins.case_num)
--join IndvOrgContacts_Indexed ioc1
--	on ioc1.saga = ins.insurer_id
--		and ISNULL(ins.insurer_id, 0) <> 0
--		and ioc1.CTG = 2
--left join IndvOrgContacts_Indexed ioc2
--	on ioc2.saga = ins.adjuster_id
--		and ISNULL(ins.adjuster_id, 0) <> 0
--join [sma_MST_IndvContacts] i
--	on i.cinsLastName = ins.insured
--		and i.source_id = ins.insured
--		and i.source_ref = 'insurance'
--join [sma_MST_AllContactInfo] info
--	on info.ContactId = i.cinnContactID
--		and info.ContactCtg = i.cinnContactCtg
go

dbcc dbreindex ('conversion.insurance_contacts_helper', ' ', 90) with no_infomsgs
go

-------------------------------------------------------------------------------
-- Build conversion.multi_party_helper
-------------------------------------------------------------------------------
if OBJECT_ID('conversion.multi_party_helper') is not null
begin
	drop table conversion.multi_party_helper
end

go

-- Seed multi_party_helper with plaintiff id's
select
	ins.id as ins_id,
	t.plnnPlaintiffID
into conversion.multi_party_helper
--select *
from [BenAbbot_Needles].[dbo].[insurance_Indexed] ins
join [sma_TRN_cases] CAS
	on CAS.source_id = CONVERT(VARCHAR(50), INS.casesid)
join [sma_TRN_Plaintiff] T
	on t.saga_party = CONVERT(VARCHAR(50), ins.partyid)
go

-- update insurance_contacts_helper.pord = P using multi_party_helper
update conversion.insurance_contacts_helper
set pord = 'P',
	PlaintiffDefendantID = A.plnnPlaintiffID
from conversion.multi_party_helper a
where a.ins_id = insurance_id
go

-- drop multi_party_helper
if OBJECT_ID('conversion.multi_party_helper') is not null
begin
	drop table conversion.multi_party_helper
end

go

-- Seed multi_party_helper with defendant id's
select
	ins.id as ins_id,
	d.defnDefendentID
into conversion.multi_party_helper
from [BenAbbot_Needles].[dbo].[insurance_Indexed] ins
join [sma_TRN_cases] CAS
	on CAS.source_id = CONVERT(VARCHAR(50), INS.casesid)
join [sma_TRN_Defendants] D
	on d.saga_party = CONVERT(VARCHAR(50), ins.partyid)
go

-- update insurance_contacts_helper.pord = D using multi_party_helper
update conversion.insurance_contacts_helper
set pord = 'D',
	PlaintiffDefendantID = A.defnDefendentID
from conversion.multi_party_helper a
where a.ins_id = insurance_id
go


/* ------------------------------------------------------------------------------
Insurance Types
*/ ------------------------------------------------------------------------------
insert into [sma_MST_InsuranceType]
	(
		intsDscrptn
	)
	select
		'Unspecified'
	union
	select distinct
		it.type
	from [BenAbbot_Needles].[dbo].[insurance] ins
	join [BenAbbot_Needles].[dbo].[insurance_type] it
		on it.id = ins.insurancetypeid
	except
	select
		intsDscrptn
	from [sma_MST_InsuranceType]
go

/* ------------------------------------------------------------------------------
Plaintiff Insurance
*/ ------------------------------------------------------------------------------
alter table [sma_TRN_InsuranceCoverage] disable trigger all
go

insert into [sma_TRN_InsuranceCoverage]
	(
		[incnCaseID],
		[incnInsContactID],
		[incnInsAddressID],
		[incbCarrierHasLienYN],
		[incnInsType],
		[incnAdjContactId],
		[incnAdjAddressID],
		[incsPolicyNo],
		[incsClaimNo],
		[incnStackedTimes],
		[incsComments],
		[incnInsured],
		[incnCovgAmt],
		[incnDeductible],
		[incnUnInsPolicyLimit],
		[incnUnderPolicyLimit],
		[incbPolicyTerm],
		[incbTotCovg],
		[incsPlaintiffOrDef],
		[incnPlaintiffIDOrDefendantID],
		[incnTPAdminOrgID],
		[incnTPAdminAddID],
		[incnTPAdjContactID],
		[incnTPAdjAddID],
		[incsTPAClaimNo],
		[incnRecUserID],
		[incdDtCreated],
		[incnModifyUserID],
		[incdDtModified],
		[incnLevelNo],
		[incnUnInsPolicyLimitAcc],
		[incnUnderPolicyLimitAcc],
		[incb100Per],
		[incnMVLeased],
		[incnPriority],
		[incbDelete],
		[incnauthtodefcoun],
		[incnauthtodefcounDt],
		[incbPrimary],
		[source_id]
	)
	select distinct
		map.caseID				 as [incncaseid],
		map.incninscontactid	 as [incninscontactid],
		map.incninsaddressid	 as [incninsaddressid],
		null					 as [incbcarrierhaslienyn],
		(
			select
				intnInsuranceTypeID
			from [sma_MST_InsuranceType]
			where intsDscrptn = case
					when it.type <> ''
						then it.type
					else 'Unspecified'
				end
		)						 as [incninstype],
		map.incnadjcontactid	 as [incnadjcontactid],
		map.incnadjaddressid	 as [incnadjaddressid],
		ins.policy				 as [incspolicyno],
		ins.claim				 as [incsclaimno],
		null					 as [incnstackedtimes],
		''						 as [incscomments],
		map.incninsured			 as [incninsured],
		ins.actual				 as [incncovgamt],
		null					 as [incndeductible],
		ins.maximum_amount		 as [incnuninspolicylimit],
		ins.minimum_amount		 as [incnunderpolicylimit],
		0						 as [incbpolicyterm],
		0						 as [incbtotcovg],
		'P'						 as [incsplaintiffordef],
		map.PlaintiffDefendantID as [incnplaintiffidordefendantid],
		null					 as [incntpadminorgid],
		null					 as [incntpadminaddid],
		null					 as [incntpadjcontactid],
		null					 as [incntpadjaddid],
		null					 as [incstpaclaimno],
		368						 as [incnrecuserid],
		GETDATE()				 as [incddtcreated],
		null					 as [incnmodifyuserid],
		null					 as [incddtmodified],
		null					 as [incnlevelno],
		null					 as [incnuninspolicylimitacc],
		null					 as [incnunderpolicylimitacc],
		0						 as [incb100per],
		null					 as [incnmvleased],
		null					 as [incnpriority],
		0						 as [incbdelete],
		0						 as [incnauthtodefcoun],
		null					 as [incnauthtodefcoundt],
		0						 as [incbprimary],
		ins.id					 as [source_id]
	--select *
	from [BenAbbot_Needles].[dbo].[insurance_Indexed] ins
	left join [BenAbbot_Needles].[dbo].[insurance_type] it
		on it.id = ins.insurancetypeid
	--LEFT JOIN Insurance_Comment_Helper UD on convert(varchar(50),INS.id) = convert(varchar(50),UD.insuranceid)	
	join conversion.insurance_contacts_helper map
		on ins.id = map.insurance_id
			and map.pord = 'P'
go

/* ------------------------------------------------------------------------------
Defendant Insurance
*/ ------------------------------------------------------------------------------
insert into [sma_TRN_InsuranceCoverage]
	(
		[incnCaseID],
		[incnInsContactID],
		[incnInsAddressID],
		[incbCarrierHasLienYN],
		[incnInsType],
		[incnAdjContactId],
		[incnAdjAddressID],
		[incsPolicyNo],
		[incsClaimNo],
		[incnStackedTimes],
		[incsComments],
		[incnInsured],
		[incnCovgAmt],
		[incnDeductible],
		[incnUnInsPolicyLimit],
		[incnUnderPolicyLimit],
		[incbPolicyTerm],
		[incbTotCovg],
		[incsPlaintiffOrDef],
		[incnPlaintiffIDOrDefendantID],
		[incnTPAdminOrgID],
		[incnTPAdminAddID],
		[incnTPAdjContactID],
		[incnTPAdjAddID],
		[incsTPAClaimNo],
		[incnRecUserID],
		[incdDtCreated],
		[incnModifyUserID],
		[incdDtModified],
		[incnLevelNo],
		[incnUnInsPolicyLimitAcc],
		[incnUnderPolicyLimitAcc],
		[incb100Per],
		[incnMVLeased],
		[incnPriority],
		[incbDelete],
		[incnauthtodefcoun],
		[incnauthtodefcounDt],
		[incbPrimary],
		[source_id]
	)
	select distinct
		map.caseID				 as [incncaseid],
		map.incninscontactid	 as [incninscontactid],
		map.incninsaddressid	 as [incninsaddressid],
		null					 as [incbcarrierhaslienyn],
		(
			select
				intnInsuranceTypeID
			from [sma_MST_InsuranceType]
			where intsDscrptn = case
					when it.type <> ''
						then it.type
					else 'Unspecified'
				end
		)						 as [incninstype],
		map.incnadjcontactid	 as [incnadjcontactid],
		map.incnadjaddressid	 as [incnadjaddressid],
		ins.policy				 as [incspolicyno],
		ins.claim				 as [incsclaimno],
		null					 as [incnstackedtimes],
		''						 as [incscomments],
		map.incninsured			 as [incninsured],
		ins.actual				 as [incncovgamt],
		null					 as [incndeductible],
		ins.maximum_amount		 as [incnuninspolicylimit],
		ins.minimum_amount		 as [incnunderpolicylimit],
		0						 as [incbpolicyterm],
		0						 as [incbtotcovg],
		'D'						 as [incsplaintiffordef],
		map.PlaintiffDefendantID as [incnplaintiffidordefendantid],
		null					 as [incntpadminorgid],
		null					 as [incntpadminaddid],
		null					 as [incntpadjcontactid],
		null					 as [incntpadjaddid],
		null					 as [incstpaclaimno],
		368						 as [incnrecuserid],
		GETDATE()				 as [incddtcreated],
		null					 as [incnmodifyuserid],
		null					 as [incddtmodified],
		null					 as [incnlevelno],
		null					 as [incnuninspolicylimitacc],
		null					 as [incnunderpolicylimitacc],
		0						 as [incb100per],
		null					 as [incnmvleased],
		null					 as [incnpriority],
		0						 as [incbdelete],
		0						 as [incnauthtodefcoun],
		null					 as [incnauthtodefcoundt],
		0						 as [incbprimary],
		ins.id					 as [source_id]
	--select *
	from [BenAbbot_Needles].[dbo].[insurance_Indexed] ins
	left join [BenAbbot_Needles].[dbo].[insurance_type] it
		on it.id = ins.insurancetypeid
	--LEFT JOIN Insurance_Comment_Helper UD on convert(varchar(50),INS.id) = convert(varchar(50),UD.insuranceid)	
	join conversion.insurance_contacts_helper map
		on ins.id = map.insurance_id
			and map.pord = 'D'
go

alter table [sma_TRN_InsuranceCoverage] enable trigger all
go


/* ------------------------------------------------------------------------------
Adjusters
*/ ------------------------------------------------------------------------------

-- Adjuster/Insurer association
insert into [sma_MST_RelContacts]
	(
		[rlcnPrimaryCtgID],
		[rlcnPrimaryContactID],
		[rlcnPrimaryAddressID],
		[rlcnRelCtgID],
		[rlcnRelContactID],
		[rlcnRelAddressID],
		[rlcnRelTypeID],
		[rlcnRecUserID],
		[rlcdDtCreated],
		[rlcnModifyUserID],
		[rlcdDtModified],
		[rlcnLevelNo],
		[rlcsBizFam],
		[rlcnOrgTypeID]
	)
	select distinct
		1					  as [rlcnprimaryctgid],
		ic.[incnAdjContactId] as [rlcnprimarycontactid],
		ic.[incnAdjAddressID] as [rlcnprimaryaddressid],
		2					  as [rlcnrelctgid],
		ic.[incnInsContactID] as [rlcnrelcontactid],
		ic.[incnAdjAddressID] as [rlcnreladdressid],
		2					  as [rlcnreltypeid],
		368					  as [rlcnrecuserid],
		GETDATE()			  as [rlcddtcreated],
		null				  as [rlcnmodifyuserid],
		null				  as [rlcddtmodified],
		null				  as [rlcnlevelno],
		'Business'			  as [rlcsbizfam],
		null				  as [rlcnorgtypeid]
	from [sma_TRN_InsuranceCoverage] ic
	where
		ISNULL(ic.[incnAdjContactId], 0) <> 0
		and
		ISNULL(ic.[incnInsContactID], 0) <> 0

-- Insert Insurance Adjusters
insert into [sma_TRN_InsuranceCoverageAdjusters]
	(
		insuranceCoverageID,
		AdjusterContactUID
	)
	select
		incnInsCovgID,
		ioc2.UNQCID
	from sma_TRN_InsuranceCoverage ic
	join [BenAbbot_Needles].[dbo].[insurance_Indexed] INS
		on CONVERT(VARCHAR(50), INS.ID) = IC.[source_id]
	join IndvOrgContacts_Indexed IOC2
		on IOC2.[source_id] = CONVERT(VARCHAR(50), ins.adjuster_namesid)
