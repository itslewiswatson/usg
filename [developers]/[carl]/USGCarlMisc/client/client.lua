
local showing = false
local selectedApp = nil
local selectedID = nil

local function tableSize(tab)
    local length = 0
    for _ in pairs(tab) do length = length + 1 end
    return length
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

local function enterAppCurrentlyInUse(app)
	triggerEvent ( app.event, root)
	outputChatBox(app.event)
	toggle()
end


local function selectEnter()
	enterAppCurrentlyInUse(selectedApp)
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


bindKey ( "b", "down", toggle)
bindKey(",","down",processInput,"left")
bindKey(".","down",processInput,"right")
bindKey("lalt","down",processInput,"select")