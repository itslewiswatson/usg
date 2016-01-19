local chatTabs = 
{
	{name="Main",cmd="say"},
	{name="Team",cmd="teamsay"},
	{name="Local",cmd="local"},
	{name="Support", cmd="support"},
	{name="Global",cmd="global"},
}


local chatGrid = {}
local inputChat = {}

local chatBoxGUI = {}

addEventHandler("onClientResourceStart", resourceRoot, function ()
	for i, chat in ipairs(chatBoxes) do
		table.insert(chatTabs, chat)
	end
	if(getResourceFromName("USGaccounts") and getResourceState(getResourceFromName("USGaccounts")) == "running" and exports.USGaccounts:isPlayerLoggedIn()) then
		setupGUI()
	end
end )

function setupGUI()
	createChatBoxes()
	exports.USGGUI:setVisible(chatBoxGUI.window, false)
end

function createChatBoxes()
	chatBoxGUI.window = exports.USGGUI:createWindow("center","center",730,500,false,"Chat boxes")
	chatBoxGUI.tabpanel = exports.USGGUI:createTabPanel("center",5,720,460,false,chatBoxGUI.window,tocolor(0,0,0,80))
	for i, chatTab in ipairs(chatTabs) do
		local tab = exports.USGGUI:addTab(chatBoxGUI.tabpanel, chatTab.name)
		local grid = exports.USGGUI:createGridList("center",10,710,390,false,tab)
		exports.USGGUI:gridlistAddColumn(grid, "Messages", 1.0)
		chatGrid[chatTab.name] = grid
		exports.USGGUI:createLabel(0,405,50,25,false,chatTab.cmd,tab)
		local input = exports.USGGUI:createEditBox(50, 405,660,25,false,"",tab)
		inputChat[input] = chatTab.cmd
		addEventHandler("onUSGGUIAccept", input, onChatSay,false)
	end
	chatBoxGUI.close = exports.USGGUI:createButton(655, 470, 70, 25, false, "Close", chatBoxGUI.window)
	addEventHandler("onUSGGUISClick", chatBoxGUI.close, closeChatBoxGUI,false)
	addEventHandler("onElementDestroyed", chatBoxGUI.window, setupGUI, false)
end

addEventHandler("onServerPlayerLogin", localPlayer,setupGUI)

function toggleChatBoxGUI()
	if(not isElement(chatBoxGUI.window)) then
		createChatBoxes()
		showCursor(true)
	elseif(exports.USGGUI:getVisible(chatBoxGUI.window)) then
		closeChatBoxGUI()
	else
		exports.USGGUI:setVisible(chatBoxGUI.window, true)
		showCursor(true)
	end
end
addCommandHandler("chat", toggleChatBoxGUI)
bindKey("j","down","chat")

function closeChatBoxGUI()
	exports.USGGUI:setVisible(chatBoxGUI.window, false)
	showCursor(false)
end

addEvent("USGchatsystem.onChatMessage", true)
function onAddChat(chat, message)
	local grid = chatGrid[chat]
	if(isElement(grid)) then
		local row = exports.USGGUI:gridlistAddRow(grid)
		exports.USGGUI:gridlistSetItemText(grid, row, 1, message)
	end
end
addEventHandler("USGchatsystem.onChatMessage", root, onAddChat)

function onChatSay()
	local cmd = inputChat[source]
	if(cmd) then
		local message = exports.USGGUI:getText(source)
		if(#(message:gsub(" ","")) > 0) then
			triggerServerEvent("USGchatsystem.outputChat", localPlayer, cmd, message)
			exports.USGGUI:setText(source, "")
		else
			exports.USGmsg:msg("You did not enter a message!", 255,0,0)
		end
	end
end