local playerPunishments = {}
-- maintaining tables
function loadPlayerPunishments(player)
	query(loadPlayerPunishmentsCallback,{player},"SELECT * FROM punishments WHERE ( username=? OR serial=? )",
		exports.USGaccounts:getPlayerAccount(player),getPlayerSerial(player))
end
addEventHandler("onServerPlayerLogin",root,function () loadPlayerPunishments(source) end)

function loadAllPlayerPunishments()
	for i, player in ipairs(getElementsByType("player")) do
		if(exports.USGaccounts:isPlayerLoggedIn(player)) then
			loadPlayerPunishments(player)
		end
	end
end
addEventHandler("onResourceStart", resourceRoot, loadAllPlayerPunishments)

function loadPlayerPunishmentsCallback(punishments, player)
	if(isElement(player)) then
		playerPunishments[player] = punishments
	end
end

function releasePlayerPunishments()
	playerPunishments[source] = nil
end
addEventHandler("onPlayerQuit",root,releasePlayerPunishments)

function getPlayerPunishments(player, onlyActive)
	if ( exports.USGaccounts:isPlayerLoggedIn(player) ) then
		if not ( playerPunishments[player] ) then return {} end
		if ( onlyActive ) then
			local active = {}
			for _, punishment in ipairs(playerPunishments[player]) do
				if(punishment.active == 1) then
					table.insert(active,punishment)
				end
			end
			return active
		else
			return playerPunishments[player]
		end
	end
	return false
end

function addPlayerPunishment(player,text,punisher)
	if ( isElement(player) and isElement(punisher) and exports.USGaccounts:isPlayerLoggedIn(player) and exports.USGaccounts:isPlayerLoggedIn(punisher) and text ) then
		local serial = getPlayerSerial(player)
		local username = exports.USGaccounts:getPlayerAccount(player)
		local punisheraccount = exports.USGaccounts:getPlayerAccount(punisher)
		local result = addPunishment(username,serial,punisheraccount,text)
		if(result) then
			loadPlayerPunishments(player) -- update punishments table
		end
		return result
	end
	return false
end

function addOfflinePunishment(targetAccount,targetSerial,text,punisher)
	if ( isElement(punisher) and targetAccount and targetSerial and text ) then
		local punisheraccount = exports.USGaccounts:getPlayerAccount(punisher)
		return addPunishment(targetAccount,targetSerial,punisheraccount,text)
	end
	return false
end

function addPunishment(username,userserial,punisheraccount,text)
	if ( username and userserial and punisheraccount and text ) then
		return exports.mysql:execute("INSERT INTO punishments (username,punishtext,punisheraccount,serial,punishdate) VALUES (?,?,?,?,NOW())",username,text,punisheraccount,userserial)
	end
	return false
end

function setPunishmentActive(punishID,active)
	if ( punishID ) then
		if ( active == true ) then active = 1 
		elseif ( active == false ) then active = 0 
		else return false end
		return exports.mysql:execute("UPDATE punishments SET active=? WHERE punishid=?",active,punishID)
	end
	return false
end

function setPunishmentText(punishID,newText)
	if ( punishID and type(newText) == "string" ) then
		return exports.mysql:execute("UPDATE punishments SET punishtext=? WHERE punishid=?",newText,punishID)
	end
	return false
end

-- client gui
addEvent("USGadmin.requestPlayerPunishments", true)
addEventHandler("USGadmin.requestPlayerPunishments", root,
	function ()
		local pPunishments = getPlayerPunishments(client, true)
		triggerClientEvent(client, "USGadmin.receivePlayerPunishments", client, pPunishments)
	end
)