USE  [SAbilleasterlyLaw]
GO

alter table sma_trn_Casevalue disable trigger all
delete from sma_trn_Casevalue
DBCC CHECKIDENT ('sma_trn_Casevalue', RESEED, 0);
alter table sma_trn_Casevalue enable trigger all

INSERT INTO sma_trn_Casevalue (csvncaseid, csvnValueID, csvnValue, csvsComments, csvdFromDate, csvdToDate, 
			csvnRecUserID, csvdDtCreated, csvnMinSettlementValue, csvnExpectedResolutionDate, csvnMaxSettlementValue)
SELECT DISTINCT
	cas.casncaseid			as csvncaseid,
	NULL					as csvnValueID,
	NULL					as csvnValue,
	----isnull('Value Notes: ' + nullif(convert(varchar(max),ud.value_notes),'') + CHAR(13),'') +
	----isnull('Case Grade Value: ' + nullif(convert(varchar(max),ud.Case_Grade_Value),'') + CHAR(13),'') +
	''						as csvsComments, 
	getdate()				as csvdFromDate,
	null					as csvdToDate,
	368						as csvnRecUserID,
	getdate()				as csvdDtCreated,
	minimum_amount			as csvnMinSettlementValue,
	null					as csvnExpectedResolutionDate,
	maximum_amount		as csvnMaxSettlementValue
--select *
FROM [NeosBillEasterly]..insurance ii
JOIN sma_trn_Cases cas on cas.Neos_Saga = convert(varchar(50),ii.casesid)
-----LEFT JOIN [NeosBillEasterly]..user_tab7_data ud on convert(varchar,ud.casesid) = cas.cassCaseNumber
WHERE isnull(minimum_amount,0) <> 0
or isnull( maximum_amount, 0 )<> 0