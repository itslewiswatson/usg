addEvent("USGdm_room.prepareRound", true)
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
	end
end
addEventHandler("USGdm_room.prepareRound", root, prepareRound)

local roundWinner = false
local startAnnounceTick = 0

addEvent("USGdm.announceWinner", true)
function announceWinner()
	if(exports.USGrooms:getPlayerRoom() ~= "dm") then return false end

	if(not roundWinner) then
		addEventHandler("onClientRender", root, renderWinner)
	end
	roundWinner = source
	startAnnounceTick = getTickCount()	
end
addEventHandler("USGdm.announceWinner", root, announceWinner)

addEvent("onPlayerExitRoom", true)
function stopAnnouncingWinner()
	if(roundWinner) then
		roundWinner = false
		removeEventHandler("onClientRender", root, renderWinner)
	end
end
addEventHandler("onPlayerExitRoom", localPlayer, 
	function (prevRoom)
		if(prevRoom == "dm") then
			setPedCanBeKnockedOffBike(localPlayer, true)
		end
		stopAnnouncingWinner()
	end
)

addEvent("onPlayerJoinRoom", true)
addEventHandler("onPlayerJoinRoom", localPlayer, 
	function (room)
		if(room == "dm") then
			setPedCanBeKnockedOffBike(localPlayer, false)
		end
	end
)

addEvent("USGdm.roundEnd", true)
function onRoundEnd()
	exports.USGrace_ranklist:clear()
	stopAnnouncingWinner()
end
addEventHandler("USGdm.roundEnd", root, onRoundEnd)

local screenWidth, screenHeight = guiGetScreenSize()
function renderWinner()
	if(isElement(roundWinner) and getTickCount() - startAnnounceTick < 5000) then
		local name = getPlayerName(roundWinner)
		dxDrawText("Winner:\n\n"..name, 0, 0, screenWidth, screenHeight, tocolor(180,255,180),4,"default-bold","center","center")
	else
		stopAnnouncingWinner()
	end
end

addEvent("USGdm_room.playerWasted", true)
function onPlayerWasted(rank, time, nick)
	exports.USGrace_ranklist:add(source, rank, time, nick)
end
addEventHandler("USGdm_room.playerWasted", root, onPlayerWasted)