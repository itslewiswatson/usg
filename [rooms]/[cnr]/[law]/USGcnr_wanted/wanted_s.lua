playerWanted = {}

local killZone = createColRectangle(866,480,2300,2800)

addEvent("onPlayerJoinCNR", true)
function onPlayerJoinCNR(data)
    setPlayerWantedLevel(source, math.max(0,tonumber(data.wantedlvl) or 0))
end
addEventHandler("onPlayerJoinCNR", root, onPlayerJoinCNR)

addEventHandler("onResourceStart", resourceRoot,
    function ()
        for i, player in ipairs(getElementsByType("player")) do
            if(exports.USGrooms:getPlayerRoom(player) == "cnr") then
                if(not getElementData(player, "wantedLevel")) then
                    local data = exports.USGcnr_room:getPlayerAccountData(player) or {}
                    setPlayerWantedLevel(player, math.max(0,tonumber(data.wantedlvl) or getElementData(player, "wantedLevel") or 0))
                else
                    setPlayerWantedLevel(player, getElementData(player, "wantedLevel"))
                end
            end
        end
    end
)

addEvent("onPlayerPostExitRoom", true)
function onPlayerExitRoom(room)
    playerWanted[source] = nil
    removeElementData(source, "wantedLevel")
end
addEventHandler("onPlayerPostExitRoom", root, onPlayerExitRoom)

addEvent("onPlayerBecomeWanted", true)
function givePlayerWantedLevel(player, amount)
    if(not isElement(player) or not playerWanted[player]) then
        error("'player' is not an element or not in the CnR room.")
    end
    if(type(amount) == "number" and math.floor(amount) > 0) then
        if(not playerWanted[player] or playerWanted[player] == 0) then
            triggerEvent("onPlayerBecomeWanted", player)
        end
        playerWanted[player] = playerWanted[player] and playerWanted[player]+math.floor(amount) or math.floor(amount)
        setPlayerNametagText(player, getPlayerName(player).."["..playerWanted[player].."]")
        setElementData(player, "wantedLevel", playerWanted[player])
    else
        error("Invalid amount, NaN or below zero. [ "..tostring(amount).."]")
    end
end

function setPlayerWantedLevel(player, amount)
    if(not isElement(player) or exports.USGrooms:getPlayerRoom(player) ~= "cnr") then
        error("'player' is not an element or not in the CnR room.")
    end
    if(type(amount) == "number" and math.floor(amount) >= 0) then
        if(amount > 0 and (not playerWanted[player] or playerWanted[player] == 0)) then
            triggerEvent("onPlayerBecomeWanted", player)
        end 
        playerWanted[player] = math.floor(amount)
        setPlayerNametagText(player, getPlayerName(player).."["..playerWanted[player].."]")
        setElementData(player, "wantedLevel", playerWanted[player])
    else
        error("Invalid amount, NaN or below zero. [ "..tostring(amount).."]")
    end
end

function getPlayerWantedLevel(player)
    if(not isElement(player)) then
        error("'player' is not an element or not in the CnR room.")
    end
    return playerWanted[player] or getElementData(player, "wantedLevel") or 0
end

local KILL_WLVL = 6
local ATTACK_WLVL = 2
local CARJACK_WLVL = 2

-- manage events to get players wanted
addEventHandler("onVehicleEnter", root,
    function (player, seat, jacked)
        if(exports.USGrooms:getPlayerRoom(player) ~= "cnr") then return end
        if(jacked) then
		local jackedCity = exports.USG:getPlayerChatZone(player)
            if(exports.USGcnr_jobs:getPlayerJobType(player) ~= "police" and exports.USGcnr_jobs:getPlayerJobType(player) ~= "staff") and ( jackedCity ~= "LV" ) then
                givePlayerWantedLevel(player, CARJACK_WLVL)
            end
        end
    end
)

addEventHandler("onPlayerWasted", root,
    function (totalAmmo, killer, weapon, bodypart, stealth)
        if(exports.USGrooms:getPlayerRoom(source) ~= "cnr") then return end
        --if( exports.USGcnr_jobs:getPlayerJobType(source) == "staff") then return false end
        if(isElement(killer) and killer ~= source) then
            if(getElementType(killer) == "vehicle") then
                killer = getVehicleController(killer)
                if(not killer) then return end
            end
			if ( exports.USGcnr_jobs:getPlayerJobType(killer) ~= "staff")then
				local killCity = exports.USG:getPlayerChatZone(source)
				local kWLVL = getPlayerWantedLevel(killer)
				local vWLVL = getPlayerWantedLevel(source)
				local kJobType = exports.USGcnr_jobs:getPlayerJobType(killer)
				local vJobType = exports.USGcnr_jobs:getPlayerJobType(source)
				if(kJobType == "police") then
					if(vWLVL == 0) and ( killCity ~= "LV" ) then
					outputChatBox(tostring(vWLVL))
					outputChatBox(tostring(killCity ~= "LV"))
						exports.USGcnr_jobs:setPlayerJob(killer, false)
						givePlayerWantedLevel(killer, KILL_WLVL)
					end
					elseif not ( isElementWithinColShape( source, killZone ) ) or ( isElementWithinColShape( source, killZone ) ) and ( killCity ~= "LV" ) then
					givePlayerWantedLevel(killer, KILL_WLVL)
				end
			end
        end
    end
)

addEventHandler("onPlayerDamage", root,
    function (attacker, weapon, bodypart, loss)
        if(exports.USGrooms:getPlayerRoom(source) ~= "cnr") then return end
       --if() then return flase end
        if(isElement(attacker) and attacker ~= source) then
            if(getElementType(attacker) == "vehicle") then
                attacker = getVehicleController(attacker)
                if(not attacker) then return end
            end
			if( exports.USGcnr_jobs:getPlayerJobType(attacker) ~= "staff" )then
				local attackCity = exports.USG:getPlayerChatZone(source)
				local kWLVL = getPlayerWantedLevel(attacker)
				local vWLVL = getPlayerWantedLevel(source)
				local kJobType = exports.USGcnr_jobs:getPlayerJobType(attacker)
				local vJobType = exports.USGcnr_jobs:getPlayerJobType(source)
				if(kJobType == "police") then
					if(vWLVL == 0) and ( attackCity ~= "LV" ) then
						exports.USGcnr_jobs:setPlayerJob(attacker, false)
						givePlayerWantedLevel(attacker, ATTACK_WLVL)
					end
					elseif not ( isElementWithinColShape( source, killZone ) ) or ( isElementWithinColShape( source, killZone ) ) and ( attackCity ~= "LV" ) then
					givePlayerWantedLevel(attacker, ATTACK_WLVL)
				end
			end
        end
    end
)