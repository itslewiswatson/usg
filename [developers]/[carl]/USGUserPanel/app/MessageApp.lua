local msgGUI = {}
local messages = ""


function createmsgGUI()
    exports.USGGUI:setDefaultTextAlignment("left","center")
    msgGUI.window = exports.USGGUI:createWindow("center","center", 300, 430, false,"Message")
    msgGUI.memo = exports.USGGUI:createMemo("center", "top", 298, 152, false,  messages,msgGUI.window)
    exports.USGGUI:setProperty( msgGUI.memo, "readOnly", true)
    msgGUI.input = exports.USGGUI:createEditBox("center",180,298,25,false,"",msgGUI.window)
    addEventHandler("onUSGGUIAccept", msgGUI.input, sendSMS, false)
    msgGUI.grid = exports.USGGUI:createGridList("center",205,298,170,false,msgGUI.window)
    exports.USGGUI:gridlistAddColumn(msgGUI.grid, "Player", 1.0)
    msgGUI.search = exports.USGGUI:createEditBox("center","bottom",298,25,false,"",msgGUI.window)
    addEventHandler("onUSGGUIChange",  msgGUI.search, msgsearchchange, false)
    exports.USGGUI:createLabel("center",375, 295, 35,false,"Search For a Player",msgGUI.window)
    exports.USGGUI:createLabel("center",150, 290, 35,false,"Type your message here",msgGUI.window)
end

function togglemsgGUI()
if(not exports.USGaccounts:isPlayerLoggedIn()) then return end
    if(isElement(msgGUI.window )) then
        if(exports.USGGUI:getVisible(msgGUI.window )) then
            exports.USGGUI:setVisible(msgGUI.window , false)
            showCursor(false)
            exports.USGblur:setBlurDisabled()
            showPlayerHudComponent("radar",true)
        else
            showCursor(true)
            exports.USGGUI:setVisible(msgGUI.window , true)
            msgfillPlayerGrid()
            exports.USGblur:setBlurEnabled()
            showPlayerHudComponent("radar",false)
        end
    else
        createmsgGUI()
        showCursor(true)
        msgfillPlayerGrid()
        exports.USGblur:setBlurEnabled()
        showPlayerHudComponent("radar",true)
    end 
end 
addEvent("UserPanel.App.MessageApp",true)
addEventHandler("UserPanel.App.MessageApp",root,togglemsgGUI)


function msgRefresh()
    msgfillPlayerGrid()
end

function msgfillPlayerGrid()
    exports.USGGUI:gridlistClear(msgGUI.grid)
    local filter = exports.USGGUI:getText(msgGUI.search)
    for i, player in ipairs(getElementsByType("player")) do
        local name = getPlayerName(player)
        if(player ~= localPlayer and (filter == "" or string.find(name:lower(), filter:lower()))) then
        local row = exports.USGGUI:gridlistAddRow(msgGUI.grid)
            exports.USGGUI:gridlistSetItemText(msgGUI.grid, row, 1, name)
            exports.USGGUI:gridlistSetItemData(msgGUI.grid, row, 1, player)
        end
    end
end


function refreshMessages()
    if(isElement(msgGUI.memo)) then
        exports.USGGUI:setText(msgGUI.memo, messages)
    end
end

function sendSMS()
    local selected = exports.USGGUI:gridlistGetSelectedItem(msgGUI.grid)
    if(selected) then
        local player = exports.USGGUI:gridlistGetItemData(msgGUI.grid, selected, 1)
        if(isElement(player)) then
            local message = exports.USGGUI:getText(msgGUI.input)
            triggerServerEvent("sendPM", localPlayer, player, message)
            exports.USGGUI:setText(msgGUI.input, "")
        else
            exports.USGmsg:msg("This player has quit.", 255,0,0)
        end
    else
        exports.USGmsg:msg("You did not select a player.", 255,0,0)
    end
end


function msgsearchchange ()
    msgfillPlayerGrid()
end


addEvent("onRecievePM")
function onRecieveMessage(message)
    messages = "< "..getPlayerName(source)..": "..message.."\n\n"..messages
    if(msgGUI) then
        refreshMessages()
    end
end
addEventHandler("onRecievePM", root, onRecieveMessage)

addEvent("onSendPM")
function onSentMessage(target, message)
    messages = "> "..getPlayerName(target)..": "..message.."\n\n"..messages
    if(msgGUI) then
        refreshMessages()
    end
end
addEventHandler("onSendPM", root, onSentMessage)