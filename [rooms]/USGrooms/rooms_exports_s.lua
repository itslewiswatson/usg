function getPlayerRoom(player)
	if(not isElement(player) or getElementType(player) ~= "player") then return false end
	local room = playerRooms[player] ~= nil and playerRooms[player] or getElementData(player, "room")
	return room
end

function getPlayerRoomFriendly(player)
	if(not isElement(player) or getElementType(player) ~= "player") then return false end
	local room = playerRooms[player] or getElementData(player, "room")
	if(room and rooms[room]) then return rooms[room].text end
	return false
end