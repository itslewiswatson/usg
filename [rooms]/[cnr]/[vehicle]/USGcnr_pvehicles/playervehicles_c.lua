local screenW,screenH = guiGetScreenSize()
-- spectate vars
local spectating = false
local preSpecData = {}

-- confirm sell gui
local sellVehicleID

-- utility

function trim(s)
  return (s:gsub("^%s*(.-)%s*$", "%1"))
end

function getRelativeColor(percent)
	if percent > 60 then
		return 0,255,0
	elseif percent > 30 then
		return 255,255,0
	else
		return 255,0,0
	end
end

function getVehicleFuel(id)
	local vehicleFuel = vehicles[id].fuel
	if isElement(vehicles[id].element) then
		vehicleFuel = getElementData(vehicles[id].element,"vehicleFuel")
	end
	return tonumber(vehicleFuel) or 100
end

function getVehicleHealth(id)
	local vehicleHealth = vehicles[id].health
	if isElement(vehicles[id].element) then
		vehicleHealth = getElementHealth(vehicles[id].element)
	end
	return math.floor(tonumber(vehicleHealth)/10) or 100
end

function getVehiclePosition(id)
	local x,y,z = vehicles[id].x,vehicles[id].y,vehicles[id].z
	if isElement(vehicles[id].element) then
		x,y,z = getElementPosition(vehicles[id].element)
		 vehicles[id].x,vehicles[id].y,vehicles[id].z = x, y, z
	end
	return x,y,z
end

-- vehicle data management
local vehGUI = { btn = {} }
vehicles = {}
local pendingData = {}

function addPendingData(id, data)
	data.tick = getTickCount()
	if(pendingData[id] and getTickCount()-pendingData[id].tick < 3500) then
		for k,v in pairs(data) do
			pendingData[id][k] = v
		end
	else
		pendingData[id] = data
	end
end

addEvent("USGcnr_pvehicles.client.addVehicle", true)
function addVehicle(vehicle)
	vehicles[vehicle.id] = vehicle
	if(pendingData[vehicle.id] and getTickCount()-pendingData[vehicle.id].tick < 3500) then
		for k, v in pairs(pendingData[vehicle.id]) do
			vehicles[vehicle.id][k] = v
		end
	else
		pendingData[vehicle.id] = nil
	end
	updateVehicleGrid(vehicle.id)
end
addEventHandler("USGcnr_pvehicles.client.addVehicle", root, addVehicle)

addEvent("USGcnr_pvehicles.client.addVehicles", true)
function addVehicles(vehs)
	for i, vehicle in ipairs(vehs) do
		addVehicle(vehicle)
	end
end
addEventHandler("USGcnr_pvehicles.client.addVehicles", root, addVehicles)

addEvent("USGcnr_pvehicles.client.onVehicleSpawned", true)
function onVehicleSpawned(id)
	if(vehicles[id]) then
		vehicles[id].spawned = 1
		vehicles[id].element = source
		updateVehicleGrid(id)
	else
		addPendingData(id, {spawned = 1, element = source})
	end
end
addEventHandler("USGcnr_pvehicles.client.onVehicleSpawned", root, onVehicleSpawned)

addEvent("")

addEvent("USGcnr_pvehicles.client.onVehicleRepaired", true)
function onVehicleRepaired(id)
	if(vehicles[id]) then
		vehicles[id].health = 1000
		updateVehicleGrid(id)
	else
		addPendingData(id, {health = 1000})
	end
end
addEventHandler("USGcnr_pvehicles.client.onVehicleRepaired", root, onVehicleRepaired)

addEvent("USGcnr_pvehicles.client.onVehicleRemoved", true)
function onVehicleRemoved(id)
	if(vehicles[id]) then
		vehicles[id].spawned = 0
		vehicles[id].element = false
		updateVehicleGrid(id)
	else
		addPendingData(id, {spawned = 0, element = false})
	end
end
addEventHandler("USGcnr_pvehicles.client.onVehicleRemoved", root, onVehicleRemoved)

addEvent("USGcnr_pvehicles.client.onVehicleSold", true)
function onVehicleSold(id)
	vehicles[id] = nil
	if(isElement(vehGUI.grid)) then
		for id, vehicle in pairs(vehicles) do
			vehicle.row = nil
		end
		exports.USGGUI:gridlistClear(vehGUI.grid)
		loadVehicleGrid()
	end
end
addEventHandler("USGcnr_pvehicles.client.onVehicleSold", root, onVehicleSold)

