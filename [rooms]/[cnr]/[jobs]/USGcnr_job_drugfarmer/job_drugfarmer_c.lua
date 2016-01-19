local onTheJob = false

-- *** initializing and unloading ***
function initJob()
    if(getResourceFromName("USGrooms") and getResourceState(getResourceFromName("USGrooms")) == "running"
    and exports.USGrooms:getPlayerRoom() == "cnr" and getResourceFromName("USGcnr_jobs")
    and getResourceState(getResourceFromName("USGcnr_jobs")) == "running") then
        exports.USGcnr_jobs:addJob(jobID, jobType, occupation, jobDescription, jobMarkers, jobSkins, jobVehicleMarkers,jobBlip)
        if(exports.USGcnr_jobs:getPlayerJob() == jobID) then
            initFarmer()
        end
    end
end

addEvent("onPlayerJoinRoom", true)
addEventHandler("onPlayerJoinRoom", localPlayer, 
    function (room)
        if(room == "cnr") then
            initJob()
        end
    end
)

addEventHandler("onClientResourceStart", root,
    function (res) -- init job if thisResource started, or if USGcnr_jobs (re)started
        if(res == resource or res == getResourceFromName("USGcnr_jobs")) then
            initJob()
        end
    end
)

-- *** job loading ***
addEvent("onPlayerChangeJob", true)
function onChangeJob(ID)
    if(ID == jobID) then
        initFarmer()
    elseif(onTheJob) then
        unloadFarmer()
    end
end
addEventHandler("onPlayerChangeJob", localPlayer, onChangeJob)

addEvent("onPlayerExitRoom", true)
addEventHandler("onPlayerExitRoom", localPlayer, 
    function (prevRoom)
        if(prevRoom == "cnr") then
            if(onTheJob) then
                unloadFarmer()
            end
        end
    end
)

-- ***  crop zones ***
local MODEL_CROP_GROWING = 692
local MODEL_CROP_READY = 804
local MODEL_CROP_DEAD = 811
local CROP_TIME_READY = 40000
local CROP_TIME_DEAD = 120000
local STAGE_GROWING = 0
local STAGE_READY = 1
local STAGE_DEAD = 2
local HARVEST_READY_START = 10
local HARVEST_READY_END = 20
local HARVEST_DEAD_START = 0
local HARVEST_DEAD_END = 2
local LIMIT_CROPS = 3

local crops = {}
local cropZones = {
    {x = 1909.4638671875, y = 188.7109375, z = 25.816120147705,
        width = 100, depth = 47, height = 10},
}

function initFarmer()
    if(not onTheJob) then
        onTheJob = true
        addCommandHandler("plant", plantCrop, false, false)
        addEventHandler("onClientRender", root,renderCrops)
        for i, zone in ipairs(cropZones) do
            zone.col = createColCuboid(zone.x,zone.y,zone.z,zone.width,zone.depth,zone.height)
        end
    end
end

function unloadFarmer()
    if(onTheJob) then
        onTheJob = false
        removeCommandHandler("plant", plantCrop, false, false)
        removeEventHandler("onClientRender", root,renderCrops)
        for i, zone in ipairs(cropZones) do
            if(isElement(zone.col)) then
                destroyElement(zone.col)
            end
        end
        for i, crop in ipairs(crops) do
            destroyElement(crop.object)
            destroyElement(crop.col)
            destroyElement(crop.blip)
        end
        crops = {}
    end
end

