local COP_SIGNUPS = {
	{x = 592.8720703125, y = -1249.3037109375, z = 18.185718536377, tx = 432.45, ty = -2494.94, tz = 30.81,}, -- front
	{x=591.16015625, y=-1260.3203125, z=64.1875, tx = 442.63, ty = -2520.57, tz = 70.05}, -- roof
}
local CRIM_SIGNUPS = {
	{x = 597.0390625, y = -1248.0537109375, z = 18.25, tx = 475.08, ty = -2556.46, tz = 52.64}, -- front
	{x=593.16015625, y=-1268.3203125, z=64.1875, tx = 442.63, ty = -2520.57, tz = 70.05}, -- roof
}

local STAGES = {
	{x = 459.345703125, y = -2525.7021484375, z = 52.6328125,},
	{x = 470.568359375, y = -2531.2138671875, z = 47.440944671631},
	{x = 468.16796875, y = -2537.7294921875, z = 40.160362243652},
	{x = 446.55078125, y = -2489.42578125, z = 30.815937042236},
}

addEvent("onPlayerAttemptArrest")

local KILL_REWARD = 5000
local REWARD = 13500
local MINIMUM_CRIMINALS = 5

local ROB_INTERVAL = 1800000 -- 30 minutes
local ROB_TIME_LIMIT = 360000 -- 6 minutes

function teleportPlayer(player, x, y, z, dimension)
	fadeCamera(player, false)
	setElementFrozen(player, true)
	setTimer(startPlayerTeleport, 1000, 1, player, x,y, z, dimension)
end

function startPlayerTeleport(player,x,y,z,dimension)
	if(isElement(player)) then	
		setElementDimension(player, dimension)
		setElementPosition(player, x,y,z)
		setTimer(fadePlayerCamera, 500, 1, player)
		setTimer(unfreezePlayer, 2000, 1, player)
	end
end	

function fadePlayerCamera(player)
	if(isElement(player)) then 
		fadeCamera(player, true) 
		setCameraTarget(player, player)
	end
end

function unfreezePlayer(player)
	if(isElement(player)) then setElementFrozen(player, false) end
end

local markerID = {}

local signupsCop = {}
local signupsCrim = {}
local exitMarkers = {}

local splitReward
local cantRejoin = {}
local activeStage
local stageMarker
local stageBlip
local bankGate
local signupID = {}
local isMedic = {}
local participates = {}
local leftBank = {}
local bankZoneCol

local GlobalTimer
local timeLimitTimer

local ID = 2

addEvent("onPlayerChangeJob")
function startSignup()
	for i, marker in ipairs(signupsCop) do
		if(isElement(marker)) then destroyElement(marker) end
	end
	for i, marker in ipairs(signupsCrim) do
		if(isElement(marker)) then destroyElement(marker) end
	end		
	bankGate = createObject( 11416, 479.29998779297, -2524.1999511719, 49.400001525879, 0, 0, 300 )
	setElementDimension(bankGate, DIMENSION)
	signupsCop = {}
	signupsCrim = {}
	cantRejoin = {}
	leftBank = {}
	cops = {}
	criminals = {}
	isMedic = {}
	participates = {}
	activeStage = 0
	for i, signup in ipairs(COP_SIGNUPS) do
		local marker = createMarker(signup.x,signup.y,signup.z-1, "cylinder", 2,0,0,255)
		setElementDimension(marker, exports.USGrooms:getRoomDimension("cnr"))
		addEventHandler("onMarkerHit", marker, onSignupAsCop)
		table.insert(signupsCop, marker)
		markerID[marker] = i
	end
	for i, signup in ipairs(CRIM_SIGNUPS) do
		local marker = createMarker(signup.x,signup.y,signup.z-1, "cylinder", 2,255,0,0)
		setElementDimension(marker, exports.USGrooms:getRoomDimension("cnr"))
		addEventHandler("onMarkerHit", marker, onSignupAsCrim)
		table.insert(signupsCrim, marker)
		markerID[marker] = i
	end
	for i, player in ipairs(getElementsByType("player")) do
		if(exports.USGrooms:getPlayerRoom(player) == "cnr") then
			exports.USGmsg:msg(player, "You can now sign up for bankrob in LS!", 0, 255, 0)
		end
	end
end