-- GUI, general

function createGUI()
	vehGUI.window = exports.USGGUI:createWindow("center", "center", 510, 415, false, "Vehicle Management")

	vehGUI.grid = exports.USGGUI:createGridList("center",50,490,250,false,vehGUI.window)
	exports.USGGUI:gridlistAddColumn(vehGUI.grid, "Name", 0.25)
    exports.USGGUI:gridlistAddColumn(vehGUI.grid, "Plate",0.1)
    exports.USGGUI:gridlistAddColumn(vehGUI.grid, "Health",0.1)
    exports.USGGUI:gridlistAddColumn(vehGUI.grid, "Fuel",0.1)
    exports.USGGUI:gridlistAddColumn(vehGUI.grid, "Locked",0.1)
    exports.USGGUI:gridlistAddColumn(vehGUI.grid, "Location",0.3)
    for id, vehicle in pairs(vehicles) do
    	vehicle.row = nil
    end
	vehGUI.btn.tLock = exports.USGGUI:createButton(10, 330, 115, 30, false, "(un)Lock", vehGUI.window)
	vehGUI.btn.sell = exports.USGGUI:createButton(10, 370, 115, 30, false, "Sell", vehGUI.window)
	vehGUI.btn.tSpawn = exports.USGGUI:createButton(135, 330, 115, 30, false, "Spawn", vehGUI.window)
	vehGUI.btn.recover = exports.USGGUI:createButton(136, 370, 115, 30, false, "Recover", vehGUI.window)
	vehGUI.btn.tMark = exports.USGGUI:createButton(260, 330, 115, 30, false, "(un)Mark", vehGUI.window)
	vehGUI.btn.spectate = exports.USGGUI:createButton(259, 370, 115, 30, false, "Spectate",vehGUI.window)
	vehGUI.btn.repair = exports.USGGUI:createButton(385, 330, 115, 30, false, "Repair", vehGUI.window)
	vehGUI.btn.close = exports.USGGUI:createButton(385, 370, 115, 30, false, "Close", vehGUI.window)
	vehGUI.labelInfo1 = exports.USGGUI:createLabel(10, 20, 495, 30, false, "Your vehicles:", vehGUI.window)
	exports.USGGUI:setTextAlignment(vehGUI.labelInfo1,"center","center")
	vehGUI.labelInfo2 = exports.USGGUI:createLabel(10, 300, 240, 32, false, "Options:", vehGUI.window)
	exports.USGGUI:setTextAlignment(vehGUI.labelInfo2,"left","center")     
	addEventHandler("onUSGGUISClick",vehGUI.btn.tLock,onGUIClick, false)
	addEventHandler("onUSGGUISClick",vehGUI.btn.sell,onGUIClick, false)
	addEventHandler("onUSGGUISClick",vehGUI.btn.tSpawn,onGUIClick, false)
	addEventHandler("onUSGGUISClick",vehGUI.btn.recover,onGUIClick, false)
	addEventHandler("onUSGGUISClick",vehGUI.btn.tMark,onGUIClick, false)
	addEventHandler("onUSGGUISClick",vehGUI.btn.spectate,onGUIClick, false)
	addEventHandler("onUSGGUISClick",vehGUI.btn.repair,onGUIClick, false)
	addEventHandler("onUSGGUISClick",vehGUI.btn.close,onGUIClick, false)
end

addEvent("onPlayerJoinRoom", true)
addEventHandler("onPlayerJoinRoom", localPlayer,
	function (room)
		if(room == "cnr") then
			bindKey("F3","down",toggleGUI)
		end
	end
)

addEvent("onPlayerExitRoom", true)
addEventHandler("onPlayerExitRoom", localPlayer,
	function (prevRoom)
		if(prevRoom == "cnr") then
			unbindKey("F3","down",toggleGUI)
			if(isElement(vehGUI.window)) then
				if(exports.USGGUI:getVisible(vehGUI.window)) then
					toggleGUI()
				end	
				destroyElement(vehGUI.window)
			end
			if(isElement(sellConfirmDialog)) then destroyElement(sellConfirmDialog) end
			vehicles = {}
		end
	end
)
addEventHandler("onClientResourceStart", resourceRoot,
	function ()
		if(getResourceFromName("USGrooms") and getResourceState(getResourceFromName("USGrooms")) == "running" and exports.USGrooms:getPlayerRoom() == "cnr") then
			bindKey("F3","down",toggleGUI)
		end
	end
)

