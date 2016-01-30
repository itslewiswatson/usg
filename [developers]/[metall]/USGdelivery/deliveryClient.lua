-- Object ID: 1271 & 3798

function testObjects()
	local px, py, pz = getElementPosition(localPlayer)
	createObject(1271, px, py, pz)
end
addCommandHandler("testobj", testObjects)