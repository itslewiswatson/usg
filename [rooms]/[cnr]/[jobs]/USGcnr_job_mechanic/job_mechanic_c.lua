-- *** initializing and unloading ***
function initJob()
	if(getResourceFromName("USGrooms") and getResourceState(getResourceFromName("USGrooms")) == "running"
	and exports.USGrooms:getPlayerRoom() == "cnr" and getResourceFromName("USGcnr_jobs")
	and getResourceState(getResourceFromName("USGcnr_jobs")) == "running") then
		exports.USGcnr_jobs:addJob(jobID, jobType, occupation, jobDescription, jobMarkers, jobSkins, jobVehicleMarkers,jobBlip)
	end
end

addEvent("onPlayerJoinRoom", true)
addEventHandler("onPlayerJoinRoom", localPlayer, 
	function (room)
		if(room == "cnr") then
			initJob()
		end
	end
)

addEventHandler("onClientResourceStart", root,
	function (res) -- init job if thisResource started, or if USGcnr_jobs (re)started
		if(res == resource or res == getResourceFromName("USGcnr_jobs")) then
			initJob()
		end
	end
)

-- *** job loading ***
addEvent("onPlayerChangeJob", true)
local onTheJob = false
function onChangeJob(ID)
	onTheJob = ID == jobID
end
addEventHandler("onPlayerChangeJob", localPlayer, onChangeJob)

addEvent("onPlayerExitRoom", true)
addEventHandler("onPlayerExitRoom", localPlayer, 
	function (prevRoom)
		if(prevRoom == "cnr") then
			onTheJob = false
		end
	end
)

setTimer(function()
if (exports.usgcnr_jobs:getPlayerJob(localPlayer) ~= "Mechanic") then
	if ( exports.usggui:getVisible ( panel ) ) then            
		exports.usggui:setVisible(panel,false)
		showCursor(false)
	end 
	if ( exports.usggui:getVisible ( panel2 ) ) then  
		exports.usggui:setVisible(panel2,false)
		showCursor (false)
		setElementFrozen(vehiclee,false)
		triggerServerEvent("rejectRequest", localPlayer, mechanicc,vehiclee)
	end
end	
end,500,0)

--Panel1
function showPanel()  
	if (exports.usgcnr_jobs:getPlayerJob(localPlayer) == "Mechanic") then
	damagedVehicles()
		if ( exports.usggui:getVisible ( panel ) ) then            
			exports.usggui:setVisible(panel,false)
			showCursor(false)
		else              
			exports.usggui:setVisible ( panel, true ) 
			showCursor(true)
			damagedVehicles()
		end
	end
end
bindKey("F5", "down", showPanel)

panel = exports.USGGUI:createWindow("center","center",421, 480,false,"Mechanic Panel")
exports.usggui:setVisible(panel,false)
grid = exports.USGGUI:createGridList(7,7,405, 275,false,panel)
exports.USGGUI:gridlistAddColumn(grid,"Owner(name)",0.5)
exports.USGGUI:gridlistAddColumn(grid,"Health",0.2)
exports.USGGUI:gridlistAddColumn(grid,"Distance",0.4)
markS = exports.USGGUI:createButton(7, 290, 80, 30,false,"Mark selected",panel)
markA = exports.USGGUI:createButton(170, 290, 80, 30,false,"Mark all",panel)
Clear1 = exports.USGGUI:createButton(333, 290, 80, 30,false,"Clear all",panel)
Close1 = exports.USGGUI:createButton(333, 440, 80,30,false,"Close",panel)
mark1 = exports.USGGUI:createRadioButton(7, 340, 100, 30,false,"Vehicles with less than 60% health",panel)
mark2 = exports.USGGUI:createRadioButton(7, 370, 100, 30,false,"Vehicles with less than 30% health",panel)
mark3 = exports.USGGUI:createRadioButton(7, 400, 100, 30,false,"All Vehicles",panel)
exports.USGGUI:setRadioButtonState(mark3,true)
--gps = exports.USGGUI:createCheckBox(7, 440, 100, 30,false,"GPS system",panel)


