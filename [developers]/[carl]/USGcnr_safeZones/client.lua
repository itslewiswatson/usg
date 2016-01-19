-- Individual col shapes for each location
local colShapeLV = createColCuboid ( 1577.6962890625, 1723.3515625, 8 , 60,140,50)
local colShapeLSJefferson = createColCuboid ( 1996.8935546875, -1450.9189453125, 10 , 105,50,50)
local colShapeLSAS = createColCuboid ( 1149.6982421875, -1385.3076171875, 10 , 40,95,50)
local colShapeSF = createColCuboid ( -2711.849609375, 580.8662109375, 10, 100,95,50)
local jail = createColCuboid ( -2423.078125, 1718.220703125, -5, 225, 200, 200 )

local fireKeys = getBoundKeys("fire") -- Get bound keys for firing
local safeZones = {colShapeLV, colShapeLSJefferson, colShapeLSAS, colShapeSF, jail} -- Put all the locations in a table for ease of checking

function isElementWithinSafeZone(element)
	if (not element or not isElement(element)) then return end
	if (element.interior ~= 0 or element.dimension ~= 0) then return false end
	for _, z in ipairs(safeZones) do
		if (isElementWithinColShape(element, z)) then
			return true
		end
	end
	return false
end

function zoneEntry(element, matchingDimension)
	if (element ~= localPlayer or not matchingDimension) then return end
	if (element.dimension ~= 0 or element.interior ~= 0) then return end
	-- Give police their nightstick
	if (localPlayer.team.name == "Police") then
		setPedWeaponSlot(localPlayer, 1)
		return
	end
end
for _, z in ipairs(safeZones) do
	addEventHandler("onClientColShapeHit", z, zoneEntry)
end

function cancelDmg()
	if (isElementWithinSafeZone(localPlayer)) then
		if (localPlayer:getWantedLevel() > 0) then return end
		cancelEvent()
	end
end
addEventHandler("onClientPlayerDamage", root, cancelDmg)

function fireCheck(button, state)
	if (localPlayer.vehicle) then return end
	if (fireKeys[button] and state == true) then
		if (isElementWithinSafeZone(localPlayer)) then
			if (localPlayer:getWeapon() == 3) then
				toggleControl("fire", true)
			else
				toggleControl("fire", false)
			end
		end
	end
	if (fireKeys[button] and state == false) then
		if (not isElementWithinSafeZone(localPlayer) and not localPlayer.frozen) then
			toggleControl("fire", true)
		end
	end
end
addEventHandler("onClientKey", root, fireCheck)
