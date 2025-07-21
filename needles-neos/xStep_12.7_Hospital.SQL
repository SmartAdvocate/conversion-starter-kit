
USE  [SAbilleasterlyLaw]
GO

 
alter table [sma_TRN_Hospitals] disable trigger all
delete from [sma_TRN_Hospitals] 
DBCC CHECKIDENT ('[sma_TRN_Hospitals]', RESEED, 0);
alter table [sma_TRN_Hospitals] enable trigger all

---(0)---
if not exists (SELECT * FROM sys.columns WHERE Name = N'saga' AND Object_ID = Object_ID(N'sma_TRN_Hospitals'))
begin
    ALTER TABLE [sma_TRN_Hospitals] ADD [saga] varchar(50) NULL; 
end
GO

---(0)---
if exists (select * from sys.objects where name='value_tab_Hospitals_Helper' and type='U')
begin
	drop table value_tab_Hospitals_Helper
end 
GO





create table value_tab_Hospitals_Helper (
    TableIndex [int] IDENTITY(1,1) NOT NULL,
    case_id		    varchar(50),
    value_id		varchar(50),
    ProviderNamesId	varchar(50),
    ProviderName	varchar(200),
    ProviderCID	    int,
    ProviderCTG	    int,
    ProviderAID	    int,
    ProviderUID	    bigint,
    casnCaseID		int,
    PlaintiffID	    int,
-----CONSTRAINT IOC_Clustered_Index_value_tab_Disbursement_Helper PRIMARY KEY CLUSTERED ( TableIndex )
) ON [PRIMARY] 
GO

---0---
insert into value_tab_Hospitals_Helper ( case_id,value_id,ProviderNamesId,ProviderName,ProviderCID,ProviderCTG,ProviderAID,ProviderUID,casnCaseID,PlaintiffID )
select
    V.casesid		    as case_id,	-- needles case
    V.id			    as tab_id,		-- needles records TAB item
    V.namesid		    as ProviderNamesId,  
    IOC.Name		    as ProviderName,
    IOC.CID				as ProviderCID,  
    IOC.CTG				as ProviderCTG,
    IOC.AID				as ProviderAID,
    IOC.UNQCID		    as ProviderUID,
    CAS.casnCaseID	    as casnCaseID,
    null			    as PlaintiffID
--SELECT *
FROM  [NeosBillEasterly].[dbo].[value_Indexed] V
JOIN  [NeosBillEasterly].[dbo].[value_code] VC on v.valuecodeid = vc.id
JOIN [sma_TRN_cases] CAS on CAS.Neos_saga = convert(varchar(50),V.casesid)
JOIN IndvOrgContacts_Indexed IOC on IOC.SAGA_ref = convert(varchar(50),V.[namesid] )
WHERE code in (    'MEDICAL',   'SUBRO', 'LIEN', 'PPD', 'MED',  'HEALTH' )
			            
GO

---(0)---
DBCC DBREINDEX('value_tab_Hospitals_Helper',' ',90)  WITH NO_INFOMSGS 
GO

---(0)--- value_id may associate with secondary plaintiff
if exists (select * from sys.objects where Name='value_tab_Multi_Party_Helper_Temp')
begin
    drop table value_tab_Multi_Party_Helper_Temp
end
GO

SELECT 
    V.casesid		    as cid,	
    V.id			    as vid,
    T.plnnPlaintiffID
INTO value_tab_Multi_Party_Helper_Temp   
FROM  [NeosBillEasterly].[dbo].[value_Indexed] V
JOIN [sma_TRN_cases] CAS on CAS.Neos_saga =  convert(varchar(50),V.casesid)
JOIN  [NeosBillEasterly]..Party_Indexed pt on pt.id = v.partyid
JOIN IndvOrgContacts_Indexed IOC on IOC.SAGA_REF = convert(varchar(50),pt.namesid)
JOIN [sma_TRN_Plaintiff] T on T.plnnContactID=IOC.CID and T.plnnContactCtg=IOC.CTG and T.plnnCaseID=CAS.casnCaseID

 update value_tab_Hospitals_Helper set PlaintiffID=A.plnnPlaintiffID
