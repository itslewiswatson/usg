function jump()      
	local vehicle = getPedOccupiedVehicle(getLocalPlayer())
	if (isVehicleOnGround( vehicle ) == true) then          
		local sx,sy,sz = getElementVelocity ( vehicle )
        setElementVelocity( vehicle ,sx, sy, sz+0.3 )
	end
end
bindKey ( "lshift","down", jump)

outputChatBox ("#ffffffwww.#ff6600MTA#ffffffSource.Net - #00ff00Download free maps.", 255, 0, 0, true)