
use   [SAbilleasterlyLaw]
go

 
alter table [sma_TRN_Documents] disable trigger all
delete from [sma_TRN_Documents] 
DBCC CHECKIDENT ('[sma_TRN_Documents]', RESEED, 0);
alter table [sma_TRN_Documents] enable trigger all
 


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
/*INSERT INTO [sma_MST_ScannedDocCategories] ( sctgsCategoryName )
(
SELECT DISTINCT
    cat.[name] as sctgsCategoryName 
	FROM [NeosBrianWhite].[dbo].[documents] doc
	JOIN [NeosBrianWhite].[dbo].[document_category] cat on doc.doc_category_id = cat.id
    UNION
SELECT 'Other'
)
    EXCEPT 
SELECT sctgsCategoryName FROM [sma_MST_ScannedDocCategories]
GO   */

 

-------   This query compares data from the case_document_category table in the NeosBillEasterly database with the sma_MST_ScannedDocCategories table. It inserts new categories that are not already present in the target table
 MERGE INTO [sma_MST_ScannedDocCategories] AS target
USING (
    SELECT DISTINCT id, name
    FROM [NeosBillEasterly].[dbo].[case_document_category]      
) AS source
ON target.sctgsCategoryName = source.name  
WHEN NOT MATCHED BY TARGET THEN
    INSERT (sctgsCategoryName, sctgdDtCreated)
    VALUES (source.name, GETDATE());
go

 
------------------


/*ALTER TABLE [dbo].[sma_TRN_Documents]
ALTER column [docsToContact] [varchar](120) NULL
GO   */

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

SELECT distinct 
    CAS.casnCaseID						as [docnCaseID], 
    ''  as [docsDocumentName],
    case  when  df.field_title ='File Path' then doc.data
	         else  ''
	end as [docsDocumentPath]    ,
   ''									as [docsDocumentData],
    null								as [docnCategoryID],
    null								as [docnSubCategoryID],
    auth.CTG							as [docnFromContactCtgID],
    auth.CID							as [docnFromContactID],
    null								as [docsToContact],
    'Doc'								as [docsDocType],
    null								as [docnTemplateID],
    null								as [docbAttachFlag],
    ''               					as [docsDescrptn],
    0									as [docnAuthor],
    ''									as [docsDocsrflag],
   '' /* (select usrnUserID from sma_mst_users where saga = doc.staffcreatedid)	*/ as [docnRecUserID],
   ''   /*doc.date_created		*/			as [docdDtCreated],
  '' /* (select usrnUserID from sma_mst_users where saga = doc.staffmodifiedid)  */	as [docnModifyUserID],
    doc.last_modified					as [docdDtModified],
    ''									as [docnLevelNo],
    case
	       when exists (select * FROM sma_MST_ScannedDocCategories where sctgsCategoryName  =   cdc.name ) 
		                                        then (select sctgnCategoryID FROM sma_MST_ScannedDocCategories where sctgsCategoryName = cdc.[name])
	      else (select sctgnCategoryID FROM sma_MST_ScannedDocCategories where sctgsCategoryName='Other')
    end								as [ctgnCategoryID],
    null								as [sctnSubCategoryID],
    '','','','','','',null,null,null,null,null,null,GETDATE(),
    3									as [docnPriority],  -- normal priority
    convert(varchar(50),doc.id)			as [saga]      
--SELECT *
FROM [NeosBillEasterly].[dbo].[case_document_data]  DOC
left join [NeosBillEasterly].[dbo].[case_document_category] cdc on cdc.id = doc.picklistid
left join  [NeosBillEasterly].[dbo].[case_document_list]  odi on doc.tablistid   = odi.id
left join [NeosBillEasterly].[dbo].user_doc_fields df on df.id = doc.userdocumentfieldid
left  JOIN IndvOrgContacts_Indexed auth on auth.saga_ref = convert(varchar(50),doc.namesid)
JOIN [sma_TRN_Cases] CAS on CAS.Neos_Saga = convert(varchar(50),odi.casesid)
order by cas.casnCaseID
GO


ALTER TABLE [sma_TRN_Documents] ENABLE TRIGGER ALL
GO

