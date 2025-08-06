USE   [SAbilleasterlyLaw]
GO


/*
select [Employer's Name], * from [dbo].[NeosUserParty] where isnull([Employer's Name], '')<>''
 
*/

IF NOT EXISTS (SELECT * From sys.columns WHERE Name = N'saga' AND Object_ID = Object_ID(N'sma_TRN_Employment') )
BEGIN
	ALTER TABLE [sma_TRN_Employment]
	ADD saga varchar(50)
END
GO

--------------------
alter table [sma_TRN_Employment]disable trigger all
delete from [sma_TRN_Employment]
DBCC CHECKIDENT ('[sma_TRN_Employment]', RESEED, 0);
alter table [sma_TRN_Employment] enable trigger all




WITH Data_CTE AS (
    SELECT 
        ROW_NUMBER() OVER (PARTITION BY cas.casnCaseID, ud.[Employer's Name] ORDER BY pln.plnnPlaintiffID) AS rn,
        pln.plnnPlaintiffID AS empnPlaintiffID,
        ioc.AID AS empnEmprAddressID,
        ioc.CID AS empnEmployerID,
        NULL AS empncontactPersonID,
        NULL AS empnCPAddressID,
        NULL AS empnEmpUnion,
        NULL AS empnStatusId,
        ud.[Employer's Name] AS empsJobTitle,
        '' AS empsCompensationComments,
        NULL AS empnAverageWeeklyWage,
        NULL AS empnSalaryAmt,
        NULL AS empnSalaryFreqID,
        NULL AS empbOnTheJob,
        NULL AS empbWCClaim,
        ud.[Hire Date] AS empdDateHired,
        NULL AS empdDateTo,
        ISNULL('Injured Person Name : ' + NULLIF(CONVERT(VARCHAR(MAX), ud.[Injured Person's Name ]), '') + CHAR(13), '') + 
        ISNULL(' Working History: ' + NULLIF(CONVERT(VARCHAR(MAX), ud.[Work History]), '') + CHAR(13), '') AS empsComments,
        CONVERT(VARCHAR(50), ud.partyid) AS saga
    FROM [NeosBillEasterly]..NeosUserParty ud
    JOIN [NeosBillEasterly]..Party_Indexed p ON p.id = ud.partyid
    JOIN sma_trn_cases cas ON cas.Neos_saga = CONVERT(VARCHAR(50), p.casesid)
    JOIN sma_trn_plaintiff pln ON pln.plnnCaseID = cas.casnCaseID AND pln.plnbIsPrimary = 1
    JOIN IndvOrgContacts_Indexed ioc ON ioc.Name = ud.[Employer's Name]
    WHERE ISNULL(ud.[Employer's Name], '') <> ''   ------and cas.casnOrgCaseTypeID <> '1588'
)
 INSERT INTO [sma_TRN_Employment] (
    empnPlaintiffID,
    empnEmprAddressID,
    empnEmployerID,
    empncontactPersonID,
    empnCPAddressID,
    empnEmpUnion,
    empnStatusId,
    empsJobTitle,
    empsCompensationComments,
    empnAverageWeeklyWage,
    empnSalaryAmt,
    empnSalaryFreqID,
    empbOnTheJob,
    empbWCClaim,
    empdDateHired,
    empdDateTo,
    empsComments,
    saga
)   
SELECT 
    empnPlaintiffID,
    empnEmprAddressID,
    empnEmployerID,
    empncontactPersonID,
    empnCPAddressID,
    empnEmpUnion,
    empnStatusId,
    empsJobTitle,
    empsCompensationComments,
    empnAverageWeeklyWage,
    empnSalaryAmt,
    empnSalaryFreqID,
    empbOnTheJob,
    empbWCClaim,
    empdDateHired,
    empdDateTo,
    empsComments,
    saga
FROM Data_CTE
WHERE rn = 1; -- Only take 1 row if duplicates


--------------
------WC case need add employeement as Defendant (Client requirement)
--------------
 WITH RankedData AS (
    SELECT 
        pln.plnnPlaintiffID AS empnPlaintiffID,
       addr.addnAddressID  AS empnEmprAddressID,
       def.defnContactID   AS empnEmployerID,
        NULL AS empncontactPersonID,
        NULL AS empnCPAddressID,
        NULL AS empnEmpUnion,
        NULL AS empnStatusId,
        '' AS empsJobTitle,
        '' AS empsCompensationComments,
        NULL AS empnAverageWeeklyWage,
        NULL AS empnSalaryAmt,
        NULL AS empnSalaryFreqID,
        NULL AS empbOnTheJob,
        NULL AS empbWCClaim,
        NULL   AS empdDateHired,
        NULL AS empdDateTo,
        '' AS empsComments,
        CONVERT(VARCHAR(50), pln.saga_party) AS saga,
        ROW_NUMBER() OVER (PARTITION BY cas.casnCaseID ORDER BY pln.plnnPlaintiffID) AS rn
    FROM sma_TRN_Plaintiff pln
    JOIN sma_trn_cases cas ON pln.plnnCaseID = cas.casnCaseId
    JOIN sma_TRN_Defendants def ON def.defnCaseID = cas.casnCaseId
 JOIN  sma_MST_Address addr  ON addr.addnContactID = def.defnContactID
    WHERE def.defnContactCtgID = 2
      AND def.defbIsPrimary = 1
	  and pln.plnbIsPrimary=1
	  and addr.addnContactCtgID =2
      AND cas.casnOrgCaseTypeID = '1588'
)

MERGE INTO sma_TRN_Employment AS TARGET
USING (
    SELECT *
    FROM RankedData
    WHERE rn = 1
) AS SOURCE
ON TARGET.empnPlaintiffID = SOURCE.empnPlaintiffID

WHEN NOT MATCHED THEN
INSERT (
    empnPlaintiffID,
    empnEmprAddressID,
    empnEmployerID,
    empncontactPersonID,
    empnCPAddressID,
    empnEmpUnion,
    empnStatusId,
    empsJobTitle,
    empsCompensationComments,
    empnAverageWeeklyWage,
    empnSalaryAmt,
    empnSalaryFreqID,
    empbOnTheJob,
    empbWCClaim,
    empdDateHired,
    empdDateTo,
    empsComments,
    saga
)
VALUES (
    SOURCE.empnPlaintiffID,
    SOURCE.empnEmprAddressID,
    SOURCE.empnEmployerID,
    SOURCE.empncontactPersonID,
    SOURCE.empnCPAddressID,
    SOURCE.empnEmpUnion,
    SOURCE.empnStatusId,
    SOURCE.empsJobTitle,
    SOURCE.empsCompensationComments,
    SOURCE.empnAverageWeeklyWage,
    SOURCE.empnSalaryAmt,
    SOURCE.empnSalaryFreqID,
    SOURCE.empbOnTheJob,
    SOURCE.empbWCClaim,
    SOURCE.empdDateHired,
    SOURCE.empdDateTo,
    SOURCE.empsComments,
    SOURCE.saga
);


 