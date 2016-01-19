class 'gpsApp' ( "app" )
local locations

function gpsApp:gpsApp()
	app.app(self, "GPS", "images/apps/gps_icon.png")
	self.roomRestriction = "cnr"
	self.GUI = {}
end

function gpsApp:open()
	if(not isElement(self.GUI.scrollarea)) then
		self.GUI.scrollarea = exports.USGGUI:createScrollArea(screenWidth,screenHeight,PHONE_SCREEN_WIDTH-2, PHONE_SCREEN_HEIGHT-PHONE_TITLEBAR_HEIGHT-2, false)
		self.GUI.destination = exports.USGGUI:createLabel("center",0,PHONE_SCREEN_WIDTH-4,35,false,"Destination\nLos santos", self.GUI.scrollarea)
		self.GUI.remove = exports.USGGUI:createButton("center",40,PHONE_SCREEN_WIDTH-4-40,25,false,"Remove destination", self.GUI.scrollarea)
		addEventHandler("onUSGGUISClick", self.GUI.remove, function () GPSApp:removeDestination() end, false)
		self.GUI.markPlayer = exports.USGGUI:createButton("center",70,PHONE_SCREEN_WIDTH-4-40,25,false,"Mark player", self.GUI.scrollarea)
		addEventHandler("onUSGGUISClick", self.GUI.markPlayer, function () GPSApp:markPlayer() end, false)
		self.GUI.playerSearch = exports.USGGUI:createEditBox("center", 100, PHONE_SCREEN_WIDTH-4-30, 25, false, "", self.GUI.scrollarea)
		addEventHandler("onUSGGUIChange", self.GUI.playerSearch, function () GPSApp:onPlayerSearchChange() end, false)
		self.GUI.playerGrid = exports.USGGUI:createGridList("center", 130, PHONE_SCREEN_WIDTH-4-30, 120, false, self.GUI.scrollarea)
		exports.USGGUI:gridlistAddColumn(self.GUI.playerGrid, "Player", 1.0)
		self.GUI.fromMap = exports.USGGUI:createButton("center",255,PHONE_SCREEN_WIDTH-4-40,25,false,"From map...", self.GUI.scrollarea)
		addEventHandler("onUSGGUISClick", self.GUI.fromMap, function () GPSApp:pickFromMap() end, false)

		self.GUI.markLocation = exports.USGGUI:createButton("center",305,PHONE_SCREEN_WIDTH-4-40,25,false,"Mark location", self.GUI.scrollarea)
		addEventHandler("onUSGGUISClick", self.GUI.markLocation, function () GPSApp:markLocation() end, false)
		self.GUI.locationGrid = exports.USGGUI:createGridList("center", 335, PHONE_SCREEN_WIDTH-4-30, 180, false, self.GUI.scrollarea)
		exports.USGGUI:gridlistAddColumn(self.GUI.locationGrid, "Location", 1.0)
		
		Phone:addRelativeGUI(self, self.GUI.scrollarea, 1,1)
		self:fillLocationGrid()
	else
		exports.USGGUI:setVisible(self.GUI.scrollarea, true)
	end
	self:fillPlayerGrid()
	self:updateDestination()
end

function gpsApp:updateDestination()
	local destination = exports.USGcnr_gps:getDestination()
	local destinationName = "none"
	if(destination) then
		destinationName = destination.name or "Unknown"
	end
	exports.USGGUI:setText(self.GUI.destination, "Destination:\n"..destinationName)
end

function gpsApp:refresh()
	self:updateDestination()
	self:fillPlayerGrid()
end

function gpsApp:close()
	exports.USGGUI:setVisible(self.GUI.scrollarea, false)
	exports.USGGUI:gridlistClear(self.GUI.playerGrid)
end

function gpsApp:fillLocationGrid()
	exports.USGGUI:gridlistClear(self.GUI.locationGrid)
	local px,py,pz = getElementPosition(localPlayer)
	for type, typeLocations in pairs(locations) do
		local row = exports.USGGUI:gridlistAddRow(self.GUI.locationGrid)
		exports.USGGUI:gridlistSetItemText(self.GUI.locationGrid, row, 1, type)
	end
end

function gpsApp:fillPlayerGrid()
	exports.USGGUI:gridlistClear(self.GUI.playerGrid)
	local filter = exports.USGGUI:getText(self.GUI.playerSearch)
	for i, player in ipairs(getElementsByType("player")) do
		local name = getPlayerName(player)
		if(player ~= localPlayer and (filter == "" or string.find(name:lower(), filter:lower()))) then
			local row = exports.USGGUI:gridlistAddRow(self.GUI.playerGrid)
			exports.USGGUI:gridlistSetItemText(self.GUI.playerGrid, row, 1, name)
			exports.USGGUI:gridlistSetItemData(self.GUI.playerGrid, row, 1, player)
		end
	end
end

function gpsApp:onPlayerSearchChange()
	self:fillPlayerGrid()
end

function gpsApp:removeDestination()
	exports.USGcnr_gps:removeDestination()
end

function gpsApp:markPlayer()
	local selected = exports.USGGUI:gridlistGetSelectedItem(self.GUI.playerGrid)
	if(selected) then
		local player = exports.USGGUI:gridlistGetItemData(self.GUI.playerGrid, selected, 1)
		if(isElement(player)) then
			exports.USGcnr_gps:setDestination(getPlayerName(player), player)
			self:updateDestination()
		else
			exports.USGmsg:msg("This player has quit.", 255,0,0)		
		end
	else
		exports.USGmsg:msg("You did not select a player.", 255,0,0)
	end
end

function gpsApp:pickFromMap()
end

function gpsApp:markLocation()
	if(getElementInterior(localPlayer) ~= 0) then
		exports.USGmsg:msg("You can only set GPS when outside.", 255,0,0)
		return false
	end
	local selected = exports.USGGUI:gridlistGetSelectedItem(self.GUI.locationGrid)
	if(selected) then
		local locationType = exports.USGGUI:gridlistGetItemText(self.GUI.locationGrid, selected, 1)
		-- get closest location with this type
		local distance = false
		local closest = false
		local px,py,pz = getElementPosition(localPlayer)
		for i, location in ipairs(locations[locationType]) do
			local dist = getDistanceBetweenPoints2D(px,py,location.x,location.y)
			if(not closest or dist < distance) then
				closest = location
				distance = dist
			end
		end
		exports.USGcnr_gps:setDestination(exports.USGGUI:gridlistGetItemText(self.GUI.locationGrid, selected, 1), closest.x, closest.y, closest.z)
		self:updateDestination()
	else
		exports.USGmsg:msg("You did not select a location.", 255,0,0)
	end	
end

locations = {
	["Ammunation"] = {
		{x = 2153.5986328125, y = 943.96484375, z = 10.8203125},
	},
	["Police department"] = {
		{x = 2320.189453125, y = 2418.451171875, z = 10.470796585083}, -- LV
		{x = -1604.0625, y = 719.1123046875, z = 11.700479507446}, -- SF
		{x = 1537.74609375, y = -1671.3037109375, z = 13.546875}, -- LS
	},
	["Fuel station"] = {
		{x = 2200.775390625, y = 2473.2236328125, z = 10.547392845154},
		{x = 2120.6484375, y = 948.8623046875, z = 10.540092468262},
	},
}