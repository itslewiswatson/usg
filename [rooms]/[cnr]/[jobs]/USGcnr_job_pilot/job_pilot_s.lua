-- *** initializing and unloading ***
function initJob()
	if(getResourceFromName("USGcnr_jobs") and getResourceState(getResourceFromName("USGcnr_jobs")) == "running") then
		exports.USGcnr_jobs:addJob(jobID, jobType, occupation)
	end
end

addEventHandler("onResourceStart", root,
	function (res) -- init job if thisResource started, or if USGcnr_jobs (re)started
		if(res == resource or res == getResourceFromName("USGcnr_jobs")) then
			initJob()
		end
	end
)


--- *** job ***
local flights = {}
local passengerFlight = {}
local pilotFlights = {}
local passengerDestinationReached = {}
local passengerAircraft = {}
local pilotVehicles = {}
local allowedAircraftModels = {
	[519] = true,
	[553] = true,
	[487] = true,
	[511] = true,
}

local passengerSeats = {[519] = 8, [553] = 6}
addEventHandler("onVehicleStartEnter", root,
	function (passenger, seat, door)
		if(exports.USGrooms:getPlayerRoom(passenger) ~= "cnr") then return end
		local driver = getVehicleOccupant(source, 0)
		local model = getElementModel(source)
		if(not allowedAircraftModels[model] or not driver or driver == passenger or exports.USGcnr_jobs:getPlayerJob(driver) ~= jobID) then return end
		cancelEvent()
		triggerClientEvent(passenger, "USGcnr_job_pilot.onPassengerAttemptEnter", driver)
		exports.USGmsg:msg(driver, getPlayerName(passenger).." is selecting a destination.", 0, 255, 0)
	end
)

addEvent("USGcnr_job_pilot.onPassengerPickDestination", true)
function onPassengerPickDestination(pilot, x, y)
	if(isElement(pilot) and exports.USGrooms:getPlayerRoom(pilot) == "cnr" and exports.USGcnr_jobs:getPlayerJob(pilot) == jobID) then
		if(not passengerFlight[client]) then
			local aircraft = getPedOccupiedVehicle(pilot)
			if(aircraft and allowedAircraftModels[getElementModel(source)] and getVehicleController(aircraft) == pilot) then
				local px, py = getElementPosition(aircraft)
				local distance = getDistanceBetweenPoints2D(px,py,x,y)
				local price = math.floor(distance*2)
				if(getPlayerMoney(client) > price) then
					local model = getElementModel(aircraft)
					local seats = passengerSeats[model] or getVehicleMaxPassengers(aircraft)
					local freeSeat = false
					for seat=1, seats do
						if(not isVehicleSeatOccupied(aircraft, seat)) then
							freeSeat = seat
							break
						end
					end
					if(freeSeat) then
						if(not pilotVehicles[aircraft]) then pilotVehicles[aircraft] = {} end
						if(passengerSeats[model]) then -- custom seats
							setElementInterior(client, 1)
							setElementDimension(client, getVehicleInteriorDimension(aircraft))
							setElementRotation(client, 0, 0, 0)
							setElementPosition(client, 1.6650390625, 24.8662109375, 1199.59375)
						else
							warpPedIntoVehicle(client, aircraft, freeSeat)
						end
						pilotVehicles[aircraft][freeSeat] = client
						local flight = {passenger = client, aircraft = aircraft, price = price, pilot = pilot, destinationHit = false}
						passengerFlight[client] = flight
						if(not pilotFlights[pilot]) then pilotFlights[pilot] = {} end
						table.insert(pilotFlights[pilot], flight)
						table.insert(flights, flight)
						triggerClientEvent(client, "USGcnr_job_pilot.onEnterAsPassenger", pilot, passengerSeats[model] ~= nil)
						triggerClientEvent(pilot, "USGcnr_job_pilot.onPassengerEnter", client, x, y)
					else
						exports.USGmsg:msg(client, "This aircraft does not have any free spaces left.", 255, 0, 0)
					end
				else
					exports.USGmsg:msg(client, "You can not afford this flight.", 255, 0, 0)
				end
			else
				exports.USGmsg:msg(client, "The pilot left his vehicle or is not controlling it.", 255, 0, 0)
			end
		else
			exports.USGmsg:msg(client, "You are already in flight.", 255, 0, 0)
		end
	else
		exports.USGmsg:msg(client, "The pilot left or quit his job.", 255, 0, 0)
	end
