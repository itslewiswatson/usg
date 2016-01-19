function getPlayerFromNamePart(name)
	local name = name:lower()
	local name = exports.USG:escapeString(name)
	local target = false
	local matchCount = 0
	for i, player in ipairs(getElementsByType("player")) do
		local startMatch, endMatch = getPlayerName(player):lower():find(name)
		if(startMatch and endMatch) then
			if(not target) then
				target = player
			else
				local count = #getPlayerName(player)-math.abs(endMatch-startMatch) -- calculate best match
				if(count > matchCount) then
					matchCount = count
					target = player
				end
			end
		end
	end
	return target
end

local antiSpam = {}
local playerBusy = {}

addEvent("sendPM", true)
function onPlayerSendPM(pSource, cmd, targetName, ...)
	if(not exports.USGaccounts:isPlayerLoggedIn(pSource)) then return false end
	if(antiSpam[pSource] and getTickCount()-antiSpam[pSource] < 1000) then 
		exports.USGmsg:msg(pSource,"Please wait before sending another message.", 255, 0, 0)
		return false
	end
	local pMute = exports.USGadmin:getPlayerMute(pSource)
	if(pMute and pMute == "global") then
		exports.USGmsg:msg(pSource, "You are muted ( "..pMute.." ), you can't talk.", 255, 0, 0)
		return false
	end		
	local target = targetName and getPlayerFromNamePart(targetName) or false
	if(target == pSource) then
		exports.USGmsg:msg(pSource, "You can't PM yourself.", 255,0,0)
		return false
	elseif(not isElement(target)) then
		exports.USGmsg:msg(pSource, "A player with this name was not found.", 255,0,0)
		return false
	elseif(not exports.USGaccounts:isPlayerLoggedIn(target)) then 
		exports.USGmsg:msg(pSource, "This player is not logged in yet.", 255,0,0)
		return false
	elseif(playerBusy[target]) then
		exports.USGmsg:msg(pSource, "This player has marked himself busy.", 255, 128, 0)
		return false
	end
	local message = table.concat({...}," ")
	if(#message:gsub(" ","") == 0) then
		exports.USGmsg:msg(pSource, "You need to enter a message.", 255, 0, 0)
		return false
	end
	if(not onUSGPlayerChat(pSource, message, "pm")) then return false end
	exports.system:log("pm", "> "..exports.USGaccounts:getPlayerAccount(target)..": "..message, pSource)
	exports.system:log("pm", "< "..exports.USGaccounts:getPlayerAccount(pSource)..": "..message, target)
	triggerClientEvent(target, "USGchatsystem.pm.recieve", pSource, message)
end
addCommandHandler("pm", onPlayerSendPM, false, false)
addCommandHandler("sms", onPlayerSendPM, false, false)
addEventHandler("sendPM", root, function (player, message) onPlayerSendPM(client, "pm", getPlayerName(player), message) end)

addEvent("USGchatsystem.pm.recieved", true)
function onPlayerRecievedPM(sender, message, blacklisted)
	if(not isElement(sender)) then return end
	if(blacklisted) then
		exports.USGmsg:msg(sender, "You can't send a PM to "..getPlayerName(client).." because this player has blacklisted you.", 255,0,0)
	else
		triggerClientEvent(sender, "USGchatsystem.pm.send", sender, client, message)
	end
end
addEventHandler("USGchatsystem.pm.recieved", root, onPlayerRecievedPM)
	
addCommandHandler("busy",
	function (pSource)
		if (playerBusy[pSource]) then
			playerBusy[pSource] = nil
			exports.USGmsg:msg(pSource, "You are no longer busy!", 0, 255, 0)
		else
			playerBusy[pSource] = true
			exports.USGmsg:msg(pSource, "You are now busy!", 0, 255, 0)		
		end
	end
)

addEventHandler("onPlayerQuit", root,
	function()
		playerBusy[source] = nil
	end
)