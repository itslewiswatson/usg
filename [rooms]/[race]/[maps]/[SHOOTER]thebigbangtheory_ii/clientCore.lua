-- This script is created by MegaDreams for [FUN] ExXoTicC ft. MegaDreams - The Big Bang Theory II, Don't even think about stealing it.

addEventHandler('onClientResourceStart', resourceRoot, 
function() 
	song = playSound("song.ogg",true)
	end 
)


addEventHandler("onClientResourceStart",getResourceRootElement(getThisResource()),
function ()
	setSoundVolume(song,1)
	setRadioChannel ( 0 )
	
	palmtxd = engineLoadTXD("gta_tree_palm.txd")
	engineImportTXD(palmtxd, 622 )

	local palmdff = engineLoadDFF('veg_palm03.dff', 0) 
	engineReplaceModel(palmdff, 622) 
	
outputChatBox("#8c8c8cVita|#88ff00ExXoTicC: #ffffffPress '#88ff00z#FFFFFF' to turn the music ON/OFF.",255,255,255,true)
outputChatBox("#8c8c8cVita|#88ff00ExXoTicC: #ffffffPress '#88ff00lshift#FFFFFF' for a mini-jump.",255,255,255,true)
outputChatBox("#8c8c8cVita|#88ff00ExXoTicC: #ffffffGood #88ff00Luck #FFFFFFand have #88ff00FUN!",255,255,255,true)
	
	local keys = nil
	local keysCount = 0
	for keyName, state in pairs(getBoundKeys("fire")) do
		if keysCount == 0 then
			keys = keyName
		else
			keys = keys.." #FFFFFFor #64a6ff"..keyName
		end
		keysCount = keysCount + 1
    end
	
	keys = nil
	keysCount = 0
	for keyName, state in pairs(getBoundKeys("jump")) do
		if keysCount == 0 then
			keys = keyName
		else
			keys = keys.." #FFFFFFor #64a6ff"..keyName
		end
		keysCount = keysCount + 1
    end
end
)

function stationChange()
    setRadioChannel(0)
    cancelEvent()
end
addEventHandler("onClientPlayerRadioSwitch",getRootElement(),stationChange)
addEventHandler("onClientPlayerVehicleEnter",getRootElement(),stationChange)

function toggleSong()
    if not songOff then
	    setSoundVolume(song,0)
		songOff = true
		removeEventHandler("onClientPlayerRadioSwitch",getRootElement(),stationChange)
	else
	    setSoundVolume(song,1)
		songOff = false
		setRadioChannel(0)
		addEventHandler("onClientPlayerRadioSwitch",getRootElement(),stationChange)
	end
end

addCommandHandler("music",toggleSong)
bindKey("z","down","music")