end
addEventHandler("USGcnr_job_pilot.onPassengerPickDestination", root, onPassengerPickDestination)

local intDimension = 0

function getVehiclePassenger(vehicle, seat)
	local model = getElementModel(vehicle)
	if(passengerSeats[model] and pilotVehicles[vehicle]) then
		return pilotVehicles[vehicle][seat]
	else
		return getVehicleOccupant(vehicle, seat)
	end
end

function isVehicleSeatOccupied(vehicle, seat)
	local model = getElementModel(vehicle)
	if(passengerSeats[model] and pilotVehicles[vehicle]) then
		return pilotVehicles[vehicle][seat] ~= nil
	else
		return isElement(getVehicleOccupant(vehicle, seat))
	end
end

function vehicleHasCustomSeats(vehicle)
	if(not isElement(vehicle)) then return false end
	local model = getElementModel(vehicle)
	return passengerSeats[model] ~= nil
end

function getPassengerSeat(passenger)
	local flight = passengerFlight[passenger]
	local aircraft = flight and flight.aircraft or false
	if(aircraft and pilotVehicles[aircraft]) then
		local model = getElementModel(aircraft)
		local seats = passengerSeats[model] or getVehicleMaxPassengers(aircraft)	
		for seat=1,seats do
			local occupant = getVehiclePassenger(aircraft, seat)
			if(occupant and occupant == passenger) then
				return seat
			end
		end
		return false
	end
	return false
end

function getVehicleInteriorDimension(vehicle)
	if(not pilotVehicles[vehicle] or not pilotVehicles[vehicle].dimension) then
		intDimension = intDimension+1
		if(intDimension >= 100) then
			intDimension = 1
		end
		pilotVehicles[vehicle] = { dimension = intDimension}
	end
	return pilotVehicles[vehicle].dimension
end

function removePlayerFromAircraft(player)
	local flight = passengerFlight[player]
	local aircraft = flight and flight.aircraft or false
	if(aircraft and pilotVehicles[aircraft]) then
		local model = getElementModel(aircraft)
		local seat = getPassengerSeat(player)
		if(seat) then
			pilotVehicles[aircraft][seat] = nil -- free the seat
		end
		if(passengerSeats[model]) then
			local x, y, z = getElementPosition(aircraft)
			setElementInterior(player, 0)
			setElementDimension(player, 0)
			setElementRotation(player, 0, 0, 0)
			setElementPosition(player, x+5, y+6, z+1)
		else
			removePedFromVehicle(player)
		end
	end
end

addEvent("USGcnr_job_pilot.exitAircraft", true)
function passengerExit()
	removePlayerFromAircraft(source)
	onPassengerExit(source)
end
addEventHandler("USGcnr_job_pilot.exitAircraft", root, passengerExit)

function onPassengerExit(passenger, manualRemove)
	if(passengerFlight[passenger]) then
		local flight = passengerFlight[passenger]
		local pilot = flight.pilot
		if(flight.destinationHit) then
			flight.price = flight.price * 2
			exports.USGmsg:msg(passenger, "You have paid "..exports.USG:formatMoney(flight.price).." to "..getPlayerName(pilot)..".", 0, 255, 0)
			exports.USGmsg:msg(pilot, "You have received "..exports.USG:formatMoney(flight.price).." from "..getPlayerName(passenger)..".", 0, 255, 0)
			takePlayerMoney(passenger, flight.price)
			givePlayerMoney(pilot, flight.price)
		end
		triggerClientEvent(pilot, "USGcnr_job_pilot.onPassengerExit", passenger)
		triggerClientEvent(passenger, "USGcnr_job_pilot.onExitAsPassenger", passenger)
		passengerFlight[passenger] = nil
		if(not manualRemove) then
			for i, aFlight in ipairs(flights) do
				if(aFlight == flight) then
					table.remove(flights, i)
					break
				end
			end
			local pFlights = pilotFlights[pilot]
			if(pFlights) then
				for i, aFlight in ipairs(pFlights) do
					if(aFlight == flight) then
						table.remove(pFlights, i)
						break
					end
				end
			end
		end
	end
