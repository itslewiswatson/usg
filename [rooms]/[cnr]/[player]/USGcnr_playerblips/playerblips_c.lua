local playerBlips = {}

function isResourceReady(name)
	return getResourceFromName(name)
	and getResourceState(getResourceFromName(name)) == "running"
end

function createPlayerBlip(player)
	if(player ~= localPlayer and not isElement(playerBlips[player])) then
		local r,g,b = exports.USG:getPlayerTeamColor(player)
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

addEvent("onPlayerChangeJob", true)
addEventHandler("onPlayerChangeJob", root,
	function ()
		if(isElement(playerBlips[source])) then
			local r,g,b = exports.USG:getPlayerTeamColor(source)
			setBlipColor(playerBlips[source],r,g,b,255)
		end
	end
)


addEvent("onPlayerJoinRoom", true)
addEventHandler("onPlayerJoinRoom", localPlayer, 
	function (room)
		if(room == "cnr") then
			createRoomBlips()
		end
	end
)

addEventHandler("onClientResourceStart", resourceRoot, 
	function ()
		if(isResourceReady("USGrooms") and exports.USGrooms:getPlayerRoom() == "cnr") then
			createRoomBlips()
		end
	end
)

function createRoomBlips()
	for i, player in ipairs(getElementsByType("player")) do
		if(exports.USGrooms:getPlayerRoom(player) == "cnr" and player ~= localPlayer) then
			createPlayerBlip(player)
		end
	end
end

addEvent("onPlayerJoinCNR", true)
function onPlayerJoinCNR(data)
	if(source ~= localPlayer) then
		createPlayerBlip(source)
	end
end
addEventHandler("onPlayerJoinCNR", root, onPlayerJoinCNR)

addEvent("onPlayerExitRoom", true)
function onPlayerExitRoom(room)
	if(room ~= "cnr") then return end
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