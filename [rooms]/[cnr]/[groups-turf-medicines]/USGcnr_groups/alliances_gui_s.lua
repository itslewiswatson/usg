function getPlayerAllianceData(member)
	if(isElement(member)) then member = playerMember[member] end
	if(not member) then return false end
	local groupID = member.groupid
	local allianceID = getGroupAlliance(groupID)
	local data = {myInvites = groupID and groupAllianceInvites[groupID] or {}}
	if(allianceID and alliances[allianceID]) then
		local alliance = alliances[allianceID]
		local groupList = {}
		for i, groupid in ipairs(alliance.groups) do
			if(groups[groupid]) then
				table.insert(groupList, {groupid = groupid, groupname = groups[groupid].groupname})
			end
		end
		data = {
			alliancename = alliance.alliancename, groups = groupList, founder = getGroupName(alliance.foundergroupid),
			invites = createAllianceInviteList(allianceID), info = alliance.allianceinfo, color = {alliance.colorR, alliance.colorG, alliance.colorB}}
		-- permissions
		if(groupID == alliance.foundergroupid and member.rank == 6) then
			data.isFounder = true			
		end
	else
		data = false
	end
	return data
end

function createAllianceInviteList(allianceid)
	local alliance = alliances[allianceid]
	if(not alliance) then return false end
	local inviteList = {}
	for i, groupid in ipairs(alliance.invites) do
		if(groups[groupid]) then
			table.insert(inviteList, {groupid=groupid, groupname = groups[groupid].groupname})
		end
	end
	return inviteList
end

function createGroupAllianceInviteList(groupid)
	if(not groups[groupid]) then return false end
	local inviteList = {}
	if(groupAllianceInvites[groupid]) then
		for i, allianceid in ipairs(groupAllianceInvites[groupid]) do
			if(alliances[allianceid]) then
				table.insert(inviteList, {allianceid = allianceid, alliancename = alliances[allianceid].alliancename})
			end
		end
	end
	return inviteList
end

