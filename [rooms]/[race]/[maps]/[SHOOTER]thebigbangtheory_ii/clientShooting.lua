-- This script is created by MegaDreams for [FUN] *FreakZer ft. MegaDreams - The Big Bang Theory II, Don't even think about stealing it.

local shootingAllowed = true

function playerSpawn()
	shootingAllowed = true
end
addEventHandler("onClientPlayerSpawn", getLocalPlayer(), playerSpawn)

function doShoot()
	if shootingAllowed == true then
		if not isPlayerDead(getLocalPlayer()) then
			shootingAllowed = false
			local theVehicle = getPedOccupiedVehicle(getLocalPlayer())
			local x,y,z = getElementPosition(theVehicle)
			local rX,rY,rZ = getVehicleRotation(theVehicle)
			local x = x+4*math.cos(math.rad(rZ+90))
			local y = y+4*math.sin(math.rad(rZ+90))
			createProjectile(theVehicle, 19, x, y, z, 1.0, nil)
			setTimer(allowShooting, 3000, 1)
		end
	end
end

function allowShooting()
	shootingAllowed = true
end

for keyName, state in pairs(getBoundKeys("fire")) do
	bindKey(keyName, "down", doShoot)
end