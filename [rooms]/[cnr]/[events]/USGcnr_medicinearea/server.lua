local Left,Botom = 1073.2685546875, -2098.5332031
local Right, Top = 1383.7783203125, -1980.4570312
local Width = Right - Left
local Height = Top - Botom
local area = createRadarArea(Left,Botom,Width,Height,1,2,3,180)
local rewardMedicine ,rewardScore = 5,0.5

function killed(totalAmmo, killer, killerWeapon, bodypart, stealth)
    if isElement(killer) and getElementType(killer) == "player" then
    local sx,sy = getElementPosition(source)
    local kx,ky = getElementPosition(killer)
        if( isInsideRadarArea(area,sx,sy) and isInsideRadarArea(area,kx,ky)) then
            if (exports.USGcnr_jobs:getPlayerJob(killer) == "criminal") and (exports.USGcnr_jobs:getPlayerJob(source) == "police") then
            exports.USGmsg:msg(killer, "You have Killed "..getPlayerName(source).." and you have earned "..rewardMedicine.." from each medicines and "..rewardScore .." score.", 255, 0,0)
            exports.USGcnr_medicines:givePlayerMedicines(killer,"Aspirin",rewardMedicine)
            exports.USGcnr_medicines:givePlayerMedicines(killer,"Steroid",rewardMedicine)
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
    if(isElement(cop) and exports.USGrooms:getPlayerRoom(cop) == "cnr") then
        local reward = math.random(wlvl * 100, wlvl * 105)
        exports.USGmsg:msg(cop, "You have jailed "..getPlayerName(criminal).." and earned "..exports.USG:formatMoney(reward).." and "..rewardMedicine.." from each medicines. ", 0, 255,0)
        exports.USGcnr_medicines:givePlayerMedicines(cop,"Aspirin",rewardMedicine)
        exports.USGcnr_medicines:givePlayerMedicines(cop,"Steroid",rewardMedicine)
        exports.USGplayerstats:incrementPlayerStat(cop, "cnr_arrests", 1)
         givePlayerMoney(cop, reward)
        exports.USGcnr_score:givePlayerScore(cop, rewardScore)
    end
    exports.USGmsg:msg(criminal, "You have been jailed ".. (isElement(cop) and ("by "..getPlayerName(cop)) or "")..".", 255, 128,0)
end