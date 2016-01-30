locations =
{
	{ 76.698150634766, -244.18774414063, 1.5, "" },
	{ 1348.78, 355.87, 19.69, " - BIO-Engineering" },
	{ 2461.66, -2110.8, 13.54, " - Oil Plant" },
	{ 2183.56,-2274.58,13.5, " - Train Station" },
	{ 2757.73, -2394.69, 13.63, " - Docks" },
	{ -1534.42, -2748.16, 48.53, " - Gas Station" },
	{ -2109.35, -93.63, 35.32, "" },
	{ -334.22, 1522.82, 75.35, "" },
	{ -479.57, -504.42, 25.51, "" },
	{ -1048.74, -655.38, 32, "" },
	{ 688, 1844.42, 5.5, "" },
	{ -1742.28, -106.07, 3.55, " - Docks" },
	{ -2100.42, -2255.42, 30.62, "" },
	{ -74.57, -1129.11, 1.07, " - RS Haul" },
	{ 1018.1, -333.53, 73.99, " - Farm" },
	{ -1843.15, 135.49, 15.11, " - Solarin Factory" },
	{ 0, 20, 4, " - Farm" },
	{ 2100.55, -2218.26, 13.54, " - Airport" },
	{ -110.71, 1117.29, 19.74, "" },
	{ -531.12, 2622.91, 53.41, "" },
	{ -743.63, 2740.09, 47.7, "" },
	{ -1116.82, -1660.43, 76.36, " - Farm" },
	{ -2198.19, -2435.08, 30.62, "" },
	{ -265.66, -2166.94, 28.86, "" },
	{ 382.7, -1861.36, 7.83, "" },
	{ 1775.6, -2049.4, 13.56, "" },
	{ 1780.85, -1928.19, 13.38, "" },
	{ 2393.54, -1474.36, 23.81, "" },
	{ 2412.35, -2470.56, 13.62, "" },
	{ 2317.81, -74.56, 26.48, "" },
	{ 1694.32, 693.18, 10.82, "" },
	{ 2634.6, 1075.75, 10.82, " - Gas Station" },
	{ 1618, 1623, 10.82, " - Airport" },
	{ 2050.45, 2238.89, 10.82, "" },
	{ 1403.1953125, 991.703125, 10.8203125, " - Depot"}
}

function getPointFromDistanceRotation(x, y, dist, angle)
    local a = math.rad(angle-90);
    local dx = math.cos(a) * dist;
    local dy = math.sin(a) * dist;
    return x+dx, y+dy;
end

local zonesLoaded = false
local locationMarkers
local locationGUI = {}
local playerTruck, playerTrailer
local transportReward
local lastHit

function loadLocations()
	locationMarkers = {}
	local roomDimension = exports.USGrooms:getRoomDimension("cnr")
	for i, location in ipairs(locations) do
		local x,y,z = unpack(location,1,3)
		if(not zonesLoaded) then
			location[4] = getZoneName(x,y,z, true)..location[4]
		end
		local element = createMarker(x,y,z-1, "cylinder", 2,0,200,0)
		setElementDimension(element, roomDimension)
		addEventHandler("onClientMarkerHit", element, onLocationMarkerHit)
		locationMarkers[element] = location
	end
	zonesLoaded = true
end

function unloadLocations()
	if(locationMarkers) then
		for marker, location in pairs(locationMarkers) do
			if(isElement(marker)) then
				destroyElement(marker)
			end
		end
	end
	locationMarkers = nil
end

local trucks = {403, 514, 515}

function onLocationMarkerHit(hitElement, dimensions)
	if(hitElement ~= localPlayer or not dimensions) then return end
	if (not inVeh(hitElement)) then return end
	if(not isPedInVehicle(hitElement) or getVehicleController(getPedOccupiedVehicle(hitElement)) ~= localPlayer) then
		exports.USGmsg:msg("You have to be in your truck to use this marker.", 255,0,0)
		return
	end
	if(transporting and source == destinationMarker) then
		onDestinationHit()
	else
		openLocationGUI(source)
	end
end

function inVeh(element)
	if (element and isElement(element)) then
		local veh = getPedOccupiedVehicle(element)
		local state = getElementModel(veh)
		if (state == 403 or state == 514 or state == 515) then
			return true
		else
			return false
		end
		return false
	end
