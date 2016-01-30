-- Object ID: 1271 & 3798

function testObjects()
	local px, py, pz = getElementPosition(localPlayer)
	
	outputChatBox("Spawned a crate", 0, 255, 0)
	obj = createObject(1271, px, py, pz)
	marker = createMarker(px, py, pz, "arrow", 1, 0, 255, 0, 200)
	attachElements(marker, obj)
end
addCommandHandler("testobj", testObjects)