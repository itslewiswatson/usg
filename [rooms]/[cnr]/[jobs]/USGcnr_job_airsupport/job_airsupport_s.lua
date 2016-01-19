-- *** initializing and unloading ***
function isResourceReady(name)
	return getResourceFromName(name) and getResourceState(getResourceFromName(name)) == "running"
end

function initJob()
	if(isResourceReady("USGcnr_jobs")) then
		exports.USGcnr_jobs:addJob(jobID, jobType, occupation)
	end
end

addEventHandler("onResourceStart", root,
	function (res) -- init job if thisResource started, or if USGcnr_jobs (re)started
		if(res == resource or res == getResourceFromName("USGcnr_jobs")) then
			initJob()
		end
		if((res == resource and isResourceReady("USGcnr_inventory")) or res == getResourceFromName("USGcnr_inventory")) then
			exports.USGcnr_inventory:create("shortspikes","SMALLINT UNSIGNED", 0)
			exports.USGcnr_inventory:create("longspikes","SMALLINT UNSIGNED", 0)
		end
	end
)

-- *** job ***
local longSpike = 2892
local shortSpike = 2899
local spikeHits = {}

addEvent("USGcnr_job_airsupport.dropSpike", true)
function onPlayerDropSpike(type, x, y, z, targetZ, rz)
	if(exports.USGcnr_inventory:get(client, type == 1 and "longspikes" or "shortspikes") > 0) then
		exports.USGcnr_inventory:take(client, type == 1 and "longspikes" or "shortspikes", 1)
		local spike = createObject(type == 1 and longSpike or shortSpike, x, y, z, 0, 0, rz)
		local colShape = createColSphere(x, y, z, type == 1 and 5 or 2.5)
		attachElements ( colShape, spike)
		setElementParent(colShape, spike)
		addEventHandler('onColShapeHit', colShape, onSpikeHit)
		spikeHits[spike] = 0
		moveObject(spike, 50*((z-targetZ)*1.3), x, y, targetZ+0.1, 0, 0, 0, "InQuad")
	else
		exports.USGmsg:msg(client, string.format("You do not have any %s spike strips left!", type == 1 and "long" or "short"), 255, 0, 0)
	end
end
addEventHandler("USGcnr_job_airsupport.dropSpike", root, onPlayerDropSpike)

function destroySpike(spike)
	destroyElement(spike)
	spikeHits[spike] = nil
end

local wheellessVehicleTypes = { Plane = true, Helicopter = true }
function onSpikeHit(element, dimensions)
	if(dimensions and getElementType(element) == "vehicle" and not wheellessVehicleTypes[getVehicleType(element)]) then
		-- spikes become less effective over time
		local spike = getElementParent(source)
		if(spikeHits[spike] == 0) then
			setVehicleWheelStates(element,1,1,1,1)
		elseif(spikeHits[spike] == 1) then
			setVehicleWheelStates(element,math.random(1) == 1 and -1 or 1,1,1,-1)
		elseif(spikeHits[spike] == 2) then
			setVehicleWheelStates(element,math.random(1) == 1 and -1 or 1,-1,math.random(1) == 1 and -1 or 1,-1)
		end
		spikeHits[spike] = spikeHits[spike]+1
		if(spikeHits[spike] > 2) then
			destroySpike(spike)
		end
	end
end