local screenWidth, screenHeight = guiGetScreenSize()
local chatLayout = getChatboxLayout()

local LIST_HEIGHT = 400
local LIST_Y = (screenHeight-LIST_HEIGHT-30)/2

local markerLocation = {}
local blips = {}

function createShops()
    for i, location in ipairs(locations) do
		local blipID
		if (location.type_) then
			if (location.type_ == "car") then
				blipID = 55
			elseif (location.type_ == "bike") then
				blipID = 55 -- Need to add one for bikes
			elseif (location.type_ == "aircraft") then
				blipID = 5
			elseif (location.type_ == "boat") then
				blipID = 9
			end
		end
		
        local marker = createMarker(location.x,location.y,location.z-1, "cylinder",2, 150,255,0,170)
        addEventHandler("onClientMarkerHit", marker, onShopMarkerHit)
        markerLocation[marker] = i
        local blip = createBlip(location.x, location.y, location.z, blipID, 2, 255,255,255,255,0,400)
        exports.USGcnr_blips:setBlipDimension(blip, 0)
        exports.USGcnr_blips:setBlipUserInfo(blip, "Shops", "Vehicle shop")
        exports.USGcnr_blips:setBlipVisibleDistance(blip, 300)
        table.insert(blips, blip)
    end
end

function removeShops()
    for i, blip in ipairs(blips) do
        destroyElement(blip)
    end
    blips = {}
    for marker, location in pairs(markerLocation) do
        if(isElement(marker)) then
            destroyElement(marker)
        end
    end
    markerLocation = {}
end

addEvent("onPlayerJoinRoom", true)
addEventHandler("onPlayerJoinRoom", localPlayer,
    function (room)
        if(room == "cnr") then
            createShops()
        end
    end
)
addEvent("onPlayerExitRoom", true)
addEventHandler("onPlayerExitRoom", localPlayer,
    function (prevRoom)
        if(prevRoom == "cnr") then
            removeShops()
            closeShop()
        end
    end
)
addEventHandler("onClientResourceStart", resourceRoot,
    function ()
        if(getResourceFromName("USGrooms") and getResourceState(getResourceFromName("USGrooms")) == "running" and exports.USGrooms:getPlayerRoom() == "cnr") then
            createShops()
        end
    end
)

addEventHandler("onClientResourceStop", resourceRoot,
    function ()
        closeShop()
    end
)

local shopping = false
local shopGUI = {}
local shopLocation

function onShopMarkerHit(hitElement, dimensions)
    if(not dimensions or hitElement ~= localPlayer) then return end
    if(not exports.USG:validateMarkerZ(source, hitElement) or isPedInVehicle(localPlayer)) then return end
    local location = markerLocation[source]
    local location = locations[location]
    location.i = markerLocation[source]
    openShop(location)
end

function insertTableVehicles(tab)
    for i, vehicleID in ipairs(tab) do
        if(type(vehicleID) == "table") then
            insertTableVehicles(vehicleID)
        else
            local name = getVehicleNameFromModel(vehicleID)
            local price = getVehiclePrice(vehicleID)
            local row = exports.USGGUI:gridlistAddRow(shopGUI.list)
            exports.USGGUI:gridlistSetItemText(shopGUI.list, row, 1, name)
            exports.USGGUI:gridlistSetItemText(shopGUI.list, row, 2, price and exports.USG:formatMoney(price) or "unknown")
            exports.USGGUI:gridlistSetItemSortIndex(shopGUI.list, row, 2, price or -1)
            exports.USGGUI:gridlistSetItemData(shopGUI.list, row, 1, vehicleID)
        end
    end
end

