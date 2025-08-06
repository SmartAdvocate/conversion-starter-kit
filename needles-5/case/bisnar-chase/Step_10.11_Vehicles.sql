USE SA
GO

--truncate table [sma_TRN_Vehicles]
/*

select  td.casesid, ucf.field_title, ucf.field_type, ucf.field_len, td.[data] as FieldData
from [NeedlesNeosBisnarChase]..user_tab6_data td
JOIN [NeedlesNeosBisnarChase]..user_case_fields ucf on ucf.id = td.usercasefieldid
where field_Title in ('Def Vehicle Yr/Make/Model','Pl Vehicle Yr/Make/Model','Plt License Plate No.','Plt Plate State','Plt Vehicle Color')
order by ucf.field_title

select  td.casesid, ucf.field_title, td.[data] as FieldData, 
case when isnumeric(left(td.[data],4) )=1 then left(td.[data],4) else '' end VehicleYear
from [NeedlesNeosBisnarChase]..user_tab6_data td
JOIN [NeedlesNeosBisnarChase]..user_case_fields ucf on ucf.id = td.usercasefieldid
where field_Title in ('Def Vehicle Yr/Make/Model','Pl Vehicle Yr/Make/Model')
*/
-------------------------------
--INSERT VEHICLE MAKES
-------------------------------
/*
INSERT INTO sma_MST_VehicleMake (vmksDscrptn)
SELECT DISTINCT [Make]
EXCEPT
SELECT vmksDscrptn from sma_MST_VehicleMake

-------------------------------
--INSERT VEHICLE MODELS
-------------------------------
INSERT INTO sma_MST_VehicleModels (vmdnMakeID, vmdsModelDscrptn)
SELECT DISTINCT (select vmknMakeID From sma_MST_VehicleMake where vmksDscrptn=[Make]), model
FROM CasePeerSheehan..Carpropertydamage 
WHERE isnull([Model],'') <>''
EXCEPT SELECT vmdnMakeID, vmdsModelDscrptn FROM sma_MST_VehicleModels
*/
/*
ALTER TABLE sma_trn_Vehicles
ALTER COLUMN vehsComments varchar(300)
GO

ALTER TABLE sma_trn_Vehicles
ALTER column vehsLicenceNo varchar(25);
GO
*/
---------------------------------------------------------
--PLAINTIFF VEHICLE INFORMATION
---------------------------------------------------------
INSERT INTO [sma_TRN_Vehicles]
	([vehnCaseID],[vehbIsPlaintiff],[vehnPlntDefID],[vehnOwnerID],[vehnOwnerCtg],[vehnRegistrantID],[vehnRegistrantCtg],[vehnOperatorID],[vehnOperatorCtg],[vehsLicenceNo],[vehnLicenceStateID],[vehdLicExpDt]
	,[vehnVehicleMake],[vehnYear],[vehnModelID],[vehnBodyTypeID],[vehsPlateNo],[vehsColour],[vehnVehicleStateID],[vehsVINNo],[vehdRegExpDt],[vehnIsLeased],[vehnDamageClaim],[vehdEstReqdOn],[vehdEstRecvdOn],[vehdPhotoReqdOn]
	,[vehdPhotoRecvdOn],[vehbRepairs],[vehbTotalLoss],[vehnCostOfRepairs],[vehnValueBefAcdnt],[vehnRentalExpense],[vehnOthExpense],[vehnSalvage],[vehnTLRentalExpense],[vehnTLOthExpense],[vehnLoss],[vehnNetLoss],[vehnLicenseHistory]
	,[vehnPlateSearch],[vehnTitlesearch],[vehnMV104],[vehdOprLicHistory],[vehdPlateSearchOn],[vehdTitleSearchOn],[vehdMV104On],[vehdOprLicHistoryRecd],[vehdPlateSearchOnRecd],[vehdTitleSearchOnRecd],[vehdMV104OnRecd],[vehsComments]
	,[vehbPhotoAttached],[vehnRecUserID],[vehdDtCreated],[vehnModifyUserID],[vehdDtModified],[vehnLevelNo])
