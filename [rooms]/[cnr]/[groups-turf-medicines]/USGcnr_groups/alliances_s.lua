local emptyJSON = "[ [ ] ]"

alliances = {}
groupAllianceInvites = {}
usedAllianceNames = {}
groupAlliance = {}
function loadAlliances()
	query(loadAlliancesCallback, {}, "SELECT * FROM cnr__alliances")
end

function loadAlliancesCallback(dbAlliances)
	for k, dbAlliance in ipairs(dbAlliances) do
		dbAlliance.groups = fromJSON(dbAlliance.groups)
		for i, groupid in ipairs(dbAlliance.groups) do
			dbAlliance.groups[i] = tonumber(groupid)
			groupAlliance[tonumber(groupid)] = dbAlliance.allianceid
		end
		dbAlliance.invites = fromJSON(dbAlliance.invites) or {}
		for i, groupid in ipairs(dbAlliance.invites) do
			dbAlliance.invites[tonumber(i)] = tonumber(groupid)
			local gInvites = groupAllianceInvites[tonumber(groupid)] or {}
			table.insert(gInvites, dbAlliance.allianceid)
			groupAllianceInvites[tonumber(groupid)] = gInvites
		end
		groupAlliance[dbAlliance.foundergroupid] = dbAlliance.allianceid
		alliances[dbAlliance.allianceid] = dbAlliance
		usedAllianceNames[dbAlliance.alliancename] = true
	end
end

function getGroupAlliance(groupID)
	return groupAlliance[groupID] or false
end

function getAllianceName(allianceID)
	return alliances[allianceID] and alliances[allianceID].alliancename or false
end

function deleteAlliance(allianceID)
	if(not alliances[allianceID]) then return false end
	outputAllianceMessage(allianceID, "The alliance has been deleted.")
	local alliance = alliances[allianceID]
	-- clean up groups
	for i, groupid in ipairs(alliance.groups) do
		groupAlliance[groupid] = nil
	end
	-- clean up invites
	for i, groupid in ipairs(alliance.invites) do
		local gInvites = groupAllianceInvites[groupid]
		if(gInvites) then
			for i, allianceid in ipairs(gInvites) do
				if(allianceid == allianceID) then
					table.remove(gInvites, i)
					break
				end
			end
		end
	end	
	usedAllianceNames[alliance.alliancename] = nil
	exports.MySQL:execute("DELETE FROM cnr__alliances WHERE allianceid=?", allianceID)
	alliances[allianceID] = nil
	return true
end

