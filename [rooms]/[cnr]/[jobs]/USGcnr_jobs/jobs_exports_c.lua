function getPlayerJob(player)
	if(player and not isElement(player)) then
		error("Syntax is getPlayerJob(player) or getPlayerJob() for localPlayer!")
	end
	return getElementData(player or localPlayer, "jobID")
end

function getPlayerOccupation(player)
	if(player and not isElement(player)) then
		error("Syntax is getPlayerJob(player) or getPlayerJob() for localPlayer!")
	end
	local job = getPlayerJob(player or localPlayer)
	if(job) then
		return jobs[job].occupation
	else
		return getElementData(player or localPlayer, "occupation")
	end
end

function getPlayerJobType(player)
	if(player and not isElement(player)) then
		error("Syntax is getPlayerJob(player) or getPlayerJob() for localPlayer!")
	end
	local id = getPlayerJob(player or localPlayer)
	if(id and jobs[id]) then
		return jobs[id].type
	else
		return false
	end
end