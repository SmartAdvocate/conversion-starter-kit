USE SA
GO

/*
alter table [sma_TRN_Lienors] disable trigger all
delete from [sma_TRN_Lienors] 
DBCC CHECKIDENT ('[sma_TRN_Lienors]', RESEED, 0);
alter table [sma_TRN_Lienors] enable trigger all

alter table [sma_TRN_LienDetails] disable trigger all
delete from [sma_TRN_LienDetails] 
DBCC CHECKIDENT ('[sma_TRN_LienDetails]', RESEED, 0);
alter table [sma_TRN_LienDetails] enable trigger all


alter table [sma_TRN_Lienors] disable trigger all

alter table [sma_TRN_LienDetails] disable trigger all
*/

---(0)---
IF NOT EXISTS (SELECT * FROM sys.columns WHERE Name = N'saga' AND Object_ID = Object_ID(N'sma_TRN_Lienors'))
BEGIN
    ALTER TABLE [sma_TRN_Lienors] ADD [saga] varchar(50) NULL; 
END

---(0)---
IF EXISTS (select * from sys.objects where name='value_tab_Liencheckbox_Helper' and type='U')
BEGIN
	DROP TABLE value_tab_Liencheckbox_Helper
END 
GO

---(0)---
CREATE TABLE value_tab_Liencheckbox_Helper (
    TableIndex		    int IDENTITY(1,1) NOT NULL,
    value_id		    varchar(50),
CONSTRAINT IOC_Clustered_Index_value_tab_Liencheckbox_Helper PRIMARY KEY CLUSTERED ( TableIndex )
) ON [PRIMARY] 
CREATE NONCLUSTERED INDEX IX_NonClustered_Index_value_tab_Liencheckbox_Helper_value_id ON [value_tab_Liencheckbox_Helper] (value_id);   
GO

---(0)---
INSERT INTO value_tab_Liencheckbox_Helper ( value_id )
SELECT VP1.id
FROM [NeedlesNeosBisnarChase].[dbo].[value_Indexed] VP1 
LEFT JOIN ( select distinct id from [NeedlesNeosBisnarChase].[dbo].[value_Indexed] where lien=1 ) VP2 on VP1.id = VP2.id and VP2.id is not null
WHERE VP2.id is not null -- ( Lien checkbox got marked ) 
GO

---(0)---
DBCC DBREINDEX('value_tab_Liencheckbox_Helper',' ',90)  WITH NO_INFOMSGS 
GO


---(0)---
INSERT INTO [sma_MST_LienType] ([lntsCode],[lntsDscrptn])
(
	SELECT DISTINCT 'CONVERSION',VC.[description]
	FROM [NeedlesNeosBisnarChase].[dbo].[value] V
	JOIN [NeedlesNeosBisnarChase].[dbo].[value_code] VC on VC.id=V.valuecodeid
	WHERE isnull(Vc.code,'') in ( 'LIEN REIMB', 'FEE LIEN','LIEN DUE' )
)
EXCEPT
SELECT [lntsCode],[lntsDscrptn] FROM [sma_MST_LienType] 
GO


---(0)---
IF EXISTS (select * from sys.objects where name='value_tab_Lien_Helper' and type='U')
BEGIN
	DROP TABLE value_tab_Lien_Helper
END 
GO

---(0)---
CREATE TABLE value_tab_Lien_Helper (
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
    Paid			varchar(20),
CONSTRAINT IOC_Clustered_Index_value_tab_Lien_Helper PRIMARY KEY CLUSTERED ( TableIndex )
) ON [PRIMARY] 
GO

CREATE NONCLUSTERED INDEX IX_NonClustered_Index_value_tab_Lien_Helper_case_id ON [dbo].[value_tab_Lien_Helper] (case_id);   
CREATE NONCLUSTERED INDEX IX_NonClustered_Index_value_tab_Lien_Helper_value_id ON [dbo].[value_tab_Lien_Helper] (value_id);   
CREATE NONCLUSTERED INDEX IX_NonClustered_Index_value_tab_Lien_Helper_ProviderNameId ON [dbo].[value_tab_Lien_Helper] (ProviderNameId);   
GO

