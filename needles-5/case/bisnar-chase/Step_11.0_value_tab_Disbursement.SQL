
USE [SA]
GO


/*
alter table [sma_TRN_Disbursement] disable trigger all
delete from [sma_TRN_Disbursement] 
DBCC CHECKIDENT ('[sma_TRN_Disbursement]', RESEED, 0);
alter table [sma_TRN_Disbursement] enable trigger all

*/

--select distinct code, description from [NeedlesNeosBisnarChase].[dbo].[value] order by code

---(0)---
if not exists (SELECT * FROM sys.columns WHERE Name = N'saga' AND Object_ID = Object_ID(N'sma_TRN_Disbursement'))
begin
    ALTER TABLE [sma_TRN_Disbursement] ADD [saga] varchar(50) NULL; 
end
GO
/*
INSERT INTO [sma_MST_CheckRequestStatus] ([description])
select 'Unrecouped'
EXCEPT SELECT [description] FROM [sma_MST_CheckRequestStatus]
*/
---(0)---
INSERT INTO [sma_MST_DisbursmentType] ( disnTypeCode, dissTypeName )
(
	SELECT DISTINCT 'CONVERSION',VC.[description]
	FROM NeedlesNeosBisnarChase..value_code vc
	JOIN NeedlesNeosBisnarChase..value_Indexed vi on vc.id = vi.valuecodeid
	WHERE isnull(vc.code,'') in ( 'INTEREST','DTF','FILE MAINT','COMM FUND','CDB','CASEEXP','RFNDAYFEE','REIMBURSE') 
)
EXCEPT 
SELECT 'CONVERSION',dissTypeName FROM [sma_MST_DisbursmentType] 



---(0)---
if exists (select * from sys.objects where name='value_tab_Disbursement_Helper' and type='U')
begin
	drop table value_tab_Disbursement_Helper
end 
GO

---(0)---
create table value_tab_Disbursement_Helper (
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
CONSTRAINT IOC_Clustered_Index_value_tab_Disbursement_Helper PRIMARY KEY CLUSTERED ( TableIndex )
) ON [PRIMARY] 
GO

CREATE NONCLUSTERED INDEX IX_NonClustered_Index_value_tab_Disbursement_Helper_case_id ON [value_tab_Disbursement_Helper] (case_id);   
CREATE NONCLUSTERED INDEX IX_NonClustered_Index_value_tab_Disbursement_Helper_value_id ON [value_tab_Disbursement_Helper] (value_id);   
CREATE NONCLUSTERED INDEX IX_NonClustered_Index_value_tab_Disbursement_Helper_ProviderNameId ON [value_tab_Disbursement_Helper] (ProviderNamesId);   
GO

---(0)---
insert into value_tab_Disbursement_Helper ( case_id,value_id,ProviderNamesId,ProviderName,ProviderCID,ProviderCTG,ProviderAID,ProviderUID,casnCaseID,PlaintiffID )
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
FROM [NeedlesNeosBisnarChase].[dbo].[value_Indexed] V
JOIN [NeedlesNeosBisnarChase].[dbo].[value_code] VC on v.valuecodeid = vc.id
JOIN [sma_TRN_cases] CAS on CAS.Needles_saga = convert(varchar(50),V.casesid)
JOIN IndvOrgContacts_Indexed IOC on IOC.SAGA = convert(varchar(50),V.[namesid] )
WHERE code in ( 'INTEREST','DTF','FILE MAINT','COMM FUND','CDB','CASEEXP','RFNDAYFEE','REIMBURSE') 
GO

---(0)---
DBCC DBREINDEX('value_tab_Disbursement_Helper',' ',90)  WITH NO_INFOMSGS 
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
FROM [NeedlesNeosBisnarChase].[dbo].[value_Indexed] V
JOIN [sma_TRN_cases] CAS on CAS.Needles_saga =  convert(varchar(50),V.casesid)
JOIN NeedlesNeosBisnarChase..Party_Indexed pt on pt.id = v.partyid
JOIN IndvOrgContacts_Indexed IOC on IOC.SAGA = convert(varchar(50),pt.namesid)
JOIN [sma_TRN_Plaintiff] T on T.plnnContactID=IOC.CID and T.plnnContactCtg=IOC.CTG and T.plnnCaseID=CAS.casnCaseID

update value_tab_Disbursement_Helper set PlaintiffID=A.plnnPlaintiffID
from value_tab_Multi_Party_Helper_Temp A
where case_id=A.cid and value_id=A.vid
GO

