use BenAbbot_SA
go

--if not exists (
--		select
--			*
--		from sys.columns
--		where Name = N'saga_party'
--			and object_id = OBJECT_ID(N'sma_TRN_Plaintiff')
--	)
--begin
--	alter table [sma_TRN_Plaintiff] add [saga_party] VARCHAR(50) null;
--end

---- source_id
--if not exists (
--		select
--			*
--		from sys.columns
--		where Name = N'source_id'
--			and object_id = OBJECT_ID(N'sma_TRN_Plaintiff')
--	)
--begin
--	alter table [sma_TRN_Plaintiff] add [source_id] VARCHAR(MAX) null;
--end

--go

---- source_db
--if not exists (
--		select
--			*
--		from sys.columns
--		where Name = N'source_db'
--			and object_id = OBJECT_ID(N'sma_TRN_Plaintiff')
--	)
--begin
--	alter table [sma_TRN_Plaintiff] add [source_db] VARCHAR(MAX) null;
--end

--go

---- source_ref
--if not exists (
--		select
--			*
--		from sys.columns
--		where Name = N'source_ref'
--			and object_id = OBJECT_ID(N'sma_TRN_Plaintiff')
--	)
--begin
--	alter table [sma_TRN_Plaintiff] add [source_ref] VARCHAR(MAX) null;
--end

--go


alter table [sma_TRN_Plaintiff] disable trigger all
go

-------------------------------------------------------------------------------
-- Insert plaintiffs
-------------------------------------------------------------------------------

insert into [sma_TRN_Plaintiff]
	(
		[plnnCaseID],
		[plnnContactCtg],
		[plnnContactID],
		[plnnAddressID],
		[plnnRole],
		[plnbIsPrimary],
		[plnbWCOut],
		[plnnPartiallySettled],
		[plnbSettled],
		[plnbOut],
		[plnbSubOut],
		[plnnSeatBeltUsed],
		[plnnCaseValueID],
		[plnnCaseValueFrom],
		[plnnCaseValueTo],
		[plnnPriority],
		[plnnDisbursmentWt],
		[plnbDocAttached],
		[plndFromDt],
		[plndToDt],
		[plnnRecUserID],
		[plndDtCreated],
		[plnnModifyUserID],
		[plndDtModified],
		[plnnLevelNo],
		[plnsMarked],
		[saga],
		[plnnNoInj],
		[plnnMissing],
		[plnnLIPBatchNo],
		[plnnPlaintiffRole],
		[plnnPlaintiffGroup],
		[plnnPrimaryContact],
		[plnsComments],
		[plnbIsClient],
		[saga_party]
	)
	select
		CAS.casnCaseID  as [plnnCaseID],
		CIO.CTG			as [plnnContactCtg],
		CIO.CID			as [plnnContactID],
		CIO.AID			as [plnnAddressID],
		S.sbrnSubRoleId as [plnnRole],
		1				as [plnbIsPrimary],
		0,
		0,
		0,
		0,
		0,
		0,
		null,
		null,
		null,
		null,
		null,
		null,
		GETDATE(),
		null,
		368				as [plnnRecUserID],
		GETDATE()		as [plndDtCreated],
		null			as [plnnModifyUserID],
		null			as [plndDtModified],
		null			as [plnnLevelNo],
		null,
		'',
		null,
		null,
		null,
		null,
		null,
		1				as [plnnPrimaryContact],
		ISNULL('Relationship: ' + NULLIF(CONVERT(VARCHAR, p.relationship), '') + CHAR(13), '') +
		''				as [plnsComments],
		p.our_client	as [plnbIsClient],
		P.id			as [saga_party]
	from [BenAbbot_Needles].[dbo].[party_indexed] p
	join [sma_TRN_Cases] cas
		on cas.source_id = CONVERT(VARCHAR(50), p.casesid)
	join IndvOrgContacts_Indexed cio
		on cio.source_id = CONVERT(VARCHAR(50), p.namesid)
	join [BenAbbot_Needles]..party_role_list prl
		on prl.id = p.partyrolelistid
	join [PartyRoles] pr
		on pr.[Needles Roles] = prl.[role]
	join [sma_MST_SubRole] s
		on cas.casnOrgCaseTypeID = s.sbrnCaseTypeID
			and s.sbrsDscrptn = [SA Roles]
			and s.sbrnRoleID = 4
	where
		pr.[SA Party] = 'Plaintiff'
