------------------------------------------------------------------------------------
------------------------------------------------------------------------------------
--  RIGHTS:      All rights reserved by developer
--  FILE:        EventPanel/Event_s.lua
--  DEVELOPER:   Prime aka Kunal
------------------------------------------------------------------------------------
------------------------------------------------------------------------------------
addCommandHandler("event",
function (player)
    if exports.USGadmin:isPlayerMapManager(player) == true then
        triggerClientEvent(player,"openEventPanel",player)
    end
end)

---======================================================== CREATING EVENT ============================================================---

local eventPickups = {}
local WrapedPlayers = {}
local savePosition = {}
local warpLimit = 0
local wraps = 0
local eventWrap = false
local ex,ey,ez = 0,0,0
local interiorEvent = 0
local multipleWarps = false
local freezeOnWrap = false

addEvent( "Prime.createEvent", true )
function createEvent(limit, freezeOnWarp, multipleWarps)
    if (eventWrap == false ) then
        ex,ey,ez = getElementPosition(source)
        dimensionEvent = getElementDimension(source)
        interiorEvent = getElementInterior(source)
        warpLimit = limit
        WrapedPlayers = {}
        savePosition = {}
        wraps = 0
        eventWrap = true
        multipleWarps = multipleWarps
        freezeOnWrap = freezeOnWarp
        if ( freezeOnWarp ) then
            triggerClientEvent("onFreezeOnWarp", source)
        end
        exports.USGmsg:msg(root,"An event has been created, type /eventwarp to be warped to the event (limit: " .. warpLimit .. ")",  0, 255, 0, true)
    else
    exports.USGmsg:msg(root,"Already an event going on", root, 225, 0, 0, true) 
    end
end
addEventHandler("Prime.createEvent", root, createEvent)

function warpPerson(player)
    if (eventWrap == false) then return end
    if (WrapedPlayers[player] and multipleWarps == true) then
        exports.USGmsg:msg(player,"You have already used /eventwarp",  0, 255, 0, true)
        return
    end
    if (tonumber(wraps) < tonumber(warpLimit) and eventWrap) then
        if (not getPedOccupiedVehicle(player)) then
            if (not WrapedPlayers[player]) then
                local px,py,pz = getElementPosition(player)
                local pint = getElementInterior(player)
                local pdim = getElementDimension(player)
                savePosition[player] = {px, py, pz, pint, pdim}
            end
            setElementPosition(player, ex, ey, ez)
            setElementDimension(player, dimensionEvent)
            if (freezeOnWrap) then
                toggleAllControls ( player, false )
                setPedWeaponSlot(player, 0)
            end
            WrapedPlayers[player] = true
            wraps = wraps + 1
            triggerClientEvent("loadEventPlayers", root, player)
            triggerClientEvent("eventWarpUsed", root, wraps, warpLimit)
            if (tonumber(wraps) >= tonumber(warpLimit)) then
                exports.USGmsg:msg(root,"The event is now full", 0, 255, 0, true)
                multipleWarps = false
                eventWrap = false
                freezeOnWrap = false
            end
        end
    else
    exports.USGmsg:msg(root,"The event has reached the limit of " .. warpLimit .. " warps",  0, 255, 0, true)
    end
end 
addCommandHandler("eventwarp", warpPerson)

addEvent("Prime.stopEvent", true)
function stopEvent(player)
        if (eventWrap) then
            eventWrap = false
            multipleWarps = false
            freezeOnWrap = false
            exports.USGmsg:msg(root,getPlayerName(source).. " disabled Event warping", 0, 255, 0, true)
        end
end
addEventHandler("Prime.stopEvent", root, stopEvent) 
---=============================================================== EVENT VEHICLES =====================================================---

local eventVehicleMarker = {}
local markerData = {}
local markerCreator = {}
local eventVehicles = {}
local createTick = nil

