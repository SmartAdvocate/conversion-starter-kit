USE   [SAbilleasterlyLaw]
GO

 

IF NOT EXISTS (Select * From sys.tables t join sys.columns c on t.object_id = c.object_id where t.name = 'sma_TRN_LitigationDiscovery' and c.name = 'saga')
BEGIN
	ALTER TABLE sma_TRN_LitigationDiscovery
	ADD saga varchar(50)
END
GO

/*ALTER TABLE sma_TRN_LitigationDiscovery
ALTER COLUMN SAGA varchar(50)
GO   */
--------------------------------------
--LITIGATION DISCOVERY TYPE
--------------------------------------
INSERT INTO sma_MST_DiscoveryType (dstsDescription, dstsDescriptionType)
SELECT DISTINCT g.code, g.code
FROM  [NeosBillEasterly]..NeosUserTab5 u
JOIN  [NeosBillEasterly]..mini_general_dir g on g.id = u.[Court Reporter]
WHERE isnull([Litigation Document],'') <>'' 
EXCEPT
SELECT dstsDescription, dstsDescriptionType FROM sma_MST_DiscoveryType
GO

--------------------------------------
--INSERT SERVICE TYPES
--------------------------------------
INSERT INTO sma_MST_ServiceTypes (sctsCode, sctsDscrptn)
SELECT NULL,'Unknown'
EXCEPT SELECT sctsCode, sctsDscrptn FROM sma_MST_ServiceTypes

--sp_help sma_TRN_LitigationDiscovery
--------------------------------------------
--INSERT LITIGATION DISCOVERY
--------------------------------------------
INSERT INTO sma_TRN_LitigationDiscovery (caseid, EnteredDt, typeid, MethodOfService, ServedByID, ResDescription, DemandOrder,
	OrderDt, OnDate, OnBeforeDt, WithinDays, FromDt, DtToComply, AppointmentID, RecUserID, ModifyUserID, DtModified, lidnRespondentType, saga)
SELECT DISTINCT
		cas.casnCaseID				as caseid, 
		NULL						as EnteredDt, 
		(select dstnDiscoveryTypeID From sma_MST_DiscoveryType where dstsDescription = g.Code)	as typeid, 
		(select sctnSrvcTypeID From sma_MST_ServiceTypes where sctsDscrptn = 'Unknown')						as MethodOfService, 
		NULL						as ServedByID, 
		isnull('Filed Date: '+ nullif(convert(varchar(max),u.[Filed Date]),''),'') +char(13) +
		isnull('Note: '+ nullif(convert(varchar(max),u.[Note]),''),'') +char(13) +
		isnull('All Counsel Copied: '+ nullif(convert(varchar(max),u.[All Counsel Copied]),''),'') +char(13) +
		isnull('Answered Date: '+ nullif(convert(varchar(max),u.[Answered Date]),''),'') +char(13) +
		isnull('Document Name: '+ nullif(convert(varchar(max),u.[Document Name]),''),'') +char(13) +
		isnull('Filing Party: '+ nullif(convert(varchar(max),ioc.[name]),''),'') +char(13) +
		isnull('Party Receiving: '+ nullif(convert(varchar(max),iocr.[name]),''),'') +char(13) +
		isnull('Medical Provider: '+ nullif(convert(varchar(max),iocp.[name]),''),'') +char(13) +
		isnull('Received Date: '+ nullif(convert(varchar(max),u.[Received Date]),''),'') +char(13) +
		isnull('Service Date: '+ nullif(convert(varchar(max),u.[Service Date]),''),'') +char(13) +
		''							as ResDescription,   --2000
		1							as DemandOrder,		--1=Demand; 2=Order
		[Service Date]				as OrderDt, 
		Case when u.[Service Date] between '1/1/1900' and '6/6/2079' then u.[Service Date] else NULL end	as OnDate, 
		NULL						as OnBeforeDt, 
		NULL						as WithinDays,
		NULL						as FromDt, 
		case when u.[Due Date] between '1/1/1900' and '6/6/2079' then u.[Due Date] else NULL end		as DtToComply,
		NULL						as AppointmentID, 
		368							as RecUserID, 
		NULL						as ModifyUserID, 
		NULL						as DtModified,
		NULL						as lidnRespondentType, 
		'Tab5: '+convert(varchar(50),tablistid)	as saga
--select *
FROM [NeosBillEasterly]..NeosUserTab5 u
JOIN [NeosBillEasterly]..mini_general_dir g on g.id = u.[Litigation Document]
JOIN sma_trn_Cases cas on CAS.Neos_saga = convert(varchar(50),u.casesid)
LEFT JOIN IndvorgContacts_Indexed ioc on ioc.saga_ref = convert(varchar(50),u.[Filing Party])
LEFT JOIN IndvorgContacts_Indexed iocp on iocp.saga_ref = convert(varchar(50),u.[Medical Provider])
LEFT JOIN IndvorgContacts_Indexed iocr on iocr.saga_ref = convert(varchar(50),u.[Party Receiving])
WHERE isnull([litigation document],'') <>''
	or isnull([document name],'') <> ''
GO

--------------------------
--INSERT COMPLIED DATE
--------------------------
INSERT INTO sma_TRN_DiscoveryDepositionRespondents (DiscoveryID, RespondentID, CSWDt, RecUserID, DtCreated, CSW)
SELECT
		ld.DiscoveryID		as DiscoveryID,
		null				as RespondentID,
		[Answered Date]		as CSWDt,
		368					as RecUserID,
		getdate()			as DtCreated,
		1					as CSW
FROM  [NeosBillEasterly]..NeosUserTab5 u
JOIN [NeosBillEasterly] ..mini_general_dir g on g.id = u.[Litigation Document]
JOIN sma_TRN_LitigationDiscovery ld on ld.saga = 'Tab5: '+convert(varchar(50),tablistid)
WHERE isnull(u.[Answered Date], '') <> ''
GO