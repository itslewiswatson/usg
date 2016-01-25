services = {
    {name="Police",id="police"},
    {name="Medic",id="medic"},
    {name="Mechanic",id="mechanic"},
}

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

messages = {}
	messages.color = {}
		messages.color.alert = {}
			messages.color.alert.r = 255
			messages.color.alert.g = 0
			messages.color.alert.b = 0
			
		messages.color.info = {}
			messages.color.info.r = 0
			messages.color.info.g = 255
			messages.color.info.b = 0
			
binds = {}
	binds.toggleUserPanel = {}
		binds.toggleUserPanel.key = "b"
		binds.toggleUserPanel.keyState = "down"
		
	binds.previousSelection = {}
		binds.previousSelection.key = ","
		binds.previousSelection.keyState = "down"
		
	binds.nextSelection = {}
		binds.nextSelection.key = "."
		binds.nextSelection.keyState = "down"
		
	binds.select = {}
		binds.select.key = "lalt"
		binds.select.keyState = "down"
		
	binds.toggleCursor = {}
		binds.toggleCursor.key = "ralt"
		binds.toggleCursor.keyState = "down"
		
	binds.closeAllApps = {}
		binds.closeAllApps.key = "lctrl"
		binds.closeAllApps.keyState = "down"