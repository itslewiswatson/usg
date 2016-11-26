addEventHandler("onPlayerChangeNick", root,
	function (old, new)
		if(new:find("#%x%x%x%x%x%x")) then
			cancelEvent()
			exports.USGmsg:msg(source, "Your nickname can not contain color codes.", 255, 0, 0)
		end
	end
)

addEventHandler("onPlayerJoin", root,
	function ()
		local nick = getPlayerName(source)
		if(nick:find("#%x%x%x%x%x%x")) then
			setPlayerName(source, nick:gusb("#%x%x%x%x%x%x",""))
		end
	end
)