use [NeosBillEasterly]
go

--------------------------------
--7. USER TAB3 PIVOT
--------------------------------
  -- Drop table if it already exists
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'NeosUserTab3')
BEGIN
    DROP TABLE NeosUserTab3
END

-- Insert data into NeosUserTab3
SELECT casesid, tablistid,
       [Comments] AS 'Comments',
       [MMI Date] AS 'MMI Date',
       [Body Part] AS 'Body Part',
       [Received] AS 'Received',
       [Not Available] AS 'Not Available',
       [Name] AS 'Name',
       [Other] AS 'Other',
       [Type of Business] AS 'Type of Business',
       [Details of Job Duties] AS 'Details of Job Duties',
       [Restrictions] AS 'Restrictions',
       [Rating] AS 'Rating',
       [Hours Per Day] AS 'Hours Per Day',
       [Job Title] AS 'Job Title',
       [Type] AS 'Type',
       [Days Per Week] AS 'Days Per Week',
       [Contact] AS 'Contact',
       [Notes] AS 'Notes',
       [Department] AS 'Department',
       [Write, Type, handle small] AS 'Write, Type, handle small',
       [Day] AS 'Day',
       [Lifting and Carrying] AS 'Lifting and Carrying',
       [Walk?] AS 'Walk?',
       [How much supervision time] AS 'How much supervision time',
       [Machines, Tools,Equipment] AS 'Machines, Tools,Equipment',
       [Stand?] AS 'Stand?',
       [If so, How many people?] AS 'If so, How many people?',
       [Did you hire and fire Ees] AS 'Did you hire and fire Ees',
       [Stoop?] AS 'Stoop?',
       [Month] AS 'Month',
       [Crouch?] AS 'Crouch?',
       [Hour] AS 'Hour',
       [Did you supervise others?] AS 'Did you supervise others?',
       [Writing,Complete Reports?] AS 'Writing,Complete Reports?',
       [Reach?] AS 'Reach?',
       [Ten lbs] AS 'Ten lbs',
       [Were you a Lead Worker?] AS 'Were you a Lead Worker?',
       [Handle Big Objects] AS 'Handle Big Objects',
       [Week] AS 'Week',
       [Climb?] AS 'Climb?',
       [Less than 10 lbs.] AS 'Less than 10 lbs.',
       [Tech. Knowledge or Skills] AS 'Tech. Knowledge or Skills',
       [Crawl?] AS 'Crawl?',
       [Year] AS 'Year',
       [Start Date] AS 'Start Date',
       [Fifty lbs] AS 'Fifty lbs',
       [Weight Frequently Lifted?] AS 'Weight Frequently Lifted?',
       [One Hundred lbs. or more] AS 'One Hundred lbs. or more',
       [Sit?] AS 'Sit?',
       [Your Rate of Pay] AS 'Your Rate of Pay',
       [Twenty lbs] AS 'Twenty lbs',
       [End Date] AS 'End Date',
       [Kneel?] AS 'Kneel?',
       [Treatment Start Date] AS 'Treatment Start Date'
INTO NeosUserTab3
FROM (
    SELECT casesid, 
           tablistid, 
           ISNULL(
               ISNULL(CONVERT(VARCHAR(MAX), id.namesid), 
                      CONVERT(VARCHAR(MAX), picklistID)), 
               CONVERT(VARCHAR(MAX), id.[data])
           ) AS FieldVal, 
           field_title
    FROM [NeosBillEasterly]..user_tab3_data id
    JOIN [NeosBillEasterly]..user_case_fields f ON f.id = id.usercasefieldid
    JOIN [NeosBillEasterly]..user_tab3_list tl ON tl.id = id.tablistid
) AS SourceData
PIVOT (
    MAX(FieldVal) FOR field_title IN (
        [Comments],
        [MMI Date],
        [Body Part],
        [Received],
        [Not Available],
        [Name],
        [Other],
        [Type of Business],
        [Details of Job Duties],
        [Restrictions],
        [Rating],
        [Hours Per Day],
        [Job Title],
        [Type],
        [Days Per Week],
        [Contact],
        [Notes],
        [Department],
        [Write, Type, handle small],
        [Day],
        [Lifting and Carrying],
        [Walk?],
        [How much supervision time],
        [Machines, Tools,Equipment],
        [Stand?],
        [If so, How many people?],
        [Did you hire and fire Ees],
        [Stoop?],
        [Month],
        [Crouch?],
        [Hour],
        [Did you supervise others?],
        [Writing,Complete Reports?],
        [Reach?],
        [Ten lbs],
        [Were you a Lead Worker?],
        [Handle Big Objects],
        [Week],
        [Climb?],
        [Less than 10 lbs.],
        [Tech. Knowledge or Skills],
        [Crawl?],
        [Year],
        [Start Date],
        [Fifty lbs],
        [Weight Frequently Lifted?],
        [One Hundred lbs. or more],
        [Sit?],
        [Your Rate of Pay],
        [Twenty lbs],
        [End Date],
        [Kneel?],
        [Treatment Start Date]
    )
) AS PivottedData;
go

