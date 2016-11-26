------------------------------------
-- IRC Commands
------------------------------------
addEvent("onIRCResourceStart")
addEventHandler("onIRCResourceStart",root,
	function ()
		addIRCCommandHandler("!room",
			function (server,channel,user,command,name,...)
				if not name then ircNotice(user,"syntax is !room <name>") return end
				local player = getPlayerFromPartialName(name)
				if player then
					local room = exports.USGrooms:getPlayerRoomFriendly(player)
					if(room) then
						ircSay(channel, getPlayerName(player).." is playing in the room: "..room)
					else
						ircSay(channel, getPlayerName(player).." is in the lobby.")
					end
				else
					ircNotice(user,"'"..name.."' no such player")
				end
			end
		)

		addIRCCommandHandler("!group",
			function (server,channel,user,command,name,...)
				if not name then ircNotice(user,"syntax is !group <name>") return end
				local player = getPlayerFromPartialName(name)
				if player then
					local group = exports.USGcnr_groups:getPlayerGroupName(player)
					if(group) then
						ircSay(channel, getPlayerName(player).."'s group: "..group)
					else
						ircSay(channel, getPlayerName(player).." has no group.")
					end
				else
					ircNotice(user,"'"..name.."' no such player")
				end
			end
		)

		addIRCCommandHandler("!playtime",
			function (server,channel,user,command,name,...)
				if not name then ircNotice(user,"syntax is !playtime <name>") return end
				local player = getPlayerFromPartialName(name)
				if player then
					if(exports.USGaccounts:isPlayerLoggedIn(player)) then						
						local playtime = (getElementData(player, "playTime") or 0)/60
						ircSay(channel, string.format("%s's playtime: %.0f hours.", getPlayerName(player), playtime))
					else
						ircNotice(user, getPlayerName(player).." is not logged in.")
					end
				else
					ircNotice(user,"'"..name.."' no such player")
				end
			end
		)

		addIRCCommandHandler("!account",
			function (server,channel,user,command,name,...)
				if not name then ircNotice(user,"syntax is !account <name>") return end
				local player = getPlayerFromPartialName(name)
				if player then
					if(exports.USGaccounts:isPlayerLoggedIn(player)) then						
						local playtime = (getElementData(player, "playTime") or 0)/60
						ircNotice(user, string.format("%s's account: %s", getPlayerName(player), exports.USGaccounts:getPlayerAccount(player)))
					else
						ircNotice(user, getPlayerName(player).." is not logged in.")
					end
				else
					ircNotice(user,"'"..name.."' no such player")
				end
			end
		)

		addIRCCommandHandler("!state",
			function (server,channel,user,command,name,...)
				if not name then ircNotice(user,"syntax is !state <name>") return end
				local resource = getResourceFromPartialName (name)
				if resource then
					ircNotice(user, string.format("%s's state is: %s", getResourceName(resource), getResourceState(resource)))
				else
					ircNotice(user,"'"..name.."' no such resource")
				end
			end
		)

		addIRCCommandHandler("!staff",
			function (server,channel,user,command)
				local staffMembers = {}
				for i, player in ipairs(getElementsByType("player")) do
					if(exports.USGadmin:isPlayerStaff(player)) then
						table.insert(staffMembers, getPlayerName(player).." in "..(exports.USGrooms:getPlayerRoomFriendly(player) or "lobby"))
					end
				end
				if(#staffMembers > 0) then
					ircSay(channel, "Online staff: "..table.concat(staffMembers, ", "))
				else
					ircSay(channel, "No staff online!")
				end
			end
		)		
	end
)

local antiSpam = {}
addCommandHandler("ircpm", 
	function (pSource, cmd, target, ...)
		if(antiSpam[pSource] and getTickCount()-antiSpam[pSource] < 3000) then
			exports.USGmsg:msg(pSource, "Please wait before sending another IRCPM.", 255, 0, 0)
			return
		end
		antiSpam[pSource] = getTickCount()
		local message = table.concat({...}," ")
		local user = ircGetUserFromNick(target)
		if(user) then
			ircSay(user, "Message from "..getPlayerName(pSource)..": "..message)
			exports.USGmsg:msg(pSource, "Sent your message to "..ircGetUserNick(user).."!", 0, 255, 0)
		else
			exports.USGmsg:msg(pSource, "User not found!", 255, 0, 0)
		end
	end
)