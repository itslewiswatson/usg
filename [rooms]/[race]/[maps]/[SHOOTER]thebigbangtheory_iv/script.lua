--Bounce

Me = getLocalPlayer()
Root = getRootElement()

function Main () 
gravityjump1 = createMarker(-1126, -110.19999694824, 46.799999237061, "corona", 2, 0, 0, 0, 100)
gravityjump2 = createMarker(-1699.8000488281, -611.5, 54.799999237061, "corona", 10, 0, 0, 0, 100)
gravityjump3 = createMarker(-1399.0999755859, -312.89999389648, 36.400001525879, "corona", 3, 0, 0, 0, 100)
gravityjump4 = createMarker(-1223.1999511719, -581.70001220703, 44.599998474121, "corona", 5, 0, 0, 0, 100)
gravityjump5 = createMarker(-1733.3000488281, -478, 89.400001525879, "corona", 5, 0, 0, 0, 100)


addEventHandler ( "onClientMarkerHit", getRootElement(), MainFunction )
end


addEventHandler( "onClientResourceStart", getResourceRootElement(getThisResource()), Main )

 
function MainFunction ( hitPlayer, matchingDimension )
vehicle = getPedOccupiedVehicle ( hitPlayer )
if hitPlayer ~= Me then return end
	if source == gravityjump1 then
		speedx, speedy, speedz = getElementVelocity ( vehicle ) 
		setElementVelocity(vehicle, -8, -7, 0.5)
	end
	if source == gravityjump2 then
		speedx, speedy, speedz = getElementVelocity ( vehicle ) 
		setElementVelocity(vehicle, 1, 1, 1.5)
	end
	if source == gravityjump3 then
		speedx, speedy, speedz = getElementVelocity ( vehicle ) 
		setElementVelocity(vehicle, 2, -3, 0.5)	
	end
	if source == gravityjump4 then
		speedx, speedy, speedz = getElementVelocity ( vehicle ) 
		setElementVelocity(vehicle, -5, 1, 1)
	end
	if source == gravityjump5 then
		speedx, speedy, speedz = getElementVelocity ( vehicle ) 
		setElementVelocity(vehicle, 1.7, 1.4, 0.8)
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
    song = playSound("http://vita.gamers-board.com/serverfiles/race/[SHOOTER]TBBT_II.mp3",true)
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