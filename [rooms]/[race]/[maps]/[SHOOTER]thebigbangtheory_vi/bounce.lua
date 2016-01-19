--Bounce

Me = getLocalPlayer()
Root = getRootElement()

function Main () 
gravityjump1 = createMarker(4928.1000976563, -1655.9000244141, 4.4000000953674, "corona", 2, 0, 0, 0, 100)
gravityjump2 = createMarker(4806.5, -1655.1999511719, 4.4000000953674, "corona", 2, 0, 0, 0, 100)
gravityjump3 = createMarker(4927, -1534.5, 4.4000000953674, "corona", 2, 0, 0, 0, 100)
gravityjump4 = createMarker(4806.7001953125, -1534.0999755859, 4.4000000953674, "corona", 2, 0, 0, 0, 100)
gravityjump5 = createMarker(0, 0, 0, "corona", 0, 0, 0, 0, 100)


addEventHandler ( "onClientMarkerHit", getRootElement(), MainFunction )
end


addEventHandler( "onClientResourceStart", getResourceRootElement(getThisResource()), Main )

 
function MainFunction ( hitPlayer, matchingDimension )
vehicle = getPedOccupiedVehicle ( hitPlayer )
if hitPlayer ~= Me then return end
	if source == gravityjump1 then
		speedx, speedy, speedz = getElementVelocity ( vehicle ) 
		setElementVelocity(vehicle, -1, 1, 1)
	end
	if source == gravityjump2 then
		speedx, speedy, speedz = getElementVelocity ( vehicle ) 
		setElementVelocity(vehicle, 1, 1, 1)
	end
	if source == gravityjump3 then
		speedx, speedy, speedz = getElementVelocity ( vehicle ) 
		setElementVelocity(vehicle, -1, -1, 1)	
	end
	if source == gravityjump4 then
		speedx, speedy, speedz = getElementVelocity ( vehicle ) 
		setElementVelocity(vehicle, 1, -1, 1)
	end
	if source == gravityjump5 then
		speedx, speedy, speedz = getElementVelocity ( vehicle ) 
		setElementVelocity(vehicle, 0, 0, 0)
	end
end
--Wether

setCloudsEnabled ( false )