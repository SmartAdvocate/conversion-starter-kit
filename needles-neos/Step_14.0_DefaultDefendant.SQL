
USE   [SAbilleasterlyLaw]
GO


---(1)---
  alter table  sma_MST_CaseTypeDefualtDefs disable trigger all
delete from sma_MST_CaseTypeDefualtDefs
DBCC CHECKIDENT ('sma_MST_CaseTypeDefualtDefs', RESEED, 0);
alter table sma_MST_CaseTypeDefualtDefs enable trigger all    

---(2)---
INSERT INTO sma_MST_CaseTypeDefualtDefs
SELECT DISTINCT 
    CST.cstnCaseTypeID		  as cddnCaseTypeID,
    I.cinnContactID			  as cddnDefContatID,
    I.cinnContactCtg		  as cddnDefContactCtgID,
    sbrnSubRoleId			  as cddnRoleID,
    A.addnAddressID			  as cddnDefAddressID
FROM sma_mst_casetype CST
JOIN sma_mst_SubRole S on sbrnCaseTypeID=CST.cstnCaseTypeID 
JOIN sma_mst_SubRoleCode STC on S.sbrnTypeCode=STC.srcnCodeId and STC.srcsDscrptn='(D)-Defendant'
CROSS JOIN sma_MST_IndvContacts I
JOIN sma_MST_Address A on A.addnContactID=I.cinnContactID and A.addnContactCtgID=I.cinnContactCtg and A.addbPrimary=1
WHERE CST.VenderCaseType='NeosBillEasterlyCaseType'
and I.cinsFirstName='Individual'
and I.cinsLastName='Unidentified'




