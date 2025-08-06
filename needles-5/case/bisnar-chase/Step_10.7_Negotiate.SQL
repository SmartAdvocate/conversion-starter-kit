
use [SA]
go
/*
alter table [sma_TRN_Negotiations] disable trigger all
delete [sma_TRN_Negotiations]
DBCC CHECKIDENT ('[sma_TRN_Negotiations]', RESEED, 1);
alter table [sma_TRN_Negotiations] enable trigger all

alter table [sma_TRN_Settlements] disable trigger all
delete [sma_TRN_Settlements]
DBCC CHECKIDENT ('[sma_TRN_Settlements]', RESEED, 1);
alter table [sma_TRN_Settlements] enable trigger all
*/

--(0)--

IF NOT EXISTS( SELECT * FROM sys.columns WHERE Name = N'SettlementAmount' AND Object_ID = Object_ID(N'sma_TRN_Negotiations') )
BEGIN
	ALTER TABLE sma_TRN_Negotiations
    ADD SettlementAmount decimal(18, 2) null
END
GO

--(1)--
INSERT INTO [sma_TRN_Negotiations]
(      [negnCaseID]
      ,[negsUniquePartyID]
      ,[negdDate]
      ,[negnStaffID]
      ,[negnPlaintiffID]
      ,[negbPartiallySettled]
      ,[negnClientAuthAmt]
      ,[negbOralConsent]
      ,[negdOralDtSent]
      ,[negdOralDtRcvd]
      ,[negnDemand]
      ,[negnOffer]
      ,[negbConsentType]
      ,[negnRecUserID]
      ,[negdDtCreated]
      ,[negnModifyUserID]
      ,[negdDtModified]
      ,[negnLevelNo]
      ,[negsComments]
	  ,[SettlementAmount]
 )
SELECT 
    CAS.casnCaseID													as [negnCaseID],
    ('I' + convert(varchar,  (select top 1 incnInsCovgID from [sma_TRN_InsuranceCoverage] INC where INC.incnCaseID=CAS.casnCaseID and INC.saga= convert(varchar(50),INS.id)
    and INC.incnInsContactID= (select top 1 connContactID from [sma_MST_OrgContacts] where saga= convert(varchar(50),INS.insurer_namesid)))) )
																	as [negsUniquePartyID],
    case when NEG.neg_date  between '1900-01-01' and '2079-12-31' then NEG.neg_date
	   else null end												as [negdDate],
    (select usrnContactiD from sma_MST_Users where saga=convert(varchar(50),NEG.staffid))	as [negnStaffID],
	-1																as [negnPlaintiffID],
	null															as [negbPartiallySettled],
	case when nt.[name] = 'Client Authorize' then NEG.amount else null end	 as [negnClientAuthAmt],
	null															as [negbOralConsent],
	null															as [negdOralDtSent],
	null															as [negdOralDtRcvd],
	case when nt.[name] = 'Demand' then NEG.amount else null end		as [negnDemand],
	case when nt.[name] IN( 'Offer','Conditional Ofr') then NEG.amount else null end		as [negnOffer],
	null															as [negbConsentType],
	368,
	getdate(),
	368,
	getdate(),
	0																as [negnLevelNo],
     isnull(nt.[name] + ' : ' + NULLIF( convert(varchar,NEG.amount),'')  + CHAR(13) + CHAR(10),'') + 
	NEG.notes														as [negsComments],
	case when nt.[name] = 'Settlement' then NEG.amount else null end	as [SettlementAmount]
--select *
FROM [NeedlesNeosBisnarChase].[dbo].[negotiation] NEG
LEFT JOIN NeedlesNeosBisnarChase..negotiation_type nt on nt.id = neg.negotiationtypeid
LEFT JOIN [NeedlesNeosBisnarChase].[dbo].[insurance_Indexed] INS on INS.id = NEG.insuranceid
JOIN [sma_TRN_cases] CAS on CAS.Needles_saga = convert(varchar(50), neg.casesid)
LEFT JOIN [Insurance_Contacts_Helper] MAP on convert(varchar(50),INS.id) = MAP.insurance_id 


-----------------

INSERT INTO [sma_TRN_Settlements]
(
    stlnSetAmt,
    stlnStaffID,
    stlnPlaintiffID,
    stlsUniquePartyID,
    stlnCaseID,
    stlnNegotID
)
SELECT 
    SettlementAmount    as stlnSetAmt,
    negnStaffID			as stlnStaffID,
	negnPlaintiffID		as stlnPlaintiffID,
    negsUniquePartyID   as stlsUniquePartyID,
    negnCaseID		    as stlnCaseID,
    negnID				as stlnNegotID
FROM [sma_TRN_Negotiations]
WHERE isnull(SettlementAmount ,0) > 0

