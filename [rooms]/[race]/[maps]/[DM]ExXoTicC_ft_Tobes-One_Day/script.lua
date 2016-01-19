--Bounce

Me = getLocalPlayer()
Root = getRootElement()

function Main () 
gravityjump1 = createMarker(5153.6000976563, -3944.8000488281, 238.30000305176, "corona", 3, 0, 255, 255, 100)
gravityjump2 = createMarker(1, 2, 3, "corona", 25, 0, 221, 255, 100)
gravityjump3 = createMarker(1, 2, 3, "corona", 10, 0, 221, 255, 100)
gravityjump4 = createMarker(1, 2, 3, "corona", 6, 0, 221, 255, 100)
gravityjump5 = createMarker(1, 2, 3, "corona", 6, 0, 221, 255, 100)


addEventHandler ( "onClientMarkerHit", getRootElement(), MainFunction )
end


addEventHandler( "onClientResourceStart", getResourceRootElement(getThisResource()), Main )


function MainFunction ( hitPlayer, matchingDimension )
vehicle = getPedOccupiedVehicle ( hitPlayer )
if hitPlayer ~= Me then return end
	if source == gravityjump1 then
		speedx, speedy, speedz = getElementVelocity ( vehicle ) 
		setElementVelocity(vehicle, 0, -1, 0.5)
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
    song = playSound("http://vita.gamers-board.com/serverfiles/race/exxoticcfttobes.mp3",true)
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