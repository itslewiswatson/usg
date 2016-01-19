-- *** initializing and unloading ***
function initJob()
	if(getResourceFromName("USGrooms") and getResourceState(getResourceFromName("USGrooms")) == "running" 
	and exports.USGrooms:getPlayerRoom() == "cnr" and getResourceFromName("USGcnr_jobs")
	and getResourceState(getResourceFromName("USGcnr_jobs")) == "running") then
		exports.USGcnr_jobs:addJob(jobID, jobType, occupation, jobDescription, jobMarkers, jobSkins, jobVehicleMarkers, jobBlip)
		if(exports.USGcnr_jobs:getPlayerJob(localPlayer) == jobID) then
			onChangeJob(jobID)
		end
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
transporting = false


addEvent("onPlayerChangeJob", true)
local onTheJob = false
function onChangeJob(ID)
	if(ID == jobID and not onTheJob) then
		loadLocations()
		onTheJob = true
	elseif(onTheJob) then
		unloadLocations()
		stopTransport()
		onTheJob = false
	end
end
addEventHandler("onPlayerChangeJob", localPlayer, onChangeJob)

addEvent("onPlayerExitRoom", true)
addEventHandler("onPlayerExitRoom", localPlayer, 
	function (prevRoom)
		if(prevRoom == "cnr") then
			onChangeJob(false)
		end
	end
)