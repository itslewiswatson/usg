local hudTextures = {"*icon*","fist","radar*","font1"}

function isResourceReady(name)
	return getResourceFromName(name) and getResourceState(getResourceFromName(name)) == "running"
end

-- *** initializing and unloading ***
function initJob()
	if(isResourceReady("USGrooms") and exports.USGrooms:getPlayerRoom() == "cnr" 
	and isResourceReady("USGcnr_jobs")) then
		exports.USGcnr_jobs:addJob(jobID, jobType, occupation, jobDescription, jobMarkers, jobSkins, jobVehicleMarkers,jobBlip)
		if(exports.USGcnr_jobs:getPlayerJob(localPlayer) == jobID and not onTheJob) then
			startJob()
		end
	end
end

addEvent("onPlayerJoinRoom", true)
addEventHandler("onPlayerJoinRoom", localPlayer, 
	function (room)
		if(room == "cnr") then
			initJob()
			if(isResourceReady("USGcnr_inventory")) then
				exports.USGcnr_inventory:create("shortspikes","Short spike strips", ":USGcnr_job_airsupport/spike.png")
				exports.USGcnr_inventory:create("longspikes","Long spike strips", ":USGcnr_job_airsupport/spike.png")
			end
		end
	end
)

addEventHandler("onClientResourceStart", root,
	function (res) -- init job if thisResource started, or if USGcnr_jobs (re)started
		if(res == resource or res == getResourceFromName("USGcnr_jobs")) then
			initJob()
		end
		if(((res == resource and isResourceReady("USGcnr_inventory") and isResourceReady("USGrooms"))
		or res == getResourceFromName("USGcnr_inventory")) and exports.USGrooms:getPlayerRoom() == "cnr") then
			exports.USGcnr_inventory:create("shortspikes","Short spike strips", ":USGcnr_job_airsupport/spike.png")
			exports.USGcnr_inventory:create("longspikes","Long spike strips", ":USGcnr_job_airsupport/spike.png")
		end		
	end
)

-- *** job loading ***
addEvent("onPlayerChangeJob", true)
local onTheJob = false
function onChangeJob(ID)
	if(ID == jobID and not onTheJob) then
		startJob()
	elseif(ID ~= jobID and onTheJob) then
		stopJob()
	end
end
addEventHandler("onPlayerChangeJob", localPlayer, onChangeJob)

addEvent("onPlayerExitRoom", true)
addEventHandler("onPlayerExitRoom", localPlayer, 
	function (prevRoom)
		if(prevRoom == "cnr" and onTheJob) then
			stopJob()
		end
	end
)

addEventHandler("onClientResourceStop", resourceRoot,
	function ()
		if(onTheJob) then
			stopJob()
		end
	end
)

local cameraView = false
local thermalState = false

function startJob()
	onTheJob = true
	initThermal()
	bindKey("space", "down", toggleThermalView)
	bindKey("lctrl", "down", toggleCameraView)
end

function stopJob()
	onTheJob = false
	if(thermalState) then
		stopThermal()
	end
	if(cameraView) then
		stopCameraView()
	end	
	destroyElement(coldShader)
	destroyElement(pedShader)
	destroyElement(vehicleShader)
	unbindKey("space", "down", toggleThermalView)
	unbindKey("lctrl", "down", toggleCameraView)
end

-- *** the job ***
function getPointFromDistanceRotation(x, y, dist, angle)
    local a = math.rad(angle + 90);
    local dx = math.cos(a) * dist;
    local dy = math.sin(a) * dist;
    return x+dx, y+dy;
end

function initThermal()
	coldShader = dxCreateShader("thermal-cold.fx",0,0,false,"world,object")
	pedShader = dxCreateShader("thermal-hot_ped.fx", 0, 0, false, "ped")
	vehicleShader = dxCreateShader("thermal-hot_vehicle.fx", 0, 0, false, "vehicle")
end

function startThermal()
	local pVehicle = getPedOccupiedVehicle(localPlayer)
	if(cameraView and not thermalState and pVehicle and getElementModel(pVehicle) == 497) then
		thermalState = true
		engineApplyShaderToWorldTexture(coldShader, "*")
		engineApplyShaderToWorldTexture(pedShader, "*")
		engineApplyShaderToWorldTexture(vehicleShader, "*")
		-- remove all hud textures
		for i, tex in ipairs(hudTextures) do
			engineRemoveShaderFromWorldTexture ( coldShader, tex )
		end
	end
end

function stopThermal()
	thermalState = false
	engineRemoveShaderFromWorldTexture(coldShader, "*")
	engineRemoveShaderFromWorldTexture(pedShader, "*")
	engineRemoveShaderFromWorldTexture(vehicleShader, "*")
end

function toggleThermalView()
	if(thermalState) then
		stopThermal()
	else
		startThermal()
	end
end

local cameraMode = 0
local cameraPitchOffset = 0
local cameraRotation = 0
local cameraYOffset = 0
local cameraObject

