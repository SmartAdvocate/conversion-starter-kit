use BenAbbot_SA
go

-------------------------------------------------------------------------------
-- [sma_TRN_LawyerReferral] Schema
-------------------------------------------------------------------------------
-- saga
if not exists (select * from sys.columns where Name = N'saga' and object_id = OBJECT_ID(N'sma_TRN_LawyerReferral'))
begin
	alter table [sma_TRN_LawyerReferral] add [saga] INT null;
end

-- source_id
if not exists (select * from sys.columns where Name = N'source_id' and object_id = OBJECT_ID(N'sma_TRN_LawyerReferral'))
begin
	alter table [sma_TRN_LawyerReferral] add [source_id] VARCHAR(MAX) null;
end

go

-- source_db
if not exists (select * from sys.columns where Name = N'source_db' and object_id = OBJECT_ID(N'sma_TRN_LawyerReferral'))
begin
	alter table [sma_TRN_LawyerReferral] add [source_db] VARCHAR(MAX) null;
end

go

-- source_ref
if not exists (select * from sys.columns where Name = N'source_ref' and object_id = OBJECT_ID(N'sma_TRN_LawyerReferral'))
begin
	alter table [sma_TRN_LawyerReferral] add [source_ref] VARCHAR(MAX) null;
end

go



-----------------------------------
--REFERRAL PIVOT TABLE
-----------------------------------
IF EXISTS (SELECT * FROM sys.tables where name = 'ReferralPivot')
BEGIN
	DROP TABLE ReferralPivot
END


SELECT casesid, [Fee Agreement], [Fee Terms], [Referring Attorney]
INTO ReferralPivot
FROM
(
	SELECT td.casesid as CasesID, case when convert(varchar(50),td.[namesid]) IS NULL then td.[data] else convert(varchar(50),td.[namesid]) end as [data], ucf.field_title
	FROM [NeedlesNeosBisnarChase]..user_tab7_data td
	JOIN [NeedlesNeosBisnarChase]..user_case_fields ucf on ucf.id = td.usercasefieldid
	WHERE field_Title in ( 'Fee Agreement', 'Fee Terms', 'Referring Attorney' )
) d
pivot
(
  max([data])
  for field_title in ( [Fee Agreement], [Fee Terms], [Referring Attorney])
) piv;

-----------------------------------
--INSERT INTO LAWYER REFERRAL
-----------------------------------
insert into sma_TRN_LawyerReferral
	(
		lwrnCaseID,
		lwrnRefLawFrmContactID,
		lwrnRefLawFrmAddressId,
		lwrnAttContactID,
		lwrnAttAddressID,
		lwrnPlaintiffID,
		lwrdRetainerSentDt,
		lwrdRetainerRcvdDt,
		lwrdRetainerDt,
		lwrsComments,
		lwrnUserID,
		lwrdDtCreated,
		lwrnModifyUserID,
		lwrdDtModified,
		saga,
		source_id,
		source_db,
		source_ref
	) select
		cas.casnCaseID as lwrnCaseID,
		case
				when ioc.ctg = 2
					then ioc.cid
				else null
		end			   as lwrnRefLawFrmContactID,
		case
				when ioc.ctg = 2
					then ioc.aid
				else null
		end			   as lwrnRefLawFrmAddressId,
		case
				when ioc.ctg = 1
					then ioc.cid
				else null
		end			   as lwrnAttContactID,
		case
				when ioc.ctg = 1
					then ioc.aid
				else null
		end			   as lwrnAttAddressID,
		-1			   as lwrnPlaintiffID,
		null		   as lwrdRetainerSentDt,
		null		   as lwrdRetainerRcvdDt,
		null		   as lwrdRetainerDt,
		ISNULL('Fee Agreement: ' + NULLIF(CONVERT(VARCHAR(MAX), rp.[Fee Agreement]), '') + CHAR(13), '') +
		ISNULL('Fee Terms: ' + NULLIF(CONVERT(VARCHAR(MAX), rp.[Fee Terms]), '') + CHAR(13), '') +
		''			   as lwrsComments,
		368			   as lwrnUserID,
		GETDATE()	   as lwrdDtCreated,
		null		   as lwrnModifyUserID,
		null		   as lwrdDtModified,
		null		   as saga,
		null		   as source_id,
		null		   as source_db,
		null		   as source_ref
	from ReferralPivot rp
	join sma_trn_Cases cas
		on cas.Needles_saga = CONVERT(VARCHAR(50), rp.casesid)
	join IndvOrgContacts_Indexed ioc
		on ioc.saga = CONVERT(VARCHAR(50), rp.[Referring Attorney])
	where
		ISNULL([Referring Attorney], '') <> ''