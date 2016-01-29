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

-- *** job ***
local playerTrailers = {}
local trailerModels = {435,450,591,584}

addEvent("USGcnr_job_trucker.onTransportStart", true)
function onTransportStart()
	if(isElement(playerTrailers[client])) then
		destroyElement(playerTrailers[client])
	end
	local pVehicle = getPedOccupiedVehicle(client)
	local px,py,pz = getElementPosition(pVehicle)
	local _,_,rot = getElementRotation(pVehicle)
	playerTrailers[client] = createVehicle(trailerModels[math.random(#trailerModels)], px,py,pz+4,0,0,rot)
	setElementData(playerTrailers[client], "room", "cnr")
	setElementDimension(playerTrailers[client], exports.USGrooms:getRoomDimension("cnr"))
	attachTrailerToVehicle(pVehicle, playerTrailers[client])
	triggerClientEvent(client, "USGcnr_job_trucker.onTrailerAttached", client , playerTrailers[client])
end
addEventHandler("USGcnr_job_trucker.onTransportStart", root, onTransportStart)

addEvent("USGcnr_job_trucker.onTransportStop", true)
function onTransportStop(success, reward)
	if(isElement(playerTrailers[client])) then
		destroyElement(playerTrailers[client])
	end
	if(success) then
		local currentJobRank = exports.USGcnr_jobranks:getPlayerJobRank(client, "trucker")
		local rankBonus = exports.USGcnr_jobranks:getPlayerJobBonus(client, "trucker", currentJobRank)
		local expAmount = math.floor(reward / 10)
		reward = reward + rankBonus
		givePlayerMoney(client, reward)
		exports.USGcnr_jobranks:givePlayerJobExp(client, "trucker", expAmount)
		exports.USGmsg:msg(client, "Exp earned: " .. exports.USGmisc:convertNumber(expAmount), 255, 255, 0)
		exports.USGcnr_money:logTransaction(client, "earned "..exports.USG:formatMoney(reward).." from trucking")
	end
end
addEventHandler("USGcnr_job_trucker.onTransportStop", root, onTransportStop)

function onPlayerQuit()
	if (getElementData(source, "jobID") == jobID) then
		if (isElement(playerTrailers[source])) then
			destroyElement(playerTrailers[source])
		end
	end
end
addEventHandler("onPlayerQuit", root, onPlayerQuit)