end

function calculateTransportReward(source, target)
	local startPrice = 250
	local x1,y1,z1 = unpack(source)
	local x2,y2,z2 = unpack(target)
	local distancePrice = (getDistanceBetweenPoints3D(x1,y1,z1,x2,y2,z2)*1.5)
	local price = startPrice+distancePrice
	return math.floor((price / 100)+0.5)*100
end

function toggleTransport()
	if(transporting) then
		stopTransport()
	else
		local selected = exports.USGGUI:gridlistGetSelectedItem(locationGUI.grid)
		if(selected) then
			local i = exports.USGGUI:gridlistGetItemData(locationGUI.grid, selected, 1)
			local location = locations[i]
			startTransport(location)
			closeLocationGUI()
		end
	end
end

function spaceForTrailer(vehicle)
	if(not vehicle) then return false end
	local x,y,z = getElementPosition(vehicle)
	local rx,ry,rz = getElementRotation(vehicle)
	local endX, endY = getPointFromDistanceRotation ( x,y, 13, rz )
	return isLineOfSightClear(x,y,z-1,endX, endY, z-1,true,true,true,true,true,false,false,vehicle)
end

function startTransport(location)
	if(not transporting) then
		local truck = getPedOccupiedVehicle(localPlayer)
		if(not spaceForTrailer(truck)) then
			exports.USGmsg:msg("There is no room for a trailer!", 255, 0, 0)
			return false
		end
		transporting = true
		for marker, loc in pairs(locationMarkers) do
			if(loc == location) then
				destinationMarker = marker
				break
			end
		end
		local x,y,z = location[1],location[2],location[3]
		destinationBlip = createBlip(x,y,z,51)
		transportReward = calculateTransportReward({getElementPosition(lastHit)}, {x,y,z})
		playerTruck = truck

		triggerServerEvent("USGcnr_job_trucker.onTransportStart", localPlayer)
		updateLocationGUI()
		addEventHandler("onClientVehicleExplode", playerTruck, onTruckExplode)
		addEventHandler("onClientVehicleEnter", playerTruck, onTruckEnter)
		addEventHandler("onClientVehicleExit", playerTruck, onTruckExit)
	end
end

addEvent("USGcnr_job_trucker.onTrailerAttached", true)
function onTrailerAttached(trailer)
	playerTrailer = trailer
	addEventHandler("onClientVehicleExplode", trailer, onTrailerExplode)
	addEventHandler("onClientTrailerAttach", trailer, onTrailerReAttached)
	addEventHandler("onClientTrailerDetach", trailer, onTrailerDetached)
end
addEventHandler("USGcnr_job_trucker.onTrailerAttached", localPlayer, onTrailerAttached)

function stopTransport(success)
	if(transporting) then
		if(isElement(playerTruck)) then
			removeEventHandler("onClientVehicleExplode", playerTruck, onTruckExplode)
			removeEventHandler("onClientVehicleEnter", playerTruck, onTruckEnter)
			removeEventHandler("onClientVehicleExit", playerTruck, onTruckExit)
		end
		if(isElement(playerTrailer)) then
			removeEventHandler("onClientVehicleExplode", playerTrailer, onTrailerExplode)
			removeEventHandler("onClientTrailerDetach", playerTrailer, onTrailerDetached)
		end
		triggerServerEvent("USGcnr_job_trucker.onTransportStop", localPlayer, success, transportReward)
		transporting = false
		destinationMarker = nil
		if(isElement(destinationBlip)) then
			destroyElement(destinationBlip)
		end
		playerTruck = nil
		playerTrailer = nil
		transportReward = nil
		updateLocationGUI()
	end
end

function onDestinationHit()
	if(getVehicleController(playerTruck) == localPlayer and getVehicleTowedByVehicle(playerTruck) == playerTrailer) then
		fadeCamera(false)
		setTimer(function ()
				exports.USGmsg:msg("You have delivered the cargo and earned "..exports.USG:formatMoney(transportReward).."!",0,255,0)
				stopTransport(true)
				setTimer(fadeCamera, 500, 1, true)
			end, 1200, 1 )
	else
		exports.USGMSG:msg("You appear to have lost your cargo or truck!", 255,0,0)
		stopTransport()
	end
end

