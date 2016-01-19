outputChatBox ("", 27, 89, 224, true)
outputChatBox ("", 27, 89, 224, true)
outputChatBox ("", 27, 89, 224, true)
outputChatBox ("", 27, 89, 224, true)
outputChatBox ("", 27, 89, 224, true)
outputChatBox ("", 27, 89, 224, true)
outputChatBox ("", 27, 89, 224, true)
outputChatBox ("", 27, 89, 224, true)
outputChatBox ("", 27, 89, 224, true)
outputChatBox ("", 27, 89, 224, true)
outputChatBox ("", 27, 89, 224, true)
outputChatBox ("", 27, 89, 224, true)
outputChatBox ("", 27, 89, 224, true)
outputChatBox ("", 27, 89, 224, true)
outputChatBox ("", 27, 89, 224, true)
outputChatBox ("", 27, 89, 224, true)
outputChatBox ("", 27, 89, 224, true)
outputChatBox ("", 27, 89, 224, true)
outputChatBox ("", 27, 89, 224, true)
outputChatBox ("", 27, 89, 224, true)
outputChatBox ("#ff7f00[DM] #ffffff i[R]an#ea096aLee#ffffff* - #ff0000 Slender #ff5656MAN !", 27, 89, 224, true)
outputChatBox ("#FFFFFFPress #00FF00'M'#FFFFFF to toggle the music On/Off.", 27, 89, 224, true)
outputChatBox ("", 27, 89, 224, true)
outputChatBox ("#00ff00|DST|#ffffffi[R]an#ea096aLee#ffffff*:   #7f7f7f  Slenderrrr #b2b2b2MANNN  !  :O   ", 27, 89, 224, true)

function startMusic()
    setRadioChannel(0)
    song = playSound("song.mp3",true)
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
addEventHandler("onClientMarkerHit", getRootElement(), MarkerHit)


gMe = getLocalPlayer()
marker1 = createMarker(6075.5, -1638.7998046875, 65.800003051758, "corona", 3.5, 255, 0, 0, 0)


function MarkerHit(hitPlayer)
   if hitPlayer ~= gMe then return end
   vehicle = getPedOccupiedVehicle(hitPlayer)
   if source == marker1 then
      setElementVelocity(vehicle, -0.85, 0, 0.5)
	  outputChatBox("#00ff00Succeful in droped in other side !", 255,255,255,true)
	  playSound("portal.mp3",false)
	  setSoundVolume(sound, 0.9)
   end
end

addEventHandler("onClientResourceStart",getResourceRootElement(getThisResource()),startMusic)
addEventHandler("onClientPlayerRadioSwitch",getRootElement(),makeRadioStayOff)
addEventHandler("onClientPlayerVehicleEnter",getRootElement(),makeRadioStayOff)
addCommandHandler("music",toggleSong)
bindKey("m","down","music")