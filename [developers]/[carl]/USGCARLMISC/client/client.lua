
local showing = false
local selectedApp = nil
local selectedID = nil

local function tableSize(tab)
    local length = 0
    for _ in pairs(tab) do length = length + 1 end
    return length
end

local function selectApp(id)
	selectedID = id
	if(selectedApp)then
		selectedApp.isSelected = false
	end
	selectedApp = appsIDs[id]
	selectedApp.isSelected = true
end

local function selectPrevious()
	local previousID = selectedID - 1
	if(previousID < 1)then
		selectApp(tableSize(apps))
	else
		selectApp(previousID)
	end
end

local function selectNext()
	local nextID = selectedID + 1
	if(nextID > tableSize(apps))then
		selectApp(1)
	else
		selectApp(nextID)
	end
end

local function selectEnter()
	
end

local function processInput(_,_,action)
	if(showing)then
		if(action == "left")then
			selectPrevious()
		elseif(action == "right")then
			selectNext()
		elseif(action == "select")then
			selectEnter()
		else
			outputChatBox("There was an error with th 3D panel plz tell Carl")
		end
	end	
end

local function render()
	local playerRoom = exports.USGrooms:getPlayerRoom(localPlayer)
	local x,y,z = getElementPosition(localPlayer)
	local Mult = 1
	
		if(getPedOccupiedVehicle (localPlayer))then
			local vehicle = getPedOccupiedVehicle (localPlayer)
			x,y,z = getElementPosition(vehicle)
			
			if(vehicles[getVehicleName(vehicle)])then
				local vehicleData = vehicles[getVehicleName(vehicle)]
				Mult = vehicleData.Mult
			end
			
		end
		
	--[[
	if(playerRoom == "cnr" or apps.account.allRooms)then
		dxDrawMaterialLine3D ( x + apps.account.position.x * Mult,		y + apps.account.position.y * Mult,	z + apps.account.position.z * Mult + apps.account.size.default * Mult,		x + apps.account.position.x * Mult,	y + apps.account.position.y * Mult,	z + apps.account.position.z * Mult,	apps.account.icon,	apps.account.size.default * Mult	)
	end
	if(playerRoom == "cnr" or apps.call.allRooms)then
		dxDrawMaterialLine3D ( x + apps.call.position.x * Mult,		y + apps.call.position.y * Mult,		z + apps.call.position.z * Mult + apps.call.size.default * Mult,			x + apps.call.position.x * Mult,		y + apps.call.position.y * Mult,		z + apps.call.position.z * Mult,		apps.call.icon,		apps.call.size.default * Mult		)
	end
	if(playerRoom == "cnr" or apps.gps.allRooms)then
		dxDrawMaterialLine3D ( x + apps.gps.position.x * Mult,			y + apps.gps.position.y * Mult,		z + apps.gps.position.z * Mult + apps.gps.size.default * Mult,				x + apps.gps.position.x * Mult,	 	y + apps.gps.position.y * Mult,		z + apps.gps.position.z * Mult,		apps.gps.icon,		apps.gps.size.default * Mult		)
	end
	if(playerRoom == "cnr" or apps.music.allRooms)then
		dxDrawMaterialLine3D ( x + apps.music.position.x * Mult,		y + apps.music.position.y * Mult,		z + apps.music.position.z * Mult + apps.music.size.default * Mult,			x + apps.music.position.x * Mult, 		y + apps.music.position.y * Mult,		z + apps.music.position.z * Mult,		apps.music.icon,	apps.music.size.default * Mult		)
	end
	if(playerRoom == "cnr" or apps.weapons.allRooms)then
		dxDrawMaterialLine3D ( x + apps.weapons.position.x * Mult,		y + apps.weapons.position.y * Mult,	z + apps.weapons.position.z * Mult + apps.weapons.size.default * Mult,		x + apps.weapons.position.x * Mult,	y + apps.weapons.position.y * Mult,	z + apps.weapons.position.z * Mult,	apps.weapons.icon,	apps.weapons.size.default * Mult	)
	end
	if(playerRoom == "cnr" or apps.messages.allRooms)then
		dxDrawMaterialLine3D ( x + apps.messages.position.x * Mult,	y + apps.messages.position.y * Mult,	z + apps.messages.position.z * Mult + apps.messages.size.default * Mult,	x + apps.messages.position.x * Mult,	y + apps.messages.position.y * Mult,	z + apps.messages.position.z * Mult,	apps.messages.icon,	apps.messages.size.default * Mult	)
	end
	if(playerRoom == "cnr" or apps.money.allRooms)then
		dxDrawMaterialLine3D ( x + apps.money.position.x * Mult,		y + apps.money.position.y * Mult,		z + apps.money.position.z * Mult + apps.money.size.default * Mult,			x + apps.money.position.x * Mult,		y + apps.money.position.y * Mult,		z + apps.money.position.z * Mult,		apps.money.icon,	apps.money.size.default * Mult		)
	end	]]

	for k,v in pairs(appsIDs)do
		if(playerRoom == "cnr" or v.allRooms)then
			if(v.isSelected)then
			dxDrawMaterialLine3D ( x + v.position.x * Mult,		y + v.position.y * Mult,	z + v.position.z * Mult + v.size.selected * Mult,		x + v.position.x * Mult,	y + v.position.y * Mult,	z + v.position.z * Mult,	v.icon,	v.size.selected * Mult	)
			else
			dxDrawMaterialLine3D ( x + v.position.x * Mult,		y + v.position.y * Mult,	z + v.position.z * Mult + v.size.default * Mult,		x + v.position.x * Mult,	y + v.position.y * Mult,	z + v.position.z * Mult,	v.icon,	v.size.default * Mult	)
			end
		end
	end
		
end

local function toggle()
	if(showing)then
		showing = false
		removeEventHandler("onClientRender", root,render)
		selectedID = nil
	else
		showing = true
		addEventHandler("onClientRender", root,render)
		selectApp(1)
	end
end

bindKey ( "b", "down", toggle)
bindKey(",","down",processInput,"left")
bindKey(".","down",processInput,"right")
bindKey("lalt","down",processInput,"select")