function updateVehicleGrid(id)
	if not vehicles[id] or not isElement(vehGUI.grid) then return false end
	if not vehicles[id].row then
		vehicles[id].row = exports.USGGUI:gridlistAddRow(vehGUI.grid)
	end
	local row = vehicles[id].row
	
	exports.USGGUI:gridlistSetItemText(vehGUI.grid,row,1,getVehicleNameFromModel(vehicles[id].model))
		if isElement(vehicles[id].element) then 
			exports.USGGUI:gridlistSetItemColor(vehGUI.grid,row,1,tocolor(0,255,0))
		else 
			exports.USGGUI:gridlistSetItemColor(vehGUI.grid,row,1,tocolor(255,0,0))
		end
		
	exports.USGGUI:gridlistSetItemText(vehGUI.grid,row,2,vehicles[id].plate or "")
	
	local health = getVehicleHealth(id)
	exports.USGGUI:gridlistSetItemText(vehGUI.grid,row,3,health.."%")
		exports.USGGUI:gridlistSetItemColor(vehGUI.grid,row,3,tocolor(getRelativeColor(health)))
		
	local fuel = getVehicleFuel(id)
	exports.USGGUI:gridlistSetItemText(vehGUI.grid,row,4,getVehicleFuel(id).."%")
		exports.USGGUI:gridlistSetItemColor(vehGUI.grid,row,4,tocolor(getRelativeColor(fuel)))
	
	local lr,lg,lb = 0,255,0
	local lockedString = "Yes"
	if vehicles[id].locked == 0 then
		lockedString = "No"
		lr,lg,lb = 255,0,0
	end
	exports.USGGUI:gridlistSetItemText(vehGUI.grid,row,5,lockedString)
		exports.USGGUI:gridlistSetItemColor(vehGUI.grid,row,5,tocolor(lr,lg,lb))
	exports.USGGUI:gridlistSetItemText(vehGUI.grid,row,6,getZoneName(getVehiclePosition(id)))
		
	exports.USGGUI:gridlistSetItemData(vehGUI.grid,row,1,id)	
end

function loadVehicleGrid()
	for id, vehicle in pairs(vehicles) do
		updateVehicleGrid(id)
	end
end

function toggleGUI()
	if(not isElement(vehGUI.window)) then
		createGUI()
		loadVehicleGrid()
		showCursor(true)
	elseif(exports.USGGUI:getVisible(vehGUI.window)) then
		showCursor(false)
		exports.USGGUI:setVisible(vehGUI.window, false)
	else
		loadVehicleGrid()
		showCursor(true)
		exports.USGGUI:setVisible(vehGUI.window, true)
	end
end

function getSelectedVehicle()
	local selected = exports.USGGUI:gridlistGetSelectedItem(vehGUI.grid)
	if(selected) then
		local id = exports.USGGUI:gridlistGetItemData(vehGUI.grid,selected,1)
		return id
	else
		return false
	end
end

local antiButtonSpamTimer

