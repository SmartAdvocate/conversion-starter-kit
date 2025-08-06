use [BenAbbot_SA]
go

/*

delete [sma_TRN_Negotiations]
DBCC CHECKIDENT ('[sma_TRN_Negotiations]', RESEED, 1);
alter table [sma_TRN_Negotiations] enable trigger all

alter table [sma_TRN_Settlements] disable trigger all
delete [sma_TRN_Settlements]
DBCC CHECKIDENT ('[sma_TRN_Settlements]', RESEED, 1);

*/


---------------------------------------------------
-- schema
---------------------------------------------------
-- saga
if not exists (select * from sys.columns where Name = N'saga' and object_id = OBJECT_ID(N'sma_TRN_Negotiations'))
begin
	alter table [sma_TRN_Negotiations] add [saga] INT null;
end

go

-- source_id
if not exists (select * from sys.columns where Name = N'source_id' and object_id = OBJECT_ID(N'sma_TRN_Negotiations'))
begin
	alter table [sma_TRN_Negotiations] add [source_id] VARCHAR(MAX) null;
end

go

-- source_db
if not exists (select * from sys.columns where Name = N'source_db' and object_id = OBJECT_ID(N'sma_TRN_Negotiations'))
begin
	alter table [sma_TRN_Negotiations] add [source_db] VARCHAR(MAX) null;
end

go

-- source_ref
if not exists (select * from sys.columns where Name = N'source_ref' and object_id = OBJECT_ID(N'sma_TRN_Negotiations'))
begin
	alter table [sma_TRN_Negotiations] add [source_ref] VARCHAR(MAX) null;
end

go

-- SettlementAmount
if not exists (select * from sys.columns where Name = N'SettlementAmount' and object_id = OBJECT_ID(N'sma_TRN_Negotiations'))
begin
	alter table sma_TRN_Negotiations
	add SettlementAmount DECIMAL(18, 2) null
end


/* ------------------------------------------------------------------------------
Insert Negotiations
*/

alter table [sma_TRN_Negotiations] disable trigger all
go

insert into [sma_TRN_Negotiations]
	(
		[negnCaseID],
		[negsUniquePartyID],
		[negdDate],
		[negnStaffID],
		[negnPlaintiffID],
		[negbPartiallySettled],
		[negnClientAuthAmt],
		[negbOralConsent],
		[negdOralDtSent],
		[negdOralDtRcvd],
		[negnDemand],
		[negnOffer],
		[negbConsentType],
		[negnRecUserID],
		[negdDtCreated],
		[negnModifyUserID],
		[negdDtModified],
		[negnLevelNo],
		[negsComments],
		[SettlementAmount],
		[saga],
		[source_id],
		[source_db],
		[source_ref]
	) select
		CAS.casnCaseID as [negnCaseID],
		('I' + CONVERT(VARCHAR, (select top 1
			 incnInsCovgID
		 from [sma_TRN_InsuranceCoverage] INC
		 where INC.incnCaseID = CAS.casnCaseID
			 and INC.source_id = INS.id
			 and INC.incnInsContactID = (select top 1
				  connContactID
			  from [sma_MST_OrgContacts]
			  where INC.source_id = INS.insurer_namesid
			 )
		)))			   
		as [negsUniquePartyID],
		case
				when NEG.neg_date between '1900-01-01' and '2079-12-31'
					then NEG.neg_date
				else null
		end			   as [negdDate],
		(select
			 usrnContactiD
		 from sma_MST_Users
		 where source_id = CONVERT(VARCHAR(50), NEG.staffid)
		)			   as [negnStaffID],
		-1			   as [negnPlaintiffID],
		null		   as [negbPartiallySettled],
		null		   as [negnClientAuthAmt],
		null		   as [negbOralConsent],
		null		   as [negdOralDtSent],
		null		   as [negdOralDtRcvd],
		case
				when nt.name in (
						'Counter', 'Counter demand', 'Demand',
						'E-fax demand', 'E-mail demand', 'Mediation Demand'
						)
					then NEG.amount
				else null
		end			   as [negnDemand],
		case
				when nt.name in ('Offer', 'Mediation Offer')
					then NEG.amount
				when nt.name in (
						'Adjuster', 'Adjuster T/C', 'Adjustor/TC', 'Attorney', 'Atty review',
						'Ben''s reveiw', 'Ben''s review', 'Check here', 'Client T/C',
						'CM''s review',
						'Def Atty T/C', 'E-fax', 'E-mail', 'Email rec''d', 'Email sent',
						'Mediation',
						'Mediators Proposal', 'ONLY BEN CAN SETTLE', 'Supplement'
						)
					then NEG.amount
				else null
		end			   as [negnOffer],
		null		   as [negbConsentType],
		368,
		GETDATE(),
		368,
		GETDATE(),
		0			   as [negnLevelNo],
		ISNULL(nt.name + ' : ' + NULLIF(CONVERT(VARCHAR, NEG.amount), '') + CHAR(13) + CHAR(10), '') +
		NEG.notes	   as [negsComments],
		case
				when nt.name in ('Settled')
					then NEG.amount
				else null
		end			   as [SettlementAmount],
		null		   as [saga],
		neg.id		   as [source_id],
		'needles'	   as [source_db],
		'negotiation'  as [source_ref]
	from [BenAbbot_Needles].[dbo].[negotiation] NEG
	left join [BenAbbot_Needles]..negotiation_type nt
		on nt.id = neg.negotiationtypeid
	left join [BenAbbot_Needles].[dbo].[insurance_Indexed] INS
		on INS.id = NEG.insuranceid
	join [sma_TRN_cases] CAS
		on CAS.source_id = CONVERT(VARCHAR(50), neg.casesid)
	left join conversion.insurance_contacts_helper MAP
		on CONVERT(VARCHAR(50), INS.id) = MAP.insurance_id




--from [BenAbbot_Needles].[dbo].[negotiation] NEG
--left join [BenAbbot_Needles].[dbo].[insurance_Indexed] INS
--	on INS.insurance_id = NEG.insurance_id
--join [sma_TRN_cases] CAS
--	on CAS.cassCaseNumber = CONVERT(VARCHAR, NEG.case_id)
--left join [conversion].[Insurance_Contacts_Helper] MAP
--	on INS.insurance_id = MAP.insurance_id
go


insert into [sma_TRN_Settlements]
	(
		stlnSetAmt,
		stlnStaffID,
		stlnPlaintiffID,
		stlsUniquePartyID,
		stlnCaseID,
		stlnNegotID
	) select
		SettlementAmount  as stlnSetAmt,
		negnStaffID		  as stlnStaffID,
		negnPlaintiffID	  as stlnPlaintiffID,
		negsUniquePartyID as stlsUniquePartyID,
		negnCaseID		  as stlnCaseID,
		negnID			  as stlnNegotID
	from [sma_TRN_Negotiations]
	where
		ISNULL(SettlementAmount, 0) > 0


alter table [sma_TRN_Settlements] enable trigger all