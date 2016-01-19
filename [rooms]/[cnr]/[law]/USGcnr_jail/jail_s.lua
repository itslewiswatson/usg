local jailedPlayers = {}

local colShape = createColCuboid ( -2423.078125, 1718.220703125, -5, 225, 200, 200 )

local jails = 
{ -- [locID] = data
    LV =    { x = 2340.7763671875, y = 2456.26171875, z = 14.96875, rot = 180,
                jailMarker = { x = 2283.841796875, y = 2427.8349609375, z = 10.8203125}
            },
    LS =    { x = 1544.236328125, y = -1676.669921875, z = 13.558013916016, rot = 90,
                jailMarker = { x = 1540.046875, y = -1656.8583984375, z = 13.549829483032}
            },
    AP =    { x = -2150.0029296875, y = -2396.57421875, z = 30.625, rot = 151.79766845703,
                jailMarker = { x = -2163.51953125, y = -2387.9443359375, z = 30.625 }
            },
    SF =    { x = -1596.9833984375, y = 719.712890625, z = 10.421817779541, rot = 0,
                jailMarker = { x = -1606.2275390625, y = 722.2685546875, z = 12.098920822144}
            },
    EQ =    { x = -1392.421875, y = 2624.8916015625, z = 55.967582702637, rot = 90,
                jailMarker = { x = -1419.08984375, y = 2639.29296875, z = 55.6875}
            },
    FC =    { x = -222.0146484375, y = 990.0966796875, z = 19.525724411011, rot = 270,
                jailMarker = { x = -202.2255859375, y = 977.8203125, z = 18.913713455}
            },
    LS2=    { x = 631.7099609375, y = -587.154296875, z = 16.342170715332, rot = 270,
                jailMarker = {  x = 634.1962890625, y = -568.40625, z = 16.3359375}
            },
}

local markerJail = {}

local JAIL_DIMENSION, JAIL_INTERIOR = exports.USGrooms:getRoomDimension("cnr"), 0
local JAIL_X, JAIL_Y, JAIL_Z, JAIL_ROT = -2342.359375, 1846.806640625, 18.5, 0

--Jail Door
local ObjectgateID, closedX, closedY, closedZ, closedRoationX, closedRoationY, closedRoationZ, openX, openY, openZ, openSpeed = 3475, -2328.3999, 1867.80005, 19.1, 0, 0, 258.745 ,-2323.3999, 1867.80005, 19.1,1000
local JailDoor = createObject(ObjectgateID, closedX, closedY, closedZ, closedRoationX, closedRoationY, closedRoationZ)
local JailOpen = false

local function messageCNR(message,r,g,b)
    for k, player in ipairs(getElementsByType("player")) do
                    if(exports.USGrooms:getPlayerRoom(player) == "cnr")then
                    exports.USGmsg:msg(player, message, r,g,b)
                end
            end
end

local timer = {}

addEventHandler ( "onColShapeHit", colShape, function(element)
    if(getElementType(element) == "vehicle")then
        if(getVehicleType(element) == "Plane" or getVehicleType(element) == "Helicopter")then
            local player = getVehicleOccupant (element)
            exports.USGmsg:msg(player, "You have 10 seconds to leave the area before dying suddenly!", 255,255,255)
            timer[player] = setTimer(function()
            if(isElementWithinColShape(player,colShape))then
                killPed(player)
            end
            end,10000,1)
        end
    end
end )

function toggleJailDoor(state)
    if(state == "close")then
    moveObject(JailDoor,openSpeed,closedX, closedY, closedZ)
    messageCNR("Jail doors are now closed",0,0,255)
    JailOpen = false
    elseif(state == "open")then
    moveObject(JailDoor,openSpeed,openX, openY, openZ)
    JailOpen = true
    messageCNR("Jail doors are now open",255,0,0)
    for k, player in ipairs(getElementsByType("player")) do
            if(exports.USGrooms:getPlayerRoom(player) == "cnr")then
                if(exports.USGcnr_job_police:isPlayerArrested(player))then
                        exports.USGcnr_job_police:releasePlayer(player)
                        exports.USGmsg:msg(player, "You have been released from arrest", 255,0,0)
                end
                if(isPlayerJailed(player))then
                        unjailPlayerOpenDoor(player)
                        exports.USGmsg:msg(player, "Jail doors are now open you are free to go!", 255,0,0)
                end
            end
        end
    end
end

function isJailOpen()
    return JailOpen
end

