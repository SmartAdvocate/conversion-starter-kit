 use  [SAbilleasterlyLaw]
 go
 

 
alter table [sma_TRN_Incidents] disable trigger all
delete [sma_TRN_Incidents]
DBCC CHECKIDENT ('[sma_TRN_Incidents]', RESEED, 0);
alter table [sma_TRN_Incidents] enable trigger all
 

---
ALTER TABLE [sma_TRN_Incidents] DISABLE TRIGGER ALL
GO
ALTER TABLE [sma_TRN_Cases] DISABLE TRIGGER ALL
GO
---
WITH StateField AS (
    SELECT td.casesid, td.data, ucf.field_title
    FROM [NeosBillEasterly]..user_case_data td
    JOIN [NeosBillEasterly]..user_case_fields ucf ON ucf.id = td.usercasefieldid
    WHERE ucf.field_title = 'State'
),
TimeOfAccidentField AS (
    SELECT td.casesid, td.data
    FROM [NeosBillEasterly]..user_tab6_data td
    JOIN [NeosBillEasterly]..user_case_fields ucf ON ucf.id = td.usercasefieldid
    WHERE ucf.field_title = 'Time of Accident'
),
StateTab6Field AS (
    SELECT td.casesid, td.data
    FROM [NeosBillEasterly]..user_tab6_data td
    JOIN [NeosBillEasterly]..user_case_fields ucf ON ucf.id = td.usercasefieldid
    WHERE ucf.field_title = 'State'
)

INSERT INTO [sma_TRN_Incidents]
(  
       [CaseId]
      ,[IncidentDate]
      ,[StateID]
      ,[LiabilityCodeId]
      ,[IncidentFacts]
      ,[MergedFacts]
      ,[Comments]
      ,[IncidentTime]
      ,[RecUserID]
      ,[DtCreated]
      ,[ModifyUserID]
      ,[DtModified]
)
SELECT DISTINCT 
    CAS.casnCaseID AS CaseId,
    CASE 
        WHEN (C.date_of_incident BETWEEN '1900-01-01' AND '2079-06-06') 
            THEN CONVERT(DATE, C.date_of_incident) 
        ELSE NULL 
    END AS IncidentDate,

    COALESCE(
                           (SELECT sttnStateID FROM sma_MST_States WHERE sttsDescription = sf.data),
                           (SELECT sttnStateID FROM sma_MST_States WHERE sttsCode = st6.data),
                           (SELECT sttnStateID FROM sma_MST_States WHERE sttsCode = 'TN')
                        ) AS StateID,

    0 AS LiabilityCodeId,
    C.synopsis AS IncidentFacts,
    '' AS MergedFacts,
    '' AS Comments,
    ta.data AS IncidentTime,
    368 AS RecUserID,
    c.intake_date AS DtCreated,
    NULL AS ModifyUserID,
    GETDATE() AS DtModified

FROM [NeosBillEasterly].[dbo].[cases] C
LEFT JOIN StateField sf ON sf.casesid = C.id
LEFT JOIN TimeOfAccidentField ta ON ta.casesid = C.id
LEFT JOIN StateTab6Field st6 ON st6.casesid = C.id
JOIN sma_TRN_cases CAS ON CAS.neos_saga = CONVERT(VARCHAR(50), C.id);


UPDATE CAS
SET CAS.casdIncidentDate=INC.IncidentDate,
    CAS.casnStateID=INC.StateID,
    CAS.casnState=INC.StateID
FROM sma_trn_cases as CAS
LEFT JOIN sma_TRN_Incidents as INC on casnCaseID=caseid
WHERE INC.CaseId=CAS.casncaseid 

---
ALTER TABLE [sma_TRN_Incidents] ENABLE TRIGGER ALL
GO
ALTER TABLE [sma_TRN_Cases] ENABLE TRIGGER ALL
GO

 