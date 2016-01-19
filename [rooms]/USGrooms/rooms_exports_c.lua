function getPlayerRoom(player)
	if(player and not isElement(player)) then
		error("Syntax is getPlayerRoom(player) or getPlayerRoom() for localPlayer!")
	end
	return getElementData(player or localPlayer,"room")
end

function getPlayerRoomFriendly(player)
	if(player and not isElement(player)) then
		error("Syntax is getPlayerRoomFriendly(player) or getPlayerRoomFriendly() for localPlayer!")
	end
	local room = getPlayerRoom(player or localPlayer)
	if(room) then return rooms[room].text end
	return false
end