addCommandHandler("jailstate",function(player)
    if(isJailOpen())then
    exports.USGmsg:msg(player, "Jail doors are open", 255,255,255)
    else
    exports.USGmsg:msg(player, "Jail doors are closed", 255,255,255)
    end
end)

addEventHandler("onResourceStart", resourceRoot,
    function ()
        local map = getResourceMapRootElement(resource, "map/jail.map")
        local objects = getElementChildren(map)
        for i, object in ipairs(objects) do
            setElementDimension(object, JAIL_DIMENSION)
        end     
        for name, jail in pairs(jails) do
            if(jail.jailMarker) then
              local marker = createMarker(jail.jailMarker.x, jail.jailMarker.y, jail.jailMarker.z-1, 
                    "cylinder", 3, 0, 0, 200, 130)
                setElementDimension(marker, 0)
                jail.marker = marker
                markerJail[marker] = name
                addEventHandler("onMarkerHit", marker, onJailMarkerHit)
            end
        end
        for i, player in ipairs(getElementsByType("player")) do
            if(exports.USGrooms:getPlayerRoom(player) == "cnr") then
                local data = exports.USGcnr_room:getPlayerAccountData(player)
                if(data.jailtime and data.jailtime > 5) then
                    jailPlayer(player, data.jailtime, data.jail)
                end
            end
        end
    end
)

addEventHandler("onResourceStop", resourceRoot,
    function ()
        for player, jailInfo in pairs(jailedPlayers) do
            savePlayerJailTime(player)
        end
    end
)

function savePlayerJailTime(player)
    if(jailedPlayers[player]) then
        local info = jailedPlayers[player]
        if(isTimer(info.timer)) then
            local timeLeft, _, _ = getTimerDetails(info.timer)
            local duration = math.floor(timeLeft/1000)
            if(duration > 5) then
                exports.MySQL:execute("UPDATE cnr__accounts SET jailtime=? WHERE username=?",duration, exports.USGaccounts:getPlayerAccount(player))
                exports.USGcnr_room:updatePlayerAccountData(player, "jailtime", duration)
            else
                exports.MySQL:execute("UPDATE cnr__accounts SET jailtime='0',jail=NULL WHERE username=?", exports.USGaccounts:getPlayerAccount(player))
                exports.USGcnr_room:updatePlayerAccountData(player, "jailtime", 0)
                exports.USGcnr_room:updatePlayerAccountData(player, "jail", nil)
            end
        else
            exports.MySQL:execute("UPDATE cnr__accounts SET jailtime='0',jail=NULL WHERE username=?", exports.USGaccounts:getPlayerAccount(player))
            exports.USGcnr_room:updatePlayerAccountData(player, "jailtime", 0)
            exports.USGcnr_room:updatePlayerAccountData(player, "jail", nil)                
        end
    end
end

addEvent("onPlayerExitRoom")
function onPlayerExitRoom(room)
    if(room == "cnr" and jailedPlayers[source]) then
        savePlayerJailTime(source)
        triggerClientEvent(source, "USGcnr_jail.onLeaveJail", source)
        if(isTimer(jailedPlayers[source].timer)) then
            killTimer(jailedPlayers[source].timer)
        end
        jailedPlayers[source] = nil
    end
end
addEventHandler("onPlayerExitRoom", root, onPlayerExitRoom)

function onPlayerQuit()
    savePlayerJailTime(source)
    jailedPlayers[source] = nil
end
addEventHandler("onPlayerQuit", root, onPlayerQuit)


addEvent("onPlayerHitJailMarker", true)
function onJailMarkerHit(hitElement, dimensions)
    if(getElementType(hitElement) ~= "player" or exports.USGrooms:getPlayerRoom(hitElement) ~= "cnr" or not dimensions) then return end
    local name = markerJail[source]
    if(name and jails[name]) then
        triggerEvent("onPlayerHitJailMarker", hitElement, name)
    end
end