function openShop(location)
    if(not shopping) then
        shopping = true
        shopLocation = location
        shopGUI.list = exports.USGGUI:createGridList(5,LIST_Y, 200, LIST_HEIGHT,false,false,tocolor(0,0,0,220))
        exports.USGGUI:gridlistAddColumn(shopGUI.list, "Name", 0.65)
        exports.USGGUI:gridlistAddColumn(shopGUI.list, "Price", 0.35)
        addEventHandler("onUSGGUISClick", shopGUI.list, onListClick, false)
        shopGUI.close = exports.USGGUI:createButton(5,LIST_Y+LIST_HEIGHT, 70, 30, false, "Close")
        addEventHandler("onUSGGUISClick", shopGUI.close, closeShop, false)
        shopGUI.buy = exports.USGGUI:createButton(135,LIST_Y+LIST_HEIGHT, 70, 30, false, "Buy")
        addEventHandler("onUSGGUISClick", shopGUI.buy, onBuyVehicle, false)
        insertTableVehicles(location.vehicles)
        showCursor(true)
        showChat(false)
        showPlayerHudComponent("radar", false)
        openEditor()
    end
end

addEvent("USGcnr_vehicleshops.closeShop", true)
function closeShop()
    if(shopping) then
        shopping = false
        for k, gui in pairs(shopGUI) do
            destroyElement(gui)
        end
        showCursor(false)
        if(isElement(confirmPurchaseDialog)) then destroyElement(confirmPurchaseDialog) end
        stopPreview()
        closeEditor()
        showChat(true)
        showPlayerHudComponent("radar", true)
    end
end
addEventHandler("USGcnr_vehicleshops.closeShop", localPlayer, closeShop)

function onListClick()
    local selected = exports.USGGUI:gridlistGetSelectedItem(shopGUI.list)
    if(selected) then
        local ID = exports.USGGUI:gridlistGetItemData(shopGUI.list, selected, 1)
        setPreviewVehicle(ID)
    end
end

local pendingPurchase
local confirmPurchaseDialog

function onBuyVehicle()
    local selected = exports.USGGUI:gridlistGetSelectedItem(shopGUI.list)
    if(selected) then
        local ID = exports.USGGUI:gridlistGetItemData(shopGUI.list, selected, 1)
        pendingPurchase = ID
        local name = exports.USGGUI:gridlistGetItemText(shopGUI.list, selected, 1)
        local price = exports.USGGUI:gridlistGetItemText(shopGUI.list, selected, 2)
        confirmPurchaseDialog = exports.USGGUI:createDialog("Buy a vehicle", "Are you sure you want to buy a "..name.." for "..price.."?", "confirm")
        addEventHandler("onUSGGUIDialogFinish", confirmPurchaseDialog, onPurchaseDialogFinish, false)
    end
end

function onPurchaseDialogFinish(result)
    if(result) then
        local r1,g1,b1,r2,g2,b2 = getPreviewColor()
        triggerServerEvent("USGcnr_vehicleshops.purchaseVehicle", localPlayer, pendingPurchase, shopLocation.i, getPlateText(), r1,g1,b1,r2,g2,b2)
    end
end

-- vehicle preview
function getPointFromDistanceRotation(x, y, dist, angle)
    local a = math.rad(90 - angle);
    local dx = math.cos(a) * dist;
    local dy = math.sin(a) * dist;
    return x+dx, y+dy;
end

local previewing = false
local previewVehicle
local animation = false

function setPreviewVehicle(id)
    fadeCamera(false, 0.5)
    if(isElement(previewVehicle)) then destroyElement(previewVehicle) end
    local position = shopLocation.preview
    previewVehicle = createVehicle(id, position.x, position.y, position.z, 0, 0, position.rz)
    if(position.vx or position.vy or position.vz) then
    --  setElementVelocity(previewVehicle, shopLocation.preview.vx or 0, shopLocation.preview.vy or 0, shopLocation.preview.vz or 0)
    --  setElementRotation(previewVehicle, 0, 0, position.rz)
    end

    if(not previewing) then
        setCameraMatrix(unpack(position.camera))
        previewing = true
    end
    fadeCamera(true, 1)
end

