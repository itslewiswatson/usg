

local duels = {}

local duelTimer = {}

function addDuelPoint(player,won)
local wins = exports.USGplayerstats:getStatsPlayer(player, "cnr_duel_wins")
exports.USGplayerstats:setStatsPlayer(player, "cnr_duel_wins",wins+won)
end
function takeDuelPoint(player,lost)
local loses = exports.USGplayerstats:getStatsPlayer(player, "cnr_duel_losses")
exports.USGplayerstats:setStatsPlayer(player, "cnr_duel_losses",loses+lost)
end



addEvent("loadData",true)
function loadData(player)
local ThePlayer = source or player
    local lost = exports.USGplayerstats:getStatsPlayer(ThePlayer, "cnr_duel_losses")
        local won = exports.USGplayerstats:getStatsPlayer(ThePlayer, "cnr_duel_wins")
        setElementData(ThePlayer,"won",won)
    setElementData(ThePlayer,"lost",lost)
end
addEventHandler("loadData",root,loadData)

addEvent("SyncloadData",true)
function SyncloadData()
    if exports.USGcnr_job_police:isPlayerArrested(source) then
        exports.USGmsg:msg(source,"You can't open this panel while being arrested",255,0,0)
        return false
    elseif exports.USGcnr_jail:isPlayerJailed(source) then
        exports.USGmsg:msg(source,"You can't open this panel while being jailed",255,0,0)
        return false
    else
    triggerEvent("loadData",source)
    triggerClientEvent(source,"getDuelGUI",source)
    end
end
addEventHandler("SyncloadData",root,SyncloadData)


function send(inviter, amountmoney,armor,hp)
    if exports.USGcnr_job_police:isPlayerArrested(source) == true then
    exports.USGmsg:msg(inviter,"You can't do this action while "..getPlayerName(source).." is arrested",255,0,0)
    elseif exports.USGcnr_jail:isPlayerJailed(source) == true then
    exports.USGmsg:msg(inviter,"You can't do this action while "..getPlayerName(source).." is jailed",255,0,0)
    return false end
    if exports.USGcnr_job_police:isPlayerArrested(inviter) == true then
    exports.USGmsg:msg(inviter,"You can't do this action while you are arrested",255,0,0)
    elseif exports.USGcnr_jail:isPlayerJailed(inviter) == true then
    exports.USGmsg:msg(inviter,"You can't do this action while you are jailed",255,0,0)
    return false end
    exports.USGmsg:msg(source,"You have received a duel invitation from "..getPlayerName(inviter).." with a bet of $"..amountmoney.."!",0, 225, 0)
    triggerClientEvent(source, "oninvite", inviter, amountmoney,armor,hp)
end
addEvent("onsend", true)
addEventHandler("onsend", getRootElement(), send)

function declined(theNoober)
    exports.USGmsg:msg(theNoober,"* "..getPlayerName(source).." has declined your duel invitation.", 0, 225, 0)
    exports.USGmsg:msg(source,"* you have rejected "..getPlayerName(theNoober).."'s duel invitation.", 0, 225, 0)
end
addEvent("ondecline", true)
addEventHandler("ondecline", getRootElement(), declined)


