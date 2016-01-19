addEvent("USGdd_room.prepareRound", true)
function prepareRound(vehicles)
	-- init countdown
	exports.USGrace_countdown:startCountdown(4, true)
	-- spawn protection
	for i, vehicle in ipairs(vehicles) do
		for _,vehicle2 in ipairs(vehicles) do
			if(vehicle ~= vehicle2) then
				setElementCollidableWith(vehicle,vehicle2,false)
			end
		end
		setElementAlpha(vehicle, 200)
	end
end
addEventHandler("USGdd_room.prepareRound", root, prepareRound)

addEvent("USGdd_room.gameStopSpawnProtection", true)
function stopSpawnProtection(vehicles)
	for i, vehicle in ipairs(vehicles) do
		for _,vehicle2 in ipairs(vehicles) do
			if(vehicle ~= vehicle2) then
				setElementCollidableWith(vehicle,vehicle2,true)
			end
		end
		setElementAlpha(vehicle, 255)
	end
end
addEventHandler("USGdd_room.gameStopSpawnProtection", root, stopSpawnProtection)

local roundWinner = false

addEvent("USGdd.roundWon", true)
function onRoundWon()
	if(exports.USGrooms:getPlayerRoom() ~= "dd") then return false end
	roundWinner = source
	addEventHandler("onClientRender", root, renderWinner)
end
addEventHandler("USGdd.roundWon", root, onRoundWon)

addEvent("onPlayerExitRoom", true)
addEvent("USGdd.roundEnd", true)
function onRoundEnd()
	exports.USGrace_ranklist:clear()
	if(roundWinner) then
		removeEventHandler("onClientRender", root, renderWinner)
	end
	roundWinner = false
end
addEventHandler("USGdd.roundEnd", root, onRoundEnd)
addEventHandler("onPlayerExitRoom", localPlayer, onRoundEnd)

local screenWidth, screenHeight = guiGetScreenSize()
function renderWinner()
	if(isElement(roundWinner)) then
		local name = getPlayerName(roundWinner)
		dxDrawText("Winner:\n\n"..name, 0, 0, screenWidth, screenHeight, tocolor(180,255,180),4,"default-bold","center","center")
	end
end

addEvent("USGdd_room.playerWasted", true)
function onPlayerWasted(rank, time, nick)
	exports.USGrace_ranklist:add(source, rank, time, nick)
end
addEventHandler("USGdd_room.playerWasted", root, onPlayerWasted)