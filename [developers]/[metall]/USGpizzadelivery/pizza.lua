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
	if (isElement(marker)) then destroyElement(marker) end
	if (isElement(blip)) then destroyElement(blip) end
end
addEventHandler("onPlayerChangeJob", localPlayer, onChangeJob)

addEvent("onPlayerExitRoom", true)
addEventHandler("onPlayerExitRoom", localPlayer, 
	function (prevRoom)
		if(prevRoom == "cnr") then
			onTheJob = false
			if (isElement(marker)) then destroyElement(marker) end
			if (isElement(blip)) then destroyElement(blip) end
		end
	end
)

function startDelivery(x, y, z)
	if (isElement(marker)) then destroyElement(marker) end
	if (isElement(blip)) then destroyElement(blip) end
	marker = createMarker(x, y, z, "cylinder", 2, 200, 200, 0, 200)
	blip = createBlip(x, y, z, 51, 1)
	exports.USGmsg:msg("Deliver the pizza to "..getZoneName(x, y, z), 0, 200, 0)
	addEventHandler("onClientMarkerHit", marker, onHit)
	setElementFrozen(getPedOccupiedVehicle(source), false)
end
addEvent("USGpizzadelivery.startDelivery", true)
addEventHandler("USGpizzadelivery.startDelivery", localPlayer, startDelivery)

function onHit(hitElement, md)
	if (hitElement == localPlayer and md) then
		if (not isPedInVehicle(localPlayer)) then return end
		if (exports.USGcnr_jobs:getPlayerJob(hitElement) == "Pizza Delivery") then
			local veh = getPedOccupiedVehicle(hitElement)
			if (getElementModel(veh) ~= 448) then return outputChatBox("You have to enter with Faggio!", 255, 0, 0) end
			fadeCamera(false)
			if (isElement(marker)) then destroyElement(marker) end
			if (isElement(blip)) then destroyElement(blip) end
			setTimer(fadeCamera, 3000, 1, true)
			setElementFrozen(veh, true)
			triggerServerEvent("USGpizzadelivery.givePayment", localPlayer, localPlayer, elements)
		else
			deleteAll()
		end
	end
end

function deleteAll()
	if (isElement(marker)) then destroyElement(marker) end
	if (isElement(blip)) then destroyElement(blip) end
end
addEvent("USGpizzadelivery.deleteAll", true)
addEventHandler("USGpizzadelivery.deleteAll", localPlayer, deleteAll)

function onExit(player, seat)
	if (not exports.USGcnr_jobs:getPlayerJob(player) == "Pizza Delivery") then return end
	if (player == localPlayer) then
		if (isElement(marker)) then
			--if (getElementModel(source) ~= 448) then return end
			--removeEventHandler("onClientMarkerHit", marker, onHit)
			--destroyElement(marker)
			--triggerServerEvent("USGpizzadelivery.do", player, player)
			--if (isElement(blip)) then destroyElement(blip) end
		else
			deleteAll()
		end
	end
end
addEventHandler("onClientVehicleExit", root, onExit)

fileDelete("pizza.lua")