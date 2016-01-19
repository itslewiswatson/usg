function msg(player,text,r,g,b,duration)
	if ( isElement(player) or (type(player) == "table" and isElement(player[1])) ) then
		triggerClientEvent(player,"USGmsg.newMsg",type(player) == "table" and root or player,text,r,g,b,duration)
		return true
	else
		error("Invalid player!")
	end
	return false
end
