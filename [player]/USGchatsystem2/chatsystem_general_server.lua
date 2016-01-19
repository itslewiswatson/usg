addEvent("onUSGChat", true)

antiSpamTimers = {}
local globalAntiSpamTimers = {}
ircColor = ""
ircMessageColor = ircColor
ircNickColor = ircColor.."04"
ircPreColor = ircColor.."11"

-- For optimization
local concat = table.concat

addEvent("onUSGPlayerChat")
function onUSGPlayerChat(player, msg, chat)
	return triggerEvent("onUSGPlayerChat", player, msg, chat)
end

function onPlayerChat(pSource, msg, msgType)
	if (#(msg:gsub(" ","")) < 1) then
		return false
	end
	msg = msg:gsub("#%x%x%x%x%x%x","")
	if not (exports.USGaccounts:isPlayerLoggedIn(pSource)) then return false end
	local pMute = exports.USGadmin:getPlayerMute(pSource)
	if (pMute and (pMute == "global" or pMute == "main")) then
		exports.USGmsg:msg(pSource, "You are muted ("..pMute.."), you can't talk.", 255, 0, 0)
		return false
	end
	if (not antiSpamTimers[pSource] or getTickCount() - antiSpamTimers[pSource] > 1000) then
		local r,g,b = 100,100,100
		local nick = getPlayerName(pSource)
		local coloredNick = exports.USG:getPlayerColoredName(pSource)
		local room = exports.USGrooms:getPlayerRoom(pSource)
		local finalString, ircString
		local logString, logType
		local players = getElementsByType("player")
		
		local pTeam = getPlayerTeam(pSource)
		if (pTeam) then
			if (getTeamColor(pTeam)) then r,g,b = getTeamColor(pTeam) end
		end
		
		-- Main chat message
		if (msgType == 0) then
			msgType = "main"
			if (not onUSGPlayerChat(pSource, msg, msgType)) then return false end
			local roomname = exports.USGrooms:getPlayerRoomFriendly(pSource) or "Lobby"
			if (exports.USGrooms:getPlayerRoom(pSource) == "cnr") then
				local cZone = exports.USG:getPlayerChatZone(pSource)
				
				finalString = "["..cZone.."] "..coloredNick.."#efefef: "..msg
				ircString = ircPreColor.."["..cZone.."] "..ircNickColor..nick..":"..ircMessageColor.." "..msg
				local chatStr = nick..": "..msg
				for i,player in ipairs(players) do
					if(exports.USGrooms:getPlayerRoom(player) == room or exports.USGstaff:doesPlayerMonitorChat(player)) then
					--if (exports.USG:getPlayerChatZone(player) == cZone) then
						if(exports.USGstaff:doesPlayerMonitorChat(player)) then
							outputChatBox("["..(room or "lobby"):upper().."] "..finalString,player,255,255,255,true)
						else
							outputChatBox(finalString,player,255,255,255,true)
						end
						triggerClientEvent(player, "USGchatsystem.onChatMessage", pSource, "Main", chatStr)
					--end
					end
				end
				logString, logType = "["..roomname.."] ["..cZone.."] "..nick.."(1): "..msg, "mainchat"
			else
				finalString = coloredNick.."#efefef: "..msg
				ircString = ircNickColor..nick..": "..ircMessageColor..msg
				for i,player in ipairs(players) do
					if (exports.USGrooms:getPlayerRoom(player) == room or exports.USGstaff:doesPlayerMonitorChat(player)) then
						if(exports.USGstaff:doesPlayerMonitorChat(player)) then
							outputChatBox("["..(room or "lobby"):upper().."] "..finalString,player,255,255,255,true)
						else
							outputChatBox(finalString,player,255,255,255,true)
						end
						triggerClientEvent(player, "USGchatsystem.onChatMessage", pSource, "Main", nick..": "..msg)
					end
				end
				logString, logType = "["..roomname.."] "..nick.."(1): "..msg, "mainchat"										
			end	
		
		-- /me
		elseif (msgType == 1) then
			local playerstable2 = {} --store all players into this
			msgType = "action"
			if(not onUSGPlayerChat(pSource, msg, msgType)) then return false end
				local roomname = exports.USGrooms:getPlayerRoomFriendly(pSource) or "Lobby"
				if (exports.USGrooms:getPlayerRoom(pSource) == "cnr") then
					finalString = "* "..nick.." "..msg
					local pX,pY,pZ = getElementPosition(pSource)
					local pDimension, pRoom = getElementDimension(pSource), exports.USGrooms:getPlayerRoom(pSource)
					for k,v in ipairs(getElementsByType("player")) do
					if (v == player or (getElementDimension(v) == pDimension and pRoom == exports.USGrooms:getPlayerRoom(v))) then
						if (exports.USGmisc:isPlayerInRange(v, pX, pY, pZ, 100)) then
							table.insert(playerstable2,v)
						end
					end
				end
			end
			
			for k, target in ipairs(playerstable2) do
				outputChatBox("*"..exports.USG:getPlayerColoredName(pSource).." "..msg,target,255,255,255,true)
			end
			finalString = exports.USG:convertRGBToHEX(r,g,b)..finalString
			logString, logType = "* "..nick.."(1) "..msg, "actionchat"
			
		-- Team chat
		elseif (msgType == 2 and pTeam) then
			msgType = "team"
			if(not onUSGPlayerChat(pSource, msg, msgType)) then return false end
			local teamName = getTeamName(pTeam) or "TEAM"
			finalString = "[TEAM] "..coloredNick.."#efefef: "..msg
			ircString = ircPreColor.."["..teamName:upper().."] "..ircNickColor..nick..":"..ircMessageColor.." "..msg
			for i,player in ipairs(players) do
				if ((getPlayerTeam(player) == pTeam and exports.USGrooms:getPlayerRoom(player) == room) or exports.USGstaff:doesPlayerMonitorChat(player)) then
					if(exports.USGstaff:doesPlayerMonitorChat(player)) then
						outputChatBox("["..(room or "lobby"):upper().."] "..finalString,player,255,255,255,true)
					else
						outputChatBox(finalString, player, 255, 255, 255, true)
					end
					triggerClientEvent(player, "USGchatsystem.onChatMessage", pSource, "Team", nick..": "..msg)
				end
			end
			logString, logType = "["..teamName.."] "..nick.."(1): "..msg, "teamchat"
		end
		triggerEvent("onUSGChat",pSource,msg,msgType,finalString, ircString)
		exports.system:log(logType,logString,pSource)
		antiSpamTimers[pSource] = getTickCount()
	else
		exports.USGmsg:msg(pSource, "Calm down, wait before chatting.", 255,0,0)
		return false
	end
end

addEventHandler("onPlayerChat", root,
	function (msg, msgType)
		cancelEvent()
		onPlayerChat(source, msg, msgType)
	end
)

local function globalchat(player, _, ...)
	if (exports.USGaccounts:isPlayerLoggedIn(player)) then
		
		local message = concat({...}, " ")
		if (not onUSGPlayerChat(player, message, "global")) then return false end
		
		local pMute = exports.USGadmin:getPlayerMute(player)
		if(pMute and (pMute == "global" or pMute == "main")) then
			exports.USGmsg:msg(player, "You are muted ("..pMute.."), you can't talk.", 255, 0, 0)
			return false
		end
		
		if (message:match("^%s*$")) then
			exports.USGmsg:msg(player, "You didn't enter a message.", 255, 0, 0)
		elseif (globalAntiSpamTimers[player]) and (getTickCount()-globalAntiSpamTimers[player] < 7000) then
			exports.USGmsg:msg(player, "Please wait before using globalchat again.", 255, 0, 0)
		else
			globalAntiSpamTimers[player] = getTickCount()
			local room = (exports.USGrooms:getPlayerRoom(player) or "lobby"):upper()
			local coloredNick = exports.USG:getPlayerColoredName(player)
			local nick = getPlayerName(player)
			local finalString = "#6B6BFF["..room.."] #efefef"..nick.."#efefef: "..message
			local ircString = ircPreColor.."[GLOBAL] "..ircNickColor..nick..": "..ircMessageColor..message
			local players = getElementsByType("player")
			
			for i,p in ipairs(players) do
				if (exports.USGaccounts:isPlayerLoggedIn(p)) then
					outputChatBox(finalString, p, 255, 255, 255, true)
					triggerClientEvent(p, "USGchatsystem.onChatMessage", player, "Global", nick..": "..message)
				end
			end
			
			local logString, logType = "["..room.."] "..nick.."(1): "..message, "globalchat"		
			triggerEvent("onUSGChat",player,message,"globalchat", finalString, ircString)
			exports.system:log(logType, logString, player)
		end
	end
end
addCommandHandler("global", globalchat, false, false)
addCommandHandler("globalchat", globalchat, false, false)

local localAntiSpamTimers = {}

function localchat(player,_,...)
	if (exports.USGaccounts:isPlayerLoggedIn(player)) then
		local pX,pY,pZ = getElementPosition(player)
		local message = concat({...}, " ")
		if(not onUSGPlayerChat(player, message, "local")) then return false end
		local pMute = exports.USGadmin:getPlayerMute(player)
		if(pMute and pMute == "global") then
			exports.USGmsg:msg(player, "You are muted ("..pMute.."), you can't talk.", 255, 0, 0)
			return false
		end
		if (message:match("^%s*$")) then
			exports.USGmsg:msg(player,"You didn't enter a message.",255,0,0,2000)
		elseif (localAntiSpamTimers[player]) and (getTickCount()-localAntiSpamTimers[player] < 1000) then
			exports.USGmsg:msg(player,"You're typing too fast!",255,0,0,2000)
		else
			localAntiSpamTimers[player] = getTickCount()
			local nick = getPlayerName(player)
			local playerstable = {} --store all players into this
			local pDimension, pRoom = getElementDimension(player), exports.USGrooms:getPlayerRoom(player)
			for k,v in ipairs(getElementsByType("player")) do
				if (v == player or (getElementDimension(v) == pDimension and pRoom == exports.USGrooms:getPlayerRoom(v))) then
					if (exports.USGmisc:isPlayerInRange(v, pX, pY, pZ, 100)) then
						table.insert(playerstable,v)
					end
				end
			end
			triggerClientEvent(playerstable, "USGchatsystem.onChatMessage", player, "Local", nick..": "..message)
			local count = #playerstable - 1 --take 1 away because we don't want to count the player that's using /local
			
			for k, target in ipairs(playerstable) do
				if (getElementAlpha(target) == 0) then
					count = count - 1
				end
				outputChatBox("[LOCAL] ["..count.."] "..exports.USG:getPlayerColoredName(player)..": "..message,target,255,255,255,true)
				if (target ~= player) then
					triggerClientEvent(target, "onChatbubblesMessageIncome", player, message)
				end
			end
			exports.system:log("localchat",message,player) --log it to the db
		end
	end
end
addCommandHandler("localchat",localchat, false, false)
addCommandHandler("local",localchat, false, false)
addCommandHandler("lc",localchat, false, false)

addEventHandler("onResourceStart", resourceRoot,
	function ()
		for i, player in ipairs(getElementsByType("player")) do
			if(exports.USGaccounts:isPlayerLoggedIn(player)) then
				bindKey(player, "U","down","chatbox", "local")
			end
		end
	end
)

addEvent("onServerPlayerLogin", true)
addEventHandler("onServerPlayerLogin", root,
	function ()
		bindKey(source, "U", "down", "chatbox", "local")
	end
)