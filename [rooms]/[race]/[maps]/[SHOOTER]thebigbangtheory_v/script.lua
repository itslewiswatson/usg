--Bounce

Me = getLocalPlayer()
Root = getRootElement()

function Main () 
gravityjump1 = createMarker(4117.8999023438, -1361.6999511719, 1.2000000476837, "corona", 2, 0, 0, 0, 100)
gravityjump2 = createMarker(4202.1000976563, -1894.5, 1.2000000476837, "corona", 2, 0, 0, 0, 100)
gravityjump3 = createMarker(4426.2001953125, -1585.5999755859, 1.2000000476837, "corona", 2, 0, 0, 0, 100)
gravityjump4 = createMarker(3893.6000976563, -1670.1999511719, 1.2000000476837, "corona", 2, 0, 0, 0, 100)
gravityjump5 = createMarker(0, 0, 0, "corona", 5, 0, 0, 0, 100)


addEventHandler ( "onClientMarkerHit", getRootElement(), MainFunction )
end


addEventHandler( "onClientResourceStart", getResourceRootElement(getThisResource()), Main )

 
function MainFunction ( hitPlayer, matchingDimension )
vehicle = getPedOccupiedVehicle ( hitPlayer )
if hitPlayer ~= Me then return end
	if source == gravityjump1 then
		speedx, speedy, speedz = getElementVelocity ( vehicle ) 
		setElementVelocity(vehicle, 0.48, -3, 1)
	end
	if source == gravityjump2 then
		speedx, speedy, speedz = getElementVelocity ( vehicle ) 
		setElementVelocity(vehicle, -0.48, 3, 1)
	end
	if source == gravityjump3 then
		speedx, speedy, speedz = getElementVelocity ( vehicle ) 
		setElementVelocity(vehicle, -3, -0.48, 1)	
	end
	if source == gravityjump4 then
		speedx, speedy, speedz = getElementVelocity ( vehicle ) 
		setElementVelocity(vehicle, 3, 0.48, 1)
	end
	if source == gravityjump5 then
		speedx, speedy, speedz = getElementVelocity ( vehicle ) 
		setElementVelocity(vehicle, speedx+0, speedy+0, speedz+0)
	end
end

--Replace

function replace ()
txd = engineLoadTXD("vgnbasktball.txd")
engineImportTXD(txd, 6959 ) 
end
addEventHandler( "onClientResourceStart", getResourceRootElement(getThisResource()), replace )

--Wether

setCloudsEnabled ( false )

--Music

function startMusic()
    setRadioChannel(0)
    song = playSound("[SHOOTER]thebigbangtheory___v.mp3",true)
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
bindKey("z","down","music")