function startCameraView()
	local pVehicle = getPedOccupiedVehicle(localPlayer)
	if(not cameraView and pVehicle and getVehicleController(pVehicle) ~= localPlayer and getElementModel(pVehicle) == 497) then
		cameraView = true
		cameraViewVehicle = pVehicle
		cameraObject = createObject(1616, 0,0,0)
		setElementAlpha(cameraObject, 0)
		attachElements(cameraObject, cameraViewVehicle, 0, 0, -1, 210, 0, 230)
		addEventHandler("onClientRender", root, renderCameraView)
		addEventHandler("onClientPlayerWasted", localPlayer, stopCameraView)
		addEventHandler("onClientPlayerVehicleExit", localPlayer, stopCameraView)
		addEventHandler("onClientElementDestroy", cameraViewVehicle, stopCameraView)
		bindKey("lshift", "down", nextCameraMode)
	end
end

function stopCameraView()
	if(cameraView) then
		cameraView = false
		setCameraTarget(localPlayer)
		removeEventHandler("onClientPlayerVehicleExit", localPlayer, stopCameraView)
		removeEventHandler("onClientPlayerWasted", localPlayer, stopCameraView)
		removeEventHandler("onClientElementDestroy", cameraViewVehicle, stopCameraView)
		removeEventHandler("onClientRender", root, renderCameraView)
		unbindKey("lshift", "down", nextCameraMode)
		destroyElement(cameraObject)
		cameraViewVehicle = nil	
		cameraMode = 0
		cameraPitchOffset = 0
		cameraRotation = 0
		cameraYOffset = 0
		if(thermalState) then
			stopThermal()
		end
	end
end

local scannerSize = 300
local screenWidth, screenHeight = guiGetScreenSize()
local scannerX, scannerY = (screenWidth-scannerSize)/2, (screenHeight-scannerSize)/2
local color_red, color_white, color_transblack, color_blue = tocolor(255,0,0), tocolor(255,255,255), tocolor(0,0,0,150), tocolor(80,80,220)

local controlUpdateTick = 0
function updateCameraControls()
	local tick = getTickCount()
	if(tick-controlUpdateTick > 20) then
		controlUpdateTick = tick
		if(getKeyState("arrow_u")) then
			cameraPitchOffset = math.min(10, cameraPitchOffset+1.3)
		elseif(getKeyState("arrow_d")) then
			cameraPitchOffset = math.max(-90, cameraPitchOffset-1.3)
		elseif(getKeyState("arrow_l")) then
			cameraRotation = cameraRotation+1
			if(cameraRotation > 360) then
				cameraRotation = cameraRotation-360
			end
		elseif(getKeyState("arrow_r")) then
			cameraRotation = cameraRotation-1
			if(cameraRotation < 0) then
				cameraRotation = cameraRotation+360			
			end
		end
	end
end

