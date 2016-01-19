class 'moneyApp' ( "app" )

function moneyApp:moneyApp()
	app.app(self, "Money", "images/apps/money_icon.png", false)
	self.roomRestriction = "cnr"
	self.GUI = {}
end

function moneyApp:open()
	if(not isElement(self.GUI.memo)) then
		local height = PHONE_SCREEN_HEIGHT-PHONE_TITLEBAR_HEIGHT
		self.GUI.amount = exports.USGGUI:createEditBox(screenWidth,screenHeight,PHONE_SCREEN_WIDTH-2,25,false,"")
		self.GUI.grid = exports.USGGUI:createGridList(screenWidth,screenHeight,PHONE_SCREEN_WIDTH-2,height-26-29-26,false,"")
		exports.USGGUI:gridlistAddColumn(self.GUI.grid, "Player", 1.0)
		self.GUI.search = exports.USGGUI:createEditBox(screenWidth,screenHeight,PHONE_SCREEN_WIDTH-2,25,false,"")
		addEventHandler("onUSGGUIChange", self.GUI.search, function () MoneyApp:onSearchChange() end, false)
		self.GUI.send = exports.USGGUI:createButton(screenWidth,screenHeight,PHONE_SCREEN_WIDTH-2,25,false,"Send amount")
		addEventHandler("onUSGGUISClick", self.GUI.send, function () MoneyApp:sendMoney() end, false)
		Phone:addRelativeGUI(self, self.GUI.grid, 1,29)
		Phone:addRelativeGUI(self, self.GUI.amount, 1, height-52)
		Phone:addRelativeGUI(self, self.GUI.search, 1,2)
		Phone:addRelativeGUI(self, self.GUI.send, 1, height-26)
	else
		for k, element in pairs(self.GUI) do
			if(isElement(element)) then
				exports.USGGUI:setVisible(element, true)
			end
		end
	end
	self:fillPlayerGrid()
end

function moneyApp:refresh()
	self:fillPlayerGrid()
end

function moneyApp:close()
	for k, element in pairs(self.GUI) do
		if(isElement(element)) then
			exports.USGGUI:setVisible(element, false)
		end
	end
	exports.USGGUI:gridlistClear(self.GUI.grid)
end

function moneyApp:fillPlayerGrid()
	exports.USGGUI:gridlistClear(self.GUI.grid)
	local filter = exports.USGGUI:getText(self.GUI.search)
	filter = exports.USG:escapeString(filter)
	for i, player in ipairs(getElementsByType("player")) do
		local name = getPlayerName(player)
		if(player ~= localPlayer and (filter == "" or string.find(name:lower(), filter:lower()))
		and exports.USGrooms:getPlayerRoom(player) == self.roomRestriction) then
			local row = exports.USGGUI:gridlistAddRow(self.GUI.grid)
			exports.USGGUI:gridlistSetItemText(self.GUI.grid, row, 1, name)
			exports.USGGUI:gridlistSetItemData(self.GUI.grid, row, 1, player)
		end
	end
end

function moneyApp:onSearchChange()
	self:fillPlayerGrid()
end

function moneyApp:sendMoney()
	local selected = exports.USGGUI:gridlistGetSelectedItem(self.GUI.grid)
	if(selected) then
		local player = exports.USGGUI:gridlistGetItemData(self.GUI.grid, selected, 1)
		if(isElement(player)) then
			local amount = tonumber(exports.USGGUI:getText(self.GUI.amount))
			if(amount and amount > 0) then
				triggerServerEvent("USGphone.sendMoney", player, amount)
				exports.USGGUI:setText(self.GUI.amount, "")
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