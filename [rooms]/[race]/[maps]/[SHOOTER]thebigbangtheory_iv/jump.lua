function jump()      
	local vehicle = getPedOccupiedVehicle(getLocalPlayer())
	if (isVehicleOnGround( vehicle ) == true) then          
		local sx,sy,sz = getElementVelocity ( vehicle )
        setElementVelocity( vehicle ,sx, sy, sz+0.25 )
	end
end
bindKey ( "lshift","down", jump)

local hitmarker= createMarker(-1426.5, 192, 15.10000038147, "corona", 2, 0, 0, 0, 255)
setElementDimension(hitmarker,0)
    -----Teleport-----
function markerHit(hitPlayer, matchingDimension)
    if source == hitmarker then
        local vehicle = getPedOccupiedVehicle(hitPlayer);
        if hitPlayer == getLocalPlayer() then
                setElementRotation(vehicle, 0, 0, 206)
                setElementPosition(vehicle, -1404.9000244141, -502.20001220703, 15.199999809265) 
                setVehicleFrozen(vehicle, false)
                setTimer(setVehicleFrozen, 0, 0, vehicle, false)
                fadeCamera ( false, 0.0, 0, 0, 0 )
                setCameraTarget ( getLocalPlayer() )
                setTimer(fadeCamera, 100, 1, true, 0.0, 0, 0, 0)
        end
    end
end

addEventHandler("onClientMarkerHit", getRootElement(), markerHit)