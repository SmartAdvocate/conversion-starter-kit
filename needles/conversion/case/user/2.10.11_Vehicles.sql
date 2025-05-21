USE Schechter_SA
GO

--truncate table [sma_TRN_Vehicles]
/*
select case_id, Plate_Number, Plate_State, Drivers_License_Number, Drivers_License_State, Vehicle_YearMakeModel, Def_VehicleYrMakeModel, Def_Plate_Number, Def_Plate_State
from Schechter_Needles..user_tab6_data
where isnull(Vehicle_YearMakeModel,'') <> ''
or isnull(Def_VehicleYrMakeModel,'') <> ''
or isnull(Plate_Number,'') <> ''
or isnull(Plate_State, '') <> ''
or isnull(Def_Plate_Number,'') <>''
or isnull(Def_plate_State,'') <> ''
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
		ud.Drivers_License_Number,	--[vehsLicenceNo],  --varchar 25
		case when isnull(Drivers_License_state,'') <> '' then (select sttnStateID from sma_MST_States where sttsCode = ud.Drivers_License_State)
			else NULL end,					--[vehnLicenceStateID],
		NULL,					--[vehdLicExpDt],
		vm.vmknMakeID,			--[vehnVehicleMake],
		case when isnumeric(left(ud.Vehicle_YearMakeModel,4))=1 then left(ud.Vehicle_YearMakeModel,4) 
				when isnumeric(left(ud.Vehicle_YearMakeModel,2)) = 1 then left(ud.Vehicle_YearMakeModel,2) 
				else null end ,		--[vehnYear],  varchar 4
		vmo.vmdnModelID,		--[vehnModelID],
		NULL, 					--[vehnBodyTypeID],
		ud.Plate_Number,		--[vehsPlateNo],
		Plt_Vehicle_Color,		--[vehsColour],  30
		case when isnull(Plate_State,'') <> '' then (select sttnStateID from sma_MST_States where sttsCode = ud.Plate_State)
			else NULL End,					--[vehnVehicleStateID],
		plt_VIN_No,				--[vehsVINNo],   25
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
		isnull('Year/Make/Model: ' + nullif(convert(varchar(MAX),ud.Vehicle_YearMakeModel),'') + CHAR(13),'' ) + 
		isnull('Drivable: ' + nullif(convert(varchar(MAX),ud.Drivable),'') + CHAR(13),'' ) + 
		isnull('Air Bag Deployed? ' + nullif(convert(varchar(MAX),ud.Air_Bag_Deployed),'') + CHAR(13),'' ) + 
		isnull('Plt Wearing Seatbelt? ' + nullif(convert(varchar(MAX),ud.Plt_Wearing_Seatbelt),'') + CHAR(13),'' ) + 
		'', 					--[vehsComments],  200
		NULL, 					--[vehbPhotoAttached],
		368, 					--[vehnRecUserID],
		getdate(), 				--[vehdDtCreated],
		NULL, 					--[vehnModifyUserID],
		NULL, 					--[vehdDtModified],
		1						--[vehnLevelNo]
--Select ud.vehicle_yearmakemodel, vm.vmksDscrptn, vmo.vmdsModelDscrptn
FROM Schechter_Needles..user_tab6_data ud
JOIN sma_trn_Cases cas on cas.casscasenumber = convert(varchar,ud.[case_id])
LEFT JOIN sma_TRN_Plaintiff p on p.plnnCaseID = cas.casnCaseID and p.plnbIsPrimary = 1
LEFT JOIN sma_MST_VehicleMake vm ON ud.Vehicle_YearMakeModel like '%'+vm.vmksDscrptn+'%' 
LEFT JOIN sma_MST_VehicleModels vmo ON vmo.vmdnMakeID = vm.vmknMakeID and  ud.Vehicle_YearMakeModel like '%'+vmo.vmdsModelDscrptn+'%'
WHERE isnull(Vehicle_YearMakeModel,'') <> ''
or isnull(Drivers_License_state,'') <> ''
or isnull(Drivers_License_Number,'') <> ''
or isnull(plt_VIN_No,'') <> ''
or isnull(Plate_Number,'') <> ''
or isnull(Plate_State,'') <> ''


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
		ud.Def_DLID_Num,		--[vehsLicenceNo],  --varchar 25
		case when isnull(Def_DL_State,'') <> '' then (select sttnStateID from sma_MST_States where sttsCode = ud.Def_DL_State)
			else NULL end,		--[vehnLicenceStateID],
		NULL,					--[vehdLicExpDt],
		vm.vmknMakeID,			--[vehnVehicleMake],
		case when isnumeric(left(ud.Def_VehicleYrMakeModel,4))=1 then left(ud.Def_VehicleYrMakeModel,4) 
				when isnumeric(left(ud.Def_VehicleYrMakeModel,2)) = 1 then left(ud.Def_VehicleYrMakeModel,2) 
				else null end ,		--[vehnYear],  varchar 4
		vmo.vmdnModelID,		--[vehnModelID],
		NULL, 					--[vehnBodyTypeID],
		ud.Def_Plate_Number,	--[vehsPlateNo],
		null, 					--[vehsColour],  30
		case when isnull(Def_plate_state,'') <>'' then (select sttnStateID from sma_MST_States where sttsCode = ud.Def_plate_state)
			else NULL end,					--[vehnVehicleStateID],
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
		isnull('Year/Make/Model: ' + nullif(convert(varchar(MAX),ud.Def_VehicleYrMakeModel),'') + CHAR(13),'' ) + 
		isnull('Def Drivable: ' + nullif(convert(varchar(MAX),ud.Def_Drivable),'') + CHAR(13),'' ) + 
		isnull('Def Location of Damage: ' + nullif(convert(varchar(MAX),ud.Def_Location_of_Damage),'') + CHAR(13),'' ) + 
		isnull('Def Location of Vehicle: ' + nullif(convert(varchar(MAX),ud.Def_Location_of_Vehicle),'') + CHAR(13),'' ) + 
		'', 					--[vehsComments],  200
		NULL, 					--[vehbPhotoAttached],
		368, 					--[vehnRecUserID],
		getdate(), 				--[vehdDtCreated],
		NULL, 					--[vehnModifyUserID],
		NULL, 					--[vehdDtModified],
		1						--[vehnLevelNo]
--Select Def_DL_State, Def_Plate_State
FROM Schechter_Needles..user_tab6_data ud
JOIN sma_trn_Cases cas on cas.casscasenumber = convert(varchar,ud.[case_id])
LEFT JOIN sma_TRN_Defendants d on d.defnCaseID = cas.casnCaseID and d.defbIsPrimary = 1
LEFT JOIN sma_MST_VehicleMake vm ON ud.Def_VehicleYrMakeModel like '%'+vm.vmksDscrptn+'%' 
LEFT JOIN sma_MST_VehicleModels vmo ON vmo.vmdnMakeID = vm.vmknMakeID and  ud.Def_VehicleYrMakeModel like '%'+vmo.vmdsModelDscrptn+'%'
WHERE isnull(Def_VehicleYrMakeModel,'') <> ''
or isnull(Def_DLID_Num,'') <> ''
or isnull(Def_DL_State,'') <> ''
or isnull(Def_Plate_Number,'') <> ''
or isnull(Def_plate_state,'') <> ''