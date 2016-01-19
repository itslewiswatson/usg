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

-- *** job ***
local onJob = {}

addEvent("onPlayerChangeJob", true)
function onJobChange(job)
	if(job == jobID) then
		giveWeapon(source, 3, 1)
		giveWeapon(source, 43, 5000)
		onJob[source] = true
	elseif(onJob[source]) then
		takeWeapon(source, 3)
		takeWeapon(source, 43)
		onJob[source] = false
	end
end
addEventHandler("onPlayerChangeJob", root, onJobChange)

local arrestedPlayers = {}
local copArrestedPlayers = {}

local nightStickHits = {}

addEvent("onPlayerAttemptArrest")
addEvent("USGcnr_job_police.onNightStickHit", true)
function onPlayerNightStickHit(criminal)
	if(exports.USGcnr_jobs:getPlayerJobType(client) ~= jobType) then return end
	if(not triggerEvent("onPlayerAttemptArrest", client, criminal)) then
		return false
	end
	if(exports.USGcnr_jobs:getPlayerJobType(criminal) == "staff") then return end
	if(not nightStickHits[criminal]) then nightStickHits[criminal] = {} end
	table.insert(nightStickHits[criminal], {cop = client, tick = getTickCount()})
	if(#nightStickHits[criminal] >= 2) then
		if(nightStickHits[criminal][1].tick < getTickCount() - 30000) then
			table.remove(nightStickHits[criminal], 1)
		else
			onPlayerArrest(client, criminal)
		end
	else
		exports.USGmsg:msg(client, "Hit the criminal one more time to arrest him!", 255,128,0)
	end
end
addEventHandler("USGcnr_job_police.onNightStickHit", root, onPlayerNightStickHit)

addEvent("onPlayerArrested")
function onPlayerArrest(cop, criminal)
	if(exports.USGcnr_jail:isJailOpen())then 
	exports.USGmsg:msg(cop, "You cannot arrest anyone while jail doors are open!", 0, 255,0)
	return
	end
	if(arrestedPlayers[criminal]) then return end
		arrestedPlayers[criminal] = cop
			if(nightStickHits[criminal]) then
				for i, hit in ipairs(nightStickHits[criminal]) do
					if(hit.cop ~= cop and hit.tick > getTickCount() - 30000) then
						exports.USGmsg:msg(hit.cop, "You have assisted in arresting "..getPlayerName(criminal).." and earned 1.5 score.", 0, 255,0)
						exports.USGcnr_score:givePlayerScore(hit.cop, 1.5)
					end
				end
				nightStickHits[criminal] = nil
			end
			exports.USGmsg:msg(cop, "You have arrested "..getPlayerName(criminal)..". Jail him at a nearby Police Department.", 0, 255,0)
			exports.USGmsg:msg(criminal, "You have been arrested by "..getPlayerName(cop)..".", 255, 128,0)
			triggerClientEvent(criminal, "USGcnr_job_police.startFollow", cop)
			triggerEvent("onPlayerArrested", criminal, cop)
			triggerClientEvent(cop, "onPlayerArrested", criminal, cop)
			triggerClientEvent(criminal, "onPlayerArrested", criminal, cop)
			if(not copArrestedPlayers[cop]) then
				copArrestedPlayers[cop] = { criminal }
				addEventHandler("onPlayerChangeJob", cop, onCopChangeJob)
				addEventHandler("onPlayerWasted", cop, onCopWasted)
			else
				table.insert(copArrestedPlayers[cop], criminal)
			end
end

function onCopWasted()
	releaseCopPlayers(source)
end

function onCopChangeJob()
	releaseCopPlayers(source)
end

function releaseCopPlayers(player)
	if(not copArrestedPlayers[player]) then return false end
	for i, criminal in ipairs(copArrestedPlayers[player]) do
		releasePlayer(criminal, true)
	end
	removeEventHandler("onPlayerChangeJob", player, onCopChangeJob)
	removeEventHandler("onPlayerWasted", player, onCopWasted)
	copArrestedPlayers[player] = nil
end

function isPlayerArrested(player)
	return isElement(player) and arrestedPlayers[player] ~= nil
end

addEvent("onPlayerSuicide", true)
addEventHandler("onPlayerSuicide", root, function () if(isPlayerArrested(source)) then cancelEvent() end end) -- prevent suicide when arrested

function releasePlayer(criminal, manualRemoveFromCop)
	if(not isPlayerArrested(criminal)) then return false end
	local cop = arrestedPlayers[criminal]
	triggerClientEvent(criminal, "USGcnr_job_police.stopFollow", criminal)
	arrestedPlayers[criminal] = nil
	if(not manualRemoveFromCop and copArrestedPlayers[cop]) then
		for i, arrestedPlayer in ipairs(copArrestedPlayers[cop]) do
			if(arrestedPlayer == criminal) then
				table.remove(copArrestedPlayers[cop], i)
				break
			end
		end
		if(#copArrestedPlayers[cop] == 0) then
			removeEventHandler("onPlayerChangeJob", cop, onCopChangeJob)
			removeEventHandler("onPlayerWasted", cop, onCopWasted)
			copArrestedPlayers[cop] = nil
		end
	end
	return true
end

addCommandHandler("release",
	function (pSource, cmd, pName)
		if(exports.USGcnr_jobs:getPlayerJobType(pSource) ~= jobType) then return end
		if(pName ~= "*") then
			local target = getCNRPlayerFromNamePart(pName)
			if(not target) then
				exports.USGmsg:msg(pSource,"This player was not found!", 255,0,0)
				return false
			end
			if(not isPlayerArrested(target) or arrestedPlayers[target] ~= pSource) then
				exports.USGmsg:msg(pSource,"You didn't arrest this player!", 255,0,0)
				return false
			end
			releasePlayer(target)
			exports.USGmsg:msg(target, "You have been released by "..getPlayerName(pSource).."!",0,255,0)
			exports.USGmsg:msg(pSource, "You have released "..getPlayerName(target).."!",255,128,0)	
		else
			exports.USGmsg:msg(pSource, "You have released all the players you arrested!",255,128,0)
			releaseCopPlayers(pSource)
		end
	end
)

addEvent("onPlayerHitJailMarker", true)
function onJailMarkerHit(player, jail)
	if(arrestedPlayers[player]) then
		jailArrestedPlayer(player, arrestedPlayers[player], jail)
		releasePlayer(player)
	end
end
addEventHandler("onPlayerHitJailMarker", root, function (...) onJailMarkerHit(source, ...) end)

function jailArrestedPlayer(criminal, cop, jail, useAccount)
	local wlvl = exports.USGcnr_wanted:getPlayerWantedLevel(criminal)
	if(not useAccount) then
		exports.USGcnr_jail:jailPlayer(criminal, wlvl*3, jail, getPlayerName(cop))
	else
		exports.USGcnr_jail:jailAccount(exports.USGaccounts:getPlayerAccount(criminal),wlvl*3,jail)
	end
	exports.USGcnr_wanted:setPlayerWantedLevel(criminal, 0)
	if(isElement(cop) and exports.USGrooms:getPlayerRoom(cop) == "cnr") then
		local reward = math.random(wlvl * 150, wlvl * 155)
		exports.USGmsg:msg(cop, "You have jailed "..getPlayerName(criminal).." and earned "..exports.USG:formatMoney(reward)..".", 0, 255,0)
		givePlayerMoney(cop, reward)
		exports.USGplayerstats:incrementPlayerStat(cop, "cnr_arrests", 1)
		exports.USGcnr_score:givePlayerScore(cop, 3)
	end
	exports.USGmsg:msg(criminal, "You have been jailed ".. (isElement(cop) and ("by "..getPlayerName(cop)) or "")..".", 255, 128,0)
end

addEvent("onPlayerExitRoom", true)
function onPlayerQuit(room)
	if(arrestedPlayers[source]) then
		jailArrestedPlayer(source, arrestedPlayers[source], "LV",true)
		releasePlayer(source)
	elseif((room and room == "cnr" or exports.USGrooms:getPlayerRoom(source) == "cnr") 
	and exports.USGcnr_wanted:getPlayerWantedLevel(source) > 0) then
		local jailed = false
		if(nightStickHits[source]) then -- if player recently got hit with nightstick, jail him for evasion
			for i, hit in ipairs(nightStickHits[source]) do
				if(isElement(hit.cop) and getTickCount()-hit.tick < 60000) then
					jailed = true
					jailArrestedPlayer(source, hit.cop, "LV",true)
					break
				end
			end
		end
		if(not jailed) then -- jail criminals if they are nearby a cop
			local x,y,z = getElementPosition(source)
			local closest = nil
			local distance = 200 -- max distance of 200
			for i, player in ipairs(getElementsByType("player")) do
				if(exports.USGrooms:getPlayerRoom(player) == "cnr" and exports.USGcnr_jobs:getPlayerJobType(player) == jobType) then
					local px,py,pz = getElementPosition(player)
					local dist = getDistanceBetweenPoints2D(x,y,px,py)
					if(dist < distance and math.abs(pz-z) < 150) then -- max Z offset of 150
						closest = player
						distance = dist
					end
				end
			end
			if(closest) then
				jailArrestedPlayer(source, closest, "LV", true)
			end
		end
	end
	releaseCopPlayers(source)
	nightStickHits[source] = nil
end
addEventHandler("onPlayerExitRoom", root, onPlayerQuit)
addEventHandler("onPlayerQuit", root, onPlayerQuit)

function getCNRPlayerFromNamePart(name)
	local name = name:lower()
	local target = false
	local matchCount = 0
	for i, player in ipairs(getElementsByType("player")) do
		if(exports.USGrooms:getPlayerRoom(player) == "cnr") then
			local startMatch, endMatch = getPlayerName(player):lower():find(name)
			if(startMatch and endMatch) then
				if(not target) then
					target = player
				else
					local count = #getPlayerName(player)-math.abs(endMatch-startMatch)
					if(count > matchCount) then
						matchCount = count
						target = player
					end
				end
			end
		end
	end
	return target
end

function finePlayer(pSource, cmd, playername)
	if(exports.USGcnr_jobs:getPlayerJobType(pSource) == jobType) then
		if(not playername or #playername == 0) then
			exports.USGmsg:msg(pSource, "Syntax: /"..cmd.." <name>", 255,0,0)
			return false
		end
		local player = getCNRPlayerFromNamePart(playername)
		if(isElement(player)) then
			local px,py,pz = getElementPosition(player)
			local x,y,z = getElementPosition(pSource)
			local distance = getDistanceBetweenPoints3D(px,py,pz,x,y,z)
			if(distance > 6) then
				exports.USGmsg:msg(pSource, "This player is too far away, get closer to fine him.", 255, 0, 0)
				return false
			end
			local wantedLevel = exports.USGcnr_wanted:getPlayerWantedLevel(player)
			if(not isPlayerArrested(player) and wantedLevel > 0 and wantedLevel <= 2) then
				local amount = wantedLevel*350
				exports.USGcnr_wanted:setPlayerWantedLevel(player, 0)
				givePlayerMoney(pSource,amount+200)
				takePlayerMoney(player, amount)
				exports.USGcnr_score:givePlayerScore(pSource, 1.5)
				exports.USGmsg:msg(pSource, "You have fined "..getPlayerName(player).." and earned $"..(amount+200).." and 1.5 score.",0,255,0)
				exports.USGmsg:msg(player, "You have been fined by "..getPlayerName(pSource).." and paid $"..amount..".",255,128,0)
			else
				exports.USGmsg:msg(pSource, "This player does not need to be fined.",255,0,0)
				return false
			end
		else
			exports.USGmsg:msg(pSource, "Could not find a player with that name!",255,0,0)
			return false
		end
	end
end
addCommandHandler("fine", finePlayer)

addEventHandler("onVehicleEnter", root,
	function (player, eSeat, jacked) -- arrest all wanted occupants if a cop enters a vehicle as driver
		if(exports.USGrooms:getPlayerRoom(player) ~= "cnr" or exports.USGcnr_jobs:getPlayerJobType(player) ~= jobType) then return end
		if(eSeat == 0) then
			for seat=1,getVehicleMaxPassengers(source) do
				local occupant = getVehicleOccupant(source, seat)
				if(occupant) then
					local wlvl = exports.USGcnr_wanted:getPlayerWantedLevel(occupant)
					if(wlvl > 0) then
						onPlayerArrest(player, occupant)
					end
				end
			end
		end
		if(jacked) then
			local wlvl = exports.USGcnr_wanted:getPlayerWantedLevel(jacked)
			if(wlvl > 0) then
				onPlayerArrest(player, jacked)
			end
		end		
	end
)

-- following
addEvent("USGcnr_job_police.warpIntoCopVehicle", true)
addEventHandler("USGcnr_job_police.warpIntoCopVehicle", root,
	function ()
		if(arrestedPlayers[client]) then
			local cop = arrestedPlayers[client]
			local vehicle = getPedOccupiedVehicle(cop)
			if(vehicle) then
				local warped = false
				for seat=1, getVehicleMaxPassengers(vehicle) do -- skip driver seat
					if(not getVehicleOccupant(vehicle, seat)) then
						warpPedIntoVehicle(client, vehicle, seat)
						warped = true
					end
				end
				if(not warped) then
					releasePlayer(client)
				end
			end
		end
	end
)

addEvent("USGcnr_job_police.removeFromVehicle", true)
addEventHandler("USGcnr_job_police.removeFromVehicle", root,
	function ()
		if(arrestedPlayers[client]) then
			removePedFromVehicle(client)
		end
	end
)

---- tazer
local isTazed = {}
addEvent("onPlayerGetTazed")
addEvent("USGcnr_job_police.onTazerHit", true)
addEventHandler("USGcnr_job_police.onTazerHit", root,
	function (target)
		if(exports.USGcnr_jobs:getPlayerJobType(client) ~= jobType) then return end
		if(isTazed[target]) then return end
		local wlvl = exports.USGcnr_wanted:getPlayerWantedLevel(target)
		if(wlvl > 0) then
				setElementFrozen(target, true)
				setPedAnimation(target, "crack", "crckdeth1", -1, true, false, false)
				triggerClientEvent(target, "USGcnr_job_police.hitByTazer", target)
				triggerEvent("onPlayerGetTazed", target)
				setTimer(removeTazerEffect, 3500, 1, target)
				isTazed[target] = true
		end
	end
)

function removeTazerEffect(player)
	isTazed[player] = nil
	if(isElement(player)) then
		setPedAnimation(player)
		setElementFrozen(player, false)
	end
end