addEvent("createVeh", true)
function createVeh ( eventVeh )
    local eventManager = getAccountName(getPlayerAccount(source))
    if ( eventManager ) then
        if ( isElement( eventVehicleMarker[eventManager] ) ) then 
            destroyElement( eventVehicleMarker[eventManager] ) 
        end
        local x, y, z = getElementPosition( source )
        eventVehicleMarker[eventManager] = createMarker( x, y, z - 1, "cylinder", 1.5, 225,225,225, 100 )
        setElementDimension( eventVehicleMarker[eventManager], getElementDimension( source ) )
        local theVehicleModel = getVehicleModelFromName( eventVeh )
        createTick = getTickCount()
        markerData[eventVehicleMarker[eventManager]] = theVehicleModel
        markerCreator[eventVehicleMarker[eventManager]] = eventManager
        setElementInterior( eventVehicleMarker[eventManager], getElementInterior( source ) )    
        --outputChatBox( "Created Vehicle marker ("..eventVeh..")", source, 0, 255, 255)
        addEventHandler( "onMarkerHit", eventVehicleMarker[eventManager], eventVehMarkerHit )
    end
end
addEventHandler( "createVeh", root, createVeh )

function eventVehMarkerHit ( eventVeh, matchingDimension )
    if ( matchingDimension ) then
        if ( createTick ) and ( getTickCount()-createTick < 3000 ) then
            return
        else
            if ( getElementType ( eventVeh ) == "player" ) and not ( isPedInVehicle( eventVeh ) ) then
                local theModel = markerData[source]
                local eventManager = markerCreator[source]
                if ( theModel ) and ( eventManager ) then
                    local x, y, z = getElementPosition( source )
                    local theVehicle = createVehicle( theModel, x, y, z +2 )
                    setElementDimension( theVehicle, getElementDimension( source ) )                    
                    setElementInterior( theVehicle, getElementInterior( source ) )              
                    warpPedIntoVehicle( eventVeh, theVehicle )
                    if not ( eventVehicles[eventManager] ) then eventVehicles[eventManager] = {} end
                    table.insert( eventVehicles[eventManager], theVehicle )
                end
            end
        end
    end
end

addEvent("destroyVehicleMarkers", true)
function destroyVehicleMarkers ( eventManager )
    local eventManager = getAccountName(getPlayerAccount(source))
    if ( isElement( eventVehicleMarker[eventManager] ) ) then 
        removeEventHandler( "onMarkerHit", eventVehicleMarker[eventManager], eventVehMarkerHit ) 
        destroyElement( eventVehicleMarker[eventManager] )
    end
    if ( eventVehicleMarker[eventManager] ) then eventVehicleMarker[eventManager] = {} end
end
addEventHandler( "destroyVehicleMarkers", root, destroyVehicleMarkers )
---======================================================== LOAD EVENT PLAYERS ============================================================---

addEvent("loadEventPlayers", true)
function loadEventPlayers(player)
    local eventPlayers = WrapedPlayers[player]
    triggerClientEvent("loadEventPlayers", root, eventPlayers)
end
addEventHandler("loadEventPlayers", root, loadEventPlayers)
---========================================================== EVENT PLAYER OUTPUT ==========================================================---

function outputEventPlayers( eventOutPut )
    for eventPlayers in pairs(WrapedPlayers) do
        exports.USGmsg:msg(eventPlayers, eventOutPut, 0, 255, 0)
    end
end
---========================================================== EVENT PLAYER JETPACK ==========================================================---

addEvent("eventGiveJetpack", true)
function eventGiveJetpack(eventSelectedPlr)
    if ( not doesPedHaveJetPack ( eventSelectedPlr ) ) then 
        givePedJetPack( eventSelectedPlr )
    else
        outputChatbox("Player already has a jetpack", source, 0, 225, 0 )
    end
end
addEventHandler("eventGiveJetpack", root, eventGiveJetpack )

addEvent("eventRemoveJetpack", true)
function eventRemoveJetpack(eventSelectedPlr)
    if ( doesPedHaveJetPack ( eventSelectedPlr ) ) then  
        removePedJetPack ( eventSelectedPlr )
    else
    exports.USGmsg:msg(source,"Player doesn't have jetpack" , 0, 225, 0 )
    end
end
addEventHandler("eventRemoveJetpack", root, eventRemoveJetpack )
---========================================================== EVENT PLAYER FREEZING ==========================================================---

