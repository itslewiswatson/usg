function markers(player)
	if isPedInVehicle(player) then
		local vehicle = getPedOccupiedVehicle(player)
		fixVehicle(vehicle)
	end
end
addEventHandler("onClientMarkerHit", getResourceRootElement(getThisResource()), markers)

function allowShoots()
	bindTrigger = 1
end
