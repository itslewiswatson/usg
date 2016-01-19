-- *** initializing and unloading ***
local initialised = false
function initJob()
	if(getResourceFromName("USGrooms") and getResourceState(getResourceFromName("USGrooms")) == "running"
	and exports.USGrooms:getPlayerRoom() == "cnr" and getResourceFromName("USGcnr_jobs")
	and getResourceState(getResourceFromName("USGcnr_jobs")) == "running") then
		exports.USGcnr_jobs:addJob(jobID, jobType, occupation, jobDescription, jobMarkers, jobSkins, jobVehicleMarkers, jobBlip)
		if(not initialised) then
			addEventHandler("onClientPlayerDamage", localPlayer, onPlayerDamage)
			initialised = true
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
		if(res == resource or res == getResourceFromName("USGcnr_jobs") or res == getResourceFromName("USGrooms")) then
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
			if(initialised) then
				removeEventHandler("onClientPlayerDamage", localPlayer, onPlayerDamage)
				initialised = false
			end
		end
	end
)

-- *** job stuff ***
local healTimer = false
local damagedByPlayer = {}
function onPlayerDamage(attacker,weapon)
	if(exports.USGcnr_jobs:getPlayerJob(attacker) == jobID and weapon == 41) then
		cancelEvent()
		if(damagedByPlayer[attacker] and getTickCount()-damagedByPlayer[attacker] < 45000) then return end
		if(healTimer and getTickCount()-healTimer < 750) then return end
		healTimer = getTickCount()
		local maxHealth = exports.USG:getPedMaxHealth(source)
		if(getElementHealth(localPlayer) < maxHealth) then
			triggerServerEvent("USGcnr_job_medic.healMe", localPlayer, attacker)
		end
	elseif(exports.USGcnr_jobs:getPlayerJob(attacker) == jobID) then
		damagedByPlayer[attacker] = getTickCount()
	end
end