-- CHAT ZONES
chatZonesData =
{ -- leave out LV and generally assume it is LV if unsure
	{name = "SF", -750, 500, -3200, -3200, 50, -3200, 50, -1537,-69.51953125, -579.8037109375, -955.9189453125, -276.3437, -995.451171875, 1094.0693359375, 
		-2665.94140625, 2163.9892578125, -3200, 2163.9892, -3200, -3200},
	{name = "LS", 1500,1500, 50,-3200,3200, -3200, 3200, 408, 1085.107421875, 586.486328125, -985.46484375, 301.1904296875,
		-955.9189453125, -276.3437, -69.51953125, -579.8037109375, 50, -1537, 50,-3200}
}

chatZoneCols = {}

function createChatZones()
	for _,zone in ipairs(chatZonesData) do
		local col = createColPolygon(unpack(zone))
		table.insert(chatZoneCols,col)
	end
end
addEventHandler("onResourceStart",resourceRoot,createChatZones)
addEventHandler("onClientResourceStart",resourceRoot,createChatZones)