end

addEvent("USGcnr_job_pilot.onPilotDestinationHit", true)
addEventHandler("USGcnr_job_pilot.onPilotDestinationHit", root,
	function ()
		local pilot = client
		local passenger = source
		if(passengerFlight[passenger]) then
			exports.USGmsg:msg(passenger, "Your pilot "..getPlayerName(pilot).." has reached your destination.", 0, 255, 0)
			passengerFlight[passenger].destinationHit = true
		end
	end
)

function onPilotExit(pilot)
	local pFlights = pilotFlights[pilot]
	for i, flight in ipairs(pFlights) do
		removePlayerFromAircraft(flight.passenger)
		onPassengerExit(flight.passenger)
	end
	pilotFlights[pilot] = nil
end

addEventHandler("onPlayerWasted", root,
	function ()
		local flight = passengerFlight[source]
		if(flight) then
			if(vehicleHasCustomSeats(flight.aircraft)) then
				removePlayerFromAircraft(source)
				onPassengerExit(source)
			end
		end

		local pFlights = pilotFlights[source]
		if(pFlights) then
			onPilotExit(source)
		end
	end
)

addEvent("onPlayerExitRoom")
addEventHandler("onPlayerExitRoom", root,
	function (room)
		if(room ~= "cnr") then return end
		local flight = passengerFlight[source]
		if(flight) then
			if(vehicleHasCustomSeats(flight.aircraft)) then
				removePlayerFromAircraft(source)
				onPassengerExit(source)
			end
		end

		local pFlights = pilotFlights[source]
		if(pFlights) then
			onPilotExit(source)
		end
	end
)

addEvent("onPlayerAttemptExitRoom")
addEventHandler("onPlayerAttemptExitRoom", root,
	function (room)
		if(room ~= "cnr") then return end
		local flight = passengerFlight[source]
		if(flight) then
			if(vehicleHasCustomSeats(flight.aircraft)) then
				local x,y,z = getElementPosition(flight.aircraft)
				exports.USGcnr_room:setPlayerDataCache(source, "pos", 5000, x, y, z) -- set pos of aircraft for when they quit
				removePlayerFromAircraft(source)
				onPassengerExit(source)
			end
		end

		local pFlights = pilotFlights[source]
		if(pFlights) then
			onPilotExit(source)
		end
	end
)

addEventHandler("onResourceStop", resourceRoot,
	function ()
		for i, flight in ipairs(flights) do
			if(vehicleHasCustomSeats(flight.aircraft)) then 
				removePlayerFromAircraft(flight.passenger)
			end
		end
	end
)

addEvent("onPlayerChangeJob")
addEventHandler("onPlayerChangeJob", root,
	function ()
		local pFlights = pilotFlights[source]
		if(pFlights) then
			onPilotExit(source)
		end
	end
)

-- cargo
addEvent("USGcnr_job_pilot.onCargoMissionFinish", true)
function onPlayerFinishCargo(missionType, distance)
	if(exports.USGcnr_jobs:getPlayerJob(client) == "pilot" and isPedInVehicle(client)) then
		local reward = missionType == "drop" and 750 or 500
		reward = reward + (distance/1.25)
		reward = 10*math.floor(reward/10)
		reward = reward * 2
		givePlayerMoney(client, reward)
		exports.USGmsg:msg(client, "You have earned "..exports.USG:formatMoney(reward).." for completing a cargo mission.", 0, 255, 0)
	end
end
addEventHandler("USGcnr_job_pilot.onCargoMissionFinish", root, onPlayerFinishCargo)