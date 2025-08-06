use BenAbbot_SA
go

/* ------------------------------------------------------------------------------
helper tables
*/ ------------------------------------------------------------------------------


--- conversion.value_specialDamage
begin

	if OBJECT_ID('conversion.value_specialDamage', 'U') is not null
	begin
		drop table conversion.value_specialDamage
	end

	create table conversion.value_specialDamage (
		code VARCHAR(25)
	);
	insert into conversion.value_specialDamage
		(
			code
		)
		values
		('SUB'),
		('PD'),
		('PD$');
end

--- [value_tab_spDamages_Helper]
if exists (select * from sys.objects where name = 'value_tab_spDamages_Helper' and type = 'U')
begin
	drop table value_tab_spDamages_Helper
end

go

---
create table value_tab_spDamages_Helper (
	TableIndex	   [INT] identity (1, 1) not null,
	case_id		   VARCHAR(50),
	value_id	   VARCHAR(50),
	ProviderNameId VARCHAR(50),
	ProviderName   VARCHAR(200),
	ProviderCID	   INT,
	ProviderCTG	   INT,
	ProviderAID	   INT,
	casnCaseID	   INT,
	PlaintiffID	   INT,
	constraint IOC_Clustered_Index_value_tab_spDamages_Helper primary key clustered (TableIndex)
) on [PRIMARY]
go

create nonclustered index IX_NonClustered_Index_value_tab_spDamages_Helper_case_id on [value_tab_spDamages_Helper] (case_id);
create nonclustered index IX_NonClustered_Index_value_tab_spDamages_Helper_value_id on [value_tab_spDamages_Helper] (value_id);
create nonclustered index IX_NonClustered_Index_value_tab_spDamages_Helper_ProviderNameId on [value_tab_spDamages_Helper] (ProviderNameId);
go

---
insert into [value_tab_spDamages_Helper]
	(
		case_id,
		value_id,
		ProviderNameId,
		ProviderName,
		ProviderCID,
		ProviderCTG,
		ProviderAID,
		casnCaseID,
		PlaintiffID
	) select
		CONVERT(VARCHAR(50), v.casesid) as case_id,	-- needles case
		CONVERT(VARCHAR(50), V.id)		as tab_id,		-- needles records TAB item
		CONVERT(VARCHAR(50), V.namesid) as ProviderNameId,
		IOC.Name						as ProviderName,
		IOC.CID							as ProviderCID,
		IOC.CTG							as ProviderCTG,
		IOC.AID							as ProviderAID,
		CAS.casnCaseID					as casnCaseID,
		null							as PlaintiffID
	from [BenAbbot_Needles].[dbo].[value_Indexed] V
	join [BenAbbot_Needles].[dbo].[value_code] VC
		on v.valuecodeid = vc.id
	join [sma_TRN_cases] CAS
		on CAS.source_id = CONVERT(VARCHAR(50), V.casesid)
	join IndvOrgContacts_Indexed IOC
		on IOC.source_id = CONVERT(VARCHAR(50), V.namesid)
	where
		code in (select code from conversion.value_specialDamage vd)

---
dbcc dbreindex ('value_tab_spDamages_Helper', ' ', 90) with no_infomsgs
go


--- value_tab_Multi_Party_Helper_Temp
if exists (select * from sys.objects where Name = 'value_tab_Multi_Party_Helper_Temp')
begin
	drop table value_tab_Multi_Party_Helper_Temp
end

go

---
select
	V.casesid as cid,
	V.id	  as vid,
	T.plnnPlaintiffID
into value_tab_Multi_Party_Helper_Temp
from [BenAbbot_Needles].[dbo].[value_Indexed] V
join [BenAbbot_Needles].[dbo].[value_code] VC
	on v.valuecodeid = vc.id
join [sma_TRN_cases] CAS
	on CAS.source_id = CONVERT(VARCHAR(50), V.casesid)
join [BenAbbot_Needles].[dbo].[Party_Indexed] pt
	on pt.id = v.partyid
		and v.casesid = pt.casesid
join IndvOrgContacts_Indexed IOC
	on IOC.source_id = CONVERT(VARCHAR(50), pt.namesid)
join [sma_TRN_Plaintiff] T
	on T.plnnContactID = IOC.CID
		and T.plnnContactCtg = IOC.CTG
		and T.plnnCaseID = CAS.casnCaseID
go

---
update [value_tab_spDamages_Helper]
set PlaintiffID = A.plnnPlaintiffID
from value_tab_Multi_Party_Helper_Temp A
where case_id = A.CID
and value_id = A.vid
go

---
if exists (select * from sys.objects where Name = 'value_tab_Multi_Party_Helper_Temp')
begin
	drop table value_tab_Multi_Party_Helper_Temp
end

go

---
select
	V.casesid as cid,
	V.id	  as vid,
	(select
		 plnnPlaintiffID
	 from [sma_TRN_Plaintiff]
	 where plnnCaseID = CAS.casnCaseID
		 and plnbIsPrimary = 1
	)		  as plnnPlaintiffID
into value_tab_Multi_Party_Helper_Temp
from [BenAbbot_Needles].[dbo].[value_Indexed] V
join [BenAbbot_Needles].[dbo].[value_code] VC
	on v.valuecodeid = vc.id