function setAllianceName(allianceID, name)
	if(#name < ALLIANCE_NAME_MINIMUM_LENGTH) then return false end
	if(not alliances[allianceID]) then return false end
	if(usedAllianceNames[name]) then
		if(isElement(player)) then exports.USGmsg:msg(player,"This alliance name is already in use, try another one.", 255,0,0) end
		return false
	end
	usedAllianceNames[alliances[allianceID].alliancename] = nil -- clear old name
	usedAllianceNames[name] = true	
	alliances[allianceID].alliancename = name
	exports.MySQL:execute("UPDATE cnr__alliances SET alliancename=? WHERE allianceid=?", name, allianceID)
	return true
end

function createAlliance(foundergroupid, name, player)
	if(#name < ALLIANCE_NAME_MINIMUM_LENGTH) then return false end
	if(usedAllianceNames[name]) then
		if(isElement(player)) then exports.USGmsg:msg(player,"This alliance name is already in use, try another one.", 255,0,0) end
		return false
	end
	if(not groups[foundergroupid]) then
		if(isElement(player)) then exports.USGmsg:msg(player,"Something went wrong, are you in a group?", 255,0,0) end
		return false
	end
	insert(addAlliance,{foundergroupid, name, player},"INSERT INTO cnr__alliances SET foundergroupid=?,alliancename=?,groups=?,invites=?",foundergroupid,name,"[ ["..foundergroupid.." ] ]",emptyJSON)
	return true
end

function addAlliance(insertID, foundergroupid, name, player)
	if(insertID) then
		local alliance = {groups = {foundergroupid}, invites = {}}
		alliance.allianceid = insertID
		alliance.foundergroupid = foundergroupid
		alliance.allianceinfo = ""
		alliance.alliancename = name
		usedAllianceNames[name] = true
		groupAlliance[alliance.foundergroupid] = alliance.allianceid
		alliances[insertID] = alliance
		if(isElement(player)) then
			exports.USGmsg:msg(player,"Successfully created alliance "..name.."!", 0, 255,0)
			groupMessage(foundergroupid, getPlayerName(player).." created an alliance!")
			triggerClientEvent(player, "USGcnr_groups.updateGroupData", player, {myAlliance = getPlayerAllianceData(player)})
		end
		return true
	else
		if(isElement(player)) then
			exports.USGmsg:msg(player,"Could not create alliance, try again later.", 255, 0,0)
		end
		return false
	end
end

function setAllianceInfo(allianceID, info)
	if(not alliances[allianceID]) then return false end
	alliances[allianceID].allianceinfo = info
	return exports.MySQL:execute("UPDATE cnr__alliances SET allianceinfo=? WHERE allianceid=?",info,allianceID)
end

function setAllianceColor(allianceID, r,g,b)
	if(not alliances[allianceID]) then return false end
	alliances[allianceID].colorR = r
	alliances[allianceID].colorG = g
	alliances[allianceID].colorB = b
	outputAllianceMessage(allianceID, "The alliance color was changed to "..exports.USG:convertRGBToHEX(r,g,b).."this.")
	return exports.MySQL:execute("UPDATE cnr__alliances SET colorR=?,colorG=?,colorB=? WHERE allianceid=?", r,g,b, allianceID)
end

function addGroupToAlliance(groupID,allianceID)
	if(groups[groupID] and alliances[allianceID]) then
		if(not groupAlliance[groupID]) then
			local alliance = alliances[allianceID]
			table.insert(alliance.groups, groupID)
			groupAlliance[groupID] = allianceID
			local groups = toJSON(alliance.groups)
			local success = exports.MySQL:execute("UPDATE cnr__alliances SET groups=? WHERE allianceid=?", groups, allianceID)
			if(success and groups[groupID]) then
				outputAllianceMessage(allianceID, groups[groupID].groupname.." has joined the alliance.")
			end		
			return success
		else
			return false
		end
	else
		return false
	end
end 

function removeGroupFromAlliance(groupID)
	if(groups[groupID] and groupAlliance[groupID]) then
		local alliance = alliances[groupAlliance[groupID]]
		if(alliance) then
			for i, id in ipairs(alliance.groups) do
				if(id == groupID) then
					table.remove(alliance.groups, i)
					break
				end
			end
			if(#alliance.groups == 0) then
				deleteAlliance(groupAlliance[groupID])
			end
			groupAlliance[groupID] = nil
			return exports.MySQL:execute("UPDATE cnr__alliances SET groups=? WHERE allianceid=?", toJSON(alliance.groups), alliance.allianceid)
		else
			return false
		end
	else
		return false	
	end
end

function inviteGroupToAlliance(groupID, allianceID,inviter)
	if(groups[groupID] and alliances[allianceID]) then
		if(not groupAlliance[groupID]) then
			local alliance = alliances[allianceID]
			for i, invite in ipairs(alliance.invites) do
				if(invite == groupID) then
					return false
				end
			end
			table.insert(alliance.invites, groupID)
			local invites = groupAllianceInvites[groupID] or {}
			table.insert(invites, allianceID)
			groupAllianceInvites[groupID] = invites
			local invites = toJSON(alliance.invites)
			return exports.MySQL:execute("UPDATE cnr__alliances SET invites=? WHERE allianceid=?", invites, allianceID)
		else
			return false
		end
	else
		return false
	end
end

function removeAllianceInvite(groupID, allianceID)
	if(alliances[allianceID]) then
		local alliance = alliances[allianceID]
		local found = false
		for i, groupid in ipairs(alliance.invites) do
			if(groupid == groupID) then
				table.remove(alliance.invites, i)
				found = true
				break
			end
		end
		if(groupAllianceInvites[groupID]) then
			for i, allianceid in ipairs(groupAllianceInvites[groupID]) do
				if(allianceid == allianceID) then
					table.remove(groupAllianceInvites[groupID], i)
					found = true
					break
				end
			end
		end
		if(found) then
			local invites = toJSON(alliance.invites)
			return exports.MySQL:execute("UPDATE cnr__alliances SET invites=? WHERE allianceid=?", invites, allianceID)
		else
			return false
		end
	else
		return false
	end
end

function outputAllianceMessage(allianceID, message)
	if(alliances[allianceID]) then
		for i, groupid in ipairs(alliances[allianceID].groups) do
			local group = groups[groupid]
			if(group) then
				for i, player in ipairs(group.players) do
					outputChatBox("["..alliances[allianceID].alliancename.."] "..message, player,240,160,0,true)
				end
			end
		end
		return true
	end
	return false
end

local antiSpam = {}

function onCommandAllianceChat(pSource, cmd, ...)
	local message = table.concat({...}, " ")
	local pMute = exports.USGadmin:getPlayerMute(pSource)
	if(pMute and pMute == "global") then
		exports.USGmsg:msg(pSource, "You are muted ( "..pMute.." ), you can't talk.", 255, 0, 0)
		return false
	end		
	if(not antiSpam[pSource] or antiSpam[pSource] < getTickCount()-1500) then
		allianceChat(pSource, message)
	else
		exports.USGmsg:msg(pSource,"Calm down, wait before talking in alliance chat again.", 255,0,0)
	end
end
addCommandHandler("ac", onCommandAllianceChat, false)
addCommandHandler("alliance", onCommandAllianceChat, false)
addCommandHandler("alliancechat", onCommandAllianceChat, false)

function allianceChat(player, message)
	local group = getPlayerGroup(player)
	if(group) then
		local alliance = getGroupAlliance(group)
		if(alliance) then
			antiSpam[player] = getTickCount()
			outputAllianceMessage(alliance, exports.USG:getPlayerColoredName(player,":#FFFFFF ")..message)
		end
	end
end