
USE   [SAbilleasterlyLaw]
GO


 
alter table [sma_TRN_Settlements] disable trigger all
delete [sma_TRN_Settlements]
DBCC CHECKIDENT ('[sma_TRN_Settlements]', RESEED, 0);
alter table [sma_TRN_Settlements] enable trigger all
 

--select distinct code, description from [NeosBrianWhite].[dbo].[value] order by code
---(0)---
if not exists (SELECT * FROM sys.columns WHERE Name = N'saga' AND Object_ID = Object_ID(N'sma_TRN_Settlements'))
begin
    ALTER TABLE [sma_TRN_Settlements] ADD [saga] varchar(50) NULL; 
end
GO

---(0)---
------------------------------------------------
--INSERT SETTLEMENT TYPES
------------------------------------------------
INSERT INTO [sma_MST_SettlementType] (SettlTypeName)
SELECT 'Settlement'
EXCEPT SELECT SettlTypeName FROM [sma_MST_SettlementType]
GO


if exists (select * from sys.objects where name='value_tab_Settlement_Helper' and type='U')
begin
	drop table value_tab_Settlement_Helper
end 
GO

---(0)---
create table value_tab_Settlement_Helper (
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
CONSTRAINT IOC_Clustered_Index_value_tab_Settlement_Helper PRIMARY KEY CLUSTERED ( TableIndex )
) ON [PRIMARY] 
GO

CREATE NONCLUSTERED INDEX IX_NonClustered_Index_value_tab_Settlement_Helper_case_id ON [value_tab_Settlement_Helper] (case_id);   
CREATE NONCLUSTERED INDEX IX_NonClustered_Index_value_tab_Settlement_Helper_value_id ON [value_tab_Settlement_Helper] (value_id);   
CREATE NONCLUSTERED INDEX IX_NonClustered_Index_value_tab_Settlement_Helper_ProviderNameId ON [value_tab_Settlement_Helper] (ProviderNameId);   
CREATE NONCLUSTERED INDEX IX_NonClustered_Index_value_tab_Settlement_Helper_PlaintiffID ON [value_tab_Settlement_Helper] (PlaintiffID);   
GO

---(0)---
insert into value_tab_Settlement_Helper ( case_id,value_id,ProviderNameId,ProviderName,ProviderCID,ProviderCTG,ProviderAID,casnCaseID,PlaintiffID )
select
    convert(varchar(50),V.casesid)		as case_id,	-- needles case
    convert(varchar(50),V.id)			as tab_id,		-- needles records TAB item
     convert(varchar(50),V.namesid)		as ProviderNameId,  
    IOC.Name		as ProviderName,
    IOC.CID		    as ProviderCID,  
    IOC.CTG		    as ProviderCTG,
    IOC.AID		    as ProviderAID,
    CAS.casnCaseID	as casnCaseID,
    null			as PlaintiffID
---- select *
FROM  [NeosBillEasterly].[dbo].[value_Indexed] V
JOIN  [NeosBillEasterly].[dbo].[value_code] VC on v.valuecodeid = vc.id
JOIN [sma_TRN_cases] CAS on CAS.Neos_saga = convert(varchar(50),V.casesid)
JOIN IndvOrgContacts_Indexed IOC on IOC.SAGA_ref = convert(varchar(50),V.namesid)
WHERE code IN ( 'OFFER', 'DEPOSIT', 'OVER', 'FEE', 'SET PROC', 'SET', 'SET ADV',  'TRUST PAY', 'TOTAL')

    
 

GO
---(0)---
DBCC DBREINDEX('value_tab_Settlement_Helper',' ',90)  WITH NO_INFOMSGS 
GO


---(0)--- (prepare for multiple party)
if exists (select * from sys.objects where Name='value_tab_Multi_Party_Helper_Temp')
begin
    drop table value_tab_Multi_Party_Helper_Temp
end
GO

SELECT 
    V.casesid		    as cid,	
    V.id				as vid,
    T.plnnPlaintiffID
INTO value_tab_Multi_Party_Helper_Temp   
FROM   [NeosBillEasterly].[dbo].[value_Indexed] V
JOIN [NeosBillEasterly].[dbo].[value_code] VC on v.valuecodeid = vc.id
JOIN [sma_TRN_cases] CAS on CAS.Neos_saga = convert(varchar(50),V.casesid)
JOIN [sma_TRN_Plaintiff] t on t.plnnCaseID=CAS.casnCaseID and t.saga_party = v.partyid
go
 

UPDATE value_tab_Settlement_Helper set PlaintiffID=A.plnnPlaintiffID
FROM value_tab_Multi_Party_Helper_Temp A
WHERE case_id=A.cid and value_id=A.vid
GO


