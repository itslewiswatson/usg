function jump()      
	local vehicle = getPedOccupiedVehicle(getLocalPlayer())
	if (isVehicleOnGround( vehicle ) == true) then          
		local sx,sy,sz = getElementVelocity ( vehicle )
        setElementVelocity( vehicle ,sx, sy, sz+0.25 )
	end
end
bindKey ( "lshift","down", jump)