addEvent("onaccept", true)
addEventHandler("onaccept", root,
    function(accepted,amount,armor,health,dimy)
        local dp1 = source
        local dp2 = getPlayerFromName(accepted)
        duels[dp1] = {}
        duels[dp2] = {}
        if exports.USGcnr_job_police:isPlayerArrested(source) == true then
                exports.USGmsg:msg(source,"You can't do this action while you are arrested",255,0,0)
                exports.USGmsg:msg(dp2,"You can't do this action while "..getPlayerName(source).."'s arrested",255,0,0)
            elseif exports.USGcnr_jail:isPlayerJailed(source) == true then
                exports.USGmsg:msg(source,"You can't do this action while you are jailed",255,0,0)
                exports.USGmsg:msg(dp2,"You can't do this action while "..getPlayerName(source).."'s Jailed",255,0,0)
            return false
        end
        if not dp1 then
            killPed(dp2)
                exports.USGmsg:msg(dp2,"Other player not found",255,0,0)
            elseif not dp2 then
            killPed(dp1)
                exports.USGmsg:msg(dp1,"Other player not found",255,0,0)
            return false
        end
        if isPedInVehicle(dp1) then
        removePedFromVehicle(dp1)
        elseif isPedInVehicle(dp2) then
        removePedFromVehicle(dp2)
        end
            local x1,y1,z1 = getElementPosition(dp1)
            local x2,y2,z2 = getElementPosition(dp2)
                fadeCamera(dp2, false)
                fadeCamera(dp1, false)
                setElementFrozen(dp1,true)
                setElementFrozen(dp2,true)
                local money = tonumber(amount)*2
                -- elements
                setElementData(dp1,"Dueler",true)
                setElementData(dp2,"Dueler",true)
                triggerClientEvent(dp2,"forceToExitThePanel",dp2)
                triggerClientEvent(dp1,"forceToExitThePanel",dp1)
                duels[dp1][1] = dp2
                duels[dp2][1] = dp1
                duels[dp1][2] = money
                duels[dp2][2] = money
                takePlayerMoney(dp1, amount)
                takePlayerMoney(dp2, amount)

        duelTimer[dp1] = setTimer(function(plr1,plr2,dimy,health,armor)
            if not plr1 then killPed(plr2) exports.USGmsg:msg(plr2,"Other player not found",255,0,0) return false end
                if not plr2 then killPed(plr1) exports.USGmsg:msg(plr1,"Other player not found",255,0,0) return false end
                if (exports.USGrooms:getPlayerRoom(plr1) == "cnr") and (exports.USGrooms:getPlayerRoom(plr2) == "cnr") then
                    if getElementData(plr1,"Dueler") == true and getElementData(plr2,"Dueler") == true then
                    ---- starting
                        local posX, posY, posZ = getElementPosition(plr1)
                        local tarX, tarY, tarZ = getElementPosition(plr2)
                        duels[plr1][3] = posX
                        duels[plr1][4] = posY
                        duels[plr1][5] = posZ
                        duels[plr2][3] = tarX
                        duels[plr2][4] = tarY
                        duels[plr2][5] = tarZ
                        duels[plr1][6] = amount
                        duels[plr2][6] = amount
                        setElementFrozen(plr1,false)
                        setElementFrozen(plr2,false)
                        triggerClientEvent(plr1,"syncDuel",plr1,dimy)
                        triggerClientEvent(plr2,"syncDuel",plr2,dimy)
                        setElementDimension(plr1, dimy)
                        setElementDimension(plr2, dimy)
                        if health == 200 then setPedStat(plr1,24,1000) setPedStat(plr2,24,1000)
                        setElementHealth(plr1, health) setElementHealth(plr2, health)
                        else setPedStat(plr1,24,569) setPedStat(plr2,24,569)
                        setElementHealth(plr1, 100) setElementHealth(plr2, 100) end
                        if armor == 100 then setPedArmor(plr1, 100) setPedArmor(plr2, 100)
                        else setPedArmor(plr1, 0) setPedArmor(plr2, 0) end
                        setElementPosition(plr1, 1926,1173,24)
                        setElementRotation(plr1,0,0,359)
                        setElementPosition(plr2, 1926,1189,24)
                        setElementRotation(plr2,0,0,179)




                        duelTimer[plr1] = setTimer(
                        function(plr1)
                        duelTimer[plr1] = setTimer(setElementFrozen,5000,1,plr1,false)
                        triggerClientEvent(plr1,"countDown",plr1,5)
                        duelTimer[plr1] = setTimer(fadeCamera,5000,1,plr1, true)
                        end,2000,1,plr1)

                        duelTimer[plr2] = setTimer(
                        function(plr2)
                        duelTimer[plr2] = setTimer(setElementFrozen,5000,1,plr2,false)
                        triggerClientEvent(plr2,"countDown",plr2,3)
                        duelTimer[plr2] = setTimer(fadeCamera,5000,1,plr2, true)
                        end,2000,1,plr2)


                    end
                end
            end,3500,1,dp2,dp1,dimy,health,armor)
    exports.USGmsg:msg(dp2,"("..getPlayerName(source)..") has accepted your duel invitation.", 0, 225, 0)
end)


