USE   [SAbilleasterlyLaw]
GO

 

 --------------------------------
 ------------ Create CTE table to split     [Year/Make/Model:]  [Vehicle Year/Make/Model] columns
 ---------------------------
 /*with CTE
 as
 (
   SELECT 
    casesid, 
    [Year/Make/Model:], 

    -- Extract Year from [Year/Make/Model:]
    LTRIM(RTRIM(
        CASE 
            WHEN CHARINDEX('/', [Year/Make/Model:]) > 0 THEN 
                LEFT([Year/Make/Model:], CHARINDEX('/', [Year/Make/Model:]) - 1)
            WHEN CHARINDEX(' ', [Year/Make/Model:]) > 0 THEN 
                LEFT([Year/Make/Model:], CHARINDEX(' ', [Year/Make/Model:] + ' ') - 1)
            ELSE 
                [Year/Make/Model:]
        END
    )) AS [Year_YearMakeModel],

    -- Extract Make from [Year/Make/Model:]
    LTRIM(RTRIM(
        CASE 
            WHEN CHARINDEX('/', [Year/Make/Model:]) > 0 THEN 
                PARSENAME(REPLACE([Year/Make/Model:], '/', '.'), 2)
            ELSE 
                SUBSTRING([Year/Make/Model:], CHARINDEX(' ', [Year/Make/Model:]) + 1, CHARINDEX(' ', [Year/Make/Model:] + ' ', CHARINDEX(' ', [Year/Make/Model:]) + 1) - CHARINDEX(' ', [Year/Make/Model:]) - 1)
        END
    )) AS [Make_YearMakeModel],

    -- Extract Model from [Year/Make/Model:]
    LTRIM(RTRIM(
        CASE 
            WHEN CHARINDEX('/', [Year/Make/Model:]) > 0 THEN 
                PARSENAME(REPLACE([Year/Make/Model:], '/', '.'), 1)
            ELSE 
                SUBSTRING([Year/Make/Model:], CHARINDEX(' ', [Year/Make/Model:], CHARINDEX(' ', [Year/Make/Model:]) + 1) + 1, LEN([Year/Make/Model:]))
        END
    )) AS [Model_YearMakeModel],

    [Vehicle Year/Make/Model],

    -- Extract Year from [Vehicle Year/Make/Model]
    LTRIM(RTRIM(
        CASE 
            WHEN CHARINDEX('/', [Vehicle Year/Make/Model]) > 0 THEN 
                LEFT([Vehicle Year/Make/Model], CHARINDEX('/', [Vehicle Year/Make/Model]) - 1)
            WHEN CHARINDEX(' ', [Vehicle Year/Make/Model]) > 0 THEN 
                LEFT([Vehicle Year/Make/Model], CHARINDEX(' ', [Vehicle Year/Make/Model] + ' ') - 1)
            ELSE 
                [Vehicle Year/Make/Model]
        END
    )) AS [Year_VehicleYearMakeModel],

    -- Extract Make from [Vehicle Year/Make/Model]
    LTRIM(RTRIM(
        CASE 
            WHEN CHARINDEX('/', [Vehicle Year/Make/Model]) > 0 THEN 
                PARSENAME(REPLACE([Vehicle Year/Make/Model], '/', '.'), 2)
            ELSE 
                SUBSTRING([Vehicle Year/Make/Model], CHARINDEX(' ', [Vehicle Year/Make/Model]) + 1, CHARINDEX(' ', [Vehicle Year/Make/Model] + ' ', CHARINDEX(' ', [Vehicle Year/Make/Model]) + 1) - CHARINDEX(' ', [Vehicle Year/Make/Model]) - 1)
        END
    )) AS [Make_VehicleYearMakeModel],

    -- Extract Model from [Vehicle Year/Make/Model]
    LTRIM(RTRIM(
        CASE 
            WHEN CHARINDEX('/', [Vehicle Year/Make/Model]) > 0 THEN 
                PARSENAME(REPLACE([Vehicle Year/Make/Model], '/', '.'), 1)
            ELSE 
                SUBSTRING([Vehicle Year/Make/Model], CHARINDEX(' ', [Vehicle Year/Make/Model], CHARINDEX(' ', [Vehicle Year/Make/Model]) + 1) + 1, LEN([Vehicle Year/Make/Model]))
        END
    )) AS [Model_VehicleYearMakeModel]

FROM [NeosBillEasterly].[dbo].[NeosUserTab6]

-- WHERE Clause
WHERE 
    -- Validate Year length (2 or 4) and avoid invalid substring errors
    LEN(
        CASE 
            WHEN CHARINDEX('/', [Year/Make/Model:]) > 0 THEN 
                LEFT([Year/Make/Model:], CHARINDEX('/', [Year/Make/Model:]) - 1)
            WHEN CHARINDEX(' ', [Year/Make/Model:]) > 0 THEN 
                LEFT([Year/Make/Model:], CHARINDEX(' ', [Year/Make/Model:] + ' ') - 1)
            ELSE 
                [Year/Make/Model:]
        END
    ) IN (2, 4)

    -- Exclude NULL or empty rows
    AND (ISNULL([Year/Make/Model:], '') <> '' 
         OR ISNULL([Vehicle Year/Make/Model], '') <> '') 

 )
 
     select *
     into  CTE1
     from CTE

 SELECT * 
FROM cte1 
WHERE CAST(casesid AS VARCHAR(36)) = 'FB643AC3-DF83-4C83-A865-AA450120FCB7';


-------------------------------
--INSERT VEHICLE MAKES
-------------------------------
 
---INSERT INTO sma_MST_VehicleMake (vmksDscrptn)
INSERT INTO sma_MST_VehicleMake (vmksDscrptn)
SELECT DISTINCT make_YearMakeModel 
FROM  CTE1
WHERE ISNUMERIC(make_YearMakeModel) = 0 -- Exclude numeric values
UNION 
SELECT DISTINCT make_VehicleYearMakeModel 
FROM CTE1
WHERE ISNUMERIC(make_VehicleYearMakeModel) = 0 -- Exclude numeric values
EXCEPT
SELECT vmksDscrptn 
FROM sma_MST_VehicleMake;
 

-------------------------------
--INSERT VEHICLE MODELS
-------------------------------
 INSERT INTO sma_MST_VehicleModels (vmdsModelDscrptn )
SELECT DISTINCT model_YearMakeModel  FROM  CTE1
 UNION 
SELECT DISTINCT model_VehicleYearMakeModel  FROM CTE1
EXCEPT
SELECT vmdsModelDscrptn 
FROM sma_MST_VehicleModels;
go  */
 ---------------------------------------------------
 alter table [sma_TRN_Vehicles]  disable trigger all
