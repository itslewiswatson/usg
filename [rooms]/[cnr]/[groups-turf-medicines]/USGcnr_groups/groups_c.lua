local updatingBlips = false
local updateBlipsTimer
local playerBlips = {}

function onResStart(res)
	if(getResourceName(res) == "USGrooms") then
		if(exports.USGrooms:getPlayerRoom() == "cnr") then
			triggerServerEvent("USGcnr_groups.initGroupData", localPlayer)
			updateBlipsTimer = setTimer(updateBlips, 1000, 0)
			updatingBlips = true
		end
		removeEventHandler("onClientResourceStart", root, onResStart)
	end
end

addEventHandler("onClientResourceStart", resourceRoot,
	function ()
		if(getResourceFromName("USGrooms") and getResourceState(getResourceFromName("USGrooms")) == "running" and exports.USGrooms:getPlayerRoom() == "cnr") then
			triggerServerEvent("USGcnr_groups.initGroupData", localPlayer)
			updateBlipsTimer = setTimer(updateBlips, 1000, 0)
			updatingBlips = true
		else
			addEventHandler("onClientResourceStart", root, onResStart)
		end
	end
)

-- blips
addEvent("onPlayerJoinRoom", true)
function onJoinRoom(room)
	if(room == "cnr" and not updatingBlips) then
		updateBlipsTimer = setTimer(updateBlips, 1000, 0)
		updatingBlips = true
	end
end
addEventHandler("onPlayerJoinRoom", localPlayer, onJoinRoom)

addEvent("onPlayerExitRoom", true)
function onExitRoom(room)
	if(room == "cnr") then
		if(source == localPlayer and updatingBlips) then
			killTimer(updateBlipsTimer)
			updatingBlips = false
		end
		removePlayerBlip(source)
	end
end
addEventHandler("onPlayerExitRoom", root, onExitRoom)

function onPlayerQuit()
	removePlayerBlip(source)
end
addEventHandler("onClientPlayerQuit", root, onPlayerQuit)

function updateBlips()
	local pGroup = getPlayerGroupName()
	for i, player in ipairs(getElementsByType("player")) do
		if(player ~= localPlayer and exports.USGrooms:getPlayerRoom(player) == "cnr") then
			local group = exports.USGsyncdata:getPlayerData(player, "cnr", "group")
			if (pGroup and group == pGroup) then
				addPlayerBlip(player)
			else
				removePlayerBlip(player)
			end
		end
	end
end

function addPlayerBlip(player)
	if(not isElement(playerBlips[player])) then
		local blip = createBlipAttachedTo(player, 60)
		setBlipVisibleDistance(blip, 9999)
		exports.USGcnr_blips:setBlipDimension(blip, exports.USGrooms:getRoomDimension("cnr"))
		exports.USGcnr_blips:setBlipUserInfo(blip, "Player blips", "Group members")
		playerBlips[player] = blip
	end
end

function removePlayerBlip(player)
	if(isElement(playerBlips[player])) then
		destroyElement(playerBlips[player])
	end
end