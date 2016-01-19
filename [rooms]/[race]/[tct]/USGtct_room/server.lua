function onJoinRoom(room)
    if(room ~= "tct") then return false end
    playerJoinRoom(source)
end
addEventHandler("onPlayerJoinRoom", root, onJoinRoom)


addEvent("USGtct_room.choosen",true)
function playerJoinRoom(player)
    --addEventHandler("USGrace_maps.onMapLoaded", client, onClientMapLoaded)
    showChat(player,true)
    spawnPlayerTCT(player)
    if(not isTimer(onResourceStartTimer)) then onPlayerChooseTeam(player) end
    bindKey(player, "arrow_r", "up", nextSpectateTarget)
    bindKey(player, "arrow_l", "up", previousSpectateTarget)
    showPlayerHudComponent(player,"all",true)
    showPlayerHudComponent(player,"radar",true)
    showPlayerHudComponent(player,"radio",true)
    setPedStat(player, 230, 1000)
    setPedStat(player, 24, 500)
    triggerClientEvent(player, "USGrace_ranklist.init", player) 
end
addEventHandler("USGtct_room.choosen",resourceRoot,playerJoinRoom)

function playerExitRoom(player)
    setElementData(player,"Team","")
    showPlayerHudComponent(player,"all",true)   
    onPlayerExitGame(player)
    local x,y,z = getElementPosition(player)
    killPed(player)
    setCameraMatrix(player,x,y,z+30,x,y,z)
    unbindKey(player, "arrow_r", "up", nextSpectateTarget)
    unbindKey(player, "arrow_l", "up", previousSpectateTarget)
    setPedStat(player, 230, 0)
    setPlayerNametagShowing(player, true)
    removeEventHandler("USGrace_maps.onMapLoaded", player, onClientMapLoaded)
    setPlayerNametagColor ( player ,false)
    triggerClientEvent(player, "USGrace_ranklist.close", player)    
end

function onExitRoom(prevRoom)
    if(prevRoom ~= "tct") then return false end
    playerExitRoom(source)
end
addEventHandler("onPlayerExitRoom", root, onExitRoom)

addEventHandler("onResourceStart", resourceRoot,
    function ()
        onResourceStartTimer = setTimer(loadGame, 2000, 1) -- fix for warpPedIntoVehicle onStart issue: http://bugs.mtasa.com/view.php?id=7855
        for i, player in ipairs(exports.USGrooms:getPlayersInRoom("tct")) do
                playerJoinRoom(player)
        end
    end
)
addEventHandler("onResourceStop", resourceRoot,
    function ()
    for i, player in ipairs(exports.USGrooms:getPlayersInRoom("tct")) do
            playerExitRoom(player)
        end
    end
)