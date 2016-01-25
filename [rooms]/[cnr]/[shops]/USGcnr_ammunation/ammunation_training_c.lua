local trainingLocations = {
    {x = 300.27, y = -138.59, z = 1004.06,int = 7,dim = 1},
    {x = 300.54, y = -137.02, z = 1004.06,int = 7,dim = 1},
    {x = 300.23, y = -135.61, z = 1004.06,int = 7,dim = 1},
    {x = 300.51, y = -134.1, z = 1004.06,int = 7,dim = 1},
    {x = 300.36, y = -132.49, z = 1004.06,int = 7,dim = 1},
    {x = 300.24, y = -130.88, z = 1004.06,int = 7,dim = 1},
    {x = 300.52, y = -129.46, z = 1004.06,int = 7,dim = 1},
    {x = 300.23, y = -127.96, z = 1004.06,int = 7,dim = 1},
    --{x = 302.82, y = -59.71, z = 1001.51,int = 4,dim = 5},
    --{x = 302.65, y = -61.18, z = 1001.51,int = 4,dim = 5},
    --{x = 302.36, y = -62.61, z = 1001.51,int = 4,dim = 5},
    --{x = 302.46, y = -64.33, z = 1001.51,int = 4,dim = 5},
    --{x = 302.4, y = -65.71, z = 1001.51,int = 4,dim = 5},
    --{x = 302.47, y = -67.22, z = 1001.51,int = 4,dim = 5},
    --{x = 302.39, y = -68.9, z = 1001.51,int = 4,dim = 5},
    --{x = 302.84, y = -70.28, z = 1001.51,int = 4,dim = 5},

    {x = 2179.28125, y = 955.9423828125, z = 10.096077919006, int = 0, dim = 0},
    {x = 2179.2998046875, y = 954.51171875, z = 10.096077919006, int = 0, dim = 0},
    {x = 2179.3642578125, y = 952.9521484375, z = 10.096077919006, int = 0, dim = 0},
    {x = 2179.28125, y = 951.458984375, z = 10.096077919006, int = 0, dim = 0},
    {x = 2179.208984375, y = 949.89453125, z = 10.096077919006, int = 0, dim = 0},
    {x = 2179.5205078125, y = 948.4169921875, z = 10.096077919006, int = 0, dim = 0},
    {x = 2179.1572265625, y = 946.9384765625, z = 10.096077919006, int = 0, dim = 0},
    {x = 2179.490234375, y = 945.4892578125, z = 10.096077919006, int = 0, dim = 0},

    {x = 289.24, y = -24.93, z = 1001.51, int = 1, dim = 2},
    {x = 290.67, y = -25.15, z = 1001.51, int = 1, dim = 2},
    {x = 292.22, y = -25.22, z = 1001.51, int = 1, dim = 2},
    {x = 293.69, y = -25.00, z = 1001.51, int = 1, dim = 2},
    {x = 295.21, y = -25.17, z = 1001.51, int = 1, dim = 2},
    {x = 296.76, y = -25.07, z = 1001.51, int = 1, dim = 2},
    {x = 298.17, y = -25.15, z = 1001.51, int = 1, dim = 2},
    {x = 299.63, y = -25.16, z = 1001.51, int = 1, dim = 2},
    ----lvtarin

    ----LV
    {x=2179.365234375,  y=955.984375,  z=11.093437194824, int=0, dim=0},
    {x=2179.35546875, y=954.4716796875, z=11.093437194824, int=0, dim=0},
    {x=2179.1611328125, y=953.052734375, z=11.093437194824, int=0, dim=0},
    {x=2179.2109375, y=951.5478515625, z=11.093437194824, int=0, dim=0},
    {x=2179.1923828125, y=950.001953125, z=11.093437194824, int=0, dim=0},
    {x=2179.32421875, y=948.5732421875, z=11.093437194824, int=0, dim=0},
    {x=2179.1005859375, y=947.1171875, z=11.093437194824, int=0, dim=0},
    {x=2179.3671875, y=945.4580078125, z=11.093437194824, int=0, dim=0},
    ----LS
    {x=1386.5185546875, y=-1283.5908203125, z=13.557812690735, int=0, dim=0},
    {x=1386.5947265625, y=-1285.033203125, z=13.557812690735, int=0, dim=0},
    {x=1386.419921875, y=-1286.6123046875, z=13.557812690735, int=0, dim=0},
    {x=1386.4072265625, y=-1288.09375, z=13.557812690735, int=0, dim=0},
    {x=1386.7080078125, y=-1289.6328125, z=13.557812690735, int=0, dim=0},
    {x=1386.5732421875, y=-1291.076171875, z=13.557812690735, int=0, dim=0},
    {x=1386.4951171875, y=-1292.7080078125, z=13.557812690735, int=0, dim=0},
    {x=1386.4306640625, y=-1294.138671875, z=13.557812690735, int=0, dim=0},
}

