use [SAbilleasterlyLaw]
go

-----
alter table sma_trn_emails disable trigger all
delete from  sma_trn_emails
DBCC CHECKIDENT ('sma_trn_emails', RESEED, 0);
alter table sma_trn_emails enable trigger all
-------
IF NOT EXISTS (select * From sys.tables t join sys.columns c on t.object_id = c.object_id where t.name = 'sma_trn_emails' and c.name = 'saga')
BEGIN
	alter table sma_trn_emails
	add SAGA varchar(50)
END
GO

------------ select * from sma_trn_emails
ALTER TABLE [sma_TRN_Emails] disable trigger all
GO
--------

INSERT INTO [dbo].[sma_TRN_Emails]
           ([emlnCaseID]
           ,[emlsContents]
		   ,emlnRecUserID
		   ,emldDate 
           , SAGA )
 select      casnCaseID	
		   ,replace(note, char(10), '<br>')    as emlsContents 
		   ,   U.usrnUserID	  as  emlnRecUserID
		  
		   , CASE WHEN N.note_date between '1900-01-01' and '2079-06-06' THEN     N.note_date 
	                    ELSE '1900-01-01' 
			 end			as emldDate 
		  , convert(varchar(50),n.ID)			as SAGA
-----select *
FROM  [NeosBillEasterly].[dbo].[case_notes_Indexed] N
LEFT JOIN [NeosBillEasterly] ..[case_note_topic] t on n.casenotetopicid = t.id
JOIN [sma_TRN_Cases] C on C.Neos_Saga = convert(varchar(50),N.casesid)
LEFT JOIN [sma_MST_Users] U on U.saga = convert(varchar(50),N.staffcreatedid)
LEFT JOIN [sma_TRN_Emails]  es on es.SAGA = convert(varchar(50),n.ID)
where t.topic = 'Email'  
go

----------
ALTER TABLE [sma_TRN_Emails] enable trigger all
go

------
 