from value_tab_Multi_Party_Helper_Temp A
where case_id=A.cid and value_id=A.vid
GO

 ---(0)--- value_id may associate with defendant. steve malman make it associates to primary plaintiff 
if exists (select * from sys.objects where Name='value_tab_Multi_Party_Helper_Temp')
begin
    drop table value_tab_Multi_Party_Helper_Temp
end
GO

WITH RankedPlaintiffs AS (
    SELECT 
        plnnPlaintiffID,
        plnnCaseID,
        ROW_NUMBER() OVER (PARTITION BY plnnCaseID ORDER BY plnnPlaintiffID) AS row_num
    FROM sma_TRN_Plaintiff
    WHERE plnbIsPrimary = 1
)
SELECT 
    V.casesid AS cid,	
    V.id AS vid,
    RP.plnnPlaintiffID
INTO value_tab_Multi_Party_Helper_Temp   
FROM [NeosBillEasterly].[dbo].[value_Indexed] V
JOIN [sma_TRN_cases] CAS ON CAS.Neos_saga = CONVERT(VARCHAR(50), V.casesid)
JOIN [NeosBillEasterly]..Party_Indexed pt ON pt.id = V.partyid
JOIN RankedPlaintiffs RP ON RP.plnnCaseID = CAS.casnCaseID AND RP.row_num = 1
JOIN IndvOrgContacts_Indexed IOC ON IOC.SAGA_ref = CONVERT(VARCHAR(50), pt.namesid)
JOIN [sma_TRN_Defendants] D ON D.defnContactID = IOC.CID 
    AND D.defnContactCtgID = IOC.CTG 
    AND D.defnCaseID = CAS.casnCaseID;


update value_tab_Hospitals_Helper set PlaintiffID=A.plnnPlaintiffID
from value_tab_Multi_Party_Helper_Temp A
where case_id=A.cid and value_id=A.vid
GO

alter table [sma_TRN_Hospitals ] disable trigger all
 GO

---(1)---
INSERT INTO [sma_TRN_Hospitals]
(
		hosnCaseID,
	 
		hosnContactCtg,
		hosnContactID,
		hosnTotalBill,
		hosnPlaintiffID,
		hossMedProType,
		hosnIndvProvContactID,
	 
		hosnComments,
		 
		 hosdStartDt,
	     hosdEndDt,
		hosnRecUserID,
		hosdDtCreated,
		 
		saga
)
select 
    MAP.casnCaseID		   as disnCaseID,
    MAP.ProviderCTG		   as disnPayeeContactCtgID,
    MAP.ProviderCID		   as disnPayeeContactID,
    V.total_value		   as hosnTotalBill,
    MAP.PlaintiffID 	   as hosnPlaintiffID,
	'M' as hossMedProType,
   
    MAP.ProviderUID		   as hosnIndvProvContactID,
  
	 V.[memo]					   as hosnComments,  
 
    case when V.[start_date] between '1900-01-01' and '2079-06-06' then V.[start_date]
	   else null end	   as hosdStartDt ,
     case when V.[stop_date] between '1900-01-01' and '2079-06-06' then V.[stop_date]
	   else null end	  as  hosdEndDt,
    (select usrnUserID from sma_MST_Users where saga= convert(Varchar(50),v.staffcreatedid))				   
						   as hosnRecUserID,
    case when v.date_created between '1900-01-01' and '2079-06-06' then v.date_created
	   else null end	   as hosdDtCreated,
	 
	--1						as disnRecoverable,
    V.id				   as saga
--select  *  
FROM  [NeosBillEasterly].[dbo].[value_Indexed] V
JOIN  [NeosBillEasterly].[dbo].[value_code] VC on v.valuecodeid = vc.id
 LEFT JOIN [NeosBillEasterly]..user_value_data uvd on v.id = uvd.valueid
JOIN value_tab_Disbursement_Helper MAP on MAP.case_id=V.casesid and MAP.value_id=V.id
-----where map.casnCaseID = '160'
GO


alter table [sma_TRN_Hospitals ] enable trigger all