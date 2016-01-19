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
local updatePlayersTimer
local playerVehicles = {}
local gameStartTick

function spawnPlayerDD(player)
    spawnPlayer(player, 0, 0, 3)
    setElementAlpha(player,255)
    setElementDimension(player, exports.USGrooms:getRoomDimension("dd"))
end

function loadGame()
    if(state ~= STATE_FINISHED and state ~= STATE_WAITING) then return false end
    players = exports.USGrooms:getPlayersInRoom("dd")
    if(#players == 0) then
        state = STATE_WAITING
        return
    end
    state = STATE_LOADING   
    map = exports.USGrace_maps:getRandomMap("dd")
    local title = exports.USGrace_maps:getMapTitle(map)
    local author = exports.USGrace_maps:getMapAuthor(map)   
    for i,player in ipairs(players) do
        isAlive[player] = false
        outputChatBox("[DD] Loading map "..(title or "unnamed").." by "..(author or "unknown"), player, 10,170,250)
        spawnPlayerDD(player)
    end
    playerMapLoaded = {}
    exports.USGrace_maps:startMap(map, players)
    loadMapTimeoutTimer = setTimer(loadMapTimeout, 45000, 1)
end

local playerMapLoaded = {}

function loadMapTimeout()
    if(#players > 1) then
        for i, player in ipairs(players) do
            if(not playerMapLoaded[player]) then
                if(exports.USGrooms:getPlayerRoom(player) == "dd") then
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
    local i = 1
    players = exports.USGrooms:getPlayersInRoom("dd")
    local vehicles = {}
    for _, player in ipairs(players) do
        local spawn = spawns[i]
        removePlayerVehicle(player)
        local vehicle = createVehicle(spawn.model or 415, spawn.x, spawn.y, spawn.z, spawn.rx, spawn.ry, spawn.rz)
        playerVehicles[player] = vehicle
        setElementDimension(vehicle, getElementDimension(player))
        setElementPosition(player, spawn.x, spawn.y, spawn.z)
        warpPedIntoVehicle(player, vehicle)
        setElementFrozen(vehicle, true)
        table.insert(vehicles, vehicle)
        addEventHandler("onVehicleExplode", vehicle, function () onPlayerWasted(getVehicleController(source)) end)
        setCameraTarget(player)
        fadeCamera(player, true, 1)
        i = i + 1
        if(not spawns[i]) then i = 1 end -- go back to first spawn
    end
    triggerClientEvent(players, "USGdd_room.prepareRound", resourceRoot, vehicles)
    setTimer(startGame, 4000, 1)
end

function startGame()
    players = exports.USGrooms:getPlayersInRoom("dd")
    for i, player in ipairs(players) do
        local vehicle = getPedOccupiedVehicle(player)
        if(vehicle) then
            setElementFrozen(vehicle, false)
            isAlive[player] = true
        end
    end
    rank = #players+1
    updatePlayersTimer = setTimer(updatePlayers, 500, 0)
    setTimer(endSpawnProtection, 5000, 1)
    gameStartTick = getTickCount()
end

function endSpawnProtection()
    if(state == STATE_ACTIVE) then
        local vehicles = {}
        local igPlayers = {}
        for i, player in ipairs(players) do
            if(exports.USGrooms:getPlayerRoom(player) == "dd") then
                table.insert(igPlayers, player)
                local vehicle = getPedOccupiedVehicle(player)
                if(vehicle) then
                    table.insert(vehicles, vehicle)
                end
                outputChatBox("[DD] Spawn protection ended.", player, 10, 170, 250)
            end
        end
        triggerClientEvent(igPlayers, "USGdd_room.gameStopSpawnProtection", resourceRoot, vehicles)
    end
end

function stopGame(winner)
    killTimer(updatePlayersTimer)
    state = STATE_FINISHED
    if(#players > 1) then
        if(not winner) then
            for i, p in ipairs(players) do
                if(isAlive[p] and exports.USGrooms:getPlayerRoom(p) == "dd") then
                    winner = p
                    break
                end
            end
        end
        if(winner) then
            local reward = ((#players+1)-rank) * 37
            givePlayerMoney(winner, reward)
            exports.USGplayerstats:incrementPlayerStat(winner, "dd_wins", 1)
            outputChatBox("[DD] You win, you gain $"..reward.."!", winner,0,255,0)
        end
    end
    if(winner) then
        for i, player in ipairs(players) do
            if(isElement(player) and exports.USGrooms:getPlayerRoom(player) == "dd") then
                triggerClientEvent(player, "USGdd.roundWon", winner)
            end
        end
    end
    setTimer(endGame, 5000, 1)
end

function endGame()
    for i,player in ipairs(players) do
        if(exports.USGrooms:getPlayerRoom(player) == "dd") then
            fadeCamera(player, false)
            triggerClientEvent(player, "USGdd.roundEnd", player)
        end
    end
    setTimer(cleanGame, 1000, 1)
end

function cleanGame()
    for player, vehicle in pairs(playerVehicles) do
        if(isElement(vehicle)) then
            if(isElement(player)) then
                removePedFromVehicle(player)
            end
            destroyElement(vehicle)
        end
    end
    playerVehicles = {} 
    setTimer(loadGame, 500, 1)
end

function onPlayerWasted(player)
    if(not isAlive[player] or state ~= STATE_ACTIVE) then return end
    local index
    for i, pPlayer in ipairs(players) do
        if(player == pPlayer and isAlive[pPlayer]) then -- he was actually participating
            rank = rank - 1
            isAlive[player] = false
            removePlayerVehicle(player)
            startSpectate(player)
            spawnPlayerDD(player)
            if(rank <= 2) then -- there is one player left
                stopGame()
            else
                outputChatBox("[DD] You finished at #"..rank, player, 200,255,200)
            end 
            index = i
            break
        end
    end
    if(index and gameStartTick) then -- valid death
        local secondsSinceStart = math.floor((getTickCount()-gameStartTick)/1000)
        local deathTime = string.format("%02i:%02i", secondsSinceStart/60, secondsSinceStart%60)
        for i, pPlayer in ipairs(players) do
            if(isElement(pPlayer) and exports.USGrooms:getPlayerRoom(pPlayer) == "dd") then
                triggerClientEvent(pPlayer, "USGdd_room.playerWasted", player, rank, deathTime, exports.USG:getPlayerColoredName(player))
            end
        end
    end
    if(index) then -- find people who are spectating, if they were spectating the person who died, go to the next
        for player, i in pairs(spectators) do
            if(i == index and exports.USGrooms:getPlayerRoom(player) == "dd") then
                nextSpectateTarget(player)
            end
        end
    end
end

addEventHandler("onPlayerWasted", root, 
    function () 
        if(exports.USGrooms:getPlayerRoom(source) == "dd") then
            onPlayerWasted(source)
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

function onPlayerJoinGame(player)
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
            break
        end
    end
    if(not found) then
        triggerClientEvent(player, "USGrace_common.freezeCamera", player)
    end
end

function setSpectateTarget(player, target, i)
    if(exports.USGrooms:getPlayerRoom(player) ~= "dd") then return false end
    setCameraTarget(player, target)
    spectators[player] = i
end

function nextSpectateTarget(player)
    if(isAlive[player]) then return false end
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
    if(isAlive[player]) then return false end
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

function removePlayerVehicle(player)
    local vehicle = getPedOccupiedVehicle(player)
    if(isElement(vehicle)) then
        removePedFromVehicle(player, vehicle)
        destroyElement(vehicle)
    end
    vehicle = playerVehicles[player]
    if(isElement(vehicle)) then
        removePedFromVehicle(player, vehicle)
        destroyElement(vehicle)
    end
    playerVehicles[player] = nil
end