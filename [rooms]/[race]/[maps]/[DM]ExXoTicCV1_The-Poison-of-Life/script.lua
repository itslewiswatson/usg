--Bounce

Me = getLocalPlayer()
Root = getRootElement()

function Main () 
gravityjump1 = createMarker(3664.1999511719, 1181.5, 21.10000038147, "corona", 20, 0, 221, 255, 100)
gravityjump2 = createMarker(4222.5, 1196.0999755859, 122.40000152588, "corona", 6, 0, 0, 0, 0)
gravityjump3 = createMarker(4222.3999023438, 1175.6999511719, 122.40000152588, "corona", 6, 0, 0, 0, 0)
gravityjump4 = createMarker(4222.6000976563, 1185.9000244141, 122.40000152588, "corona", 6, 0, 0, 0, 0)
gravityjump5 = createMarker(1, 2, 3, "corona", 6, 0, 221, 255, 100)


addEventHandler ( "onClientMarkerHit", getRootElement(), MainFunction )
end


addEventHandler( "onClientResourceStart", getResourceRootElement(getThisResource()), Main )


function MainFunction ( hitPlayer, matchingDimension )
vehicle = getPedOccupiedVehicle ( hitPlayer )
if hitPlayer ~= Me then return end
	if source == gravityjump1 then
		speedx, speedy, speedz = getElementVelocity ( vehicle ) 
		setElementVelocity(vehicle, 2.5, 0, 2)
	end
	if source == gravityjump2 then
		speedx, speedy, speedz = getElementVelocity ( vehicle ) 
		setElementVelocity(vehicle, 0, 0, 0)
	end
	if source == gravityjump3 then
		speedx, speedy, speedz = getElementVelocity ( vehicle ) 
		setElementVelocity(vehicle, 0, 0, 0)	
	end
	if source == gravityjump4 then
		speedx, speedy, speedz = getElementVelocity ( vehicle ) 
		setElementVelocity(vehicle, 0, 0, 0)
	end
	if source == gravityjump5 then
		speedx, speedy, speedz = getElementVelocity ( vehicle ) 
		setElementVelocity(vehicle, 0, -0.3, 0.4)
	end
end

--Replace

function replace ()
palmtxd = engineLoadTXD("gta_tree_palm.txd")
engineImportTXD(palmtxd, 622 )
local palmdff = engineLoadDFF('veg_palm03.dff', 0) 
engineReplaceModel(palmdff, 622)  
end
addEventHandler( "onClientResourceStart", getResourceRootElement(getThisResource()), replace )

--Wether

setCloudsEnabled ( false )

--Music

function startMusic()
    setRadioChannel(0)
    song = playSound("http://vita.gamers-board.com/serverfiles/race/freakzer3",true)
	outputChatBox("#8c8c8cVita|#93E0F1ExXoTicC: #ffffffPress '#93E0F1m#FFFFFF' to turn the music ON/OFF.",255,255,255,true)
	outputChatBox("#8c8c8cVita|#93E0F1ExXoTicC: #ffffffGood #93E0F1Luck #FFFFFFand have #93E0F1FUN!",255,255,255,true)
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
addCommandHandler("music",toggleSong)
bindKey("m","down","music")