--- *** GUI ***
function createLocationGUI()
	locationGUI.window = exports.USGGUI:createWindow("center","center",460,360,false,"Trucking locations")
	locationGUI.grid = exports.USGGUI:createGridList(9,25,445,294,false,locationGUI.window)
	exports.USGGUI:gridlistAddColumn(locationGUI.grid, "Destination", 0.65)
	exports.USGGUI:gridlistAddColumn(locationGUI.grid, "Reward", 0.35)
	locationGUI.toggle = exports.USGGUI:createButton(380,330,70,25,false,transporting and "Stop" or "Start",locationGUI.window)
	locationGUI.close = exports.USGGUI:createButton(5,330,70,25,false,"Close",locationGUI.window)
	addEventHandler("onUSGGUISClick", locationGUI.toggle, toggleTransport, false)
	addEventHandler("onUSGGUISClick", locationGUI.close, closeLocationGUI, false)
end

function openLocationGUI(locationMarker)
	lastHit = locationMarker
	if(not isElement(locationGUI.window)) then
		createLocationGUI()
	elseif(not exports.USGGUI:getVisible(locationGUI.window)) then
		exports.USGGUI:setVisible(locationGUI.window, true)
	end
	showCursor(true)
	updateLocationGUI()
end

function updateLocationGUI()
	if (locationMarkers[lastHit]) then
		local mLocation = locationMarkers[lastHit]
		exports.USGGUI:gridlistClear(locationGUI.grid)
		exports.USGGUI:setText(locationGUI.toggle, transporting and "Stop" or "Start")
		if(not transporting) then
			local sourcePosition = {getElementPosition(lastHit)}
			for i, location in ipairs(locations) do
				if(location ~= mLocation) then
					local row = exports.USGGUI:gridlistAddRow(locationGUI.grid)
					exports.USGGUI:gridlistSetItemText(locationGUI.grid, row, 1, location[4])
					local reward = calculateTransportReward(sourcePosition, {location[1],location[2],location[3]})
					exports.USGGUI:gridlistSetItemText(locationGUI.grid, row, 2, 
						exports.USG:formatMoney(reward))
					exports.USGGUI:gridlistSetItemSortIndex(locationGUI.grid, row, 2, reward)
					exports.USGGUI:gridlistSetItemData(locationGUI.grid, row, 1, i)
				end
			end
		end
	end
end

function closeLocationGUI()
	if(isElement(locationGUI.window) and exports.USGGUI:getVisible(locationGUI.window)) then
		exports.USGGUI:setVisible(locationGUI.window, false)
		showCursor(false)
	end
end

-- *** truck and trailer events ***

local trailerDetachTimer
local truckExitTimer

function onTruckExit(player)
	if(player ~= localPlayer) then return end
	if(not isTimer(truckExitTimer)) then
		truckExitTimer = setTimer(onTruckNotEntered, 30000, 1)
	end
	exports.USGmsg:msg("Your exited your truck, re-enter in 30 seconds.", 255,127,0)	
end

function onTruckEnter(player)
	if(player ~= localPlayer) then return end
	if(isTimer(truckExitTimer)) then
		killTimer(truckExitTimer)
	end	
end

function onTruckNotEntered()
	stopTransport()
	exports.USGmsg:msg("You didn't enter your truck in time, transport failed!", 255,0,0)
end

function onTruckExplode()
	stopTransport()
	exports.USGmsg:msg("Your truck exploded, transport failed!", 255,0,0)
end

function onTrailerDetached(tower)
	if(tower ~= playerTruck) then return end
	if(not isTimer(trailerDetachTimer)) then
		trailerDetachTimer = setTimer(onTrailerNotReattached, 60000, 1)
	end
	exports.USGmsg:msg("Your trailer detached, re-attach within a minute!", 255,127,0)
end

function onTrailerReAttached(tower)
	if(tower ~= playerTruck) then return end
	if(isTimer(trailerDetachTimer)) then
		killTimer(trailerDetachTimer)
	end
end

function onTrailerNotReattached()
	if(getVehicleTowedByVehicle(playerTruck) ~= playerTrailer) then
		stopTransport()
		exports.USGmsg:msg("Your trailer was not re-attached, transport failed!", 255,0,0)
	end
end

function onTrailerExplode()
	stopTransport()
	exports.USGmsg:msg("Your trailer exploded, transport failed!", 255,0,0)
end