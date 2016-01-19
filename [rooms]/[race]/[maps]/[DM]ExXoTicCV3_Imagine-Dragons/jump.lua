--Bounce

Me = getLocalPlayer()
Root = getRootElement()

function Main () 
gravityjump1 = createMarker(4803, -7290.6000976563, 1.2000000476837, "corona", 3, 0, 0, 0, 100)
gravityjump2 = createMarker(4773.5, -8131.7001953125, 31.200000762939, "corona", 3, 0, 0, 0, 100)
gravityjump3 = createMarker(4773.6000976563, -8129.7001953125, 394.39999389648, "corona", 2, 0, 0, 0, 100)
gravityjump4 = createMarker(0, 0, 0, "corona", 6, 0, 221, 255, 100)
gravityjump5 = createMarker(0, 0, 0, "corona", 6, 0, 221, 255, 100)


addEventHandler ( "onClientMarkerHit", getRootElement(), MainFunction )
end


addEventHandler( "onClientResourceStart", getResourceRootElement(getThisResource()), Main )


function MainFunction ( hitPlayer, matchingDimension )
vehicle = getPedOccupiedVehicle ( hitPlayer )
if hitPlayer ~= Me then return end
	if source == gravityjump1 then
		speedx, speedy, speedz = getElementVelocity ( vehicle ) 
		setElementVelocity(vehicle, 0, -2, 2)
	end
	if source == gravityjump2 then
		speedx, speedy, speedz = getElementVelocity ( vehicle ) 
		setElementVelocity(vehicle, 0, 0, 3)
	end
	if source == gravityjump3 then
		speedx, speedy, speedz = getElementVelocity ( vehicle ) 
		setElementVelocity(vehicle, -0.3, 0, 0)	
	end
	if source == gravityjump4 then
		speedx, speedy, speedz = getElementVelocity ( vehicle ) 
		setElementVelocity(vehicle, 0, 0, 2.5)
	end
	if source == gravityjump5 then
		speedx, speedy, speedz = getElementVelocity ( vehicle ) 
		setElementVelocity(vehicle, 0, -0.3, 0.4)
	end
end
addEventHandler( "onClientResourceStart", getResourceRootElement(getThisResource()), replace )