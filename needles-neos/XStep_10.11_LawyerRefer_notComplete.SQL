USE [SAbilleasterlyLaw]
GO


/*
select  td.casesid, ucf.field_title, ucf.field_type, ucf.field_len, td.[data] as FieldData, td.namesid
--select distinct td.[data]
from [NeosBrianWhite]..user_tab7_data td
JOIN [NeosBrianWhite]..user_case_fields ucf on ucf.id = td.usercasefieldid
WHERE ucf.field_title IN ('Referral Source Code','Internal Referral Source','Referral Decision','Referring Attorney')
order by ucf.field_title
*/

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
	FROM  [NeosBillEasterly]..user_tab7_data td
	JOIN [NeosBillEasterly]..user_case_fields ucf on ucf.id = td.usercasefieldid
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
INSERT INTO sma_TRN_LawyerReferral (
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
			lwrdDtModified )
SELECT
			cas.casnCaseID				as lwrnCaseID, 
			case when ioc.ctg = 2 then ioc.cid else NULL end	as lwrnRefLawFrmContactID, 
			case when ioc.ctg = 2 then ioc.aid else NULL end	as lwrnRefLawFrmAddressId, 
			case when ioc.ctg = 1 then ioc.cid else NULL end	as lwrnAttContactID, 
			case when ioc.ctg = 1 then ioc.aid else NULL end	as lwrnAttAddressID, 
			-1							as lwrnPlaintiffID, 
			NULL						as lwrdRetainerSentDt, 
			NULL						as lwrdRetainerRcvdDt, 
			NULL						as lwrdRetainerDt, 
			isnull('Fee Agreement: ' + nullif(convert(varchar(max),rp.[Fee Agreement]),'') + CHAR(13),'') + 
			isnull('Fee Terms: ' + nullif(convert(varchar(max),rp.[Fee Terms]),'') + CHAR(13),'') + 
			''							as lwrsComments, 
			368							as lwrnUserID, 
			getdate()					as lwrdDtCreated, 
			NULL						as lwrnModifyUserID, 
			NULL						as lwrdDtModified
FROM ReferralPivot rp
JOIN sma_trn_Cases cas on cas.Neos_Saga = convert(varchar(50),rp.casesid)
JOIN IndvOrgContacts_Indexed ioc on ioc.saga_ref = convert(varchar(50),rp.[Referring Attorney])
WHERE isnull([Referring Attorney],'') <> ''