--[[local roomLimit = {
	cnr = 1000,
	dd = 350,
	str = 350,
	dm = 1000,
}

local playerWarnings = {}

function enforcePingLimit()
	for i, player in ipairs(getElementsByType("player")) do
		local room = exports.USGrooms:getPlayerRoom(player)
		if (room and roomLimit[room]) then
			if( getPlayerPing(player) > roomLimit[room]) then
				if (playerWarnings[player] and playerWarnings[player] > 3) then
					playerWarnings[player] = 0
					exports.USGrooms:removePlayerFromRoom(player)
					exports.USGmsg:msg(player, "You have been removed from your room because your ping is too high.", 255, 0, 0)
				else
					playerWarnings[player] = (playerWarnings[player] or 0) + 1
					outputChatBox(string.format("Your ping is too high for this room. Warnings: %0.1f\\4", playerWarnings[player]), player, 255, 100, 0)
				end
			elseif (playerWarnings[player]) then
				playerWarnings[player] = playerWarnings[player]  -0.5
				if (playerWarnings[player] <= 0) then
					playerWarnings[player] = nil
				end
			end
		end
	end
end

function checkPlayerPingOnJoin(room)
	if(roomLimit[room] and getPlayerPing(source) > roomLimit[room]) then
		cancelEvent()
		exports.USGmsg:msg(source, "Your ping is currently too high to join this room.", 255, 0, 0)
	end
end

addEventHandler("onResourceStart", resourceRoot,
	function ()
		addEvent("onPlayerPreJoinRoom")
		--addEventHandler("onPlayerPreJoinRoom", root, checkPlayerPingOnJoin)
		setTimer(enforcePingLimit, 10000, 0)
	end
)
addEventHandler("onPlayerQuit", root,
	function ()
		playerWarnings[source] = nil
	end
)
]]