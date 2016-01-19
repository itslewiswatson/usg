loadstring(exports.MySQL:getQueryTool())()

local playerStats = {}

addEvent("onServerPlayerLogin")
function loadPlayerStats(player)
    singleQuery(onAccountStatsCallback,{player},"SELECT * FROM accountstats WHERE username=?",exports.USGaccounts:getPlayerAccount(player))
end
addEventHandler("onServerPlayerLogin", root, function () loadPlayerStats(source) end)

function onAccountStatsCallback(result, player)
    if(not isElement(player)) then return false end
    if(not result) then
        local username = exports.USGaccounts:getPlayerAccount(player)
        if(username) then
            insert(onStatsInserted, {player}, "INSERT INTO accountstats ( username ) VALUES ( ? )",username)
        end
        return
    end
    result.username = nil
    playerStats[player] = result
end

function onStatsInserted(id, player)
    if(id and isElement(player)) then
        loadPlayerStats(player)
    end
end

addEventHandler("onResourceStart", resourceRoot,
    function ()
        for i, player in ipairs(getElementsByType("player")) do
            if(exports.USGaccounts:isPlayerLoggedIn(player)) then
                loadPlayerStats(player)
            end
        end
    end
)

addEventHandler("onPlayerQuit", root,
    function ()
        playerStats[source] = nil
    end
)

function getStatsPlayer(player, stat)
    if(player and playerStats[player]) then
        return playerStats[player][stat]
    else
        return nil
    end
end

function setStatsPlayer(player, stat, value)
    if(player and playerStats[player]) then
        playerStats[player][stat] = value
        local account = exports.USGaccounts:getPlayerAccount(player)
        exports.MySQL:execute("UPDATE accountstats SET ??=? WHERE username=?",stat,value,account)
        return true
    else
        return false
    end
end

function incrementPlayerStat(player, stat, value)
    if(player and playerStats[player] and type(value) == "number") then
        setStatsPlayer(player, stat, (type(playerStats[player][stat]) == "number" and playerStats[player][stat] or 0) + value)
        return true
    else
        return false
    end
end

-- gui interaction
addEvent("USGplayerstats.request", true)
addEventHandler("USGplayerstats.request", root,
    function ()
        local stats = playerStats[source]
        --[[if(stats.cnr_deaths ~= 0) then
            stats.cnr_killdeathratio = stats.cnr_kills/stats.cnr_deaths
        else
            stats.cnr_killdeathratio = "N/A"
        end]]
        triggerClientEvent(client, "USGplayerstats.receive",source,stats)
    end
)