if exists (select * from sys.objects where Name='value_tab_Multi_Party_Helper_Temp')
begin
    drop table value_tab_Multi_Party_Helper_Temp
end
GO

/*SELECT 
    V.casesid		    as cid,	
    V.id				as vid,
    ( select plnnPlaintiffID from [sma_TRN_Plaintiff] where plnnCaseID=CAS.casnCaseID and plnbIsPrimary=1) as plnnPlaintiffID 
    into value_tab_Multi_Party_Helper_Temp   
FROM [NeosBillEasterly].[dbo].[value_Indexed] V
JOIN  [NeosBillEasterly].[dbo].[value_code] VC on v.valuecodeid = vc.id
JOIN [sma_TRN_cases] CAS on CAS.Neos_saga = convert(varchar(50),V.casesid)
JOIN [sma_TRN_Defendants] d on d.defnCaseID = cas.casncaseid and d.saga_party = v.partyid  */

 
SELECT  
    V.casesid AS cid,
    V.id AS vid,
    RP.plnnPlaintiffID
 INTO value_tab_Multi_Party_Helper_Temp   
FROM [NeosBillEasterly].[dbo].[value_Indexed] V
JOIN [NeosBillEasterly].[dbo].[value_code] VC ON V.valuecodeid = VC.id
JOIN [sma_TRN_cases] CAS ON CAS.Neos_saga = CONVERT(VARCHAR(50), V.casesid)
JOIN [sma_TRN_Defendants] D ON D.defnCaseID = CAS.casnCaseID AND D.saga_party = V.partyid
LEFT JOIN sma_TRN_Plaintiff RP ON RP.plnnCaseID = CAS.casnCaseID  


 
GO

update value_tab_Settlement_Helper set PlaintiffID=A.plnnPlaintiffID
from value_tab_Multi_Party_Helper_Temp A
where case_id=A.cid and value_id=A.vid
GO

----(1)----(  specified items go to settlement rows )
ALTER TABLE [sma_TRN_Settlements] DISABLE TRIGGER ALL
GO

INSERT INTO [sma_TRN_Settlements]
(
    stlnCaseID,
    stlnSetAmt,
    stlnNet,
    stlnNetToClientAmt,
    stlnPlaintiffID,
    stlnStaffID, 
    stlnLessDisbursement,
    stlnGrossAttorneyFee,
	stlnForwarder,  --referrer
	stlnOther,
	stlnMedPay,
	InterestOnDisbursement,
    stlsComments,
    stlTypeID,
	stldSettlementDate,
	saga
)
select 
    MAP.casnCaseID					as stlnCaseID,
    case when vc.code IN ( 'OFFER', 'DEPOSIT', 'OVER', 'FEE', 'SET PROC', 'SET', 'SET ADV', 'TRUST PAY', 'TOTAL' ) 
	          then v.total_value 
			  else null 
	end			as stlnSetAmt,
    null							as stlnNet,
    null							as stlnNetToClientAmt, 
    MAP.PlaintiffID					as stlnPlaintiffID,
    null							as stlnStaffID, 
    null							as stlnLessDisbursement,
     null  					as stlnGrossAttorneyFee,
	 null  	as stlnForwarder,    --Referrer
	null							as stlnOther,
	  null  					as stlnMedPay,
    null							as InterestOnDisbursement,
    isnull('memo:' + nullif(V.memo,'') + CHAR(13),'') +
    isnull('code:' + nullif(Vc.code,'') + CHAR(13),'') +
	''								as [stlsComments],
    (select ID from [sma_MST_SettlementType] where SettlTypeName= 'Settlement' )  as stlTypeID,
      V.[start_date]			as stldSettlementDate,
    V.id							as saga
---- select v.start_date, *
FROM  [NeosBillEasterly].[dbo].[value_Indexed] V
JOIN  [NeosBillEasterly].[dbo].[value_code] VC on v.valuecodeid = vc.id
JOIN value_tab_Settlement_Helper MAP on MAP.case_id= convert(varchar(50),V.casesid)
                                                                and MAP.value_id= convert(varchar(50),V.id)
 WHERE code IN ( 'OFFER', 'DEPOSIT', 'OVER', 'FEE', 'SET PROC', 'SET', 'SET ADV',  'TRUST PAY', 'TOTAL') and memo <> 'Retainer Fee'
        ---  and casesid = '5AF35858-9A23-4012-82EB-AA450120FCAD'
 
 

GO

ALTER TABLE [sma_TRN_Settlements] ENABLE TRIGGER ALL
GO

