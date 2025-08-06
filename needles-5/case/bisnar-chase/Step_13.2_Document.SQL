
use [SA]
go

/*
alter table [sma_TRN_Documents] disable trigger all
delete from [sma_TRN_Documents] 
DBCC CHECKIDENT ('[sma_TRN_Documents]', RESEED, 0);
alter table [sma_TRN_Documents] enable trigger all
*/


/*
IF OBJECT_ID (N'dbo.FileNamePart', N'FN') IS NOT NULL
    DROP FUNCTION FileNamePart;
GO
CREATE FUNCTION dbo.FileNamePart(@parameter varchar(MAX) )
RETURNS varchar(MAX) 
AS 

BEGIN
	declare @trimParameter varchar(MAX)=ltrim(rtrim(@parameter));
    DECLARE @return varchar(MAX);
	declare @position int =convert(int,(SELECT CHARINDEX('\', REVERSE (@trimParameter), 0)))
	set @return=substring (right(@trimParameter,@position),2,1000)
    RETURN @return;
END;
GO

---(0)---

IF OBJECT_ID (N'dbo.PathPart', N'FN') IS NOT NULL
    DROP FUNCTION PathPart;
GO
CREATE FUNCTION dbo.PathPart(@parameter varchar(MAX) )
RETURNS varchar(MAX) 
AS 

BEGIN
	declare @trimParameter varchar(MAX)=ltrim(rtrim(@parameter));
    DECLARE @return varchar(MAX);
	if ((len(@trimParameter) + 2 - convert(int,(SELECT CHARINDEX('\', REVERSE (@trimParameter), 0)))) < 0 )
	begin
		set @return=@trimParameter
	END
	ELSE
	BEGIN
		SET @return=substring(@trimParameter,0,len(@trimParameter) + 2 - convert(int,(SELECT CHARINDEX('\', REVERSE (@trimParameter), 0))))
	end
		RETURN @return;
END;
GO
*/

---(0)---
INSERT INTO [sma_MST_ScannedDocCategories] ( sctgsCategoryName )
(
SELECT DISTINCT
    cat.[name] as sctgsCategoryName 
	FROM [NeedlesNeosBisnarChase].[dbo].[documents] doc
	JOIN [NeedlesNeosBisnarChase].[dbo].[document_category] cat on doc.doc_category_id = cat.id
    UNION
SELECT 'Other'
)
    EXCEPT 
SELECT sctgsCategoryName FROM [sma_MST_ScannedDocCategories]
GO

ALTER TABLE [dbo].[sma_TRN_Documents]
ALTER column [docsToContact] [varchar](120) NULL
GO

----

IF NOT EXISTS (SELECT * FROM sys.columns WHERE Name = N'saga' AND Object_ID = Object_ID(N'sma_TRN_Documents'))
BEGIN
    ALTER TABLE [sma_TRN_Documents] ADD [saga] [varchar](50) NULL; 
END 
GO
----

ALTER TABLE [sma_TRN_Documents] DISABLE TRIGGER ALL
GO
SET QUOTED_IDENTIFIER  ON 

---(1)---


/*
alter table [sma_TRN_Documents] disable trigger all
delete from [sma_TRN_Documents] 
DBCC CHECKIDENT ('[sma_TRN_Documents]', RESEED, 0);
alter table [sma_TRN_Documents] enable trigger all
*/

INSERT INTO [sma_TRN_Documents]
([docnCaseID],[docsDocumentName],[docsDocumentPath],[docsDocumentData],[docnCategoryID],[docnSubCategoryID],[docnFromContactCtgID]
,[docnFromContactID],[docsToContact],[docsDocType],[docnTemplateID],[docbAttachFlag],[docsDescrptn],[docnAuthor],[docsDocsrflag]
,[docnRecUserID],[docdDtCreated],[docnModifyUserID],[docdDtModified],[docnLevelNo],[ctgnCategoryID],[sctnSubCategoryID],[sctssSubSubCategoryID]
,[sctsssSubSubSubCategoryID],[docnMedProvContactctgID],[docnMedProvContactID],[docnComments],[docnReasonReject],[docsReviewerContactId]
,[docsReviewDate],[docsDocumentAnalysisResultId],[docsIsReviewed],[docsToContactID],[docsToContactCtgID],[docdLastUpdated],[docnPriority],[saga])

SELECT 
    CAS.casnCaseID						as [docnCaseID], 
    doc.[file_name]						as [docsDocumentName],
    odi.web_url							as [docsDocumentPath],
    ''									as [docsDocumentData],
    null								as [docnCategoryID],
    null								as [docnSubCategoryID],
    auth.CTG							as [docnFromContactCtgID],
    auth.CID							as [docnFromContactID],
    null								as [docsToContact],
    'Doc'								as [docsDocType],
    null								as [docnTemplateID],
    null								as [docbAttachFlag],
    doc.[file_name]						as [docsDescrptn],
    0									as [docnAuthor],
    ''									as [docsDocsrflag],
    (select usrnUserID from sma_mst_users where saga = doc.staffcreatedid)	as [docnRecUserID],
    doc.date_created					as [docdDtCreated],
    (select usrnUserID from sma_mst_users where saga = doc.staffmodifiedid)	as [docnModifyUserID],
    doc.date_modified					as [docdDtModified],
    ''									as [docnLevelNo],
    case
	   when exists (select * FROM sma_MST_ScannedDocCategories where sctgsCategoryName = cat.[name]) 
		  then (select sctgnCategoryID FROM sma_MST_ScannedDocCategories where sctgsCategoryName = cat.[name])
	   else (select sctgnCategoryID FROM sma_MST_ScannedDocCategories where sctgsCategoryName='Other/Misc')
    end									as [ctgnCategoryID],
    null								as [sctnSubCategoryID],
    '','','','','','',null,null,null,null,null,null,GETDATE(),
    3									as [docnPriority],  -- normal priority
    convert(varchar(50),doc.id)			as [saga]
--SELECT *
FROM [NeedlesNeosBisnarChase].[dbo].[documents] DOC
JOIN [NeedlesNeosBisnarChase].[dbo].[one_drive_items] odi on doc.onedriveitemid = odi.id
LEFT JOIN [NeedlesNeosBisnarChase].[dbo].[document_category] cat on doc.doc_category_id = cat.id
LEFT JOIN IndvOrgContacts_Indexed auth on auth.saga = convert(varchar(50),doc.author)
JOIN [sma_TRN_Cases] CAS on CAS.Needles_saga = convert(varchar(50),DOC.cases_id)
GO


ALTER TABLE [sma_TRN_Documents] ENABLE TRIGGER ALL
GO

