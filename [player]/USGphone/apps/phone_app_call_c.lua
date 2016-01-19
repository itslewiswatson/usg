class 'phoneApp' 'app'

local services = {
	{name="Police",id="police"},
	{name="Medic",id="medic"},
	{name="Mechanic",id="mechanic"},
}

function phoneApp:phoneApp()
	app.app(self, "Phone","images/apps/call_icon.png", true)
	self.roomRestriction = "cnr"
	self.GUI = {}
end

function phoneApp:open()
	if(not isElement(self.GUI.grid)) then
		self.GUI.grid = exports.USGGUI:createGridList(screenWidth, screenHeight, PHONE_SCREEN_WIDTH,PHONE_SCREEN_HEIGHT-PHONE_TITLEBAR_HEIGHT-33, false)
		exports.USGGUI:gridlistAddColumn(self.GUI.grid, "Service", 1.0)
		Phone:addRelativeGUI(self, self.GUI.grid, 0,0)
		self.GUI.call = exports.USGGUI:createButton(screenWidth, screenHeight, PHONE_SCREEN_WIDTH-2, 25, false, "Call")
		Phone:addRelativeGUI(self, self.GUI.call, 1,PHONE_SCREEN_HEIGHT-PHONE_TITLEBAR_HEIGHT-27)
		addEventHandler("onUSGGUISClick", self.GUI.call, function () PhoneApp:onCallClick() end, false)
		for i, service in ipairs(services) do
			local row = exports.USGGUI:gridlistAddRow(self.GUI.grid)
			exports.USGGUI:gridlistSetItemText(self.GUI.grid, row, 1, service.name)
			exports.USGGUI:gridlistSetItemData(self.GUI.grid, row, 1, i)
		end
	else
		for k, element in pairs(self.GUI) do
			exports.USGGUI:setVisible(element, true)
		end
	end
end

function phoneApp:close()
	for k, element in pairs(self.GUI) do
		exports.USGGUI:setVisible(element, false)
	end
end

function phoneApp:onCallClick()
	local selected = exports.USGGUI:gridlistGetSelectedItem(self.GUI.grid)
	if(selected) then
		local id = exports.USGGUI:gridlistGetItemData(self.GUI.grid, selected, 1)
		triggerServerEvent("USGcnr_phone.callService", localPlayer, services[id].id, services[id].name)
	else
		exports.USGmsg:msg("You did not select a service from the list.", 255, 0, 0)
	end
end