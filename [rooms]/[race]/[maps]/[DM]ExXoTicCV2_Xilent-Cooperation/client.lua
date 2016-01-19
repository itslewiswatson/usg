    -----Chatbox-----
outputChatBox("#8c8c8cVita|#93E0F1ExXoTicC: #ffffffPress '#93E0F1m#FFFFFF' to turn the music ON/OFF.",255,255,255,true)
outputChatBox("#8c8c8cVita|#93E0F1ExXoTicC: #ffffffGood #93E0F1Luck #FFFFFFand have #93E0F1FUN!",255,255,255,true)
    -----Texturen-----
addEventHandler("onClientResourceStart", getResourceRootElement(getThisResource()),
function()
        txd = engineLoadTXD ( "airportrminl_sfse.txd" )
    engineImportTXD ( txd, 10755 )
        txd = engineLoadTXD ( "cranes_dyn2.txd" )
     engineImportTXD ( txd, 1383 )
end
)    
local hitmarker= createMarker(4861.5, -209.5, 2.2000000476837, "corona", 4, 0, 0, 0, 255)
setElementDimension(hitmarker,0)
    -----Teleport-----
function markerHit(hitPlayer, matchingDimension)
    if source == hitmarker then
        local vehicle = getPedOccupiedVehicle(hitPlayer);
        if hitPlayer == getLocalPlayer() then
                setElementRotation(vehicle, 0, 0, 270)
                setElementPosition(vehicle, 6521.7001953125, -1995.0999755859, 2) 
                setVehicleFrozen(vehicle, true)
                setTimer(setVehicleFrozen, 100, 1, vehicle, false)
                fadeCamera ( false, 0.0, 0, 0, 0 )
                setCameraTarget ( getLocalPlayer() )
                setTimer(fadeCamera, 100, 1, true, 0.0, 0, 0, 0)
        end
    end
end
    -----Musik-----
function startMusic()
    setRadioChannel(0)
    song = playSound("http://vita.gamers-board.com/serverfiles/race/xilent.mp3",true)
end
function makeRadioStayOff()
    setRadioChannel(0)
    cancelEvent()
end
function toggleSong()
    if not songOff then
        setSoundVolume(song,0)
        songOff = true
        removeEventHandler("onClientPlayerRadioSwitch",getRootElement(),makeRadioStayOff)
    else
        setSoundVolume(song,1)
        songOff = false
        setRadioChannel(0)
        addEventHandler("onClientPlayerRadioSwitch",getRootElement(),makeRadioStayOff)
    end
end
addEventHandler("onClientResourceStart",getResourceRootElement(getThisResource()),startMusic)
addEventHandler("onClientPlayerRadioSwitch",getRootElement(),makeRadioStayOff)
addEventHandler("onClientPlayerVehicleEnter",getRootElement(),makeRadioStayOff)
addEventHandler("onClientMarkerHit", getRootElement(), markerHit)
addCommandHandler("music",toggleSong)
bindKey("m","down",toggleSong)
 setCloudsEnabled(false)
