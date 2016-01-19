local canFireRockets = false

addEvent("USGstr_room.prepareRound", true)
function prepareRound(vehicles)
    -- init countdown
    exports.USGrace_countdown:startCountdown(4, true)
    -- spawn protection
    for i, vehicle in ipairs(vehicles) do
        for _,vehicle2 in ipairs(vehicles) do
            if(vehicle ~= vehicle2) then
                setElementCollidableWith(vehicle,vehicle2,false)
                unbindKey("lshift","down",shootRocket)
            end
        end
        setElementAlpha(vehicle, 200)
    end
end
addEventHandler("USGstr_room.prepareRound", root, prepareRound)

addEvent("USGstr_room.gameStopSpawnProtection", true)
function stopSpawnProtection(vehicles)
    canFireRockets = true
    for i, vehicle in ipairs(vehicles) do
        for _,vehicle2 in ipairs(vehicles) do
            if(vehicle ~= vehicle2) then
                setElementCollidableWith(vehicle,vehicle2,true)
                bindKey("lshift","down",shootRocket)
            end
        end
        setElementAlpha(vehicle, 255)
    end
end
addEventHandler("USGstr_room.gameStopSpawnProtection", root, stopSpawnProtection)

local roundWinner = false

addEvent("USGstr.roundWon", true)
function onRoundWon()
    if(exports.USGrooms:getPlayerRoom() ~= "str") then return false end
    roundWinner = source
    addEventHandler("onClientRender", root, renderWinner)
end
addEventHandler("USGstr.roundWon", root, onRoundWon)

addEvent("USGstr.roundEnd", true)
addEvent("onPlayerExitRoom", true)
function onRoundEnd()
    exports.USGrace_ranklist:clear()
    if(roundWinner) then
        removeEventHandler("onClientRender", root, renderWinner)
    end
    roundWinner = false
end
addEventHandler("USGstr.roundEnd", root, onRoundEnd)
addEventHandler("onPlayerExitRoom", localPlayer, onRoundEnd)

local screenWidth, screenHeight = guiGetScreenSize()
function renderWinner()
    if(isElement(roundWinner)) then
        local name = getPlayerName(roundWinner)
        dxDrawText("Winner:\n\n"..name, 0, 0, screenWidth, screenHeight, tocolor(180,255,180),4,"default-bold","center","center")
    end
end

function findPointFromDistanceRotation(x,y, angle, dist)
    local angle = math.rad(angle+90)
    return x+(dist * math.cos(angle)), y+(dist * math.sin(angle))
end

local ROCKET_INTERVAL = 2250
local lastRocket = 0
function shootRocket()
    if(exports.USGrooms:getPlayerRoom() ~= "str") then return false end
    if(not canFireRockets or getTickCount() - lastRocket < ROCKET_INTERVAL) then return false end
    local vehicle = getPedOccupiedVehicle(localPlayer)
    if(vehicle) then
        lastRocket = getTickCount()
        local x,y,z = getElementPosition(vehicle)
        local rx,ry,rz = getElementRotation(vehicle)
        local px, py = findPointFromDistanceRotation(x,y,rz,4)
        local velocity = 60
        local nrotX = -rx
        local nrotZ = -(rz + 180)
        
        local vz = velocity * math.sin(math.rad(rx))
        local a = velocity * math.cos(math.rad(rx))
        
        local vx = a * math.sin(math.rad(-rz))
        local vy = a * math.cos(math.rad(-rz))
        local pz = z+(vz/50)+0.2
        createProjectile(localPlayer, 19, px, py, pz, 1.0, nil, nrotX, 0, nrotZ, vx / 50, vy / 50, vz / 50)
    end
end
bindKey("lshift","down",shootRocket)


function getRocketWaitProgress()
    local timeIn = getTickCount()-lastRocket
    return math.min(1, timeIn/ROCKET_INTERVAL)
end

addEvent("USGstr_room.playerWasted", true)
function onPlayerWasted(rank, time, nick)
    exports.USGrace_ranklist:add(source, rank, time, nick)
end
addEventHandler("USGstr_room.playerWasted", root, onPlayerWasted)