----- select * from NeosUserTab3

  --------------------------------
--8. USER TAB4 PIVOT
--------------------------------
 -- Drop table if it already exists
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'NeosUserTab4')
BEGIN
    DROP TABLE NeosUserTab4
END

-- Insert data into NeosUserTab4
SELECT casesid, tablistid,
       [Comments] AS 'Comments',
       [Location of Depo] AS 'Location of Depo',
       [Location] AS 'Location',
       [Type of Witness] AS 'Type of Witness',
       [Depo Date] AS 'Depo Date',
       [Srvd on Plt] AS 'Srvd on Plt',
       [Srvd on Def] AS 'Srvd on Def',
       [Reviewed] AS 'Reviewed',
       [Depo Time] AS 'Depo Time',
       [Court Reporter] AS 'Court Reporter',
       [Contact] AS 'Contact',
       [Notes] AS 'Notes',
       [Type of Expert] AS 'Type of Expert',
       [CV on File?] AS 'CV on File?',
       [Witness Name] AS 'Witness Name',
       [Depo Prep Date] AS 'Depo Prep Date',
       [Depo Prep Time] AS 'Depo Prep Time',
       [Interpreter?] AS 'Interpreter?',
       [Court Reporter Cost] AS 'Court Reporter Cost',
       [Expert Cost] AS 'Expert Cost'
INTO NeosUserTab4
FROM (
    SELECT casesid, 
           tablistid, 
           ISNULL(
               ISNULL(CONVERT(VARCHAR(MAX), id.namesid), 
                      CONVERT(VARCHAR(MAX), picklistID)), 
               CONVERT(VARCHAR(MAX), id.[data])
           ) AS FieldVal, 
           field_title
    FROM [NeosBillEasterly]..user_tab4_data id
    JOIN [NeosBillEasterly]..user_case_fields f ON f.id = id.usercasefieldid
    JOIN [NeosBillEasterly]..user_tab4_list tl ON tl.id = id.tablistid
) AS SourceData
PIVOT (
    MAX(FieldVal) FOR field_title IN (
        [Comments],
        [Location of Depo],
        [Location],
        [Type of Witness],
        [Depo Date],
        [Srvd on Plt],
        [Srvd on Def],
        [Reviewed],
        [Depo Time],
        [Court Reporter],
        [Contact],
        [Notes],
        [Type of Expert],
        [CV on File?],
        [Witness Name],
        [Depo Prep Date],
        [Depo Prep Time],
        [Interpreter?],
        [Court Reporter Cost],
        [Expert Cost]
    )
) AS PivottedData;

-------select * from NeosUserTab4

--------------------------------
--9. USER TAB5 PIVOT
--------------------------------
 -- Drop table if it already exists
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'NeosUserTab5')
BEGIN
    DROP TABLE NeosUserTab5
END

