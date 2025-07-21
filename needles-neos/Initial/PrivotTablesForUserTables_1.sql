 use [NeosBillEasterly]
 go
 --------------------------------
--1. USER CASE PIVOT
--------------------------------   
 IF EXISTS (SELECT * FROM sys.tables WHERE name = 'NeosUserCase')
BEGIN
    DROP TABLE NeosUserCase
END

SELECT 
    casesid, 
    [Defendant Caption],
    [UM],
    [Last Date of Service],
    [Client Done Treating?],
    [Contacted by Def Carrier?],
    [Location],
    [Hire Date],
    [Plt Ins Info],
    [Un-Injured Caller],
    [City],
    [County],
    [State],
    [County of Injury],
    [Def Ins Info],
    [Plaintiff Caption],
    [Health],
    [Time],
    [Employer/Carrier Caption],
    [Reconsideration Case?],
    [Presently in jail?],
    [Work Status],
    [Date Application Filed],
    [Date Injury Reported],
    [Status Upon Intake],
    [As Of],
    [Prompting Reconsideration],
    [Date Application Denied],
    [Court Date/ Court Room],
    [Their Title],
    [Reported to],
    [Approx. Settlement Date],
    [Comp Rate],
    [Doctor Support Claim?],
    [If Other, Please Explain],
    [Date Last Worked],
    [Employee Caption],
    [Local SS Office],
    [Last Doctor Seen],
    [Employer Name],
    [SSI/SSDI],
    [Regarding Comp Rate],
    [What are the charges?],
    [Prior WC Claims?],
    [Date of Last Appointment],
    [Onset Date],
    [COURT CAPTION],
    [Court City],
    [Pay at time of DOI],
    [2nd Class Code]
INTO NeosUserCase
FROM (
    SELECT 
        id.casesid, 
        id.[data]      AS FieldVal, 
       f. field_title
    FROM  
         [NeosBillEasterly]..user_case_data id
    JOIN  
         [NeosBillEasterly]..user_case_fields f 
    ON 
        f.id = id.usercasefieldid
) AS SourceData
PIVOT (
    MAX(FieldVal) FOR field_title IN (
        [Defendant Caption],
        [UM],
        [Last Date of Service],
        [Client Done Treating?],
        [Contacted by Def Carrier?],
        [Location],
        [Hire Date],
        [Plt Ins Info],
        [Un-Injured Caller],
        [City],
        [County],
        [State],
        [County of Injury],
        [Def Ins Info],
        [Plaintiff Caption],
        [Health],
        [Time],
        [Employer/Carrier Caption],
        [Reconsideration Case?],
        [Presently in jail?],
        [Work Status],
        [Date Application Filed],
        [Date Injury Reported],
        [Status Upon Intake],
        [As Of],
        [Prompting Reconsideration],
        [Date Application Denied],
        [Court Date/ Court Room],
        [Their Title],
        [Reported to],
        [Approx. Settlement Date],
        [Comp Rate],
        [Doctor Support Claim?],
        [If Other, Please Explain],
        [Date Last Worked],
        [Employee Caption],
        [Local SS Office],
        [Last Doctor Seen],
        [Employer Name],
        [SSI/SSDI],
        [Regarding Comp Rate],
        [What are the charges?],
        [Prior WC Claims?],
        [Date of Last Appointment],
        [Onset Date],
        [COURT CAPTION],
        [Court City],
        [Pay at time of DOI],
        [2nd Class Code]
    )
) AS PivottedData;
go
 
------select * from NeosUserCase

--------------------------------
--2. USER INSURANCE INFO PIVOT
-------------------------------- 
  IF EXISTS (SELECT * FROM sys.tables WHERE name = 'NeosUserInsurance')
BEGIN
    DROP TABLE NeosUserInsurance;
END;

