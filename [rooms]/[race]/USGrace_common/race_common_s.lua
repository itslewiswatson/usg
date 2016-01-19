local raceRooms = {
    dd = true, dm = true, str = true, tct=true
}
local defaultAccount = { money = 5000 }
loadstring(exports.MySQL:getQueryTool())()

local playerAccounts = {}

function isPlayerInRaceRoom(player)
    local room = exports.USGrooms:getPlayerRoom(player)
    return room and raceRooms[room]
end

addEvent("onPlayerJoinRoom")
function onPlayerJoinRoom(room)
    if(not raceRooms[room]) then -- only clean up if player joins a room that isnt a race room ( majority is race, so caching is smarter )
        playerAccounts[source] = nil
    end
    if(raceRooms[room]) then -- load if race room and cache isnt available
        if(not playerAccounts[source]) then
            loadPlayerAccount(source)
        else
            applyPlayerAccount(source)
        end
    end
end
addEventHandler("onPlayerJoinRoom", root, onPlayerJoinRoom)

addEvent("onPlayerExitRoom")
function onPlayerExitRoom(room)
    if(playerAccounts[source]) then
        savePlayerAccount(source)
    end
end
addEventHandler("onPlayerExitRoom", root, onPlayerExitRoom)

addEventHandler("onPlayerQuit", root, 
    function ()
        if(isPlayerInRaceRoom(source)) then
            savePlayerAccount(source)
        end
        playerAccounts[source] = nil
    end
)

function applyPlayerAccount(player)
    if(isElement(player) and isPlayerInRaceRoom(player) and playerAccounts[player]) then
        setPlayerMoney(player, playerAccounts[player].money)
        outputDebugString("applying "..playerAccounts[player].money)
    end
end

function savePlayerAccount(player)
    if(isElement(player)) then
        local account = exports.USGaccounts:getPlayerAccount(player)
        local money = getPlayerMoney(player)
        playerAccounts[player].money = money
        exports.MySQL:execute("UPDATE race__accounts SET money=? WHERE username=?",money,account)
    end
end

function loadPlayerAccount(player, applyAccount)
    if(isElement(player)) then
        local account = exports.USGaccounts:getPlayerAccount(player)
        if(account) then
            singleQuery(loadPlayerAccountCallback, {player, applyAccount}, "SELECT * FROM race__accounts WHERE username=?", account)
            singleQuery(requestAccountMoneyCallback,{player},"SELECT money FROM race__accounts WHERE username=?",account)
        end
    end
end

function requestAccountMoneyCallback(result, player)
    if(result) then
        setPlayerMoney(player, result.money, true)
    end
end

function loadPlayerAccountCallback(account, player, applyAccount)
    if(isElement(player) and isPlayerInRaceRoom(player)) then
        if(account) then
            account.username = nil
            playerAccounts[player] = account
        else
            createPlayerAccount(player)
        end
        if(applyAccount) then
            applyPlayerAccount(player)
        end
    end
end

addEventHandler("onResourceStart", resourceRoot,
    function ()
        for i, player in ipairs(getElementsByType("player")) do
            if(exports.USGaccounts:isPlayerLoggedIn(player) and isPlayerInRaceRoom(player)) then
                loadPlayerAccount(player)
            end
        end
    end
)

addEventHandler("onResourceStop", resourceRoot,
    function ()
        for player, account in pairs(playerAccounts) do
            if(exports.USGaccounts:isPlayerLoggedIn(player) and isPlayerInRaceRoom(player)) then
                savePlayerAccount(player)
            end
        end
    end
)

function createPlayerAccount(player)
    if(isElement(player) and isPlayerInRaceRoom(player)) then
        local pAccount = {}
        for k, v in pairs(defaultAccount) do
            pAccount[k] = v
        end
        playerAccounts[player] = pAccount
        exports.MySQL:execute("INSERT INTO race__accounts (username) VALUES ( ? )",exports.USGaccounts:getPlayerAccount(player))
        singleQuery(requestAccountMoneyCallback,{player},"SELECT money FROM cnr__accounts WHERE username=?",username)
        showPlayerHudComponent(player,"money", true)
    end
end

-- events