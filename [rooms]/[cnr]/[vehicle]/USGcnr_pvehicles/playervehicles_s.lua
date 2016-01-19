function hexToRGB(hex)
	local hex = hex:gsub("#", "")
	return tonumber("0x" .. hex:sub(1, 2)), tonumber("0x" .. hex:sub(3, 4)), tonumber("0x" .. hex:sub(5, 6))
end

loadstring(exports.MySQL:getQueryTool())()

-- loading vehicles from DB, and when players join
local elementID = {}
local vehicles = {}
local accountVehicles = {}

addEventHandler("onResourceStart", resourceRoot,
	function ()
		setTimer(function() query(loadDBVehicles, {}, "SELECT * FROM cnr__pvehicles") end, 2500, 1)
	end
)

function loadDBVehicles(results)
	local onlineAccounts = {}
	for i, player in ipairs(getElementsByType("player")) do
		if(exports.USGaccounts:isPlayerLoggedIn(player) and exports.USGrooms:getPlayerRoom(player) == "cnr") then
			onlineAccounts[exports.USGaccounts:getPlayerAccount(player)] = player
		end
	end
	local playerVehicles = {}
	for i, vehicle in ipairs(results) do
		vehicle.wheels = {vehicle.wheel1,vehicle.wheel2,vehicle.wheel3,vehicle.wheel4}
		vehicle.wheel1,vehicle.wheel2,vehicle.wheel3,vehicle.wheel4 = nil,nil,nil,nil
		vehicles[vehicle.id] = vehicle
		if(not accountVehicles[vehicle.owner]) then
			accountVehicles[vehicle.owner] = {vehicle.id}
		else
			table.insert(accountVehicles[vehicle.owner], vehicle.id)
		end
		local player = onlineAccounts[vehicle.owner]
		if(isElement(player)) then
			if(not playerVehicles[player]) then playerVehicles[player] = {vehicle}
			else table.insert(playerVehicles[player], vehicle) end
			spawnVehicle(vehicle.id)
		end
	end
	for player, vehs in pairs(playerVehicles) do
		triggerClientEvent(player, "USGcnr_pvehicles.client.addVehicles", player, vehs)
	end
end

addEventHandler("onResourceStop", resourceRoot,
	function ()
		for id, vehicle in pairs(vehicles) do
			saveVehicle(id)
		end
	end
)

