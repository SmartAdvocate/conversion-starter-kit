 USE   [SAbilleasterlyLaw]
GO
 
alter table [sma_trn_caseJudgeorClerk] disable trigger all
delete from [sma_trn_caseJudgeorClerk]
DBCC CHECKIDENT ('[sma_trn_caseJudgeorClerk]', RESEED, 0);
alter table [sma_trn_caseJudgeorClerk] enable trigger all

alter table [sma_TRN_CourtDocket] disable trigger all
delete from [sma_TRN_CourtDocket]
DBCC CHECKIDENT ('[sma_TRN_CourtDocket]', RESEED, 0);
alter table [sma_TRN_CourtDocket] enable trigger all

alter table [sma_TRN_Courts] disable trigger all
delete from [sma_TRN_Courts]
DBCC CHECKIDENT ('[dbo].[sma_TRN_Courts]', RESEED, 0);
alter table [sma_TRN_Courts] enable trigger all
 

---
ALTER TABLE [sma_trn_caseJudgeorClerk] DISABLE TRIGGER ALL
GO
ALTER TABLE [sma_TRN_CourtDocket] DISABLE TRIGGER ALL
GO
ALTER TABLE [sma_TRN_Courts] DISABLE TRIGGER ALL
GO
---
--select * from  [sma_TRN_Courts] 
/*
select * 
FROM [NeosBillEasterly] .[dbo].[cases] C
WHERE isnull(convert(varchar(50),court_namesid),'')<>''
or isnull(convert(varchar(50),judge_namesid),'')<>''
or isnull(docket,'') <> ''
*/


---(1)---
INSERT INTO [sma_TRN_Courts] 
( 
	crtnCaseID,
	crtnCourtID,
	crtnCourtAddId,
	crtnIsActive
	--crtnLevelNo 
)
SELECT  
	A.casnCaseID	as crtnCaseID, 
	A.CID		    as crtnCourtID, 
	A.AID		    as crtnCourtAddId,  
	1			    as crtnIsActive
FROM (	  SELECT 
			           CAS.casnCaseID,
		            	IOC.CID,
		            	IOC.AID
			         --C.judge_link  
		     --select *
	        	FROM  [NeosBillEasterly].[dbo].[cases] C
	            JOIN    [sma_TRN_cases] CAS on CAS.Neos_Saga = convert(varchar(50),C.id)
		        JOIN    IndvOrgContacts_Indexed IOC on IOC.saga_ref = convert(varchar(50),C.court_Namesid)
	        	WHERE isnull(convert(varchar(50),C.court_Namesid),'') <> ''
 
		    UNION  

	      	SELECT 
		          	CAS.casnCaseID,
		        	IOC.CID,
		        	IOC.AID  
		    	--C.judge_link
		   FROM  [NeosBillEasterly] .[dbo].[cases_Indexed] C
	    	JOIN    [sma_TRN_cases] CAS on CAS.Neos_Saga = C.id
		    JOIN    IndvOrgContacts_Indexed IOC on IOC.SAGA= '-1' and IOC.[Name]='Unidentified Court' 
		  WHERE     isnull(convert(varchar(50),court_namesid),'')=''
		            and ( isnull(convert(varchar(50),judge_namesid),'')<>''   or     isnull(docket,'') <> '' )
			     	 
) A
GO

---------------------------------------------------
--UPDATE COURT CAPTION FIELDS
---------------------------------------------------
UPDATE sma_TRN_Courts
SET crtsPlaintiffCaption = c.[Plaintiff Caption],
	crtsDefendantCaption = c.[Defendant Caption] 
---select *	 
FROM [NeosBillEasterly] ..NeosUserCase c
JOIN [sma_TRN_cases] CAS on CAS.Neos_Saga = convert(varchar(50),C.casesid) 
JOIN sma_trn_Courts crt on crt.crtnCaseID = cas.casnCaseID
GO

--------------------
--COURT DOCKET
--------------------
INSERT INTO [sma_TRN_CourtDocket] 
( 
	crdnCourtsID,
	crdnIndexTypeID,
	crdnDocketNo,
	crdddate,
	crdnPrice,
	crdbActiveInActive,
	crdsEfile,
	crdsComments
) 
SELECT 
    crtnPKCourtsID	    as crdnCourtsID,
    (select idtnIndexTypeID from sma_MST_IndexType where idtsDscrptn='Docket Number') 
						as crdnIndexTypeID,

    case     when isnull(C.docket,'')<>'' then        left(C.docket,30)   
	            else 'Case-' + CAS.cassCaseNumber
    end					as crdnDocketNo, 

	NULL				as crdddate,
	0  					as crdnPrice,
	1					as crdbActiveInActive,
	0					as crdsEfile,
    'Docket Number:' + left(C.docket,30) 
						as crdsComments
FROM [sma_TRN_Courts] CRT
JOIN [sma_TRN_cases] CAS on CAS.casnCaseID=CRT.crtnCaseID 
JOIN  [NeosBillEasterly].[dbo].[cases_indexed] C on convert(varchar(50),c.id) = CAS.Neos_Saga
GO


--------------------------
--INSERT JUDGE
--------------------------
INSERT INTO [sma_trn_caseJudgeorClerk] 
( 
	crtDocketID,
	crtJudgeorClerkContactID,
	crtJudgeorClerkContactCtgID,
	crtJudgeorClerkRoleID
) 
SELECT DISTINCT
	CRD.crdnCourtDocketID	as crtDocketID,
	IOC.CID				as crtJudgeorClerkContactID,
	IOC.CTG				as crtJudgeorClerkContactCtgID,
	(select octnOrigContactTypeID from sma_MST_OriginalContactTypes where octsDscrptn='Judge') as crtJudgeorClerkRoleID 
FROM [sma_TRN_CourtDocket] CRD
JOIN [sma_TRN_Courts] CRT on CRT.crtnPKCourtsID=CRD.crdnCourtsID  
JOIN sma_trn_Cases cas on cas.casnCaseID = crt.crtnCaseID
JOIN  [NeosBillEasterly]..[cases_indexed] ci on convert(varchar(50),ci.id) = cas.Neos_Saga
JOIN IndvOrgContacts_Indexed IOC on IOC.saga_ref= convert(varchar(50), ci.judge_namesid)

ALTER TABLE [sma_trn_caseJudgeorClerk] enable TRIGGER ALL
GO
ALTER TABLE [sma_TRN_CourtDocket] enable TRIGGER ALL
GO
ALTER TABLE [sma_TRN_Courts] enable TRIGGER ALL
GO