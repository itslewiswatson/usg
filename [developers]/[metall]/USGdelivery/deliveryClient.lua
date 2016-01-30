-- Object ID: 1271 & 3798

function testObjects(plr)
	local px, py, pz = getElementPosition(plr)
	testObj = createObject(1271, x, y, z)
end
addCommandHandler("testobj", testObjects)