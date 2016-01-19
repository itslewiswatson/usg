function isResourceReady(name)
	return getResourceFromName(name) and getResourceState(getResourceFromName(name)) == "running"
end

function addCriminalJob()
	exports.USGcnr_jobs:addJob(jobID,jobType,occupation)
	for i, player in ipairs(getElementsByType("player")) do
		if(exports.USgrooms:getPlayerRoom(player) == "cnr") then
			local wlvl = exports.USGcnr_wanted:getPlayerWantedLevel(player)
			local job = exports.USGcnr_jobs:getPlayerJob(player)
			if(wlvl > 0 and exports.USGcnr_jobs:getJobType(job) ~= jobType) then
				exports.USGcnr_jobs:setPlayerJob(player, jobID)
			end
		end
	end
end

addEventHandler("onResourceStart", root, 
	function (res)
		if(source == resourceRoot or source == getResourceRootElement(getResourceFromName("USGcnr_jobs"))) then
			addCriminalJob()
		end
		if((res == resource and isResourceReady("USGcnr_inventory")) or res == getResourceFromName("USGcnr_inventory")) then
			exports.USGcnr_inventory:create("smokemachines","SMALLINT UNSIGNED", 0)
		end		
	end
)

addEvent("onPlayerBecomeWanted", true)
function onPlayerBecomeWanted()
	if(exports.USGcnr_jobs:getPlayerJobType(source) ~= jobType) then
		exports.USGcnr_jobs:setPlayerJob(source, jobID)
	end
end
addEventHandler("onPlayerBecomeWanted", root, onPlayerBecomeWanted)

addEvent("onPlayerAttemptChangeJob")
function onPlayerAttemptChangeJob(job, skin)
	local wlvl = exports.USGcnr_wanted:getPlayerWantedLevel(source)
	if(wlvl > 0 and exports.USGcnr_jobs:getJobType(job) ~= jobType) then
		cancelEvent()
		if(exports.USGcnr_jobs:getPlayerJobType(source) ~= "criminal") then
			exports.USGcnr_jobs:setPlayerJob(source, jobID)
		else
			exports.USGmsg:msg(source, "You can't change your job while being a wanted criminal.", 255, 0, 0)
		end
	end
end
addEventHandler("onPlayerAttemptChangeJob", root, onPlayerAttemptChangeJob)

-- deployable smoke machine
local canDeploySmoke = {Automobile = true, Bike = 1}

function deploySmokeMachine(player, cmd, count)
	if(exports.USGrooms:getPlayerRoom(player) ~= "cnr") then return end
	if(exports.USGcnr_jobs:getPlayerJobType(player) == "criminal") then
		local count = count == "2" and 2 or 1
		local machines = exports.USGcnr_inventory:get(player, "smokemachines")
		if(machines and machines >= count) then
			local vehicle = getPedOccupiedVehicle(player)
			if(vehicle) then
				local vehType = getVehicleType(vehicle)
				if(canDeploySmoke[vehType] == true or canDeploySmoke[vehType] >= count) then
					local machine
					if(count == 1) then
						machine = createObject(2780, 0, 0, 0)
						if(vehType == "Bike") then
							setObjectScale(machine, 0.3)
							attachElements(machine, vehicle, 0, -1, 0.2, 0, -20)
						else
							attachElements(machine, vehicle, 0, -1.8, -0.2, 0, -20)
						end
					elseif(count == 2) then
						machine = createObject(2780, 0, 0, 0)
						attachElements(machine, vehicle, 0.9, -1.8, -0.20, -20)
						local second = createObject(2780, 0, 0, 0)
						attachElements(second, vehicle, -0.9, -1.8, -0.20, -20)
						setElementParent(second, machine)
					end
					setTimer(destroySmokeMachine, 30000, 1, machine)
					exports.USGcnr_inventory:take(player, "smokemachines", count)
				else
					exports.USGmsg:msg(player, string.format("Your vehicle does not support deploying %s smoke machines!", 
						canDeploySmoke[vehType] and count or "any"), 255, 0, 0)
				end
			else
				exports.USGmsg:msg(player, "You are not in a vehicle!", 255, 0, 0)
			end
		else
			exports.USGmsg:msg(player, "You don't have any smoke machines!", 255, 0, 0)
		end
	else
		exports.USGmsg:msg(player, "You need to be a criminal to deploy smoke machines!", 255, 0, 0)
	end
end
addCommandHandler("smokemachine", deploySmokeMachine, false, false)

function destroySmokeMachine(object)
	if(isElement(object)) then
		destroyElement(object)
	end
end
