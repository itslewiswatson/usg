
local services = {
    {name="Police",id="police"},
    {name="Medic",id="medic"},
    {name="Mechanic",id="mechanic"},
    }
    
local gpsGUI = {}


function createGpsGUI()
    gpsGUI.window = exports.USGGUI:createWindow("center","center", 300, 430, false,"GPS")
    gpsGUI.playergrid = exports.USGGUI:createGridList("center","top",298,150,false,gpsGUI.window)
    exports.USGGUI:gridlistAddColumn(gpsGUI.playergrid, "Players", 1.0)
    gpsGUI.playersearch = exports.USGGUI:createEditBox("center",155,298,25,false,"",gpsGUI.window)
    addEventHandler("onUSGGUIChange",  gpsGUI.playersearch, gpssearchchange, false)
    gpsGUI.playermark = exports.USGGUI:createButton("left",183,145,25,false,"Mark",gpsGUI.window)
    gpsGUI.playerunmark = exports.USGGUI:createButton("right",183,145,25,false,"Unmark",gpsGUI.window)
    addEventHandler("onUSGGUISClick", gpsGUI.playermark, gpsmarkPlayer , false)
    addEventHandler("onUSGGUISClick", gpsGUI.playerunmark, gpsunmarkPlayer , false)
    gpsGUI.destination = exports.USGGUI:createLabel("center",210,298,35,false,"Destination\n", gpsGUI.window)
    gpsGUI.locgrid = exports.USGGUI:createGridList("center",250,298,150,false,gpsGUI.window)
    exports.USGGUI:gridlistAddColumn(gpsGUI.locgrid, "Locations", 1.0)  
    gpsGUI.locmark = exports.USGGUI:createButton("left",401, 145,24,false,"Mark",gpsGUI.window)
    gpsGUI.locunmark = exports.USGGUI:createButton("right",401, 145,24,false,"Unmark",gpsGUI.window)
    addEventHandler("onUSGGUISClick", gpsGUI.locmark, gpslocmark , false)
    addEventHandler("onUSGGUISClick", gpsGUI.locunmark, gpsunmarkPlayer , false)
end

function togglegpsGUI()
if(not exports.USGaccounts:isPlayerLoggedIn()) then return end
    if(isElement(gpsGUI.window )) then
        if(exports.USGGUI:getVisible(gpsGUI.window )) then
        exports.USGGUI:setVisible(gpsGUI.window , false)
            showCursor(false)
            exports.USGblur:setBlurDisabled()
            playerStats = {}
        else
            showCursor(true)
            exports.USGGUI:setVisible(gpsGUI.window , true)
            exports.USGblur:setBlurEnabled()
            gpsfillPlayerGrid()
            gpsfillLocationGrid()
        end
    else
        createGpsGUI()
        showCursor(true)
        exports.USGblur:setBlurEnabled()
        gpsfillPlayerGrid()
        gpsfillLocationGrid()
    end 
end 
addEvent("UserPanel.App.GPSApp",true)
addEventHandler("UserPanel.App.GPSApp",root,togglegpsGUI)

function gpsupdateDestination()
    local destination = exports.USGcnr_gps:getDestination()
    local destinationName = "none"
    if(destination) then
        destinationName = destination.name or "Unknown"
    end
    exports.USGGUI:setText(gpsGUI.destination, "Destination:\n"..destinationName)
end


function gpsRefresh()
    gpsfillPlayerGrid()
    gpsfillLocationGrid()
end

function gpsfillPlayerGrid()
    exports.USGGUI:gridlistClear(gpsGUI.playergrid)
    local filter = exports.USGGUI:getText(gpsGUI.playersearch)
    for i, player in ipairs(getElementsByType("player")) do
        local name = getPlayerName(player)
        if(player ~= localPlayer and (filter == "" or string.find(name:lower(), filter:lower()))) then
            local row = exports.USGGUI:gridlistAddRow(gpsGUI.playergrid)
            exports.USGGUI:gridlistSetItemText(gpsGUI.playergrid, row, 1, name)
            exports.USGGUI:gridlistSetItemData(gpsGUI.playergrid, row, 1, player)
        end
    end
end

function gpssearchchange ()
    gpsfillPlayerGrid()
end

function gpsmarkPlayer()
    local selected = exports.USGGUI:gridlistGetSelectedItem(gpsGUI.playergrid)
    if(selected) then
        local player = exports.USGGUI:gridlistGetItemData(gpsGUI.playergrid, selected, 1)
        if(isElement(player)) then
            exports.USGcnr_gps:setDestination(getPlayerName(player), player)
            gpsupdateDestination()
        else
            exports.USGmsg:msg("This player has quit.", 255,0,0)        
        end
    else
        exports.USGmsg:msg("You did not select a player.", 255,0,0)
    end
end

function gpsunmarkPlayer()
    exports.USGcnr_gps:removeDestination()
end


locations = {
    ["Ammunation"] = {
        {x = 2153.5986328125, y = 943.96484375, z = 10.8203125},
    },
    ["Police department"] = {
        {x = 2320.189453125, y = 2418.451171875, z = 10.470796585083}, -- LV
        {x = -1604.0625, y = 719.1123046875, z = 11.700479507446}, -- SF
        {x = 1537.74609375, y = -1671.3037109375, z = 13.546875}, -- LS
    },
    ["Fuel station"] = {
        {x = 2200.775390625, y = 2473.2236328125, z = 10.547392845154},
        {x = 2120.6484375, y = 948.8623046875, z = 10.540092468262},
    },
}

function gpsfillLocationGrid()
    exports.USGGUI:gridlistClear(gpsGUI.locgrid)
    local px,py,pz = getElementPosition(localPlayer)
    for type, typeLocations in pairs(locations) do
    local row = exports.USGGUI:gridlistAddRow(gpsGUI.locgrid)
        exports.USGGUI:gridlistSetItemText(gpsGUI.locgrid, row, 1, type)
    end
end

function gpslocmark()
    if(getElementInterior(localPlayer) ~= 0) then
        exports.USGmsg:msg("You can only set GPS when outside.", 255,0,0)
        return false
    end
    local selected = exports.USGGUI:gridlistGetSelectedItem(gpsGUI.locgrid)
    if(selected) then
        local locationType = exports.USGGUI:gridlistGetItemText(gpsGUI.locgrid, selected, 1)
        -- get closest location with this type
        local distance = false
        local closest = false
        local px,py,pz = getElementPosition(localPlayer)
        for i, location in ipairs(locations[locationType]) do
            local dist = getDistanceBetweenPoints2D(px,py,location.x,location.y)
            if(not closest or dist < distance) then
                closest = location
                distance = dist
            end
        end
        exports.USGcnr_gps:setDestination(exports.USGGUI:gridlistGetItemText(gpsGUI.locgrid, selected, 1), closest.x, closest.y, closest.z)
        gpsupdateDestination()
    else
        exports.USGmsg:msg("You did not select a location.", 255,0,0)
    end 
end