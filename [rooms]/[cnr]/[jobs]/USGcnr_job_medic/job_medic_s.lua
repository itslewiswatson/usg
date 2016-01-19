-- *** initializing and unloading ***
function initJob()
	if(getResourceFromName("USGcnr_jobs") and getResourceState(getResourceFromName("USGcnr_jobs")) == "running") then
		exports.USGcnr_jobs:addJob(jobID, jobType, occupation)
	end
end

addEventHandler("onResourceStart", root,
	function (res) -- init job if thisResource started, or if USGcnr_jobs (re)started
		if(res == resource or res == getResourceFromName("USGcnr_jobs")) then
			initJob()
		end
	end
)

local medics = {}
addEvent("onPlayerChangeJob")
addEventHandler("onPlayerChangeJob", root,
	function (ID)
		if(ID ~= "medic" and not medics[source]) then return end
		if(not medics[source]) then
			giveWeapon(source, 41, 99999999,false)
			medics[source] = true
			addEventHandler("onPlayerExitRoom", source, onMedicQuit)
			addEventHandler("onPlayerQuit", source, onMedicQuit)
		else
			onMedicLoseJob(source)
		end
	end
)

function onMedicQuit()
	onMedicLoseJob(source)
end

function onMedicLoseJob(medic)
	if(medics[medic]) then
		removeEventHandler("onPlayerExitRoom", medic, onMedicQuit)
		removeEventHandler("onPlayerQuit", medic, onMedicQuit)
		takeWeapon(source, 41)
		medics[medic] = false
	end
end

-- *** job stuf ***
addEvent("USGcnr_job_medic.healMe", true)
function healPlayer(medic)
	if(getElementHealth(source) < 100) then	
		if(getPlayerMoney(source) >= 100) then
			setElementHealth(source, getElementHealth(source)+10)
			takePlayerMoney(source, 200)
			givePlayerMoney(medic, 200)
			exports.USGmsg:msg(medic,"You have earned $100 for healing "..getPlayerName(source), 0, 255, 0)
		else
			exports.USGmsg:msg(source, "You don't have enough money to afford healing!", 255, 0, 0)
			exports.USGmsg:msg(medic, "This player doesn't have enough money to afford healing.", 255, 0, 0)
		end
	end
end
addEventHandler("USGcnr_job_medic.healMe", root, healPlayer)