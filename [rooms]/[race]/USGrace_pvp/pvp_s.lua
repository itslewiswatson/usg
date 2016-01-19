local raceRooms = {dm = true, dd = true, str = true}
local PVPs = {}
local playerPVP = {}

function startPVP(player1, player2, rounds, amount)
	local room1 = exports.USGrooms:getPlayerRoom(player1)
	local room2 = exports.USGrooms:getPlayerRoom(player2)
	if(room1 ~= room2 or not raceRooms[room1]) then return false end
	local pvp = {player1 = player1, player2 = player2, amount = amount, rounds = rounds, active = false,
		player1Rounds = 0, player2Rounds = 0}
	playerPVP[player1] = pvp
	playerPVP[player2] = pvp
	takePlayerMoney(player1, amount)
	takePlayerMoney(player2, amount)
	table.insert(PVPs, pvp)
end

function stopPVP(pvp)
	for i, aPVP in ipairs(PVPs) do
		if(aPVP = pvp) then
			table.remove(PVPs, i)
			break
		end
	end
	playerPVP[pvp.player1] = nil
	playerPVP[pvp.player2] = nil
	return true	
end

function abortPVP(pvp)
	if(isElement(pvp.player1)) then
		givePlayerMoney(pvp.player1, pvp.amount)
	end
	if(isElement(pvp.player2)) then
		givePlayerMoney(pvp.player2, pvp.amount)
	end
	stopPVP(pvp)
end

function declarePVPWinner(pvp, winner)
	givePlayerMoney(winner, pvp.amount*2)
end

function onPlayerWasted()
	if(playerPVP[source]) then
		local pvp = playerPVP[source]
		if(pvp.active) then
			local var = pvp.player1 == source and "player1Rounds" or "player2Rounds"
			pvp[var] = pvp[var] + 1
			if(pvp[var] >= pvp.rounds) then
				declarePVPWinner(pvp, source)
				stopPVP(pvp)
			end
		end
	end
end