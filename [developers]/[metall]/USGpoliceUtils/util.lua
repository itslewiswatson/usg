function getPointFrontOfElement(element, distance)
	local x, y, z = getElementPosition(element)
	local rx, ry, rz = getElementRotation(element)
	x = x + (distance * (math.sin(math.rad(-rz))))
	y = y + (distance * (math.cos(math.rad(-rz))))
	return x, y, z
end

function getPositionFromElementAtOffset(element, x, y, z)
	if (not x or not y or not z) then      
		return x, y, z   
	end
	
	local matrix = getElementMatrix(element)
	local offX = x * matrix[1][1] + y * matrix[2][1] + z * matrix[3][1] + matrix[4][1]
	local offY = x * matrix[1][2] + y * matrix[2][2] + z * matrix[3][2] + matrix[4][2]
	local offZ = x * matrix[1][3] + y * matrix[2][3] + z * matrix[3][3] + matrix[4][3]
	return offX, offY, offZ
end

function getVehicleWheelPosition(vehicle, wheel)
	local x, y, z = 0, 0, 0
	local minX, minY, minZ, maxX, maxY, maxZ = getElementBoundingBox(vehicle)
	if (wheel == 1) then
		x, y, z = getPositionFromElementAtOffset(vehicle, minX, maxY, minZ)
	elseif (wheel == 2) then
		x, y, z = getPositionFromElementAtOffset(vehicle, minX, -maxY, minZ)		
	elseif (wheel == 3) then
		x, y, z = getPositionFromElementAtOffset(vehicle, maxX, maxY, minZ)
	elseif (wheel == 4) then
		x, y, z = getPositionFromElementAtOffset(vehicle, maxX, -maxY, minZ)
	end	 
	return x, y, z
end

function placeStinger()
	if (isPedInVehicle(localPlayer)) then return end
	if (not isPedOnGround(localPlayer)) then return end
	if (isPedDead(localPlayer)) then return end
	if (exports.USGcnr_jobs:getPlayerJobType() == "police" or exports.USGcnr_jobs:getPlayerJobType() == "nationalguard") then
		local x, y, z = getPointFrontOfElement(localPlayer, 3)
		local rx, ry, rz = getElementRotation(localPlayer)
		z = getGroundPosition(x, y, z)
		triggerServerEvent("USGpoliceUtils.createStinger", localPlayer, x, y, z, rx, ry, rz)
	end
end
addCommandHandler("stinger", placeStinger)

function makeThemWork()
	if (isPedInVehicle(localPlayer)) and (exports.USGcnr_wanted:getPlayerWantedLevel(localPlayer) >= 1) then
		local vehicle = getPedOccupiedVehicle(localPlayer)
		if (vehicle) then
			local wx1, wy1, wz1 = getVehicleWheelPosition(vehicle, 1)
			local wx2, wy2, wz2 = getVehicleWheelPosition(vehicle, 2)
			local wx3, wy3, wz3 = getVehicleWheelPosition(vehicle, 3)
			local wx4, wy4, wz4 = getVehicleWheelPosition(vehicle, 4)
			
			for k, v in ipairs(getElementsByType("object")) do
				if (getElementData(v, "stinger") == true) then
					local vx, vy, vz = getElementPosition(v)
					if (getDistanceBetweenPoints2D(wx1, wy1, vx, vy) <= 1.4) then
						setVehicleWheelStates(vehicle, 1, -1, -1, -1)
					end
					if (getDistanceBetweenPoints2D(wx2, wy2, vx, vy) <= 1.4) then
						setVehicleWheelStates(vehicle, -1, 1, -1, -1)	
					end
					if (getDistanceBetweenPoints2D(wx3, wy3, vx, vy) <= 1.4) then
						setVehicleWheelStates(vehicle, -1, -1, 1, -1)	
					end
					if (getDistanceBetweenPoints2D(wx4, wy4, vx, vy) <= 1.4) then
						setVehicleWheelStates(vehicle, -1, -1, -1, 1)	
					end
				end
			end
		end
	end
end
addEventHandler("onClientRender", root, makeThemWork)