function jailPlayer(player, duration, jail, jailedby)
    if(not isElement(player)) then return false end
    if(jailedPlayers[player] and isTimer(jailedPlayers[player].timer)) then
        local timeLeft, _,_ = getTimerDetails(jailedPlayers[player].timer)
        duration = duration + math.floor(timeLeft/1000)
        killTimer(jailedPlayers[player].timer)
    end
    jail = (jail and jails[jail]) and jail or "LV"
    jailedPlayers[player] = {}
    jailedPlayers[player].timer = setTimer(unjailPlayer, duration*1000, 1, player)
    jailedPlayers[player].jail = jail
    exports.MySQL:execute("UPDATE cnr__accounts SET jailtime=?,jail=? WHERE username=?",duration, jail, exports.USGaccounts:getPlayerAccount(player))
    if(isPedInVehicle(player)) then
        removePedFromVehicle(player)
    end
    setElementFrozen(player, true)
    setTimer(unfreezePlayer, 2000, 1, player)
    setElementDimension(player, JAIL_DIMENSION)
    setElementInterior(player, JAIL_INTERIOR)
    setElementPosition(player, JAIL_X, JAIL_Y, JAIL_Z)
    setElementRotation(player, 0,0, JAIL_ROT)
    exports.USGcnr_wanted:setPlayerWantedLevel(player, 0)
    triggerClientJailEvent(player, jailedby or "-", duration) -- bad solution to event not ready clientside
    addEventHandler("onPlayerSpawn", player, onJailedPlayerSpawn)
	toggleControl ( player, "fire", false )
	toggleControl ( player, "jump", false )
end

function unfreezePlayer(player)
    if(isElement(player)) then setElementFrozen(player,false) end
end
function triggerClientJailEvent(player, jailedby, duration)
    if(isElement(player)) then triggerClientEvent(player, "USGcnr_jail.onJailed", player, jailedby, duration) end
end

function isPlayerJailed(player)
    return jailedPlayers[player] ~= nil
end

function jailAccount(account, duration, jail)
    if(not account) then return false end
    local jail = (jail and jails[jail]) and jail or "LV"
    return exports.MySQL:execute("UPDATE cnr__accounts SET jailtime=jailtime+?,jail=? WHERE username=?",duration, jail, account)
end

function unjailPlayer(player)
    if(jailedPlayers[player]) then
        local jail = jails[jailedPlayers[player].jail] or jails.LV
        setElementDimension(player, exports.USGRooms:getRoomDimension("cnr"))
        setElementInterior(player, 0)
        setElementPosition(player, jail.x, jail.y, jail.z)
        setElementRotation(player, 0,0,jail.rot)
        if(isTimer(jailedPlayers[player].timer)) then
            killTimer(jailedPlayers[player].timer)
        end
        jailedPlayers[player] = nil
        exports.MySQL:execute("UPDATE cnr__accounts SET jailtime='0',jail=NULL WHERE username=?", exports.USGaccounts:getPlayerAccount(player))
        -- just in case it got saved from a restart
        exports.USGcnr_room:updatePlayerAccountData(player, "jailtime", 0)
        exports.USGcnr_room:updatePlayerAccountData(player, "jail", nil)

        triggerClientEvent(player, "USGcnr_jail.onLeaveJail", player)
        removeEventHandler("onPlayerSpawn", player, onJailedPlayerSpawn)
		toggleControl ( player, "fire", true )
		toggleControl ( player, "jump", true )
		
    end
end

function unjailPlayerOpenDoor(player)
    if(jailedPlayers[player]) then
        local jail = jails[jailedPlayers[player].jail] or jails.LV
        setElementDimension(player, exports.USGRooms:getRoomDimension("cnr"))
        setElementInterior(player, 0)
        if(isTimer(jailedPlayers[player].timer)) then
            killTimer(jailedPlayers[player].timer)
        end
        jailedPlayers[player] = nil
        exports.MySQL:execute("UPDATE cnr__accounts SET jailtime='0',jail=NULL WHERE username=?", exports.USGaccounts:getPlayerAccount(player))
        -- just in case it got saved from a restart
        exports.USGcnr_room:updatePlayerAccountData(player, "jailtime", 0)
        exports.USGcnr_room:updatePlayerAccountData(player, "jail", nil)

        triggerClientEvent(player, "USGcnr_jail.onLeaveJail", player)
        removeEventHandler("onPlayerSpawn", player, onJailedPlayerSpawn)
		toggleControl ( player, "fire", true )
		toggleControl ( player, "jump", true )
    end
end

function onJailedPlayerSpawn()
    if(jailedPlayers[source]) then
        setElementFrozen(source, true)
        setTimer(unfreezePlayer, 2000, 1, source)
        setElementDimension(source, JAIL_DIMENSION)
        setElementInterior(source, JAIL_INTERIOR)
        setElementPosition(source, JAIL_X, JAIL_Y, JAIL_Z)
        setElementRotation(source, 0,0, JAIL_ROT)
    end
end

addEventHandler("onPlayerSuicide", root, function () if(isPlayerJailed(source)) then
cancelEvent() 
end end) -- prevent suicide when arrested