SELECT DISTINCT
		cas.casnCaseID,			--[vehnCaseID],
		1,		--case when isnull(cpd.defendant,'') ='' then 1 else 0 end,					--[vehbIsPlaintiff],
		p.plnnPlaintiffID,		--[vehnPlntDefID],
		NULL,					--[vehnOwnerID],
		NULL, 					--[vehnOwnerCtg],
		NULL, 					--[vehnRegistrantID],
		NULL,					--[vehnRegistrantCtg],
		NULL, 					--[vehnOperatorID],
		NULL, 					--[vehnOperatorCtg],
		NULL,					--[vehsLicenceNo],  --varchar 25
		NULL,					--[vehnLicenceStateID],
		NULL,					--[vehdLicExpDt],
		vm.vmknMakeID,			--[vehnVehicleMake],
		case when isnumeric(left(ymm.[data],4) )=1 then left(ymm.[data],4) else '' end ,		--[vehnYear],  varchar 4
		vmo.vmdnModelID,		--[vehnModelID],
		NULL, 					--[vehnBodyTypeID],
		lpn.[data],				--[vehsPlateNo],
		vc.[data],				--[vehsColour],  30
		case when isnull(ps.[data],'') <> '' then (select sttnStateID from sma_MST_States where sttsCode = ps.[data])
			else NULL End,					--[vehnVehicleStateID],
		vn.[data],				--[vehsVINNo],   25
		NULL,					--[vehdRegExpDt],
		NULL, 					--[vehnIsLeased],
		NULL,					--[vehnDamageClaim],
		NULL, 					--[vehdEstReqdOn],
		NULL, 					--[vehdEstRecvdOn],
		NULL, 					--[vehdPhotoReqdOn],
		NULL, 					--[vehdPhotoRecvdOn],
		NULL, 					--[vehbRepairs],
		NULL, 					--[vehbTotalLoss],
		NULL, 					--[vehnCostOfRepairs],
		NULL, 					--[vehnValueBefAcdnt],
		NULL, 					--[vehnRentalExpense],
		NULL, 					--[vehnOthExpense],
		NULL, 					--[vehnSalvage],
		NULL, 					--[vehnTLRentalExpense],
		NULL, 					--[vehnTLOthExpense],
		NULL, 					--[vehnLoss],
		NULL, 					--[vehnNetLoss],
		NULL, 					--[vehnLicenseHistory],
		NULL, 					--[vehnPlateSearch],
		NULL, 					--[vehnTitlesearch],
		NULL, 					--[vehnMV104],
		NULL, 					--[vehdOprLicHistory],
		NULL, 					--[vehdPlateSearchOn],
		NULL, 					--[vehdTitleSearchOn],
		NULL, 					--[vehdMV104On],
		NULL, 					--[vehdOprLicHistoryRecd],
		NULL, 					--[vehdPlateSearchOnRecd],
		NULL, 					--[vehdTitleSearchOnRecd],
		NULL, 					--[vehdMV104OnRecd],
		isnull('Year/Make/Model: ' + nullif(convert(varchar(MAX),ymm.[data]),'') + CHAR(13),'' ) + 
		'', 					--[vehsComments],  200
		NULL, 					--[vehbPhotoAttached],
		368, 					--[vehnRecUserID],
		getdate(), 				--[vehdDtCreated],
		NULL, 					--[vehnModifyUserID],
		NULL, 					--[vehdDtModified],
		1						--[vehnLevelNo]
--Select ymm.[data], vm.vmksDscrptn, vmo.vmdsModelDscrptn
FROM NeedlesNeosBisnarChase..cases_Indexed ud
JOIN sma_trn_Cases cas on cas.Needles_saga = convert(varchar(50),ud.id)
LEFT JOIN sma_TRN_Plaintiff p on p.plnnCaseID = cas.casnCaseID and p.plnbIsPrimary = 1
LEFT JOIN (select td.casesid, td.[data]
		from [NeedlesNeosBisnarChase]..user_tab6_data td
		JOIN [NeedlesNeosBisnarChase]..user_case_fields ucf on ucf.id = td.usercasefieldid
		where field_Title in ('Pl Vehicle Yr/Make/Model') ) ymm on ymm.casesid = ud.id
