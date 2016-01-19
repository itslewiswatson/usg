local enabledRooms = { dd = true, str = true, dm = true}
local playerBlips = {}

function isResourceReady(name)
	return getResourceFromName(name)
	and getResourceState(getResourceFromName(name)) == "running"
end

function createPlayerBlip(player)
	if(player ~= localPlayer and not isElement(playerBlips[player])) then
		local r,g,b = 255,255,255
		local blip = createBlipAttachedTo(player, 0,2,r,g,b,255,0,1000)
		playerBlips[player] = blip
	end
end

function destroyPlayerBlip(player)
	if(isElement(playerBlips[player])) then
		destroyElement(playerBlips[player])
	end
	playerBlips[player] = nil
end


addEvent("onPlayerJoinRoom", true)
addEventHandler("onPlayerJoinRoom", root, 
	function (room)
		if(source == localPlayer and enabledRooms[room]) then
			createRoomBlips()
		elseif(enabledRooms[room] and room == exports.USGrooms:getPlayerRoom()) then
			createPlayerBlip(source)
		end
	end
)

addEventHandler("onClientResourceStart", resourceRoot, 
	function ()
		if(isResourceReady("USGrooms") and enabledRooms[exports.USGrooms:getPlayerRoom()]) then
			createRoomBlips()
		end
	end
)

function createRoomBlips()
	local myRoom = exports.USGrooms:getPlayerRoom()
	for i, player in ipairs(getElementsByType("player")) do
		if(exports.USGrooms:getPlayerRoom(player) == myRoom and player ~= localPlayer) then
			createPlayerBlip(player)
		end
	end
end

addEvent("onPlayerExitRoom", true)
function onPlayerExitRoom(room)
	if(not enabledRooms[room]) then return end
	if(source == localPlayer) then
		for player, blip in pairs(playerBlips) do
			destroyPlayerBlip(player)
		end
		playerBlips = {}
	else
		destroyPlayerBlip(source)
	end
end
addEventHandler("onPlayerExitRoom", root, onPlayerExitRoom)

function onPlayerQuit()
	destroyPlayerBlip(source)
end
addEventHandler("onClientPlayerQuit", root, onPlayerQuit)