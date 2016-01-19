function getPlayerWantedLevel(player)
    local thePlayer = player ~= nil and player or localPlayer
    if(not isElement(thePlayer) or not exports.USGrooms:getPlayerRoom(thePlayer) == "cnr") then
        error("Not a player, syntax: getPlayerWantedLevel(player) | getPlayerWantedLevel() ")
    end
    return getElementData(thePlayer, "wantedLevel")
end