function onGUIClick()
	local vehID = getSelectedVehicle()
	if source == vehGUI.btn.close then
		toggleGUI()
	elseif source == vehGUI.btn.spectate and spectating then
		stopSpectating()
	elseif vehID then
		if isTimer(antiButtonSpamTimer) then
			exports.USGmsg:msg("Please wait before using the buttons again.",255,0,0)
			return false
		end
		local vehicleElement = vehicles[vehID].element
		local vehicleName = getVehicleNameFromModel(vehicles[vehID].model)
		local vehicleLocked = vehicles[vehID].locked or 0
		if isElement(vehicleElement) then
			vehicleLocked = isVehicleLocked(vehicleElement)
		else 
			vehicleElement = false
		end
		if source == vehGUI.btn.tSpawn then
			triggerServerEvent("USGcnr_pvehicles.spawnVehicle",localPlayer,vehID)
		elseif source == vehGUI.btn.sell then
			openSellConfirmGUI(vehID,vehicleName,getVehicleSellPrice(vehicles[vehID].boughtprice))
		elseif source == vehGUI.btn.tMark then
			if isElement(vehicles[vehID].blip) then
				destroyElement(vehicles[vehID].blip)
				exports.USGmsg:msg("Your "..vehicleName.." has been unmarked from the map!",0,255,0)
			elseif vehicleElement then
				vehicles[vehID].blip = createBlipAttachedTo(vehicleElement, 53)
				exports.USGmsg:msg("Your "..vehicleName.." has been marked on the map!",0,255,0)
			else
				exports.USGmsg:msg("This vehicle is not spawned!",255,0,0)
			end
		elseif source == vehGUI.btn.repair then
			triggerServerEvent("USGcnr_pvehicles.repairVehicle",localPlayer,vehID)
		elseif source == vehGUI.btn.recover then
			triggerServerEvent("USGcnr_pvehicles.recoverVehicle",localPlayer,vehID)
		elseif source == vehGUI.btn.spectate then
			if not spectating then -- only attempt when it's the last in table
				if vehicleElement then
					if isPedOnGround(localPlayer) then
						setElementFrozen(localPlayer,true)
						preSpecData.int = getElementInterior(localPlayer)
						preSpecData.dim = getElementDimension(localPlayer)
						setElementDimension(localPlayer,getElementDimension(vehicleElement))
						setElementInterior(localPlayer,getElementInterior(vehicleElement))
						addEventHandler("onClientRender",root,specateVehicleOnRender)
						spectating = vehID
						exports.USGmsg:msg("You are now spectating your "..vehicleName.."!",0,255,0)
					else
						exports.USGmsg:msg("You have to be on the ground to spectate!",255,0,0)
					end
				else
					exports.USGmsg:msg("This vehicle is not spawned!",255,0,0)
				end
			end
		end
		for k,btn in pairs(vehGUI.btn) do -- if any button was clicked, start antiSpam timer
			if(btn == source) then
				if(isTimer(antiButtonSpamTimer)) then killTimer(antiButtonSpamTimer) end
				antiButtonSpamTimer = setTimer(function () end, 350,1)
				break
			end
		end
	else
		exports.USGmsg:msg("You didn't select a vehicle!", 255, 0, 0)
	end
end

-- spectating

local facing = 0
local zoom = 16
local zoomDuration = 12500
local zoomStart
-- 50p
function specateVehicleOnRender()
	if(spectating and isElement(vehicles[spectating].element)) then
		local tick = getTickCount()
		if not zoomStart or tick >= zoomDuration+zoomStart then
			zoomStart = tick
		end
		local zoomProgress = (getTickCount()-zoomStart)/zoomDuration
		local zoom = interpolateBetween(8,0,0,18,0,0,zoomProgress,"SineCurve")
		
		local x,y,z = getElementPosition(vehicles[spectating].element)
		local multiplier = zoom
		local vehType = getVehicleType( vehicles[spectating].element)
		local camX = x + math.cos( facing / math.pi * 180 ) * multiplier
		local camY = y + math.sin( facing / math.pi * 180 ) * multiplier
		facing = facing + 0.0001
		setCameraMatrix(camX,camY,z+3,x,y,z)
	else
		stopSpectating(false)
	end
end

function stopSpectating(onStop)
	if spectating then
		if not onStop then
			setTimer(setElementFrozen,3500,1,localPlayer,false)
		else
			local x,y,z = getElementPosition(localPlayer)
			setElementPosition(localPlayer,x,y,z+10) -- cant use timers :/
			setElementFrozen(localPlayer,false)
		end
		setElementDimension(localPlayer,preSpecData.dim)
		setElementInterior(localPlayer,preSpecData.int)
		removeEventHandler("onClientRender",root,specateVehicleOnRender)
		spectating = false
		setCameraTarget(localPlayer)
		exports.USGmsg:msg("You have stopped spectating!",0,255,0)	
	end
end
addEventHandler("onClientResourceStop",resourceRoot,stopSpectating)

-- selling

-- confirm sell gui
local sellVehicleID
local sellConfirmDialog

function openSellConfirmGUI(id, name, price)
    if(isElement(sellConfirmDialog)) then destroyElement(sellConfirmDialog) end
    sellVehicleID = id
    
  	sellConfirmDialog = exports.USGGUI:createDialog("Sell "..name.."?", "Are you sure you want to sell your "..name.." for "..exports.USG:formatMoney(price).."?", "confirm")
    addEventHandler("onUSGGUIDialogFinish", sellConfirmDialog, onSellDialogFinish, false)
end

function onSellDialogFinish(result)
	if(result) then
	    if sellVehicleID and vehicles[sellVehicleID] then
	        triggerServerEvent("USGcnr_pvehicles.sellVehicle", localPlayer, sellVehicleID)
			-- Check if there is a blip for that vehicle, and delete it if there is
			if (vehicles[sellVehicleID].blip) then
				destroyElement(vehicles[sellVehicleID].blip)
			end
	    end
	    sellVehicleID = false
	end
end