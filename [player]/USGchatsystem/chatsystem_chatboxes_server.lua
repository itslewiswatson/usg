local cmdChat = {}

addEventHandler("onResourceStart", resourceRoot,
	function ()
		for i, chat in ipairs(chatBoxes) do
			addCommandHandler(chat.cmd, onChatBoxCommand, false, false)
			cmdChat[chat.cmd] = chat
		end
	end
)

addEvent("USGchatsystem.outputChat", true)
function onPlayerOutputChat(cmd, message)
	if(not exports.USGaccounts:isPlayerLoggedIn(client)) then return end	
	if(cmd == "say") then
		onPlayerChat(client, message, 0)
	elseif(cmd == "teamsay") then
		onPlayerChat(client, message, 2)
	elseif(cmd == "support") then
		onSupportChat(client, cmd, message)
	else
		executeCommandHandler(cmd, client, message)
	end
end
addEventHandler("USGchatsystem.outputChat", root, onPlayerOutputChat)

function onChatBoxCommand(pSource, cmd, ...)
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
	if(cmdChat[cmd]) then
		local message = getPlayerName(pSource) ..": ".. unpack({...})
		if(not onUSGPlayerChat(pSource, message, cmd)) then return false end
		triggerClientEvent(root, "USGchatsystem.onChatMessage", pSource, cmdChat[cmd].name, message)
		exports.system:log("cmd",message,pSource)
		antiSpamTimers[pSource] = getTickCount()
	end
end