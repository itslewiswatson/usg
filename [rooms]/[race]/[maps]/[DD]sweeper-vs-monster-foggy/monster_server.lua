------------------------------------------------------------------------------------
-- PROJECT: Towers Mania DD
-- VERSION: 1.0
-- DATE: June 2013
-- DEVELOPERS: JR10
-- RIGHTS: All rights reserved by developers
------------------------------------------------------------------------------------

outputChatBox("Every 30 seconds a random player will get a monster", root, 255, 255, 0)

function pickLuckyPlayer()
	local picked = 0
	local players = exports.towers:getCurrentPlayers()
	if (players and #players == 0 and isTimer(pickTimer)) then killTimer(pickTimer) return end
	local tried = 0
	local player = players[math.random(#players)]
	while (isPedDead(player) or not isPedInVehicle(player) or getElementModel(getPedOccupiedVehicle(player)) == 556) do
		player = players[math.random(#players)]
		tried = tried + 1
		if (tried == #players) then
			if isTimer(pickTimer) then killTimer(pickTimer) return end
			break
		end
	end
	if (not isPedDead(player) and isPedInVehicle(player) and getElementModel(getPedOccupiedVehicle(player)) ~= 556) then
		outputChatBox("Warning: "..getPlayerName(player).." got a monster!", root, 255, 0, 0)
		setElementModel(getPedOccupiedVehicle(player), 556)
		picked = picked + 1
		if (picked == players and isTimer(pickTimer)) then killTimer(pickTimer) end
	end
end
pickTimer = setTimer(pickLuckyPlayer, 30000, 0)