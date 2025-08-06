USE SA
GO

----------------------------------------------------------------------------
--CUSTOM DAMAGE
----------------------------------------------------------------------------
--delete From [sma_TRN_SpDamages] where spdsRefTable = 'CustomDamage'
--INSERT DAMAGE SUBTYPE (UNDER "OTHER" DAMAGE TYPE)
IF (select count(*) from sma_MST_SpecialDamageType where SpDamageTypeDescription = 'Other') = 0
BEGIN
INSERT INTO sma_MST_SpecialDamageType (SpDamageTypeDescription, IsEditableType, SpDamageTypeCreatedUserID, SpDamageTypeDtCreated)
select 'Other', 1, 368, getdate()
END

INSERT INTO sma_MST_SpecialDamageSubType (spdamagetypeid, SpDamageSubTypeDescription ) --, SpDamageSubTypeDtCreated, SpDamageSubTypeCreatedUserID)
SELECT (select spdamagetypeid from sma_MST_SpecialDamageType where SpDamageTypeDescription = 'Other'), vc.[description]--, getdate(), 368
FROM NeedlesNeosBisnarChase..value_code vc
WHERE code in ('PROP DAM')
EXCEPT SELECT spdamagetypeid, SpDamageSubTypeDescription FROM sma_MST_SpecialDamageSubType

---(0)---
IF EXISTS (select * from sys.objects where name='value_tab_spDamages_Helper' and type='U')
BEGIN
	DROP TABLE value_tab_spDamages_Helper
END 
GO

---(0)---
CREATE TABLE value_tab_spDamages_Helper (
    TableIndex [int] IDENTITY(1,1) NOT NULL,
    case_id		    varchar(50),
    value_id		varchar(50),
    ProviderNameId	varchar(50),
    ProviderName	varchar(200),
    ProviderCID	    int,
    ProviderCTG	    int,
    ProviderAID	    int,
    casnCaseID		int,
    PlaintiffID	    int,
CONSTRAINT IOC_Clustered_Index_value_tab_spDamages_Helper PRIMARY KEY CLUSTERED ( TableIndex )
) ON [PRIMARY] 
GO

CREATE NONCLUSTERED INDEX IX_NonClustered_Index_value_tab_spDamages_Helper_case_id ON [value_tab_spDamages_Helper] (case_id);   
CREATE NONCLUSTERED INDEX IX_NonClustered_Index_value_tab_spDamages_Helper_value_id ON [value_tab_spDamages_Helper] (value_id);   
CREATE NONCLUSTERED INDEX IX_NonClustered_Index_value_tab_spDamages_Helper_ProviderNameId ON [value_tab_spDamages_Helper] (ProviderNameId);   
GO

---(0)---
INSERT INTO [value_tab_spDamages_Helper] ( case_id,value_id,ProviderNameId,ProviderName,ProviderCID,ProviderCTG,ProviderAID,casnCaseID,PlaintiffID )
SELECT
    convert(varchar(50),v.casesid)		as case_id,	-- needles case
    convert(varchar(50),V.id)			as tab_id,		-- needles records TAB item
    convert(varchar(50),V.namesid)		as ProviderNameId,  
    IOC.[Name]		as ProviderName,
    IOC.CID		    as ProviderCID,  
    IOC.CTG		    as ProviderCTG,
    IOC.AID		    as ProviderAID,
    CAS.casnCaseID	as casnCaseID,
    null			as PlaintiffID  
FROM [NeedlesNeosBisnarChase].[dbo].[value_Indexed] V
JOIN [NeedlesNeosBisnarChase].[dbo].[value_code] VC on v.valuecodeid = vc.id
JOIN [sma_TRN_cases] CAS on CAS.Needles_saga = convert(varchar(50),V.casesid)
JOIN IndvOrgContacts_Indexed IOC on IOC.SAGA = convert(varchar(50),V.namesid)
WHERE code in ('PROP DAM')

---(0)---
DBCC DBREINDEX('value_tab_spDamages_Helper',' ',90)  WITH NO_INFOMSGS 
GO


---(0)---
IF EXISTS (select * from sys.objects where Name='value_tab_Multi_Party_Helper_Temp')
BEGIN
    DROP TABLE value_tab_Multi_Party_Helper_Temp
END
GO

SELECT 
    V.casesid		    as cid,	
    V.id				as vid,
    T.plnnPlaintiffID
