-- chat

function outputStaffChat(nickname, message, outputIRC)
	if (message ~= "") or (message ~= " ") then
		local staff = exports.USGadmin:getOnlineStaff()
		local text = "#00af00[USG] "..nickname..": #ffffff"..message
		for i, member in ipairs(staff) do
			outputChatBox(text, member, 255, 255, 255, true)
		end
		if (outputIRC and getResourceFromName("irc") and getResourceState(getResourceFromName("irc")) == "running") then 
			-- replace hex with mIRC codes
			local text = string.char(3).."03[USG] "..nickname..":"..string.char(3).." "..message
			exports.irc:ircSay(exports.irc:ircGetChannelFromName("#staff"), text)
		end
	end
end

addCommandHandler("USG", 
    function (p, cmd, ...)
        if (exports.USGadmin:isPlayerStaff(p)) then
            local message = table.concat({...}, " ")

            if (string.match(message, "%w")) then
                outputStaffChat(getPlayerName(p), message, true)
            end
        end
    end, false, false
)

addEvent("onIRCMessage")
addEventHandler("onIRCMessage", root,
    function (channel, message)
        if (exports.irc:ircGetUserNick(source) ~= "USGecho" and exports.irc:ircGetUserNick(source) ~= "Hans" and exports.irc:ircGetChannelName(channel) == "#staff") then
            outputStaffChat(exports.irc:ircGetUserNick(source).." [IRC]", message, false)
        end
    end
)

local monitors = {}
addCommandHandler("monitorchat",
    function (p, cmd)
        if (monitors[p]) then
            monitors[p] = nil
            exports.USGmsg:msg(p, "No longer monitoring room chats!", 0, 255, 0)
        elseif (exports.USGadmin:isPlayerStaff(p)) then
            monitors[p] = true
            exports.USGmsg:msg(p, "Now monitoring room chats!", 0, 255, 0)
        end
    end, false, false
)

function doesPlayerMonitorChat(player)
    return monitors[player]
end

addEventHandler("onPlayerQuit",root,
    function ()
        monitors[source] = nil
    end
)

addCommandHandler("note",
    function (p, cmd, ...)
        if (exports.USGadmin:isPlayerStaff(p)) then
            local message = table.concat({...}," ")

            if (string.match(message, "%w")) then
                outputChatBox("#FF2121[NOTE] "..exports.USG:getPlayerColoredName(p, "#FF2121")..": "..message, root, 255, 0, 0, true)
            end
        end
    end
)