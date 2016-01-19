data = {}

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

addEvent("USGsyndata.sync", true)
function sync(nData)
	for player, pData in pairs(nData) do
		if(not data[player]) then data[player] = {} end
		updateTable(data[player], pData)
	end
end
addEventHandler("USGsyndata.sync", root, sync)

function getPlayerData(player, room, key)
	if(data[player] and data[player][room] and data[player][room][key]) then
		return data[player][room][key]
	else
		return nil
	end
end

addEventHandler("onClientPlayerQuit", root, 
	function ()
		data[source] = nil
	end
)

addEvent("onPlayerExitRoom", true)
addEventHandler("onPlayerExitRoom", root,
	function(room)
		if(data[source]) then
			data[source][room] = nil
		end
	end
)