LEFT JOIN (select td.casesid, td.[data]
		from [NeedlesNeosBisnarChase]..user_tab6_data td
		JOIN [NeedlesNeosBisnarChase]..user_case_fields ucf on ucf.id = td.usercasefieldid
		where field_Title in ('Plt License Plate No.') ) lpn on lpn.casesid = ud.id	
LEFT JOIN (select td.casesid, td.[data]
		from [NeedlesNeosBisnarChase]..user_tab6_data td
		JOIN [NeedlesNeosBisnarChase]..user_case_fields ucf on ucf.id = td.usercasefieldid
		where field_Title in ('Plt Plate State') ) ps on ps.casesid = ud.id
LEFT JOIN (select td.casesid, td.[data]
		from [NeedlesNeosBisnarChase]..user_tab6_data td
		JOIN [NeedlesNeosBisnarChase]..user_case_fields ucf on ucf.id = td.usercasefieldid
		where field_Title in ('Plt Vehicle Color') ) vc on vc.casesid = ud.id
LEFT JOIN (select td.casesid, td.[data]
		from [NeedlesNeosBisnarChase]..user_tab6_data td
		JOIN [NeedlesNeosBisnarChase]..user_case_fields ucf on ucf.id = td.usercasefieldid
		where field_Title in ('VIN') ) vn on vn.casesid = ud.id
LEFT JOIN sma_MST_VehicleMake vm ON ymm.[data] like case when vm.vmksdscrptn like '%chevr%' then '%Chev%' 
														when vm.vmksdscrptn like '%merce%' then '%Merce%' 
														else '%'+vm.vmksDscrptn+'%' end
LEFT JOIN sma_MST_VehicleModels vmo ON vmo.vmdnMakeID = vm.vmknMakeID and  ymm.[data] like '%'+vmo.vmdsModelDscrptn+'%'
WHERE isnull(ymm.[data],'') <> ''
or isnull(lpn.[data],'') <> ''
or isnull(ps.[data],'') <> ''
or isnull(vc.[data],'') <> ''



---------------------------------------------------------
--Defendant Vehicle Information
---------------------------------------------------------
INSERT INTO [sma_TRN_Vehicles]
	([vehnCaseID],[vehbIsPlaintiff],[vehnPlntDefID],[vehnOwnerID],[vehnOwnerCtg],[vehnRegistrantID],[vehnRegistrantCtg],[vehnOperatorID],[vehnOperatorCtg],[vehsLicenceNo],[vehnLicenceStateID],[vehdLicExpDt]
	,[vehnVehicleMake],[vehnYear],[vehnModelID],[vehnBodyTypeID],[vehsPlateNo],[vehsColour],[vehnVehicleStateID],[vehsVINNo],[vehdRegExpDt],[vehnIsLeased],[vehnDamageClaim],[vehdEstReqdOn],[vehdEstRecvdOn],[vehdPhotoReqdOn]
	,[vehdPhotoRecvdOn],[vehbRepairs],[vehbTotalLoss],[vehnCostOfRepairs],[vehnValueBefAcdnt],[vehnRentalExpense],[vehnOthExpense],[vehnSalvage],[vehnTLRentalExpense],[vehnTLOthExpense],[vehnLoss],[vehnNetLoss],[vehnLicenseHistory]
	,[vehnPlateSearch],[vehnTitlesearch],[vehnMV104],[vehdOprLicHistory],[vehdPlateSearchOn],[vehdTitleSearchOn],[vehdMV104On],[vehdOprLicHistoryRecd],[vehdPlateSearchOnRecd],[vehdTitleSearchOnRecd],[vehdMV104OnRecd],[vehsComments]
	,[vehbPhotoAttached],[vehnRecUserID],[vehdDtCreated],[vehnModifyUserID],[vehdDtModified],[vehnLevelNo])
