local TYPE_V = 1
local TYPE_R = 0

local spawners = {}
local markerSpawner = {}
local selectedSpawner = false
local selectedRotation = 0
local markerVehicleRotation = {}
local vehiclePickerGUI = {}

function addSpawner(markers, vehicles, spawnerInfo, isVSpawner)
	if(type(markers) == "table" and type(vehicles) == "table" and type(spawnerInfo) == "table" and spawnerInfo.name) then
		spawnerInfo.resource = getResourceName(sourceResource)
		removeSpawner(spawnerInfo.name)
		if(isVSpawner) then
			spawners[spawnerInfo.name] = {vehicles = vehicles, spawnerInfo = spawnerInfo, zones = {}, type = TYPE_V}
			initVSpawner(spawnerInfo.name)
		else
			spawners[spawnerInfo.name] = {markers = {}, vehicles = vehicles, spawnerInfo = spawnerInfo, type = TYPE_R}
			for _, marker in ipairs(markers) do
				local r,g,b,a = marker.r or markers.r, marker.g or markers.g, marker.b or markers.b, marker.a or markers.a
				local element = createMarker(marker.x, marker.y, marker.z-1, "cylinder", 2, r or 0, g or 0, b or 255, a or 180)
				addEventHandler("onClientMarkerHit", element, vehicleMarkerHit)
				addEventHandler("onClientMarkerLeave", element, vehicleMarkerExit)
				setElementDimension(element, exports.USGrooms:getRoomDimension("cnr"))
				table.insert(spawners[spawnerInfo.name].markers, element)
				markerSpawner[element] = spawners[spawnerInfo.name]
				markerVehicleRotation[element] = marker.vehRotation
			end
		end
		return true
	else
		error("invalid syntax, addSpawner(markers, vehicles, spawnerInfo)")
	end
end

function vehicleMarkerHit(hitElement, matchingDimensions)
	if(hitElement ~= localPlayer or not matchingDimensions or isPedInVehicle(localPlayer)) then return end
	local _,_,z = getElementPosition(localPlayer)
	local mx,my,mz = getElementPosition(source)
	if(math.abs(z-mz) >= 2) then return end
	if(not markerSpawner[source]) then return end
	openVehicleGUI()
	selectedSpawner = markerSpawner[source]
	selectedRotation = markerVehicleRotation[source]
	exports.USGGUI:gridlistClear(vehiclePickerGUI.grid)
	for i, vehicle in ipairs(selectedSpawner.vehicles) do
		local row = exports.USGGUI:gridlistAddRow(vehiclePickerGUI.grid)
		exports.USGGUI:gridlistSetItemText(vehiclePickerGUI.grid, row, 1, vehicle.name or getVehicleNameFromModel(vehicle.model))
		exports.USGGUI:gridlistSetItemData(vehiclePickerGUI.grid, row, 1, {model = vehicle.model, 
			color = {vehicle.r,vehicle.g,vehicle.b,vehicle.r2,vehicle.g2,vehicle.b2}, zOffset = vehicle.zOffset})
	end
end

function vehicleMarkerExit(hitElement)
	if(hitElement == localPlayer) then closeVehicleGUI() end
end

function removeSpawner(spawnerName)
	local spawner = spawners[spawnerName]
	if(spawner) then
		if(spawner.type == TYPE_R) then
			for i, marker in ipairs(spawner.markers) do
				if(isElement(marker)) then
					destroyElement(marker)
				end
				markerVehicleRotation[marker] = nil
			end
		elseif(spawner.type == TYPE_V) then
			for i, zone in ipairs(spawner.zones) do
				if(isElementWithinColShape(localPlayer, zone)) then
					onVZoneLeave(localPlayer, getElementDimension(zone) == getElementDimension(localPlayer))
				end
				destroyElement(zone) -- also destroys child object vehicle
			end
		end
	end
	if(selectedSpawner and selectedSpawner.name == spawnerName and selectedSpawner.type == TYPE_R) then
		closeVehicleGUI()
	end
	spawners[spawnerName] = nil
end

addEvent("onPlayerExitRoom", true)
function onPlayerExitRoom(prevRoom)
	if(prevRoom == "cnr") then
		for spawnerName, _ in pairs(spawners) do
			removeSpawner(spawnerName)
		end
	end
end
addEventHandler("onPlayerExitRoom", localPlayer, onPlayerExitRoom)

