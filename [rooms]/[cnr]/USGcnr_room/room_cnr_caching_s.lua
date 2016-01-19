-- caching

function setPlayerDataCache(player,key,duration,...)
	if ( not isElement(player) or type(key) ~= "string" 
		or type(duration) ~= "number" or exports.USGrooms:getPlayerRoom(player) ~= "cnr" ) then return false end
	local values = {...}
	if not ( playerDataCache[player] ) then playerDataCache[player] = {} end
	if key == "weapons" then
		if not values[1] then
			values = getWeaponsString(player)
		elseif type(values[1]) ~= "string" then
			return false
		end
	elseif key == "dim" then
		if not values[1] then
			values = getElementDimension(player)
		elseif type(values[1]) ~= "number" then
			return false
		end
	elseif key == "int" then
		if not values[1] then
			values = getElementInterior(player)
		elseif type(values[1]) ~= "number" then
			return false
		end
	elseif key == "money" then
		if not values[1] then
			values = getPlayerMoney(player)
		elseif type(values[1]) ~= "number" then
			return false
		end
	elseif key == "pos" and not ( values[1] and values[2] and values[3] ) then
		values = {getElementPosition(player)}
	elseif key == "health" then
		if not values[1] then
			values = getElementHealth(player)
		elseif type(values[1]) ~= "number" then
			return false
		end
	end
	if type(values) == "table" and #values == 1 then
		values = values[1]
	end
	setTimer(clearPlayerCache,duration,1,player,key)
	playerDataCache[player][key] = values
end

function clearPlayerCache(player, key)
	if ( not isElement(player) or type(key) ~= "string" or not playerDataCache[player] ) then return false end
	playerDataCache[player][key] = nil -- empty the cache
end