go

/*
-------------------------------------------------------------------------------
##############################################################################
-------------------------------------------------------------------------------
---(Appendix A)-- every case need at least one plaintiff
*/

insert into [sma_TRN_Plaintiff]
	(
		[plnnCaseID],
		[plnnContactCtg],
		[plnnContactID],
		[plnnAddressID],
		[plnnRole],
		[plnbIsPrimary],
		[plnbWCOut],
		[plnnPartiallySettled],
		[plnbSettled],
		[plnbOut],
		[plnbSubOut],
		[plnnSeatBeltUsed],
		[plnnCaseValueID],
		[plnnCaseValueFrom],
		[plnnCaseValueTo],
		[plnnPriority],
		[plnnDisbursmentWt],
		[plnbDocAttached],
		[plndFromDt],
		[plndToDt],
		[plnnRecUserID],
		[plndDtCreated],
		[plnnModifyUserID],
		[plndDtModified],
		[plnnLevelNo],
		[plnsMarked],
		[saga],
		[plnnNoInj],
		[plnnMissing],
		[plnnLIPBatchNo],
		[plnnPlaintiffRole],
		[plnnPlaintiffGroup],
		[plnnPrimaryContact]
	)
	select
		casnCaseID as [plnncaseid],
		1		   as [plnncontactctg],
		(
			select
				cinncontactid
			from sma_MST_IndvContacts
			where cinsFirstName = 'Plaintiff'
				and cinsLastName = 'Unidentified'
		)		   as [plnncontactid],
		null	   as [plnnaddressid],
		(
			select
				sbrnSubRoleId
			from sma_MST_SubRole s
			inner join sma_MST_SubRoleCode c
				on c.srcnCodeId = s.sbrnTypeCode
				and c.srcsDscrptn = '(P)-Default Role'
			where s.sbrnCaseTypeID = cas.casnOrgCaseTypeID
		)		   as plnnrole,
		1		   as [plnbisprimary],
		0,
		0,
		0,
		0,
		0,
		0,
		null,
		null,
		null,
		null,
		null,
		null,
		GETDATE(),
		null,
		368		   as [plnnrecuserid],
		GETDATE()  as [plnddtcreated],
		null,
		null,
		'',
		null,
		'',
		null,
		null,
		null,
		null,
		null,
		1		   as [plnnprimarycontact]
	from sma_trn_cases cas
	left join [sma_TRN_Plaintiff] t
		on t.plnncaseid = cas.casnCaseID
	where
		plnncaseid is null
go



update sma_TRN_Plaintiff
set plnbIsPrimary = 0

update sma_TRN_Plaintiff
set plnbIsPrimary = 1
from (
	select distinct
		t.plnnCaseID,
		ROW_NUMBER() over (partition by t.plnnCaseID order by p.record_num) as rownumber,
		t.plnnPlaintiffID													as id
	from sma_TRN_Plaintiff t
	left join [BenAbbot_Needles].[dbo].[party_indexed] p
		on p.TableIndex = t.saga_party
) a
where a.rownumber = 1
and plnnPlaintiffID = a.id



alter table [sma_TRN_Plaintiff] enable trigger all
go


/* ------------------------------------------------------------------------------
Plaintiff Death
*/ ------------------------------------------------------------------------------
insert into [sma_TRN_PlaintiffDeath]
	(
		[pldnCaseID],
		[pldnPlaintiffID],
		[pldnContactID],
		[plddDeathDt],
		[pldbAutopsyYN]
	)
	select
		P.plnnCaseID	  as [pldnCaseID],
		P.plnnPlaintiffID as [pldnPlaintiffID],
		P.plnnContactID	  as [pldnContactID],
		I.cindDateOfDeath as [plddDeathDt],
		0				  as [pldbAutopsyYN]
	from [sma_TRN_Plaintiff] P
	join [sma_MST_IndVContacts] I
		on I.cinnContactID = P.plnnContactID
	where
		cindDateOfDeath is not null