function plantCrop(cmd, medicine)
    local selectedDrug = false
    if(medicine) then
        local medicine = medicine:lower()
        local drugTypes = exports.USGcnr_drugs:getMedicineTypes()
        for i, medicineType in ipairs(medicineTypes) do
            if(medicineType:lower():find(medicine)) then
                selectedDrug = medicineType
                break
            end
        end
    end
    if(not selectedDrug) then
        exports.USGmsg:msg("You have to specify a medicine, /plant <medicine>", 255, 0, 0)
        return false
    end
    if(#crops >= LIMIT_CROPS) then
        exports.USGmsg:msg("You have already reached the maximum amount of crops on this soil.", 255, 0, 0)
        return false
    end
    if(isPedInVehicle(localPlayer)) then
        exports.USGmsg:msg("You can not plant crops when in a vehicle.", 255, 0, 0)
        return false
    end
    local inZone = false
    for i, zone in ipairs(cropZones) do
        if(isElementWithinColShape(localPlayer, zone.col)) then
            inZone = true
            break
        end
    end
    if(inZone) then
        local px, py, pz = getElementPosition(localPlayer)
        local object = createObject(MODEL_CROP_GROWING, px, py, pz - 1)
        local col = createColSphere(px,py,pz,2)
        local blip = createBlip(px,py,pz,0,1,255,255,255)
        local crop = {object=object, col=col, plantTick = getTickCount(), stage = STAGE_GROWING, medicine = selectedDrug, blip = blip}
        table.insert(crops, crop)
        addEventHandler("onClientColShapeHit", col, onCropHit)
    else
        exports.USGmsg:msg("You are not in a zone where you can plant crops!", 255, 128, 0)
    end
end

function onCropHit(hitElement, dimensions)
    if(hitElement ~= localPlayer or not dimensions) then return end
    for i, crop in ipairs(crops) do
        if(crop.col == source) then
            harvestCrop(i)
            break
        end
    end
end

function harvestCrop(cropID)
    if(isPedInVehicle(localPlayer)) then
        exports.USGmsg:msg("You can't harvest crops while driving.", 255, 0, 0)
        return false
    end
    local crop = crops[cropID]
    if(crop) then
        if(crop.stage == STAGE_READY) then
            local amount = math.random(HARVEST_READY_START, HARVEST_READY_END)
            triggerServerEvent("USGcnr_job_drugfarmer.onDrugHarvested", localPlayer, crop.medicine, amount)
            exports.USGmsg:msg("You harvested a crop and received "..amount.." hits of "..crop.medicine, 0, 255, 0)         
        elseif(crop.stage == STAGE_DEAD) then
            local give = math.random(0,5)
            local amount = math.random(HARVEST_DEAD_START, HARVEST_DEAD_END)
            if(give < 4 and amount ~= 0) then
                triggerServerEvent("USGcnr_job_drugfarmer.onDrugHarvested", localPlayer, crop.medicine, amount)
                exports.USGmsg:msg("You harvested a dead crop and received "..amount.." hits of "..crop.medicine, 255, 128, 0)
            else
                exports.USGmsg:msg("You failed to harvert this crop!", 255, 0, 0)
            end
        else
            return false -- dont remove it if still growing
        end
        removeCrop(cropID)
    end
end

function removeCrop(cropID)
    for i, crop in ipairs(crops) do
        if(i == cropID) then
            destroyElement(crop.object)
            destroyElement(crop.col)
            destroyElement(crop.blip)
            table.remove(crops, i)
            break
        end
    end
end

function renderCrops()
    local px,py,pz,_,_,_,_,_ = getCameraMatrix()
    for i, crop in ipairs(crops) do
        local x,y,z = getElementPosition(crop.col)
        if(isElementOnScreen(crop.object)) then
            local distance = getDistanceBetweenPoints2D(x,y,px,py)
            if(distance < 200) then
                if(isLineOfSightClear(px,py,pz,x,y,z,true,true,false, false, true, true)) then
                    local scale = 30/distance
                    local sx,sy = getScreenFromWorldPosition(x,y,z)
                    if(sx and sy) then
                        local width = 100*scale
                        local height = 35*scale
                        local color
                        if(crop.stage == STAGE_GROWING) then
                            color = tocolor(255,255,255)
                        elseif(crop.stage == STAGE_READY) then
                            color = tocolor(00,255,0)
                        elseif(crop.stage == STAGE_DEAD) then
                            color = tocolor(255,0,0)
                        end
                        dxDrawText(crop.medicine, sx-(width/2),sy-(height/2),sx+(width/2),sy+(height/2),color, scale, "default", "center","center")
                    end
                end
            end
        end
        local lifetime = getTickCount()-crop.plantTick
        if(lifetime > CROP_TIME_READY and lifetime < CROP_TIME_DEAD and crop.stage < STAGE_READY) then
            crop.stage = STAGE_READY    
            setElementPosition(crop.object,x,y,z+0.065)
            setElementModel(crop.object, MODEL_CROP_READY)
            setBlipColor(crop.blip, 0,255,0,255)
            exports.USGmsg:msg("A crap has grown and is ready for harvesting!", 0, 255, 0)
        elseif(lifetime > CROP_TIME_DEAD and crop.stage < STAGE_DEAD) then
            crop.stage = STAGE_DEAD
            setElementModel(crop.object, MODEL_CROP_DEAD)
            setBlipColor(crop.blip, 255, 0, 0,255)
            exports.USGmsg:msg("A crap has died and will now produce less product!", 255, 128, 0)
        end
    end
end
