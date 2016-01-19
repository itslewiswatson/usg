local activePunishments = {}
local playerMutes = {}

function onJailTimeCallback(result, account, duration)
	if(result) then
		if(result.jailtime == 0 or not result.jail) then
			exports.MySQL:execute("UPDATE cnr_accounts SET jail='LV',jailtime=? WHERE username=?",result.jailtime+duration,account)
		else
			exports.MySQL:execute("UPDATE cnr_accounts SET jailtime=? WHERE username=?",result.jailtime+duration,account)
		end
	end
end

function jailPlayer(player, jailer, duration)
	if ( isElement(player) ) then
		exports.USGcnr_jail:jailPlayer(player, duration, "LV", jailer)
	end
end

function kickPlayer(player,kicker,reason)
	if ( isElement(player) ) then
		kickPlayer(player,getPlayerName(kicker) or "USG", reason)
	end
end

function mutePlayer(player,duration,muteType,reason)
	if ( isElement(player) ) then
		playerMutes[player] = muteType
	end
end

function getPlayerMute(player)
	return playerMutes[player]
end

function addActivePunishment(account, punishment, duration, player)
	if(punishment == "jail") then
		if(not player or exports.USGrooms:getPlayerRoom(player) ~= "cnr") then
			-- request jail time and add to that
			singleQuery(onJailTimeCallback, {account,duration},"SELECT jailtime FROM cnr__accounts WHERE username=?",account)
			return true
		else
			jailPlayer(player, "Staff",duration)
			return true
		end
	else
		local found = false
		if(player and activePunishments[player]) then
			for i, pPunishment in ipairs(activePunishments[player]) do
				if(pPunishment.punishment == punishment) then
					pPunishment.duration = pPunishment.duration + duration
					found = true
					break
				end
			end
		end
		if(found) then
			return true 
		else
			return insert(activePunishmentInserted, {account, punishment, duration, player},"INSERT INTO activepunishments ( username, punishment, duration ) VALUES ( ?, ?, ? )",account, punishment, duration)
		end
	end
end

function activePunishmentInserted(id, account, punishment, duration, player)
	applyPunishment(player, id, punishment, duration)
end

function applyPunishment(player, id, punishment, duration)
	if(not activePunishments[player]) then
		activePunishments[player] = { { id = id, punishment = punishment, duration = duration } }
	else
		table.insert(activePunishments[player], { id = id, punishment = punishment, duration = duration })
	end
	if(punishment:sub(0,4) == "mute") then
		mutePlayer(player, duration, punishment:sub(6),nil)
	elseif(punishment == "jail") then
		jailPlayer(player, punishment, duration)
	end
end

function onPunishmentEnd(player, punishment)
	for i, pPunishment in ipairs(activePunishments[player]) do
		if(pPunishment.id == punishment.id) then
			table.remove(activePunishments[player], i)
			break
		end
	end
	exports.MySQL:execute("DELETE FROM activepunishments WHERE id=?",punishment.id)
	-- undo effect
	if(punishment.punishment:sub(0,4) == "mute") then
		if(punishment.punishment:sub(6) == playerMutes[player]) then
			playerMutes[player] = nil
		end
	elseif(punishment.punishment == "jail") then
		exports.USGcnr_jail:unjailPlayer(player)
	end
end

function loadActivePunishments()

end

function loadPlayerActivePunishments(punishments, player)
	if(not isElement(player)) then return end
	for i, punishment in ipairs(punishments) do
		applyPunishment(player, punishment.id, punishment.punishment, punishment.duration)
	end
end

function loadActivePunishment(player, punishment)

end

function storeActivePunishments()
	for player, punishments in pairs(activePunishments) do
		storePlayerActivePunishments(player)
	end
end

function storePlayerActivePunishments(player)
	if(not activePunishments[player]) then return end
	for i, punishment in ipairs(activePunishments[player]) do
		exports.MySQL:execute("UPDATE activepunishments SET duration=? WHERE id=?",punishment.duration,punishment.id)
	end
end

function updateActivePunishments()
	for player, punishments in pairs(activePunishments) do
		for i, punishment in ipairs(punishments) do
			punishment.duration = punishment.duration - 1
			if(punishment.duration <= 0) then
				onPunishmentEnd(player, punishment)
			end
		end
		if(#activePunishments[player] == 0) then
			activePunishments[player] = nil
		end
	end
end

addEventHandler("onResourceStart", resourceRoot,
	function ()
		for i, player in ipairs(getElementsByType("player")) do
			if(exports.USGaccounts:isPlayerLoggedIn(player)) then
				local account = exports.USGaccounts:getPlayerAccount(player)
				query(loadPlayerActivePunishments,{player},"SELECT * FROM activepunishments WHERE username=?",account)
			end
		end		
		setTimer(updateActivePunishments, 1000, 0)
	end
)

function onPlayerQuiteSaveActivePunishments()
	storePlayerActivePunishments(source)
	activePunishments[source] = nil
end
addEventHandler("onPlayerQuit", root, onPlayerQuiteSaveActivePunishments)

addEventHandler("onResourceStop", resourceRoot,
	function ()
		storeActivePunishments()
	end
)

addEvent("onServerPlayerLogin")
function onPlayerLogin()
	local account = exports.USGaccounts:getPlayerAccount(source)
	query(loadPlayerActivePunishments,{source},"SELECT * FROM activepunishments WHERE username=?",account)
end
addEventHandler("onServerPlayerLogin", root, onPlayerLogin)