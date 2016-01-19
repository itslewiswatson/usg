
function setPlayerStaffData(player)
	if ( isElement(player) and exports.USGaccounts:isPlayerLoggedIn(player) ) then
		local account = exports.USGaccounts:getPlayerAccount(player):lower()
		if ( staffAccounts[account] ) then
			staffPlayers[player] = staffAccounts[account]
		end
	end
end

function onPlayerLogin()
	setPlayerStaffData(source)
end
addEvent("onServerPlayerLogin", true)
addEventHandler("onServerPlayerLogin",root,onPlayerLogin)

-- exports

function isPlayerStaff(player)
	local thePlayer = player or localPlayer
	if ( isElement(thePlayer) ) then
		return ( staffPlayers[thePlayer] and staffPlayers[thePlayer].active == 1 ) 
	end
	return false
end

function getPlayerStaffLevel(player)
	local thePlayer = player or localPlayer
	if ( isElement(thePlayer) and isPlayerStaff(thePlayer) ) then
		return staffPlayers[thePlayer].level
	end
	return false
end

function isPlayerEventManager(player)
	local thePlayer = player or localPlayer
	if ( isElement(thePlayer) and isPlayerStaff(thePlayer) ) then
		return staffPlayers[thePlayer].eventmanager == 1
	end
	return false
end

function isPlayerMapManager(player)
	local thePlayer = player or localPlayer
	if ( isElement(thePlayer) and isPlayerStaff(thePlayer) ) then
		return staffPlayers[thePlayer].mapmanager == 1
	end
	return false
end

function isPlayerBaseMod(player)
	local thePlayer = player or localPlayer
	if ( isElement(thePlayer) and isPlayerStaff(thePlayer) ) then
		return staffPlayers[thePlayer].basemod == 1
	end
	return false
end

function getOnlineStaff()
	local staff = {}
	for k, player in ipairs(getElementsByType("player")) do
		if(isPlayerStaff(player)) then
			table.insert(staff, player)
		end
	end
	return staff
end