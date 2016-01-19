Me = getLocalPlayer()
Root = getRootElement()
local screenWidth, screenHeight = guiGetScreenSize() -- Get the screen resolution

function Main () 
used = 0
gravityjump2 = createMarker(7725.9033203125, -2082.71484375, 17.239999771118, "corona", 10, 0, 0, 0, 0)


addEventHandler ( "onClientMarkerHit", getRootElement(), MainFunction )
end


addEventHandler( "onClientResourceStart", getResourceRootElement(getThisResource()), Main )


function MainFunction ( hitPlayer, matchingDimension )
vehicle = getPedOccupiedVehicle ( hitPlayer )
if hitPlayer ~= Me then return end
	if source == gravityjump2 then
			setElementVelocity(vehicle, 0, -4, 6)
	end

end

function ClientStarted ()
setWaterColor( 0 , 125 , 255 ) -- RGB colors
setSkyGradient( 83 , 134 , 139 , 93 , 104 , 205 ) -- 1st RGB colors top sky, 2nd RGB colors bottom sky
end 


addEventHandler( "onClientResourceStart", getResourceRootElement(getThisResource()), ClientStarted )

function SpawnJump()
    local veh = getPedOccupiedVehicle(getLocalPlayer())
	local x,y,z = getElementPosition(veh)	
		if y >= -930.70001220703 and used == 0 then
				speedx, speedy, speedz = getElementVelocity ( vehicle ) 
				speedcnx = (speedx)
				speedcny = (speedy)
				speedcnz = (speedz)
				setElementVelocity ( vehicle, speedcnx, speedcny,-0.3 )
				used = 1
	else
    if z <=46 then
    if x >= 3948.1999511719 and x <= 4018.8000488281  then 
	if y >= -1181.0999755859 and y <= -1100.0999755859  then
	setElementVelocity(veh, -0.07, 1.4, 1.2)
end
end
end
end
end

addEventHandler("onClientRender",getRootElement(),SpawnJump)

 