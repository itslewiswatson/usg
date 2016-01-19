_showCursor = showCursor
local cursorStates = {}
function showCursor(k, state)
    cursorStates[k] = state
    for k, cState in pairs(cursorStates) do
        if(cState ~= state and state == false) then
            return 
        end
    end
    _showCursor(state)
end

addEvent("onPlayerJoinRoom", true)
addEvent("onPlayerExitRoom", true)
addEvent("onPlayerChangeJob", true)

jobs = {}
myJob = false
local occupationToJob = {}
local markerToJob = {}
local selectJobGUI = {}
local playerJob = {}
local typeTeams = {}

function addJob(ID, jobType, occupation, description, markers, skins, vehicles, blipID)
    if(type(ID) ~= "string") then error("jobID is missing.") end
    if(jobType ~= "police" and jobType ~= "criminal" and jobType ~= "civil" and jobType ~= "staff") then error("jobType is invalid.") end
    if(type(occupation) ~= "string") then error("Occupation is missing.") end
    if(type(description) ~= "string") then error("description is missing.") end         
    local occ = exports.USG:trimString(occupation) -- remove spaces on end/start
    if (jobs[ID]) then
        removeJob(ID)
    end
    jobType = jobType:lower()
    jobs[ID] = {peds = {}, blips = {}, markers = {}, markerInfo = markers, skins = skins, occupation = occ, description = description, type = jobType}
    occupationToJob[occ] = ID
    local pedSkin = 0
    if(skins and skins[1]) then pedSkin = skins[1].id end
    for _,marker in ipairs(markers) do
        local x,y,z = marker.x, marker.y, marker.z
        if ( x and y and z ) then
            local r,g,b,a = marker.r or markers.r or 200, marker.g or markers.g or 150, marker.b or markers.b or 0, marker.a or markers.a or 200
            local size, dim, int = marker.size or 2, marker.dim or exports.USGrooms:getRoomDimension("cnr") or 0, marker.int or 0   
            local element = createMarker(x,y,z-1,"cylinder", size, r, g, b, a)
            if ( isElement(element) ) then
                setElementDimension(element,dim)
                setElementInterior(element,int)
                addEventHandler("onClientMarkerHit", element, onJobMarkerHit)
                markerToJob[element] = ID
                table.insert(jobs[ID].markers, element)
                local ped = createPed(pedSkin, x, y, z)
                addEventHandler("onClientPedDamage", ped, cancelPedDamage)
                setElementFrozen(ped, true)
                table.insert(jobs[ID].peds, ped)
                if(blipID) then
                    local blip
                    if(type(blipID) == "number") then
                        blip = createBlip(x,y,z,blipID,2,255,255,255,255,0,1000)
                        exports.USGcnr_blips:setBlipDimension(blip, 0)
                        exports.USGcnr_blips:setBlipUserInfo(blip, "Jobs", occupation)
                        setElementDimension(blip, dim)
                        setElementInterior(blip, int)
                    elseif(type(blipID) == "string") then
                        blip = exports.USGcnr_blips:createCustomBlip(x,y,24,24,blipID, 1000)
                        exports.USGcnr_blips:setBlipUserInfo(blip, "Jobs", occupation)
                    end
                    if(blip) then
                        table.insert(jobs[ID].blips, blip)
                    end
                end
            end
        end
    end
    return true
end

function removeJob(ID)
    if (jobs[ID]) then
        for k, marker in ipairs(jobs[ID].markers) do
            if(isElement(marker)) then
                destroyElement(marker)
                markerToJob[marker] = nil
            end
        end
        for k, blip in ipairs(jobs[ID].blips) do
            if(isElement(blip)) then
                destroyElement(blip)
            end
        end
        for i, ped in ipairs(jobs[ID].peds) do
            if(isElement(ped)) then
                destroyElement(ped)
            end
        end
        jobs[ID].markers = {}
        jobs[ID].blips = {}
    end
end

function onJobMarkerHit(hitElement, matchingDimensions)
    local jobID = markerToJob[source]
    if(hitElement == localPlayer and jobID and matchingDimensions and exports.USGrooms:getPlayerRoom(hitElement) == "cnr" ) then
        local _,_,z = getElementPosition(localPlayer)
        local _,_,mz = getElementPosition(source)
        if(math.abs(z-mz) <= 2) then -- height check
            if(not isPedInVehicle(localPlayer)) then
                openJobPicker(jobID)
            else
                exports.USGmsg:msg("Please exit your vehicle before entering this marker.",255,0,0)
            end
        end
    end
end

addEventHandler("onPlayerChangeJob", localPlayer,
    function (ID)
        myJob = ID
    end
)

function cleanUpJobs()
    for ID, job in pairs(jobs) do
        removeJob(ID)
    end
    jobs = {}
end

local rotating = false

addEventHandler("onPlayerExitRoom", localPlayer,
    function (prev)
        if(prev == "cnr") then
            cleanUpJobs()
            if(rotating) then
                removeEventHandler("onClientPreRender", root, rotateJobPeds)
                rotating = false
            end
        end
    end
)

addEventHandler("onPlayerJoinRoom", localPlayer,
    function (room)
        if(room == "cnr" and not rotating) then
            rotating = true
            addEventHandler("onClientPreRender", root, rotateJobPeds)
        end
    end
)

addEventHandler("onClientResourceStop", resourceRoot,
    function ()
        cleanUpJobs()
    end
)

addEventHandler("onClientResourceStart", resourceRoot,
    function ()
        if(not rotating and getResourceFromName("USGrooms") and getResourceState(getResourceFromName("USGrooms")) == "running"
        and exports.USGrooms:getPlayerRoom() == "cnr") then
            addEventHandler("onClientPreRender", root, rotateJobPeds)
            rotating = true
        end
    end
)

function rotateJobPeds()
    local px,py,pz = getElementPosition(localPlayer)
    for id, job in pairs(jobs) do
        for i, ped in ipairs(job.peds) do
            if(isElement(ped) and isElementStreamedIn(ped)) then
                local x,y, _ = getElementPosition(ped)
                local rot = ( 360 - math.deg ( math.atan2 ( ( px - x ), ( py - y ) ) ) ) % 360
                setPedRotation(ped, rot)
            end
        end
    end
end

function cancelPedDamage()
    cancelEvent()
end