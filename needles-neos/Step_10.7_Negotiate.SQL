
use   [SAbilleasterlyLaw]
go
 
alter table [sma_TRN_Negotiations] disable trigger all
delete [sma_TRN_Negotiations]
DBCC CHECKIDENT ('[sma_TRN_Negotiations]', RESEED, 1);
alter table [sma_TRN_Negotiations] enable trigger all

alter table [sma_TRN_Settlements] disable trigger all
delete [sma_TRN_Settlements]
DBCC CHECKIDENT ('[sma_TRN_Settlements]', RESEED, 1);
alter table [sma_TRN_Settlements] enable trigger all
 

--(0)--

IF NOT EXISTS( SELECT * FROM sys.columns WHERE Name = N'SettlementAmount' AND Object_ID = Object_ID(N'sma_TRN_Negotiations') )
BEGIN
	ALTER TABLE sma_TRN_Negotiations
    ADD SettlementAmount decimal(18, 2) null
END
GO

--(1)--
WITH InsuranceCovg AS (
    SELECT 
        INC.incnCaseID,
        INC.saga,
        INC.incnInsContactID,
        INC.incnInsCovgID,
        ROW_NUMBER() OVER (
            PARTITION BY INC.incnCaseID, INC.saga 
            ORDER BY INC.incnInsCovgID
        ) AS rn
    FROM [sma_TRN_InsuranceCoverage] INC
),
OrgContact AS (
    SELECT 
        neos_saga,
        connContactID,
        ROW_NUMBER() OVER (
            PARTITION BY neos_saga
            ORDER BY connContactID
        ) AS rn
    FROM [sma_MST_OrgContacts]
),
MatchedCovg AS (
    SELECT 
        ic.incnCaseID,
        ic.saga,
        ic.incnInsCovgID
    FROM InsuranceCovg ic
    JOIN OrgContact oc 
        ON ic.incnInsContactID = oc.connContactID
       AND ic.saga = oc.neos_saga
       AND ic.rn = 1 AND oc.rn = 1
),
UserMatch AS (
    SELECT 
        saga AS user_saga,
        usrnContactID
    FROM sma_MST_Users
)

 INSERT INTO [sma_TRN_Negotiations] (
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
    [SettlementAmount]
)   
SELECT 
    CAS.casnCaseID AS [negnCaseID],
    'I' + CONVERT(VARCHAR, MC.incnInsCovgID) AS [negsUniquePartyID],
    CASE 
        WHEN NEG.neg_date BETWEEN '1900-01-01' AND '2079-12-31' THEN NEG.neg_date 
        ELSE NULL 
    END AS [negdDate],
    UM.usrnContactID AS [negnStaffID],
    -1 AS [negnPlaintiffID],
    NULL AS [negbPartiallySettled],
    CASE WHEN nt.[name] = 'Pre-Rep offer' THEN NEG.amount ELSE NULL END AS [negnClientAuthAmt],
    NULL AS [negbOralConsent],
    NULL AS [negdOralDtSent],
    NULL AS [negdOralDtRcvd],
    CASE WHEN nt.[name] = 'Discuss' THEN NEG.amount ELSE NULL END AS [negnDemand],
    CASE WHEN nt.[name] = 'Offer' THEN NEG.amount ELSE NULL END AS [negnOffer],
    NULL AS [negbConsentType],
    368,
    GETDATE(),
    368,
    GETDATE(),
    0 AS [negnLevelNo],
    ISNULL(nt.[name] + ' : ' + NULLIF(CONVERT(VARCHAR, NEG.amount), '') + CHAR(13) + CHAR(10), '') + NEG.notes AS [negsComments],
    CASE WHEN nt.[name] = 'Settled' THEN NEG.amount ELSE NULL END AS [SettlementAmount]
--- select *
FROM [NeosBillEasterly].[dbo].[negotiation] NEG
LEFT JOIN [NeosBillEasterly].[dbo].[negotiation_type] nt 
    ON nt.id = NEG.negotiationtypeid
LEFT JOIN [NeosBillEasterly].[dbo].[insurance_Indexed] INS 
    ON INS.id = NEG.insuranceid
JOIN [sma_TRN_Cases] CAS 
    ON CAS.Neos_Saga = CONVERT(VARCHAR(50), NEG.casesid)
 LEFT JOIN MatchedCovg MC 
    ON MC.incnCaseID = CAS.casnCaseID AND MC.saga = CONVERT(VARCHAR(50), INS.id)
LEFT JOIN UserMatch UM 
    ON UM.user_saga = CONVERT(VARCHAR(50), NEG.staffid)
LEFT JOIN [Insurance_Contacts_Helper] MAP 
    ON CONVERT(VARCHAR(50), INS.id) = MAP.insurance_id;


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

