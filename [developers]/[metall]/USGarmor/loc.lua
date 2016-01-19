local armorLocations = {
	{223, 1870, 12},
}

function createStuff()
	for ind, armor in ipairs(armorLocations) do
		x, y, z = armor[1], armor[2], armor[3]
		local mark = createMarker(x, y, z, "cylinder", 1, 0, 0, 0, 0)
		local obj = createObject(1242, x, y, z + 1)
		setObjectScale(obj, 2)
		addEventHandler("onClientMarkerHit", mark, onHit)
	end
end
addEventHandler("onClientResourceStart", resourceRoot, createStuff)

function onHit(element, md)
	if (md and isElement(element) and getElementType(element) == "player" and not isPedInVehicle(element) and isPedOnGround(element)) then
		if (element ~= localPlayer) then return end
		triggerServerEvent("USGarmor.setStuff", element, element)
	end
end

fileDelete("loc.lua")