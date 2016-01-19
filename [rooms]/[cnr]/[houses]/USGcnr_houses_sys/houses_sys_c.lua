local housePickup = false
local pickupHouse = false

addEvent("USGcnr_housing_sys.updatePickup", true)
function updatePickup(pickup)
	createHousePickup(unpack(pickup))
end
addEventHandler("USGcnr_housing_sys.updatePickup", root, updatePickup)

addEvent("USGcnr_houses_sys.createPickup", true)
function createHousePickup(ID, x,y,z, owned)
	if(isElement(housePickup[ID])) then
		destroyElement(housePickup[ID])
	end
	local pickup = createPickup(x,y,z,3,owned and 1272 or 1273)
	addEventHandler("onClientPickupHit", pickup, onPickupHit)
	addEventHandler("onClientPickupLeave", pickup, onPickupLeave)
	pickupHouse[pickup] = ID
	housePickup[ID] = pickup
end
addEventHandler("USGcnr_houses_sys.createPickup", root, createHousePickup)

addEvent("USGcnr_housing_sys.recieveHouses", true)
function recieveHouses(houses)
	pickupHouse = {}
	housePickup = {}
	for i, house in ipairs(houses) do
		createHousePickup(unpack(house))
	end
end
addEventHandler("USGcnr_housing_sys.recieveHouses", root, recieveHouses)

addEventHandler("onClientResourceStart", resourceRoot, 
	function ()
		addEvent("onHousePickupHit", true)
		addEvent("onHousePickupLeave", true)
		if(getResourceFromName("USGrooms") and getResourceState(getResourceFromName("USGrooms")) == "running" and exports.USGrooms:getPlayerRoom() == "cnr") then
			requestPickups()
		end
		addEventHandler("onPlayerJoinRoom", localPlayer, onJoinRoom)
		addEventHandler("onPlayerExitRoom", localPlayer, onExitRoom)
	end
)

function requestPickups()
	triggerServerEvent("USGcnr_housing_sys.requestHouses", localPlayer) -- let the server know the client is ready to recieve the houses
end

function onJoinRoom(room)
	if(room == "cnr") then
		requestPickups()
	end
end

function onExitRoom()
	if(pickupHouse) then
		for pickup, house in pairs(pickupHouse) do
			if(isElement(pickup)) then destroyElement(pickup) end
		end
		pickupHouse = false
		housePickup = false
	end
end

function onPickupHit(element, dimensions)
	if(element ~= localPlayer or not dimensions) then return end
	triggerEvent("onHousePickupHit", source, pickupHouse[source])
end

function onPickupLeave(element)
	if(element ~= localPlayer) then return end
	triggerEvent("onHousePickupLeave", source, pickupHouse[source])
end