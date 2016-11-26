fileDelete("account_shared_exports")
addEvent("onServerPlayerLogin", true)

function isPlayerLoggedIn(player)
    local thePlayer = player or localPlayer
    if (isElement(thePlayer)) then
        return getPlayerAccount(player) ~= false
    else
        return false
    end
end

function getPlayerAccount(player)
    local thePlayer = player or localPlayer
    if (isElement(thePlayer)) then
        local name = getElementData(thePlayer,"account")
        return name or false
    else
        return false
    end
end

function getPlayerFromAccount(account)
    if(type(account) ~= "string") then return false end
    for _, player in ipairs(getElementsByType("player")) do
        if(account == getPlayerAccount(player)) then return player end
    end
end

function getLoggedInPlayers()
    local players = {}
    for i, player in ipairs(getElementsByType("player")) do
        if(isPlayerLoggedIn(player)) then
            table.insert(players, player)
        end
    end
    return players
end