SELECT DISTINCT
		cas.casnCaseID,			--[vehnCaseID],
		0,		--case when isnull(cpd.defendant,'') ='' then 1 else 0 end,					--[vehbIsPlaintiff],
		d.defnDefendentID,		--[vehnPlntDefID],
		NULL,					--[vehnOwnerID],
		NULL, 					--[vehnOwnerCtg],
		NULL, 					--[vehnRegistrantID],
		NULL,					--[vehnRegistrantCtg],
		NULL, 					--[vehnOperatorID],
		NULL, 					--[vehnOperatorCtg],
		NULL,					--[vehsLicenceNo],  --varchar 25
		NULL,					--[vehnLicenceStateID],
		NULL,					--[vehdLicExpDt],
		vm.vmknMakeID,			--[vehnVehicleMake],
		case when isnumeric(left(ymm.[data],4) )=1 then left(ymm.[data],4) else '' end,		--[vehnYear],  varchar 4
		vmo.vmdnModelID,		--[vehnModelID],
		NULL, 					--[vehnBodyTypeID],
		NULL,					--[vehsPlateNo],
		null, 					--[vehsColour],  30
		NULL,					--[vehnVehicleStateID],
		null,					--[vehsVINNo],   25
		NULL,					--[vehdRegExpDt],
		NULL, 					--[vehnIsLeased],
		NULL,					--[vehnDamageClaim],
		NULL, 					--[vehdEstReqdOn],
		NULL, 					--[vehdEstRecvdOn],
		NULL, 					--[vehdPhotoReqdOn],
		NULL, 					--[vehdPhotoRecvdOn],
		NULL, 					--[vehbRepairs],
		NULL, 					--[vehbTotalLoss],
		NULL, 					--[vehnCostOfRepairs],
		NULL, 					--[vehnValueBefAcdnt],
		NULL, 					--[vehnRentalExpense],
		NULL, 					--[vehnOthExpense],
		NULL, 					--[vehnSalvage],
		NULL, 					--[vehnTLRentalExpense],
		NULL, 					--[vehnTLOthExpense],
		NULL, 					--[vehnLoss],
		NULL, 					--[vehnNetLoss],
		NULL, 					--[vehnLicenseHistory],
		NULL, 					--[vehnPlateSearch],
		NULL, 					--[vehnTitlesearch],
		NULL, 					--[vehnMV104],
		NULL, 					--[vehdOprLicHistory],
		NULL, 					--[vehdPlateSearchOn],
		NULL, 					--[vehdTitleSearchOn],
		NULL, 					--[vehdMV104On],
		NULL, 					--[vehdOprLicHistoryRecd],
		NULL, 					--[vehdPlateSearchOnRecd],
		NULL, 					--[vehdTitleSearchOnRecd],
		NULL, 					--[vehdMV104OnRecd],
		isnull('Year/Make/Model: ' + nullif(convert(varchar(MAX),ymm.[data]),'') + CHAR(13),'' ) + 
		'', 					--[vehsComments],  200
		NULL, 					--[vehbPhotoAttached],
		368, 					--[vehnRecUserID],
		getdate(), 				--[vehdDtCreated],
		NULL, 					--[vehnModifyUserID],
		NULL, 					--[vehdDtModified],
		1						--[vehnLevelNo]
--Select *
FROM NeedlesNeosBisnarChase..cases_Indexed ud
JOIN sma_trn_Cases cas on cas.Needles_saga = convert(varchar(50),ud.id)
LEFT JOIN sma_TRN_Defendants d on d.defnCaseID = cas.casnCaseID and d.defbIsPrimary = 1
LEFT JOIN (select td.casesid, td.[data]
		from [NeedlesNeosBisnarChase]..user_tab6_data td
		JOIN [NeedlesNeosBisnarChase]..user_case_fields ucf on ucf.id = td.usercasefieldid
		where field_Title in ('Def Vehicle Yr/Make/Model') ) ymm on ymm.casesid = ud.id
LEFT JOIN sma_MST_VehicleMake vm ON ymm.[data] like case when vm.vmksdscrptn like '%chevr%' then '%Chev%' 
														when vm.vmksdscrptn like '%merce%' then '%Merce%' 
														else '%'+vm.vmksDscrptn+'%' end
LEFT JOIN sma_MST_VehicleModels vmo ON vmo.vmdnMakeID = vm.vmknMakeID and  ymm.[data] like '%'+vmo.vmdsModelDscrptn+'%'
WHERE isnull(ymm.[data],'') <> ''