local interiorTargets = {
    -- [int] = { align = "x/y",
    --=         [stage] = x,y,z,rz},
    [1] =   { 
                align = "x",
                wall1 = 284,
                wall2 = 300,
                [1] = {x = 293.3818359375, y = -20.3994140625, z = 1001.515625, rz = 180},
                [2] = {x = 293.9521484375, y = -16.845703125, z = 1001.515625, rz = 180},
                [3] = {x = 293.4033203125, y = -13.9013671875, z = 1001.515625, rz = 180},
                [4] = {x = 291.7119140625, y = -10.5478515625, z = 1001.515625, rz = 180},
                [5] = {x = 291.2314453125, y = -8.0302734375, z = 1001.515625, rz = 180},
            },
    [4] =   {
                align = "y",
                wall1 = -72,
                wall2 = -56,
                [1] = { x = 309.7880859375, y = -65.30859375, z = 1001.515625, rz = 90 },
                [2] = { x = 313.7880859375, y = -65.30859375, z = 1001.515625, rz = 90 },
                [3] = { x = 316.7880859375, y = -65.30859375, z = 1001.515625, rz = 90 },
                [4] = { x = 320.7880859375, y = -65.30859375, z = 1001.515625, rz = 90 },
                [5] = { x = 325.7880859375, y = -65.30859375, z = 1001.515625, rz = 90 },
            },
    [7] =   {
                align = "y",
                wall1 = -142,
                wall2 = -126,
                [1] = {x = 295.5634765625, y = -133.1328125, z = 1004.0625, rz = 270},
                [2] = {x = 293.3212890625, y = -132.666015625, z = 1004.0625, rz = 270},
                [3] = {x = 290.1298828125, y = -133.9921875, z = 1004.0625, rz = 270},
                [4] = {x = 286.2529296875, y = -134.9345703125, z = 1004.062, rz = 270},
                [5] = {x = 280.939453125, y = -135.5341796875, z = 1004.0625, rz = 270},
            },
     [0] =   {
                align = "y",
                wall1 = -72,
                wall2 = -56,
                [1] = {x = 1391.0517578125, y = -1283.393554625, z = 13.565625, rz = 90},
                [2] = {x = 1393.0517578125, y = -1283.393554625, z = 13.565625, rz = 90} ,
                [3] = {x = 1395.0517578125, y = -1283.393554625, z = 13.565625, rz = 90},
                [4] = {x = 1397.0517578125, y = -1283.393554625, z = 13.565625, rz = 90} ,
                [5] = {x = 1398.0517578125, y = -1283.393554625, z = 13.565625, rz = 90} ,
            },
}

local trainingMarkers = {}
local markerInterior = {}
local training = false
local trainGUI = {}

function createTrainers()
    for i, location in ipairs(trainingLocations) do
        for dimension=0,5 do
            local marker = createMarker(location.x,location.y,location.z-1, "cylinder",1, 255,0,0,170)
            addEventHandler("onClientMarkerHit", marker, onTrainMarkerHit)
            addEventHandler("onClientMarkerLeave", marker, onTrainMarkerExit)
            setElementInterior(marker, location.int)
            setElementDimension(marker, dimension)
            table.insert(trainingMarkers, marker)
            markerInterior[marker] = location.int
        end
    end
end

function removeTrainers()
    for i, marker in ipairs(trainingMarkers) do
        if(isElement(marker)) then
            destroyElement(marker)
        end
    end
    trainingMarkers = {}
    markerInterior = {}
end

addEvent("onPlayerJoinRoom", true)
addEventHandler("onPlayerJoinRoom", localPlayer,
    function (room)
        if(room == "cnr") then
            createTrainers()
        end
    end
)
addEvent("onPlayerExitRoom", true)
addEventHandler("onPlayerExitRoom", localPlayer,
    function (prevRoom)
        if(prevRoom == "cnr") then
            removeTrainers()
        end
    end
)
addEventHandler("onClientResourceStart", resourceRoot,
    function ()
        if(getResourceFromName("USGrooms") and getResourceState(getResourceFromName("USGrooms")) == "running"
        and exports.USGrooms:getPlayerRoom() == "cnr") then
            createTrainers()
        end
    end
)

