loadstring(exports.MySQL:getQueryTool())()

addEvent("USGrace_mapmanager.requestList", true)
addEventHandler("USGrace_mapmanager.requestList", root,
	function ()
		if(exports.USGadmin:isPlayerMapManager(client)) then
			query(sendMapList, {client},"SELECT * FROM race_maps")
		end
	end
)

function sendMapList(maps, player)
	if(isElement(player) and exports.USGadmin:isPlayerMapManager(player)) then
		triggerLatentClientEvent(player, "USGrace_mapmanager.receiveList", player, maps)
	end
end

addEvent("USGrace_mapmanager.removeMap", true)
addEventHandler("USGrace_mapmanager.removeMap", root,
	function (id)
		if(exports.USGadmin:isPlayerMapManager(client) and id) then
			singleQuery(onMapFoundForDelete,{client},"SELECT * FROM race_maps WHERE id=?",id)
		end
	end
)

function onMapFoundForDelete(result, player)
	if(result) then
		if(isElement(player) and exports.USGadmin:isPlayerMapManager(player)) then
			exports.mysql:execute("DELETE FROM race_maps WHERE id=?",result.id)
			exports.USGmsg:msg(player, "Map deleted and being unloaded!", 0, 255, 0)
			exports.USGrace_maps:unloadMap(result.name)
			query(sendMapList, {player},"SELECT * FROM race_maps")
		end
	else
		exports.USGmsg:msg(player, "Map not found!", 255, 0, 0)
	end
end

addEvent("USGrace_mapmanager.addMap", true)
addEventHandler("USGrace_mapmanager.addMap", root,
	function (name, room)
		if(exports.USGadmin:isPlayerMapManager(client) and name and room) then
			refreshResources()
			if(exports.USGrace_maps:addMap(name, room)) then
				exports.USGmsg:msg(client, "Map added and successfully loaded!", 0, 255, 0)
				exports.mysql:execute("INSERT INTO race_maps ( name, room ) VALUES ( ?, ?)",name,room)
				query(sendMapList, {client},"SELECT * FROM race_maps")
			else
				exports.USGmsg:msg(client, "Map could not be loaded.", 255, 0, 0)
				if(not getResourceFromName(name)) then
					exports.USGmsg:msg(client, "Possible cause: resource not found on FTP", 255, 0, 0)
				end
			end
		end
	end
)

addEvent("USGrace_mapmanager.setAsNext", true)
addEventHandler("USGrace_mapmanager.setAsNext", root, 
	function (name, room)
		if(exports.USGadmin:isPlayerMapManager(client) and name and room) then
			if(exports.USGrace_maps:setRoomNextMap(room, name)) then
				exports.USGmsg:msg(client, "Map set as next map!", 0, 255, 0)
			else
				exports.USGmsg:msg(client, "Could not set as next map!", 255, 0, 0)
			end
		end
	end
)