addEvent("eventFeezePlayers", true)
function eventFeezePlayers()
    for eventPlayers in pairs(WrapedPlayers) do 
        toggleAllControls ( eventPlayers, false )
    end
    outputEventPlayers ( "Event Players have been frozen " )
end
addEventHandler("eventFeezePlayers", root, eventFeezePlayers )

addEvent("eventUnfreezePlayers", true)
function eventUnfreezePlayers()
    for eventPlayers in pairs(WrapedPlayers) do
        toggleAllControls ( eventPlayers, true )
    end
    outputEventPlayers ( "Event Players have been unfroze" )
end
addEventHandler("eventUnfreezePlayers", root, eventUnfreezePlayers )

addEvent("eventFeezePlayer", true)
function eventFeezePlayer(eventSelectedPlr)
    toggleAllControls ( eventSelectedPlr, false )
end
addEventHandler("eventFeezePlayer", root, eventFeezePlayer)

addEvent("eventUnfreezePlayer", true)
function eventUnfreezePlayer(eventSelectedPlr)
    toggleAllControls ( eventSelectedPlr, true )
end
addEventHandler("eventUnfreezePlayer", root, eventUnfreezePlayer)
---=====================================================  EVENT PLAYERS WEAPON SWITCH ===============================================================---

addEvent("weaponSwitch", true)
function weaponSwitch()
    for i, eventPlayers in ipairs(WrapedPlayers) do
        setPedWeaponSlot( eventPlayers, 0)
        outputEventPlayers ( "Weapon switching is disabled " )
    end
end
addEventHandler( "weaponSwitch", root, weaponSwitch )
---============================================================ EVENT VEHICLE FREEZING ========================================================---

addEvent("eventFreezeVehicle", true)
function eventFreezeVehicle(player)
    local eventManager = getAccountName(getPlayerAccount(source))
    if ( eventVehicles[eventManager] ) then
        for i, eventVeh in ipairs ( eventVehicles[eventManager] ) do
            setElementFrozen ( eventVeh, true )
        end
    end
    outputEventPlayers ( "Event Vehicles have been frozen" )
end
addEventHandler("eventFreezeVehicle", root, eventFreezeVehicle)

addEvent("eventUnfreezeVehicles", true)
function eventUnfreezeVehicles(player)
    local eventManager = getAccountName(getPlayerAccount(source))
    if ( eventVehicles[eventManager] ) then
        for i, eventVeh in ipairs ( eventVehicles[eventManager] ) do            
            setElementFrozen ( eventVeh, false )
        end
    end
    outputEventPlayers ( "Event Vehicles have been unfroze " )
end
addEventHandler("eventUnfreezeVehicles", root, eventUnfreezeVehicles)
---=================================================== EVENT VEHICLE LOCKS=================================================================---

addEvent("eventLockVehicles", true)
function eventLockVehicles()
    local eventManager = getAccountName(getPlayerAccount(source))
    if ( eventVehicles[eventManager] ) then
        for i, eventVeh in ipairs ( eventVehicles[eventManager] ) do                                             
            setVehicleLocked ( eventVeh, true )             
        end
    end
    outputEventPlayers ( "Event Vehicles have been locked " )
end
addEventHandler( "eventLockVehicles", root,  eventLockVehicles)

addEvent("eventUnlockVehicles", true)
function eventUnlockVehicles()
    local eventManager = getAccountName(getPlayerAccount(source))
    if ( eventVehicles[eventManager] ) then
        for i, eventVeh in ipairs ( eventVehicles[eventManager] ) do                                             
            setVehicleLocked ( eventVeh, false )            
        end
        outputEventPlayers ( "Event Vehicles have been unlocked " )
    end
end
addEventHandler( "eventUnlockVehicles", root, eventUnlockVehicles )
---===================================================== EVENT VEHICLE DAMAGE ===============================================================---

addEvent("eventEnableDamageProof", true)
function eventEnableDamageProof()
    local eventManager = getAccountName(getPlayerAccount(source))
    if ( eventVehicles[eventManager] ) then
        for i, eventVeh in ipairs ( eventVehicles[eventManager] ) do
            triggerClientEvent("eventEnableDamageProof",source,eventVeh)
        end
    end
    outputEventPlayers ( "Event Vehicles are now undamageable" )