function onTrainMarkerHit(hitElement, dimensions)
    if(hitElement ~= localPlayer or not dimensions) then return end
    if(not exports.USG:validateMarkerZ(source, hitElement)) then return end
    if(not training) then
        toggleTrainGUI(true)
    end
    setControlState("forwards", false)
end

function onTrainMarkerExit(leaveElement, dimensions)
    if(leaveElement ~= localPlayer) then return end
    if(training) then
        exports.USGmsg:msg("You left the shooting marker, training cancelled.", 255,128,0)
        stopTraining()
    elseif(isElement(trainGUI.window) and exports.USGGUI:getVisible(trainGUI.window)) then
        toggleTrainGUI(false)
    end
end

function createTrainGUI()
    trainGUI.window = exports.USGGUI:createWindow("center", "center", 350, 200, false, "Training weapons")
    trainGUI.infoLabel = exports.USGGUI:createLabel("center",5, 340,155, false, "You can train your weapons here. Each time you complete a training your skill for that weapon will increase with 25%.\
        This means you have to train each weapon 4 times to get 100%.\
        Each time you progress you will unlock bonuses for that weapon.\
        Training a weapon costs $200, you can still practice without $200 but it won't increase your skill.", trainGUI.window)
    trainGUI.cancel = exports.USGGUI:createButton(5,160,70,30,false,"Cancel",trainGUI.window)
    addEventHandler("onUSGGUISClick", trainGUI.cancel, toggleTrainGUI, false)
    trainGUI.toggle = exports.USGGUI:createButton(275,160,70,30,false,training and "Stop" or "Start",trainGUI.window)
    addEventHandler("onUSGGUISClick", trainGUI.toggle, toggleTraining, false)
end

function toggleTrainGUI(onlyOpen)
    if(not isElement(trainGUI.window)) then
        createTrainGUI()
        showCursor(true)
    else
        if(exports.USGGUI:getVisible(trainGUI.window) and not onlyOpen) then
            exports.USGGUI:setVisible(trainGUI.window, false)
            showCursor(false)
        else
            exports.USGGUI:setText(trainGUI.toggle, training and "Stop" or "Start")
            exports.USGGUI:setVisible(trainGUI.window, true)
            showCursor(true)
        end
    end
end

local stageTimes = { --[wepID] = time in ms
    default = 7500,
    [24] = 15500,
}

local STAGE_TIME_LIMIT = 7500
local currentTarget
local trainingInterior
local trainingWeapon
local targets = {}
local turnDuration = 500
local stageProgress = 0
local currentStage
local stageEnd

addEvent ( "onClientInteriorHit", true )
function startTraining()
    training = true
    trainingWeapon = false
    trainingInterior = interiorTargets[getElementInterior(localPlayer)]
    addEventHandler("onClientInteriorHit", root, onInteriorHit)
    currentStage = 1
    startStage()
    STAGE_TIME_LIMIT = stageTimes[getPedWeapon(localPlayer)] or stageTimes.default
    addEventHandler("onClientRender", root, renderTargets)
    toggleTrainGUI()
end

function onInteriorHit()
    exports.USGmsg:msg("You left the shooting range, training cancelled.", 255,128,0)
    stopTraining()
end

function startStage()
    if(not training) then return end
    stageProgress = 0
    local pos = trainingInterior[currentStage]
    local px, py, pz = getElementPosition(localPlayer)
    if(trainingInterior.align == "y") then
        pos.y = py
    elseif(trainingInterior.align == "x") then
        pos.x = px
    end
    local target = createTarget(pos.x, pos.y, pos.z, pos.rz or 0)
    local rx, ry, rz = getElementRotation(target.frame)
    target.turn = true
    target.turnType = "in"
    target.turnStartTick = getTickCount()
    setElementRotation(target.frame, rx, 90, rz)
    if(currentStage >= 3) then
        target.move = true
        target.moveType = math.random(1,2) == 1 and "add" or "sub"
        target.moveRange = currentStage*1.2
        target.moveStartTick = false
    end
    currentTarget = target
end

function stopStage()
    if(currentTarget) then
        for k, object in pairs(currentTarget) do
            if(isElement(object)) then
                destroyElement(object)
            end
        end
    end
    currentTarget = nil
end

function onStageCompleted()
    currentTarget.turnType = "out"
    currentTarget.turnStartTick = getTickCount()
    currentTarget.turn = true
    currentStage = currentStage+1
    if(currentStage <= 5) then
        exports.USGmsg:msg("Stage complete! Next stage "..currentStage.."/5 starting in 4 seconds.",0,255,0)
        setTimer(startStage, 4000, 1)
    else
        exports.USGmsg:msg("Training complete!",0,255,0)
        stopTraining(true)
        triggerServerEvent("USGcnr_ammunation.training.complete", localPlayer, trainingWeapon)
    end
