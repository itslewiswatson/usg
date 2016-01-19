local STATE_INACTIVE = 0
local STATE_PREPARATION = 1
local STATE_ACTIVE = 2

local TYPE_CONVOY_KILL = 1
local TYPE_CONVOY_TAKE = 2
local TYPE_KILL = 3
local TYPES = 1 -- number of available types

local convoyRoutes = {
    --{x = -2727.099609375, y = -311.17578125, z = 7.0390625, rz = 135, tx = -2261.7353515625, ty = 2334.9482421875, tz = 4.8125},
    {x = -2727.099609375, y = -311.17578125, z = 7.0390625, rz = 135, tx = 1672.3720703125 , ty = 1204.28125, tz = 10.990625},
}

local convoy = {}

local EVENT_TYPE
local EVENT_STATE = STATE_INACTIVE
local EVENT_INTERVAL = 15*60*60*1000
local criminalsGivenWantedLevel = {}

local ID = 3
local GlobalTimer

_destroyElement = destroyElement
function destroyElement(element)
    if(isElement(element)) then _destroyElement(element) end
end

function getLawPlayers()
    local lawPlayers = {}
    for i, player in ipairs(getElementsByType("player")) do
        if(exports.USGcnr_jobs:getPlayerJobType(player) == "police") then
            table.insert(lawPlayers, player)
        end
    end
    return lawPlayers
end

function notifyLaw(msg, chatbox,r,g,b)
    for i, player in ipairs(getElementsByType("player")) do
        if(exports.USGcnr_jobs:getPlayerJobType(player) == "police") then
            if(chatbox) then
                outputChatBox(msg,player,r,g,b)
            else
                exports.USGmsg:msg(player, msg, r,g,b)
            end
        end
    end
end

