local policeBans = {}
local policeChiefs = {}
loadstring(exports.MySQL:getQueryTool())()

function loadPoliceChiefs()
    query(loadPoliceChiefsCallback, {}, "SELECT * FROM cnr__police_chiefs")
end
addEventHandler("onResourceStart", resourceRoot, loadPoliceChiefs)

function loadPoliceChiefsCallback(result)
    if(result) then
        for i, row in ipairs(result) do
            policeChiefs[row.username] = row.level
        end
        for i, player in ipairs(getElementsByType("player")) do
            if(exports.USGrooms:getPlayerRoom(player) == "cnr" and isPlayerPoliceChief(player)) then
                triggerClientEvent(player, "USGcnr_pchief.onPoliceChiefConnect", player, policeChiefs)
            end
        end        
    end
end

addEventHandler("onPlayerJoinRoom", root,
    function (room)
        if(room == "cnr") then
            local account = exports.USGaccounts:getPlayerAccount(source)
            if(policeChiefs[account]) then
                triggerClientEvent(source, "USGcnr_pchief.onPoliceChiefConnect", source, policeChiefs)
            end
        end
    end
)

function updateClientChiefList(account)
    for i, player in ipairs(getElementsByType("player")) do
        if(exports.USGrooms:getPlayerRoom(player) == "cnr" and isPlayerPoliceChief(player)) then
            triggerClientEvent(player, "USGcnr_pchief.updatePoliceChiefList", player, account, policeChiefs[account])
        end
    end
end

function addPoliceChief(account)
    if(type(account) ~= "string") then error("account invalid") end
    if(not policeChiefs[account]) then
        policeChiefs[account] = 1
        updateClientChiefList(account)
        return exports.MySQL:execute("INSERT INTO cnr__police_chiefs ( username ) VALUES ( ? )", account)
    end
    return false
end

function removePoliceChief(account)
    if(type(account) ~= "string") then error("account invalid") end
    if(policeChiefs[account]) then
        policeChiefs[account] = nil
        updateClientChiefList(account)
        return exports.MySQL:execute("DELETE FROM cnr__police_chiefs WHERE username=?", account)
    end
    return false
end

function setPoliceChiefLevel(account, level)
    if(policeChiefs[account]) then
        policeChiefs[account] = level
        updateClientChiefList(account)
        return exports.MySQL:execute("UPDATE cnr__police_chiefs SET level=? WHERE username=?", level, account)
    end
    return false
end

function isPlayerPoliceChief(player)
    local account = exports.USGaccounts:getPlayerAccount(player)
    if(account and policeChiefs[account]) then
        return policeChiefs[account] ~= nil
    end
    return false
end

function getPoliceChiefLevel(player)
    local account = exports.USGaccounts:getPlayerAccount(player)
    if(account and policeChiefs[account]) then
        return policeChiefs[account]
    else
        return false
    end
end

-- events

addEvent("USGcnr_pchief.requestBanList", true)
addEventHandler("USGcnr_pchief.requestBanList", root, 
    function ()
        if(isPlayerPoliceChief(client)) then
            triggerClientEvent(client, "USGcnr_pchief.receiveBanList", client, policeBans)
        end
    end
)

addEvent("USGcnr_pchief.kickCop", true)
function onPlayerKickFromCopJob()
    if(not isPlayerPoliceChief(client)) then return end
    if(exports.USGcnr_jobs:getPlayerJob(source) == "police") then
        exports.USGcnr_jobs:setPlayerJob(source, false)
        exports.USGmsg:msg(source,"You have been kicked from the police job by "..getPlayerName(client).."!", 255, 0, 0)
        exports.USGmsg:msg(client,"You have kicked "..getPlayerName(source).." from the police job!", 0, 255, 0)
    else 
        exports.USGmsg:msg(client, getPlayerName(source).." is not a cop!", 255, 0, 0)
    end
end
addEventHandler("USGcnr_pchief.kickCop", root, onPlayerKickFromCopJob)

addEvent("USGcnr_pchief.banCop", true)
function onPlayerBanFromCopJob(time)
    if(not isPlayerPoliceChief(client)) then return end
    if(exports.USGcnr_jobs:getPlayerJob(source) == "police") then exports.USGcnr_jobs:setPlayerJob(source,false) end
    exports.USGmsg:msg(source,"You have been banned from the police job ("..getPlayerName(client)..")("..time.." minutes)", 255, 0, 0)
    exports.USGmsg:msg(client,"You have banned "..getPlayerName(source).." from the police job for "..time.." minutes.", 0, 255, 0)
    local accountName = exports.USGaccounts:getPlayerAccount(source) 
    banFromCopJob(accountName, time)
end
addEventHandler("USGcnr_pchief.banCop", root, onPlayerBanFromCopJob)

addEvent("USGcnr_pchief.warnCop", true)
function onPlayerWarnCop(message)
    if(not isPlayerPoliceChief(client)) then return end
    outputChatBox("You have been warned by police chief"..getPlayerName(client)..":", source, 255, 128, 0)
    outputChatBox(message, source, 255, 0, 0)
    exports.USGmsg:msg(client,"You have warned "..getPlayerName(source)..".", 0, 255, 0)
end
addEventHandler("USGcnr_pchief.warnCop", root, onPlayerWarnCop)

