local jobRanks = {
	["Pilot"] = {
		--syntax:
		--[exp needed] = {rankName = the rank name, reward = amount of money given when player ranks up},
		[0] = {rankName = "Junior Flight Officer", reward = 0},
		[1000] = {rankName = "Flight Officer", reward = 500},
		[2500] = {rankName = "First Officer", reward = 750},
		[5000] = {rankName = "Captain", reward = 1000},
		[7500] = {rankName = "Senior Captain", reward = 1250},
		[10000] = {rankName = "Commercial First Officer", reward = 1500},
		[12500] = {rankName = "Commercial Captain", reward = 1750},
		[15000] = {rankName = "Commercial Senior Captain", reward = 2000},
		[17500] = {rankName = "Commercial Commander", reward = 2250},
		[20000] = {rankName = "Commercial Senior Commander", reward = 2500},
		[25000] = {rankName = "ATP First Officer", reward = 5000},
		[30000] = {rankName = "ATP Captain", reward = 7500},
		[50000] = {rankName = "ATP Senior Captain", reward = 10000},
		[75000] = {rankName = "ATP Commander", reward = 25000},
		[100000] = {rankName = "ATP Senior Commander", reward = 100000},
	},
} 

local jobBonuses = {
	--[Job name] = {Ranks go in here, follow syntax below}
	["Pilot"] = {
		--[rank name] = bonus given when player ranks up,
		["Junior Flight Officer"] = 0,
		["Flight Officer"] = 1000,
		["First Officer"] = 1500,
		["Captain"] = 2000,
		["Senior Captain"] = 2500,
		["Commercial First Officer"] = 3000,
		["Commercial Captain"] = 3500,
		["Commercial Senior Captain"] = 4000,
		["Commercial Commander"] = 4500,
		["Commercial Senior Commander"] = 5000,
		["ATP First Officer"] = 10000,
		["ATP Captain"] = 15000,
		["ATP Senior Captain"] = 20000,
		["ATP Commander"] = 50000,
		["ATP Senior Commander"] = 100000,
	},
}

--Converts jobID to the actual name
local dataNameFromJobName = {
	["Bus Driver"] = "busDriver",
	["Criminal"] = "criminal",
	["Delivery Driver"] = "deliveryDriver",
	["Farmer"] = "farmer",
	["Fire Fighter"] = "fireFighter",
	["Garbage Man"] = "garbageMan",
	["Lumberjack"] = "lumberjack",
	["Maintenence Man"] = "maintenenceMan",
	["Oil Miner"] = "oilMiner",
	["Paramedic"] = "paramedic",
	["Pilot"] = "pilot",
	["Police Officer"] = "policeOfficer",
	["Quarry Miner"] = "quarryMiner",
	["Taxi Driver"] = "taxiDriver",
	["Train Driver"] = "trainDriver",
	["Truck Driver"] = "truckDriver",

}

function getPlayerJobRank(player, jobName)
	if (player and isElement(player) and getElementType(player) == "player" and jobName) then
		if (jobRanks[jobName]) then
			local dataName = "jobExp." .. dataNameFromJobName[jobName]
			local plrAcc = getPlayerAccount(player)
			local jobExp = getAccountData(plrAcc, dataName)

			if (jobExp) then
				local rank = false

				for k,v in pairs(jobRanks[jobName]) do
					if (not rank) then
						rank = v.rankName
					elseif (jobExp >= k) then
						rank = v.rankName
					else
						break
					end
				end
				return rank
			end
		else
			outputDebugString("Error getting ranks from job name given. (job name is wrong)", 1)
		end
	else
		outputDebugString("Error on getting player job rank. (No player and/or job name given)", 1)
	end
end

--Since we need to get the client and not parse player as a variable (for security reasons)
--make an event that then activates the getPlayerJobRank function
addEvent("getJobRank", true)
addEventHandler("getJobRank", root, 
	function(jobName)
		if (jobName) then
			if (isElement(client) and getElementType(client) == "player") then
				getPlayerJobRank(client, jobName)
			end
		end
	end
)

--Gets the job bonus value from a given job and the rank
function getJobBonus(player, jobName, newRank)
	if (player and isElement(player) and jobName and newRank) then
		if (jobBonuses[jobName]) then
			for k,v in pairs(jobBonuses[jobName]) do
				if (k == newRank) then
					return v
				end
			end
		end
	end
end

--Handles giving player job experience for a given job.
function givePlayerJobExp(player, jobName, expToGive)
	if (player and isElement(player) and jobName and expToGive) then
		local dataName = "jobExp." .. dataNameFromJobName[jobName]
		local plrAcc = getPlayerAccount(player)
		local currentJobExp = getAccountData(plrAcc, dataName)

		if (currentJobExp) then
			local currentJobRank = getPlayerJobRank(player, jobName)
			local newJobExp = currentJobExp + expToGive
			setAccountData(plrAcc, dataName, newJobExp)
			local checkNewJobRank = getPlayerJobRank(player, jobName)

			outputChatBox(currentJobRank .. ", " .. checkNewJobRank, player)

			if (checkNewJobRank ~= currentJobRank) then
				local jobBonus = getJobBonus(player, jobName, checkNewJobRank)
				exports.USGmsg:msg(player, "You have been promoted to " .. checkNewJobRank .. "! You have received a bonus of $" .. jobBonus, 255, 255, 0)
			else
				outputChatBox("No rank difference")
			end
		end
	end
end

function getPlayerJobExp(player, jobName)
	if (player and isElement(player) and jobName) then
		local plrAcc = getPlayerAccount(player)
		local dataName = "jobExp." .. jobName
		local jobExp = getAccountData(plrAcc, dataName)

		if (jobExp) then
			outputChatBox(jobName .. ": " .. jobExp, player, 255, 255, 0)
			return jobExp
		end
	end
end

--Development functions
addCommandHandler("checkjobexp", 
	function(player, cmd, jobName)
		if (jobName) then
			getPlayerJobExp(player, jobName)
		end
	end
)

addCommandHandler("testexp", 
	function(player, cmd, jobName, exp)
		if (jobName and exp) then
			outputChatBox("Triggered from command")
			givePlayerJobExp(player, jobName, exp)
		end
	end
)