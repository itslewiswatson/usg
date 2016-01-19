local moneyGUI = {}


function createMoneyGUI()
    exports.USGGUI:setDefaultTextAlignment("left","center")
    moneyGUI.window = exports.USGGUI:createWindow("center","center", 300, 430, false,"Money Transfer")
        exports.USGGUI:createLabel("center",5, 290, 35,false,"Player Name:",moneyGUI.window)
    moneyGUI.search = exports.USGGUI:createEditBox("center",36,298,25,false,"",moneyGUI.window)
    moneyGUI.grid = exports.USGGUI:createGridList("center",62,298,280,false,moneyGUI.window)
        exports.USGGUI:gridlistAddColumn(moneyGUI.grid, "Player", 1.0)
        exports.USGGUI:createLabel("center",335, 290, 35,false,"Money Amount:",moneyGUI.window)
    moneyGUI.amount = exports.USGGUI:createEditBox("center",370,298,25,false,"",moneyGUI.window)
    moneyGUI.send = exports.USGGUI:createButton("center",400,110,25,false,"Send Money",moneyGUI.window)
       addEventHandler("onUSGGUISClick", moneyGUI.send, sendMoney, false)     
       addEventHandler("onUSGGUIChange",  moneyGUI.search, moneyonSearchChange, false) 
    end

function togglemoneyGUI()
if(not exports.USGaccounts:isPlayerLoggedIn()) then return end
    if(isElement(moneyGUI.window )) then
        if(exports.USGGUI:getVisible(moneyGUI.window )) then
        exports.USGGUI:setVisible(moneyGUI.window , false)
            showCursor(false)
            exports.USGblur:setBlurDisabled()
        else
            showCursor(true)
            exports.USGGUI:setVisible(moneyGUI.window , true)
            exports.USGblur:setBlurEnabled()
            moneyfillPlayerGrid()
        end
    else
        createMoneyGUI()
        showCursor(true)
        exports.USGblur:setBlurEnabled()
        moneyfillPlayerGrid()
    end 
end 
addEvent("UserPanel.App.MoneyApp",true)
addEventHandler("UserPanel.App.MoneyApp",root,togglemoneyGUI)

function moneyrefresh()
    moneyfillPlayerGrid()
end


function moneyfillPlayerGrid()
    exports.USGGUI:gridlistClear(moneyGUI.grid)
    local filter = exports.USGGUI:getText(moneyGUI.search)
    filter = exports.USG:escapeString(filter)
    for i, player in ipairs(getElementsByType("player")) do
        local name = getPlayerName(player)
        if(player ~= localPlayer and (filter == "" or string.find(name:lower(), filter:lower()))
            and exports.USGrooms:getPlayerRoom(player) == "cnr") then
            local row = exports.USGGUI:gridlistAddRow(moneyGUI.grid)
            exports.USGGUI:gridlistSetItemText(moneyGUI.grid, row, 1, name)
            exports.USGGUI:gridlistSetItemData(moneyGUI.grid, row, 1, player)
        end
    end
end

function moneyonSearchChange()
    moneyfillPlayerGrid()
end

function sendMoney()
    local selected = exports.USGGUI:gridlistGetSelectedItem(moneyGUI.grid)
    if(selected) then
    local player = exports.USGGUI:gridlistGetItemData(moneyGUI.grid, selected, 1)
        if(isElement(player)) then
            local amount = tonumber(exports.USGGUI:getText(moneyGUI.amount))
            if(amount and amount > 0) then
            triggerServerEvent("testing.sendMoney", player, amount)
                exports.USGGUI:setText(moneyGUI.amount, "")
            else
                exports.USGmsg:msg("Invalid amount.", 255, 0, 0)
            end
        else
            exports.USGmsg:msg("This player has quit.", 255,0,0)
        end
    else
        exports.USGmsg:msg("You did not select a player.", 255,0,0)
    end
end