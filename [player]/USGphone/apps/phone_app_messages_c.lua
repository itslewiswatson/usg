class 'messageApp' ( "app" )
local messages = ""

function messageApp:messageApp()
	app.app(self, "Messages", "images/apps/messages_icon.png", true)
	self.GUI = {}
end

function messageApp:open()
	if(not isElement(self.GUI.memo)) then
		local height = PHONE_SCREEN_HEIGHT-PHONE_TITLEBAR_HEIGHT
		self.GUI.memo = exports.USGGUI:createMemo(screenWidth,screenHeight,PHONE_SCREEN_WIDTH-2,0.4*height,false,messages)
		exports.USGGUI:setProperty(self.GUI.memo, "readOnly", true)
		self.GUI.input = exports.USGGUI:createEditBox(screenWidth,screenHeight,PHONE_SCREEN_WIDTH-2,25,false,"")
		addEventHandler("onUSGGUIAccept", self.GUI.input, function () MessageApp:sendSMS() end, false)
		self.GUI.grid = exports.USGGUI:createGridList(screenWidth,screenHeight,PHONE_SCREEN_WIDTH-2,0.6*height-58,false,"")
		exports.USGGUI:gridlistAddColumn(self.GUI.grid, "Player", 1.0)
		self.GUI.search = exports.USGGUI:createEditBox(screenWidth,screenHeight,PHONE_SCREEN_WIDTH-2,25,false,"")
		addEventHandler("onUSGGUIChange", self.GUI.search, function () MessageApp:onSearchChange() end, false)
		Phone:addRelativeGUI(self, self.GUI.memo, 1,0)
		Phone:addRelativeGUI(self, self.GUI.grid, 1,29+0.4*height)
		Phone:addRelativeGUI(self, self.GUI.input, 1, height-26)
		Phone:addRelativeGUI(self, self.GUI.search, 1,2+0.4*height)
	else
		for k, element in pairs(self.GUI) do
			if(isElement(element)) then
				exports.USGGUI:setVisible(element, true)
			end
		end
	end
	self:fillPlayerGrid()
end

function messageApp:refresh()
	self:fillPlayerGrid()
end

function messageApp:close()
	for k, element in pairs(self.GUI) do
		if(isElement(element)) then
			exports.USGGUI:setVisible(element, false)
		end
	end
	exports.USGGUI:gridlistClear(self.GUI.grid)
end

function messageApp:fillPlayerGrid()
	exports.USGGUI:gridlistClear(self.GUI.grid)
	local filter = exports.USGGUI:getText(self.GUI.search)
	for i, player in ipairs(getElementsByType("player")) do
		local name = getPlayerName(player)
		if(player ~= localPlayer and (filter == "" or string.find(name:lower(), filter:lower()))) then
			local row = exports.USGGUI:gridlistAddRow(self.GUI.grid)
			exports.USGGUI:gridlistSetItemText(self.GUI.grid, row, 1, name)
			exports.USGGUI:gridlistSetItemData(self.GUI.grid, row, 1, player)
		end
	end
end

function messageApp:onSearchChange()
	self:fillPlayerGrid()
end

function messageApp:refreshMessages()
	if(isElement(self.GUI.memo)) then
		exports.USGGUI:setText(self.GUI.memo, messages)
	end
end

function messageApp:sendSMS()
	local selected = exports.USGGUI:gridlistGetSelectedItem(self.GUI.grid)
	if(selected) then
		local player = exports.USGGUI:gridlistGetItemData(self.GUI.grid, selected, 1)
		if(isElement(player)) then
			local message = exports.USGGUI:getText(self.GUI.input)
			triggerServerEvent("sendPM", localPlayer, player, message)
			exports.USGGUI:setText(self.GUI.input, "")
		else
			exports.USGmsg:msg("This player has quit.", 255,0,0)
		end
	else
		exports.USGmsg:msg("You did not select a player.", 255,0,0)
	end
end

addEvent("onRecievePM")
function onRecieveMessage(message)
	messages = "< "..getPlayerName(source)..": "..message.."\n\n"..messages
	if(MessageApp) then
		MessageApp:refreshMessages()
	end
end
addEventHandler("onRecievePM", root, onRecieveMessage)

addEvent("onSendPM")
function onSentMessage(target, message)
	messages = "> "..getPlayerName(target)..": "..message.."\n\n"..messages
	if(MessageApp) then
		MessageApp:refreshMessages()
	end
end
addEventHandler("onSendPM", root, onSentMessage)