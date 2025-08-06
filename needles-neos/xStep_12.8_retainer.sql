use     SAbilleasterlyLaw]
go

-------- select * from sma_TRN_Retainer

alter table [sma_TRN_Retainer] disable trigger all
delete from [sma_TRN_Retainer]
DBCC CHECKIDENT ('sma_TRN_Retainer', RESEED, 0);
alter table [sma_TRN_Retainer] enable trigger all

ALTER TABLE [sma_TRN_Retainer] DISABLE TRIGGER ALL
GO


 INSERT INTO [sma_TRN_Retainer] (
		[rtnnCaseID],
		[rtnnPlaintiffID],
		[rtndSentDt],
		[rtndRcvdDt],
		[rtndRetainerDt],
		[rtnbCopyRefAttFee],
		[rtnnFeeStru],
		[rtnbMultiFeeStru],
		[rtnnBeforeTrial],
		[rtnnAfterTrial],
		[rtnnAtAppeal],
		[rtnnUDF1],
		[rtnnUDF2],
		[rtnnUDF3],
		[rtnbComplexStru],
		[rtnbWrittenAgree],
		[rtnnStaffID],
		[rtnsComments],
		[rtnnUserID],
		[rtndDtCreated],
		[rtnnModifyUserID],
		[rtndDtModified],
		[rtnnLevelNo],
		[rtnnPlntfAdv],
		[rtnnFeeAmt],
		[rtnsRetNo],
		[rtnsClosingRetNo]
)
SELECT 
	 	 casnCaseID,			--[rtnnCaseID],
		NULL,					--[rtnnPlaintiffID],
		NULL,					--[rtndSentDt],
		casdOpeningDate,     --[rtndRcvdDt]    
	     casdOpeningDate,   --[rtndRetainerDt]
		NULL,					--[rtnbCopyRefAttFee],
		NULL,					--[rtnnFeeStru],
		NULL,					--[rtnbMultiFeeStru],
		NULL,					--[rtnnBeforeTrial],
		NULL,					--[rtnnAfterTrial],
		NULL,					--[rtnnAtAppeal],
		NULL,					--[rtnnUDF1],
		NULL,					--[rtnnUDF2],
		NULL,					--[rtnnUDF3],
		NULL,					--[rtnbComplexStru],
		1,						--[rtnbWrittenAgree],
		NULL,					--[rtnnStaffID],
		'',						--[rtnsComments],
		1,						--[rtnnUserID],
		GETDATE(),				--[rtndDtCreated],
		NULL,					--[rtnnModifyUserID],
		NULL,					--[rtndDtModified],
		1,						--[rtnnLevelNo],
		NULL,					--[rtnnPlntfAdv],
		NULL,					--[rtnnFeeAmt],
		'',			--[rtnsRetNo]
		''			--[rtnsClosingRetNo]
from sma_TRN_Cases

ALTER TABLE [sma_TRN_Retainer] ENABLE TRIGGER ALL
GO


----select * from sma_trn_cases


 








