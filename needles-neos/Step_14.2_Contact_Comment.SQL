
USE   [SAbilleasterlyLaw]
GO

---
ALTER TABLE sma_MST_IndvContacts DISABLE TRIGGER ALL
GO
---

----(1)----
UPDATE sma_MST_IndvContacts SET cinsComments = isnull(cinsComments,'') + CHAR(13) + 'Age : ' + convert(varchar,A.Age)
FROM
(
SELECT 
    P.casesid											   as CaseID, 
    P.namesid											   as PartyID,
    DATEPART(yyyy,getdate()) - DATEPART(yyyy,N.date_of_birth) - 1   as Age

FROM [NeosBillEasterly].[dbo].[party_Indexed] P 
JOIN [NeosBillEasterly].[dbo].[names] N on N.id =P.namesid
WHERE N.date_of_birth is not null
) A
WHERE convert(varchar(50), A.PartyID) = saga_ref 


----(2)----
UPDATE sma_MST_IndvContacts SET cinsComments = isnull(cinsComments,'') + CHAR(13) + 'Age at DOI : ' + convert(varchar,A.DOI)
FROM
(
SELECT 
    P.casesid											   as CaseID, 
    P.namesid											   as PartyID,
    DATEPART(yyyy,C.date_of_incident) - DATEPART(yyyy,N.date_of_birth) - 1   as DOI
FROM [NeosBillEasterly].[dbo].[party_Indexed] P 
JOIN [NeosBillEasterly].[dbo].[names] N on N.id =P.namesid
JOIN [NeosBillEasterly].[dbo].[cases] C on C.id=P.casesid
WHERE C.date_of_incident is not null 
and N.date_of_birth is not null
) A
WHERE convert(varchar(50), A.PartyID)=saga_ref 


----(3)----
UPDATE sma_MST_IndvContacts SET cinsComments = isnull(cinsComments,'') + CHAR(13) + 'Deceased : ' + convert(varchar,A.Deceased)
FROM
(
SELECT 
    P.casesid											   as CaseID, 
    P.namesid											   as PartyID,
    N.Deceased											   as Deceased
FROM [NeosBillEasterly].[dbo].[party_Indexed] P 
JOIN [NeosBillEasterly].[dbo].[names] N on N.id=P.namesid
WHERE N.Deceased is not null
) A
WHERE convert(varchar(50), A.PartyID)=saga_ref 


----(4)----
UPDATE sma_MST_IndvContacts SET cinsComments = isnull(cinsComments,'') + CHAR(13) + 'Date of Death : ' + convert(varchar,A.DOD)
FROM
(
SELECT 
    P.casesid											   as CaseID, 
    P.namesid											   as PartyID,
    DATEPART(yyyy,N.date_of_death)							   as DOD
FROM [NeosBillEasterly].[dbo].[party_Indexed] P 
JOIN [NeosBillEasterly].[dbo].[names] N on N.id=P.namesid
WHERE N.date_of_death is not null
) A
WHERE convert(varchar(50), A.PartyID) = saga_ref 



----(5)----
UPDATE sma_MST_IndvContacts SET cinsComments = isnull(cinsComments,'') + CHAR(13) + 'Incapacitated : ' + convert(varchar,A.incapacitated)
FROM
(
SELECT 
    P.casesid											   as CaseID, 
    P.namesid											   as PartyID,
    P.incapacitated										   as incapacitated
FROM [NeosBillEasterly].[dbo].[party_Indexed] P 
JOIN [NeosBillEasterly].[dbo].[names] N on N.id=P.namesid
WHERE isnull(incapacitated,'')<>''
) A
WHERE convert(varchar(50), A.PartyID) = saga_ref 


----(5)----
UPDATE sma_MST_IndvContacts SET cinsComments = isnull(cinsComments,'') + CHAR(13) + 'Incapacity : ' + convert(varchar,A.Incapacity)
FROM
(
SELECT 
    P.casesid											   as CaseID, 
    P.namesid											   as PartyID,
    P.incapacity										   as Incapacity
FROM [NeosBillEasterly].[dbo].[party_Indexed] P 
JOIN [NeosBillEasterly].[dbo].[names] N on N.id=P.namesid
WHERE isnull(incapacity,'')<>''
) A
WHERE convert(varchar(50), A.PartyID) = saga_ref 



----(6)----
UPDATE sma_MST_IndvContacts SET cinsComments = isnull(cinsComments,'') + CHAR(13) + 'Responsible for another party : ' + convert(varchar,A.Responsibility)
FROM
(
SELECT 
    P.casesid											   as CaseID, 
    P.namesid											   as PartyID,
    P.responsibility									   as Responsibility
FROM [NeosBillEasterly].[dbo].[party_Indexed] P 
JOIN [NeosBillEasterly].[dbo].[names] N on N.id=P.namesid
WHERE isnull(P.responsibility,'')<>''
) A
WHERE convert(varchar(50), A.PartyID) =saga_ref 


---
ALTER TABLE sma_MST_IndvContacts ENABLE TRIGGER ALL
GO
---
