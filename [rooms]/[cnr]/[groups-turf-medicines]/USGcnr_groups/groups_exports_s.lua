function getPlayerGroupName(player)
	if(not isElement(player)) then return false end
	return playerMember[player] and groups[playerMember[player].groupid].groupname or false
end

function getPlayerGroup(player)
	if(not isElement(player)) then return false end
	return playerMember[player] and playerMember[player].groupid or false
end

function getGroupName(groupid)
	if(not groups[groupid]) then
		return false
	end
	return groups[groupid].groupname
end

function isGroupTurfingAsAlliance(groupid)
	if(not groups[groupid]) then
		return false
	end
	return groups[groupid].turfAsAlliance
end

function getGroupColor(groupid)
	if(not groups[groupid]) then
		return false
	end
	return groups[groupid].colorR, groups[groupid].colorG, groups[groupid].colorB
end

function getAllianceColor(allianceid)
	if(not alliances[allianceid]) then
		return false
	end
	return alliances[allianceid].colorR, alliances[allianceid].colorG, alliances[allianceid].colorB
end