antiSpamTimers = {}

chatBoxes = 
{
	{name="Arabic",cmd="ar"},
	{name="French",cmd="fr"},
	{name="Russian",cmd="ru"},
	{name="Spanish",cmd="es"},
}


function ArabicChat(pSource, cmd, ...)
	if(not exports.USGaccounts:isPlayerLoggedIn(pSource)) then return end
	local pMute = exports.USGadmin:getPlayerMute(pSource)
	if(pMute and (pMute == "global")) then
		exports.USGmsg:msg(pSource, "You are muted ( "..pMute.." ), you can't talk.", 255, 0, 0)
		return false
	end	
	if(antiSpamTimers[pSource] and getTickCount() - antiSpamTimers[pSource] < 1000 ) then
		exports.USGmsg:msg(pSource, "Please wait before chatting again.",255,0,0)
		return false
	end
	local message = table.concat({...}, " ")
	local chatStr = getPlayerName(pSource)..": "..message
	local finalString = "#FF8000[AR] "..getPlayerName(pSource)..":#FFFFFF "..message
	antiSpamTimers[pSource] = getTickCount()
	for i,player in ipairs(getElementsByType("player")) do
		if(exports.USGaccounts:isPlayerLoggedIn(player)) then
			triggerClientEvent(player, "USGchatsystem.onArabic", player, finalString)
			triggerClientEvent(player, "USGchatsystem.onChatMessage", pSource, "Arabic", chatStr)
		end
	end
	exports.system:log("Arabic",message,pSource)
end
addCommandHandler("ar", ArabicChat, false, false)
addCommandHandler("Arabic", ArabicChat, false, false)

function FrenchChat(pSource, cmd, ...)
	if(not exports.USGaccounts:isPlayerLoggedIn(pSource)) then return end
	local pMute = exports.USGadmin:getPlayerMute(pSource)
	if(pMute and (pMute == "global")) then
		exports.USGmsg:msg(pSource, "You are muted ( "..pMute.." ), you can't talk.", 255, 0, 0)
		return false
	end	
	if(antiSpamTimers[pSource] and getTickCount() - antiSpamTimers[pSource] < 1000 ) then
		exports.USGmsg:msg(pSource, "Please wait before chatting again.",255,0,0)
		return false
	end
	local message = table.concat({...}, " ")
	local chatStr = getPlayerName(pSource)..": "..message
	local finalString = "#FF8000[FR] "..getPlayerName(pSource)..":#FFFFFF "..message
	antiSpamTimers[pSource] = getTickCount()
	for i,player in ipairs(getElementsByType("player")) do
		if(exports.USGaccounts:isPlayerLoggedIn(player)) then
			triggerClientEvent(player, "USGchatsystem.onFrench", player, finalString)
			triggerClientEvent(player, "USGchatsystem.onChatMessage", pSource, "French", chatStr)
		end
	end
	exports.system:log("French",message,pSource)
end
addCommandHandler("fr", FrenchChat, false, false)
addCommandHandler("French", FrenchChat, false, false)

function RussianChat(pSource, cmd, ...)
	if(not exports.USGaccounts:isPlayerLoggedIn(pSource)) then return end
	local pMute = exports.USGadmin:getPlayerMute(pSource)
	if(pMute and (pMute == "global")) then
		exports.USGmsg:msg(pSource, "You are muted ( "..pMute.." ), you can't talk.", 255, 0, 0)
		return false
	end	
	if(antiSpamTimers[pSource] and getTickCount() - antiSpamTimers[pSource] < 1000 ) then
		exports.USGmsg:msg(pSource, "Please wait before chatting again.",255,0,0)
		return false
	end
	local message = table.concat({...}, " ")
	local chatStr = getPlayerName(pSource)..": "..message
	local finalString = "#FF8000[RU] "..getPlayerName(pSource)..":#FFFFFF "..message
	antiSpamTimers[pSource] = getTickCount()
	for i,player in ipairs(getElementsByType("player")) do
		if(exports.USGaccounts:isPlayerLoggedIn(player)) then
			triggerClientEvent (player, "USGchatsystem.onRussian", player, finalString)
			triggerClientEvent(player, "USGchatsystem.onChatMessage", pSource, "Russian", chatStr)
		end
	end
	exports.system:log("Russian",message,pSource)
end
addCommandHandler("ru", RussianChat, false, false)
addCommandHandler("Russian", RussianChat, false, false)

function SpanishChat(pSource, cmd, ...)
	if(not exports.USGaccounts:isPlayerLoggedIn(pSource)) then return end
	local pMute = exports.USGadmin:getPlayerMute(pSource)
	if(pMute and (pMute == "global")) then
		exports.USGmsg:msg(pSource, "You are muted ( "..pMute.." ), you can't talk.", 255, 0, 0)
		return false
	end	
	if(antiSpamTimers[pSource] and getTickCount() - antiSpamTimers[pSource] < 1000 ) then
		exports.USGmsg:msg(pSource, "Please wait before chatting again.",255,0,0)
		return false
	end
	local message = table.concat({...}, " ")
	local chatStr = getPlayerName(pSource)..": "..message
	local finalString = "#FF8000[ES] "..getPlayerName(pSource)..":#FFFFFF "..message
	antiSpamTimers[pSource] = getTickCount()
	for i,player in ipairs(getElementsByType("player")) do
		if(exports.USGaccounts:isPlayerLoggedIn(player)) then
			triggerClientEvent (player, "USGchatsystem.onSpanish", player, finalString)
			triggerClientEvent(player, "USGchatsystem.onChatMessage", pSource, "Spanish", chatStr)
		end
	end
	exports.system:log("Spanish",message,pSource)
end
addCommandHandler("es", SpanishChat, false, false)
addCommandHandler("Spanish", SpanishChat, false, false)