--load
function damagedVehicles()
	shealth = 1000
	if (exports.usggui:getRadioButtonState(mark1)) then 
		shealth = 600
	elseif (exports.usggui:getRadioButtonState(mark2)) then 
		shealth = 300
	elseif (exports.usggui:getRadioButtonState(mark3)) then 
		shealth = 1000
	end
	vehiclesList = false
	exports.usggui:gridlistClear(grid)
	for i, vehicle in ipairs(getElementsByType("vehicle")) do
		if (getElementHealth(vehicle) < shealth) and (getElementDimension(vehicle) == 0) then
			triggerServerEvent("isOwner", localPlayer, vehicle)
			vehicleOwner = getElementData(vehicle, "Owner")
			if isElement(vehicleOwner) then
 				vehiclesList = true
				x, y, z = getElementPosition(vehicle)
				px, py, pz = getElementPosition(localPlayer)
				distance = round(getDistanceBetweenPoints2D ( x, y, px,py ),3)
				row = exports.usggui:gridlistAddRow(grid)
				exports.usggui:gridlistSetItemText( grid, row, 1, tostring(getPlayerName(vehicleOwner)).. " (" ..tostring(getVehicleName(vehicle)).. ")")
				exports.usggui:gridlistSetItemData( grid, row, 1, vehicle)
				exports.usggui:gridlistSetItemText( grid, row, 2, tostring(math.floor(getElementHealth ( vehicle )  / 10)).."%")
				exports.usggui:gridlistSetItemText( grid, row, 3, tostring(distance))
			end
		end
	end
	
	if (not ( vehiclesList )) then
			row = exports.usggui:gridlistAddRow(grid )
			exports.usggui:gridlistSetItemText( grid, row, 1, "No vehicles found")
			exports.usggui:gridlistSetItemText( grid, row, 2, " N/A")
			exports.usggui:gridlistSetItemText( grid, row, 3, " N/A")
	end	
end
addEventHandler("onUSGGUISClick",mark1,damagedVehicles,false)
addEventHandler("onUSGGUISClick",mark2,damagedVehicles,false)
addEventHandler("onUSGGUISClick",mark3,damagedVehicles,false)

--Mark Selected
function markSelected()
if (exports.usgcnr_jobs:getPlayerJob(localPlayer) == "Mechanic") then
	local selected = exports.usggui:gridlistGetSelectedItem(grid)
	if type(selected) == "number" then
	local vehicle = exports.usggui:gridlistGetItemData(grid, exports.usggui:gridlistGetSelectedItem(grid) ,1)
	if not (isElement(vehicle)) then
		exports.USGmsg:msg("You didn't select a player", 225 ,0 ,0)
	else
		if (isElement(vehicle)) then
			if (getAttachedElements(vehicle)) then
				for i, blip in ipairs (getAttachedElements(vehicle)) do
					if ( getElementType (blip) == "blip" ) then
						if ( getBlipIcon (blip) == 20 ) then
							return
						end
					end
				end
			end
			theBlip = createBlipAttachedTo ( vehicle, 20 )
			addEventHandler("onClientElementDestroy", vehicle,function()
				if isElement(theBlip) then
					destroyElement(theBlip)
				end
			end)
		end
	end
	end
end	
end
addEventHandler("onUSGGUISClick",markS,markSelected,false)

local refreshBlips = false

t = setTimer ( function ()
	if ( refreshBlips ) then
		if (exports.usgcnr_jobs:getPlayerJob(localPlayer) == "Mechanic") then
			markAll()
		else	
			Clear()
		end	
	end
end, 5000, 0)

--Mark All
function markAll()
	shealth = 1000
	if (exports.usggui:getRadioButtonState(mark1)) then 
		shealth = 600
	elseif (exports.usggui:getRadioButtonState(mark2)) then 
		shealth = 300
	elseif (exports.usggui:getRadioButtonState(mark3)) then 
		shealth= 1000
	end
	Clear()
	for i, vehicle in ipairs(getElementsByType("vehicle")) do
		if (getElementHealth(vehicle) < shealth) and (getElementDimension(vehicle) == 0) then
			triggerServerEvent("isOwner", localPlayer, vehicle)
			vehicleOwner = getElementData(vehicle, "Owner")
			if isElement(vehicleOwner) then
				local theBlip = createBlipAttachedTo ( vehicle, 20 )
				addEventHandler("onClientElementDestroy", vehicle,function()
					if isElement(theBlip) then
						destroyElement(theBlip)
					end
				end)
				refreshBlips = true
			end
		end
	end