SELECT 
    insuranceid,
    [Medicare Notes] AS MedicareNotes,
    [Fax POR to COBC] AS FaxPORToCOBC,
    [Final Demand] AS FinalDemand,
    [Notes] AS Notes,
    [Comments] AS Comments,
    [Insurance Plan Type] AS InsurancePlanType,
    [Name] AS Name,
    [Rights & Responsibility] AS RightsAndResponsibility,
    [Attorney Portal Access?] AS AttorneyPortalAccess,
    [FINAL DEMAND AMOUNT] AS FinalDemandAmount,
    [Set up Claim with COBC] AS SetUpClaimWithCOBC,
    [ERISA?] AS ERISA,
    [POR from Client] AS PORFromClient,
    [Self Funded] AS SelfFunded,
    [COBC Initial Form Letter] AS COBCInitialFormLetter,
    [Name of the Group] AS NameOfTheGroup,
    [CPL Received] AS CPLReceived,
    [Fully Insured] AS FullyInsured,
    [Final Settlement Detail] AS FinalSettlementDetail
INTO NeosUserInsurance
FROM 
    (
        SELECT 
            insuranceid,
            ISNULL(ISNULL(CONVERT(VARCHAR(MAX), id.namesid), CONVERT(VARCHAR(MAX), id.picklistID)), CONVERT(VARCHAR(MAX), id.[data])) AS FieldVal,
            field_title
        FROM  
            [NeosBillEasterly]..[user_insurance_data] id
        JOIN  
            [NeosBillEasterly]..user_case_fields f 
        ON 
            f.id = id.usercasefieldid
    ) AS SourceData
PIVOT 
(
    MAX(FieldVal)
    FOR field_title IN (
        [Medicare Notes],
        [Fax POR to COBC],
        [Final Demand],
        [Notes],
        [Comments],
        [Insurance Plan Type],
        [Name],
        [Rights & Responsibility],
        [Attorney Portal Access?],
        [FINAL DEMAND AMOUNT],
        [Set up Claim with COBC],
        [ERISA?],
        [POR from Client],
        [Self Funded],
        [COBC Initial Form Letter],
        [Name of the Group],
        [CPL Received],
        [Fully Insured],
        [Final Settlement Detail]
    )
) AS PivottedData;
go

------ select *  from NeosUserInsurance


--------------------------------
--3. USER COUNSEL PIVOT
--------------------------------
  IF EXISTS (SELECT * FROM sys.tables WHERE name = 'NeosUserCounsel')
BEGIN
    DROP TABLE NeosUserCounsel
END
GO

SELECT 
    counselid, 
    [Amount Settled For] -- Field_title's name
INTO NeosUserCounsel
FROM (
    SELECT 
        counselid, 
        ISNULL(ISNULL(CONVERT(VARCHAR(MAX), id.namesid), CONVERT(VARCHAR(MAX), picklistID)), CONVERT(VARCHAR(MAX), id.[data])) AS FieldVal, 
        field_title
    FROM  
        [NeosBillEasterly]..user_counsel_data id
    JOIN  
        [NeosBillEasterly]..user_case_fields f 
    ON 
        f.id = id.usercasefieldid
) i
PIVOT (
    MAX(FieldVal) 
    FOR field_title IN ([Amount Settled For]) -- Include field title here
) piv;
GO

---- select * from NeosUserCounsel

--------------------------------
--4. USER PARTY PIVOT
--------------------------------
  IF EXISTS (SELECT * FROM sys.tables WHERE name = 'NeosUserParty')
BEGIN
    DROP TABLE NeosUserParty
END

