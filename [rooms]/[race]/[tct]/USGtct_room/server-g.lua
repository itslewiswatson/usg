STATE_ACTIVE = 1
STATE_FINISHED = 2
STATE_LOADING = 3
STATE_WAITING = 4

addEvent("USGrace_maps.onMapLoaded", true)

local state = STATE_WAITING
local players
local isAlive = {}
local rank
local map
local spectators = {}
local IGplayer = {}
local updatePlayersTimer
local loadMapTimeoutTimer
local gameStartTick
local kills = {}

local function messageTCT(message,r,g,b)
	for k, player in ipairs(getElementsByType("player")) do
		if (exports.USGrooms:getPlayerRoom(player) == "tct") then
			exports.USGmsg:msg(player, message, r,g,b)
		end
	end
end

function spawnPlayerTCT(player)
    spawnPlayer(player, 0, 0, 3)
    setElementAlpha(player, 255)
    setElementDimension(player, exports.USGrooms:getRoomDimension("tct"))
end

function loadGame()
    if(state ~= STATE_FINISHED and state ~= STATE_WAITING) then return false end
    players = exports.USGrooms:getPlayersInRoom("tct")
    if(#players == 0) then
        state = STATE_WAITING
        return
    end
    state = STATE_LOADING
    map = exports.USGrace_maps:getRandomMap("tct")
    local title = exports.USGrace_maps:getMapTitle(map)
    local author = exports.USGrace_maps:getMapAuthor(map)
    local team = "Red Team"
    for i,player in ipairs(players) do
        setElementData(player,"Team",team)
        if(team == "Red Team")then
            team = "Blue Team"
            setPlayerNametagColor ( player ,255,0,0 )
        else team = "Red Team"
            setPlayerNametagColor ( player ,0,0,255)
        end
        isAlive[player] = false
        spawnPlayerTCT(player)
        addEventHandler("USGrace_maps.onMapLoaded", player, onClientMapLoaded)
        outputChatBox("[TCT] Loading map "..(title or "unnamed").." by "..(author or "unknown"), player, 10,170,250)
    end 
    playerMapLoaded = {}
    exports.USGrace_maps:startMap(map, players)
    loadMapTimeoutTimer = setTimer(loadMapTimeout, 45000, 1)
end

local playerMapLoaded = {}

function loadMapTimeout()
    if(#players > 1) then -- if only 1 player, let him load
        for i, player in ipairs(players) do
            if(not playerMapLoaded[player]) then
                if(exports.USGrooms:getPlayerRoom(player) == "tct") then
                    exports.USGrooms:removePlayerFromRoom(player)
                end
            end
        end
        if(#players > 0) then
            prepareGame()
        else
            state = STATE_WAITING
        end
    else
        state = STATE_WAITING
    end
end

function onClientMapLoaded()
    playerMapLoaded[client] = true
	removeEventHandler("USGrace_maps.onMapLoaded", client, onClientMapLoaded)
    local loading = false
    for i, player in ipairs(players) do
        if(not playerMapLoaded[player]) then
            loading = true
            break
        end
    end
    if(not loading) then
        prepareGame()
    end
end

function prepareGame()
    playerMapLoaded = {}
    if(isTimer(loadMapTimeoutTimer)) then killTimer(loadMapTimeoutTimer) end
    state = STATE_ACTIVE
    local spawns = exports.USGrace_maps:getMapSpawns(map)
    local i1, i2 = 1, 1
    local PlayersInRoom = {}
    players = exports.USGrooms:getPlayersInRoom("tct")
    for _, player in ipairs(players) do
        local team = getElementData(player,"Team") == "Red Team" and "team1" or "team2"
        local spawn
        if(team == "team1") then
            spawn = spawns.team1[i1]
            i1 = i1 + 1
            if(not spawns[i1]) then i1 = 1 end -- go back to first spawn
        else
            spawn = spawns.team2[i2]
            i2 = i2 + 1 
            if(not spawns[i2]) then i2 = 1 end -- go back to first spawn
        end
        local skinID = 0
        spawnPlayer(player, spawn.x, spawn.y, spawn.z, spawn.rz, skinID, spawn.int, 400)
		kills[player] = 0
        if(getElementData(player,"Team") == "Red Team")then
        setElementModel(player,285)
        else
        setElementModel(player,287)
        end
        giveWeapon ( player, 31, 100 ) 
        giveWeapon ( player, 27, 100 ) 
        giveWeapon ( player, 24, 100 ) 
        giveWeapon ( player, 33, 100 ) 
        setElementFrozen(player, true)
        table.insert(PlayersInRoom, player)
        setCameraTarget(player)
        fadeCamera(player, true, 1)
    end
    triggerClientEvent(players, "USGtct_room.prepareRound", resourceRoot, players)
    setTimer(startGame, 4000, 1)
end

function startGame()
    players = exports.USGrooms:getPlayersInRoom("tct")
    for i, player in ipairs(players) do
            setElementFrozen(player, false)
            isAlive[player] = true
        
    end
    rank = #players+1
    updatePlayersTimer = setTimer(updatePlayers, 500, 0)
    gameStartTick = getTickCount()  
end

function setRoundWinner()
	local mostKillsPlayer
	local mostKills = 0
    local winner
    local playersInT1 = getPlayersInTeam1()
    local playersInT2 = getPlayersInTeam2()
    if(#playersInT1 == 0)then
    winner = "Blue Team"
    elseif(#playersInT2 == 0)then
    winner = "Red Team"
    end
    if(winner) then
        for i, player in ipairs(players) do
            if(isElement(player) and exports.USGrooms:getPlayerRoom(player) == "tct") then
                triggerClientEvent(player, "USGtct.announceWinner", player,winner)
				if(kills[player])then
					if(kills[player] > mostKills)then
					mostKills = kills[player]
					mostKillsPlayer = getPlayerName(player)
					end
				end
            end
        end
		messageTCT(mostKillsPlayer.." got the most kills this round. ("..tostring(mostKills).." kills)",255,255,255)
    end
    stopGame(winner)
end

function stopGame(winner)
    if(isTimer(updatePlayersTimer))then
    killTimer(updatePlayersTimer)
    end
    state = STATE_FINISHED
    setTimer(endGame, 5000, 1)
end

function endGame()
    for i,player in ipairs(players) do
        if(exports.USGrooms:getPlayerRoom(player) == "tct") then
            fadeCamera(player, false)
            triggerClientEvent(player, "USGtct.roundEnd", player)
        end
    end
    setTimer(cleanGame, 1000, 1)
end

function cleanGame()
    for player, vehicle in pairs(IGplayer) do
            if(isElement(player)) then
                destroyElement(player)
            end
    end
    IGplayer = {}     
    setTimer(loadGame, 500, 1)
end

function getPlayersInTeam1()
local team = {}
    for k,player in ipairs(players)do
        if(isAlive[player] and getElementData(player,"Team") == "Red Team")then
        table.insert(team,player)
        end
    end
    return team
end

function getPlayersInTeam2()
local team = {}
    for k,player in ipairs(players)do
        if(isAlive[player] and getElementData(player,"Team") == "Blue Team")then
        table.insert(team,player)
        end
    end
    return team
end

function onPlayerWasted(player)
    if(not isAlive[player] or state ~= STATE_ACTIVE) then return end
    local index
    for i, pPlayer in ipairs(players) do
        if(player == pPlayer and isAlive[pPlayer]) then -- he was actually participating
            isAlive[player] = false
            local playersInT1 = getPlayersInTeam1()
            local playersInT2 = getPlayersInTeam2()
            if(#playersInT1 > 0  and #playersInT2 > 0 )then
                startSpectate(player)
                spawnPlayerTCT(player)
            end
            if(#playersInT1 == 0 or #playersInT2 == 0)then
                setRoundWinner()
            end
        end
    end
    if(index and gameStartTick) then -- valid death
        local secondsSinceStart = math.floor((getTickCount()-gameStartTick)/1000)
        local deathTime = string.format("%02i:%02i", secondsSinceStart/60, secondsSinceStart%60)
        for i, pPlayer in ipairs(players) do
            if(isElement(pPlayer) and exports.USGrooms:getPlayerRoom(pPlayer) == "tct") then
                triggerClientEvent(pPlayer, "USGtct_room.playerWasted", player, rank, deathTime, exports.USG:getPlayerColoredName(player))
            end
        end
    end 
    if(index and state == STATE_ACTIVE) then -- find people who are spectating, if they were spectating the person who died, go to the next
        for player, i in pairs(spectators) do
            if(i == index and exports.USGrooms:getPlayerRoom(player) == "tct") then
                nextSpectateTarget(player)
            end
        end
    end
end

addEventHandler("onPlayerWasted", root, 
    function (totalAmmo,killer) 
        if(exports.USGrooms:getPlayerRoom(source) == "tct") then
            onPlayerWasted(source)
        end
		if(exports.USGrooms:getPlayerRoom(source) == "tct" and exports.USGrooms:getPlayerRoom(killer) == "tct") then
			if(getElementData(source,"Team") ~= getElementData(killer,"Team"))then
			kills[killer] = kills[killer] + 1
			end
		end
    end
)

function updatePlayers()
    for i, player in ipairs(players) do
        if(isAlive[player]) then
            if(isElementInWater(player)) then
                onPlayerWasted(player)
            end
        end
    end
end

function onPlayerChooseTeam(player)
    local state = getGameState()
    if(state == STATE_WAITING) then
        loadGame()
    elseif(state == STATE_FINISHED or state == STATE_ACTIVE) then
        if(state == STATE_ACTIVE and #players == 1) then
            stopGame()
        else
            fadeCamera(player, true)
            exports.USGrace_maps:startMap(map, {player})
            startSpectate(player)
        end
    end
end

function onPlayerExitGame(player)
    spectators[player] = nil
    onPlayerWasted(player)
    fadeCamera(player, false)
end

addEventHandler("onPlayerQuit", root, 
    function ()
        if(isAlive[source]) then
            onPlayerWasted(source)
        end
        spectators[source] = nil
        isAlive[source] = nil
    end
)

function getGameState()
    return state
end

-- spectating

function startSpectate(player)
    local found = false
    for i, pPlayer in ipairs(players) do
        if(isAlive[pPlayer]) then
            setSpectateTarget(player, pPlayer, i)
            found = true
            return true
        end
    end
    if(not found) then
        triggerClientEvent(player, "USGrace_common.freezeCamera", player)
    end
end

function setSpectateTarget(player, target, i)
    if(exports.USGrooms:getPlayerRoom(player) ~= "tct") then return false end
    local interior = getElementInterior(target)
    setCameraInterior(player,interior)
    setCameraTarget(player, target)
    spectators[player] = i
	if(not isAlive[target] or exports.USGrooms:getPlayerRoom(target)~= "tct") then
	startSpectate(player)
	end
end

function nextSpectateTarget(player)
    if(isAlive[player]) then return end
    local old = spectators[player]
    if(not old) then return false end
    if(#players > 1) then
        local i = old
        local passedStart = false
        while true do
            i = i + 1
            if(i > #players) then
                if(not passedStart) then
                    i = 1
                    passedStart = true
                else
                    return false
                end
            end
            if(isAlive[players[i]]) then
                setSpectateTarget(player, players[i], i)
                break
            end
        end
        return true
    else
        return false
    end
end

function previousSpectateTarget(player)
    if(isAlive[player]) then return end
    local old = spectators[player]
    if(not old) then return false end
    if(#players > 1) then
        local i = old
        local passedZero = false
        while true do
            i = i - 1
            if(i <= 0) then
                if(not passedZero) then
                    i = #players
                    passedZero = true
                else
                    return false
                end
            end
            if(isAlive[players[i]]) then
                setSpectateTarget(player, players[i], i)
                break
            end
        end
        return true
    else
        return false
    end
end

------------------

