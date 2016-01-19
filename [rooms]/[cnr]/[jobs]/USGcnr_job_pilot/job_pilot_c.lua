local cargoTimer
local onTheJob = false

-- *** initializing and unloading ***
function initJob()
	if(getResourceFromName("USGrooms") and getResourceState(getResourceFromName("USGrooms")) == "running" and exports.USGrooms:getPlayerRoom() == "cnr" and getResourceFromName("USGcnr_jobs") and getResourceState(getResourceFromName("USGcnr_jobs")) == "running") then
		exports.USGcnr_jobs:addJob(jobID, jobType, occupation, jobDescription, jobMarkers, jobSkins, jobVehicleMarkers)
		if( exports.USGcnr_jobs:getPlayerJob() == jobID) then
			onJobTaken()
		end
	end
end

addEvent("onPlayerJoinRoom", true)
addEventHandler("onPlayerJoinRoom", localPlayer, 
	function (room)
		if(room == "cnr") then
			initJob()
		end
	end
)

addEventHandler("onClientResourceStart", root,
	function (res) -- init job if thisResource started, or if USGcnr_jobs (re)started
		if(res == resource or res == getResourceFromName("USGcnr_jobs")) then
			initJob()
		end
	end
)

-- *** job loading ***
local passengers
addEvent("USGcnr_job_pilot.onPassengerEnter", true)
addEvent("USGcnr_job_pilot.onPassengerExit", true)
function onJobTaken()
	if(not onTheJob) then
		onTheJob = true
		passengers = {}
		addEventHandler("USGcnr_job_pilot.onPassengerEnter", root, onPassengerEnter)
		addEventHandler("USGcnr_job_pilot.onPassengerExit", root, onPassengerExit)
		cargoTimer = setTimer(startCargoMission, 30000, 0)
	end
end

function onJobStop()
	if(onTheJob) then
		onTheJob = false
		stopCargoMission()
		removeEventHandler("USGcnr_job_pilot.onPassengerEnter", root, onPassengerEnter)
		removeEventHandler("USGcnr_job_pilot.onPassengerExit", root, onPassengerExit)
		for i, passenger in ipairs(passengers) do
			if(isElement(passenger.marker)) then
				destroyElement(passenger.marker)
			end
			if(isElement(passenger.blip)) then
				destroyElement(passenger.blip)
			end
		end
		if(isTimer(cargoTimer)) then killTimer(cargoTimer) end
		passengers = nil
	end
end

addEvent("onPlayerChangeJob", true)
function onChangeJob(ID)
	if(onTheJob) then
		onJobStop()
	elseif(ID == jobID) then
		onJobTaken()
	end
end
addEventHandler("onPlayerChangeJob", localPlayer, onChangeJob)

addEvent("onPlayerExitRoom", true)
addEventHandler("onPlayerExitRoom", localPlayer, 
	function (prevRoom)
		if(prevRoom == "cnr") then
			onJobStop()
		end
	end
)

function onPassengerEnter(destX,destY)
	stopCargoMission()
	if(isTimer(cargoTimer)) then killTimer(cargoTimer) end
	local target = createMarker(destX, destY, 5, "checkpoint", 5.5, 200,0,0)
	local blip = createBlip(destX, destY, 5, 41)
	addEventHandler("onClientMarkerHit", target, onDestinationMarkerHit)
	table.insert(passengers, {passenger=source,x=destX,y=destY,marker=target,blip=blip})
end

function onPassengerExit()
	for i, passenger in ipairs(passengers) do
		if(passenger.passenger == source) then
			if(isElement(passenger.marker)) then
				destroyElement(passenger.marker)
			end
			if(isElement(passenger.blip)) then
				destroyElement(passenger.blip)
			end
			table.remove(passengers,i)
		end
	end
end

function onDestinationMarkerHit(hitElement, dimensions)
	if(hitElement ~= localPlayer or not dimensions) then return end
	for i, passenger in ipairs(passengers) do
		if(passenger.marker == source) then
			destroyElement(passenger.blip)
			passenger.destinationHit = true
			triggerServerEvent("USGcnr_job_pilot.onPilotDestinationHit", passenger.passenger)
			break
		end
	end
	destroyElement(source)
end

--- cargo
local cargoAircraft = {
	normal = {
		[592] = true,
		[577] = true,
		[511] = true,
		[548] = true,
		[487] = true,
		[553] = true,
		[519] = true,
	},
	drop = {
		[592] = true,
		[577] = true,
		[511] = true,
		[553] = true,
		[519] = true,
	},
}

local cargoDropObjects = {3052, 3014, 2912}

