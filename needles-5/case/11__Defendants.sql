use BenAbbot_SA
go

alter table [sma_TRN_Defendants] disable trigger all
go

-------------------------------------------------------------------------------
-- Insert defendants
-------------------------------------------------------------------------------
insert into [sma_TRN_Defendants]
	(
		[defnCaseID],
		[defnContactCtgID],
		[defnContactID],
		[defnAddressID],
		[defnSubRole],
		[defbIsPrimary],
		[defbCounterClaim],
		[defbThirdParty],
		[defsThirdPartyRole],
		[defnPriority],
		[defdFrmDt],
		[defdToDt],
		[defnRecUserID],
		[defdDtCreated],
		[defnModifyUserID],
		[defdDtModified],
		[defnLevelNo],
		[defsMarked],
		[saga],
		[defsComments],
		[defbIsClient],
		[saga_party]
	)
	select
		casnCaseID	  as [defnCaseID],
		ACIO.CTG	  as [defnContactCtgID],
		ACIO.CID	  as [defnContactID],
		ACIO.AID	  as [defnAddressID],
		sbrnSubRoleId as [defnSubRole],
		1			  as [defbIsPrimary],
		null,
		null,
		null,
		null,
		null,
		null,
		368			  as [defnRecUserID],
		GETDATE()	  as [defdDtCreated],
		null		  as [defnModifyUserID],
		null		  as [defdDtModified],
		null		  as [defnLevelNo],
		null,
		null,
		ISNULL('Relationship: ' + NULLIF(CONVERT(VARCHAR, p.relationship), '') + CHAR(13), '') +
		''			  as [defsComments],
		p.our_client  as [defbIsClient],
		P.[id]		  as [saga_party]
	from [BenAbbot_Needles].[dbo].[party_indexed] P
	join [sma_TRN_Cases] CAS
		on CAS.source_id = CONVERT(VARCHAR(50), P.casesid)
	join IndvOrgContacts_Indexed ACIO
		on ACIO.SAGA = CONVERT(VARCHAR(50), P.namesid)
	join [BenAbbot_Needles]..party_role_list prl
		on prl.id = p.partyrolelistid
	join [PartyRoles] pr
		on pr.[Needles Roles] = prl.[role]
	join [sma_MST_SubRole] S
		on CAS.casnOrgCaseTypeID = S.sbrnCaseTypeID
			and s.sbrsDscrptn = [sa roles]
			and S.sbrnRoleID = 5
	where
		pr.[sa party] = 'Defendant'
go

-------------------------------------------------------------------------------
-- Every case need at least one defendant
-------------------------------------------------------------------------------
insert into [sma_TRN_Defendants]
	(
		[defnCaseID],
		[defnContactCtgID],
		[defnContactID],
		[defnAddressID],
		[defnSubRole],
		[defbIsPrimary],
		[defbCounterClaim],
		[defbThirdParty],
		[defsThirdPartyRole],
		[defnPriority],
		[defdFrmDt],
		[defdToDt],
		[defnRecUserID],
		[defdDtCreated],
		[defnModifyUserID],
		[defdDtModified],
		[defnLevelNo],
		[defsMarked],
		[saga]
	)
	select
		casnCaseID as [defncaseid],
		1		   as [defncontactctgid],
		(
			select
				cinncontactid
			from sma_MST_IndvContacts
			where cinsFirstName = 'Defendant'
				and cinsLastName = 'Unidentified'
		)		   as [defncontactid],
		null	   as [defnaddressid],
		(
			select
				sbrnSubRoleId
			from sma_MST_SubRole s
			inner join sma_MST_SubRoleCode c
				on c.srcnCodeId = s.sbrnTypeCode
				and c.srcsDscrptn = '(D)-Default Role'
			where s.sbrnCaseTypeID = cas.casnOrgCaseTypeID
		)		   as [defnsubrole],
		1		   as [defbisprimary],-- reexamine??
		null,
		null,
		null,
		null,
		null,
		null,
		368		   as [defnrecuserid],
		GETDATE()  as [defddtcreated],
		368		   as [defnmodifyuserid],
		GETDATE()  as [defddtmodified],
		null,
		null,
		null
	from sma_trn_cases cas
	left join [sma_TRN_Defendants] d
		on d.defncaseid = cas.casnCaseID
	where
		d.defncaseid is null

-------------------------------------------------------------------------------
-- Update primary defendant
-------------------------------------------------------------------------------
update sma_TRN_Defendants
set defbIsPrimary = 0

update sma_TRN_Defendants
set defbIsPrimary = 1
from (
	select distinct
		d.defnCaseID,
		ROW_NUMBER() over (partition by d.defnCaseID order by p.record_num) as rownumber,
		d.defnDefendentID													as id
	from sma_TRN_Defendants d
	left join [BenAbbot_Needles].[dbo].[party_indexed] p
		on p.TableIndex = d.saga_party
) a
where a.rownumber = 1
and defnDefendentID = a.id

go


---
alter table [sma_TRN_Defendants] enable trigger all
go