delete  [sma_TRN_Vehicles]
DBCC CHECKIDENT ('[sma_TRN_Vehicles]', RESEED, 0);
alter table [sma_TRN_Vehicles]  enable trigger all
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
		NULL, 					--[vehnOwnerCtg]         5,
		NULL, 					--[vehnRegistrantID],
		NULL,					--[vehnRegistrantCtg],
		NULL, 					--[vehnOperatorID],
		NULL, 					--[vehnOperatorCtg],
		NULL,					--[vehsLicenceNo]              10,  --varchar 25
		NULL,					--[vehnLicenceStateID],
		NULL,					--[vehdLicExpDt],
	 
		null, 
		null,
		null,
		NULL, 					--[vehnBodyTypeID],
		null,					--[vehsPlateNo],
		null,					--[vehsColour],  30
		null,					--[vehnVehicleStateID],
		null,					--[vehsVINNo],   20
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
		case when  isnull(ud.[Year/Make/Model:], '') <> '' then  'Year/Make/Model:  ' + ud.[Year/Make/Model:]  
	        	else  ''
		end  , 					--[vehsComments],  200
		NULL, 					--[vehbPhotoAttached],
		368, 					--[vehnRecUserID],
		getdate(), 				--[vehdDtCreated],
		NULL, 					--[vehnModifyUserID],
		NULL, 					--[vehdDtModified],
		1						--[vehnLevelNo]