local airports = {
	{x = 1539.7802734375, y = 1647.052734375, z = 10.8203125, name = "LV Airport"},
	{x = 1971.744140625, y = -2626.9345703125, z = 13.546875, name = "LS Airport"},
	{x = -1248.0166015625, y = -99.017578125, z = 14.1484375, name = "SF Airport"},
	{x = 426.9384765625, y = 2501.5712890625, z = 16.484375, name = "Abandoned Airstrip"},
}

local cargoDropDestinations = {
	{x = -1.7265625, y = 1524.3564453125, z = 12.75, name = "Lil' Probe'Inn"},
	{x = -1810.869140625, y = 2046.6513671875, z = 9.0668449401855, name = "Bone County Transformators"},
	{x = -2828.068359375, y = 1304.2294921875, z = 7.1015625, name = "San Fierro Bay"},
	{x = -1608.0361328125, y = 285.7119140625, z = 7.1875, name = "San Fierro Navy"},
	{x = -2392.712890625, y = -2205.8349609375, z = 33.289062, name = "Mount Chilliad"},
	{x = -381.255859375, y = -1401.2080078125, z = 24.507307052612, name = "Los Santos Farm"},
	{x = 887.6513671875, y = -1225.7822265625, z = 16.9765625, name = "Vinewood movie set"},
	{x = 2588.50390625, y = -2439.736328125, z = 13.627708435059, name = "Los Santos Docks"},
	{x = 838.205078125, y = -2031.2685546875, z = 12.8671875, name = "Los Santos Boardwalk"},
}


for i, airport in ipairs(airports) do
	table.insert(cargoDropDestinations, airport)
end

local transportingCargo = false
local transportType
local transportTargetMarker
local transportTargetBlip
local transportAircraft
local transportCargoDropped = false
local transportDistance
local transportDropObject
local transportDropTargetCol
local transportCargoPickedUp
local transportDestination

function getDistanceBetweenElements2D(el1, el2)
	local x1,y1,_ = getElementPosition(el1)
	local x2,y2,_ = getElementPosition(el2)
	return getDistanceBetweenPoints2D(x1,y1,x2,y2)
end

