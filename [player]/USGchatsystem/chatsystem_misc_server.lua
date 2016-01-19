function onCarChat(pSource, cmd, ...)
	if(not exports.USGaccounts:isPlayerLoggedIn(pSource)) then return end
	local pMute = exports.USGadmin:getPlayerMute(pSource)
	if(pMute and pMute == "global") then
		exports.USGmsg:msg(pSource, "You are muted ( "..pMute.." ), you can't talk.", 255, 0, 0)
		return false
	end		
	if(antiSpamTimers[pSource] and getTickCount() - antiSpamTimers[pSource] < 1000 ) then
		exports.USGmsg:msg(pSource, "Please wait before chatting again.",255,0,0)
		return false
	end
	if(not isPedInVehicle(pSource)) then
		exports.USGmsg:msg(pSource, "You are not in a vehicle.",255,0,0)
		return false
	end
	local message = table.concat({...}, " ")
	if(not onUSGPlayerChat(pSource, message, "car")) then return false end
	local final = "[CAR] "..exports.USG:getPlayerColoredName(pSource)..": "..message
	local occupants = getVehicleOccupants(getPedOccupiedVehicle(pSource))
	for seat=0, #occupants do
		local occupant = occupants[seat]
		if(isElement(occupant)) then
			outputChatBox(final, occupant, 255,255,255,true)
		end
	end
	exports.system:log("carchat",message,pSource)
end
addCommandHandler("carchat", onCarChat, false,false)
addCommandHandler("cc", onCarChat, false,false)

function onSupportChat(pSource, cmd, ...)
	if(not exports.USGaccounts:isPlayerLoggedIn(pSource)) then return end
	local pMute = exports.USGadmin:getPlayerMute(pSource)
	if(pMute and (pMute == "support" or pMute == "global")) then
		exports.USGmsg:msg(pSource, "You are muted ( "..pMute.." ), you can't talk.", 255, 0, 0)
		return false
	end	
	if(antiSpamTimers[pSource] and getTickCount() - antiSpamTimers[pSource] < 1000 ) then
		exports.USGmsg:msg(pSource, "Please wait before chatting again.",255,0,0)
		return false
	end
	local message = table.concat({...}, " ")
	if(not onUSGPlayerChat(pSource, message, "support")) then return false end
	local chatStr = getPlayerName(pSource)..": "..message
	local finalString = "[SUPPORT] "..getPlayerName(pSource)..":#FFFFFF "..message
	local ircString = ircPreColor.."[SUPPORT] "..ircNickColor..getPlayerName(pSource)..":"..ircMessageColor.." "..message
	antiSpamTimers[pSource] = getTickCount()
	for i,player in ipairs(getElementsByType("player")) do
		if(exports.USGaccounts:isPlayerLoggedIn(player)) then
			outputChatBox(finalString,player,160,160,255,true)
			triggerClientEvent(player, "USGchatsystem.onChatMessage", pSource, "Support", chatStr)
		end
	end
	exports.system:log("support",message,pSource)
	triggerEvent("onUSGChat",pSource, message, "support", finalString, ircString)
end
addCommandHandler("support", onSupportChat, false, false)

function onPlayerAdvert(pSource, commandName, ...)
	local pMute = exports.USGadmin:getPlayerMute(pSource)
	if(pMute and (pMute == "main" or pMute == "global")) then
		exports.USGmsg:msg(pSource, "You are muted ( "..pMute.." ), you can't talk.", 255, 0, 0)
		return false
	end	
	if(exports.USGrooms:getPlayerRoom(pSource) ~= "cnr") then
		exports.USGmsg:msg(pSource, "You can only use advert in the CnR room.", 255, 0, 0)
		return false
	end
	if(antiSpamTimers[pSource] and getTickCount() - antiSpamTimers[pSource] < 5000 ) then
		exports.USGmsg:msg(pSource, "Please wait before advertising again.",255,0,0)
		return false
	end	
	local message = table.concat( {...}, " " )	
	if(not onUSGPlayerChat(pSource, message, "advert")) then return false end	
	local playerColor = exports.USG:getPlayerColoredName(pSource)		
	local finalString = "#FF0000[ADVERT] "..exports.USG:getPlayerColoredName(pSource,"#FFFFFF")..": " ..message
	local money = getPlayerMoney(pSource)
	if(money > 1000) then
		antiSpamTimers[pSource] = getTickCount()
		takePlayerMoney ( pSource , 1000)
		local players = getElementsByType("player")	
		for index, player in ipairs ( players ) do
			if(exports.USGaccounts:isPlayerLoggedIn(player) and exports.USGrooms:getPlayerRoom(player) == "cnr") then
				outputChatBox( finalString, player, 255, 188 , 0 , true)
			end
		end
	else
		exports.USGmsg:msg(pSource, "You need $1,000 to advert.", 255, 0, 0)
	end
end
addCommandHandler( "advert", onPlayerAdvert )