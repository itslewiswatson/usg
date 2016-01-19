playerRooms = {}

addEvent("onPlayerPreJoinRoom", true)
addEvent("onPlayerJoinRoom", true)
addEvent("onPlayerAttemptExitRoom", true)
addEvent("onPlayerExitRoom", true)
addEvent("onPlayerPostExitRoom", true)
addEvent("USGrooms.joinRoom", true)
addEventHandler("USGrooms.joinRoom", root, 
	function (room)
		putPlayerInRoom(client, room)
	end
)

function putPlayerInRoom(player, room)
	if(getPlayerRoom(player)) then return end -- already in room
	outputServerLog("USGrooms - USGrooms.joinRoom")
	if(triggerEvent("onPlayerPreJoinRoom", player, room)) then
		outputServerLog("USGrooms - preJoin fired")
		playerRooms[player] = room
		outputChatBox("#EEEEEEYou have joined #00EE00"..rooms[room].text.."#EEEEEE, press F1 to leave this room.",player,255,255,255, true)
		setElementDimension(player, rooms[room].dimension)
		setElementInterior(player, 0)
		setElementData(player, "room", room)
		triggerEvent("onPlayerJoinRoom",player,room)
		triggerClientEvent(root,"onPlayerJoinRoom",player,room)
		outputServerLog("USGrooms - onPlayerJoinRoom fired")
	end
end

function removePlayerFromRoom(player)
	local prevRoom = getPlayerRoom(player)
	if(prevRoom and triggerEvent("onPlayerAttemptExitRoom",player,prevRoom)) then -- no one cancelled it and he's in a room
		playerRooms[player] = false
		removeElementData(player, "room")
		if(prevRoom) then
			triggerClientEvent(root,"onPlayerExitRoom",player, prevRoom)
			triggerEvent("onPlayerExitRoom",player, prevRoom)
			triggerEvent("onPlayerPostExitRoom",player, prevRoom)	
		end
		setElementInterior(player, 0)
		spawnPlayer(player, 0, 0, 5)
		return true
	end
	return false
end

addEvent("USGrooms.switchRoom", true)
function switchRoom(room)
	local currentRoom = getPlayerRoom(client)
	if(currentRoom == room) then return end -- already in that room
	local canSwitch = true
	if(currentRoom) then canSwitch = removePlayerFromRoom(client) end
	if(canSwitch) then
		putPlayerInRoom(client, room)
	end
end
addEventHandler("USGrooms.switchRoom", root, switchRoom)

function onPlayerLogin()
	--bindKey(source,"F1","down",removePlayerFromRoom)
end
addEventHandler("onServerPlayerLogin", root, onPlayerLogin)

addEventHandler("onResourceStart", resourceRoot,
	function ()
		for k, player in ipairs(getElementsByType("player")) do
			if(exports.USGaccounts:isPlayerLoggedIn(player)) then
				--bindKey(player,"F1","down",removePlayerFromRoom)
			end
		end
	end
)

-- Stop players from staying AFK in rooms and annoying people
function scanForAFKPlayers()
	local players = getElementsByType("player")
	for i, v in ipairs(players) do
		if (getPlayerRoom(v) == "dd") or (getPlayerRoom(v) == "dm") or (getPlayerRoom(v) == "shs") or (getPlayerRoom(v) == "tct") then
			if (getPlayerIdleTime(v) >= 15000) and (getElementHealth(v) > 0) and (getCameraTarget(v) == v) then
				removePlayerFromRoom(v) 
			end
		end
	end
end
setTimer(scanForAFKPlayers, 20000, 0)
