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
	if (isElement(blip)) then destroyElement(blip) end
	if (isElement(object)) then destroyElement(object) end
	if (isElement(mark)) then destroyElement(mark) end
	if (isElement(col)) then destroyElement(col) end
end
addEventHandler("onPlayerChangeJob", localPlayer, onChangeJob)

addEvent("onPlayerExitRoom", true)
addEventHandler("onPlayerExitRoom", localPlayer, 
	function (prevRoom)
		if(prevRoom == "cnr") then
			onTheJob = false
			if (isElement(blip)) then destroyElement(blip) end
			if (isElement(object)) then destroyElement(object) end
			if (isElement(mark)) then destroyElement(mark) end
			if (isElement(col)) then destroyElement(col) end
		end
	end
)

function deleteCrap()
	if (isElement(blip)) then destroyElement(blip) end
	if (isElement(object)) then destroyElement(object) end
	if (isElement(mark)) then destroyElement(mark) end
	if (isElement(col)) then destroyElement(col) end
end
addEvent("USGshitcleaner.deleteCrap", true)
addEventHandler("USGshitcleaner.deleteCrap", root, deleteCrap)

function setPoints(x, y, z)
	if (isElement(blip)) then destroyElement(blip) end
	if (isElement(col)) then
		removeEventHandler("onClientColShapeHit", col, onHit)
		destroyElement(col)
	end
	object = createObject(2838, x, y, z - 0.5)
	col = createColSphere(x, y, z, 2)
	blip = createBlip(x, y, z, 0, 1, 0, 255, 0, 255, 0, 99999, localPlayer)
	mark = createMarker(x, y, z + 1, "arrow", 1, 0, 255, 0, 200)
	addEventHandler("onClientColShapeHit", col, onHit)
end
addEvent("USGstreetcleaner.setPoints", true)
addEventHandler("USGstreetcleaner.setPoints", root, setPoints)

function onHit(hitElement)
	if (hitElement == localPlayer) then
		if (not exports.USGcnr_jobs:getPlayerJob() == "Street Cleaner") then return end
		if (not getPedOccupiedVehicle(localPlayer)) then return end
		triggerServerEvent("USGstreetcleaner.payMe", localPlayer, localPlayer)
		playSound("Pickup_Coin9.wav")
		if (isElement(blip)) then destroyElement(blip) end
		if (isElement(object)) then destroyElement(object) end
		if (isElement(mark)) then destroyElement(mark) end
		if (isElement(col)) then
			removeEventHandler("onClientColShapeHit", col, onHit)
			destroyElement(col)
		end
	end
end

function onExit(player, seat)
	if (not exports.USGcnr_jobs:getPlayerJob(player) == "Street Cleaner") then return end
	if (player == localPlayer) then
		if (isElement(col)) then
			removeEventHandler("onClientColShapeHit", col, onExit)
			destroyElement(col)
		else
			if (isElement(blip)) then destroyElement(blip) end
			if (isElement(object)) then destroyElement(object) end
			if (isElement(mark)) then destroyElement(mark) end
		end
	end
end
addEventHandler("onClientVehicleExit", root, onExit)