INTO value_tab_Multi_Party_Helper_Temp   
FROM [NeedlesNeosBisnarChase].[dbo].[value_Indexed] V
JOIN [NeedlesNeosBisnarChase].[dbo].[value_code] VC on v.valuecodeid = vc.id
JOIN [sma_TRN_cases] CAS on CAS.Needles_saga = convert(varchar(50),V.casesid)
JOIN [NeedlesNeosBisnarChase].[dbo].[Party_Indexed] pt on pt.id = v.partyid  and v.casesid = pt.casesid
JOIN IndvOrgContacts_Indexed IOC on IOC.SAGA = convert(varchar(50),pt.namesid)
JOIN [sma_TRN_Plaintiff] T on T.plnnContactID=IOC.CID and T.plnnContactCtg=IOC.CTG and T.plnnCaseID=CAS.casnCaseID
GO

UPDATE [value_tab_spDamages_Helper] SET PlaintiffID=A.plnnPlaintiffID
FROM value_tab_Multi_Party_Helper_Temp A
WHERE case_id=A.cid and value_id=A.vid
GO


IF EXISTS (select * from sys.objects where Name='value_tab_Multi_Party_Helper_Temp')
BEGIN
    DROP TABLE value_tab_Multi_Party_Helper_Temp
END
GO

SELECT 
    V.casesid		    as cid,	
    V.id				as vid,
    ( select plnnPlaintiffID from [sma_TRN_Plaintiff] where plnnCaseID=CAS.casnCaseID and plnbIsPrimary=1) as plnnPlaintiffID 
    into value_tab_Multi_Party_Helper_Temp   
FROM [NeedlesNeosBisnarChase].[dbo].[value_Indexed] V
JOIN [NeedlesNeosBisnarChase].[dbo].[value_code] VC on v.valuecodeid = vc.id
JOIN [sma_TRN_cases] CAS on CAS.Needles_saga = convert(varchar(50),V.casesid)
JOIN [NeedlesNeosBisnarChase].[dbo].[Party_Indexed] pt on pt.id = convert(varchar(50),v.partyid) and v.casesid = pt.casesid
JOIN IndvOrgContacts_Indexed IOC on IOC.SAGA = convert(Varchar(50),pt.namesid)
JOIN [sma_TRN_Defendants] D on D.defnContactID=IOC.CID and D.defnContactCtgID=IOC.CTG and D.defnCaseID=CAS.casnCaseID
GO

UPDATE value_tab_spDamages_Helper set PlaintiffID=A.plnnPlaintiffID
FROM value_tab_Multi_Party_Helper_Temp A
WHERE case_id=A.cid and value_id=A.vid
GO


ALTER TABLE [sma_TRN_SpDamages] DISABLE TRIGGER ALL
GO

INSERT INTO [sma_TRN_SpDamages]
(
     spdsRefTable
    ,spdnRecordID
	,spddCaseID
	,spddPlaintiff
	,spddDamageType
	,spddDamageSubType
    ,spdnRecUserID
    ,spddDtCreated
    ,spdnLevelNo
    ,spdnBillAmt
    ,spddDateFrom
    ,spddDateTo
	,spdsComments
)
SELECT DISTINCT 
    'CustomDamage'	    as spdsRefTable,
    NULL				as spdnRecordID,
	sdh.casnCaseID		as spddCaseID,
	sdh.PlaintiffID		as spddPlaintiff,
	(select spdamagetypeid from sma_MST_SpecialDamageType where SpDamageTypeDescription = 'Other')		as spddDamageType,
	(select SpDamageSubTypeID from sma_MST_SpecialDamageSubType 
			where SpDamageSubTypeDescription = vc.[description] and spdamagetypeid = (select spdamagetypeid from sma_MST_SpecialDamageType where SpDamageTypeDescription = 'Other'))		as spddDamageSubType,
    368					as spdnRecUserID,
    getdate()		    as spddDtCreated,
    0					as spdnLevelNo,
    v.total_value	    as spdnBillAmt,
    case when v.[start_date] between '1900-01-01' and '2079-06-01' then v.[start_date] else null end	    as spddDateFrom,
    case when v.stop_date between '1900-01-01' and '2079-06-01' then v.stop_date else null end		    as spddDateTo,
	'Provider: ' + SDH.[ProviderName] +char(13) + v.memo	as spdsComments
FROM [NeedlesNeosBisnarChase].[dbo].[value_Indexed] V
JOIN [NeedlesNeosBisnarChase].[dbo].[value_code] VC on v.valuecodeid = vc.id
JOIN [value_tab_spDamages_Helper] SDH on convert(varchar(50),v.id) = sdh.value_id
WHERE vc.code in ('PROP DAM')
GO

ALTER TABLE [sma_TRN_SpDamages] ENABLE TRIGGER ALL
GO
