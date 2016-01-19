addEventHandler("onClientResourceStart",resourceRoot,
	function ()
		local x,y = guiGetScreenSize()
		musics = playSound("music.mp3",true)
	end
)

addCommandHandler("stopmusic",
	function ()
		setSoundVolume(musics,0)
	end
)

addCommandHandler("startmusic",
	function ()
		setSoundVolume(musics,1)
	end
)