function showLoadingScreen(player,state,text)
	if (isElement(player)) then
		if (state == true) and (text ~= "") then
			triggerClientEvent(player,"showLoadingScreen",player,true,text)
		elseif (state == false) then
			triggerClientEvent(player,"showLoadingScreen",player,false,text)
		else
			outputDebugString("[LOAD-SCR] State or Text is missing!",0,255,0,0)
			return false
		end
	else
		outputDebugString("[LOAD-SCR] Player not found!",0,255,0,0)
		return false
	end
end