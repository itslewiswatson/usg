local msgGUI = {}
local messages = ""

addEventHandler("onClientResourceStart", resourceRoot,
    function()
        msgGUI.window = guiCreateWindow(0.8, 0.25, 0.2, 0.5, apps.messages.name, true)
        guiWindowSetSizable(msgGUI.window, false)

        msgGUI.memo = guiCreateMemo(0.03, 0.03, 0.95, 0.35, "", true, msgGUI.window[1])
        guiMemoSetReadOnly(msgGUI.memo, true)
        msgGUI.label[1] = guiCreateLabel(0.01, 0.40, 0.1, 0.05, "Type your message here", true, msgGUI.window[1])
        guiLabelSetHorizontalAlign(msgGUI.label[1], "center", false)
        guiLabelSetVerticalAlign(msgGUI.label[1], "center")
        msgGUI.edit[1] = guiCreateEdit(0.03, 0.45, 0.95, 0.07, "", true, msgGUI.window[1])
        msgGUI.gridlist = guiCreateGridList(0.03, 0.5, 0.95, 0.4, true, msgGUI.window[1])
        guiGridListAddColumn(msgGUI.gridlist, "Player", 0.9)
        msgGUI.label[2] = guiCreateLabel(0.02, 0.9, 0.1, 0.04, "Search for a Player:", true, msgGUI.window[1])
        guiLabelSetHorizontalAlign(msgGUI.label[2], "center", false)
        guiLabelSetVerticalAlign(msgGUI.label[2], "center")
        msgGUI.edit[2] = guiCreateEdit(0.03, 0.9, 0.95, 0.05, "", true, msgGUI.window[1])    
    end
)

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
		exports.USGGUI:setVisible(msgGUI.window , true)
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