--Select *
FROM  [NeosBillEasterly]..neosuserTab6 ud
JOIN sma_trn_Cases cas on cas.Neos_saga = convert(varchar(50),ud.casesid)
LEFT JOIN sma_TRN_Plaintiff p on p.plnnCaseID = cas.casnCaseID and p.plnbIsPrimary = 1
GO
 
---------------------------------------------------------
--DEFENDANT VEHICLE INFORMATION
---------------------------------------------------------
 INSERT INTO sma_TRN_Vehicles
(
    [vehnCaseID]             -- Case ID from the sma_trn_Cases table
    ,[vehbIsPlaintiff]       -- Indicates whether the vehicle is associated with a plaintiff
    ,[vehnPlntDefID]         -- Plaintiff or defendant ID from the sma_TRN_Defendants table
    ,[vehnOwnerID]           -- Vehicle owner ID (currently NULL)
    ,[vehnOwnerCtg]          -- Vehicle owner category (currently NULL)
    ,[vehnRegistrantID]      -- Registrant ID (currently NULL)
    ,[vehnRegistrantCtg]     -- Registrant category (currently NULL)
    ,[vehnOperatorID]        -- Operator ID (currently NULL)
    ,[vehnOperatorCtg]       -- Operator category (currently NULL)
    ,[vehsLicenceNo]         -- License number (currently NULL)
    ,[vehnLicenceStateID]    -- License state ID (currently NULL)
    ,[vehdLicExpDt]          -- License expiration date (currently NULL)
    ,[vehnVehicleMake]       -- Vehicle make ID (currently NULL in this query)
    ,[vehnYear]              -- Vehicle year (currently NULL in this query)
    ,[vehnModelID]           -- Vehicle model ID (currently NULL in this query)
    ,[vehnBodyTypeID]        -- Vehicle body type ID (currently NULL)
    ,[vehsPlateNo]           -- Vehicle plate number (currently NULL)
    ,[vehsColour]            -- Vehicle color (currently NULL)
    ,[vehnVehicleStateID]    -- Vehicle state ID (currently NULL)
    ,[vehsVINNo]             -- Vehicle Identification Number (currently NULL)
    ,[vehdRegExpDt]          -- Registration expiration date (currently NULL)
    ,[vehnIsLeased]          -- Indicates if the vehicle is leased (currently NULL)
    ,[vehnDamageClaim]       -- Damage claim (currently NULL)
    ,[vehdEstReqdOn]         -- Estimate required on (currently NULL)
    ,[vehdEstRecvdOn]        -- Estimate received on (currently NULL)
    ,[vehdPhotoReqdOn]       -- Photo required on (currently NULL)
    ,[vehdPhotoRecvdOn]      -- Photo received on (currently NULL)
    ,[vehbRepairs]           -- Indicates if repairs were done (currently NULL)
    ,[vehbTotalLoss]         -- Indicates if the vehicle is a total loss (currently NULL)
    ,[vehnCostOfRepairs]     -- Cost of repairs (currently NULL)
    ,[vehnValueBefAcdnt]     -- Vehicle value before the accident (currently NULL)
    ,[vehnRentalExpense]     -- Rental expense (currently NULL)
    ,[vehnOthExpense]        -- Other expenses (currently NULL)
    ,[vehnSalvage]           -- Salvage value (currently NULL)
    ,[vehnTLRentalExpense]   -- Total loss rental expense (currently NULL)
    ,[vehnTLOthExpense]      -- Total loss other expense (currently NULL)
    ,[vehnLoss]              -- Vehicle loss value (currently NULL)
    ,[vehnNetLoss]           -- Net loss value (currently NULL)
    ,[vehnLicenseHistory]    -- License history (currently NULL)
    ,[vehnPlateSearch]       -- Plate search (currently NULL)
    ,[vehnTitlesearch]       -- Title search (currently NULL)
    ,[vehnMV104]             -- MV104 report status (currently NULL)
    ,[vehdOprLicHistory]     -- Operator license history (currently NULL)
    ,[vehdPlateSearchOn]     -- Plate search performed on (currently NULL)
    ,[vehdTitleSearchOn]     -- Title search performed on (currently NULL)
    ,[vehdMV104On]           -- MV104 report performed on (currently NULL)
    ,[vehdOprLicHistoryRecd] -- Operator license history received (currently NULL)
    ,[vehdPlateSearchOnRecd] -- Plate search received on (currently NULL)
    ,[vehdTitleSearchOnRecd] -- Title search received on (currently NULL)
    ,[vehdMV104OnRecd]       -- MV104 report received on (currently NULL)
    ,[vehsComments]          -- Comments about the vehicle
    ,[vehbPhotoAttached]     -- Indicates if a photo is attached (currently NULL)
    ,[vehnRecUserID]         -- Record user ID
    ,[vehdDtCreated]         -- Date created
    ,[vehnModifyUserID]      -- Modify user ID (currently NULL)
    ,[vehdDtModified]        -- Date modified (currently NULL)
    ,[vehnLevelNo]           -- Record level number
)
SELECT DISTINCT
    cas.casnCaseID                  -- Case ID
    ,0                              -- Default value for IsPlaintiff
    ,d.defnDefendentID              -- Defendant ID
    ,NULL                           -- Owner ID
    ,NULL                           -- Owner category
    ,NULL                           -- Registrant ID
    ,NULL                           -- Registrant category
    ,NULL                           -- Operator ID
    ,NULL                           -- Operator category
    ,NULL                           -- License number
    ,NULL                           -- License state ID
    ,NULL                           -- License expiration date
    ,NULL                           -- Vehicle make (not provided)
    ,NULL                           -- Vehicle year (not provided)
    ,NULL                           -- Vehicle model ID (not provided)
    ,NULL                           -- Vehicle body type ID
    ,NULL                           -- Plate number
    ,NULL                           -- Vehicle color
    ,NULL                           -- Vehicle state ID
    ,NULL                           -- Vehicle VIN
    ,NULL                           -- Registration expiration date
    ,NULL                           -- Is leased
    ,NULL                           -- Damage claim
    ,NULL                           -- Estimate required on
    ,NULL                           -- Estimate received on
    ,NULL                           -- Photo required on
    ,NULL                           -- Photo received on
    ,NULL                           -- Repairs
    ,NULL                           -- Total loss
    ,NULL                           -- Cost of repairs
    ,NULL                           -- Value before accident
    ,NULL                           -- Rental expense
    ,NULL                           -- Other expenses
    ,NULL                           -- Salvage value
    ,NULL                           -- Total loss rental expense
    ,NULL                           -- Total loss other expense
    ,NULL                           -- Loss
    ,NULL                           -- Net loss
    ,NULL                           -- License history
    ,NULL                           -- Plate search
    ,NULL                           -- Title search
    ,NULL                           -- MV104 report
    ,NULL                           -- Operator license history
    ,NULL                           -- Plate search performed on
    ,NULL                           -- Title search performed on
    ,NULL                           -- MV104 report performed on
    ,NULL                           -- Operator license history received
    ,NULL                           -- Plate search received on
    ,NULL                           -- Title search received on
    ,NULL                           -- MV104 report received on
    ,CASE 
         WHEN ISNULL(ud.[Vehicle Year/Make/Model], '') <> '' 
         THEN 'Vehicle Year/Make/Model: ' + ud.[Vehicle Year/Make/Model] 
         ELSE ' '
     END                           -- Vehicle comments
    ,NULL                           -- Photo attached
    ,368                            -- Record user ID
    ,GETDATE()                      -- Date created
    ,NULL                           -- Modify user ID
    ,NULL                           -- Date modified
    ,1                              -- Level number