function prepareEvent()
    if(EVENT_STATE == STATE_INACTIVE) then
        EVENT_STATE = STATE_PREPARATION
        EVENT_TYPE = math.random(TYPES)
        criminalsGivenWantedLevel = {}
        if(EVENT_TYPE == TYPE_CONVOY_KILL or EVENT_TYPE == TYPE_CONVOY_TAKE) then -- make a convoy
            local convoyRoute = convoyRoutes[math.random(#convoyRoutes)]
            convoy = { x = convoyRoute.x, y = convoyRoute.y, z = convoyRoute.z, rz = convoyRoute.rz, tx = convoyRoute.tx, ty = convoyRoute.ty, tz = convoyRoute.tz } 
            convoy.vehicle = createVehicle(427, convoy.x, convoy.y, convoy.z+0.25, 0, 0, convoy.rz)
            setElementFrozen(convoy.vehicle, true)
            setVehicleDamageProof(convoy.vehicle, true)
            addEventHandler("onVehicleStartEnter",convoy.vehicle, onConvoyVehicleStartEnter)
            addEventHandler("onVehicleEnter",convoy.vehicle, onConvoyVehicleEnter)
            convoy.president = createPed(166, convoy.x, convoy.y, convoy.z+4)
            warpPedIntoVehicle(convoy.president, convoy.vehicle, 2) -- warp into back of car
            convoy.zone = createColSphere(convoy.x, convoy.y, convoy.z,150)
            attachElements(convoy.zone, convoy.vehicle)
           -- convoy.target = createColSphere(convoy.tx, convoy.ty, convoy.tz,30)
            local lawPlayers = getLawPlayers()
            for i, player in ipairs(getElementsByType("player")) do
                if(exports.USGcnr_jobs:getPlayerJobType(player) == "police") then
                    outputChatBox("The president requires protection.", player, 0, 80, 150)
                    triggerClientEvent(player, "USGcnr_protectpresident.addConvoyBlip", convoy.president)
                end
            end
        end
    end
end

function startEvent()
    if(EVENT_STATE == STATE_PREPARATION) then
        EVENT_STATE = STATE_ACTIVE
        if(doesEventHaveConvoy()) then
            setElementFrozen(convoy.vehicle, false)
            convoy.vehicleArmor = 1500
            convoy.attackers = {}
            convoy.defenders = {}
            convoy.startZone = createColSphere(convoy.x, convoy.y, convoy.z, 150)
            convoy.target = createColSphere(convoy.tx, convoy.ty, convoy.tz,30)
            addEventHandler("onColShapeLeave", convoy.startZone, onConvoyStartZoneExit)
            addEventHandler("onColShapeHit", convoy.zone, onConvoyZoneEnter)
            addEventHandler("onColShapeLeave", convoy.zone, onConvoyZoneExit)
            addEventHandler("onPedWasted", convoy.president, onPresidentWasted)
            addEventHandler("onVehicleExplode", convoy.vehicle, onConvoyVehicleExplode)
            addEventHandler("onElementStartSync", convoy.vehicle, onConvoyVehicleStartSync)
            addEventHandler("onElementStopSync", convoy.vehicle, onConvoyVehicleStopSync)
            addEventHandler("onPlayerWasted", root, onConvoyPlayerWasted)
            addEventHandler("onVehicleDamage", root, onVehicleDamage)
            local elements = getElementsWithinColShape(convoy.zone)
            for i, element in ipairs(elements) do
                onConvoyZoneEnter(element, getElementDimension(element) == getElementDimension(convoy.zone))
            end
            addEventHandler("onColShapeHit", convoy.target, onConvoyTargetEnter)
            for i, player in ipairs(getElementsByType("player")) do
                if(exports.USGrooms:getPlayerRoom(player) == "cnr") then
                    triggerClientEvent(player, "USGcnr_protectpresident.addConvoyBlip", convoy.president)
                end
            end
        end
    end
end

function doesEventHaveConvoy()
    return EVENT_TYPE == TYPE_CONVOY_KILL or EVENT_TYPE == TYPE_CONVOY_TAKE
end

function onConvoyVehicleStartEnter(player, seat,jacked,door)
    if(exports.USGcnr_jobs:getPlayerJobType(player) ~= "police" and EVENT_TYPE ~= TYPE_CONVOY_TAKE) then
        cancelEvent()
        return
    end 
    if(seat == 0) then
        if(jacked) then
            cancelEvent()
        end
    elseif(seat >= 2) then -- cant sit at president's spot or next to him
        cancelEvent()
    end
end

function onConvoyVehicleEnter(player, seat,jacked,door)
    if(exports.USGcnr_jobs:getPlayerJobType(player) ~= "police") then return end
    if(seat == 0) then
        if(not convoy.driver) then
            convoy.driver = player
            onConvoyVehicleStartSync(player)
            toggleControl(player, "enter_exit", false)
            setElementHealth(player, 1000)
            setPedArmor(player, 100)
            startEvent()
        end
    end
end

function onConvoyStartZoneExit(element, dimensions)
    if(element == convoy.vehicle) then
        -- notify the criminals
        local message = "The presidential convoy is on it's way. "..(EVENT_TYPE == TYPE_CONVOY_TAKE
         and "Kidnap the president for a reward." or "Kill the president for a reward.")
        for i, player in ipairs(getElementsByType("player")) do
            if(exports.USGrooms:getPlayerRoom(player) == "cnr" and 
            exports.USGcnr_jobs:getPlayerJobType(player) == "criminal") then
                exports.USGmsg:msg(player, message, 0, 255, 0)
                triggerClientEvent(player, "USGcnr_protectpresident.addConvoyStartBlip", player, convoy.x, convoy.y, convoy.z)
            end
        end
        destroyElement(convoy.startZone)
    end
end

function onConvoyZoneEnter(element, dimensions)
    if(not dimensions or getElementType(element) ~= "player" or exports.USGrooms:getPlayerRoom(element) ~= "cnr") then return end
    local jobType = exports.USGcnr_jobs:getPlayerJobType(element)
    if(not criminalsGivenWantedLevel[element] and jobType ~= "police" and jobType ~= "staff") then
        exports.USGcnr_wanted:givePlayerWantedLevel(element, 30)
        criminalsGivenWantedLevel[element] = true
    end
    if(jobType == "police") then -- show target location
        triggerClientEvent(element, "USGcnr_protectpresident.addTargetBlip", element, convoy.tx, convoy.ty, convoy.tz)
    end 
end

function onConvoyZoneExit(element, dimensions)
    if(not dimensions or getElementType(element) ~= "player" or exports.USGrooms:getPlayerRoom(element) ~= "cnr") then return end
    triggerClientEvent(element, "USGcnr_protectpresident.destroyTargetBlip", convoy.target)
end

function onConvoyTargetEnter(element, dimensions)
    if(dimensions and element == convoy.president) then
        local police = getConvoyPolice() -- get list of involved cops
        for i, cop in ipairs(police) do
            givePlayerMoney(cop, 25000)
            exports.USGcnr_score:givePlayerScore(cop, 3.5)
            exports.USGmsg:msg(cop,"You got 25000$")
        end
        if(isElement(convoy.driver)) then
            givePlayerMoney(convoy.driver, 5000)
            exports.USGcnr_score:givePlayerScore(convoy.driver, 1)
            exports.USGmsg:msg(convoy.driver,"You got 5000")
        end
        stopEvent()
    end
end

function onConvoyVehicleStartSync(newSyncer)
    if(convoy.vehicleSyncer ~= newSyncer) then
        convoy.vehicleSyncer = getElementSyncer(convoy.vehicle)
        triggerClientEvent(newSyncer, "USGcnr_protectpresident.monitorDamage", convoy.vehicle)
    end
end

function onConvoyVehicleStopSync(oldSyncer)
    if(oldSyncer == getVehicleOccupant(convoy.vehicle, 0) or oldSYncer ~= convoy.vehicleSyncer) then return end
    convoy.vehicleSyncer = nil
    triggerClientEvent(oldSyncer, "USGcnr_protectpresident.stopMonitoringDamage", convoy.vehicle)
end

addEvent("USGcnr_protectpresident.reportDamage", true)
addEventHandler("USGcnr_protectpresident.reportDamage", root,
    function (loss)
        if(convoy and EVENT_STATE == STATE_ACTIVE) then
            if(convoy.vehicleSyncer ~= client) then return end
            local jobType = exports.USGcnr_jobs:getPlayerJobType(source)
            if(jobType ~= "police" and jobType ~= "staff") then
                convoy.attackers[source] = convoy.attackers[source] and convoy.attackers[source]+loss or loss
            end
            if(convoy.vehicleArmor > 0) then
                convoy.vehicleArmor = convoy.vehicleArmor-loss
            else
                setVehicleDamageProof(convoy.vehicle, false)
            end
        end
    end
)

function onVehicleDamage(loss)
    if(isElementWithinColShape(source, convoy.zone)) then
        if(convoy.vehicle == source) then
            setElementHealth(convoy.vehicle, getElementHealth(convoy.vehicle)-(loss*0.5))
        else
            local driver = getVehicleController(source)
            if(driver and exports.USGcnr_jobs:getPlayerJobType(driver) == "police") then
                setElementHealth(source, getElementHealth(source)-(loss*0.75))
            end
        end
    end
end

function getConvoyPolice()
    local playerAdded = {}
    local police = {}
    for player, _ in pairs(convoy.defenders) do
        table.insert(police, player)
        playerAdded[police] = true
    end
    for i, player in ipairs(getElementsWithinColShape(convoy.zone)) do
        if(getElementType(player) == "player" and not playerAdded[player]) then
            local jobType = exports.USGcnr_jobs:getPlayerJobType(player)
            if(jobType == "police") then
                table.insert(police, player)
                playerAdded[player] = true
            end
        end
    end
    return police
end

function getConvoyCriminals()
    local playerAdded = {}
    local criminals = {}
    for player, _ in pairs(convoy.attackers) do
        table.insert(criminals, player)
        playerAdded[player] = true
    end
    for i, player in ipairs(getElementsWithinColShape(convoy.zone)) do
        if(getElementType(player) == "player" and not playerAdded[player]) then
            local jobType = exports.USGcnr_jobs:getPlayerJobType(player)
            if(jobType ~= "police" and jobType ~= "staff") then
                table.insert(criminals, player)
                playerAdded[player] = true
            end
        end
    end
    return criminals
end

function onConvoyVehicleExplode()
    local killer
    local mostDamage = 0
    for player, damage in pairs(convoy.attackers) do
        if(isElement(player) and (mostDamage < damage or not killer)) then
            killer = player
            mostDamage = damage
        end
    end
    if(killer) then
        local criminals = getConvoyCriminals() -- get list of involved criminals
        for i, criminal in ipairs(criminals) do
            givePlayerMoney(criminal, 17500)
            exports.USGmsg:msg(criminal,"You got 17500")
            exports.USGcnr_score:givePlayerScore(criminal, 2.5)
            exports.USGcnr_wanted:givePlayerWantedLevel(criminal, 10)
        end 
        givePlayerMoney(killer, 4000)
        exports.USGmsg:msg(killer,"You got 4000")
        exports.USGcnr_score:givePlayerScore(killer, 0.5)
    end
    stopEvent()
end

function onConvoyPlayerWasted(ammo, killer, weapon, bodypart)
    if(not isElementWithinColShape(source, convoy.zone)) then return end
    if(killer) then
        local kJobType = exports.USGcnr_jobs:getPlayerJobType(killer)
        local vJobType = exports.USGcnr_jobs:getPlayerJobType(source)
        if(kJobType == "police" and vJobType == "criminal") then
            convoy.defenders[killer] = true
        elseif(vJobType == "police" and kJobType == "criminal") then
            convoy.attackers[source] = 0
        end
        givePlayerMoney(killer, 1000)
        exports.USGcnr_score:givePlayerScore(killer, 1)
    end
end

function onPresidentWasted(ammo, killer, weapon, bodypart)
    if(getElementHealth(convoy.vehicle) < 250) then -- give credit to explosion event
        onConvoyVehicleExplode()
        return
    end
    if(killer) then
        givePlayerMoney(killer, 5000)
        exports.USGcnr_score:givePlayerScore(killer, 1) 
    end
    local criminals = getConvoyCriminals() -- get list of involved criminals
    for i, criminal in ipairs(criminals) do
        givePlayerMoney(criminal, 20000)
        exports.USGcnr_score:givePlayerScore(criminal, 3)
        exports.USGcnr_wanted:givePlayerWantedLevel(criminal, 10)
    end
    stopEvent()
end

function stopEvent(onShutdown)
    if(EVENT_STATE == STATE_ACTIVE or EVENT_STATE == STATE_PREPARATION) then
        if(doesEventHaveConvoy()) then
            if(isElement(convoy.driver)) then
                toggleControl(convoy.driver, "enter_exit", true)
            end
            destroyElement(convoy.startZone)
            destroyElement(convoy.zone)
            destroyElement(convoy.president)
            destroyElement(convoy.target)
            destroyElement(convoy.vehicle)
            if(not onShutdown) then
                for i, player in ipairs(getElementsByType("player")) do
                    if(exports.USGrooms:getPlayerRoom(player) == "cnr") then
                        triggerClientEvent(player, "USGcnr_protectpresident.destroyConvoyStartBlip", player)
                        triggerClientEvent(player, "USGcnr_protectpresident.destroyTargetBlip", player)
                    end
                end
            end
            if(EVENT_STATE == STATE_ACTIVE) then
                removeEventHandler("onVehicleDamage", root, onVehicleDamage)
                removeEventHandler("onPlayerWasted", root, onConvoyPlayerWasted)
            end
            convoy = nil
        end
        EVENT_STATE = STATE_INACTIVE
        GlobalTimer = setTimer(prepareEvent, EVENT_INTERVAL, 1)
    end
end
addEventHandler("onResourceStop", resourceRoot, stopEvent)

addEventHandler("onResourceStart", resourceRoot, prepareEvent)


addEventHandler("onResourceStart", root,
    function (res) -- init job if thisResource started, or if USGEventsApp (re)started
        if(res == resource or res == getResourceFromName("USGEventsApp")) then
        
        end 
		if(res == resource)then 
		prepareEvent()
		end
    end
)

addEventHandler ( "onResourceStop", resourceRoot, 
    function (  )
   end 
) 