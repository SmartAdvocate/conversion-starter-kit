use SA
GO

/*
alter table [sma_TRN_Hospitals] disable trigger all
delete [sma_TRN_Hospitals]
DBCC CHECKIDENT ('[sma_TRN_Hospitals]', RESEED, 0);
alter table [sma_TRN_Hospitals] enable trigger all

SELECT tl.casesid,td.tablistid, case when convert(varchar(50),td.[namesid]) IS NULL then td.[data] else convert(varchar(50),td.[namesid]) end as [data], ucf.field_title
	FROM [NeedlesNeosBisnarChase]..user_tab2_data td
	JOIN [NeedlesNeosBisnarChase]..user_tab2_list tl on tl.id = td.tablistid
	JOIN [NeedlesNeosBisnarChase]..user_case_fields ucf on ucf.id = td.usercasefieldid
	WHERE field_Title in ('Account Number', 'Comments', 'Date Received', 'Date Requested', 'For Dates From', 'Make Check Payable To', 'Medical Record#', 'Method', 
					'No Records','Ordered By', 'Pre-Payment Required', 'Provider Name', 'Through', 'Type of Record', 'Value Code' )
*/

----------------------------------------
--MEDICAL PROVIDER/TASK  PIVOT
----------------------------------------
IF EXISTS (SELECT * FROM sys.tables where name = 'MedProvTaskPivot')
BEGIN
	DROP TABLE MedProvTaskPivot
END


