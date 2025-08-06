
use SA
go
/*
alter table [sma_TRN_CriticalComments] disable trigger all
delete from [sma_TRN_CriticalComments] 
DBCC CHECKIDENT ('[sma_TRN_CriticalComments]', RESEED, 0);
alter table [sma_TRN_CriticalComments] enable trigger all
*/

INSERT INTO [sma_TRN_CriticalComments]
(
       [ctcnCaseID]
      ,[ctcnCommentTypeID]
      ,[ctcsText]
      ,[ctcbActive]
      ,[ctcnRecUserID]
      ,[ctcdDtCreated]
      ,[ctcnModifyUserID]
      ,[ctcdDtModified]
      ,[ctcnLevelNo]
      ,[ctcsCommentType]
)
SELECT 
    CAS.casnCaseID	    as [ctcnCaseID],
    0					as [ctcnCommentTypeID],
    special_note	    as [ctcsText],
    1					as [ctcbActive],
    (select usrnUserID from sma_MST_Users where saga=convert(varchar(50),staffcreatedid))	as [ctcnRecUserID],
    date_created	    as [ctcdDtCreated],
    (select usrnUserID from sma_MST_Users where saga=convert(varchar(50),staffmodifiedid))	as [ctcnModifyUserID],
    date_modified	    as [ctcdDtModified],
    null			    as [ctcnLevelNo],
    null			    as [ctcsCommentType]
--select *
FROM [NeedlesNeosBisnarChase].[dbo].[cases_Indexed] C
JOIN [sma_trn_cases] CAS on CAS.Needles_saga= convert(varchar(50),C.id)
WHERE isnull(special_note,'')<>''

