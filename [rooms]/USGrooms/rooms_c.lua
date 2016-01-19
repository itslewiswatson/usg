addEvent("onPlayerJoinRoom", true)
addEvent("onPlayerExitRoom", true)

local screenX,screenY = guiGetScreenSize()
local startX = 0.01*screenX
local roomTileSize = 200
local tileSpaceWidth = 0.75*screenX

local selecting = false
local rowTiles = math.floor(tileSpaceWidth/(roomTileSize+15))

local selectorFadeStart
local selectorFadeDuration = 750

local rememberChoiceCheckbox
local rememberChoice = false
local roomCount = 0
for key, room in pairs(rooms) do
    roomCount = roomCount+1
    room.hasImage = fileExists("images/"..room.name..".png")
end

function onLogin()
    if(fileExists("default.conf")) then
        rememberChoice = true
        local file = fileOpen("default.conf")
        local choice = fileRead(file,math.max(fileGetSize(file),1))
        fileClose(file)
        local found = false
        if(choice and #choice > 0) then
            if(rooms[choice]) then
                joinRoom(choice)
            else
                openSelector()
            end
        else
            openSelector()
        end
    elseif (not selecting) then
        openSelector()
    end
end


function openSelector()
    if(not selecting) then
        --showChat(false)
        selecting = true
        if(not getPlayerRoom()) then -- not switching, this is onJoin
            fadeCamera(false)
            showPlayerHudComponent("radar",false)       
            setTimer(fadeCamera,1500,1,true)
            setTimer(setCameraMatrix, 1250, 1, 10,0,20,45,30, 10)
            setTimer(function ()
                selectorFadeStart = getTickCount()
                openSelectorDelay()
            end,1500,1)         
        else
            selectorFadeStart = getTickCount()
            openSelectorDelay()
        end
    end
end
addEventHandler("onPlayerExitRoom",localPlayer,openSelector)

addEventHandler("onClientResourceStart",resourceRoot,
    function ()
        if(not getPlayerRoom() and getResourceFromName("USGaccounts") and getResourceState(getResourceFromName("USGaccounts")) == "running"
        and exports.USGaccounts:isPlayerLoggedIn()) then
            openSelector()
        else
            addEvent("onServerPlayerLogin", true)
            addEventHandler("onServerPlayerLogin",localPlayer,onLogin)  
        end
    end
)

function openSelectorDelay()
    if(selecting) then
        --setCameraMatrix(0,0,20,45,30,10)
        showCursor(true)
        addEventHandler("onClientRender",root,onDraw)
        exports.USGblur:setBlurEnabled ()
        showPlayerHudComponent("radar",false)
        showChat(false)
        rememberChoiceCheckbox = exports.USGGUI:createCheckBox(startX,screenY/2,200,30,false,"Remember choice when logging in", false, nil, rememberChoice)
    end
end

local joinRoomTick = 0
function onDraw()
    local fadeProgress = 1
    if(selectorFadeStart) then fadeProgress = math.min(1,(getTickCount()-selectorFadeStart)/selectorFadeDuration) end
    dxDrawRectangle(0,0,screenX,screenY,tocolor(0,0,0,50)) -- faded background
    local totalHeight = roomTileSize
    if(roomCount > rowTiles) then
        totalHeight = math.ceil(roomCount/rowTiles)*(roomTileSize+15)
    end
    local columnX = 0
    local startY = (screenY-totalHeight)/2
    
    local cursorX,cursorY,_,_ = getCursorPosition()
    cursorX,cursorY = cursorX*screenX,cursorY*screenY
    
    local currentRoom = getPlayerRoom()
    local lastRow = 0
    local i = 1
    for k, room in pairs(rooms) do
        if(currentRoom ~= k) then
            local row = math.ceil(i/rowTiles)-1
            if(row ~= lastRow) then columnX = 0 lastRow = row end
            local yOffset = row*(roomTileSize+15)
            columnX = columnX + roomTileSize + 15
            local focus = (cursorX >= startX+columnX and cursorX <= startX+columnX+roomTileSize
            and cursorY >= startY+yOffset and cursorY <= startY+yOffset+roomTileSize)
            if(room.hasImage) then
                if(focus) then
                    dxDrawRectangle(startX+columnX,startY+yOffset,roomTileSize,roomTileSize, tocolor(180,180,180,fadeProgress*30))
                end
                dxDrawImage(startX+columnX,startY+yOffset,roomTileSize,roomTileSize, "images/"..room.name..".png")
            else
                dxDrawRectangle(startX+columnX,startY+yOffset,roomTileSize,roomTileSize,focus and tocolor(10,10,10,fadeProgress*185) or tocolor(0,0,0,fadeProgress*185))
                dxDrawText(room.text,startX+columnX+5,startY+yOffset+5,roomTileSize+startX+columnX-10,roomTileSize+startY+yOffset-10, tocolor(255,255,255,fadeProgress*255), 2,"default","center","center",false,true)
            end
            if(focus and getKeyState("mouse1")) then
                joinRoom(k)
                break
            end
            i = i + 1
        end
    end
    if(isElement(rememberChoiceCheckbox)) then
        exports.USGGUI:setPosition(rememberChoiceCheckbox, startX+roomTileSize+15, startY-35)
    end
end

function joinRoom(room)
    if(not joinRoomTick or getTickCount()-joinRoomTick > 5000) then
        joinRoomTick = getTickCount()
        if(selecting) then
            local state = exports.USGGUI:getCheckBoxState(rememberChoiceCheckbox)
            if(state) then
                local file = fileCreate("default.conf")
                fileWrite(file, room)
                rememberChoice = true
                fileClose(file)
            else
                rememberChoice = false
                if(fileExists("default.conf")) then
                    fileDelete("default.conf")
                end
            end 
        end
        if(not getPlayerRoom()) then
            triggerServerEvent("USGrooms.joinRoom",localPlayer,room)
        else
            triggerServerEvent("USGrooms.switchRoom",localPlayer,room)
        end
    end
end

function closeSelector()
    joinRoomTick = 0
    if(selecting) then
        if(not getPlayerRoom()) then
            fadeCamera(false)
        end
        removeEventHandler("onClientRender",root,onDraw)
        showCursor(false)
        showChat(true)
        destroyElement(rememberChoiceCheckbox)
        selecting = false
        showPlayerHudComponent("radar",true)
        exports.USGblur:setBlurDisabled ()
    end
end
addEventHandler("onPlayerJoinRoom", localPlayer, closeSelector)

bindKey("F1","down",
    function ()
        if(getPlayerRoom()) then
            if(not selecting) then
                openSelector()
            else
                closeSelector()
            end
        end
    end
)