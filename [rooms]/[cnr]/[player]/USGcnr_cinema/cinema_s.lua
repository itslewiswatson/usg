local currentSavedURL

addEvent("cinema.saveURL",true)

addEventHandler("cinema.saveURL",resourceRoot,function(URL)
	currentSavedURL = URL
	if(currentSavedURL)then
	else
	currentSavedURL = "http://usgmta.co/"
	end
triggerClientEvent(exports.USGrooms:getPlayersInRoom("cnr"),"cinema.sendUrlToPlayer",resourceRoot,currentSavedURL)
end)

addEventHandler("onPlayerJoinRoom",root,function(room)
	if(room == "cnr")then
	triggerClientEvent(source,"cinema.sendUrlToPlayer",resourceRoot,currentSavedURL)
	end
end)