-- *** initializing and unloading ***
function initJob()
	if(getResourceFromName("USGrooms") and getResourceState(getResourceFromName("USGrooms")) == "running"
	and exports.USGrooms:getPlayerRoom() == "cnr" and getResourceFromName("USGcnr_jobs")
	and getResourceState(getResourceFromName("USGcnr_jobs")) == "running") then
		exports.USGcnr_jobs:addJob(jobID, jobType, occupation, "staff", {}, false, {})
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
	end
)

addEventHandler("onClientPlayerDamage", localPlayer, 
	function ()
		if(exports.USGrooms:getPlayerRoom() == "cnr" and exports.USGcnr_jobs:getPlayerJob() == jobID) then
			cancelEvent()
		end
	end
)