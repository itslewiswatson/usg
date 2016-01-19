 fileDelete("banking_atm_c")      

function getPointFromDistanceRotation(x, y, dist, angle)
    local a = math.rad(90 - angle);

    local dx = math.cos(a) * dist;
    local dy = math.sin(a) * -dist;

    return x+dx, y+dy;
end

local screenWidth, screenHeight = guiGetScreenSize()

local usingATM = false

local SCREEN_MODE = 0
local ATM_WIDTH = 400
local ATM_HEIGHT = 300
local ATM_X = (screenWidth-ATM_WIDTH)/2
local ATM_Y = (screenHeight-ATM_HEIGHT)/2
local mouseState = getKeyState("mouse1")
local mousePressed = false

-- loading aspect ratio
local ratio = math.floor(10*(screenWidth/screenHeight))/10
if(ratio == 1.7) then
    SCREEN_MODE = 1
    ATM_X = 0.3931*screenWidth
    ATM_Y = 0.1211*screenHeight
    ATM_WIDTH = 0.2291*screenWidth
    ATM_HEIGHT = 0.4180*screenHeight
elseif(ratio == 1.6) then
    SCREEN_MODE = 1
    ATM_X = 0.3924*screenWidth
    ATM_Y = 0.1633*screenHeight
    ATM_WIDTH = 0.2319*screenWidth
    ATM_HEIGHT = 0.3800*screenHeight
elseif(ratio == 1.3 or ratio == 1.2) then
    SCREEN_MODE = 1
    ATM_X = 0.3825*screenWidth
    ATM_Y = 0.2083*screenHeight
    ATM_WIDTH = 0.2400*screenWidth
    ATM_HEIGHT = 0.3283*screenHeight
elseif(ratio == 1.2) then
    SCREEN_MODE = 1
    ATM_X = 0.3825*screenWidth
    ATM_Y = 0.2083*screenHeight
    ATM_WIDTH = 0.2400*screenWidth
    ATM_HEIGHT = 0.3283*screenHeight
end
ATM_X,ATM_Y,ATM_WIDTH,ATM_HEIGHT = math.floor(ATM_X), math.floor(ATM_Y), math.floor(ATM_WIDTH), math.floor(ATM_HEIGHT)

local loadingData = false
local balance
local transactions
local transactionsGrid

local withdrawDialog
local depositDialog

function onATMMarkerHit(hitElement, dimensions)
    if(hitElement ~= localPlayer or not dimensions or isPedInVehicle(localPlayer)) then return end
    local x,y,z = getElementPosition(source)
    local _,_,pz = getElementPosition(localPlayer)
    if(math.abs(z-pz) > 2) then return end
    local object = getElementChild(source, 0)
    local _,_,rot = getElementRotation(object)
    initATM(x,y,z,rot)
end

function initATM(x,y,z,rot)
    if(not usingATM) then
        loadingData = true
        triggerServerEvent("USGcnr_banking.requestATMData", localPlayer)
        usingATM = true
        local frontX, frontY = getPointFromDistanceRotation(x, y, 0.6, rot)
        frontZ = z+2.5
        setCameraMatrix(frontX,frontY,frontZ,x,y,z+0.7)
        addEventHandler("onClientRender", root, onATMRender)
        showCursor(true)
        transactionsGrid = exports.USGGUI:createGridList(ATM_X+10,ATM_Y+105,ATM_WIDTH-20,ATM_HEIGHT-155,false)
        exports.USGGUI:gridlistAddColumn(transactionsGrid,"Transaction",0.63)
        exports.USGGUI:gridlistAddColumn(transactionsGrid,"Time",0.37)
    end
end

function stopATM()
    if(usingATM) then
        dialogCloseTick = false
        usingATM = false
        removeEventHandler("onClientRender", root, onATMRender)
        setCameraTarget(localPlayer)
        showCursor(false)
        if(isElement(transactionsGrid)) then
            destroyElement(transactionsGrid)
        end
        if(isElement(withdrawDialog)) then
            destroyElement(withdrawDialog)
        end     
        if(isElement(depositDialog)) then
            destroyElement(depositDialog)
        end     
    end
end

local dialogCloseTick = false

function drawButton(x,y,width,height,text)
    local cursorX,cursorY = getCursorPosition()
    cursorX, cursorY = cursorX*screenWidth, cursorY*screenHeight
    local selected = false
    local focus = false
    if(cursorX >=x and cursorX <= x+width and cursorY >= y and cursorY <= y+height) then
        focus = true
        if(mousePressed and not isElement(withdrawDialog) and not isElement(depositDialog)) then
            if(not dialogCloseTick or getTickCount()-dialogCloseTick > 250) then
                selected = true
            end
        end
    end
    dxDrawRectangle(x,y,width, height,focus and tocolor(65,65,65) or tocolor(50,50,50,230))
    dxDrawText(text, x, y, x+width,y+height,tocolor(255,255,255),1,"default-bold","center","center")
    return selected
