local Left,Botom = 2177.2421875, -1374.0888671875
local Right, Top = 2827.75,-1060.1064453125
local Width = Right - Left
local Height = Top - Botom
local area = createRadarArea(Left,Botom,Width,Height,1,2,3,180)
local rewardMoney ,rewardScore = 1000,0.5

function killed(totalAmmo, killer, killerWeapon, bodypart, stealth)
    if isElement(killer) and getElementType(killer) == "player" then
    local sx,sy = getElementPosition(source)
    local kx,ky = getElementPosition(killer)
        if( isInsideRadarArea(area,sx,sy) and isInsideRadarArea(area,kx,ky)) then
            if (exports.USGcnr_jobs:getPlayerJob(killer) == "criminal") and (exports.USGcnr_jobs:getPlayerJob(source) == "police") then
            exports.USGmsg:msg(killer, "You have Killed "..getPlayerName(source).." and you have earned "..rewardMoney.."$ and "..rewardScore .." score.", 255, 0,0)
            givePlayerMoney(killer,rewardMoney )
            exports.USGcnr_score:givePlayerScore(killer, rewardScore )
            elseif (exports.USGcnr_jobs:getPlayerJob(source) == "criminal") and (exports.USGcnr_jobs:getPlayerJob(killer) == "police" and exports.USGcnr_wanted:getPlayerWantedLevel(source) > 0) then
            killArrestPlayer(source,killer,"LS")
            end
        end
    end
end
addEventHandler ( "onPlayerWasted", getRootElement(), killed)

function killArrestPlayer(criminal, cop, jail)
local wlvl = exports.USGcnr_wanted:getPlayerWantedLevel(criminal)
        exports.USGcnr_jail:jailPlayer(criminal, wlvl*3, jail, getPlayerName(cop))
exports.USGcnr_wanted:setPlayerWantedLevel(criminal, 0)
    if(isElement(cop) and exports.USGrooms:getPlayerRoom(cop) == "cnr") then
        local reward = math.random(wlvl * 100, wlvl * 105)
        exports.USGmsg:msg(cop, "You have jailed "..getPlayerName(criminal).." and earned "..exports.USG:formatMoney(reward)..".", 0, 255,0)
        givePlayerMoney(cop, reward)
        exports.USGplayerstats:incrementPlayerStat(cop, "cnr_arrests", 1)
        exports.USGcnr_score:givePlayerScore(cop, rewardScore)
    end
    exports.USGmsg:msg(criminal, "You have been jailed ".. (isElement(cop) and ("by "..getPlayerName(cop)) or "")..".", 255, 128,0)
end