addEvent("USGcnr_groups.createAlliance", true)
function playerCreateAlliance(name)
	if(#name < ALLIANCE_NAME_MINIMUM_LENGTH) then
		exports.USGmsg:msg(client, "The minimum length of the name is "..ALLIANCE_NAME_MINIMUM_LENGTH.."!", 255, 0, 0)
		return false
	end
	local member = playerMember[client]
	if(member and member.rank == 6) then
		createAlliance(member.groupid, name, client)
	else
		exports.USGmsg:msg(client, "You need to be the founder of a group to make an alliance!", 255, 0, 0)
		return false
	end
end
addEventHandler("USGcnr_groups.createAlliance", root, playerCreateAlliance)

addEvent("USGcnr_groups.deleteAlliance", true)
function playerDeleteAlliance()
	local group = getPlayerGroup(client)
	local allianceID = getGroupAlliance(group)	
	if(group and allianceID and alliances[allianceID]) then
		local alliance = alliances[allianceID]
		if(alliance.foundergroupid == group) then
			local member = playerMember[client]
			if(member and member.rank == 6) then
				if(deleteAlliance(allianceID)) then
					triggerClientEvent(client, "USGcnr_groups.updateGroupData", client, {myAlliance = false})
				end
			else
				exports.USGmsg:msg(client, "You need to be the group founder to delete the alliance!", 255, 0, 0)
				return false
			end
		else
			exports.USGmsg:msg(client, "Your group needs to have founded the alliance in order to delete it!", 255, 0, 0)
			return false		
		end
	else
		exports.USGmsg:msg(client, "You are not in an alliance!", 255, 0, 0)
		return false
	end
end
addEventHandler("USGcnr_groups.deleteAlliance", root, playerDeleteAlliance)

addEvent("USGcnr_groups.leaveAlliance", true)
function playerLeaveAlliance()
	local group = getPlayerGroup(client)
	local allianceID = getGroupAlliance(group)	
	if(group and allianceID and alliances[allianceID]) then
		local member = playerMember[client]
		if(member and member.rank == 6) then
			if(removeGroupFromAlliance(group)) then
				triggerClientEvent(client, "USGcnr_groups.updateGroupData", client, {myAlliance = false})
			end
		else
			exports.USGmsg:msg(client, "You need to be the group founder to leave the alliance!", 255, 0, 0)
			return false
		end
	else
		exports.USGmsg:msg(client, "You are not in an alliance!", 255, 0, 0)
		return false
	end
end
addEventHandler("USGcnr_groups.leaveAlliance", root, playerLeaveAlliance)

addEvent("USGcnr_groups.renameAlliance", true)
function playerRenameAlliance(name)
	if(#name < ALLIANCE_NAME_MINIMUM_LENGTH) then
		exports.USGmsg:msg(client, "The minimum length of the name is "..ALLIANCE_NAME_MINIMUM_LENGTH.."!", 255, 0, 0)
		return false
	end
	local group = getPlayerGroup(client)
	local allianceID = getGroupAlliance(group)	
	if(group and allianceID and alliances[allianceID]) then
		local alliance = alliances[allianceID]
		if(alliance.foundergroupid == group) then
			local member = playerMember[client]
			if(member and member.rank == 6) then
				if(setAllianceName(allianceID, name)) then
					triggerClientEvent(client, "USGcnr_groups.updateGroupData", client, {myAlliance = {alliancename = name}})
					outputAllianceMessage(allianceID, "The alliance has been renamed.")
				end
			else
				exports.USGmsg:msg(client, "You need to be the group founder to rename the alliance!", 255, 0, 0)
				return false
			end
		else
			exports.USGmsg:msg(client, "Your group needs to have founded the alliance in order to rename it!", 255, 0, 0)
			return false		
		end
	else
		exports.USGmsg:msg(client, "You are not in an alliance!", 255, 0, 0)
		return false
	end
end
addEventHandler("USGcnr_groups.renameAlliance", root, playerRenameAlliance)

addEvent("USGcnr_groups.setAllianceColor", true)
function playerSetAllianceColor(r,g,b)
	local group = getPlayerGroup(client)
	local allianceID = getGroupAlliance(group)	
	if(group and allianceID and alliances[allianceID]) then
		local alliance = alliances[allianceID]
		if(alliance.foundergroupid == group) then
			local member = playerMember[client]
			if(member and member.rank == 6) then
				if(setAllianceColor(allianceID, r,g,b)) then
					triggerClientEvent(client, "USGcnr_groups.updateGroupData", client, {myAlliance = {color = {r,g,b}}})
				end
			else
				exports.USGmsg:msg(client, "You need to be the group founder to set the alliance color!", 255, 0, 0)
				return false
			end
		else
			exports.USGmsg:msg(client, "Your group needs to have founded the alliance in order to change the color!", 255, 0, 0)
			return false		
		end
	else
		exports.USGmsg:msg(client, "You are not in an alliance!", 255, 0, 0)
		return false
	end
end
addEventHandler("USGcnr_groups.setAllianceColor", root, playerSetAllianceColor)

addEvent("USGcnr_groups.setAllianceInfo", true)
function playerSetAllianceInfo(info)
	local group = getPlayerGroup(client)
	local allianceID = getGroupAlliance(group)	
	if(group and allianceID and alliances[allianceID]) then
		local alliance = alliances[allianceID]
		if(alliance.foundergroupid == group) then
			local member = playerMember[client]
			if(member and member.rank == 6) then
				if(setAllianceInfo(allianceID, info)) then
					triggerClientEvent(client, "USGcnr_groups.updateGroupData", client, {myAlliance = {info = info}})
				end
			else
				exports.USGmsg:msg(client, "You need to be the group founder to update the alliance info!", 255, 0, 0)
				return false
			end
		else
			exports.USGmsg:msg(client, "Your group needs to have founded the alliance in order to update the info!", 255, 0, 0)
			return false		
		end
	else
		exports.USGmsg:msg(client, "You are not in an alliance!", 255, 0, 0)
		return false
	end
end
addEventHandler("USGcnr_groups.setAllianceInfo", root, playerSetAllianceInfo)

addEvent("USGcnr_groups.allianceKickGroup", true)
function playerKickGroupFromAlliance(groupid)
	local group = getPlayerGroup(client)
	local allianceID = getGroupAlliance(group)	
	if(group and allianceID and alliances[allianceID]) then
		local alliance = alliances[allianceID]
		if(alliance.foundergroupid ~= groupid) then
			if(alliance.foundergroupid == group) then
				local member = playerMember[client]
				if(member and member.rank == 6) then
					if(removeGroupFromAlliance(groupid)) then
						local groupList = {}
						for i, groupid in ipairs(alliance.groups) do
							if(groups[groupid]) then
								table.insert(groupList, {groupid = groupid, groupname = groups[groupid].groupname})
							end
						end	
						triggerClientEvent(client, "USGcnr_groups.updateGroupData", client, {myAlliance = {groups = groupList}})
						if(groups[groupid]) then
							outputAllianceMessage(allianceID, groups[groupid].groupname.." was kicked from the alliance.")
						end
					end
				else
					exports.USGmsg:msg(client, "You need to be the group founder to kick groups!", 255, 0, 0)
					return false
				end
			else
				exports.USGmsg:msg(client, "Your group needs to have founded the alliance in order to kick groups!", 255, 0, 0)
				return false		
			end
		else
			exports.USGmsg:msg(client, "You can not kick the founder group!", 255, 0, 0)
			return false
		end
	else
		exports.USGmsg:msg(client, "You are not in an alliance!", 255, 0, 0)
		return false
	end
end
addEventHandler("USGcnr_groups.allianceKickGroup", root, playerKickGroupFromAlliance)

addEvent("USGcnr_groups.allianceRemoveInvite", true)
function playerRemoveAllianceGroupInvite(groupid)
	local group = getPlayerGroup(client)
	local allianceID = getGroupAlliance(group)	
	if(group and allianceID and alliances[allianceID]) then
		local alliance = alliances[allianceID]
		if(alliance.foundergroupid == group) then
			local member = playerMember[client]
			if(member and member.rank == 6) then
				if(removeAllianceInvite(groupid, allianceID)) then
					triggerClientEvent(client, "USGcnr_groups.updateGroupData", client, {myAlliance = {invites = createAllianceInviteList(allianceID)}})
				end
			else
				exports.USGmsg:msg(client, "You need to be the group founder to remove invites!", 255, 0, 0)
				return false
			end
		else
			exports.USGmsg:msg(client, "Your group needs to have founded the alliance in order to remove invites!", 255, 0, 0)
			return false		
		end
	else
		exports.USGmsg:msg(client, "You are not in an alliance!", 255, 0, 0)
		return false
	end
end
addEventHandler("USGcnr_groups.allianceRemoveInvite", root, playerRemoveAllianceGroupInvite)

addEvent("USGcnr_groups.requestGroupList", true)
function playerRequestGroupList()
	local compactGroups = {}
	for id, group in pairs(groups) do
		if(not getGroupAlliance(id)) then
			table.insert(compactGroups, {id=id, groupname=group.groupname})
		end
	end
	triggerLatentClientEvent(client, "USGcnr_groups.recieveGroupList", 10000000, false, client, compactGroups)
end
addEventHandler("USGcnr_groups.requestGroupList", root, playerRequestGroupList)

addEvent("USGcnr_groups.allianceInviteGroup", true)
function playerInviteGroupToAlliance(groupid)
	local tGroup = groups[groupid]
	if(not tGroup) then
		exports.USGmsg:msg(client, "This group does not exit ( anymore )!", 255, 0, 0)
		return false
	end
	local member = playerMember[client]
	if(member and member.rank == 6) then
		local pGroup = groups[member.groupid]
		if(pGroup) then
			local alliance = getGroupAlliance(member.groupid)
			if(alliance and alliances[alliance] and alliances[alliance].foundergroupid == pGroup.groupid) then
				if(inviteGroupToAlliance(groupid, alliance)) then
					triggerClientEvent(client, "USGcnr_groups.updateGroupData", client, {myAlliance = {invites = createAllianceInviteList(alliance)}})
					exports.USGmsg:msg(client, "You have successfully invited the group ".. tGroup.groupname.."!", 0, 255, 0)
				else
					exports.USGmsg:msg(client, "Could not invite group, make sure it's not already invited.", 255, 0, 0)
				end
			else
				exports.USGmsg:msg(client, "Your group is not in an alliance or it does not lead it!", 255, 0, 0)
			end
		else
			exports.USGmsg:msg(client, "Could not find your group, please try again later.", 255, 0, 0)
		end
	else
		exports.USGmsg:msg(client, "You are not in a group or are not the leader of it!", 255, 0, 0)
	end
end
addEventHandler("USGcnr_groups.allianceInviteGroup", root, playerInviteGroupToAlliance)

addEvent("USGcnr_groups.acceptAllianceInvite", true)
function playerAcceptAllianceInvite(allianceid)
	local tAlliance = alliances[allianceid]
	if(not tAlliance) then
		exports.USGmsg:msg(client, "This alliance does not exit ( anymore )!", 255, 0, 0)
		return false
	end
	local member = playerMember[client]
	if(member and member.rank == 6) then
		local pGroup = groups[member.groupid]
		if(pGroup) then
			local alliance = getGroupAlliance(member.groupid)
			if(not alliance) then
				if(removeAllianceInvite(member.groupid, allianceid)) then
					addGroupToAlliance(member.groupid,allianceid)
					triggerClientEvent(client, "USGcnr_groups.updateGroupData", client, {myAlliance = getPlayerAllianceData(client)})	
				else
					exports.USGmsg:msg(client, "Something went wrong trying to accept this invite.", 255, 0, 0)
				end
			else
				exports.USGmsg:msg(client, "Your group is already in an alliance!", 255, 0, 0)
			end
		else
			exports.USGmsg:msg(client, "Could not find your group, please try again later.", 255, 0, 0)
		end
	else
		exports.USGmsg:msg(client, "You are not in a group or are not the leader of it!", 255, 0, 0)
	end
end
addEventHandler("USGcnr_groups.acceptAllianceInvite", root, playerAcceptAllianceInvite)

addEvent("USGcnr_groups.rejectAllianceInvite", true)
function playerRejectAllianceInvite(allianceid)
	local tAlliance = alliances[allianceid]
	if(not tAlliance) then
		exports.USGmsg:msg(client, "This alliance does not exit ( anymore )!", 255, 0, 0)
		return false
	end
	local member = playerMember[client]
	if(member and member.rank == 6) then
		local pGroup = groups[member.groupid]
		if(pGroup) then
			if(removeAllianceInvite(member.groupid, allianceid)) then
				exports.USGmsg:msg(client, "You have successfully rejected this invite.", 0, 255, 0)
			else
				exports.USGmsg:msg(client, "Something went wrong trying to reject this invite.", 255, 0, 0)
			end
		else
			exports.USGmsg:msg(client, "Could not find your group, please try again later.", 255, 0, 0)
		end
	else
		exports.USGmsg:msg(client, "You are not in a group or are not the leader of it!", 255, 0, 0)
	end
end
addEventHandler("USGcnr_groups.rejectAllianceInvite", root, playerRejectAllianceInvite)