-- Insert data into NeosUserTab5
SELECT casesid, tablistid,
       [Comments] ,
       [MMI Date] ,
       [Body Part] ,
       [Name] ,
       [Body System] ,
       [Burns] ,
       [Other] ,
       [Heart Attack] ,
       [Treatment Freq/Duration] ,
       [Emphysema] ,
       [Mental Illness] ,
       [Blood Clots] ,
       [Restrictions] ,
       [COPD] ,
       [Cerebral Palsy] ,
       [Glaucoma] ,
       [Stroke] ,
       [Fibromyalgia] ,
       [Rating] ,
       [Leukemia] ,
       [Deafness] ,
       [Back] ,
       [Type] ,
       [Headaches] ,
       [Crohn's Disease] ,  
       [Bronchitis]  ,
       [Asthma]  ,
       [Liver Disease]  ,
       [Diabetes]  ,
       [Hearing Loss]   ,
       [Hypertension]  ,
       [Joint Replacement]  ,
       [Doctor Support Claim?]  ,
       [Congestive Heart Failure]  ,
       [HBP]  ,
       [Impairment]  ,
       [Cystic Fibrosis]  ,
       [Mental Retardation]   ,
       [Coronary Artery Disease]  ,
       [Cancer]  ,
       [Blindness]  ,
       [Kidney Disease]  ,
       [Arthritis]  ,
       [Blood Disorder]  ,
       [Lupus]  ,
       [Lung Cancer]  ,
       [Breast Cancer]  ,
       [Colitis]  ,
       [Doctor Treating]  ,
       [Shortness of Breath] ,
       [Depression]  ,
       [Amputation]  ,
       [Angina]  ,
       [Have All Necessary Record]  ,
       [Heart Disease]  ,
       [Irregular Heartbeat]  ,
       [Irritable Bowel Syndrome]  ,
       [Eating Disorders]  ,
       [Carpal Tunnel]  ,
       [ADHD]  ,
       [Chest Pains]  ,
       [Department]  ,
       [Neuropathy]  ,
       [Sleep Apnea]  ,
       [Sjogren's Syndrome] ,
       [Skin Disorder]  ,
       [Spinal Disorders]  ,
       [Bipolar Disorder]  ,
       [Vision/Blindness]  ,
       [PeripheralArterialDisease]  ,
       [Raynaud's Syndrome] ,
       [Multiple Sclerosis]  ,
       [Thyroid]  ,
       [Organ Transplant]  ,
       [PTSD]  ,
       [Neck]  ,
       [Scoliosis]  ,
       [Other Heart Problems] ,
       [Vertigo]  ,
       [Down Syndrome]  ,
       [Schizophrenia]  ,
       [Fracture with Nonunion]  ,
       [Growth Impairment]  ,
       [Retinopathy]  ,
       [Substance Abuse]  ,
       [Muscular Dystrophy]  ,
       [ALS]  ,
       [Sickle Cell Anemia]  ,
       [Ulcers]  ,
       [Pancreatitis]  ,
       [Malnutrition]  ,
       [CFS]  ,
       [OCD]  ,
       [Myasthenia Gravis]  ,
       [Parkinson's]  ,
       [Severe Weight Loss]  ,
       [Sarcoidosis]  ,
       [Sleeping Disorders]  ,
       [Obesity]  ,
       [Treatment Dates:]  ,
       [Epilepsy]  ,
       [Traumatic Brain Injury]  ,
       [Polio]  ,
       [Treatment Start Date] 
INTO NeosUserTab5
FROM (
    SELECT casesid, 
           tablistid, 
           ISNULL(
               ISNULL(CONVERT(VARCHAR(MAX), id.namesid), 
                      CONVERT(VARCHAR(MAX), picklistID)), 
               CONVERT(VARCHAR(MAX), id.[data])
           ) AS FieldVal, 
           field_title
    FROM [NeosBillEasterly]..user_tab5_data id
    JOIN [NeosBillEasterly]..user_case_fields f ON f.id = id.usercasefieldid
    JOIN [NeosBillEasterly]..user_tab5_list tl ON tl.id = id.tablistid
) AS SourceData
PIVOT (
    MAX(FieldVal) FOR field_title IN (
        [Comments],
        [MMI Date],
        [Body Part],
        [Name],
        [Body System],
        [Burns],
        [Other],
        [Heart Attack],
        [Treatment Freq/Duration],
        [Emphysema],
        [Mental Illness],
        [Blood Clots],
        [Restrictions],
        [COPD],
        [Cerebral Palsy],
        [Glaucoma],
        [Stroke],
        [Fibromyalgia],
        [Rating],
        [Leukemia],
        [Deafness],
        [Back],
        [Type],
        [Headaches],
        [Crohn's Disease],
        [Bronchitis],
        [Asthma],
        [Liver Disease],
        [Diabetes],
        [Hearing Loss],
        [Hypertension],
        [Joint Replacement],
        [Doctor Support Claim?],
        [Congestive Heart Failure],
        [HBP],
        [Impairment],
        [Cystic Fibrosis],
        [Mental Retardation],
        [Coronary Artery Disease],
        [Cancer],
        [Blindness],
        [Kidney Disease],
        [Arthritis],
        [Blood Disorder],
        [Lupus],
        [Lung Cancer],
        [Breast Cancer],
        [Colitis],
        [Doctor Treating],
        [Shortness of Breath],
        [Depression],
        [Amputation],
        [Angina],
        [Have All Necessary Record],
        [Heart Disease],
        [Irregular Heartbeat],
        [Irritable Bowel Syndrome],
        [Eating Disorders],
        [Carpal Tunnel],
        [ADHD],
        [Chest Pains],
        [Department],
        [Neuropathy],
        [Sleep Apnea],
        [Sjogren's Syndrome],
        [Skin Disorder],
        [Spinal Disorders],
        [Bipolar Disorder],
        [Vision/Blindness],
        [PeripheralArterialDisease],
        [Raynaud's Syndrome],
        [Multiple Sclerosis],
        [Thyroid],
        [Organ Transplant],
        [PTSD],
        [Neck],
        [Scoliosis],
        [Other Heart Problems],
        [Vertigo],
        [Down Syndrome],
        [Schizophrenia],
        [Fracture with Nonunion],
        [Growth Impairment],
        [Retinopathy],
        [Substance Abuse],
        [Muscular Dystrophy],
        [ALS],
        [Sickle Cell Anemia],
        [Ulcers],
        [Pancreatitis],
        [Malnutrition],
        [CFS],
        [OCD],
        [Myasthenia Gravis],
        [Parkinson's],
        [Severe Weight Loss],
        [Sarcoidosis],
        [Sleeping Disorders],
        [Obesity],
        [Treatment Dates:],
        [Epilepsy],
        [Traumatic Brain Injury],
        [Polio],
        [Treatment Start Date]
    )
) AS PivottedData;
go

------------------select * from NeosUserTab5

--------------------------------
--10. USER TAB6 PIVOT
--------------------------------

-- Drop table if it already exists
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'NeosUserTab6')
BEGIN
    DROP TABLE NeosUserTab6
END

-- Insert data into NeosUserTab6
SELECT casesid,
       [City],
       [Intervened in this Case?],
       [Is Trial Set?],
       [Plt Issued Citation?],
       [Accident Report?],
       [Recommended Action],
       [Time of Accident],
       [Plt BAC],
       [Veh. Location],
       [Location],
       [Amount Settled For],
       [Number of Vehicles],
       [Def BAC],
       [Events Scheduled],
       [Plt Citation Type],
       [Updated],
       [Status Report Summary],
       [County],
       [Rental Car?],
       [Type of Accident],
       [Who Paid?],
       [Satisfactory],
       [Number of Witnesses],
       [Is Mediation Set?],
       [Property Damage],
       [Staff],
       [Rental Car Co.],
       [Accident Report Number],
       [Year/Make/Model:],
       [Result of Citation],
       [Contact],
       [Def Citation Type],
       [State],
       [Vehicle Year/Make/Model],
       [Member Treating?],
       [Def Issued Citation?]
INTO NeosUserTab6
FROM (
    SELECT casesid, 
           ISNULL(
               ISNULL(CONVERT(VARCHAR(MAX), id.namesid), 
                      CONVERT(VARCHAR(MAX), picklistID)), 
               CONVERT(VARCHAR(MAX), id.[data])
           ) AS FieldVal, 
           field_title
    FROM [NeosBillEasterly]..user_tab6_data id
    JOIN [NeosBillEasterly]..user_case_fields f ON f.id = id.usercasefieldid
) AS SourceData 
PIVOT (
    MAX(FieldVal) FOR field_title IN (
        [City],
        [Intervened in this Case?],
        [Is Trial Set?],
        [Plt Issued Citation?],
        [Accident Report?],
        [Recommended Action],
        [Time of Accident],
        [Plt BAC],
        [Veh. Location],
        [Location],
        [Amount Settled For],
        [Number of Vehicles],
        [Def BAC],
        [Events Scheduled],
        [Plt Citation Type],
        [Updated],
        [Status Report Summary],
        [County],
        [Rental Car?],
        [Type of Accident],
        [Who Paid?],
        [Satisfactory],
        [Number of Witnesses],
        [Is Mediation Set?],
        [Property Damage],
        [Staff],
        [Rental Car Co.],
        [Accident Report Number],
        [Year/Make/Model:],
        [Result of Citation],
        [Contact],
        [Def Citation Type],
        [State],
        [Vehicle Year/Make/Model],
        [Member Treating?],
        [Def Issued Citation?]
    )
) AS PivottedData;


 --------------------------------
--11. USER TAB7 PIVOT
--------------------------------
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'NeosUserTab7')
BEGIN
    DROP TABLE NeosUserTab7
END

SELECT casesid,
       [MRI],
       [Physical Therapy],
       [Burns],
       [Eye],
       [Amputation],
       [First Treatment Date],
       [X-Ray],
       [Favorable Decision],
       [Rx],
       [Comments],
       [SSD Fee Received],
       [Admin Fee],
       [ER],
       [Diagnosis],
       [Injuries],
       [Scarring],
       [Hospital Admission],
       [Chiropractic],
       [Broken Bone],
       [Date of Award - SSD],
       [Mouth/Tooth],
       [Surgery?],
       [Ambulance],
       [Initial Treatment],
       [Bruising],
       [Back/Neck],
       [Family Doctor],
       [Atty Fee - SSD],
       [Panel Provided?],
       [Past Due Benefits],
       [Specialist],
       [CT Scan],
       [Injured Body Part(s)],
       [Date of Decision - SSD]
INTO NeosUserTab7
FROM (
    SELECT casesid, 
           ISNULL(
               ISNULL(CONVERT(VARCHAR(MAX), id.namesid), 
                      CONVERT(VARCHAR(MAX), picklistID)), 
               CONVERT(VARCHAR(MAX), id.[data])
           ) AS FieldVal, 
           field_title
    FROM [NeosBillEasterly]..user_tab7_data id
    JOIN [NeosBillEasterly]..user_case_fields f ON f.id = id.usercasefieldid
) SourceData
PIVOT (
    MAX(FieldVal) FOR field_title IN (
        [MRI],
        [Physical Therapy],
        [Burns],
        [Eye],
        [Amputation],
        [First Treatment Date],
        [X-Ray],
        [Favorable Decision],
        [Rx],
        [Comments],
        [SSD Fee Received],
        [Admin Fee],
        [ER],
        [Diagnosis],
        [Injuries],
        [Scarring],
        [Hospital Admission],
        [Chiropractic],
        [Broken Bone],
        [Date of Award - SSD],
        [Mouth/Tooth],
        [Surgery?],
        [Ambulance],
        [Initial Treatment],
        [Bruising],
        [Back/Neck],
        [Family Doctor],
        [Atty Fee - SSD],
        [Panel Provided?],
        [Past Due Benefits],
        [Specialist],
        [CT Scan],
        [Injured Body Part(s)],
        [Date of Decision - SSD]
    )
) PivotData;

------ select * from NeosUserTab7

 --------------------------------
--12. USER TAB8 PIVOT
--------------------------------
 IF EXISTS (SELECT * FROM sys.tables WHERE name = 'NeosUserTab8')
BEGIN
    DROP TABLE NeosUserTab8
END

SELECT casesid,
       [Medical Proof Deadline],
       [Expert Wit. Depo Deadline],
       [Def. Rule 26 Disc. By],
       [Pltf Rule 26 Disc. By],
       [Date of Last Appointment],
       [Benefits?],
       [Applied],
       [Medicare?],
       [WC Paying for Treatment?],
       [Who's Paying?],
       [Health Insurance?],
       [How Often?]
INTO NeosUserTab8
FROM (
    SELECT casesid, 
           ISNULL(
               ISNULL(CONVERT(VARCHAR(MAX), id.namesid), 
                      CONVERT(VARCHAR(MAX), picklistID)), 
               CONVERT(VARCHAR(MAX), id.[data])
           ) AS FieldVal, 
           field_title
    FROM [NeosBillEasterly]..user_tab8_data id
    JOIN [NeosBillEasterly]..user_case_fields f ON f.id = id.usercasefieldid
) SourceData
PIVOT (
    MAX(FieldVal) FOR field_title IN (
        [Medical Proof Deadline],
        [Expert Wit. Depo Deadline],
        [Def. Rule 26 Disc. By],
        [Pltf Rule 26 Disc. By],
        [Date of Last Appointment],
        [Benefits?],
        [Applied],
        [Medicare?],
        [WC Paying for Treatment?],
        [Who's Paying?],
        [Health Insurance?],
        [How Often?]
    )
) PivotData;

------select * from NeosUserTab8

 --------------------------------
--12. USER TAB9 PIVOT
--------------------------------
 IF EXISTS (SELECT * FROM sys.tables WHERE name = 'NeosUserTab9')
BEGIN
    DROP TABLE NeosUserTab9
END

SELECT casesid,
       [Accident Report?],
       [Location],
       [Contact Person],
       [City],
       [County],
       [Number of Witnesses],
       [Status Conf.],
       [Time of Accident],
       [Time],
       [Day of Week]
INTO NeosUserTab9
FROM (
    SELECT casesid, 
           ISNULL(
               ISNULL(CONVERT(VARCHAR(MAX), id.namesid), 
                      CONVERT(VARCHAR(MAX), picklistID)), 
               CONVERT(VARCHAR(MAX), id.[data])
           ) AS FieldVal, 
           field_title
    FROM [NeosBillEasterly]..user_tab9_data id
    JOIN [NeosBillEasterly]..user_case_fields f ON f.id = id.usercasefieldid
) SourceData
PIVOT (
    MAX(FieldVal) FOR field_title IN (
        [Accident Report?],
        [Location],
        [Contact Person],
        [City],
        [County],
        [Number of Witnesses],
        [Status Conf.],
        [Time of Accident],
        [Time],
        [Day of Week]
    )
) PivotData;

-----SELECT * FROM NeosUserTab9;