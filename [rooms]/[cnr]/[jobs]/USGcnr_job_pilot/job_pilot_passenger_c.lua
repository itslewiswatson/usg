addEvent("USGcnr_job_pilot.onPassengerAttemptEnter", true)
addEvent("USGcnr_job_pilot.onEnterAsPassenger", true)
addEvent("USGcnr_job_pilot.onExitAsPassenger", true)

local targetRT
local pickingDestination = false
local pickingPilot
local destinationX, destinationY

addEventHandler("USGcnr_job_pilot.onPassengerAttemptEnter", root,
	function ()
		pickingPilot = source
		openDestinationPicker()
	end
)

function createTargetRT()
	if(not isElement(targetRT)) then
		targetRT = dxCreateRenderTarget(10,10)
	end
	dxSetRenderTarget(targetRT)
	dxDrawRectangle(0,0,10,10,tocolor(255,60,60))
	dxSetRenderTarget()
end
addEventHandler("onClientRestore",root,createTargetRT)

local destinationGUI = {}
function openDestinationPicker()
	if(pickingDestination and isElement(destinationGUI.window)) then return end
	pickingDestination = true
	destinationGUI.window = exports.USGGUI:createWindow("center","center",500,550,false,"Pick a destination")
	destinationGUI.map = exports.USGGUI:createImage(0,0,500,500,false,":USGcnr_job_pilot/map.jpg",destinationGUI.window)
	addEventHandler("onUSGGUISClick",destinationGUI.map,onDestinationMapClick,false)
	destinationGUI.cancel = exports.USGGUI:createButton(5,515,70,30,false,"Cancel",destinationGUI.window)
	addEventHandler("onUSGGUISClick",destinationGUI.cancel,closeDestinationPicker,false)
	destinationGUI.price = exports.USGGUI:createLabel(75,515,350,30,false,"Pick a destination",destinationGUI.window)
	exports.USGGUI:setTextAlignment(destinationGUI.price, "center","center")
	destinationGUI.pick = exports.USGGUI:createButton(425,515,70,30,false,"Pick",destinationGUI.window)
	addEventHandler("onUSGGUISClick",destinationGUI.pick,onPickDestination,false)
	if(not targetRT) then
		createTargetRT()
	end
	destinationGUI.target = exports.USGGUI:createImage(0,0,10,10,false,targetRT, destinationGUI.map)
	addEventHandler("onUSGGUISClick",destinationGUI.target,onDestinationMapClick,false)
	exports.USGGUI:setVisible(destinationGUI.target, false)
	showCursor(true)
end

function closeDestinationPicker()
	if(pickingDestination) then
		pickingDestination = false
		pickingPilot = nil
		destinationX = nil
		destinationY = nil
		if(isElement(destinationGUI.window)) then
			destroyElement(destinationGUI.window)
		end
		showCursor(false)
	end
end
addEventHandler("onPlayerExitRoom",localPlayer,closeDestinationPicker)

function onDestinationMapClick(section, sx, sy)
	local wX, wY = exports.USGGUI:getPosition(destinationGUI.window)
	local sx,sy = sx-wX,sy-wY
	local relX = sx/500
	local relY = sy/500
	destinationX = (relX*6000)-3000
	destinationY = ((1-relY)*6000)-3000
	
	exports.USGGUI:setPosition(destinationGUI.target, sx-5, sy-5)
	exports.USGGUI:setVisible(destinationGUI.target, true)
	local px,py = getElementPosition(localPlayer)
	local distance = getDistanceBetweenPoints2D(destinationX,destinationY,px,py)
	local price = math.floor(distance*2)
	exports.USGGUI:setText(destinationGUI.price, exports.USG:formatMoney(price).." distance: "..math.floor(distance))
end


function onPickDestination()
	if(destinationX and destinationY) then
		triggerServerEvent("USGcnr_job_pilot.onPassengerPickDestination", localPlayer, pickingPilot, destinationX, destinationY)
		closeDestinationPicker()
	else
		exports.USGmsg:msg("You didn't pick a destination!", 255, 0, 0)
	end
end

-- ** in the plane **
local inPlane = false
local planeHasCustomSeats = false
function enterAsPassenger(customSeats)
	local pilot = source
	if(customSeats and not planeHasCustomSeats) then
		planeHasCustomSeats = true
		bindKey("enter_exit", "down", exitAircraft)
	end
	if(not inPlane) then
		inPlane = true
		addEventHandler("onClientPlayerWasted", localPlayer, exitAircraft)
	end 
end
addEventHandler("USGcnr_job_pilot.onEnterAsPassenger", root, enterAsPassenger)

function exitAircraft()
	triggerServerEvent("USGcnr_job_pilot.exitAircraft", localPlayer)
end

function exitAsPassenger()
	if(planeHasCustomSeats) then
		unbindKey("enter_exit", "down",exitAircraft)
		planeHasCustomSeats = false
	end
	if(inPlane) then
		inPlane = false
		removeEventHandler("onClientPlayerWasted", localPlayer, exitAircraft)
	end
end
addEventHandler("USGcnr_job_pilot.onExitAsPassenger", root, exitAsPassenger)