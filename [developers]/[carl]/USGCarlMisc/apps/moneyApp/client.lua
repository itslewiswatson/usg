local moneyGUI = {}

addEventHandler("onClientResourceStart", resourceRoot,
    function()
        moneyGUI.window = guiCreateWindow(0.77, 0.24, 0.22, 0.51, apps.money.name, true)
        guiWindowSetSizable(moneyGUI.window, false)

        guiCreateLabel(17, 26, 286, 22, "Player Name:", false, moneyGUI.window)
        moneyGUI.editPlayer = guiCreateEdit(16, 51, 287, 28, "", false, moneyGUI.window)
        moneyGUI.gridlistPlayer = guiCreateGridList(0.05, 0.22, 0.92, 0.49, true, moneyGUI.window)
        guiGridListAddColumn(moneyGUI.gridlistPlayer, "Player", 0.9)
        moneyGUI.label = guiCreateLabel(0.06, 0.74, 0.91, 0.05, "Money Amount:", true, moneyGUI.window)
        guiLabelSetVerticalAlign(moneyGUI.label, "center")
        moneyGUI.editAmount = guiCreateEdit(0.05, 0.80, 0.29, 0.07, "", true, moneyGUI.window)
        moneyGUI.buttonSend = guiCreateButton(0.35, 0.90, 0.32, 0.07, "Send Money", true, moneyGUI.window)
        guiSetProperty(moneyGUI.buttonSend, "NormalTextColour", "FFAAAAAA")    
		
		addEventHandler("onClientGUIChanged", moneyGUI.editPlayer,moneyfillPlayerGrid, false)
		addEventHandler("onClientGUIClick", moneyGUI.buttonSend, sendMoney, false)
		
		guiSetVisible(moneyGUI.window, false)
    end
)

function sendMoney()
    local selected = guiGridListGetSelectedItem(moneyGUI.gridlistPlayer)
    if(selected) then
    local player = guiGridListGetItemData(moneyGUI.gridlistPlayer, selected, 1)
        if(isElement(player)) then
            local amount = tonumber(guiGetText(moneyGUI.editAmount))
            if(amount and amount > 0) then
            triggerServerEvent("testing.sendMoney", player, amount)
                guiSetText(moneyGUI.editAmount, "")
            else
                exports.USGmsg:msg(apps.money.messages.invalidAmount, messages.color.alert.r, messages.color.alert.g, messages.color.alert.b)
            end
        else
            exports.USGmsg:msg(apps.money.messages.playerQuit,  messages.color.alert.r, messages.color.alert.g, messages.color.alert.b)
        end
    else
        exports.USGmsg:msg(apps.money.messages.selectPlayer,  messages.color.alert.r, messages.color.alert.g, messages.color.alert.b)
    end
end

local function showMoneyGUI()
if(not exports.USGaccounts:isPlayerLoggedIn()) then return end
	if(guiGetVisible(moneyGUI.window) == false)then
		guiSetInputMode("no_binds_when_editing")
		guiSetVisible ( moneyGUI.window, true )
		moneyfillPlayerGrid()
	end
end

addEvent(apps.money.event,true)
addEventHandler(apps.money.event,root,showMoneyGUI)

local function hideMoneyGUI()
	if(guiGetVisible(moneyGUI.window) == true)then
		guiSetVisible ( moneyGUI.window, false )
		showCursor(false)
	end
end

bindKey( binds.closeAllApps.key, binds.closeAllApps.keyState,hideMoneyGUI)


function moneyfillPlayerGrid()
    guiGridListClear ( moneyGUI.gridlistPlayer )
    local filter = guiGetText(moneyGUI.editPlayer)
    for i, player in ipairs(getElementsByType("player")) do
        local name = getPlayerName(player)
        if(player ~= localPlayer and (filter == "" or string.find(name:lower(), filter:lower()))) then
        local row = guiGridListAddRow ( moneyGUI.gridlistPlayer )
            guiGridListSetItemText(moneyGUI.gridlistPlayer, row, 1, name, false, false)
            guiGridListSetItemData(moneyGUI.gridlistPlayer, row, 1, player)
        end
    end
end