---(0)---
INSERT INTO value_tab_Lien_Helper ( case_id,value_id,ProviderNameId,ProviderName,ProviderCID,ProviderCTG,ProviderAID,casnCaseID,PlaintiffID,Paid )
SELECT
    convert(varchar(50),V.casesid)	    as case_id,	-- needles case
    convert(varchar(50),V.id)		    as tab_id,		-- needles records TAB item
    convert(varchar(50),V.namesid)		as ProviderNameId,  
    IOC.[Name]		    as ProviderName,
    IOC.CID				as ProviderCID,  
    IOC.CTG				as ProviderCTG,
    IOC.AID				as ProviderAID,
    CAS.casnCaseID		as casnCaseID,
    null			    as PlaintiffID,
    null			    as Paid
FROM [NeedlesNeosBisnarChase].[dbo].[value_Indexed] V
JOIN [NeedlesNeosBisnarChase].[dbo].[value_code] VC on VC.id=V.valuecodeid
JOIN [sma_TRN_cases] CAS on CAS.Needles_saga = convert(varchar(50),V.casesid)
JOIN [IndvOrgContacts_Indexed] IOC on IOC.SAGA = convert(varchar(50),V.Namesid) 
WHERE code in ( 'LIEN REIMB', 'FEE LIEN','LIEN DUE' )
	OR V.id in ( select value_id from value_tab_Liencheckbox_Helper ) 
GO

---(0)---
DBCC DBREINDEX('value_tab_Lien_Helper',' ',90)  WITH NO_INFOMSGS 
GO


---(0)---
IF EXISTS (select * from sys.objects where Name='value_tab_Multi_Party_Helper_Temp')
BEGIN
    DROP TABLE value_tab_Multi_Party_Helper_Temp
END
GO

SELECT 
    V.casesid		    as cid,	
    V.id		    as vid,
    convert(varchar,((select sum(payment_amount) from [NeedlesNeosBisnarChase].[dbo].[value_payment] where id = V.id))) as Paid,
    T.plnnPlaintiffID
INTO value_tab_Multi_Party_Helper_Temp   
FROM [NeedlesNeosBisnarChase].[dbo].[value_Indexed] V
JOIN [NeedlesNeosBisnarChase].[dbo].[value_code] VC on VC.id=V.valuecodeid
JOIN [sma_TRN_cases] CAS on CAS.Needles_saga = convert(varchar(50),V.casesid)
JOIN [NeedlesNeosBisnarChase].[dbo].Party_Indexed pt on pt.id = v.partyid and pt.casesid = v.casesid
JOIN [IndvOrgContacts_Indexed] IOC on IOC.SAGA = convert(varchar(50),pt.namesid)
JOIN [sma_TRN_Plaintiff] T on T.plnnContactID=IOC.CID and T.plnnContactCtg=IOC.CTG and T.plnnCaseID=CAS.casnCaseID
GO

UPDATE value_tab_Lien_Helper 
SET PlaintiffID=A.plnnPlaintiffID,Paid=A.Paid
FROM value_tab_Multi_Party_Helper_Temp A
WHERE case_id=A.cid and value_id=A.vid
GO


IF EXISTS (select * from sys.objects where Name='value_tab_Multi_Party_Helper_Temp')
BEGIN
    DROP TABLE value_tab_Multi_Party_Helper_Temp
END
GO

SELECT 
    V.casesid	    as cid,	
    V.id		    as vid,
    convert(varchar,((select sum(payment_amount) from [NeedlesNeosBisnarChase].[dbo].[value_payment] where id = V.id))) as Paid,
    ( select plnnPlaintiffID from [sma_TRN_Plaintiff] where plnnCaseID=CAS.casnCaseID and plnbIsPrimary=1) as plnnPlaintiffID 
INTO value_tab_Multi_Party_Helper_Temp   
FROM [NeedlesNeosBisnarChase].[dbo].[value_Indexed] V
JOIN [NeedlesNeosBisnarChase].[dbo].[value_code] VC on VC.id=V.valuecodeid
JOIN [sma_TRN_cases] CAS on CAS.Needles_saga = convert(varchar(50),V.casesid)
JOIN [NeedlesNeosBisnarChase].[dbo].Party_Indexed pt on pt.id = v.partyid and pt.casesid = v.casesid
JOIN [IndvOrgContacts_Indexed] IOC on IOC.SAGA = convert(varchar(50),pt.namesid)JOIN [sma_TRN_Defendants] D on D.defnContactID=IOC.CID and D.defnContactCtgID=IOC.CTG and D.defnCaseID=CAS.casnCaseID
GO

