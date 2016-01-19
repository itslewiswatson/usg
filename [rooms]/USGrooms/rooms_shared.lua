rooms = {
    cnr = {text="Cops N Robbers", name="cnr", dimension = 0 }, 
    dd = {text="Destruction Derby", name="dd", dimension = 100 }, 
    dm = {text="Deathmatch", name="dm", dimension = 200 }, 
    str = {text="Shooter", name="str", dimension = 300 }, 
    tct = {text="Tactics", name="tct", dimension = 400 }, 
}

roomsList = {}
for room, _ in pairs(rooms) do
    table.insert(roomsList, room)
end
-- each room gets 100 dimension, rooms[i].dimension <-> rooms[i].dimension+99

function getRoomName(room)
    if(not rooms[room]) then return false end
    return rooms[room].text
end

function getRoomDimension(room)
    if(not rooms[room]) then return false end
    return rooms[room].dimension
end

function getRooms()
    return roomsList
end

function getPlayersInRoom(room)
    local players = {}
    for k,player in ipairs(getElementsByType("player")) do
        if (getPlayerRoom(player) == room) then
            table.insert(players, player)
        end
    end
    return players
end