end

function onATMRender()
    local mouse = getKeyState("mouse1")
    if(mouse and not mouseState) then
        mousePressed = true
    else
        mousePressed = false
    end
    mouseState = mouse
    if(SCREEN_MODE == 1) then
        dxDrawRectangle(ATM_X, ATM_Y, ATM_WIDTH, ATM_HEIGHT, tocolor(0,0,0,245))
        local close, withdraw, deposit -- button states
        if(loadingData) then
            dxDrawText("Please wait.", ATM_X, ATM_Y, ATM_X+ATM_WIDTH,ATM_Y+25,tocolor(255,255,255),1,"default-bold","center","center")
        else
            dxDrawText("Your bank balance: $"..exports.USGdevelopment:convertNumber(balance), ATM_X, ATM_Y, ATM_X+ATM_WIDTH,ATM_Y+25,tocolor(255,255,255),1,"default-bold","center","center")
            withdraw = drawButton(ATM_X+20,ATM_Y+35,ATM_WIDTH-40,30,"Withdraw")
            deposit = drawButton(ATM_X+20,ATM_Y+70,ATM_WIDTH-40,30,"Deposit")
        end
        local close = drawButton(ATM_X+20,ATM_Y+ATM_HEIGHT-35,ATM_WIDTH-40,30,"Close")
        if(close) then
            stopATM()
            return
        elseif(withdraw) then
            if(not isElement(withdrawDialog)) then
                withdrawDialog = exports.USGGUI:createDialog("Withdraw from bank", "Enter the amount of money to withdraw from the bank.","input","%d+")
                addEventHandler("onUSGGUIDialogFinish", withdrawDialog, onWithdrawFinish, false)
            else
                exports.USGGUI:focus(withdrawDialog)
            end
        elseif(deposit) then
            if(not isElement(depositDialog)) then
                depositDialog = exports.USGGUI:createDialog("Deposit to bank", "Enter the amount of money to deposit to the bank.","input","%d+")
                addEventHandler("onUSGGUIDialogFinish", depositDialog, onDepositFinish, false)
            else
                exports.USGGUI:focus(depositDialog)
            end     
        end
    end
end

function onWithdrawFinish(result)
    if(result and tonumber(result)) then
        local result = tonumber(result)
        if(result > 0) then
            triggerServerEvent("USGcnr_banking.withdraw", localPlayer, result)      
        else
            exports.USGmsg:msg("The amount must be more than $0!", 255,0,0)
            return
        end
    end
    dialogCloseTick = getTickCount()    
end

function onDepositFinish(result)
    if(result and tonumber(result)) then
        local result = tonumber(result)
        if(result > 0) then
            triggerServerEvent("USGcnr_banking.deposit", localPlayer, result)
        else
            exports.USGmsg:msg("The amount must be more than $0!", 255,0,0)
            return
        end
    end
    dialogCloseTick = getTickCount()
end

addEvent("USGcnr_banking.recieveATMData", true)
function recieveATMData(dBalance, dTransactions)
    loadingData = false
    balance = dBalance
    transactions = dTransactions
    exports.USGGUI:gridlistClear(transactionsGrid)
    for i, transaction in ipairs(transactions) do
        local row = exports.USGGUI:gridlistAddRow(transactionsGrid)
        exports.USGGUI:gridlistSetItemText(transactionsGrid, row, 1, transaction.text)
        exports.USGGUI:gridlistSetItemText(transactionsGrid, row, 2, transaction.datetime)
        local sortOrder = getDateSortOrder(transaction.datetime)
        exports.USGGUI:gridlistSetItemSortIndex(transactionsGrid, row, 2, sortOrder or -1)
    end
end
addEventHandler("USGcnr_banking.recieveATMData", localPlayer, recieveATMData)

addEventHandler("onClientResourceStop", resourceRoot, stopATM)

function getDateSortOrder(date)
    if(type(date) ~= "string") then return false end
    local year, month, day, hour, minute, second = date:match("(%d+)-(%d+)-(%d+)%s(%d+):(%d+):(%d+)")
    local year, month, day, hour, minute, second = tonumber(year), tonumber(month), tonumber(day), tonumber(hour), tonumber(minute), tonumber(second)
    if(year and month and day and hour and minute and second) then
        local order = year*365*24*60*60
        order = order + month*30*24*60*60
        order = order + day*24*60*60
        order = order + hour*60*60
        order = order + minute*60
        order = order + second
        return order
    end
end
