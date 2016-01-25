local msgGUI = {}
local messagesString = ""

addEventHandler("onClientResourceStart", resourceRoot,
    function()
        msgGUI.window = guiCreateWindow(0.78, 0.24, 0.21, 0.51, apps.messages.name, true)
        guiWindowSetSizable(msgGUI.window, false)

        msgGUI.memo = guiCreateMemo(0.03, 0.03, 0.94, 0.35, "", true, msgGUI.window)
        guiMemoSetReadOnly(msgGUI.memo, true)
        msgGUI.labelMessage = guiCreateLabel(0.01, 0.38, 0.97, 0.05, "Type your message here", true, msgGUI.window)
        guiLabelSetHorizontalAlign(msgGUI.labelMessage, "center", false)
        guiLabelSetVerticalAlign(msgGUI.labelMessage, "center")
        msgGUI.editMessage = guiCreateEdit(0.03, 0.44, 0.94, 0.07, "", true, msgGUI.window)
		addEventHandler("onClientGUIAccepted", msgGUI.editMessage, sendSMS, false)
        msgGUI.gridlist = guiCreateGridList(0.03, 0.51, 0.94, 0.37, true, msgGUI.window)
        guiGridListAddColumn(msgGUI.gridlist, "Player", 0.9)
        msgGUI.labelSearch = guiCreateLabel(0.02, 0.88, 0.97, 0.04, "Search for a Player:", true, msgGUI.window)
        guiLabelSetHorizontalAlign(msgGUI.labelSearch, "center", false)
        guiLabelSetVerticalAlign(msgGUI.labelSearch, "center")
        msgGUI.editSearch = guiCreateEdit(0.03, 0.92, 0.94, 0.05, "", true, msgGUI.window)
		addEventHandler("onClientGUIChanged",  msgGUI.editSearch, msgsearchchange, false)

		guiSetVisible ( msgGUI.window, false )
    end
)

local function showMessageGUI()
if(not exports.USGaccounts:isPlayerLoggedIn()) then return end
	if(guiGetVisible(msgGUI.window) == false)then
		guiSetInputMode("no_binds_when_editing")
		guiSetVisible ( msgGUI.window, true )
		msgfillPlayerGrid()
		showHelpGUI(helpInfo.app)
	end
end

addEvent(apps.messages.event,true)
addEventHandler(apps.messages.event,root,showMessageGUI)

local function hideMessageGUI()
	if(guiGetVisible(msgGUI.window) == true)then
		guiSetVisible ( msgGUI.window, false )
		showCursor(false)
		hideHelpGUI()
	end
end

bindKey( binds.closeAllApps.key, binds.closeAllApps.keyState,hideMessageGUI)


function msgfillPlayerGrid()
    guiGridListClear ( msgGUI.gridlist )
    local filter = guiGetText(msgGUI.editSearch)
    for i, player in ipairs(getElementsByType("player")) do
        local name = getPlayerName(player)
        if(player ~= localPlayer and (filter == "" or string.find(name:lower(), filter:lower()))) then
        local row = guiGridListAddRow ( msgGUI.gridlist )
            guiGridListSetItemText(msgGUI.gridlist, row, 1, name, false, false)
            guiGridListSetItemData(msgGUI.gridlist, row, 1, player)
        end
    end
end


function refreshMessages()
    if(isElement(msgGUI.memo)) then
         guiSetText (msgGUI.memo, messagesString)
    end
end

function sendSMS()
    local selected = guiGridListGetSelectedItem(msgGUI.gridlist)
    if(selected) then
        local player = guiGridListGetItemData(msgGUI.gridlist, selected, 1)
        if(isElement(player)) then
            local message = guiGetText(msgGUI.editMessage)
            triggerServerEvent("sendPM", localPlayer, player, message)
            guiSetText(msgGUI.editMessage, "")
        else
            exports.USGmsg:msg(apps.messages.messages.playerQuit, messages.color.alert.r,messages.color.alert.g,messages.color.alert.b) 
        end
    else
        exports.USGmsg:msg(apps.messages.messages.selectPlayer,messages.color.alert.r,messages.color.alert.g,messages.color.alert.b) 
    end
end


function msgsearchchange ()
    msgfillPlayerGrid()
end


addEvent("onRecievePM")
function onRecieveMessage(message)
    messagesString = "< "..getPlayerName(source)..": "..message.."\n\n"..messagesString
    if(msgGUI) then
        refreshMessages()
    end
end
addEventHandler("onRecievePM", root, onRecieveMessage)

addEvent("onSendPM")
function onSentMessage(target, message)
    messagesString = "> "..getPlayerName(target)..": "..message.."\n\n"..messagesString
    if(msgGUI) then
        refreshMessages()
    end
end
addEventHandler("onSendPM", root, onSentMessage)