end
addEventHandler("onUSGGUISClick",markA,markAll,false)

--close
function Close()
	exports.usggui:setVisible(panel,false)
	showCursor (false)
end
addEventHandler("onUSGGUISClick",Close1,Close,false)

--clear all
function Clear()
	for i, vehicle in ipairs(getElementsByType("vehicle")) do
		if (getAttachedElements(vehicle)) then 
			for j, blip in ipairs (getAttachedElements(vehicle)) do
				if isElement(blip) then 
					if (getElementType(blip) == "blip") then
						if (getBlipIcon(blip) == 20) then
							destroyElement(blip)
							refreshBlips = false
							vehiclesList = false
						end
					end
				end
			end
		end
	end
end
addEventHandler("onUSGGUISClick",Clear1,Clear,false)
addEventHandler ( "onPlayerChangeJob", root,
function ()
	if ( source == localPlayer ) then
		Clear()
	end
end
)

--Panel2
textt = "SpriN"
panel2 = exports.USGGUI:createWindow("center","center",282,182,false,"Mechanic Panel")
label = exports.USGGUI:createLabel("center", 1, 250, 30,false, textt.. ' wants to fix your vehicle',panel2)
c1 = exports.USGGUI:createRadioButton(7, 50, 80, 30,false,"Fix vehicle wheels",panel2)
c2 = exports.USGGUI:createRadioButton(7, 90, 80, 30,false,"Repair Vehicle",panel2)
buy = exports.USGGUI:createButton(7, 140, 80, 30,false,"Buy",panel2)
Close2 = exports.USGGUI:createButton(190, 140, 80, 30,false,"Close",panel2)
exports.usggui:setVisible(panel2,false)

--Player accepts
function onPlayerAccept()
	if(exports.usggui:getRadioButtonState(c1))then
	-- Wheels
		--triggerEvent ( "startProgress",  mechanicc, vehiclee, "o1")
		triggerServerEvent("wheelRepair", localPlayer, mechanicc, vehiclee)
		exports.usggui:setVisible(panel2,false)
		showCursor (false)
	elseif(exports.usggui:getRadioButtonState(c2))then
	-- Repair
		--triggerEvent ( "startProgress",  mechanicc, vehiclee, "o2" )
		triggerServerEvent("vehicleRepair", localPlayer, mechanicc, vehiclee)
		exports.usggui:setVisible(panel2,false)
		showCursor (false)
	end
		if isElement(vehiclee) then
		attachedElements = getAttachedElements(vehiclee)
		for i,blip in ipairs(attachedElements) do
			if isElement(blip) then 
					if (getElementType(blip) == "blip") then
						if (getBlipIcon(blip) == 20) then
							destroyElement(blip)
						end
					end
				end
		end
	end	
end
addEventHandler("onUSGGUISClick",buy,onPlayerAccept,false)

function showPanel2(mechanic, vehicle)
	exports.usggui:setVisible(panel2,true)
	showCursor (true)
	textt = getPlayerName(mechanic)
	exports.usggui:setText(label, getPlayerName(mechanic)..  " wants to fix your vehicle")
	mechanicc = mechanic
	vehiclee = vehicle
end
addEvent("showPanel2", true)
addEventHandler("showPanel2", getRootElement(), showPanel2)

function onPlayerReject()
	exports.usggui:setVisible(panel2,false)
	showCursor (false)
	setElementFrozen(vehiclee,false)
	triggerServerEvent("rejectRequest", localPlayer, mechanicc,vehiclee)
end
addEventHandler("onUSGGUISClick",Close2,onPlayerReject,false)

addEventHandler("onClientResourceStart", getResourceRootElement(getThisResource()),
    function ( resourceName )
        triggerServerEvent("bindAim", localPlayer)
    end
)

function round(number, digits)
  local mult = 10^(digits or 0)
  return math.floor(number * mult + 0.5) / mult
end

if fileExists("job_mechanic_c.lua") == true then
	fileDelete("job_mechanic_c.lua")
end