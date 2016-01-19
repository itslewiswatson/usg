function getVehicleNitro(vehicle)
	if(isElement(vehicle)) then
		if(isElementStreamedIn(vehicle)) then
			if(isVehicleNitroActivated(vehicle)) then
				return getVehicleNitroLevel(vehicle)
			elseif(getVehicleNitroCount(vehicle) and getVehicleNitroCount(vehicle) >= 1) then
				return getVehicleNitroLevel(vehicle)
			else
				return 0
			end
		end
		return 0
	else
		return 0
	end
end

addEvent("USGrace_nitro.onPickup", true)
function onPickupNitro()
	local vehicle = getPedOccupiedVehicle(localPlayer)
	if(isElement(vehicle)) then
		setVehicleNitroCount(vehicle, 1)
		setVehicleNitroActivated(vehicle, false)
	end
end
addEventHandler("USGrace_nitro.onPickup", localPlayer, onPickupNitro)