end

function stopTraining(reopen)
    training = false
    removeEventHandler("onClientRender", root, renderTargets)
    removeEventHandler("onClientInteriorHit", root, onInteriorHit)
    stopStage()
    currentStage = 1
    if(reopen) then
        -- prevent accidental clicks
        exports.USGGUI:setEnabled(trainGUI.cancel, false)
        setTimer(call, 1000, 1, getResourceFromName("USGGUI"),"setEnabled", trainGUI.cancel, true) 
        exports.USGGUI:setEnabled(trainGUI.toggle, false)
        setTimer(call, 1000, 1, getResourceFromName("USGGUI"),"setEnabled", trainGUI.toggle, true) 
        toggleTrainGUI(true)
        setControlState("fire", false)
        setControlState("aim_weapon", false)
    end
end

function toggleTraining()
    if(not training) then
        startTraining()
    else
        stopTraining()
    end
end

function createTarget(x,y,z, rot)
    local target = {}
    rot = rot+90
    if(rot > 360) then rot = rot - 360 end
    target.frame = createObject(3025, x,y,z+3, 0, 0, rot)
    target.board = createObject(3260, x,y,z)
    setObjectBreakable(target.board, false)
    attachElements(target.board, target.frame, 0,0,-3.4,0,0,90)
    target.head = createObject(3024, x,y,z)
    attachElements(target.head, target.frame, 0.3,0.25,-0.1,0,0,90)
    target.larm = createObject(3023, x,y,z)
    attachElements(target.larm, target.frame, 0.3,0.25,-0.1,0,0,90)
    target.rarm = createObject(3022, x,y,z)
    attachElements(target.rarm, target.frame, 0.3,0.25,-0.1,0,0,90)
    target.ltorso = createObject(3020, x,y,z)
    attachElements(target.ltorso, target.frame, 0.3,0.25,-0.1,0,0,90)
    target.rtorso = createObject(3021, x,y,z)
    attachElements(target.rtorso, target.frame, 0.3,0.25,-0.1,0,0,90)
    target.lleg = createObject(3019, x,y,z)
    attachElements(target.lleg, target.frame, 0.3,0.25,-0.1,0,0,90)
    target.rleg = createObject(3018, x,y,z)
    attachElements(target.rleg, target.frame, 0.3,0.25,-0.1,0,0,90)
    for k, object in pairs(target) do
        setElementInterior(object, getElementInterior(localPlayer))
        setElementDimension(object, getElementDimension(localPlayer))
        if(k ~= "frame" and k ~= "board") then
            addEventHandler("onClientObjectBreak", object, onTargetPieceBreak)
        end
    end
    return target
end

local scorePopups = {}

local color_red = tocolor(255,0,0)
local color_orange = tocolor(255,128,0)
local color_green = tocolor(0,255,0)

local STATUS_X = 20
local STATUS_Y = 20+((1+chatLayout["chat_lines"])*chatLayout["chat_scale"][2]*15)
local STATUS_WIDTH, STATUS_HEIGHT = 350, 70