function renderCameraView()
	if(cameraViewVehicle) then
		local rx, ry, rz = getElementRotation(cameraViewVehicle)
		local x, y, z = getElementPosition(cameraObject)
		local lz = z+math.sin(math.rad(rx+cameraPitchOffset)) * 100
		if(cameraMode == 1 or cameraMode == 3) then -- only use cameraRotation
			rz = 0
		end
		if(cameraMode == 2 or cameraMode == 3) then
			lz = z+math.sin(math.rad(cameraPitchOffset)) * 100
		end
		local lx, ly = getPointFromDistanceRotation(x, y, 100, rz+cameraRotation)
		setCameraMatrix(x, y, z, lx, ly, lz)
		-- controls
		updateCameraControls()
		-- scanner
		local target
		local targetTotalOffset
		dxDrawRectangle(0, 0, scannerX, screenHeight, color_transblack)
		dxDrawRectangle(scannerX+scannerSize, 0, screenWidth-scannerX-scannerSize, screenHeight, color_transblack)
		dxDrawRectangle(scannerX, 0, scannerSize, scannerY, color_transblack)
		dxDrawRectangle(scannerX, scannerY+scannerSize, scannerSize, screenHeight-scannerY-scannerSize, color_transblack)
		dxDrawLine(scannerX, scannerY, scannerX+scannerSize, scannerY)
		dxDrawLine(scannerX+scannerSize, scannerY, scannerX+scannerSize, scannerY+scannerSize)
		dxDrawLine(scannerX, scannerY+scannerSize, scannerX+scannerSize, scannerY+scannerSize)
		dxDrawLine(scannerX, scannerY, scannerX, scannerY+scannerSize)
		for i, vehicle in ipairs(getElementsByType("vehicle", root, true)) do
			if(isElementOnScreen(vehicle)) then
				local px, py, pz = getElementPosition(vehicle)
				local sx, sy = getScreenFromWorldPosition(px, py, pz)
				if(sx and sy and sx > scannerX and sy > scannerY and sx < scannerX+scannerSize and sy < scannerY+scannerSize) then
					local totalOffset = math.abs(sx-scannerX+scannerSize*0.5)+math.abs(sy-scannerY+scannerSize*0.5)
					if(not targetTotalOffset or totalOffset < targetTotalOffset) then
						target = vehicle
						targetTotalOffset = totalOffset
					end
				end
			end
		end
		for i, player in ipairs(getElementsByType("player", root, true)) do
			if(isElementOnScreen(player) and exports.USGrooms:getPlayerRoom(player) == "cnr") then
				local px, py, pz = getElementPosition(player)
				local sx, sy = getScreenFromWorldPosition(px, py, pz)
				if(sx and sy and sx > scannerX and sy > scannerY and sx < scannerX+scannerSize and sy < scannerY+scannerSize) then
					local totalOffset = math.abs(sx-scannerX+scannerSize*0.5)+math.abs(sy-scannerY+scannerSize*0.5)
					if(not targetTotalOffset or totalOffset < targetTotalOffset) then
						target = player
						targetTotalOffset = totalOffset
					end
				end
			end
		end
		-- draw scanner info
		dxDrawLine(0, scannerY+math.floor(scannerSize/2), screenWidth, scannerY+math.floor(scannerSize/2), target and color_red or color_white)
		dxDrawLine(scannerX+math.floor(scannerSize/2), 0, scannerX+math.floor(scannerSize/2), screenHeight, target and color_red or color_white)
		if(target and getElementType(target) == "vehicle") then
			local occupants = getVehicleOccupantsList(target)
			dxDrawText("OCCUPANTS: "..#occupants, scannerX-230, scannerY, scannerX-15, scannerY+scannerSize,
				color_white, 0.7, "bankgothic", "right")
			for i, occupant in ipairs(occupants) do
				local y = scannerY+(i-1)*40
				dxDrawText("SUSPECT: "..getPlayerName(occupant), scannerX+scannerSize+15, y, screenWidth, y+20, getPlayerScanColor(occupant), 0.5, "bankgothic")
				dxDrawText("WANTED LEVEL: "..exports.USGcnr_wanted:getPlayerWantedLevel(occupant), 
					scannerX+scannerSize+15, y+20, screenWidth, y+40, getPlayerScanColor(occupant), 0.35, "bankgothic")
			end
		else
			dxDrawText("TARGET: "..(target and getPlayerName(target) or "NONE"), scannerX-230, scannerY, scannerX-15, scannerY+scannerSize,
				target and getPlayerScanColor(target) or color_white, 0.7, "bankgothic", "right")
			if(target) then
				dxDrawText("WANTED LEVEL: "..exports.USGcnr_wanted:getPlayerWantedLevel(target), scannerX-230, scannerY+30, 
					scannerX-15, scannerY+scannerSize, getPlayerScanColor(target), 0.5, "bankgothic", "right")
			end
		end
		dxDrawText("MODE: "..cameraMode, scannerX, scannerY-20, screenWidth, scannerY, color_white, 0.6, "bankgothic")
	end
end

function getPlayerScanColor(player)
	if(exports.USGcnr_wanted:getPlayerWantedLevel(player) > 0) then
		return color_red
	elseif(exports.USGcnr_jobs:getPlayerJobType(player) == "police") then
		return color_blue
	end
	return color_white
end

function nextCameraMode()
	local newMode = cameraMode + 1
	if(newMode > 3) then
		newMode = 0
	end
	setCameraMode(newMode)
end

function toggleCameraView()
	if(cameraView) then
		stopCameraView()
	else
		startCameraView()
	end
end

function setCameraMode(mode)
	local rx, ry, rz = getElementRotation(cameraViewVehicle)
	if(mode == 3 or mode == 1) then
		cameraRotation = rz
	end
	if(mode == 3 or mode == 2) then
		cameraPitchOffset = 0
	end
	if(mode == 0) then
		cameraPitchOffset = 0
		cameraRotation = 0
	end
	if(cameraMode == 1 or cameraMode == 3) then -- reset rotation
		cameraRotation = 0
	end
	if(cameraMode == 2 or cameraMode == 3) then
		cameraPitchOffset = 0
	end
	cameraMode = mode
end

function getVehicleOccupantsList(vehicle)
	local rOccupants = getVehicleOccupants(vehicle)
	local occupants = {}
	for k, occupant in pairs(rOccupants) do
		if(occupant and getElementType(occupant) == "player" and exports.USGrooms:getPlayerRoom(occupant) == "cnr") then
			table.insert(occupants, occupant)
		end
	end
	return occupants
end
-- ** spikes **
addCommandHandler("spike",
	function (cmd, type)
		if(exports.USGcnr_jobs:getPlayerJob() ~= jobID) then
			exports.USGmsg:msg("Only air support officers can drop spike strips!", 255, 0, 0)
			return
		end
		local type = tonumber(type)
		if(not type or (type < 1 and type > 2)) then
			exports.USGmsg:msg("Syntax: /spike <type 1-2>", 255, 0, 0)
			return
		end
		local vehicle = getPedOccupiedVehicle(localPlayer)
		if(not vehicle or getElementModel(vehicle) ~= 497) then
			exports.USGmsg:msg("You need to be in the police helicopter to drop a spike strip!", 255, 0, 0)
			return
		end
		local x, y, z = getElementPosition(localPlayer)
		local groundZ = getGroundPosition(x,y,z+1)
		local rx, ry, rz = getElementRotation(vehicle)
		triggerServerEvent("USGcnr_job_airsupport.dropSpike", localPlayer, type, x, y, z, groundZ, rz+90)
	end
)