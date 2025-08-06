USE SA
GO

/*
SELECT td.casesid, case when convert(varchar(50),td.[namesid]) IS NULL then td.[data] else convert(varchar(50),td.[namesid]) end as [data], ucf.field_title
	FROM [NeedlesNeosBisnarChase]..user_tab6_data td
	JOIN [NeedlesNeosBisnarChase]..user_case_fields ucf on ucf.id = td.usercasefieldid
	WHERE field_Title in ('Account for Hours?', 'Days Per Week', 'Details of Job Duties', 'Employer Name', 'Employment Status', 'Start Date (MM/YY)', 'End Date (MM/YY)', 
						'Hours Per Day', 'Job Title', 'Day of Week', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 
						'Monthly Gross Income', 'Pay Period', 'Rate of Pay', 'Type of Business', 'Earnings Statement', 'Overtime', 'Rate of Pay', 
						'Rest Break', 'Unlawful Wage Deductions')
*/

IF NOT EXISTS (SELECT * From sys.columns WHERE Name = N'saga' AND Object_ID = Object_ID(N'sma_TRN_Employment') )
BEGIN
	ALTER TABLE [sma_TRN_Employment]
	ADD saga varchar(50)
END
GO

--------------------------
--EMPLOYOMENT PIVOT
--------------------------
IF EXISTS (SELECT * FROM sys.tables where name = 'EmploymentPivot')
BEGIN
	DROP TABLE EmploymentPivot
END


SELECT casesid, TabListID, [Account for Hours?], [Days Per Week], [Details of Job Duties], [Employer Name], [Employment Status], [Start Date (MM/YY)], [End Date (MM/YY)], 
						[Hours Per Day], [Job Title], [Monday], [Tuesday], [Wednesday], [Thursday], [Friday], 
						[Monthly Gross Income], [Pay Period], [Rate of Pay], [Type of Business], [Describe], [After Onset?]
INTO EmploymentPivot
FROM
(
	SELECT tl.casesid as CasesID, td.tablistid, case when convert(varchar(50),td.[namesid]) IS NULL then td.[data] else convert(varchar(50),td.[namesid]) end as [data], ucf.field_title
	FROM [NeedlesNeosBisnarChase]..user_tab3_data td
	JOIN [NeedlesNeosBisnarChase]..user_tab3_list tl on tl.id = td.tablistid
	JOIN [NeedlesNeosBisnarChase]..user_case_fields ucf on ucf.id = td.usercasefieldid
	WHERE field_Title in ('Account for Hours?', 'Days Per Week', 'Details of Job Duties', 'Employer Name', 'Employment Status', 'Start Date (MM/YY)', 'End Date (MM/YY)', 
						'Hours Per Day', 'Job Title', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 
						'Monthly Gross Income', 'Pay Period', 'Rate of Pay', 'Type of Business','Describe','After Onset?' )
) d
pivot
(
  max([data])
  for field_title in ([Account for Hours?], [Days Per Week], [Details of Job Duties], [Employer Name], [Employment Status], [Start Date (MM/YY)], [End Date (MM/YY)], 
						[Hours Per Day], [Job Title], [Monday], [Tuesday], [Wednesday], [Thursday], [Friday], 
						[Monthly Gross Income], [Pay Period], [Rate of Pay], [Type of Business], [Describe], [After Onset?])
) piv;

--select * From EmploymentPivot
---------------------------------------------
--EMPLOYMENT STATUSES
---------------------------------------------
INSERT INTO sma_MST_EmploymentStatuses ([Name])
SELECT DISTINCT [Employment Status]
FROM EmploymentPivot WHERE isnull([Employment Status],'') <>''
EXCEPT SELECT [Name] FROM sma_MST_EmploymentStatuses

---------------------------------------------
--EMPLOYMENT TRADES
---------------------------------------------
INSERT INTO sma_MST_Trades ([Name])
SELECT DISTINCT [Type of Business]
FROM EmploymentPivot WHERE isnull([Type of Business],'') <>''
EXCEPT SELECT [Name] From sma_MST_Trades