function renderTargets()
    local target = currentTarget
    local tick = getTickCount()
    local timeLeft = stageEnd and math.max(0,math.ceil((stageEnd-tick)/1000)) or 10
    dxDrawRectangle(STATUS_X, STATUS_Y, STATUS_WIDTH,STATUS_HEIGHT,tocolor(0,0,0,160))
    local textColor = timeLeft < 3 and color_red or color_orange
    dxDrawText("stage: "..currentStage.."/5 ", STATUS_X, STATUS_Y, STATUS_X+STATUS_WIDTH,STATUS_Y+30,textColor, 1, "bankgothic","center","center")
    if(target and not target.turn) then -- stage active
        dxDrawText("time left: "..(stageEnd and timeLeft.." seconds" or "-"), STATUS_X, STATUS_Y+35, STATUS_X+STATUS_WIDTH,STATUS_Y+65,textColor, 1, "bankgothic","center","center")
        local px,py,pz = getElementPosition(localPlayer)
        local tx,ty,tz = getElementPosition(target.board)
        local sx,sy = getScreenFromWorldPosition(tx,ty,tz+2)
        if(sx and sy) then
            local distance = getDistanceBetweenPoints2D(px,py,tx,ty)
            local scale = 13/distance
            dxDrawRectangle(sx-(60*scale), sy, scale*120, 22*scale, tocolor(0,0,0,255))
            dxDrawRectangle(sx+2-(60*scale), sy+2, ((120*scale)-4)*(1-(stageProgress/100)), (22*scale-4), tocolor(180,0,0))
        end
    end
    if(not target) then return end
    if(target.turn) then
        if(target.turnStartTick+turnDuration > tick) then
            local progress = (tick-target.turnStartTick)/turnDuration
            local rx, ry, rz = getElementRotation(target.frame)
            local ry = target.turnType == "in" and (90-(progress*90)) or (progress*90)
            setElementRotation(target.frame, rx, ry, rz)
        else
            target.turn = false
            local rx, ry, rz = getElementRotation(target.frame)
            setElementRotation(target.frame, rx, target.turnType == "in" and 0 or 90, rz)
            stageEnd = tick+STAGE_TIME_LIMIT
            if(target.turnType == "out") then
                stopStage()
            end
        end
    else -- stage started and active
        if(target.move and target.moveType) then
            local x,y,z = getElementPosition(target.frame)
            if((not target.moveStartTick) or tick > target.moveStartTick+target.moveDuration) then
                if(target.moveStartTick and target.moveStartTick+target.moveDuration < tick) then
                    target.moveType = target.moveType == "add" and "sub" or "add" -- reverse direction
                end 
                target.moveStartPos = {x=x,y=y}
                local val = trainingInterior.align == "x" and x or y
                target.moveEndPos = target.moveType == "add" and math.min(trainingInterior.wall2-1.5, val+target.moveRange) or math.max(trainingInterior.wall1+1.5, val-target.moveRange)
                target.moveDuration = math.abs(target.moveEndPos - (trainingInterior.align == "x" and target.moveStartPos.x or target.moveStartPos.y))*1000
                target.moveStartTick = tick
            else
                local progress = (tick-target.moveStartTick)/target.moveDuration
                if(target.moveType == "sub") then progress = progress end
                local nx,ny,nz
                if(trainingInterior.align == "x") then
                    nx, ny, nz = interpolateBetween(target.moveStartPos.x, target.moveStartPos.y, 0, target.moveEndPos, target.moveStartPos.y, 0, progress, "Linear")
                else
                    nx, ny, nz = interpolateBetween(target.moveStartPos.x, target.moveStartPos.y, 0, target.moveStartPos.x, target.moveEndPos, 0, progress, "Linear")
                end
                setElementPosition(target.frame, nx, ny, z)
            end
        end
        for i, popup in ipairs(scorePopups) do
            if(popup.start+1500 > tick) then
                local progress = (popup.start+1500-tick)/1500
                local _,_,fade = interpolateBetween(0,0,0,0,0,1, progress, "OutElastic")
                dxDrawText(popup.text, popup.x, popup.y, popup.x+100,popup.y+100,popup.color,fade*4, "default", "left", "top", false, false, true)
            else
                table.remove(scorePopups, i)
            end
        end
        if(tick > stageEnd) then
            stopTraining(true)
            exports.USGmsg:msg("You failed to shoot all the targets within 10 seconds, training failed!", 255,0,0)
            return false
        end
    end
end

function newScorePopup(text)
    local sizeX, sizeY = 0.75*screenWidth,0.75*screenHeight
    local x,y = ((screenWidth-sizeX)/2)+math.random(1,sizeX),((screenHeight-sizeY)/2)+math.random(1,sizeY)
    local r,g,b = math.random(1,255),  math.random(1,255),  math.random(1,255)
    table.insert(scorePopups, { text = text, x = x, y = y, start = getTickCount(), color = tocolor(r,g,b)})
end

function onTargetPieceBreak()
    if(currentTarget.turn) then return false end -- it's fading out
    local curWeapon = getPedWeapon(localPlayer)
    if(trainingWeapon and curWeapon ~= trainingWeapon) then
        exports.USGmsg:msg("You must use the same weapon you used when you started ( "..getWeaponNameFromID(trainingWeapon).." ).", 255,0,0)
        cancelEvent()
        return
    elseif(not trainingWeapon) then
        trainingWeapon = curWeapon
        STAGE_TIME_LIMIT = stageTimes[trainingWeapon] or stageTimes.default
    end
    local hitTarget, hitPart
    for part, object in pairs(currentTarget) do
        if(object == source) then
            hitPart = part
            break
        end
    end
    if(hitPart) then
        if(hitPart == "head") then
            stageProgress = math.min(100,stageProgress+50)
            newScorePopup("Headshot!\n+50")
        else
            stageProgress = math.min(100,stageProgress+17)
            newScorePopup("+17")
        end
        if(stageProgress >= 100) then
            onStageCompleted()
        end
    end
end