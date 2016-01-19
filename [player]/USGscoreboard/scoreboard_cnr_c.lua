cnr = {}

function cnr.getPlayerOccupation(player)
	return getElementData(player,"occupation") or ""
end

function cnr.getPlayerScore(player)
	return string.format("%0.1f", getElementData(player, "score") or 0)
end

function cnr.getPlayerMoney(player)
	return exports.USG:formatMoney(player == localPlayer and getPlayerMoney() or (exports.USGsyncdata:getPlayerData(player,"cnr","money") or 0))
end

function cnr.getPlayerWantedLevel(player)
	return exports.USGsyncdata:getPlayerData(player,"cnr","wantedlevel") or 0
end

function cnr.getPlayerGroup(player)
	return (player == localPlayer and exports.USGcnr_groups:getPlayerGroupName() or exports.USGsyncdata:getPlayerData(player,"cnr","group")) or ""
end

roomColumns["cnr"] = {
	{ "Occupation", cnr.getPlayerOccupation },
	{ "Score", cnr.getPlayerScore },
	{ "Money", cnr.getPlayerMoney },
	{ "WLVL", cnr.getPlayerWantedLevel },
	{ "Group", cnr.getPlayerGroup },
}