---(0)--- value_id may associate with defendant. steve malman make it associates to primary plaintiff 
if exists (select * from sys.objects where Name='value_tab_Multi_Party_Helper_Temp')
begin
    drop table value_tab_Multi_Party_Helper_Temp
end
GO

SELECT 
    V.casesid		    as cid,	
    V.id				as vid,
    ( select plnnPlaintiffID from [sma_TRN_Plaintiff] where plnnCaseID=CAS.casnCaseID and plnbIsPrimary=1) as plnnPlaintiffID 
    into value_tab_Multi_Party_Helper_Temp   
FROM [NeedlesNeosBisnarChase].[dbo].[value_Indexed] V
JOIN [sma_TRN_cases] CAS on CAS.Needles_saga =  convert(varchar(50),V.casesid)
JOIN NeedlesNeosBisnarChase..Party_Indexed pt on pt.id = v.partyid
JOIN IndvOrgContacts_Indexed IOC on IOC.SAGA = convert(varchar(50),pt.namesid)
JOIN [sma_TRN_Defendants] D on D.defnContactID=IOC.CID and D.defnContactCtgID=IOC.CTG and D.defnCaseID=CAS.casnCaseID
GO

update value_tab_Disbursement_Helper set PlaintiffID=A.plnnPlaintiffID
from value_tab_Multi_Party_Helper_Temp A
where case_id=A.cid and value_id=A.vid
GO


---
alter table [sma_TRN_Disbursement] disable trigger all
---
GO
---(1)---
INSERT INTO [sma_TRN_Disbursement]
(
		disnCaseID,
		disnPayeeContactCtgID,
		disnPayeeContactID,
		disnAmount,
		disnPlaintiffID,
		dissDisbursementType,
		UniquePayeeID,
		dissDescription,
		dissComments,
		disnCheckRequestStatus,
		disdBillDate,
		disdDueDate,
		disnRecUserID,
		disdDtCreated,
		disnRecoverable,
		saga
)
select 
    MAP.casnCaseID		   as disnCaseID,
    MAP.ProviderCTG		   as disnPayeeContactCtgID,
    MAP.ProviderCID		   as disnPayeeContactID,
    V.total_value		   as disnAmount,
    MAP.PlaintiffID 	   as disnPlaintiffID,
    (select disnTypeID from [sma_MST_DisbursmentType] where dissTypeName= vc.[description]) 
						   as dissDisbursementType,
    MAP.ProviderUID		   as UniquePayeeID,
    V.[memo]			   as dissDescription,
	--isnull('Invoice Request #: ' + nullif(convert(varchar,uvd.[Invoice__Request_#]),'') + CHAR(13),'') +
	--isnull('Trans ID Approval Code: ' + nullif(convert(varchar,uvd.[Trans_ID__Approval_Code]),'') + CHAR(13),'') +
	--isnull('Check Voided: ' + nullif(convert(varchar,uvd.Check_Voided),'') + CHAR(13),'') +
	''					   as dissComments,
    --case when v.code in ( 'CEX', 'EXP', 'HEA', 'REN','TOW','TRF' )   then  (select Id FROM [sma_MST_CheckRequestStatus] where [Description]='Paid')	
		--when v.code in ('UCC') then  (select Id FROM [sma_MST_CheckRequestStatus] where [Description]='Unrecouped')	
	NULL				   as disnCheckRequestStatus,
    case when V.[start_date] between '1900-01-01' and '2079-06-06' then V.[start_date]
	   else null end	   as disdBillDate,
    case when V.stop_date between '1900-01-01' and '2079-06-06' then V.stop_date
	   else null end	   as disdDueDate,
    (select usrnUserID from sma_MST_Users where saga= convert(Varchar(50),v.staffcreatedid))				   
						   as disnRecUserID,
    case when v.date_created between '1900-01-01' and '2079-06-06' then v.date_created
	   else null end	   as disdDtCreated,
	case when vc.code = 'DTF' then 0 else 1 end		as disnRecoverable,
	--1						as disnRecoverable,
    V.id				   as saga
--select *
FROM [NeedlesNeosBisnarChase].[dbo].[value_Indexed] V
JOIN [NeedlesNeosBisnarChase].[dbo].[value_code] VC on v.valuecodeid = vc.id
--LEFT JOIN NeedlesNeosBisnarChase..user_value_data uvd on v.value_ID = uvd.value_id
JOIN value_tab_Disbursement_Helper MAP on MAP.case_id=V.casesid and MAP.value_id=V.id
GO
---
ALTER TABLE [sma_TRN_Disbursement] enable trigger all
GO
---