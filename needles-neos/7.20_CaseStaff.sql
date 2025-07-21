
USE  [SAbilleasterlyLaw]
GO
 
alter table [sma_TRN_caseStaff] disable trigger all
delete [sma_TRN_caseStaff]
DBCC CHECKIDENT ('[sma_TRN_caseStaff]', RESEED, 0);
alter table [sma_TRN_caseStaff] enable trigger all

---- select * from sma_TRN_caseStaff
 


----(0) staff roles ----
 WITH RolesToInsert AS (
    SELECT * FROM (
        VALUES
            (1,  'Staff 2', 10),
            (2,  'Staff 3', 10),
            (3,  'Staff 4', 10),
            (4,  'Staff 5', 10),
            (5,  'Staff 6', 10),
            (6,  'Staff 7', 10),
            (7,  'Staff 8', 10),
            (8,  'Staff 9', 10),                              
            (9,  'Staff 10', 10),
            (10, 'Modified Staff', 10),
            (11, 'Created Staff', 10),
            (12, 'Intake Staff', 10),
			(13, 'Intake', 10),
            (14, 'Subro', 10),
            (15, 'Demand', 10),
            (16, 'Medical Records', 10),
            (17, 'Bookkeeper', 10),
            (18, 'Paralegal', 10),
            (19, 'Case Manager I', 10),
            (20, 'Case Manager II', 10),
			(21, 'Attorney', 10),
            (22, 'Primary Attorney', 10) 
             
    ) AS Roles(seq, srcsDscrptn, srcnRoleID)
)
INSERT INTO [sma_MST_SubRoleCode] (srcsDscrptn, srcnRoleID)
SELECT R.srcsDscrptn, R.srcnRoleID
FROM RolesToInsert R
LEFT JOIN [sma_MST_SubRoleCode] T
    ON R.srcsDscrptn = T.srcsDscrptn AND R.srcnRoleID = T.srcnRoleID
WHERE T.srcsDscrptn IS NULL
ORDER BY R.seq;

----- Client added
INSERT INTO [sma_MST_SubRoleCode] (srcsDscrptn, srcnRoleID)
values ( 'Case Manager', 10)

INSERT INTO [sma_MST_SubRoleCode] (srcsDscrptn, srcnRoleID)
values ( 'Intake Paralegal', 10)
 
 


----(1)-----
---
ALTER TABLE [sma_TRN_caseStaff] DISABLE TRIGGER ALL
GO
---

