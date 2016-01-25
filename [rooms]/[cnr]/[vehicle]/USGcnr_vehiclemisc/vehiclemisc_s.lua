function cmdEjectPlayer(pSource, cmd, target)
	if(exports.USGrooms:getPlayerRoom(pSource) ~= "cnr") then return end
	local vehicle = getPedOccupiedVehicle(pSource)
	if(not vehicle) then return end
	if(getVehicleController(vehicle) ~= pSource) then
		exports.USGmsg:msg(pSource, "You need to be driving the vehicle to eject players", 255, 0, 0)
		return
	end
	if(not target or target == "") then
		exports.USGmsg:msg(pSource, "Syntax: /eject name|*.", 255, 0, 0)		
		return
	elseif(target == "*") then
		for seat, occupant in pairs(getVehicleOccupants(vehicle)) do
			if(occupant ~= pSource) then
				setControlState(occupant, "enter_exit", true)
				exports.USGmsg:msg(occupant, "You have been ejected from your vehicle.", 255, 128, 0)
			end
		end
	else
		local targetPlayer = getCNRPlayerFromNamePart(target)
		if(targetPlayer and getPedOccupiedVehicle(targetPlayer) == vehicle) then
			if(targetPlayer ~= pSource) then
				setControlState(targetPlayer, "enter_exit", true)
				exports.USGmsg:msg(targetPlayer, "You have been ejected from your vehicle.", 255, 128, 0)
			else
				exports.USGmsg:msg(pSource, "You can't eject yourself.", 255, 0, 0)
			end
		else
			exports.USGmsg:msg(pSource, "This player does not exist or is not in your vehicle.", 255, 0, 0)
		end
	end
end
addCommandHandler("eject",cmdEjectPlayer, false, false)

local lightStates = {
	[0] = "auto",
	[1] = "off",
	[2] = "on",
}

function cmdLights(pSource, cmd, state)
	if(exports.USGrooms:getPlayerRoom(pSource) ~= "cnr") then return end
	local vehicle = getPedOccupiedVehicle(pSource)
	if(not vehicle) then return end
	if(getVehicleController(vehicle) ~= pSource) then
		exports.USGmsg:msg(pSource, "You need to be driving the vehicle to toggle lights.", 255, 0, 0)
		return
	end
	local newState
	if(not state or state == "") then
		newState = getVehicleOverrideLights(vehicle) == 2 and 1 or 2
	elseif(state == "auto") then
		newState = 0
	elseif(state == "on" or state == "off") then
		newState = state == "on" and 2 or 1
	else
		exports.USGmsg:msg(pSource, "Syntax: '/lights auto|on|off' OR '/lights' to toggle", 255, 0, 0)
		return
	end
	exports.USGmsg:msg(pSource, "Your vehicle's lights are now: "..lightStates[newState], 0, 255, 0)
	setVehicleOverrideLights(vehicle, newState)
end
addCommandHandler("lights",cmdLights, false, false)

function cmdDoors(pSource, cmd, door)
	if(exports.USGrooms:getPlayerRoom(pSource) ~= "cnr") then return end
	local vehicle = getPedOccupiedVehicle(pSource)
	if(not vehicle) then return end
	if(getVehicleController(vehicle) ~= pSource) then
		exports.USGmsg:msg(pSource, "You need to be driving the vehicle to toggle lights.", 255, 0, 0)
		return
	end
	local door = tonumber(door)
	if(not door) then
		exports.USGmsg:msg(pSource, "You must specify a door to toggle ( 1-6 ).", 255, 0, 0)
		return
	elseif(door == 5 or door == 6) then
		door = door == 5 and 0 or 1
	else
		door = door + 1
	end
	local doorState = getVehicleDoorOpenRatio(vehicle, door)
	local newState = doorState ~= 1 and 1 or 0
	setVehicleDoorOpenRatio(vehicle, door, newState, 500)
end
addCommandHandler("door", cmdDoors, false, false)

function cmdLockVehicle(pSource, cmd)
	if(exports.USGrooms:getPlayerRoom(pSource) ~= "cnr") then return end
	local vehicle = getPedOccupiedVehicle(pSource)
	if(not vehicle) then return end
	if(getVehicleController(vehicle) ~= pSource) then
		exports.USGmsg:msg(pSource, "You need to be driving the vehicle to lock or unlock it.", 255, 0, 0)
		return
	end
	local checkIsHijack = getElementData(vehicle, "vehicle.isHijack")
	local checkIsMedicineHeli = getElementData(vehicle, "vehicle.isMedicineHeli")
	if (checkIsHijack and checkIsHijack == true) then exports.USGmsg:msg(pSource, "You can't lock the hijack vehicle.", 255, 0, 0) return end
	if (checkIsMedicineHeli and checkIsMedicineHeli == true) then exports.USGmsg:msg(pSource, "You can't lock the Medicine helicopter.", 255, 0, 0) return end
	local state = not isVehicleLocked(vehicle)
	setVehicleLocked(vehicle, state)
	exports.USGmsg:msg(pSource, "You have "..(state and "locked" or "unlocked").." your vehicle.", 0, 255, 0)
end
addCommandHandler("lock",cmdLockVehicle, false, false)

function onVehicleExit(player, seat)
	if(exports.USGrooms:getPlayerRoom(player) ~= "cnr") then return end
	if(seat == 0) then
		setVehicleLocked(source, false)
	end
end
addEventHandler("onVehicleExit", root, onVehicleExit)




--- util

function getCNRPlayerFromNamePart(name)
	local name = name:lower()
	local target = false
	local matchCount = 0
	for i, player in ipairs(getElementsByType("player")) do
		if(exports.USGrooms:getPlayerRoom(player) == "cnr") then
			local startMatch, endMatch = getPlayerName(player):lower():find(name)
			if(startMatch and endMatch) then
				if(not target) then
					target = player
				else
					local count = #getPlayerName(player)-math.abs(endMatch-startMatch)
					if(count > matchCount) then
						matchCount = count
						target = player
					end
				end
			end
		end
	end
	return target
end