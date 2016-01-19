addCommandHandler("drivetype",function(player,cmd,theType)
	if(isPedInVehicle ( player ))then
		local vehicle = getPedOccupiedVehicle(player)
		if(theType == "awd" or theType == "fwd" or theType == "rwd")then
		setVehicleHandling ( vehicle, "driveType", theType )
		exports.USGmsg:msg(player, "Your vehicle drive type has been set to "..theType, 0, 255, 0)
		else exports.USGmsg:msg(player, "Syntax: /drivetype <fwd/awd/rwd> ", 0, 255, 0)
		end
	end
end)