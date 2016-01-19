local cnr = {}
cnr.money = getPlayerMoney
cnr.group = function (player)
	return exports.USGcnr_groups:getPlayerGroupName(player)
end
cnr.wantedlevel = function (player)
	return exports.USGcnr_wanted:getPlayerWantedLevel(player)
end
keys.rooms.cnr = cnr