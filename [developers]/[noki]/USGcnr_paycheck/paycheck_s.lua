local function getBaseAmount()
	local players = getElementsByType("player")
	if (#players < 8) then
		return false
	elseif (#players >= 8) and (#players <= 15) then
		return 100
	elseif (#players > 15) and (#players <= 25) then
		return 200
	elseif (#players > 25) and (#players <= 35) then
		return 250
	else
		-- We have more than 35, fuck yeah
		return 325
	end
end

local function givePlayerPayCheck()
	-- Idle for 30 mins
	if (client) and (getPlayerIdleTime(client) < 1800000) then
		local players = getElementsByType("player")
		local police = getPlayersInTeam(getTeamFromName("Police"))
		
		-- We need to have an adequate player count to do this, to avoid farming
		if (#players >= 8) and (#police >= 2) then
			local baseAmount = getBaseAmount()
			local baseAmount = math.floor(baseAmount * ((#players / #police) / 2))
			
			givePlayerMoney(client, baseAmount)
			exports.USGmsg:msg(client, "[USG Government] You have been given $"..baseAmount.." for your active service towards the city!")
		else
			exports.USGmsg:msg(client, "[USG Government] You would have been given a paycheck, but there were not enough officers active!")
		end
	end
end
addEvent("USGcnr_paycheck:givePlayerPayCheck", true)
addEventHandler("USGcnr_paycheck:givePlayerPayCheck", root, givePlayerPayCheck)