function startCargoMission()
	if(not getPedOccupiedVehicle(localPlayer) or getElementHealth(getPedOccupiedVehicle(localPlayer)) < 250
	or getElementHealth(localPlayer) <= 0) then return end
	if(not transportingCargo) then
		transportType = math.random(11) < 7 and "normal" or "drop"
		transportAircraft = getPedOccupiedVehicle(localPlayer)
		local vehicleModel = getElementModel(transportAircraft)
		if(not cargoAircraft[transportType][vehicleModel]) then
			-- try the other cargo type
			transportType = transportType == "normal" and "drop" or "normal"
			if(not cargoAircraft[transportType][vehicleModel]) then
				return -- vehicle doesnt fit
			end
		end
		-- all checks were OK
		if(isTimer(cargoTimer)) then killTimer(cargoTimer) end
		transportingCargo = true
		local x, y, z = getElementPosition(transportAircraft)
		local pickupLocation
		local distance
		for i, airport in ipairs(airports) do
			local dist = getDistanceBetweenPoints2D(x,y, airport.x, airport.y)
			if(not pickupLocation or dist < distance) then
				pickupLocation = airport
				distance = dist
			end
		end
		if(transportType == "drop") then
			transportDestination = cargoDropDestinations[math.random(#cargoDropDestinations)]
			while getDistanceBetweenPoints2D(transportDestination.x, transportDestination.y, pickupLocation.x, pickupLocation.y) < 200 do
				transportDestination = cargoDropDestinations[math.random(#cargoDropDestinations)]
			end
		else
			transportDestination = airports[math.random(#airports)]
			while transportDestination.name == pickupLocation.name do
				transportDestination = airports[math.random(#airports)]
			end
		end
		transportTargetMarker = createMarker(pickupLocation.x, pickupLocation.y, pickupLocation.z-1, "cylinder", 5, 255, 0, 0, 175)
		transportTargetBlip = createBlip(pickupLocation.x, pickupLocation.y, pickupLocation.z, 0, 4, 255, 0, 0)
		transportDistance = getDistanceBetweenPoints2D(x, y, pickupLocation.x, pickupLocation.y)+getDistanceBetweenPoints2D(transportDestination.x, transportDestination.y, pickupLocation.x, pickupLocation.y)
		addEventHandler("onClientMarkerHit", transportTargetMarker, onCargoPickupHit)
		-- general event handlers
		addEventHandler("onClientElementDestroy", transportAircraft, onCargoAircraftDestroy)
		addEventHandler("onClientVehicleExit", transportAircraft, onCargoAircraftExit)
		addEventHandler("onClientPlayerWasted", localPlayer, stopCargoMission)
		exports.USGmsg:msg("There has been a request for a cargo mission. Pick it up at "..pickupLocation.name..".", 0, 255, 0)
	end
end

function onCargoSuccess()
	triggerServerEvent("USGcnr_job_pilot.onCargoMissionFinish", localPlayer, transportType, transportDistance)
	stopCargoMission()
end

function stopCargoMission()
	if(transportingCargo) then
		transportingCargo = false
		destroyElement(transportTargetMarker)
		destroyElement(transportTargetBlip)
		if(transportType == "drop") then
			if(transportCargoDropped) then
				killTimer(checkDroppedCargoTimer)
			end
			transportCargoDropped = false
			unbindKey("lshift","down",dropCargo)
			destroyElement(transportDropObject)
			destroyElement(transportDropTargetCol)
		end
		if(isElement(transportAircraft)) then
			removeEventHandler("onClientElementDestroy", transportAircraft, onCargoAircraftDestroy)
			removeEventHandler("onClientVehicleExit", transportAircraft, onCargoAircraftExit)
		end
		removeEventHandler("onClientPlayerWasted", localPlayer, stopCargoMission)
		if(onTheJob and #passengers == 0) then
			startCargoMission()
			if(not transportingCargo) then -- try again later
				cargoTimer = setTimer(startCargoMission, 30000, 0)
			end
		end
	end
end

function onCargoPickupHit(hitElement, dimensions)
	if(hitElement == localPlayer and dimensions and exports.USG:validateMarkerZ(source, hitElement)) then
		transportCargoPickedUp = true
		exports.USGmsg:msg((transportType == "drop" and "Drop" or "Deliver").." the cargo at "..transportDestination.name..".", 0, 255, 0)
		destroyElement(source)
		destroyElement(transportTargetBlip)
		transportTargetMarker = createMarker(transportDestination.x, transportDestination.y, transportDestination.z-1, "cylinder", transportType == "drop" and 20 or 5, 255, 0, 0, 175)
		transportTargetBlip = createBlip(transportDestination.x, transportDestination.y, transportDestination.z, 0, 4, 255, 0, 0)
		if(transportType == "drop") then
			exports.USGmsg:msg("Use left-shift to drop your cargo.", 0, 255, 0)
			transportDropObject = createObject(cargoDropObjects[math.random(#cargoDropObjects)], 0,0,5)
			transportDropTargetCol = createColSphere(transportDestination.x, transportDestination.y, transportDestination.z, 20)
			attachElements(transportDropObject, transportAircraft, 0, 0, -1.5)
			addEventHandler("onClientColShapeHit", transportDropTargetCol, onCargoDropTargetColHit)
			bindKey("lshift","down",dropCargo)
		else
			addEventHandler("onClientMarkerHit", transportTargetMarker, onCargoTargetMarkerHit)
		end
	end
end

function dropCargo()
	local x,y,z = getElementPosition(transportAircraft)
	local ground = getGroundPosition(x,y,z-4)
	if(math.abs(z-ground) < 15) then
		exports.USGmsg:msg("You're too low to drop your cargo.", 255, 0, 0)
		return
	end
	detachElements(transportDropObject, transportAircraft)
	local vx, vy, vz = getElementVelocity(transportAircraft)
	setElementVelocity(transportDropObject, vx, vy, vz)
	transportCargoDropped = true
	checkDroppedCargoTimer = setTimer(checkOnDroppedCargo, 2000, 0)
end

function checkOnDroppedCargo()
	while (isElement(transportDropObject)) do
		local vx, vy, vz = getElementVelocity(transportDropObject)
		if( vx + vy + vz < 1) then
			-- cargo is dropped and not moving anymore, mission failed
			stopCargoMission()
			exports.USGmsg:msg("You failed to drop the cargo in the target area.", 255, 0, 0)
		end
	end
end

function onCargoTargetMarkerHit(hitElement, dimensions)
	if(hitElement == localPlayer and dimensions and exports.USG:validateMarkerZ(source, hitElement)) then
		onCargoSuccess()
	end
end

function onCargoDropTargetColHit(element)
	if(element == transportDropObject and transportCargoDropped) then
		onCargoSuccess()
	end
end

function onCargoAircraftDestroy()
	stopCargoMission()
end

function onCargoAircraftExit(player)
	if(player == localPlayer) then
		stopCargoMission()
	end
end