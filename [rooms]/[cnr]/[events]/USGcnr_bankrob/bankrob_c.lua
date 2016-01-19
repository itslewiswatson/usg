local started = false
local teams
local myTeam
local killCount = {}
local bestCop
local secondCop
local bestCrim
local secondCrim

addEvent("USGcnr_bankrob.onRobSignup", true)
function onBankRobSignup(team)
	addEventHandler("onClientPlayerDamage", localPlayer, onDamage)
	setCameraClip(true, true)
	activeStage = 0
	myTeam = team
	killCount = {}
end
addEventHandler("USGcnr_bankrob.onRobSignup", localPlayer, onBankRobSignup)

addEvent("USGcnr_bankrob.onRobStart", true)
function onBankRobStart(nTeams)
	teams = nTeams
	started = true
	addEventHandler("onClientRender", root, drawStats)
	deadCops = 0
	deadCriminals = 0
	activeStage = 1
end
addEventHandler("USGcnr_bankrob.onRobStart", localPlayer, onBankRobStart)

function onDamage(attacker, weapon)
	if(exports.USGcnr_jobs:getPlayerJob(attacker) == "medic") then
		cancelEvent()
		return
	end
	-- disable friendly fire
	for i, player in ipairs(teams[myTeam]) do
		if(player == attacker) then
			cancelEvent()
			return
		end
	end
	-- disable explosives
	if((weapon >= 16 and weapon <= 18) or weapon == 39 or weapon == 40) then
		cancelEvent()
		return
	end
end

addEvent("USGcnr_bankrob.onRobStop", true)
function onBankRobStop()
	if(started) then
		removeEventHandler("onClientRender", root, drawStats)
	end
	removeEventHandler("onClientPlayerDamage", localPlayer, onDamage)
	teams = nil
	myTeam = nil
	killCount = nil
end
addEventHandler("USGcnr_bankrob.onRobStop", localPlayer, onBankRobStop)

addEvent("USGcnr_bankrob.onStageStarted", true)
function onStageStarted(stage)
	activeStage = stage
	exports.USGmsg:msg((myTeam == "criminal" and "Reach" or "Defend").." the new checkpoint!",0,255,0)
end
addEventHandler("USGcnr_bankrob.onStageStarted", localPlayer, onStageStarted)

addEvent("USGcnr_bankrob.onPlayerDeath", true)
function onPlayerDeath(team)
	if(not killCount[source]) then killCount[source] = 1 
	else killCount[source] = killCount[source] + 1 end	
	if(team == "cop") then
		deadCops = deadCops + 1
		if(not bestCrim or killCount[bestCrim] < killCount[source]) then
			secondCrim = bestCrim
			bestCrim = source
		elseif(not secondCrim or killCount[secondCrim] < killCount[source]) then
			secondCrim = source
		end
	elseif(team == "criminal") then
		deadCriminals = deadCriminals + 1
		if(not bestCop or killCount[bestCop] < killCount[source]) then
			secondCop = bestCop
			bestCop = source
		elseif(not secondCop or killCount[secondCop] < killCount[source]) then
			secondCop = source
		end
	end
end
addEventHandler("USGcnr_bankrob.onPlayerDeath", root, onPlayerDeath)

local screenWidth, screenHeight = guiGetScreenSize()
local STATS_WIDTH, STATS_HEIGHT = 250, 300
local STATS_X, STATS_Y = screenWidth-STATS_WIDTH-5, screenHeight-200-STATS_HEIGHT

function drawStats()
	dxDrawRectangle(STATS_X, STATS_Y, STATS_WIDTH, STATS_HEIGHT, tocolor(0,0,0,150))
	dxDrawText("BANK ROB", STATS_X, STATS_Y, STATS_X+STATS_WIDTH, STATS_Y+40, tocolor(255,128,0),1.3, "bankgothic", "center", "top")
	dxDrawText("dead cops: "..deadCops, STATS_X+5, STATS_Y+40, STATS_X+STATS_WIDTH, STATS_Y+70, tocolor(0,0,255),0.8, "bankgothic", "left", "center")
	dxDrawText("dead criminals: "..deadCriminals, STATS_X+5, STATS_Y+70, STATS_X+STATS_WIDTH, STATS_Y+100, tocolor(255,0,0),0.8, "bankgothic", "left", "center")
	dxDrawText("Top cop: "..(isElement(bestCop) and getPlayerName(bestCop) or "-"), STATS_X+5, STATS_Y+130, STATS_X+STATS_WIDTH, STATS_Y+160, tocolor(0,0,255),0.5, "bankgothic", "left", "center")
	dxDrawText("Second cop: "..(isElement(secondCop) and getPlayerName(secondCop) or "-"), STATS_X+5, STATS_Y+160, STATS_X+STATS_WIDTH, STATS_Y+190, tocolor(0,0,255),0.5, "bankgothic", "left", "center")
	dxDrawText("Top criminal: "..(isElement(bestCrim) and getPlayerName(bestCrim) or "-"), STATS_X+5, STATS_Y+190, STATS_X+STATS_WIDTH, STATS_Y+220, tocolor(255,0,0),0.5, "bankgothic", "left", "center")
	dxDrawText("Second criminal: "..(isElement(secondCrim) and getPlayerName(secondCrim) or "-"), STATS_X+5, STATS_Y+220, STATS_X+STATS_WIDTH, STATS_Y+250, tocolor(255,0,0),0.5, "bankgothic", "left", "center")
	dxDrawText("stage: "..activeStage, STATS_X+5, STATS_Y+250, STATS_X+STATS_WIDTH, STATS_Y+STATS_HEIGHT, tocolor(255,128,0),0.8, "bankgothic", "left", "center")
end