---------------------------------------------
--INSERT EMPLOYMENT
---------------------------------------------
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
SELECT  --MAP.case_id
    (SELECT TOP 1 plnnPlaintiffID FROM sma_trn_plaintiff WHERE plnnCaseID = cas.casncaseid and plnbIsPrimary = 1)		as empnPlaintiffID,
    ioc.AID					as empnEmprAddressID,
    ioc.CID					as empnEmployerID,
	NULL					as empncontactPersonID,
	NULL	 				as empnCPAddressID,
    null					as empnEmpUnion,
	(select TOP 1 [ID] From sma_MST_EmploymentStatuses where [name] = ud.[Employment Status])		as empnStatusId,
    ud.[Job Title]			as empsJobTitle,
    isnull('Account for Hours? ' + nullif(convert(varchar(max),ud.[Account for Hours?]),'') + CHAR(13),'') + 
	isnull('Days per Week: ' + nullif(convert(varchar(max),ud.[Days Per Week]),'') + CHAR(13),'') + 
	isnull('Monthly Gross Income: ' + nullif(convert(varchar(max),ud.[Monthly Gross Income]),'') + CHAR(13),'') + 
	isnull('Pay Period: ' + nullif(convert(varchar(max),ud.[Pay Period]),'') + CHAR(13),'') + 
	isnull('Rate of Pay: ' + nullif(convert(varchar(max),ud.[Rate of Pay]),'') + CHAR(13),'') + 
	''						as empsCompensationComments,
    null					as empnAverageWeeklyWage,
    NULL					as empnSalaryAmt,
	NULL					as empnSalaryFreqID,
    null					as empbOnTheJob,
    null					as empbWCClaim,
    case when isnull([Start Date (MM/YY)],'') <> '' then convert(date, left([Start Date (MM/YY)],2)+'/1/'+ right([Start Date (MM/YY)],2)) else NULL end		as empdDateHired,
	case when isnull([End Date (MM/YY)],'') <> '' then convert(date, left([End Date (MM/YY)],2)+'/1/'+ right([End Date (MM/YY)],2)) else NULL end			as empdDateTo,
    isnull('Describe: ' + nullif(convert(varchar(max),ud.[Describe]),'') + CHAR(13),'') + 
	isnull('After Onset? ' + nullif(convert(varchar(max),ud.[After Onset?]),'') + CHAR(13),'') + 
	isnull('Details of Job Duties: ' + nullif(convert(varchar(max),ud.[details of Job Duties]),'') + CHAR(13),'') + 
	isnull('Hours Per Day: ' + nullif(convert(varchar(max),ud.[Hours Per Day]),'') + CHAR(13),'') + 
	isnull('Monday: ' + nullif(convert(varchar(max),ud.[Monday]),'') + CHAR(13),'') + 
	isnull('Tuesday: ' + nullif(convert(varchar(max),ud.[Tuesday]),'') + CHAR(13),'') + 
	isnull('Wednesday: ' + nullif(convert(varchar(max),ud.[Wednesday]),'') + CHAR(13),'') + 
	isnull('Thursday: ' + nullif(convert(varchar(max),ud.[Thursday]),'') + CHAR(13),'') + 
	isnull('Friday: ' + nullif(convert(varchar(max),ud.[Friday]),'') + CHAR(13),'') + 
	 ''						as empsComments,
	 convert(varchar(50),ud.tablistid)			as saga
FROM EmploymentPivot ud
JOIN sma_trn_cases cas on cas.Needles_saga = convert(varchar(50),ud.CasesID)
JOIN IndvOrgContacts_Indexed ioc on ioc.saga = '-2' and ioc.[name] = ud.[Employer Name]


-------------------------------------
--INSERT TRADES
-------------------------------------
INSERT INTO sma_TRN_Employment_Trades (EmploymentId, TradesId)
SELECT DISTINCT em.empnEmploymentID, tr.Id
FROM EmploymentPivot pv
JOIN [sma_TRN_Employment]  em on convert(varchar(50),pv.tablistid) = em.saga
JOIN sma_MST_Trades tr on tr.[name] = pv.[Type of Business]
WHERE isnull([Type of Business],'') <> ''