SELECT casesid, TabListID, [Account Number], [Comments], [Date Received], [Date Requested], [For Dates From], [Make Check Payable To], [Medical Record#], [Method], [No Records], 
					[Ordered By], [Pre-Payment Required], [Provider Name], [Through], [Type of Record], [Value Code]
INTO MedProvTaskPivot
FROM
(
	SELECT tl.casesid as CasesID, td.tablistid, case when convert(varchar(50),td.[namesid]) IS NULL then td.[data] else convert(varchar(50),td.[namesid]) end as [data], ucf.field_title
	FROM [NeedlesNeosBisnarChase]..user_tab2_data td
	JOIN [NeedlesNeosBisnarChase]..user_tab2_list tl on tl.id = td.tablistid
	JOIN [NeedlesNeosBisnarChase]..user_case_fields ucf on ucf.id = td.usercasefieldid
	WHERE field_Title in ('Account Number', 'Comments', 'Date Received', 'Date Requested', 'For Dates From', 'Make Check Payable To', 'Medical Record#', 'Method', 
					'No Records','Ordered By', 'Pre-Payment Required', 'Provider Name', 'Through', 'Type of Record', 'Value Code' )
) d
pivot
(
  max([data])
  for field_title in ([Account Number], [Comments], [Date Received], [Date Requested], [For Dates From], [Make Check Payable To], [Medical Record#], [Method], [No Records], 
					[Ordered By], [Pre-Payment Required], [Provider Name], [Through], [Type of Record], [Value Code])
) piv;


------------------------------------
--ADD SAGA BILL ID TO SP DAMAGES
------------------------------------
IF NOT EXISTS (SELECT * FROM sys.columns WHERE Name = N'saga_bill_id' AND Object_ID = Object_ID(N'sma_TRN_SpDamages'))
BEGIN
    ALTER TABLE [sma_TRN_SpDamages] 
	ADD [saga_bill_id] [varchar](50) NULL; 
END
GO
------------------------------------
--ADD SAGA TO VISITS
------------------------------------
IF NOT EXISTS (SELECT * FROM sys.columns WHERE Name = N'saga' AND Object_ID = Object_ID(N'sma_TRN_Visits'))
BEGIN
    ALTER TABLE [sma_TRN_Visits] 
	ADD [saga] [varchar](50) NULL; 
END
GO

------------------------------------
--ADD SAGA TO HOSPITALS TABLE
------------------------------------
IF NOT EXISTS (SELECT * FROM sys.columns WHERE Name = N'saga' AND Object_ID = Object_ID(N'sma_TRN_Hospitals'))
BEGIN
    ALTER TABLE [sma_TRN_Hospitals] 
	ADD [saga] [varchar](50) NULL; 
END

------------------------------------
--ADD SAGA TO MEDICAL REQUESTS TABLE
------------------------------------
IF NOT EXISTS (SELECT * FROM sys.columns WHERE Name = N'saga' AND Object_ID = Object_ID(N'sma_trn_MedicalProviderRequest'))
BEGIN
    ALTER TABLE [sma_trn_MedicalProviderRequest] 
	ADD [saga] [varchar](50) NULL; 
END

--select distinct type_of_Record FROM NeedlesNeosBisnarChase..user_tab2_data where isnull(Type_of_Record,'') <> ''
------------------------------------
--RECORD REQUEST TYPES
------------------------------------
INSERT INTO sma_MST_Request_RecordTypes ( RecordType )
( SELECT DISTINCT [Type of Record] from MedProvTaskPivot D
	WHERE d.[Type of Record] in ('Medical Bill', 'Medical Record', 'Medical Record and Bill', 'Hospital Bill', 
					'Hospital Record', 'Ambulance Record/Bill', 'Record and Bill', 'Radiology/Films', 'Pharmacy Record') 
)
EXCEPT SELECT RecordType FROM sma_MST_Request_RecordTypes

------------------------------------
--REQUEST STATUS
------------------------------------
INSERT INTO sma_MST_RequestStatus ( Status, Description )
SELECT 'No Record Available','No Record Available'
EXCEPT
SELECT Status,Description FROM sma_MST_RequestStatus
GO


------------------------------------
--MEDICAL PROVIDER HELPER
------------------------------------
IF EXISTS (select * from sys.objects where name='user_tab2_MedicalProvider_Helper' and type='U')
BEGIN
	drop table user_tab2_MedicalProvider_Helper
END 
GO

---(0)---
CREATE TABLE user_tab2_MedicalProvider_Helper (
    TableIndex [int] IDENTITY(1,1) NOT NULL,
	case_id				varchar(50),
	tab_id				varchar(50),
	ProviderNameId		varchar(50),
	ProviderName		varchar(200),
	ProviderCID			int,
	ProviderCTG			int,
	ProviderAID			int,
	--CounselOrderingCID		int,
	--CounselOrderingCTG		int,
	--CounselOrderingAID		int,
	casnCaseID			int,
CONSTRAINT IOC_Clustered_Index_user_tab2_MedicalProvider_Helper PRIMARY KEY CLUSTERED ( TableIndex )
) ON [PRIMARY] 
GO

CREATE NONCLUSTERED INDEX IX_NonClustered_Index_user_tab2_MedicalProvider_Helper_case_id ON [user_tab2_MedicalProvider_Helper] (case_id);   
CREATE NONCLUSTERED INDEX IX_NonClustered_Index_user_tab2_MedicalProvider_Helper_tab_id ON [user_tab2_MedicalProvider_Helper] (tab_id);   
CREATE NONCLUSTERED INDEX IX_NonClustered_Index_user_tab2_MedicalProvider_Helper_ProviderNameId ON [user_tab2_MedicalProvider_Helper] (ProviderNameId);   
GO

---(0)---
INSERT INTO user_tab2_MedicalProvider_Helper ( case_id,tab_id,ProviderNameId,ProviderName,ProviderCID,ProviderCTG,ProviderAID,casnCaseID )
SELECT
    n.CasesID			   as case_id,		
    n.tablistid			   as tab_id,		--NEEDLES RECORDS TAB ITEM
    n.[Provider Name]	   as ProviderNameId,  
    IOC.[Name]			   as ProviderName,
    IOC.CID				   as ProviderCID,  
    IOC.CTG				   as ProviderCTG,
    IOC.AID				   as ProviderAID,
    CAS.casnCaseID		   as casnCaseID  
FROM MedProvTaskPivot n
JOIN [IndvOrgContacts_Indexed] IOC on IOC.SAGA= convert(varchar(50),N.[Provider Name])
JOIN [sma_TRN_Cases] CAS on CAS.Needles_saga = n.casesid
WHERE n.[Type of Record] in  ('Medical Bill', 'Medical Record', 'Medical Record and Bill', 'Hospital Bill', 
					'Hospital Record', 'Ambulance Record/Bill', 'Record and Bill', 'Radiology/Films', 'Pharmacy Record') 
GO


---(0)---
DBCC DBREINDEX('user_tab2_MedicalProvider_Helper',' ',90)  WITH NO_INFOMSGS 
GO

---
ALTER TABLE [sma_TRN_Hospitals] DISABLE TRIGGER ALL
GO
ALTER TABLE [sma_trn_MedicalProviderRequest] DISABLE TRIGGER ALL
GO
--alter table [sma_TRN_SpDamages] disable trigger all
--GO
--alter table [sma_TRN_Visits] disable trigger all
--GO

--------------------------------------------------------------------------
---------------------------- MEDICAL PROVIDERS ---------------------------
--------------------------------------------------------------------------
INSERT INTO [sma_TRN_Hospitals]
 (	[hosnCaseID], 
	[hosnContactID], 
	[hosnContactCtg],
	[hosnAddressID], 
	[hossMedProType], 
	[hosdStartDt],
	[hosdEndDt],
	[hosnPlaintiffID],
	[hosnComments], 
	[hosnHospitalChart], 
	[hosnRecUserID],
	[hosdDtCreated], 
	[hosnModifyUserID],
	[hosdDtModified],
	[saga]
)
SELECT DISTINCT
    casnCaseID				as [hosnCaseID], 
    ProviderCID				as [hosnContactID],
    ProviderCTG				as [hosnContactCtg],
    ProviderAID				as [hosnAddressID], 
     'M' 					as [hossMedProType],			--M or P (P for Prior Medical Provider)
    NULL 					as [hosdStartDt],
    NULL 					as [hosdEndDt],
    ( select plnnPlaintiffID FROM [sma_TRN_Plaintiff] WHERE plnnCaseID = casnCaseID and plnbIsPrimary=1) 
							as hosnPlaintiffID,
	''						as [hosnComments],
	null					as [hosnHospitalChart],
    368						as [hosnRecUserID],
    getdate()				as [hosdDtCreated],
    null					as [hosnModifyUserID],
    null					as [hosdDtModified],
    'tab2'					as [saga]
	--'tab2:'+convert(varchar,UD.tab_id)	as [saga]
FROM MedProvTaskPivot d
JOIN user_tab2_MedicalProvider_Helper MAP on MAP.case_id = convert(varchar(50),D.casesid) and MAP.tab_id= convert(varchar(50),D.tablistid)
LEFT JOIN [sma_TRN_Hospitals] H on H.hosnCaseID=MAP.casnCaseID and H.hosnContactID=MAP.ProviderCID and H.hosnContactCtg=MAP.ProviderCTG and H.hosnAddressID=MAP.ProviderAID 
WHERE H.hosnHospitalID is null	--only add the hospital if it does not already exist


--------------------------------------------------------------------------
---------------------------- MEDICAL REQUESTS ----------------------------
--------------------------------------------------------------------------

INSERT INTO [sma_trn_MedicalProviderRequest]
(
    MedPrvCaseID,
    MedPrvPlaintiffID,
    MedPrvhosnHospitalID,
    MedPrvRecordType,
    MedPrvRequestdate,
    MedPrvAssignee,
    MedPrvAssignedBy,
	MedPrvHighPriority,
    MedPrvFromDate,
    MedPrvToDate,
    MedPrvComments,
	MedPrvNotes,
    MedPrvCompleteDate,
    MedPrvStatusId,
    MedPrvFollowUpDate,
	MedPrvStatusDate,
	OrderAffidavit,
	FollowUpNotes,		--Retrieval Provider Notes
	SAGA
)
SELECT 
    hosnCaseID					 as MedPrvCaseID,
    hosnPlaintiffID				 as MedPrvPlaintiffID,
    H.hosnHospitalID			 as MedPrvhosnHospitalID,
    (select uId from sma_MST_Request_RecordTypes where RecordType=UD.[Type of Record]) 	   							 as MedPrvRecordType,
    case when ( UD.[Date Requested] between '1900-01-01' and '2079-06-06') then UD.[Date Requested]  else null end	 as MedPrvRequestdate,
    null						 as MedPrvAssignee,
    (select usrnUserID From sma_mst_users u join sma_MST_IndvContacts i on u.usrnContactID = i.cinnContactID where i.cinsGrade = ud.[Ordered By])			 as MedPrvAssignedBy,
    0							 as MedPrvHighPriority,		--1=high priority; 0=Normal
    case when ud.[For Dates From] between '1900-01-01' and '2079-06-06' then ud.[For Dates From] else NULL end		 as MedPrvFromDate,
    case when ud.[Through] between '1900-01-01' and '2079-06-06' then ud.[Through] else NULL end					 as MedPrvToDate,
    isnull('PrePayment Required: ' + NULLIF(convert(varchar,UD.[pre-payment required]),'') + CHAR(13),'') + 
	isnull('Method: ' + NULLIF(convert(varchar,UD.Method),'') + CHAR(13),'') + 
	isnull('Value Code: ' + NULLIF(convert(varchar,UD.[value code]),'') + CHAR(13),'') + 
	isnull('No Records: ' + NULLIF(convert(varchar,UD.[no records]),'') + CHAR(13),'') +
	isnull('Account Number: ' + NULLIF(convert(varchar,UD.[Account number]),'') + CHAR(13),'') +
	isnull('Make Check Payable To: ' + NULLIF(convert(varchar,ioc.[name]),'') + CHAR(13),'') +
	''																											as MedPrvComments,
	isnull('Comments: ' + NULLIF(convert(varchar(max),UD.Comments),'') + CHAR(13),'') +  
	''																											as MedPrvNotes,
    case when ( UD.[Date Received] between '1900-01-01' and '2079-06-06') then UD.[Date Received] else null end		as MedPrvCompleteDate,
    case when (UD.[Date Received] between '1900-01-01' and '2079-06-06') then (select uId from [sma_MST_RequestStatus] where [status]='Received')
	   else null end							as MedPrvStatusId,
    NULL										as MedPrvFollowUpDate,
	case when (UD.[Date Received] between '1900-01-01' and '2079-06-06') 
				then (select uId from [sma_MST_RequestStatus] where [status]='Received')						 
	   else null end			as MedPrvStatusDate,
	NULL						as OrderAffidavit,	--bit
	''												as FollowUpNotes,	--Retreival Provider Notes
	'tab2: '+convert(varchar(50),UD.tablistid)			as SAGA
--select *
FROM MedProvTaskPivot UD
JOIN user_tab2_MedicalProvider_Helper MAP on MAP.case_id= convert(varchar(50),UD.caseSid) and MAP.tab_id = convert(varchar(50),UD.tablistid)
LEFT JOIN IndvOrgContacts_Indexed ioc on ioc.saga = convert(varchar(50),ud.[Make Check Payable To])
JOIN [sma_TRN_Hospitals] H on H.hosnContactID=MAP.ProviderCID and H.hosnContactCtg=MAP.ProviderCTG and H.hosnCaseID=MAP.casnCaseID
GO



/*
--------------------------------------------------------------------------
------------------------------ MEDICAL VISITS -----------------------------
--------------------------------------------------------------------------
insert into  [SA].[dbo].[sma_TRN_Visits]
(
       [vissRefTable]
      ,[visnRecordID]
      ,[visdAdmissionDt]
      ,[visnAdmissionTypeID]
      ,[visdDischargeDt]
      ,[vissAccountNo]
	  ,[vissComplaint]
	  ,[vissDiagnosis]
      ,[visnRecUserID]
      ,[visdDtCreated]
      ,[visnModifyUserID]
      ,[visdDtModified]
	  ,[vissTreatmentPlan]
	  ,[vissComments]
)
select 
    'Hospitals'			  as [vissRefTable],
    H.hosnHospitalID	   as [visnRecordID],
    NULL				   as [visdAdmissionDt],
    (select amtnAdmsnTypeID from sma_MST_AdmissionType where amtsDscrptn='Office Visit')  as [visnAdmissionTypeID],
    NULL				   as [visdDischargeDt],
    NULL				   as [vissAccountNo],
    NULL				   as [vissComplaint],
    d.Findings			   as [vissDiagnosis],
    368					   as [visnRecUserID],
    getdate()			   as [visdDtCreated],
    NULL				   as [visnModifyUserID],
    NULL				   as [visdDtModified],
    D.Treatment_Received		   as [vissTreatmentPlan],
    null				   as [vissComments]
from [NeedlesNeosBisnarChase].[dbo].[user_tab2_data] D
inner join user_tab2_MedicalProvider_Helper MAP on MAP.tab_ID=D.tab_id
inner join [SA].[dbo].[sma_TRN_Hospitals] H on H.hosnCaseID=MAP.casnCaseID and H.hosnContactID=MAP.ProviderCID and H.hosnContactCtg=MAP.ProviderCTG and H.hosnAddressID=MAP.ProviderAID 
WHERE isnull(Treatment_Received,'')<> '' or
isnull(findings,'')<>''

--------------------------------------------------------------------------
------------------------------ MEDICAL BILLS -----------------------------
--------------------------------------------------------------------------
insert into [SA].[dbo].[sma_TRN_SpDamages]
(
     [spdsRefTable]
    ,[spdnRecordID]
    ,[spdnBillAmt]
    ,[spdsAccntNo]
    ,[spddNegotiatedBillAmt]
    ,[spddDateFrom]
    ,[spddDateTo]
    ,[spddDamageSubType]
    ,[spdnVisitId]
    ,[spdsComments]
    ,[spdnRecUserID]
    ,[spddDtCreated]
    ,[spdnModifyUserID]
    ,[spddDtModified]
    ,[spdnBalance]
    ,[spdbLienConfirmed]
    ,[spdbDocAttached]
    ,[saga_bill_id]
)
select 
    'Hospitals'			   as spdsRefTable,
    H.hosnHospitalID	   as spdnRecordID,
    convert(numeric(18, 2), D.Total_Bill_Amount)	as spdnBillAmt,
    NULL				   as spdsAccntNo,
    null				   as spddNegotiatedBillAmt,
    null				   as spddDateFrom,
    null				   as spddDateTo,
    null				   as spddDamageSubType,
    null				   as spdnVisitId, 
    isnull('SSA RFCs: ' + NULLIF(D.SSA_RFCs,'') + CHAR(13),'') + 
	isnull('Reason for 1''s: ' + NULLIF(convert(varchar,D.Reason_for_1s),'') + CHAR(13),'') + 
	isnull('Phone #: ' + NULLIF(convert(varchar,D.Phone_#),'') + CHAR(13),'') + 
	isnull('Final Outstanding Balance:' + NULLIF(convert(varchar,D.Final_Outstanding_Balance),'') + CHAR(13),'') + 
	isnull('Final Balance Confirmed:' + NULLIF(convert(varchar,D.Final_Balance_Confirmed),'') + CHAR(13),'') + 
	isnull('HITECH AUTH SENT:' + NULLIF(convert(varchar,D.HITECH_AUTH_SENT),'') + CHAR(13),'') + 
	isnull('HITECH VIOLATION:' + NULLIF(convert(varchar,D.HITECH_VIOLATION),'') + CHAR(13),'') + 
	isnull('HITECH VIOLATION LTR SENT:' + NULLIF(convert(varchar,D.HITECH_VIOLATION_LTR_SENT),'') + CHAR(13),'') + 
	isnull('HITECH VIOLATION F/U:' + NULLIF(convert(varchar,D.HITECH_VIOLATION_FU),'') + CHAR(13),'') + 
	isnull('HITECH Comments:' + NULLIF(D.HITECH_Comments,'') + CHAR(13),'') + 
	isnull('Req Confirmed with Prov.:' + NULLIF(convert(varchar,D.Req_Confirmed_with_Prov),'') + CHAR(13),'') + 
	''						as spdsComments,
    368						as spdnRecordID,
    getdate()				as spddDtCreated,
    null					as spdnModifyUserID,
    null				    as spddDtModified,
    null				    as spdnBalance,
    0						as spdbLienConfirmed,
    0						as spdbDocAttached,
    'tab2:' + convert(varchar,D.tab_id)	
							as saga_bill_id  -- one bill one value
from [NeedlesNeosBisnarChase].[dbo].[user_tab2_data] D
inner join user_tab2_MedicalProvider_Helper MAP on MAP.tab_id=D.tab_id
inner join [SA].[dbo].[sma_TRN_Hospitals] H on H.hosnCaseID=MAP.casnCaseID and H.hosnContactID=MAP.ProviderCID and H.hosnContactCtg=MAP.ProviderCTG and H.hosnAddressID=MAP.ProviderAID 


---(Appendix)--- Update hospital TotalBill from Bill section
UPDATE [sma_TRN_Hospitals]
SET hosnTotalBill = (SELECT SUM(spdnBillAmt) FROM sma_TRN_SpDamages WHERE sma_TRN_SpDamages.spdsRefTable='Hospitals' AND sma_TRN_SpDamages.spdnRecordID = hosnHospitalID)

UPDATE [sma_TRN_Hospitals]
SET hosnTotalMedicalVisits = (SELECT count(*) FROM sma_TRN_Visits WHERE sma_TRN_Visits.vissRefTable='Hospitals' AND sma_TRN_Visits.visnRecordID = hosnHospitalID)

*/


---
ALTER TABLE [sma_trn_MedicalProviderRequest] ENABLE TRIGGER ALL
GO
ALTER TABLE [sma_TRN_Hospitals] ENABLE TRIGGER ALL
GO
--alter table [sma_TRN_SpDamages] enable trigger all
--GO
--alter table [sma_TRN_Visits] enable trigger all
--GO