SELECT 
    partyid, 
    [Termination Date],
    [Admissions],
    [Driver License No.],
    [Ambulance],
    [Scarring],
    [Client is Their],
    [Injuries],
    [Physical Therapy],
    [Back/Neck],
    [Alt. Address #1],
    [Memo],
    [Hire Date],
    [ER],
    [Send Mail To],
    [Job Duties],
    [TTD Rate],
    [Marital Status],
    [Dependents],
    [Chiro],
    [Agt for Process],
    [Names of Dependents],
    [Date of Accident],
    [Broken Bones],
    [Date of Prior Inj],
    [Specialist],
    [Spouse],
    [Hospital Admission],
    [Principal Place],
    [Knowledge],
    [Prior Injured How?],
    [Trtmt Since Accident],
    [Prior Injuries],
    [Military Service],
    [Surgery?],
    [Branch],
    [Honorable Discharge?],
    [Injured Body Part(s)],
    [Dependants],
    [Work History],
    [Other Income],
    [Education],
    [Type of Public Assistance],
    [Injured Person's Name],
    [Employer's Name],
    [Amount of Public Assist],
    [Married?],
    [Type of Pension],
    [Type of Disability],
    [Income from Investments],
    [Notes],
    [Children/Dependents?],
    [Public Assistance?],
    [Weight],
    [Caller Number],
    [Spouse Name],
    [Receiving Disability?],
    [Amount of Disability],
    [Dominant Hand],
    [someone else?],
    [Height Feet],
    [Pension?],
    [Spouse's Income],
    [Military Service Dates],
    [Caller Name],
    [Height Inches],
    [Valid Driver's License],
    [Relationship],
    [Mother's Maiden Name],
    [Relative Friend Reference],
    [Place of Birth City&State]
INTO NeosUserParty
FROM (
    SELECT 
        partyid, 
        ISNULL(ISNULL(CONVERT(VARCHAR(MAX), id.namesid), CONVERT(VARCHAR(MAX), id.picklistID)), CONVERT(VARCHAR(MAX), id.[data])) AS FieldVal, 
        field_title
    FROM  
        [NeosBillEasterly]..user_party_data id
    JOIN  
        [NeosBillEasterly]..user_case_fields f 
    ON 
        f.id = id.usercasefieldid
) i
PIVOT (
    MAX(FieldVal) FOR field_title IN (
        [Termination Date],
        [Admissions],
        [Driver License No.],
        [Ambulance],
        [Scarring],
        [Client is Their],
        [Injuries],
        [Physical Therapy],
        [Back/Neck],
        [Alt. Address #1],
        [Memo],
        [Hire Date],
        [ER],
        [Send Mail To],
        [Job Duties],
        [TTD Rate],
        [Marital Status],
        [Dependents],
        [Chiro],
        [Agt for Process],
        [Names of Dependents],
        [Date of Accident],
        [Broken Bones],
        [Date of Prior Inj],
        [Specialist],
        [Spouse],
        [Hospital Admission],
        [Principal Place],
        [Knowledge],
        [Prior Injured How?],
        [Trtmt Since Accident],
        [Prior Injuries],
        [Military Service],
        [Surgery?],
        [Branch],
        [Honorable Discharge?],
        [Injured Body Part(s)],
        [Dependants],
        [Work History],
        [Other Income],
        [Education],
        [Type of Public Assistance],
        [Injured Person's Name],
        [Employer's Name],
        [Amount of Public Assist],
        [Married?],
        [Type of Pension],
        [Type of Disability],
        [Income from Investments],
        [Notes],
        [Children/Dependents?],
        [Public Assistance?],
        [Weight],
        [Caller Number],
        [Spouse Name],
        [Receiving Disability?],
        [Amount of Disability],
        [Dominant Hand],
        [someone else?],
        [Height Feet],
        [Pension?],
        [Spouse's Income],
        [Military Service Dates],
        [Caller Name],
        [Height Inches],
        [Valid Driver's License],
        [Relationship],
        [Mother's Maiden Name],
        [Relative Friend Reference],
        [Place of Birth City&State]
    )
) piv;

------ select * from NeosUserParty


--------------------------------
--5. USER TAB1 PIVOT
--------------------------------
  IF EXISTS (SELECT * FROM sys.tables WHERE name = 'NeosUserTab1')
BEGIN
    DROP TABLE NeosUserTab1
END
GO

SELECT 
    casesid,
    tablistid,
    [Relationship to Client],
    [Current Medication],
    [Reason for Medication],
    [Frequency],
    [We Get Ct. Rptr],
    [Side Effects],
    [Date First Prescribed],
    [Physician Prescribed],
    [Our Office],
    [Comments],
    [Dosage],
    [Contact],
    [Medication]
INTO NeosUserTab1
FROM (
    SELECT 
        casesid, 
        tablistid,
        ISNULL(
            ISNULL(CONVERT(VARCHAR(MAX), id.namesid), CONVERT(VARCHAR(MAX), picklistID)),
            CONVERT(VARCHAR(MAX), id.[data])
        ) AS FieldVal, 
        field_title
    FROM  
        [NeosBillEasterly]..user_tab1_data id
    JOIN  
        [NeosBillEasterly]..user_case_fields f 
    ON 
        f.id = id.usercasefieldid 
    JOIN  
        [NeosBillEasterly]..user_tab1_list tl 
    ON 
        tl.id = id.tablistid
) AS SourceData
PIVOT (
    MAX(FieldVal) FOR field_title IN (
        [Relationship to Client],
        [Current Medication],
        [Reason for Medication],
        [Frequency],
        [We Get Ct. Rptr],
        [Side Effects],
        [Date First Prescribed],
        [Physician Prescribed],
        [Our Office],
        [Comments],
        [Dosage],
        [Contact],
        [Medication]
    )
) AS PivottedData;
GO


---select * from NeosUserTab1

 

--------------------------------
--6. USER TAB2 PIVOT
--------------------------------
  -- Drop table if it already exists
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'NeosUserTab2')
BEGIN
    DROP TABLE NeosUserTab2
END

-- Insert data into NeosUserTab2
SELECT casesid, tablistid,
       [Through] AS 'Through',
       [Value Code] AS 'Value Code',
       [Notes] AS 'Notes',
       [First Request] AS 'First Request',
       [MIR Appt Time] AS 'MIR Appt Time',
       [Billing Value Code:] AS 'Billing Value Code:',
       [Second Request] AS 'Second Request',
       [Date Received] AS 'Date Received',
       [Pre-Payment Required] AS 'Pre-Payment Required',
       [Type of Record] AS 'Type of Record',
       [For Dates From] AS 'For Dates From',
       [Provider Name] AS 'Provider Name',
       [MIR Date] AS 'MIR Date',
       [Third Request] AS 'Third Request',
       [Method] AS 'Method',
       [Ordered By] AS 'Ordered By',
       [Date Requested] AS 'Date Requested',
       [Notes About Provider Cont] AS 'Notes About Provider Cont',
       [Billing Company] AS 'Billing Company'
INTO NeosUserTab2
FROM (
    SELECT casesid, 
           tablistid, 
           ISNULL(
               ISNULL(CONVERT(VARCHAR(MAX), id.namesid), 
                      CONVERT(VARCHAR(MAX), picklistID)), 
               CONVERT(VARCHAR(MAX), id.[data])
           ) AS FieldVal, 
           field_title
    FROM [NeosBillEasterly]..user_tab2_data id
    JOIN [NeosBillEasterly]..user_case_fields f ON f.id = id.usercasefieldid
    JOIN [NeosBillEasterly]..user_tab2_list tl ON tl.id = id.tablistid
)  AS SourceData
PIVOT (
    MAX(FieldVal) FOR field_title IN (
        [Through],
        [Value Code],
        [Notes],
        [First Request],
        [MIR Appt Time],
        [Billing Value Code:],
        [Second Request],
        [Date Received],
        [Pre-Payment Required],
        [Type of Record],
        [For Dates From],
        [Provider Name],
        [MIR Date],
        [Third Request],
        [Method],
        [Ordered By],
        [Date Requested],
        [Notes About Provider Cont],
        [Billing Company]
    )
) AS PivottedData;

----- select * from NeosUserTab2

 