addEvent("onPlayerJoinRoom")
function onPlayerJoinRoom(room)
	if(room ~= "cnr") then return end
	local account = exports.USGaccounts:getPlayerAccount(source)
	local vehs = accountVehicles[account]
	if(vehs and #vehs > 0) then
		local playerVehicles = {}
		for i, vehicleid in ipairs(vehs) do
			local vehicle = vehicles[vehicleid]
			table.insert(playerVehicles, vehicle)
			spawnVehicle(vehicle.id)
		end
		triggerClientEvent(source, "USGcnr_pvehicles.client.addVehicles", source, playerVehicles)
	end
end
addEventHandler("onPlayerJoinRoom", root, onPlayerJoinRoom)

function removePlayerVehicles(player)
	local account = exports.USGaccounts:getPlayerAccount(player)
	local vehs = accountVehicles[account]
	if(vehs and #vehs > 0) then
		for i, vehicleid in ipairs(vehs) do
			local vehicle = vehicles[vehicleid]
			if(isElement(vehicle.element)) then
				removeVehicle(vehicle.id)
			end
		end
	end
end

addEvent("onPlayerExitRoom")
function onPlayerExitRoom(room)
	if(room ~= "cnr") then return end
	removePlayerVehicles(source)
end
addEventHandler("onPlayerExitRoom", root, onPlayerExitRoom)

function onPlayerQuit()
	if(exports.USGrooms:getPlayerRoom(source) ~= "cnr") then return end
	removePlayerVehicles(source)
end
addEventHandler("onPlayerQuit", root, onPlayerQuit)

-- interacting with client's gui
addEvent("USGcnr_pvehicles.spawnVehicle", true)
addEvent("USGcnr_pvehicles.recoverVehicle", true)
addEvent("USGcnr_pvehicles.repairVehicle", true)
addEvent("USGcnr_pvehicles.sellVehicle", true)

addEventHandler("USGcnr_pvehicles.spawnVehicle", root,
	function (id)
		local account = exports.USGaccounts:getPlayerAccount(client)
		local vehicle = vehicles[id]
		if(vehicle and vehicle.owner == account) then
			if(vehicle.health > 250) then
				if(spawnVehicle(id)) then
					exports.USGmsg:msg(client, "Spawned your "..getVehicleNameFromModel(vehicle.model).."!", 0, 255, 0)
				else
					exports.USGmsg:msg(client, "Could not spawn your "..getVehicleNameFromModel(vehicle.model).."!", 255, 0, 0)
				end
			else
				exports.USGmsg:msg(client, "Could not spawn your "..getVehicleNameFromModel(vehicle.model).." because it needs a repair!", 255, 0, 0)
			end
		end
	end
)

addEventHandler("USGcnr_pvehicles.recoverVehicle", root,
	function (id)
		local account = exports.USGaccounts:getPlayerAccount(client)
		local vehicle = vehicles[id]
		if(vehicle and vehicle.owner == account) then
			local px,py,pz = getElementPosition(client)
			if(recoverVehicle(id,px,py)) then
				exports.USGmsg:msg(client, "Recovered your "..getVehicleNameFromModel(vehicle.model).."!", 0, 255, 0)
			else
				exports.USGmsg:msg(client, "Could not recover your "..getVehicleNameFromModel(vehicle.model).."!", 255, 0, 0)
			end
		end
	end
)

addEventHandler("USGcnr_pvehicles.repairVehicle", root,
	function (id)
		local account = exports.USGaccounts:getPlayerAccount(client)
		local vehicle = vehicles[id]
		if(vehicle and vehicle.owner == account) then
			local hp = isElement(vehicle.element) and getElementHealth(vehicle.element) or vehicle.health
			if(vehicle.health < 250) then
				if(repairVehicle(id, client)) then
					exports.USGmsg:msg(client, "Repaired your "..getVehicleNameFromModel(vehicle.model).."!", 0, 255, 0)
				else
					exports.USGmsg:msg(client, "Could not repair your "..getVehicleNameFromModel(vehicle.model).."!", 255, 0, 0)
				end
			else
				exports.USGmsg:msg(client, "Your "..getVehicleNameFromModel(vehicle.model).." does not need a repair!", 255, 0, 0)
			end
		end
	end
)

addEventHandler("USGcnr_pvehicles.sellVehicle", root,
	function (id)
		if(exports.USGrooms:getPlayerRoom(client) ~= "cnr") then return end
		local account = exports.USGaccounts:getPlayerAccount(client)
		local vehicle = vehicles[id]
		if(vehicle and vehicle.owner == account) then
			local sellprice = getVehicleSellPrice(vehicle.boughtprice, client)
			removeVehicle(id)
			for i, vID in ipairs(accountVehicles[account]) do
				if(vID == id) then
					table.remove(accountVehicles[account], i)
					break
				end
			end
			vehicles[id] = nil
			exports.MySQL:execute("DELETE FROM cnr__pvehicles WHERE id=?",id)
			givePlayerMoney(client, sellprice)
			triggerClientEvent(client, "USGcnr_pvehicles.client.onVehicleSold", client, id)
		end
	end
)

--- recovering vehicles
local recoverPlaces = { -- vehicleType = {x,y,z,rotation} ( General for vehicles which are not listed under other types )
	General = 
		{ 
			{ 1679.09, -1054.18, 23.89, 110 },
			{ -1987.51, 250.96, 35.17, 355 },
			{ 1952.97, 2167.12, 10.82, 133 },
		},		
	Plane = {
			{ 2021.44, -2619.91, 14.54, 47 },
			{ -1687.54, -254.3, 15.14, 320},
			{ 1556.43, 1320.08, 11.87, 83},
		},		
	Helicopter = {
			{ 2007.4, -2444.05, 14, 180 },
			{ -1186.83, 25.94, 15, 220},
			{ 1534.27, 1735.64, 11.5, 82 },
		},		
	Boat = {
			{ 2307.51, -2419.45, 0, 140 },
			{ 2268.76, 530.92, 0, 180 },
			{ -1636.08, 160.86, 0, 35 },
		},
}

local specialVehicleRecovery = {
	[460] = recoverPlaces.Boats,
}

function recoverVehicle(id, px, py)
	if(not vehicles[id]) then return false end
	local vehType = getVehicleType(vehicles[id].model)
	local positions = specialVehicleRecovery[vehicles[id].model] or recoverPlaces[vehType] or recoverPlaces.General
	local px, py = px or 0, py or 0
	local shortest = false
	local distance = 0
	for i, position in ipairs(positions) do
		local dist = getDistanceBetweenPoints2D(position[1], position[2],px,py)
		if(not shortest or dist < distance) then
			shortest = position
			distance = dist
		end
	end
	local x,y,z,rz = shortest[1], shortest[2], shortest[3], shortest[4]
	if(isElement(vehicles[id].element)) then
		for seat=0,getVehicleMaxPassengers(vehicles[id].element) do
			local occupant = getVehicleOccupant(vehicles[id].element, seat)
			if(isElement(occupant)) then
				removePedFromVehicle(occupant)
				exports.USGmsg:msg(occupant, "This vehicle was recovered and you have been ejected.", 255, 128, 0)
			end
		end
		setElementPosition(vehicles[id].element, x,y,z)
		setElementRotation(vehicles[id].element, 0, 0, rz)
		return true
	else
		return exports.MySQL:execute("UPDATE cnr__pvehicles SET x=?,y=?,z=?,rz=? WHERE id=?",x,y,z,rz,id)
	end
end

-- system

function onPlayerPurchaseVehicle(player, model, x,y,z,rz, boughtPrice, plate, r1,g1,b1,r2,g2,b2)
	local account = exports.USGaccounts:getPlayerAccount(player)
	return insert(onPurchasedVehicleInserted, {player, model, x,y,z,rz, boughtPrice, plate,r1,g1,b1,r2,g2,b2},
		"INSERT INTO cnr__pvehicles ( owner, model, x,y,z,rz, boughtprice,plate,r,g,b,r2,g2,b2 )\
		VALUES ( ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",
		account, model, x,y,z, rz, boughtPrice,plate,r1,g1,b1,r2,g2,b2)
end

function onPurchasedVehicleInserted(id, player, model, x,y,z,rz, boughtPrice, plate,r1,g1,b1,r2,g2,b2)
	if(not id) then error("onPurchasedVehicleInserted: no id! player: "..getPlayerName(player)) end
	local account = exports.USGaccounts:getPlayerAccount(player)
	local vehInfo = { id = id, model = model, x = x,y = y,z = z,rz = rz, health = 1000, owner = account, spawned = 1,
		plate=plate,boughtprice = boughtPrice, r=r1,g=g1,b=b1,r2=r2,g2=g2,b2=b2,wheels={0,0,0,0}}
	vehicles[id] = vehInfo
	if(not accountVehicles[account]) then
		accountVehicles[account] = {id}
	else
		table.insert(accountVehicles[account], id)
	end	
	if(isElement(player) and exports.USGrooms:getPlayerRoom(player) == "cnr") then
		triggerClientEvent(player, "USGcnr_pvehicles.client.addVehicle", player, vehInfo)
		local veh = spawnVehicle(id)
		if(isElement(veh)) then
			warpPedIntoVehicle(player, veh)
		end
	end
end

function repairVehicle(id, player)
	if(vehicles[id] and vehicles[id].health < 250) then
		if(exports.USGcnr_money:buyItem(player, 5000, "a repair for your "..getVehicleNameFromModel(vehicles[id].model))) then
			vehicles[id].health = 1000
			vehicles[id].wheels = {0,0,0,0}
			local px,py, pz = getElementPosition(player)
			recoverVehicle(id, px, py)
			if(isElement(vehicles[id].element)) then
				if(getElementHealth(vehicles[id].element) < 250) then -- gonna need to respawn
					destroyElement(vehicles[id].element)
					spawnVehicle(id)
				else
					setElementHealth(vehicles[id].element, 1000)
				end
			end
			triggerClientEvent(player, "USGcnr_pvehicles.client.onVehicleRepaired", player, id)
			exports.USGcnr_money:logTransaction(player, "bought a repair for your "..getVehicleNameFromModel(vehicles[id].model).." for $5,000")
			return true
		end
		return false
	else
		return false
	end
end

function getVehicleOwnerPlayer(id)
	if(not vehicles[id]) then return false end
	local owner = vehicles[id].owner
	for i, player in ipairs(getElementsByType("player")) do
		if(exports.USGaccounts:getPlayerAccount(player) == owner and exports.USGrooms:getPlayerRoom(player) == "cnr") then
			return player
		end
	end
	return false
end

function spawnVehicle(id)
	if(vehicles[id] and not isElement(vehicles[id].element)) then
		local info = vehicles[id]
		if(info.health >= 250) then
			local veh = createVehicle(info.model, info.x, info.y, info.z+0.3, 0, 0, info.rz, info.plate or "   USG  ")
			setElementHealth(veh, info.health)
			setVehicleColor(veh, info.r, info.g, info.b, info.r2, info.g2, info.b2)
			setVehicleWheelStates(veh, unpack(info.wheels or {0}))
			vehicles[id].element = veh
			vehicles[id].spawned = 1
			elementID[veh] = id
			addEventHandler("onElementDestroy", veh, onElementDestroyed)
			addEventHandler("onVehicleExplode", veh, onVehicleExplode)
			if(info.parked == 1) then
				parkVehicle(veh)
			end
			local player = getVehicleOwnerPlayer(id)
			if(isElement(player)) then
				triggerClientEvent(player, "USGcnr_pvehicles.client.onVehicleSpawned", veh, id)
			end
			return veh
		else
			return false -- vehicle needs repair
		end
	else
		return false
	end
end

function saveVehicle(id)
	if(vehicles[id] and isElement(vehicles[id].element)) then
		vehicles[id].health = getElementHealth(vehicles[id].element)
		local x,y,z = getElementPosition(vehicles[id].element)
		vehicles[id].x, vehicles[id].y, vehicles[id].z = x,y,z
		local _,_,rz = getElementRotation(vehicles[id].element)
		vehicles[id].rz = rz
		local r,g,b,r2,g2,b2,_,_,_,_,_,_ = getVehicleColor(vehicles[id].element, true)
		vehicles[id].r, vehicles[id].g, vehicles[id].b, vehicles[id].r2, vehicles[id].g2, vehicles[id].b2 = r,g,b,r2,g2,b2
		local wheel1,wheel2,wheel3,wheel4 = getVehicleWheelStates(vehicles[id].element)
		vehicles[id].wheels = {wheel1,wheel2,wheel3,wheel4}
		local parked = isVehicleParked(vehicles[id].element) and 1 or 0
		return exports.MySQL:execute("UPDATE cnr__pvehicles SET health=?, x=?,y=?,z=?,rz=?,r=?,g=?,b=?,r2=?,g2=?,b2=?,wheel1=?,wheel2=?,wheel3=?,wheel4=?,spawned=?,parked=? WHERE id=?",
			vehicles[id].health, x,y,z,rz,r,g,b,r2,g2,b2,wheel1,wheel2,wheel3,wheel4,vehicles[id].spawned,parked,id)
	else
		return false
	end
end

function removeVehicle(id)
	if(vehicles[id] and isElement(vehicles[id].element)) then
		vehicles[id].spawned = 0
		saveVehicle(id)
		destroyElement(vehicles[id].element)
		local player = getVehicleOwnerPlayer(id)
		if(isElement(player)) then
			triggerClientEvent(player, "USGcnr_pvehicles.client.onVehicleRemoved", player, id)
		end	
		return true
	else
		return false
	end
end

function isVehiclePurchased(vehicle)
	return elementID[vehicle] ~= nil
end

function getVehicleOwner(element)
	if(elementID[element]) then
		return getVehicleOwnerPlayer(elementID[element])
	else
		return false
	end
end

-- events n such
function onElementDestroyed()
	elementID[source] = nil
end

function onVehicleExplode()
	local id = elementID[source]
	local vehicle = vehicles[id]
	removeVehicle(id)
end