addEvent("USGcnr_pchief.unbanCop", true)
function onPlayerUnbanFromCopJob()
    if(not isPlayerPoliceChief(client)) then return end
    exports.USGmsg:msg(source,"You have been unbanned from the police job.", 0, 255, 0)
    local accountName = exports.USGaccounts:getPlayerAccount(source)
    unbanFromCopJob(accountName)
end
addEventHandler("USGcnr_pchief.unbanCop", root, onPlayerUnbanFromCopJob)

addEvent("USGcnr_pchief.giveCop", true)
function onPlayerGiveCopJob()
    if(not isPlayerPoliceChief(client)) then return end
    if(exports.USGcnr_wanted:getPlayerWantedLevel(source) == 0) then
        exports.USGcnr_jobs:setPlayerJob(source,"police",280)
        exports.USGmsg:msg(source,"You have been given the police job by "..getPlayerName(client)..".", 0, 255, 0)
        exports.USGmsg:msg(client,"You gave "..getPlayerName(source).." the police job!", 0, 255, 0)
    else 
        exports.USGmsg:msg(client,getPlayerName(source).." is wanted!", 255, 0, 0)
    end
end
addEventHandler("USGcnr_pchief.giveCop", root, onPlayerGiveCopJob)

addEvent("USGcnr_pchief.promotePchief", true)
function onPlayerPromotePchief()
    if(not isPlayerPoliceChief(client) or client == source) then return end
    if(not isPlayerPoliceChief(source)) then
        addPoliceChief(exports.USGaccounts:getPlayerAccount(source))
        exports.USGmsg:msg(source,"You have been added as a Police Chief.", 0, 255, 0)
        exports.USGmsg:msg(client,"You have added "..getPlayerName(source).." as a Police Chief.", 0, 255, 0)
    elseif(getPoliceChiefLevel(client) > getPoliceChiefLevel(source)+1) then
        local newLevel = getPoliceChiefLevel(source)+1
        setPoliceChiefLevel(exports.USGaccounts:getPlayerAccount(source), newLevel)
        exports.USGmsg:msg(source,"You have been promoted to Police Chief L"..newLevel..".", 0, 255, 0)
        exports.USGmsg:msg(client,"You have promoted "..getPlayerName(source).." to Police Chief L"..newLevel..".", 0, 255, 0)
    else
        exports.USGmsg:msg(client, "You can't promote this chief anymore!", 255, 0, 0)
    end
end
addEventHandler("USGcnr_pchief.promotePchief", root, onPlayerPromotePchief)

addEvent("USGcnr_pchief.demotePchief", true)
function onPlayerDemotePchief()
    if(not isPlayerPoliceChief(client) or client == source) then return end
    if(isPlayerPoliceChief(source)) then
        local level = getPoliceChiefLevel(source)
        if(level == 1) then
            triggerClientEvent(source, "USGcnr_pchief.onPoliceChiefKicked", source)
            removePoliceChief(exports.USGaccounts:getPlayerAccount(source))
            exports.USGmsg:msg(source,"You have been kicked from Police Chief.", 255, 0, 0)
            exports.USGmsg:msg(client,"You have kicked "..getPlayerName(source).." from Police Chief.", 255, 0, 0)
        elseif(level < getPoliceChiefLevel(client)) then
            setPoliceChiefLevel(exports.USGaccounts:getPlayerAccount(source), level-1)
            exports.USGmsg:msg(source,"You have been demoted to Police Chief L"..(level-1)..".", 255, 0, 0)
            exports.USGmsg:msg(client,"You have demoted "..getPlayerName(source).." to Police Chief L"..(level-1)..".", 255, 0, 0)
        else
            exports.USGmsg:msg(client, "You can't demote this chief because he has a higher rank!", 255, 0, 0)            
        end
    else
        exports.USGmsg:msg(client, "This player is not a police chief.", 255, 0, 0)
    end
end
addEventHandler("USGcnr_pchief.demotePchief", root, onPlayerDemotePchief)

function isBannedFromPolice(player)
    local account = exports.USGaccounts:getPlayerAccount(player)
    if(account) then
        if(policeBans[account]) then
            local ban = policeBans[account]
            local timeLeft = getBanTimeLeft(player)
            if(timeLeft > 0) then
                return true
            else
                policeBans[account] = nil
                return false
            end
        end
    end
    return false
end

function getBanTimeLeft(player)
    local account = exports.USGaccounts:getPlayerAccount(player)
    if(account) then
        if(policeBans[account]) then
            local ban = policeBans[account]
            local timeLeft = math.floor((ban.duration-(getTickCount()-ban.start))/1000)
            return timeLeft
        end
    end
    return false
end

function checkifBanned(jobID, skinID)
    if (jobID == "police")then
        if(isBannedFromPolice(source)) then
            cancelEvent()
            local secondsLeft = getBanTimeLeft(source)
            local minutes = math.floor(secondsLeft/60)
            local seconds = secondsLeft%60
            local msg = string.format("You are banned from using the police job, time remaining: %02i:%02i", minutes, seconds)
            exports.USGmsg:msg(source, msg, 255, 0, 0)
        end
    end
end
addEventHandler("onPlayerAttemptChangeJob", root, checkifBanned)

function banFromCopJob(acc,mins)
    unbanFromCopJob(acc) -- remove any previous bans
    policeBans[acc] = {start = getTickCount(), duration = mins*1000*60}
end

function unbanFromCopJob(acc)
    policeBans[acc] = nil
    return true
end