IF OBJECT_ID('Ranked_helper', 'U') IS NOT NULL
DROP TABLE Ranked_helper;

 WITH RankedRaw AS (
    SELECT     
        CAS.casnCaseID AS cssnCaseID,
        cas.casnOrgCaseTypeID,
        U.usrnContactID AS cssnStaffID,
        SRL.sbrnSubRoleId AS cssnRoleID,
        SRL.sbrnRoleID,
        ROW_NUMBER() OVER (
            PARTITION BY CAS.casnCaseID, U.usrnContactID
            ORDER BY SRL.sbrnSubRoleId  -- Or any logic that chooses the “first” role
        ) AS rn
    FROM [NeosBillEasterly]..case_staff cs
    JOIN [NeosBillEasterly]..matter_staff ms ON ms.id = cs.matterstaffid
    JOIN [NeosBillEasterly]..staff_Role sr ON sr.id = ms.staffroleid
    JOIN sma_TRN_cases CAS ON CAS.Neos_Saga = CONVERT(VARCHAR(50), cs.casesid)
    JOIN sma_MST_Users U ON U.saga = CONVERT(VARCHAR(50), cs.staffid)
    JOIN sma_MST_SubRole SRL 
        ON SRL.sbrsDscrptn = 
            CASE 
                WHEN cas.casnOrgCaseTypeID in ('1583','1586','1581','1576','1575','1577','1582','1585','1578','1579') THEN 'Primary Attorney'
                WHEN cas.casnOrgCaseTypeID in ('1588','1587') AND sr.role IN ('ATTORNEY','ASSOCIATE ATTORNEY') THEN 'Primary Attorney'
                WHEN cas.casnOrgCaseTypeID in ('1588','1587') AND sr.role IN ('PARALEGAL','INTAKE','MEDICAL RECORDS','CASE MANAGER I','CASE MANAGER II') THEN 'Case Manager'
                WHEN cas.casnOrgCaseTypeID in ('1588','1587') AND sr.role = 'BOOKKEEPER' THEN 'Primary Paralegal'
                WHEN cas.casnOrgCaseTypeID = '1573' AND sr.role = 'ATTORNEY' THEN 'Primary Attorney'
                WHEN cas.casnOrgCaseTypeID = '1573' AND sr.role = 'ASSOCIATE ATTORNEY' THEN 'Attorney'
                WHEN cas.casnOrgCaseTypeID = '1573' AND sr.role IN ('CASE MANAGER I','CASE MANAGER II') THEN 'Paralegal'
                WHEN cas.casnOrgCaseTypeID = '1573' AND sr.role = 'BOOKKEEPER' THEN 'Primary Paralegal'
                WHEN cas.casnOrgCaseTypeID IN ('1580','1535','1584') AND sr.role IN ('ATTORNEY','ASSOCIATE ATTORNEY') THEN 'Primary Attorney'
                WHEN cas.casnOrgCaseTypeID IN ('1580','1535','1584') AND sr.role IN ('PARALEGAL','BOOKKEEPER','DEMAND') THEN 'Primary Paralegal'
                WHEN cas.casnOrgCaseTypeID IN ('1580','1535','1584') AND sr.role IN ('MEDICAL RECORDS','Case Manager II','SUBRO') THEN 'Case Manager'
                WHEN cas.casnOrgCaseTypeID IN ('1580','1535','1584') AND sr.role IN ('INTAKE','CASE MANAGER I') THEN 'Intake Paralegal'
                ELSE sr.role
            END
    WHERE 
        sr.role NOT IN ('Staff 2','Staff 3','Staff 4','Staff 5','Staff 6','Staff 7','Staff 8','Staff 9','Staff 10')
        AND cas.cassCaseNumber NOT LIKE 'Intake%'
        AND SRL.sbrnRoleID = 10
)

-- Now output only one role per cssnStaffID per case
SELECT 
    cssnCaseID,
    casnOrgCaseTypeID,
    cssnStaffID,
    cssnRoleID,
    sbrnRoleID
INTO Ranked_helper
FROM RankedRaw
WHERE rn = 1;
 
 

INSERT INTO sma_TRN_caseStaff  
(
    cssnCaseID,
    cssnStaffID,
    cssnRoleID,
    csssComments,
    cssdFromDate,
    cssdToDate,
    cssnRecUserID,
    cssdDtCreated,
    cssnModifyUserID,
    cssdDtModified,
    cssnLevelNo
)
SELECT  distinct 
    cssnCaseID,
    cssnStaffID,
    cssnRoleID,
    NULL,             -- csssComments
    NULL,             -- cssdFromDate
    NULL,             -- cssdToDate
    368,              -- cssnRecUserID
    GETDATE(),        -- cssdDtCreated
    NULL,             -- cssnModifyUserID
    NULL,             -- cssdDtModified
    0                 -- cssnLevelNo
FROM Ranked_helper
 
 
 ---- select * from [NeosBillEasterly]..matter_staff 
GO
 
 

-----------------------Attorney   Bill Easterly
update sma_TRN_CaseStaff
set csssComments = 'Top Rated Personal Injury Lawyer'
where cssnStaffID = '13'

select * from sma_TRN_CaseStaff order by cssnCaseID

---
ALTER TABLE [sma_TRN_caseStaff] ENABLE TRIGGER ALL
GO
---


/*UPDATE sma_MST_SubRole
SET sbrnRoleID = 10
WHERE sbrsDscrptn IN ('ATTORNEY');   */