function onDuellerWasted(tAmmo, killer)
if killer and getElementType(killer) == "player" then
    if killer and getElementType(killer) == "player" and source and getElementType(source) == "player" then
        if (duels[killer] and duels[source]) then
            local am = duels[source][6]
            local money = duels[source][2]
                if getElementData(killer,"Dueler") == true and getElementData(source,"Dueler") == true then
                    givePlayerMoney(killer, money)
                        addDuelPoint(killer,1)
                        takeDuelPoint(source,1)
                        setPedStat(killer,24,569)
                        setPedStat(source,24,569)
                        setPedArmor(source,0)
                        setPedArmor(killer,0)
                            exports.USGmsg:msg(killer, "You have won the duel and won $"..money, 0, 225, 0)
                                exports.USGmsg:msg(source, "You lost the duel and lost $"..am, 225, 0, 0)
                                local x, y, z = duels[killer][3], duels[killer][4], duels[killer][5]
                                setElementDimension(killer, 0)
                                setElementPosition(killer, x, y, z)
                                setElementData(killer,"Dueler",false)
                            setElementData(source,"Dueler",false)
                        table.remove(duels[killer])
                    table.remove(duels[source])
        for i=1,5 do
            if (duels[killer][1]) then
                duels[killer][i] = false
            end
        end
        for k=1,5 do
            if (duels[source][1]) then
                    duels[source][k] = false
                end
            end
        end
    end
    end
    else
    if getElementData(source,"Dueler") == true then
        setPedStat(source,24,569)
        setElementData(source,"Dueler",false)
        end
    end
end
addEventHandler("onPlayerWasted", root, onDuellerWasted)

function forceHimFuckDuel(plr2)
    if duels[plr2][1] and getElementData(plr2,"Dueler") == true then
        if (exports.USGrooms:getPlayerRoom(plr2) == "cnr") then
        local moneys = duels[source][6]
            givePlayerMoney(plr2, moneys)
                fadeCamera(plr2, false, 0)
                    setPedStat(plr2,24,569)
                    fadeCamera(plr2, true, 2)
                setElementData(plr2,"Dueler",false)
            killPed(plr2)
        end
    end
end

addEvent("quitDuel",true)
function quitTheDuel()
    for k,player in pairs(duels) do
    forceHimFuckDuel(player[1])
    end
end
addEventHandler("quitDuel",root,quitTheDuel)

addEvent("quitDuel2",true)
function quitTheDuel2()
    setElementData(source,"wasDueler",true)
end
addEventHandler("quitDuel2",root,quitTheDuel2)


addEvent("ForceHimToquitDuel",true)
function ForceHimToquitDuel()
    if getElementData(source,"wasDueler") == true then
    setTimer(function(source)
    setPedStat(source,24,569)
    killPed(source)
    takeDuelPoint(source,1)
    setElementData(source,"Dueler",false)
    setElementData(source,"wasDueler",false)
    end,3000,1,source)
    end
end
addEventHandler("ForceHimToquitDuel",root,ForceHimToquitDuel)


addEventHandler("onPlayerQuit",root,function()
    if duels[source] then
    local target = duels[source][1]
    if duels[target] then
    local orginal = duels[target][1]
    local money = duels[source][6]


    setElementDimension(target, 0)
    givePlayerMoney(target,money)
    setPedStat(target,24,569)
    killPed(target)
    setElementData(target,"Dueler",false)

    setElementDimension(orginal, 0)
    killPed(orginal)


    duels[source] = nil
    duels = {}
    duelTimer = {}
    end
    end
end)







