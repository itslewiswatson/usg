-- *** initializing and unloading ***
function isResourceReady(name)
	return getResourceFromName(name) and getResourceState(getResourceFromName(name)) == "running"
end

function initJob()
	if(getResourceFromName("USGrooms") and getResourceState(getResourceFromName("USGrooms")) == "running"
	and exports.USGrooms:getPlayerRoom() == "cnr" and getResourceFromName("USGcnr_jobs")
	and getResourceState(getResourceFromName("USGcnr_jobs")) == "running") then
		exports.USGcnr_jobs:addJob(jobID, jobType, occupation, jobDescription, jobMarkers, jobSkins, jobVehicleMarkers, jobBlip)
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
		if(res == resource or res == getResourceFromName("USGcnr_jobs") or res == getResourceFromName("USGrooms")) then
			initJob()
		end
		if(((res == resource and isResourceReady("USGcnr_inventory")) or res == getResourceFromName("USGcnr_inventory"))
		and isResourceReady("USGrooms") and exports.USGrooms:getPlayerRoom() == "cnr") then
			exports.USGcnr_inventory:create("smokemachines","Smoke machines", ":USGcnr_job_airsupport/shortspike.png")
		end			
	end
)
-- *** job loading ***

-- *** job stuff ***

-- deployable smoke machine