function onSignupAsCop(hitElement, dimensions)
	if(not dimensions or not exports.USG:validateMarkerZ(source,hitElement)) then return end
	if(getElementType(hitElement) ~= "player" or exports.USGrooms:getPlayerRoom(hitElement) ~= "cnr") then return end
	if(participates[hitElement]) then
		exports.USGmsg:msg(hitElement, "You are already participating in the bankrob.",255,0,0)
		return false
	elseif(cantRejoin[hitElement]) then
		exports.USGmsg:msg(hitElement, "You died and can't come back.",255,0,0)
		return false		
	end
	if(exports.USGcnr_jobs:getPlayerJobType(hitElement) ~= "police" and exports.USGcnr_jobs:getPlayerJob(hitElement) ~= "medic") then
		exports.USGmsg:msg(hitElement, "You have to be police or medic to sign up here. Criminals can sign up at the red marker.",255,0,0)
		return false
	end
	signupID[hitElement] = markerID[source]
	table.insert(cops, hitElement)
	cantRejoin[hitElement] = true
	signupPlayer(hitElement, "cop")
	addEventHandler("onPlayerAttemptArrest", hitElement, onCopAttemptArrest)
	local signup = COP_SIGNUPS[markerID[source]]
	teleportPlayer(hitElement, signup.tx, signup.ty, signup.tz, DIMENSION)
end

function onSignupAsCrim(hitElement, dimensions)
	if(not dimensions or not exports.USG:validateMarkerZ(source,hitElement)) then return end
	if(getElementType(hitElement) ~= "player" or exports.USGrooms:getPlayerRoom(hitElement) ~= "cnr") then return end
	if(participates[hitElement]) then
		exports.USGmsg:msg(hitElement, "You are already participating in the bankrob or died and can't come back.",255,0,0)
		return false
	end	
	if(exports.USGcnr_jobs:getPlayerJobType(hitElement) ~= "criminal" and exports.USGcnr_jobs:getPlayerJob(hitElement) ~= "medic") then
		exports.USGmsg:msg(hitElement, "You have to be criminal or medic to sign up here. Cops can sign up at the blue marker.",255,0,0)
		return false
	end
	signupID[hitElement] = markerID[source]
	table.insert(criminals, hitElement)
	signupPlayer(hitElement, "criminal")
	local signup = CRIM_SIGNUPS[markerID[source]]
	teleportPlayer(hitElement, signup.tx, signup.ty, signup.tz, DIMENSION)
