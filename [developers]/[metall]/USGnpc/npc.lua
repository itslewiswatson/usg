local drinkPeds = {
	-- FORMAT: x, y, z, rot, dim, int, skin
	{-223.3017578125, 1403.8896484375, 27.7734375, 89.927215576172, 0, 18, 0},
}

function makePeds()
	for ind, peds in ipairs(drinkPeds) do
		ped = createPed(peds[7], peds[1], peds[2], peds[3], peds[4])
		mark = createMarker(-224.7802734375, 1403.8984375, 28.7734375, "cylinder", 0.5, 0, 255, 255, 200)
		setElementInterior(ped, 18)
		setElementFrozen(ped, true)
		--addPedClothes(ped, "head", "hairpink", 5)
		addEventHandler("onClientPedDamage", ped, onDamage)
		addEventHandler("onClientMarkerHit", mark, onHit)
	end
end
addEventHandler("onClientResourceStart", resourceRoot, makePeds)

function onHit(element, matchingDim)
	if (element ~= localPlayer) then return end
	if (not matchingDim) then return end
	if (getElementHealth(element) >= 99) then return end
	exports.USGmsg:msg("You've bought a Cookie", 0, 255, 255)
	setElementHealth(element, getElementHealth(element) + 10)
end

function onDamage()
	cancelEvent()
end