UPDATE value_tab_Lien_Helper 
SET PlaintiffID=A.plnnPlaintiffID,Paid=A.Paid
FROM value_tab_Multi_Party_Helper_Temp A
WHERE case_id=A.cid and value_id=A.vid
GO



---------------------------------------------------------------------------------------
ALTER TABLE [sma_TRN_Lienors] DISABLE TRIGGER ALL
GO
ALTER TABLE [sma_TRN_LienDetails] DISABLE TRIGGER ALL
GO
---(1)---
INSERT INTO [sma_TRN_Lienors] (
		[lnrnCaseID],
		[lnrnLienorTypeID],
		[lnrnLienorContactCtgID],
		[lnrnLienorContactID],
		[lnrnLienorAddressID],
		[lnrnLienorRelaContactID],
		[lnrnPlaintiffID],
		[lnrnCnfrmdLienAmount],
		[lnrnNegLienAmount],
		[lnrsComments],
		[lnrnRecUserID],
		[lnrdDtCreated],
		[lnrnFinal],
		[saga]
)
SELECT 
    MAP.casnCaseID				as [lnrnCaseID],
    ( select lntnLienTypeID FROM [sma_MST_LienType] where lntsDscrptn=
	   (select [description] FROM NeedlesNeosBisnarChase.[dbo].[value_code] where [code]=Vc.code)) 
								as [lnrnLienorTypeID],				   
    MAP.ProviderCTG				as [lnrnLienorContactCtgID],
    MAP.ProviderCID				as [lnrnLienorContactID],
    MAP.ProviderAID				as [lnrnLienorAddressID],
    0							as [lnrnLienorRelaContactID],
    MAP.PlaintiffID				as [lnrnPlaintiffID],
    isnull(V.total_value,0)		as [lnrnCnfrmdLienAmount],
    isnull(V.due,0)				as [lnrnNegLienAmount],
    isnull('Memo : ' + isnull(V.memo,'') + CHAR(13),'') +
    isnull('From : ' + convert(varchar(10),V.start_date) + CHAR(13),'') +
    isnull('To : ' + convert(varchar(10),V.stop_date) + CHAR(13),'') + 
    isnull('Value Total : ' + convert(varchar,V.total_value) + CHAR(13),'') +
    isnull('Reduction : ' + convert(varchar,V.reduction) + CHAR(13),'') +
    isnull('Paid : ' + MAP.Paid,'') 
								as [lnrsComments],
    368							as [lnrnRecUserID],
    getdate()					as [lnrdDtCreated],
    0							as [lnrnFinal],
    V.id					as [saga]
FROM [NeedlesNeosBisnarChase].[dbo].[value_Indexed] V
JOIN [NeedlesNeosBisnarChase].[dbo].[value_code] VC on VC.id=V.valuecodeid
JOIN [value_tab_Lien_Helper] MAP on MAP.case_id=V.casesid and MAP.value_id=V.id

---(2)---
INSERT INTO [sma_TRN_LienDetails] (
	lndnLienorID,
	lndnLienTypeID,
	lndnCnfrmdLienAmount,
	lndsRefTable,
	lndnRecUserID,
	lnddDtCreated
)
SELECT 
	lnrnLienorID			as lndnLienorID,
	lnrnLienorTypeID		as lndnLienTypeID,
	lnrnCnfrmdLienAmount	as lndnCnfrmdLienAmount,
	'sma_TRN_Lienors'		as lndsRefTable,
	368						as lndnRecUserID,
	getdate()				as lnddDtCreated
FROM [sma_TRN_Lienors]


----
ALTER TABLE [sma_TRN_Lienors] ENABLE TRIGGER ALL
GO
ALTER TABLE [sma_TRN_LienDetails] ENABLE TRIGGER ALL
GO






