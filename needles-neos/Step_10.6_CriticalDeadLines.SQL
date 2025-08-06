
use   [SAbilleasterlyLaw]
go
 
alter table [sma_TRN_CriticalDeadlines] disable trigger all
delete [sma_TRN_CriticalDeadlines]
DBCC CHECKIDENT ('[sma_TRN_CriticalDeadlines]', RESEED, 0);
alter table [sma_TRN_CriticalDeadlines] enable trigger all

------(select cdtnCriticalTypeID FROM [sma_MST_CriticalDeadlineTypes] where cdtbActive = 1 and cdtsDscrptn='date due') 
 
-----
ALTER TABLE [sma_TRN_CriticalDeadlines] DISABLE TRIGGER ALL
-----

----(0)----- 
INSERT INTO [sma_MST_CriticalDeadlineTypes] ( cdtsDscrptn, cdtbActive ) 
SELECT DISTINCT [label], 1
FROM [NeosBillEasterly] ..[date_labels]
EXCEPT
SELECT cdtsDscrptn,cdtbActive from [sma_MST_CriticalDeadlineTypes]
WHERE cdtbActive=1


----(1)-----
INSERT INTO [sma_TRN_CriticalDeadlines]
(   [crdnCaseID],[crdnCriticalDeadlineTypeID],[crddDueDate],[crdsRequestFrom],[ResponderUID] )
SELECT 
	CAS.casnCaseID			as [crdnCaseID],
	(select cdtnCriticalTypeID FROM [sma_MST_CriticalDeadlineTypes] where cdtbActive = 1 and cdtsDscrptn=dl.[label])  
							as [crdnCriticalDeadlineTypeID],
	case when C.casedate between '1900-01-01' and '2079-06-01' then C.casedate
	   else null end	    as [crddDueDate],
	convert(varchar,aci.UniqueContactId) + ';' 		as [crdsRequestFrom],
	convert(varchar,aci.UniqueContactId)			as [ResponderUID]
FROM  [NeosBillEasterly]..[case_dates] C 
JOIN  [NeosBillEasterly]..date_labels dl on c.datelabelid = dl.id
JOIN [sma_TRN_cases] CAS on CAS.Neos_Saga= convert(varchar(50), c.casesid)
LEFT JOIN sma_TRN_Plaintiff p on p.plnnCaseID = cas.casncaseid 
JOIN sma_MST_AllContactInfo aci on ContactCtg=plnnContactCtg and ContactId=plnnContactID  
WHERE isnull(c.casedate,'') <>''


-----
ALTER TABLE [sma_TRN_CriticalDeadlines] ENABLE TRIGGER ALL
GO
-----


---(Appendix)---
ALTER TABLE sma_TRN_CriticalDeadlines DISABLE TRIGGER ALL
GO

UPDATE [sma_TRN_CriticalDeadlines] 
SET crddCompliedDate=getdate()
WHERE crddDueDate < getdate()
GO

ALTER TABLE sma_TRN_CriticalDeadlines ENABLE TRIGGER ALL
GO