end
addEventHandler("eventEnableDamageProof", root, eventEnableDamageProof)

addEvent("eventDisableDamageProof", true)
function eventDisableDamageProof()
    local eventManager = getAccountName(getPlayerAccount(source))
    if ( eventVehicles[eventManager] ) then
        for i, eventVeh in ipairs ( eventVehicles[eventManager] ) do
            triggerClientEvent("eventDisableDamageProof",source,eventVeh)
        end
    end
    outputEventPlayers ( "Event Vehicles are now damageable" )
end
addEventHandler("eventDisableDamageProof", root, eventDisableDamageProof)
---===================================================== EVENT VEHICLE FIX ===============================================================---

addEvent("eventFixVehicles", true)
function eventFixVehicles()
    local eventManager = getAccountName(getPlayerAccount(source))
    if ( eventVehicles[eventManager] ) then
        for i, eventVeh in ipairs ( eventVehicles[eventManager] ) do
            fixVehicle ( eventVeh )
        end
    end
    outputEventPlayers ( "Event Vehicles have been fixed" )
end
addEventHandler("eventFixVehicles", root, eventFixVehicles)
---===================================================== EVENT VEHICLE COLLISION ===============================================================---

addEvent("eventEnableCollision", true)
function eventEnableCollision()
    local eventManager = getAccountName(getPlayerAccount(source))
    if ( eventVehicles[eventManager] ) then
        for i, eventVeh in ipairs ( eventVehicles[eventManager] ) do
            triggerClientEvent("enableCollisions",source,eventVeh)
        end
    end
    outputEventPlayers ( "Event Vehicles collision is now enabled" )
end
addEventHandler( "eventEnableCollision", root, eventEnableCollision )

addEvent("eventDisableCollision", true)
function eventDisableCollision()
    local eventManager = getAccountName(getPlayerAccount(source))
    if ( eventVehicles[eventManager] ) then
        for i, eventVeh in ipairs ( eventVehicles[eventManager] ) do 
            triggerClientEvent("disableCollisions",source,eventVeh)
        end
    end
    outputEventPlayers ( "Event Vehicles collision is now disabled" )
end
addEventHandler( "eventDisableCollision", root, eventDisableCollision )
---====================================================== DESTROY EVENT VEHICLES==============================================================---

addEvent("destroyVehicles", true)
function destroyVehicles ( eventManager )
    local eventManager = getAccountName(getPlayerAccount(source))
    if ( eventVehicles[eventManager] ) then
        for i, eventVeh in ipairs ( eventVehicles[eventManager] ) do
            destroyElement( eventVeh )
        end
    end
    outputEventPlayers ( "Event Vehicles Vehicles have been destroyed" )
eventVehicles[eventManager] = {}
end
addEventHandler( "destroyVehicles", root, destroyVehicles )
---===================================================== CREATE EVENT PICKUPS ===============================================================---

addEvent("createHealth", true)
function createHealth ( theType )
    local eventManager = getAccountName(getPlayerAccount(source))
    if ( isElement ( source ) ) and ( eventManager ) then
        local x, y, z = getElementPosition( source )
            if ( eventPickups[eventManager] ) and ( isElement( eventPickups[eventManager] ) ) then destroyElement( eventPickups[eventManager] ) eventPickups[eventManager] = {} end
            eventPickups[eventManager] = createPickup ( x, y, z, 0, 100, 0 )
            setElementDimension( eventPickups[eventManager], getElementDimension( source ) )
            setElementInterior( eventPickups[eventManager], getElementInterior( source ) )
        end
    end
addEventHandler( "createHealth", root, createHealth )

addEvent("createArmourPickup", true)
function createArmourPickup ( theType )
    local eventManager = getAccountName(getPlayerAccount(source))
    if ( isElement ( source ) ) and ( eventManager ) then
        local x, y, z = getElementPosition( source )
            if ( eventPickups[eventManager] ) and ( isElement( eventPickups[eventManager] ) ) then 
                destroyElement( eventPickups[eventManager] ) eventPickups[eventManager] = {} 
            end
        eventPickups[eventManager] = createPickup ( x, y, z, 1, 100, 0 )
        setElementDimension( eventPickups[eventManager], getElementDimension( source ) )
        setElementInterior( eventPickups[eventManager], getElementInterior( source ) )
    end
