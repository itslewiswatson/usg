_showCursor = showCursor
local cursorStates = {}


function showCursor(k, state)
	cursorStates[k] = state
	for k, cState in pairs(cursorStates) do
		if(cState ~= state and state == false) then
			return 
		end
	end
	_showCursor(state)
end

local screenWidth, screenHeight = guiGetScreenSize()
currentID = false
local currentPickup = false
local currentInt = false
local radarOriginalStart = 630
local radarStart

addEvent("onHousePickupHit", true)
addEvent("onHousePickupLeave", true)
function onPickupHit(houseID)
	if(isPedInVehicle(localPlayer)) then return end
	local new = currentID == false
	currentID = houseID
	currentPickup = source
	currentInt = getElementInterior(localPlayer)
	if(new) then
		calculatePosition()
		addEventHandler("onClientRender", root, renderCurrentHouse)
	end
end
addEventHandler("onHousePickupHit", root, onPickupHit)

function calculatePosition()
	-- calculate radar start
	local graphicStatus = dxGetStatus()
	if(not graphicStatus.SettingHUDMatchAspectRatio) then
		radarStart = 0.75*screenHeight
	else
		local targetRatio = screenWidth/screenHeight
		if(graphicStatus.SettingAspectRatio ~= "auto") then
			local ratioNumbers = graphicStatus.SettingAspectRatio:split(":")
			targetRatio = tonumber(ratioNumbers[1])/tonumber(ratioNumbers[2])
		end	
	   	local m_fToRelMul, m_fFromRelMul = 2 / screenHeight, screenHeight / 2
	    local m_fTargetBase, m_fSourceBase = 1 - 0.36 * targetRatio, 1 - 0.36 * 1.6
	    local m_fConvertScale = 1.6/targetRatio
	    local fRelY = 1 - radarOriginalStart * m_fToRelMul
	    local fNewRelY = ((( math.abs( fRelY ) - m_fSourceBase ) * m_fConvertScale + m_fTargetBase) * (fRelY < 0 and -1 or 1))
	    radarStart = ( 1 - fNewRelY ) * m_fFromRelMul
	end
end

function renderCurrentHouse()
	if(currentID and currentPickup) then
		if(currentInt ~= getElementInterior(localPlayer)) then -- interior changed
			onPickupLeave(currentID)
			return
		end
		dxDrawRectangle(45,radarStart-50,410,40,tocolor(0,0,0,80))
		dxDrawText("Press H to open the house menu", 50, radarStart-50, 450,radarStart-10,tocolor(200,0,0),2,"default-bold","left", "bottom",false,true)
	else
		removeEventHandler("onClientRender", root, renderCurrentHouse)
	end
end

function onPickupLeave(houseID)
	if(currentPickup) then
		removeEventHandler("onClientRender", root, renderCurrentHouse)
		currentID = false
		currentPickup = false
		if(isHouseMenuVisible()) then
			closeHouseMenu()
		end
	end
end
addEventHandler("onHousePickupLeave", root, onPickupLeave)

function onAttemptOpen()
	if(isHouseMenuVisible()) then
		closeHouseMenu()
	elseif(currentID) then
		loadHouseMenu(currentID)
	else -- perhaps house panel
		toggleHousePanel()
	end
end
bindKey("H", "down", onAttemptOpen)

local exitHouseMarker
-- house entering/exiting
local enterTick
addEvent("USGcnr_houses.onClientHouseEnter", true)
function onHouseEnter(int, x, y, z)
	if(isElement(exitHouseMarker)) then destroyElement(exitHouseMarker) end
	enterTick = getTickCount()
	exitHouseMarker = createMarker(x,y,z+0.75,"arrow",1,255,255,0)
	setElementInterior(exitHouseMarker, int)
	setElementDimension(exitHouseMarker,getElementDimension(localPlayer))
	addEventHandler("onClientMarkerHit", exitHouseMarker, onExitMarkerHit)
end
addEventHandler("USGcnr_houses.onClientHouseEnter", root, onHouseEnter)

addEventHandler("onPlayerExitRoom", localPlayer,
	function (room)
		if(room == "cnr" and isElement(exitHouseMarker)) then -- fake an exit for the client
			exitHouse(true)
		end
	end
)
addEventHandler("onClientResourceStop", resourceRoot,
	function ()
		if(isElement(exitHouseMarker)) then -- fake an exit for the client
			exitHouse(true)
		end
	end
)

function exitHouse(ignoreServer)
	if(not ignoreServer) then
		triggerServerEvent("USGcnr_houses.exitHouse", localPlayer)
	end
	destroyElement(exitHouseMarker)
	enterTick = false
end

function onExitMarkerHit(hitElement, dimensions)
	if(hitElement == localPlayer and dimensions and ( not enterTick or getTickCount()-enterTick >= 2500)) then -- prevent enter->exit
		exitHouse(false)
	end
end