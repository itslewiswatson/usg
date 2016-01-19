keys = { rooms = {} }
cachedData = {}
players = getElementsByType("player")

addEventHandler("onResourceStart", resourceRoot, 
	function ()
		setTimer(syncData, 2000, 0)
	end
)

addEventHandler("onServerPlayerLogin", root, 
	function ()
		table.insert(players, source)
		cachedData[source] = {}
		triggerLatentClientEvent(source, "USGsyndata.sync", source, cachedData)
	end
)

addEventHandler("onPlayerQuit", root, 
	function ()
		for i, player in ipairs(players) do
			if(player == source) then
				table.remove(players, i)
				break
			end
		end
		cachedData[source] = nil
	end
)

addEvent("onPlayerExitRoom")
addEventHandler("onPlayerExitRoom", root,
	function(room)
		if(cachedData[source]) then
			cachedData[source][room] = nil
		end
	end
)

function setRoomDataValue(tab, player, room, key, value)
	if(not tab[player]) then
		tab[player] = { [room] = { [key] = value } }
	elseif(not tab[player][room]) then
		tab[player][room] = { [key] = value }
	else
		tab[player][room][key] = value
	end
end
function setDataValue(tab, player, key, value)
	if(not tab[player]) then
		tab[player] = { [key] = value }
	else
		tab[player][key] = value
	end
end

function updateTable(table, newTable)
	for k, v in pairs(newTable) do
		if(type(v) == "table") then
			if(not table[k]) then table[k] = {} end
			updateTable(table[k], v)
		else
			table[k] = v
		end
	end
end

function updateCache(player, newData)
	if(not cachedData[player]) then
		cachedData[player] = {}
	end
	updateTable(cachedData[player], newData)
end

function syncData()
	local playerData = {}
	for i, player in ipairs(players) do
		if(isElement(player)) then
			for key, get in pairs(keys) do
				if(key ~= "rooms") then
					local value = get(player)
					local existing = cachedData[player] and cachedData[player][key] ~= nil
					if(existing) then
						if(value ~= cachedData[player][key]) then
							setDataValue(playerData, player, key, value)
						end
					else
						setDataValue(playerData, player, key, value)
					end
				end
			end			
			local room = exports.USGrooms:getPlayerRoom(player)
			if(keys.rooms[room]) then
				for key, get in pairs(keys.rooms[room]) do
					local value = get(player)
					local existing = cachedData[player] and cachedData[player][room] and cachedData[player][room][key] ~= nil
					if(existing) then
						if(value ~= cachedData[player][room][key]) then
							setRoomDataValue(playerData, player, room, key, value)
						end
					else
						setRoomDataValue(playerData, player, room, key, value)
					end
				end
			end
		end
	end
	updateTable(cachedData, playerData)
	for i, player in ipairs(getElementsByType("player")) do
		if(exports.USGaccounts:isPlayerLoggedIn(player)) then
			triggerLatentClientEvent(player,"USGsyndata.sync", player, playerData)
		end
	end
end