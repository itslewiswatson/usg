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

local fish = {}
local netCount = 50

local fishList = {
	{"Salmon", 400},
	{"Barracuda", 200},
	{"Piranha", 140},
	{"Catfish", 240},
	{"Anaspida", 200},
	{"Archerfish", 500},
	{"Chelonia", 100},
	{"Crab", 280},
	{"Triggerfish", 230},
	{"Cod", 420},
	{"Lionfish", 420},
	{"Pilchard", 350},
	{"Sardine", 20},
	{"Sea Urchin", 1000},
	{"Stingray", 400},
	--{"White Shark", 5000}, -- Make these occur more randomly than others.
	--{"Tiger Shark", 7500}, 
	{"Frontosa", 300},
	{"Discus", 400},
	{"Humpback Whale", 100},
	{"Rockfish", 40},
	{"Marlin", 200},
	{"Smallmouth Bass", 200},
	{"Bigmouth Bass", 300},
	{"Turtle", 180},
}

local spots = {
	{718, -1485, 0.8}, -- LS
}

function createSpots()
	for k, v in pairs(spots) do
		local marker = createMarker(v[1], v[2], v[3], "cylinder", 2, 0, 200, 0, 200)
		addEventHandler("onMarkerHit", marker, emptyNet)
	end
end
addEventHandler("onResourceStart", resourceRoot, createSpots)

function onEnter(player, seat)
	if (seat == 0 and getElementModel(source) == 453 and player and isElement(player) and getElementType(player) == "player") then
		if (exports.USGcnr_jobs:getPlayerJob(player) == "Fisherman") then
			exports.USGmsg:msg(player, "Start your reefer and drive out in the open water", 0, 255, 0)
			if (not fish[player]) then
				local x, y, z = getElementPosition(player)
				local x, y = math.ceil(x), math.ceil(y)
				fish[player] = {0, 0, x, y}
			end
		end
	end
end
addEventHandler("onVehicleEnter", root, onEnter)

function onCaught()
	for plr, v in pairs(fish) do
		if (isElement(plr) and exports.USGcnr_jobs:getPlayerJob(plr) == "Fisherman") then
			local veh = getPedOccupiedVehicle(plr)
			if (veh and isElement(veh) and getElementModel(veh) == 453) then
				if (fish[plr][2] and fish[plr][2] <= netCount) then
					local px, py, pz = getElementPosition(plr)
					local px, py = math.ceil(px), math.ceil(py)
					local dist = getDistanceBetweenPoints2D(px, py, fish[plr][3], fish[plr][4])
					if (math.floor(dist) < 5) then
						exports.USGmsg:msg(plr, "This area has been out-fished, move around to fresh water", 200, 0, 0)
						return
					end
					local random = math.random(#fishList)
					local fishFound = fishList[random][1]
					local fishValue = fishList[random][2]
					fish[plr] = {fish[plr][1] + fishValue, fish[plr][2] + 1, px, py}
					exports.USGmsg:msg(plr, "You have caught a "..fishFound.." worth $"..fishValue, 0, 200, 0)
					
					if (fish[plr][2] and fish[plr][2] == netCount) then
						exports.USGmsg:msg(plr, "Your net capacity is full, return to shore to empty it and get cash!", 200, 0, 0)
						return
					end
				end
			end
		end
	end
end
setTimer(onCaught, 30 * 1000, 0)

function netCount2(plr)
	if (not exports.USGcnr_jobs:getPlayerJob(plr) == "Fisherman") then
		exports.USGmsg:msg(plr, "You must be a Fisherman to be able to use this command!", 255, 0, 0)
		return
	end
	if (not fish[plr]) then
		exports.USGmsg:msg(plr, "You have no fish in your net as of this moment", 255, 0, 0)
	elseif (fish[plr]) then
		local value = fish[plr][1]
		local amount = fish[plr][2]
		exports.USGmsg:msg(plr, "You have caught "..amount.." fishes worth $"..value, 200, 200, 0)
	end
end
addCommandHandler("net", netCount2)

function emptyNet(player, matchingDim)
	if (player and isElement(player) and getElementType(player) == "player" and matchingDim) then
		if (exports.USGcnr_jobs:getPlayerJob(player) == "Fisherman") then
			if (fish[player] and fish[player][1] and fish[player][1] >= 1) then
				local value = fish[player][1]
				local amount = fish[player][2]
				local currentJobRank = exports.USGcnr_jobranks:getPlayerJobRank(client, "Fisherman")
				local rankBonus = exports.USGcnr_jobranks:getPlayerJobBonus(client, "Fisherman", currentJobRank)
				local expAmount = math.floor(value/6)

				fish[player] = nil
				exports.USGmsg:msg(player, "Your catch has been sold for $"..value..", "..amount.." fishes", 0, 200, 0)
				givePlayerMoney(player, value + rankBonus)
				exports.USGcnr_jobranks:givePlayerJobExp(client, "Fisherman", expAmount)
			else
				exports.USGmsg:msg(player, "You have not caught anything", 200, 0, 0)
			end
		end
	end
end