join [sma_TRN_cases] CAS
	on CAS.source_id = CONVERT(VARCHAR(50), V.casesid)
join [BenAbbot_Needles].[dbo].[Party_Indexed] pt
	on pt.id = CONVERT(VARCHAR(50), v.partyid)
		and v.casesid = pt.casesid
join IndvOrgContacts_Indexed IOC
	on IOC.source_id = CONVERT(VARCHAR(50), pt.namesid)
join [sma_TRN_Defendants] D
	on D.defnContactID = IOC.CID
		and D.defnContactCtgID = IOC.CTG
		and D.defnCaseID = CAS.casnCaseID
go

---
update value_tab_spDamages_Helper
set PlaintiffID = A.plnnPlaintiffID
from value_tab_Multi_Party_Helper_Temp A
where case_id = A.CID
and value_id = A.vid
go

/* ------------------------------------------------------------------------------
Damage Types [sma_MST_SpecialDamageType]
*/ ------------------------------------------------------------------------------

if (select
		 COUNT(*)
	 from sma_MST_SpecialDamageType
	 where SpDamageTypeDescription = 'Property Damage'
	) = 0
begin
	insert into sma_MST_SpecialDamageType
		(
			SpDamageTypeDescription,
			IsEditableType,
			SpDamageTypeCreatedUserID,
			SpDamageTypeDtCreated
		) select
			'Property Damage',
			1,
			368,
			GETDATE()
end

-- Create Special Damage Type "Other" if it doesn't exist
if (select
		 COUNT(*)
	 from sma_MST_SpecialDamageType
	 where SpDamageTypeDescription = 'Other'
	) = 0
begin
	insert into sma_MST_SpecialDamageType
		(
			SpDamageTypeDescription,
			IsEditableType,
			SpDamageTypeCreatedUserID,
			SpDamageTypeDtCreated
		) select
			'Other',
			1,
			368,
			GETDATE()
end

-- Insert Special Damage Sub Types from value_code under Type "Other"
insert into sma_MST_SpecialDamageSubType
	(
		spdamagetypeid,
		SpDamageSubTypeDescription,
		SpDamageSubTypeDtCreated,
		SpDamageSubTypeCreatedUserID
	) select
		(select
			 spdamagetypeid
		 from sma_MST_SpecialDamageType
		 where SpDamageTypeDescription = 'Other'
		),
		vc.[description],
		GETDATE(),
		368
	from [BenAbbot_Needles]..value_code vc
	where
		code in (select code from conversion.value_specialDamage)

/* ------------------------------------------------------------------------------
Insert Special Damages [sma_TRN_SpDamages]
*/ ------------------------------------------------------------------------------
alter table [sma_TRN_SpDamages] disable trigger all
go

insert into [sma_TRN_SpDamages]
	(
		spdsRefTable,
		spdnRecordID,
		spddCaseID,
		spddPlaintiff,
		spddDamageType,
		spddDamageSubType,
		spdnRecUserID,
		spddDtCreated,
		spdnLevelNo,
		spdnBillAmt,
		spddDateFrom,
		spddDateTo,
		spdsComments,
		saga,
		source_id,
		source_db,
		source_ref
	) select distinct
		'CustomDamage'  as spdsRefTable,
		null			as spdnRecordID,
		SDH.casnCaseID  as spddCaseID,
		SDH.PlaintiffID as spddPlaintiff,
		case
				when vc.code in ('PD', 'PD$')
					then (select top 1
							 spdamagetypeid
						 from sma_MST_SpecialDamageType
						 where SpDamageTypeDescription = 'Property Damage'
						)
				else (select top 1
						 spdamagetypeid
					 from sma_MST_SpecialDamageType
					 where SpDamageTypeDescription = 'Other'
					)
		end				as spddDamageType,
		(select top 1
			 SpDamageSubTypeID
		 from sma_MST_SpecialDamageSubType
		 where SpDamageSubTypeDescription = VC.[description]
			 and spdamagetypeid = (select
				  spdamagetypeid
			  from sma_MST_SpecialDamageType
			  where SpDamageTypeDescription = 'Other'
			 )
		)				as spddDamageSubType,
		368				as spdnRecUserID,
		GETDATE()		as spddDtCreated,
		0				as spdnLevelNo,
		V.total_value   as spdnBillAmt,
		case
				when V.[start_date] between '1900-01-01' and '2079-06-01'
					then V.[start_date]
				else null
		end				as spddDateFrom,
		case
				when V.stop_date between '1900-01-01' and '2079-06-01'
					then V.stop_date
				else null
		end				as spddDateTo,
		'Provider: '
		+ SDH.[ProviderName]
		+ CHAR(13)
		+ V.memo		as spdsComments,
		null			as [saga],
		v.id			as [source_id],
		'needles'		as [source_db],
		'value'			as [source_ref]
	from [BenAbbot_Needles].[dbo].[value_Indexed] V
	join [BenAbbot_Needles].[dbo].[value_code] VC
		on v.valuecodeid = vc.id
	join [value_tab_spDamages_Helper] SDH
		on CONVERT(VARCHAR(50), v.id) = sdh.value_id
	where
		vc.code in (select code from conversion.value_specialDamage)
go

alter table [sma_TRN_SpDamages] enable trigger all
go

