function onJoinRoom(room)
	if(room ~= "dd") then return false end
	playerJoinRoom(source)
end
addEventHandler("onPlayerJoinRoom", root, onJoinRoom)

function playerJoinRoom(player)
	addEventHandler("USGrace_maps.onMapLoaded", player, onClientMapLoaded)
	showChat(player,true)
	spawnPlayerDD(player)
	if(not isTimer(onResourceStartTimer)) then onPlayerJoinGame(player) end
	bindKey(player, "arrow_r", "up", nextSpectateTarget)
	bindKey(player, "arrow_l", "up", previousSpectateTarget)
	showPlayerHudComponent(player,"all",false)
	showPlayerHudComponent(player,"radar",true)
	showPlayerHudComponent(player,"radio",true)
	showPlayerHudComponent(player,"vehicle_name",true)
	setPedStat(player, 229, 1000)
	toggleControl(player, "vehicle_secondary_fire", false)
	setPlayerNametagShowing(player, false)
	triggerClientEvent(player, "USGrace_ranklist.init", player)
end

function playerExitRoom(player)
	showPlayerHudComponent(player,"all",true)
	removeEventHandler("USGrace_maps.onMapLoaded", player, onClientMapLoaded)
	removePlayerVehicle(player)
	onPlayerExitGame(player)
	local x,y,z = getElementPosition(player)
	killPed(player)
	setCameraMatrix(player,x,y,z+30,x,y,z)
	unbindKey(player, "arrow_r", "up", nextSpectateTarget)
	unbindKey(player, "arrow_l", "up", previousSpectateTarget)
	setPedStat(player, 229, 0)
	toggleControl(player, "vehicle_secondary_fire", true)
	setPlayerNametagShowing(player, true)
	triggerClientEvent(player, "USGrace_ranklist.close", player)
end

function onExitRoom(prevRoom)
	if(prevRoom ~= "dd") then return false end
	playerExitRoom(source)
end
addEventHandler("onPlayerExitRoom", root, onExitRoom)

addEventHandler("onResourceStart", resourceRoot,
	function ()
		onResourceStartTimer = setTimer(loadGame, 2000, 1) -- fix for warpPedIntoVehicle onStart issue: http://bugs.mtasa.com/view.php?id=7855
		for i, player in ipairs(exports.USGrooms:getPlayersInRoom("dd")) do
			playerJoinRoom(player)
		end
	end
)
addEventHandler("onResourceStop", resourceRoot,
	function ()
		for i, player in ipairs(exports.USGrooms:getPlayersInRoom("dd")) do
			playerExitRoom(player)
		end
	end
)

function onVehicleStartExit(player)
	if(exports.USGrooms:getPlayerRoom(player) == "dd") then
		cancelEvent()
		onPlayerWasted(player)
	end
end
addEventHandler("onVehicleStartExit", root, onVehicleStartExit)