-- *** initializing and unloading ***
function isResourceReady(name)
	return getResourceFromName(name)
	and getResourceState(getResourceFromName(name)) == "running"
end

function initJob()
	if(isResourceReady("USGrooms") and exports.USGrooms:getPlayerRoom() == "cnr" and isResourceReady("USGcnr_jobs")) then
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
		if(res == resource or res == getResourceFromName("USGcnr_jobs")) then
			initJob()
		end
	end
)

-- *** job loading ***

function onClientDamage(attacker, weapon)
	if(exports.USGrooms:getPlayerRoom() ~= "cnr") then return end
	if(weapon ~= 3) then return end
	if(not attacker or getElementType(attacker) ~= "player" or exports.USGrooms:getPlayerRoom(attacker) ~= "cnr") then return end
	if(exports.USGcnr_jobs:getPlayerJobType(localPlayer) == jobType and attacker == localPlayer) then
		local wantedLevel = exports.USGcnr_wanted:getPlayerWantedLevel(source)
		if(wantedLevel > 2) then
			triggerServerEvent("USGcnr_job_police.onNightStickHit", localPlayer, source)
		end
	elseif(source == localPlayer) then
		if(exports.USGcnr_jobs:getPlayerJobType(attacker) == jobType) then
			cancelEvent()
		end
	end
end

addEventHandler("onClientPlayerDamage", root, onClientDamage)

addEvent("onPlayerArrested", true)