function stopPreview()
    if(previewing) then
        if(isElement(previewVehicle)) then destroyElement(previewVehicle) end
        previewing = false
        setCameraTarget(localPlayer)
    end
end

function getPreviewColor()
    local r1,g1,b1,r2,g2,b2,r3,g3,b3,r4,g4,b4 = getVehicleColor(previewVehicle, true)
    return r1,g1,b1,r2,g2,b2
end

-- editor
local editorGUI = {}
local editing = false
local editColorPicker
local editingColo

function getPlateText()
    local txt = exports.USGGUI:getText(editorGUI.plate)
    if(#txt == 0) then txt = "   USG  "
    elseif(#txt > 8) then txt = text:sub(1,8) end
    return txt
end

function openEditor()
    if(not editing) then
        editing = true
        editorGUI.window = exports.USGGUI:createWindow("right", "center", 200,90,false,"Edit your vehicle")
        editorGUI.plateLabel = exports.USGGUI:createLabel(5,5,80,25,false,"License plate: ",editorGUI.window)
        editorGUI.plate = exports.USGGUI:createEditBox(90,5,100,25,false,"",editorGUI.window)
        editorGUI.color1 = exports.USGGUI:createButton(5,45,80,30,false,"Primary color", editorGUI.window)
        addEventHandler("onUSGGUISClick", editorGUI.color1, onEditColor, false)
        editorGUI.color2 = exports.USGGUI:createButton(115,45,80,30,false,"Secondary color", editorGUI.window)
        addEventHandler("onUSGGUISClick", editorGUI.color2, onEditColor, false)
        addEventHandler("onColorPickerChange", resourceRoot, onColorPickerChange)
        addEventHandler("onPickColor", resourceRoot, onColorPicked)
        addEventHandler("onCancelPickColor", resourceRoot, onColorPickerCanceled)
    end
end

function onEditColor()
    if(editColorPicker) then exports.USGcolorpicker:closePicker(editColorPicker) end -- close previous
    editingColor = source == editorGUI.color1 and 1 or 2
    editColorPicker = exports.USGcolorpicker:openPicker("Vehicle color "..editingColor)
end

function closeEditor()
    if(editing) then
        editing = false
        destroyElement(editorGUI.window)
        if(editColorPicker) then exports.USGcolorpicker:closePicker(editColorPicker) end
        removeEventHandler("onColorPickerChange", resourceRoot, onColorPickerChange)
        removeEventHandler("onPickColor", resourceRoot, onColorPicked)
        removeEventHandler("onCancelPickColor", resourceRoot, onColorPickerCanceled)        
    end
end

function onColorPickerChange(ID, r,g,b,a)
    local r1,g1,b1,r2,g2,b2,r3,g3,b3,r4,g4,b4 = getVehicleColor(previewVehicle, true)
    if(editingColor == 1) then
        setVehicleColor(previewVehicle,r,g,b,r2,g2,b2,r3,g3,b3,r4,g4,b4)
    elseif(editingColor == 2) then
        setVehicleColor(previewVehicle,r1,g1,b1,r,g,b,r3,g3,b3,r4,g4,b4)
    end
end

function onColorPicked(ID, r,g,b,a)
    local r1,g1,b1,r2,g2,b2,r3,g3,b3,r4,g4,b4 = getVehicleColor(previewVehicle, true)
    if(editingColor == 1) then
        setVehicleColor(previewVehicle,r,g,b,r2,g2,b2,r3,g3,b3,r4,g4,b4)
    elseif(editingColor == 2) then
        setVehicleColor(previewVehicle,r1,g1,b1,r,g,b,r3,g3,b3,r4,g4,b4)
    end
    editColorPicker = false
    editingColor = false
end

function onColorPickerCanceled(ID)
    editColorPicker = false
    editingColor = false
end



addEvent("onColorPickerChange")
addEvent("onPickColor")
addEvent("onCancelPickColor")