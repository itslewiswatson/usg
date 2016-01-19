loadstring(exports.mysql:getQueryTool())()

turfs = {}


function resourceStart()
    query(loadTurfs,{},"SELECT * FROM cnr__turfs")
end
addEventHandler("onResourceStart", resourceRoot, resourceStart)

function loadTurfs(dbTurfs)
    for i, dbTurf in ipairs(dbTurfs) do
        Turf(dbTurf) -- initiate turf
    end
    if(not isTimer(updateTurfsTimer)) then
        updateTurfsTimer = setTimer(updateTurfs, INFLUENCE_UPDATE_INTERVAL, 0)
    end
end

function saveTurfs()
    for i, turf in ipairs(turfs) do
        local res = turf:save()
        if(not res) then
            outputDebugString("Turf with id "..turf.id.." failed to save!", 1, 255,0,0)
        end
    end
end
addEventHandler("onResourceStop", resourceRoot, saveTurfs)

function updateTurfs()
    for i, turf in ipairs(turfs) do
        turf:updateStatus()
        turf:updateInfluence()
    end
    collectgarbage()
end

---
addEventHandler("onGroupDelete", root, 
    function (groupID)
        for i, turf in ipairs(turfs) do
            if(turf.ownerGroup == groupID) then
                turf:setUnoccupied()
            end
        end
    end
)

addEventHandler("onGroupColorChange", root, 
    function (groupID, r, g, b)
        for i, turf in ipairs(turfs) do
            if(turf.ownerGroup == groupID) then
                setRadarAreaColor(turf.radarArea, r,g,b,125)
            end
        end
    end
)
-- provide spawn point for respawning, to the USGCnr_respawn resource
-- format: name = name, x = x, y = y, z = z, rot = rot
local MAX_SPAWN_DISTANCE = 1500

function getSpawnLocation(player)
    if(not turfs) then return false end
    if(not isElement(player)) then return false end
    local closest
    local closestDistance
    local px,py,pz = getElementPosition(player)
    for i, turf in ipairs(turfs) do
        if(turf:isPlayerOwner(player) and turf.status == TURF_STATUS_IDLE) then
            local x,y = turf.x+((turf.x2-turf.x)/2), turf.y+((turf.y2-turf.y)/2)
            local dist = getDistanceBetweenPoints2D(px,py, x, y)
            if(dist < MAX_SPAWN_DISTANCE and turf.spawnx and turf.spawny and turf.spawnz and ( not closest or closestDistance > dist )) then
                closestDistance = dist
                closest = turf
            end
        end
    end
    if(closest) then
        return {name = "Friendly turf", x=closest.spawnx, y=closest.spawny, z=closest.spawnz, rot=closest.spawnrot or 0}
    else
        return false
    end
end

function getCurrentTurfPlayer(player)
    if(not turfs) then return false end
    if(not isElement(player)) then return false end
    local closest
    local closestDistance
    local px,py,pz = getElementPosition(player)
    for i, turf in ipairs(turfs) do
        if(turf:isPlayerOwner(player) and turf.status == TURF_STATUS_IDLE) then
            local x,y = turf.x+((turf.x2-turf.x)/2), turf.y+((turf.y2-turf.y)/2)
            local dist = getDistanceBetweenPoints2D(px,py, x, y)
            if(dist < MAX_SPAWN_DISTANCE and turf.spawnx and turf.spawny and turf.spawnz and ( not closest or closestDistance > dist )) then
                closest = turf
            end
        end
    end
    if(closest) then
        return closest
    else
        return false
    end
end

function getTurfbyID(ID)
    for k,turf in ipairs(turfs)do
        if (turf.id == ID) then
        return turf
        end
    end
end