FROM [NeosBillEasterly]..neosuserTab6 ud
JOIN sma_trn_Cases cas 
    ON cas.Neos_saga = CONVERT(VARCHAR(50), ud.casesid)
LEFT JOIN sma_TRN_Defendants d 
    ON d.defnCaseID = cas.casnCaseID AND d.defbIsPrimary = 1

 







/*INSERT INTO [sma_TRN_Vehicles]
	([vehnCaseID],[vehbIsPlaintiff],[vehnPlntDefID],[vehnOwnerID],[vehnOwnerCtg],[vehnRegistrantID],[vehnRegistrantCtg],[vehnOperatorID],[vehnOperatorCtg],[vehsLicenceNo],[vehnLicenceStateID],[vehdLicExpDt]
	 , [vehnVehicleMake],[vehnYear],[vehnModelID] , /*[vehnBodyTypeID],[vehsPlateNo],[vehsColour],[vehnVehicleStateID],[vehsVINNo],[vehdRegExpDt],[vehnIsLeased],[vehnDamageClaim],[vehdEstReqdOn],[vehdEstRecvdOn],[vehdPhotoReqdOn]
	,[vehdPhotoRecvdOn],[vehbRepairs],[vehbTotalLoss],[vehnCostOfRepairs],[vehnValueBefAcdnt],[vehnRentalExpense],[vehnOthExpense],[vehnSalvage],[vehnTLRentalExpense],[vehnTLOthExpense],[vehnLoss],[vehnNetLoss],[vehnLicenseHistory]
	,[vehnPlateSearch],[vehnTitlesearch],[vehnMV104],[vehdOprLicHistory],[vehdPlateSearchOn],[vehdTitleSearchOn],[vehdMV104On],[vehdOprLicHistoryRecd],[vehdPlateSearchOnRecd],[vehdTitleSearchOnRecd],[vehdMV104OnRecd],*/[vehsComments]
	,[vehbPhotoAttached],[vehnRecUserID],[vehdDtCreated],[vehnModifyUserID],[vehdDtModified],[vehnLevelNo]   )  
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
		NULL, 					--[vehdLicExpDt] 
 	vm.vmknMakeID,			--[vehnVehicleMake],
		CASE 
                 WHEN CHARINDEX('/', ud.[Vehicle Year/Make/Model]  ) > 0 THEN LEFT(ud.[Vehicle Year/Make/Model], CHARINDEX('/', ud.[Vehicle Year/Make/Model]) - 1) -- Slash-delimited
                 ELSE LEFT(ud.[Vehicle Year/Make/Model], CHARINDEX(' ', ud.[Vehicle Year/Make/Model] + ' ') - 1) -- Space-delimited
         END AS [Year],
		vmo.vmdnModelID  /*,		--[vehnModelID]  ,
		NULL, 					--[vehnBodyTypeID],
		 null,	                  --[vehsPlateNo],	10
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
		NULL, 					--[vehdMV104OnRecd] */,
	 
		'', 					--[vehsComments],  200
		NULL, 					--[vehbPhotoAttached],
		368, 					--[vehnRecUserID],
		getdate(), 				--[vehdDtCreated],
		NULL, 					--[vehnModifyUserID],
		NULL, 					--[vehdDtModified],
		1						--[vehnLevelNo]      
--Select  CTE1.*
FROM  [NeosBillEasterly]..neosuserTab6 ud
JOIN sma_trn_Cases cas on cas.Neos_saga = convert(varchar(50),ud.casesid)
LEFT JOIN sma_TRN_Defendants d on d.defnCaseID = cas.casnCaseID and d.defbIsPrimary = 1
join CTE1 on cte1.casesid = cas.Neos_saga
  JOIN sma_MST_VehicleMake  vm  on vm.vmksDscrptn =cte1.Make_VehicleYearMakeModel
  JOIN sma_MST_VehicleModels vmo     ON         vmo.vmdsModelDscrptn= CTE1.Model_VehicleYearMakeModel
                                                                         
WHERE  ( isnull(ud.[Vehicle Year/Make/Model]  ,'') <> '' or isnull(ud.[Vehicle Year/Make/Model] ,'') <> '' )
  
GO   */

 