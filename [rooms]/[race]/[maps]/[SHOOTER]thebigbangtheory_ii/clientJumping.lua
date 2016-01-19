-- This script is created by MegaDreams for [FUN] *FreakZer ft. MegaDreams - The Big Bang Theory II, Don't even think about stealing it.

function plrJump()
	local theVehicle = getPedOccupiedVehicle(getLocalPlayer())
	if isVehicleOnGround(theVehicle) and not isPlayerDead(getLocalPlayer()) then
		local vx,vy,vz = getElementVelocity(theVehicle)
		setElementVelocity(theVehicle,vx,vy,0.25)
	end
end

for keyName, state in pairs(getBoundKeys("jump")) do
	bindKey(keyName, "down", plrJump)
end