------------------------------------------------------------------------------------
-- PROJECT: Towers Mania DD
-- VERSION: 1.0
-- DATE: June 2013
-- DEVELOPERS: JR10
-- RIGHTS: All rights reserved by developers
------------------------------------------------------------------------------------

local towers = {}
local currentTower
local currentMarker
local zappedTowers = 0

function getTowers()
	for index, object in pairs(getElementsByType("object")) do
		if (getElementModel(object) == 4585) then
			table.insert(towers, object)
		end
	end
	zapTimer = setTimer(zapTower, 30000, 1)
end
addEventHandler("onResourceStart", resourceRoot, getTowers)

function zapTower()
	currentTower = towers[math.random(#towers)]
	if (not isElement(currentTower)) then zapTimer = setTimer(zapTower, 1000, 1) return end
	local x, y, z = getElementPosition(currentTower)
	currentMarker = createMarker(x, y, z + 100, "checkpoint", 0.1, 255, 0, 0)
	zapTimer2 = setTimer(enlargeMarker, 50, 800)
	zappedTowers = zappedTowers + 1
	if (zappedTowers == #towers and isTimer(zapTimer)) then killTimer(zapTimer) end
end

function enlargeMarker()
	if (not isElement(currentMarker) and isTimer(zapTimer2)) then killTimer(zapTimer2) return end
	local size = getMarkerSize(currentMarker) + 0.1
	setMarkerSize(currentMarker, size)
	if (size >= 10) then
		local x, y, z = getElementPosition(currentTower)
		destroyElement(currentMarker)
		destroyElement(currentTower)
		createExplosion(x - 15, y, z + 100, 10)
		createExplosion(x, y, z + 100, 10)
		createExplosion(x + 15, y, z + 100, 10)
		triggerClientEvent("tower.playExplosionSound", root)
		zapTimer = setTimer(zapTower, 30000, 1)
		if (isTimer(zapTimer2)) then killTimer(zapTimer2) end
	end
end