function createVehicleGUI()
	vehiclePickerGUI.window = exports.USGGUI:createWindow("center","center",200,300,false,"Spawn vehicles")
	vehiclePickerGUI.grid = exports.USGGUI:createGridList("center",5,190,260,false,vehiclePickerGUI.window)
	exports.USGGUI:gridlistAddColumn(vehiclePickerGUI.grid, "Vehicle", 1.0)
	vehiclePickerGUI.cancel = exports.USGGUI:createButton(5,270,70,25,false,"Cancel",vehiclePickerGUI.window)
	addEventHandler("onUSGGUISClick", vehiclePickerGUI.cancel, closeVehicleGUI, false)	
	vehiclePickerGUI.spawn = exports.USGGUI:createButton(125,270,70,25,false,"Spawn",vehiclePickerGUI.window)
	addEventHandler("onUSGGUISClick", vehiclePickerGUI.spawn, onSpawnVehicle, false)
end

function openVehicleGUI()
	if(not isElement(vehiclePickerGUI.window)) then
		createVehicleGUI()
		showCursor(true)
	elseif(not exports.USGGUI:getVisible(vehiclePickerGUI.window)) then
		exports.USGGUI:setVisible(vehiclePickerGUI.window,true)
		showCursor(true)
	end
	setControlState("forwards", false)
end

function closeVehicleGUI()
	selectedSpawner = false
	selectedRotation = 0
	if(isElement(vehiclePickerGUI.window) and exports.USGGUI:getVisible(vehiclePickerGUI.window)) then
		showCursor(false)
		exports.USGGUI:setVisible(vehiclePickerGUI.window, false)
	end
end

function onSpawnVehicle()
	local selected = exports.USGGUI:gridlistGetSelectedItem(vehiclePickerGUI.grid)
	if(selected) then
		local vehicleInfo = exports.USGGUI:gridlistGetItemData(vehiclePickerGUI.grid, selected, 1)
		triggerServerEvent("USGcnr_vehiclespawners.spawnVehicle", localPlayer, vehicleInfo.model, selectedRotation or 0, vehicleInfo.color, vehicleInfo.zOffset, selectedSpawner.spawnerInfo)
		closeVehicleGUI()
	end
end

-- new spawner method
local zoneSpawner = {}
local inVZoneCount = 0
local currentVZone
function initVSpawner(name)
	if(spawners[name]) then
		local spawner = spawners[name]
		for i, vehicle in ipairs(spawner.vehicles) do
			local color = {vehicle.r,vehicle.g,vehicle.b,vehicle.r2,vehicle.g2,vehicle.b2}
			if(vehicle.positions) then
				for i, position in ipairs(vehicle.positions) do
					createVSpawner(name, position.x, position.y, position.z, position.rz, vehicle.model, color)
				end
			end
		end
	end
end

function createVSpawner(name, x, y, z, rz, model, color)
	local vehicle = createVehicle(model, x, y, z, 0, 0, rz)
	setElementFrozen(vehicle, true)
	if(color and color[1]) then
		local r,g,b,r2,g2,b2,r3,g3,b3,r4,g4,b4 = getVehicleColor(vehicle, true)
		outputDebugString("Setting color [1] = "..tostring(color[1]))
		outputDebugString("Setting color [2] = "..tostring(color[2]))
		outputDebugString("Setting color [3] = "..tostring(color[3]))
		setVehicleColor(vehicle, color[1] or r,color[2] or g,color[3] or b,245,245,245)
	end
	setElementCollisionsEnabled(vehicle, false)
	local zone = createColSphere(x, y, z, 2.5)
	setElementParent(vehicle, zone)
	zoneSpawner[zone] = name
	addEventHandler("onClientColShapeHit", zone, onVZoneHit)
	addEventHandler("onClientColShapeLeave", zone, onVZoneLeave)
	table.insert(spawners[name].zones, zone)
end

function onAttemptEnterV()
	if(isPedInVehicle(localPlayer) or not isElement(currentVZone) or not isElementWithinColShape(localPlayer, currentVZone)) then return end
	local spawnerName = zoneSpawner[currentVZone]
	if(spawnerName) then
		local spawner = spawners[spawnerName]
		if(spawner) then
			local vehicle = getElementChild(currentVZone, 0)
			local model = getElementModel(vehicle)
			local _, _, rz = getElementRotation(vehicle)
			local color = {getVehicleColor(vehicle, true)}
			local x,y,z = getElementPosition(vehicle)
			triggerServerEvent("USGcnr_vehiclespawners.spawnVehicleV", localPlayer, x, y, z, rz or 0, model, color, spawner.spawnerInfo)
		end
	end
end

function onVZoneHit(hitElement, dimensions)
	if(hitElement == localPlayer) then
		if(inVZoneCount == 0) then
			bindKey("enter_exit", "down", onAttemptEnterV)
		end
		currentVZone = source
		inVZoneCount = inVZoneCount + 1
	end
end

function onVZoneLeave(hitElement, dimensions)
	if(hitElement == localPlayer) then
		inVZoneCount = inVZoneCount - 1
		if(inVZoneCount == 0) then
			currentVZone = false
			unbindKey("enter_exit", "down", onAttemptEnterV)
		end
	end
end