end
addEvent("onPlayerExitRoom")
function signupPlayer(player, team)
	if(isPedInVehicle(player)) then removePedFromVehicle(player) end
	isMedic[player] = exports.USGcnr_jobs:getPlayerJob(player) == "medic"
	participates[player] = true
	triggerClientEvent(player, "USGcnr_bankrob.onRobSignup", player, team)
	addEventHandler("onPlayerWasted", player, onPlayerWasted)
	addEventHandler("onPlayerChangeJob", player, onPlayerChangeJob)
	addEventHandler("onPlayerExitRoom", player, onPlayerQuit)
	addEventHandler("onPlayerQuit", player, onPlayerQuit)
	if(#criminals >= MINIMUM_CRIMINALS) then
		for i, marker in ipairs(signupsCop) do
			if(isElement(marker)) then destroyElement(marker) end
		end
		for i, marker in ipairs(signupsCrim) do
			if(isElement(marker)) then destroyElement(marker) end
		end	
		startBankRob()
	else
		exports.USGmsg:msg(player, "You have signed up for the bank rob. It will start when there are "..MINIMUM_CRIMINALS.." criminals.",0,255,0)
	end
	return true
end

function startBankRob()
	moveObject(bankGate, 5000, 490, -2524.1999511719, 52.400001525879)
	startStage(1)
	local teams = {criminal = criminals, cop = cops}
	for i, crim in ipairs(criminals) do
		exports.USGcnr_wanted:givePlayerWantedLevel(crim, 6)
		triggerClientEvent(crim, "USGcnr_bankrob.onRobStart", crim, teams, "criminal")
	end	
	for i, cop in ipairs(cops) do
		triggerClientEvent(cop, "USGcnr_bankrob.onRobStart", cop, teams, "cop")
	end
	timeLimitTimer = setTimer(timeLimitPassed, ROB_TIME_LIMIT, 1)
end

function timeLimitPassed()
	local copI = 0
	for i, crim in ipairs(criminals) do
		copI = copI+1
		local cop = cops[copI]
		if(isMedic[cop]) then -- dont count medics
			copI = copI + 1
			cop = cops[copI]
		end
		if(not cop) then
			copI = 1
			cop = cops[1]
		end
		exports.USGmsg:msg(crim, "You didn't complete the rob in time!", 255, 0, 0)
		if(activeStage < 5) then -- criminals are still inside
			if(isElement(cop)) then
				exports.USGcnr_job_police:jailArrestedPlayer(crim, cop, "LS")
				givePlayerMoney(cop, KILL_REWARD)
			else
				local wlvl = exports.USGcnr_wanted:getPlayerWantedLevel(crim)
				exports.USGcnr_jail:jailPlayer(crim, wlvl*3, "LS")
				exports.USGcnr_wanted:setPlayerWantedLevel(crim, 0)
			end
		end
	end
	for i, cop in ipairs(cops) do
		exports.USGmsg:msg(cop, "You defended the bank for long enough!", 0, 255, 0)
	end
	stopBankRob()
end

function stopBankRob()
	if(activeStage) then
		if(isTimer(timeLimitTimer)) then killTimer(timeLimitTimer) end
		if(activeStage == 5 and isElement(bankZoneCol)) then destroyElement(bankZoneCol) end
		destroyElement(bankGate)
		for i, marker in ipairs(exitMarkers) do
			if(isElement(marker)) then 
				destroyElement(marker)
			end
		end
		for i, crim in ipairs(criminals) do
			removePlayer(crim) -- don't give index or team, we will empty table manually
		end
		criminals = {}
		for i, cop in ipairs(cops) do
			removePlayer(cop) -- don't give index or team, we will empty table manually
		end
		cops = {}
		exitMarkers = {}

		GlobalTimer = setTimer(startSignup, ROB_INTERVAL, 1)
		activeStage = false
	end
end

addCommandHandler("banktime", 
	function(pSource)
		if(exports.USGrooms:getPlayerRoom(pSource) == "cnr") then
			if(isTimer(GlobalTimer)) then
				local timeLeft, _,_ = getTimerDetails(GlobalTimer)
				local minutes = math.floor(timeLeft/60000)
				local seconds = math.floor((timeLeft-(minutes*60000))/1000)
				exports.USGmsg:msg(pSource, string.format("The signup will start in %02i minute(s) and %02i second(s).", minutes, seconds), 0, 255, 0)
			elseif(activeStage > 0) then
				exports.USGmsg:msg(pSource, "The bank rob already started.", 255, 0, 0)
			elseif(activeStage == 0) then
				exports.USGmsg:msg(pSource, "You can sign up now, criminals: "..#criminals.."/"..MINIMUM_CRIMINALS..".", 255, 128, 0)
			end
		end
	end
)

function onRobComplete() -- robbers will have to exit bank and obtain a safe distance to get a reward
	-- create exits
	for i, signup in ipairs(CRIM_SIGNUPS) do
		local marker = createMarker(signup.tx,signup.ty,signup.tz+0.5, "arrow", 1.5,255,255,0)
		setElementDimension(marker, DIMENSION)
		addEventHandler("onMarkerHit", marker, onExitRob)
		table.insert(exitMarkers, marker)
		markerID[marker] = i
	end
	bankZoneCol = createColSphere(CRIM_SIGNUPS[1].x,CRIM_SIGNUPS[1].y,CRIM_SIGNUPS[1].z, 500)
	addEventHandler("onColShapeLeave", bankZoneCol, onPlayerEscape)
	local nCrims = {}
	for i, crim in ipairs(criminals) do
		exports.USGmsg:msg(crim, "Exit the bank and evade the cops to claim your reward!", 0, 255, 0)
		if(not isMedic[crim]) then
			table.insert(nCrims, crim)
		else
			removePlayer(crim)
		end
	end
	criminals = nCrims -- remove medics from list
	for i, cop in ipairs(cops) do
		exports.USGmsg:msg(cop, "Prevent the criminals from getting away!", 255, 128, 0)
	end
	-- reset time limit
	if(isTimer(timeLimitTimer)) then killTimer(timeLimitTimer) end
	timeLimitTimer = setTimer(timeLimitPassed, ROB_TIME_LIMIT, 1)
end

function onPlayerEscape(hitElement, dimensions)
	if(exports.USGrooms:getPlayerRoom(hitElement) ~= "cnr" or not dimensions) then return end
	if(not leftBank[hitElement]) then return end
	if(isMedic[hitElement]) then return end
	for i, crim in ipairs(criminals) do
		if(crim == hitElement) then
			givePlayerMoney(crim, REWARD)
			exports.USGmsg:msg(crim, "You successfully escaped the bank rob and earned "..exports.USG:formatMoney(REWARD), 0, 255, 0)
			removePlayer(crim, "criminal", i)
			break
		end
	end
	if(#criminals == 0) then
		stopBankRob()
	end
end

function onExitRob(hitElement, dimensions)
	if(exports.USGrooms:getPlayerRoom(hitElement) ~= "cnr" or not dimensions) then return end
	if(not exports.USG:validateMarkerZ(source, hitElement)) then return end
	local signupID = markerID[source]
	local signup = CRIM_SIGNUPS[signupID]
	teleportPlayer(hitElement, signup.x, signup.y, signup.z, 0)
	leftBank[hitElement] = true
end

function startStage(stage)
	if(STAGES[stage]) then
		stageMarker = createMarker(STAGES[stage].x, STAGES[stage].y, STAGES[stage].z-1,"cylinder",2.5,255,0,0)
		setElementDimension(stageMarker, DIMENSION)
		stageBlip = createBlip(STAGES[stage].x, STAGES[stage].y, STAGES[stage].z, 0, 3)
		setElementDimension(stageBlip, DIMENSION)
		setElementVisibleTo(stageBlip, root, false)
		addEventHandler("onMarkerHit", stageMarker, onCheckpointHit)
		activeStage = stage
		for i, crim in ipairs(criminals) do
			--exports.USGmsg:msg(crim, "Reach the new checkpoint!",0,255,0)
			triggerClientEvent(crim, "USGcnr_bankrob.onStageStarted", crim, activeStage)
			setElementVisibleTo(stageBlip, crim, true)
		end
		for i, cop in ipairs(cops) do
			--exports.USGmsg:msg(cop, "Defend the new checkpoint!",0,255,0)
			setElementVisibleTo(stageBlip, cop, true)
			triggerClientEvent(cop, "USGcnr_bankrob.onStageStarted", cop, activeStage)
		end
	else
		onRobComplete()
	end
end

function stageComplete(criminal)
	destroyElement(stageMarker)
	destroyElement(stageBlip)
	startStage(activeStage+1)
end

function onCheckpointHit(hitElement, dimensions)
	if(not dimensions or not exports.USG:validateMarkerZ(source,hitElement)) then return end
	if(isMedic[hitElement]) then return end
	for i, crim in ipairs(criminals) do
		if(hitElement == crim) then
			stageComplete(hitElement)
			break
		end
	end
end

function onCopAttemptArrest(criminal)
	cancelEvent()
	exports.USGmsg:msg(source, "You can not arrest players during the bank rob!", 255, 0, 0)
end

function removePlayer(player, team, index)
	if(not index) then
		if(team == "criminal") then
			for i, crim in ipairs(criminals) do
				if(crim == player) then index = i break end
			end
		elseif(team == "cop") then
			for i, cop in ipairs(cops) do
				if(cop == player) then index = i break end
			end		
		end
	end
	if(index and team) then
		table.remove((team == "criminal" and criminals or cops), index) -- remove from active teams
	end
	if(team == "cop") then
		removeEventHandler("onPlayerAttemptArrest", player, onCopAttemptArrest)
	end
	participates[player] = false
	signupID[player] = nil
	isMedic[player] = nil
	triggerClientEvent(player, "USGcnr_bankrob.onRobStop", player)
	removeEventHandler("onPlayerWasted", player, onPlayerWasted)
	removeEventHandler("onPlayerChangeJob", player, onPlayerChangeJob)
	removeEventHandler("onPlayerExitRoom", player, onPlayerQuit)
	removeEventHandler("onPlayerQuit", player, onPlayerQuit)	
	if(getElementDimension(player) == DIMENSION and not isPedDead(player) and not leftBank[player]) then -- put him outside
		teleportPlayer(player, COP_SIGNUPS[1].x,COP_SIGNUPS[1].y,COP_SIGNUPS[1].z, 0)
	end

	if(#criminals == 0 and activeStage ~= 0 and activeStage ~= 5) then
		local msg = "You killed all criminals and earned "..exports.USG:formatMoney(REWARD).."!"
		for i, cop in ipairs(cops) do
			exports.USGmsg:msg(cop, msg, 0, 255, 0)
			givePlayerMoney(cop, REWARD)
		end
		stopBankRob()
	end
end

function onPlayerQuit()
	local pTeamIndex
	local pTeam
	for i, crim in ipairs(criminals) do
		if(crim == source) then
			pTeam = "criminal"
			pTeamIndex = i
		end
	end
	if(not pTeam) then
		for i, cop in ipairs(cops) do
			if(cop == source) then
				pTeam = "cop"
				pTeamIndex = i
			end
		end
	end
	if(pTeam and pTeamIndex) then
		removePlayer(source, pTeam, pTeamIndex)
	end
end

addEvent("onPlayerChangeJob")
function onPlayerChangeJob(job)
	local pTeamIndex
	local pTeam
	for i, crim in ipairs(criminals) do
		if(crim == source) then
			pTeam = "criminal"
			pTeamIndex = i
		end
	end
	if(not pTeam) then
		for i, cop in ipairs(cops) do
			if(cop == source) then
				pTeam = "cop"
				pTeamIndex = i
			end
		end
	end
	if(pTeam and pTeamIndex) then
		removePlayer(source, pTeam, pTeamIndex)
	end
end

function onPlayerWasted(ammo, killer, weapon, bodypart, stealth)
	local pTeamIndex
	local pTeam
	local kTeam
	for i, crim in ipairs(criminals) do
		if(killer == crim) then
			kTeam = "criminal"
		elseif(crim == source) then
			pTeam = "criminal"
			pTeamIndex = i
		end
	end
	if(not (pTeam and kTeam)) then
		for i, cop in ipairs(cops) do
			if(killer == cop) then
				kTeam = "cop"
			elseif(cop == source) then
				pTeam = "cop"
				pTeamIndex = i
			end
		end
	end
	if(pTeam and pTeamIndex) then
		removePlayer(source, pTeam, pTeamIndex) -- remove from active teams
	end
	-- if the rob started, give rewards where needed and notify clients of killed player
	if(killer and activeStage > 0 and not isMedic[source]) then
		if(pTeam == "criminal" and kTeam == "cop") then
			exports.USGcnr_job_police:jailArrestedPlayer(source, killer, "LS")
			givePlayerMoney(killer, KILL_REWARD)
			exports.USGcnr_score:givePlayerScore(killer, 1)
		elseif(pTeam == "cop" and kTeam == "criminal") then
			givePlayerMoney(killer, KILL_REWARD)
			exports.USGmsg:msg(killer, "You have earned $5,000 and 2 score for killing "..getPlayerName(source))
			exports.USGcnr_score:givePlayerScore(killer, 2)
		end
		triggerClientEvent(cops, "USGcnr_bankrob.onPlayerDeath", killer, pTeam)
		triggerClientEvent(criminals, "USGcnr_bankrob.onPlayerDeath", killer, pTeam)
	end
end

addEventHandler("onResourceStop", resourceRoot, 
	function ()
		if(activeStage and activeStage ~= 5) then
			for i, cop in ipairs(cops) do
				setElementDimension(cop, 0)
				setElementPosition(cop, CRIM_SIGNUPS[1].x,CRIM_SIGNUPS[1].y,CRIM_SIGNUPS[1].z)
			end
			for i, crim in ipairs(criminals) do
				setElementDimension(crim, 0)
				setElementPosition(crim, COP_SIGNUPS[1].x,COP_SIGNUPS[1].y,COP_SIGNUPS[1].z)
			end
		end
	end
)

addEventHandler("onResourceStart", resourceRoot, startSignup)



addEventHandler("onResourceStart", root,
    function (res) -- init job if thisResource started, or if USGEventsApp (re)started
        if(res == resource or res == getResourceFromName("USGEventsApp")) then
        
        end
		if(res == resource)then
		startSignup()
		end
    end
)

addEventHandler ( "onResourceStop", resourceRoot, 
    function (  )
   end 
) 
