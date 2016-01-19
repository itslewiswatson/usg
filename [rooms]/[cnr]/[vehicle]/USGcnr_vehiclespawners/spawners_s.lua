local playerVehicle = {}
local playerVehicleSpawner = {}

addEvent("USGcnr_vehiclespawners.spawnVehicle", true)
addEventHandler("USGcnr_vehiclespawners.spawnVehicle", root,
	function (model, rot, color, zOffset, spawnerInfo)
		local px, py, pz = getElementPosition(client)
		spawnPlayerVehicle(client, px, py, pz+(zOffset or 0), rot, model, color, spawnerInfo)
	end
)

function spawnPlayerVehicle(player, x, y, z, rot, model, color, spawnerInfo)
	if(exports.USGcnr_job_police:isPlayerArrested(client)) then
		exports.USGmsg:msg(client, "You can not spawn vehicles while arrested.", 255, 0, 0)
		return false
	end
	if(spawnerInfo.functionName) then -- restricted access
		local canUse = call(getResourceFromName(spawnerInfo.resource), spawnerInfo.functionName, client, spawnerInfo.name)
		if(not canUse) then
			exports.USGmsg:msg(client, "You can not use this spawner at this moment.",255,0,0)
			return false
		end
	end
	removePlayerVehicle(client)
	local vehicle = createVehicle(model, x,y,z,0,0,rot or 0)
	setElementData(vehicle, "room", "cnr")
	local r,g,b,r2,g2,b2 = unpack(color)
	if(r and g and b) then
		if(r2 and g2 and b2) then
			setVehicleColor(vehicle, r,g,b,r2,g2,b2)
		else
			setVehicleColor(vehicle, r,g,b)
		end
	end
	setElementDimension(vehicle, exports.USGrooms:getRoomDimension("cnr"))
	warpPedIntoVehicle(client, vehicle)
	playerVehicle[client] = vehicle
	playerVehicleSpawner[client] = spawnerInfo.name
end

addEvent("USGcnr_vehiclespawners.spawnVehicleV", true)
addEventHandler("USGcnr_vehiclespawners.spawnVehicleV", root, function (...) spawnPlayerVehicle(client, ...) end)

function removePlayerVehicle(player)
	if(isElement(playerVehicle[player])) then
		destroyElement(playerVehicle[player])
	end
	playerVehicle[player] = nil
	playerVehicleSpawner[player] = nil
end

function getPlayerSpawnedVehicle(player)
	if(playerVehicle[player] and isElement(playerVehicle[player])) then
		return playerVehicle[player]
	end
	return false
end

function getPlayerVehicleSpawner(player)
	if(playerVehicleSpawner[player] and isElement(playerVehicle[player])) then
		return playerVehicleSpawner[player]
	end
	return false
end
addEventHandler("onPlayerQuit", root, function () if(exports.USGrooms:getPlayerRoom(source) == "cnr") then removePlayerVehicle(source) end end)
addEventHandler("onPlayerPostExitRoom", root, function (prevRoom) if(prevRoom == "cnr") then removePlayerVehicle(source) end end)