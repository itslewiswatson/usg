function isPlayerBlacklisted(player)
	if(not fileExists("pm_blacklist.xml")) then return false end
	local account = exports.USGaccounts:getPlayerAccount(player)
	if(account) then
		local blacklisted = false
		local xml = xml or xmlLoadFile("pm_blacklist.xml")
		for i, node in ipairs(xmlNodeGetChildren(xml)) do
			if(xmlNodeGetValue(node) == account) then
				blacklisted = true
				break
			end
		end
		xmlUnloadFile(xml)
		return blacklisted
	end
end

function blacklistPlayer(player)
	local xml = xmlLoadFile("pm_blacklist.xml") or xmlCreateFile("pm_blacklist","blacklist")
	if(isPlayerBlacklisted(player)) then xmlUnloadFile(xml) return false end
	local account = exports.USGaccounts:getPlayerAccount(player)
	if(account) then
		local node = xmlCreateChild(xml, "account")
		xmlNodeSetValue(node, account)
		xmlSaveFile(xml)
		xmlUnloadFile(xml)
		return true
	else
		return false
	end
end

local lastSender = false

addEvent("onRecievePM")
addEvent("USGchatsystem.pm.recieve", true)
function onRecievePM(message)
	local blacklisted = isPlayerBlacklisted(source)
	triggerServerEvent("USGchatsystem.pm.recieved", localPlayer, source, message, blacklisted)
	if(not blacklisted) then
		triggerEvent("onRecievePM", source, message)
		outputChatBox("[PM] < "..getPlayerName(source)..": "..message, 0, 255,80)
		lastSender = source
	end
end
addEventHandler("USGchatsystem.pm.recieve", root, onRecievePM)

addEvent("onSendPM")
addEvent("USGchatsystem.pm.send", true)
function onSendPM(target, message)
	triggerEvent("onSendPM", localPlayer, target, message)
	outputChatBox("[PM] > "..getPlayerName(target)..": "..message,0,255,0)
end
addEventHandler("USGchatsystem.pm.send", localPlayer, onSendPM)

addCommandHandler("r", 
	function (cmd, ...)
		if(isElement(lastSender)) then
			triggerServerEvent("sendPM", localPlayer, lastSender, table.concat({...}," "))
		else
			exports.USGmsg:msg("You have not recieved a PM or the player has left.", 255,0,0)
		end
	end
)