end
addEventHandler( "createArmourPickup", root, createArmourPickup )

addEvent("destroyPickups", true)
function destroyPickups ()
    local eventManager = getAccountName(getPlayerAccount(source))
    if ( isElement ( source ) ) and ( eventManager ) then
        if ( eventPickups[eventManager] ) and ( isElement( eventPickups[eventManager] ) ) then 
            destroyElement( eventPickups[eventManager] ) 
            eventPickups[eventManager] = {} 
        end
    end
end
addEventHandler( "destroyPickups", root, destroyPickups )
---============================================================ RETURN EVENT PLAYERS ========================================================---

addEvent("returnPlayers", true)
function returnPlayers()
    for a,b in pairs(getElementsByType("player")) do
        if (WrapedPlayers[b]) then
            if (not savePosition[b]) then
                killPed(b)
                outputChatBox("You have been killed as your position wasn't saved", b, 0, 255, 0)
            end
            if (savePosition[b]) then
                local px,py,pz = savePosition[b][1],savePosition[b][2],savePosition[b][3]
                local pint = savePosition[b][4]
                local pdim = savePosition[b][5]
                if (pint >= 1) then
                    setElementInterior(b, pint, px, py, pz)
                else
                    setElementPosition(b, px, py, pz)
                end
                toggleAllControls ( b, true )
            end
            if (WrapedPlayers[b]) then WrapedPlayers[b] = nil end
            if (savePosition[b]) then savePosition[b] = nil end
            outputEventPlayers ( getPlayerName(source) .. " has returned you to your previous position")
        end
    triggerClientEvent("removeEventPlayers", root, b)
    end
end
addEventHandler("returnPlayers", root, returnPlayers)

addEvent("eventKickPlayer", true)
function eventKickPlayer(eventSelectedPlr)
    if (WrapedPlayers[eventSelectedPlr]) then
        if (not savePosition[eventSelectedPlr]) then
            killPed(eventSelectedPlr)
            outputChatBox(getPlayerName(source) .. " has Kicked you from the event", eventSelectedPlr, 225, 0, 0)
        end
        if (savePosition[eventSelectedPlr]) then
            local px,py,pz = savePosition[eventSelectedPlr][1],savePosition[eventSelectedPlr][2],savePosition[eventSelectedPlr][3]
            local pint = savePosition[eventSelectedPlr][4]
            local pdim = savePosition[eventSelectedPlr][5]
            if (pint >= 1) then
                setElementInterior(eventSelectedPlr, pint, px, py, pz)
            else
                setElementPosition(eventSelectedPlr, px, py, pz)
            end
            toggleAllControls ( eventSelectedPlr, true )
        end
        if (WrapedPlayers[eventSelectedPlr]) then WrapedPlayers[eventSelectedPlr] = nil end
        if (savePosition[eventSelectedPlr]) then savePosition[eventSelectedPlr] = nil end
        exports.USGmsg:msg( eventSelectedPlr ,getPlayerName(source) .. " has Kicked you from the event",  0, 255, 0)
    end
end
addEventHandler("eventKickPlayer", root, eventKickPlayer)

function leaveevent(plr)
    if (WrapedPlayers[plr]) then
        if (not savePosition[plr]) then
            killPed(plr)
            exports.USGmsg:msg(plr,"You have been killed as our position wasn't saved",  225, 0, 0)
        end
        if (savePosition[plr]) then
            local px,py,pz = savePosition[plr][1],savePosition[plr][2],savePosition[plr][3]
            local pint = savePosition[plr][4]
            local pdim = savePosition[plr][5]
            if (pint >= 1) then
                setElementInterior(plr, pint, px, py, pz)
            else
                setElementPosition(plr, px, py, pz)
            end
            toggleAllControls ( plr, true )
        end
        if (WrapedPlayers[plr]) then WrapedPlayers[plr] = nil end
        if (savePosition[plr]) then savePosition[plr] = nil end
        exports.USGmsg:msg(plr, "You have been returned to your previous position",  0, 255, 0)
    end
end
addCommandHandler("leaveevent", leaveevent )

