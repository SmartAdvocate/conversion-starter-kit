
USE SA
GO

/*
alter table [sma_TRN_CaseStatus] disable trigger all
delete from [sma_TRN_CaseStatus]
DBCC CHECKIDENT ('[sma_TRN_CaseStatus]', RESEED, 0);
alter table [sma_TRN_CaseStatus] enable trigger all
*/

---(0)---
INSERT INTO sma_MST_CaseStatus ( csssDescription,cssnStatusTypeID )
SELECT 
    A.[name],
    (select stpnStatusTypeID from sma_MST_CaseStatusType where stpsStatusType='Status')
FROM
(	SELECT DISTINCT [description] as [name]
	FROM [NeedlesNeosBisnarChase].[dbo].[class] class
	JOIN [NeedlesNeosBisnarChase].[dbo].[cases] C on C.classid = class.[id]
	UNION SELECT 'Conversion Case No Status'
  EXCEPT
SELECT csssDescription as [name] FROM sma_MST_CaseStatus
WHERE cssnStatusTypeID = (select stpnStatusTypeID from sma_MST_CaseStatusType where stpsStatusType='Status')
) A
GO


---(1)---
ALTER TABLE [sma_TRN_CaseStatus] DISABLE TRIGGER ALL
GO
---------

INSERT INTO [sma_TRN_CaseStatus] (
		[cssnCaseID],
		[cssnStatusTypeID],
		[cssnStatusID],
		[cssnExpDays],
		[cssdFromDate],
		[cssdToDt],
		[csssComments],
		[cssnRecUserID],
		[cssdDtCreated],
		[cssnModifyUserID],
		[cssdDtModified],
		[cssnLevelNo],
		[cssnDelFlag]
)
SELECT
    CAS.casnCaseID,
    (select stpnStatusTypeID from sma_MST_CaseStatusType where stpsStatusType='Status') as [cssnStatusTypeID],
    case when C.close_date between '1900-01-01' and '2079-06-06' 
			then (select cssnStatusID from sma_MST_CaseStatus where csssDescription='Closed Case')
	   when exists (select * from sma_MST_CaseStatus where csssDescription=CL.[description]) 
			then (select cssnStatusID from sma_MST_CaseStatus where csssDescription=CL.[description])
	   else (select cssnStatusID from sma_MST_CaseStatus where csssDescription='Conversion Case No Status')
    end				as [cssnStatusID],
    ''				as [cssnExpDays],
   GETDATE()		as [cssdFromDate],
    null			as [cssdToDt],
    case when C.close_date between '1900-01-01' and '2079-06-06' 
		  then 'Prior Status : ' + CL.[description]
	   else '' end	+char(13) +
	   ''			as [csssComments],
    368,
    GETDATE(),
    null,null,null,null 
FROM [sma_trn_cases] CAS
JOIN [NeedlesNeosBisnarChase].[dbo].[cases] C on convert(varchar(50),C.[id]) = CAS.Needles_saga
LEFT JOIN [NeedlesNeosBisnarChase].[dbo].[class] CL on C.classid = CL.id
LEFT JOIN [sma_TRN_CaseStatus] cs on cs.cssnCaseID = cas.casncaseid
WHERE cs.cssnCaseStatusID IS NULL
GO

--------
ALTER TABLE [sma_TRN_CaseStatus] ENABLE TRIGGER ALL
GO
--------


---(2)---
ALTER TABLE [sma_trn_cases] DISABLE TRIGGER ALL
GO
---------
UPDATE sma_trn_cases set casnStatusValueID=STA.cssnStatusID
FROM sma_TRN_CaseStatus STA
WHERE STA.cssnCaseID=casnCaseID
GO

ALTER TABLE [sma_trn_cases] ENABLE TRIGGER ALL
GO


