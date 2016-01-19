addEvent("USGcnr_groups.requestGroupData", true)
function requestGroupData(requester)
	local data = { myGroup = {}, myPermissions = {}	}
	local member = playerMember[requester]
	if(member) then
		local group = groups[member.groupid]
		local rank = member.rank
		if(defaultRanks[rank]) then
			rank = defaultRanks[rank]
		elseif(group.ranks[rank]) then
			rank = group.ranks[rank]
		end
		data.myRank = member.rank
		data.myGroup.name = group.groupname
		data.myGroup.info = group.groupinfo
		data.myGroup.id = member.groupid
		data.myGroup.members = group.members
		for i, member in ipairs(data.myGroup.members) do
			member.nick = exports.USGplayerlookup:getAccountNick(member.membername)
			member.lastseen = exports.USGplayerlookup:getAccountLastSeen(member.membername)
		end
		data.myGroup.alliance = group.alliance
		data.myGroup.invites = group.invites
		data.myGroup.founder = group.groupfounder
		data.myGroup.color = {group.colorR, group.colorG, group.colorB}
		data.myPermissions = {}
		for permission, description in pairs(permissions) do
			if(memberHasPermissionTo(member, permission)) then
				data.myPermissions[permission] = true
			end
		end
		if(memberHasPermissionTo(member, "customRanks") or memberHasPermissionTo(member, "ranks")) then
			data.myGroup.ranks = group.ranks
		end
		data.myAlliance = getPlayerAllianceData(requester)
		if(not data.myAlliance) then
			data.allianceInvites = createGroupAllianceInviteList(member.groupid)
		end
	end
	if(not member) then data.invites = accountInvites[exports.USGaccounts:getPlayerAccount(requester)] or {} end -- if not in a group, send invites
	triggerLatentClientEvent(requester, "USGcnr_groups.recieveGroupData", 100000, requester, data)
end
addEventHandler("USGcnr_groups.requestGroupData", root, function () requestGroupData(client) end)

addEvent("USGcnr_groups.createGroup", true)
function playerCreateGroup(name)
	if(not playerMember[client]) then
		createGroup(name, client)
	else
		exports.USGmsg:msg(client,"You're already in a group!", 255, 0, 0)
	end
end
addEventHandler("USGcnr_groups.createGroup", root, playerCreateGroup)

addEvent("USGcnr_groups.leaveGroup", true)
function playerLeaveGroup(name)
	if(playerMember[client]) then
		local member = playerMember[client]
		local group = groups[member.groupid]
		if(#group.members > 1) then
			local onlyPowerMember = true
			for i, groupMember in ipairs(group.members) do
				if( groupMember.membername ~= member.membername and memberHasPermissionTo(groupMember, "delete") and memberHasPermissionTo(groupMember, "ranks")) then
					onlyPowerMember = false
					break
				end
			end
			if(onlyPowerMember) then
				exports.USGmsg:msg(client,"You're the only member who can delete and set ranks, you must give someone else that power before leaving!", 255, 0, 0)
				return false
			end
			-- regular delete
			removeMember(member.groupid, member.membername)
			requestGroupData(client) -- load having no group
		else
			if(deleteGroup(member.groupid)) then
				requestGroupData(client)
			end
			exports.USGmsg:msg(client, "You're the only member left in this group, the group has been deleted.", 255,128,0)
			return false
		end
	else
		exports.USGmsg:msg(client,"You're not in a group!", 255, 0, 0)
	end
end
addEventHandler("USGcnr_groups.leaveGroup", root, playerLeaveGroup)

addEvent("USGcnr_groups.acceptInvite", true)
function playerAcceptInvite(id)
	local account = exports.USGaccounts:getPlayerAccount(client)
	local invites = accountInvites[account]
	local legitID = false
	local group 
	if(invites and #invites > 0) then
		for i,invite in ipairs(invites) do
			if(invite.inviteid == id and invite.membername == account) then
				group = groups[invite.groupid]
				table.remove(invites,i)
				legitID = true
				break
			end
		end
	end
	if(group) then
		for i, invite in ipairs(group.invites) do
			if(invite.inviteid == id and invite.membername == account) then
				table.remove(group.invites, i)
				break
			end
		end
	end
	if(legitID) then
		if(addMember(group.groupid, account)) then
			exports.MySQL:execute("DELETE FROM cnr__groups_invites WHERE inviteid=?", id)
			requestGroupData(client) -- load the new group
		end	
	end
	exports.USGmsg:msg(client, "This invite was not found!", 255, 0, 0)
end
addEventHandler("USGcnr_groups.acceptInvite", root, playerAcceptInvite)

addEvent("USGcnr_groups.rejectInvite", true)
function playerRejectInvite(id)
	local account = exports.USGaccounts:getPlayerAccount(client)
	local invites = accountInvites[account]
	local legitID = false
	local group 
	if(invites and #invites > 0) then
		for i,invite in ipairs(invites) do
			if(invite.inviteid == id and invite.membername == account) then
				group = groups[invite.groupid]
				table.remove(invites,i)
				legitID = true
				break
			end
		end
	end
	if(group) then
		for i, invite in ipairs(group.invites) do
			if(invite.inviteid == id and invite.membername == account) then
				table.remove(group.invites, i)
				break
			end
		end
	end
	if(legitID) then
		exports.MySQL:execute("DELETE FROM cnr__groups_invites WHERE inviteid=?", id)
		triggerClientEvent(client, "USGcnr_groups.updateGroupData", client, { invites = accountInvites[account] }) -- update new invite table
	end
end
addEventHandler("USGcnr_groups.rejectInvite", root, playerRejectInvite)

addEvent("USGcnr_groups.removeInvite", true)
function playerRemoveInvite(id)
	local member = playerMember[source]
	local legitID = false
	local group = groups[member.groupid]
	local accInvites
	if(group) then
		for i, invite in ipairs(group.invites) do
			if(invite.inviteid == id and invite.membername == account) then
				table.remove(group.invites, i)
				accInvites = accountInvites[invite.membername]
				legitID = true
				break
			end
		end
	else
		return false
	end
	if(accInvites) then
		for i,invite in ipairs(accInvites) do
			if(invite.inviteid == id) then
				table.remove(accInvites,i)
				break
			end
		end
	end
	if(legitID) then
		exports.MySQL:execute("DELETE FROM cnr__groups_invites WHERE inviteid=?", id)
		triggerClientEvent(client, "USGcnr_groups.updateGroupData", client, { myGroup = { invites = group.invites } }) -- update new invite table
	end
end
addEventHandler("USGcnr_groups.removeInvite", root, playerRemoveInvite)

addEvent("USGcnr_groups.invitePlayer", true)
function playerInvitePlayer(player)
	if(memberHasPermissionTo(client, "invite")) then
		inviteMember(playerMember[client].groupid, exports.USGaccounts:getPlayerAccount(player), client)
	else
		exports.USGmsg:msg(client, "You do not have permission to invite players!", 255,0,0)
	end
end
addEventHandler("USGcnr_groups.invitePlayer", root, playerInvitePlayer)

addEvent("USGcnr_groups.updateInfo", true)
function playerUpdateInfo(newInfo)
	local member = playerMember[client]
	if(member and member.groupid and groups[member.groupid]) then
		if(memberHasPermissionTo(member, "updateInfo")) then
			exports.MySQL:execute("UPDATE cnr__groups SET groupinfo=? WHERE groupid=?", newInfo, member.groupid)
			groups[member.groupid].groupinfo = newInfo
			exports.USGmsg:msg(client, "The group info has been updated!", 0, 255, 0)
		else
			exports.USGmsg:msg(client, "You do not have permission to update the group info!", 255, 0, 0)
		end
	else
		exports.USGmsg:msg(client, "You're not in a group!", 255, 0, 0)
	end
end
addEventHandler("USGcnr_groups.updateInfo", root, playerUpdateInfo)

function getPlayerRankOrder(p)
	local member = p
	if(isElement(p)) then
		member = playerMember[p]
	end
	if(not member) then return false end
	local group = groups[member.groupid]
	if(member.rank and member.rank <= 6) then
		return member.rank
	elseif(member.rank and group.ranks[member.rank] and group.ranks[member.rank].rankorder) then
		return group.ranks[member.rank].rankorder
	else
		return 0
	end
end

addEvent("USGcnr_groups.kickMember", true)
function playerKickMember(membername)
	if(memberHasPermissionTo(client, "ranks")) then
		local member = accountMember[membername]
		if(not member) then 
			exports.USGmsg:msg(client, "This member was not found!", 255,0,0)
			return false 
		end
		local sourcemember = playerMember[client]
		if(not sourcemember) then return false end
		if(sourcemember.membername == member.membername) then
			exports.USGmsg:msg(client, "You can not kick yourself, leave instead.", 255,0,0)
			return false
		end
		if(member.rank < getPlayerRankOrder(sourcemember) or sourcemember.rank == 6) then
			removeMember(sourcemember.groupid, membername)
			triggerClientEvent(client, "USGcnr_groups.updateGroupData", client, { myGroup = { members = groups[sourcemember.groupid].members } })
			exports.USGmsg:msg(client, "Member '"..membername.."' has been kicked!", 0, 255, 0)	
		else
			exports.USGmsg:msg(client, "You do not have permission to kick this member!", 255,0,0)
		end
	else
		exports.USGmsg:msg(client, "You do not have permission to kick members!", 255,0,0)
	end
end
addEventHandler("USGcnr_groups.kickMember", root, playerKickMember)

addEvent("USGcnr_groups.promoteMember", true)
function playerPromoteMember(membername)
	if(memberHasPermissionTo(client, "ranks")) then
		local member = accountMember[membername]
		if(not member) then 
			exports.USGmsg:msg(client, "This member was not found!", 255,0,0)
			return false 
		end
		local sourcemember = playerMember[client]
		if(not sourcemember) then return false end
		if(sourcemember.membername == member.membername) then
			exports.USGmsg:msg(client, "You can not promote yourself.", 255,0,0)
			return false
		end	
		local newRank = member.rank+1
		if(newRank == 6) then newRank = 7 end
		if(newRank > 8) then
			exports.USGmsg:msg("You can't promote this member any more.", 255, 0, 0)
			return false
		end
		local group = groups[sourcemember.groupid]
		local newRankOrder = group.ranks[newRank] and group.ranks[newRank].rankorder or newRank
		if(member.rank ~= 6 and newRankOrder < getPlayerRankOrder(sourcemember) or sourcemember.rank == 6) then
			if(defaultRanks[newRank] or group.ranks[newRank]) then
				setMemberRank(sourcemember.groupid, member.membername, newRank)
				triggerClientEvent(client, "USGcnr_groups.updateGroupData", client, { myGroup = { members = groups[sourcemember.groupid].members } })
				local rankname = group.ranks[newRank] and group.ranks[newRank].rankname or defaultRanks[newRank].name
				exports.USGmsg:msg(client, "Member '"..member.membername.."' has been promoted to "..rankname.."!", 0, 255, 0)
			else
				exports.USGmsg:msg(client, "This member can not be promoted!", 255, 0, 0)
			end
		else
			exports.USGmsg:msg(client, "You do not have permission to promote this member!", 255,0,0)
		end
	else
		exports.USGmsg:msg(client, "You do not have permission to promote members!", 255,0,0)
	end
end
addEventHandler("USGcnr_groups.promoteMember", root, playerPromoteMember)

addEvent("USGcnr_groups.demoteMember", true)
function playerDemoteMember(membername)
	if(memberHasPermissionTo(client, "ranks")) then
		local member = accountMember[membername]
		if(not member) then 
			exports.USGmsg:msg(client, "This member was not found!", 255,0,0)
			return false 
		end
		local sourcemember = playerMember[client]
		if(not sourcemember) then return false end
		if(sourcemember.membername == member.membername) then
			exports.USGmsg:msg(client, "You can not demote yourself.", 255,0,0)
			return false
		end
		local newRank = member.rank-1
		if(newRank == 6) then newRank = 5 end
		local group = groups[sourcemember.groupid]
		local newRankOrder = group.ranks[newRank] and group.ranks[newRank].rankorder or newRank
		if(member.rank ~= 6 and getPlayerRankOrder(member) < getPlayerRankOrder(sourcemember) or sourcemember.rank == 6) then
			if(defaultRanks[newRank] or group.ranks[newRank]) then		
				setMemberRank(sourcemember.groupid, member.membername, newRank)
				triggerClientEvent(client, "USGcnr_groups.updateGroupData", client, { myGroup = { members = groups[sourcemember.groupid].members } })
				local rankname = group.ranks[newRank] and group.ranks[newRank].rankname or defaultRanks[newRank].name
				exports.USGmsg:msg(client, "Member '"..member.membername.."' has been demoted to "..rankname.."!", 0, 255, 0)	
			else
				exports.USGmsg:msg(client, "This member can not be demoted, kick him instead!", 255, 0, 0)
			end
		else
			exports.USGmsg:msg(client, "You do not have permission to demote this member!", 255,0,0)
		end
	else
		exports.USGmsg:msg(client, "You do not have permission to demote members!", 255,0,0)
	end
end
addEventHandler("USGcnr_groups.demoteMember", root, playerDemoteMember)

addEvent("USGcnr_groups.deleteGroup", true)
function playerDeleteGroup(password)
	local member = playerMember[client]
	if(member and groups[member.groupid]) then
		if(member.rank == 6 or #(groups[member.groupid].members) == 1) then -- if founder or only member left
			local hashedPass = exports.USGaccounts:hash(member.membername, password)
			singleQuery(playerDeleteGroupCallback, {client, hashedPass}, "SELECT password FROM accounts WHERE username=?", exports.USGaccounts:getPlayerAccount(client))
		else
			exports.USGmsg:msg(client, "You do not have permission to delete the group!", 255, 0, 0)
		end
	else
		exports.USGmsg:msg(client, "You're not in a group!", 255, 0, 0)
	end
end
addEventHandler("USGcnr_groups.deleteGroup", root, playerDeleteGroup)

function playerDeleteGroupCallback(result,player,hashedPass)
	if(not isElement(player)) then return false end
	if(result and result.password == hashedPass) then
		-- delete the group after double checking values
		local member = playerMember[player]
		if(member and groups[member.groupid]) then
			if(member.rank == 6 or #(groups[member.groupid].members) == 1) then -- if founder or only member left
				if(deleteGroup(member.groupid)) then
					exports.USGmsg:msg(player, "Successfully deleted group!", 0, 255, 0)
					requestGroupData(player)
				else
					exports.USGmsg:msg(player, "There occured an error while deleting your group, please try again later.", 255, 0, 0)
				end
			else
				exports.USGmsg:msg(player, "You do not have permission to delete the group!", 255, 0, 0)
			end
		else
			exports.USGmsg:msg(player, "You're not in a group!", 255, 0, 0)
		end		
	else
		exports.USGmsg:msg(player,"Password does not match.", 255, 0, 0)
	end
end

addEvent("USGcnr_groups.renameGroup", true)
function playerRenameGroup(newName)
	local member = playerMember[client]
	if(member and groups[member.groupid]) then
		if(member.rank == 6) then -- if founder
			setGroupName(member.groupid, newName, client)	
		else
			exports.USGmsg:msg(client, "You do not have permission to rename the group!", 255, 0, 0)
		end
	else
		exports.USGmsg:msg(client, "You're not in a group!", 255, 0, 0)
	end
end
addEventHandler("USGcnr_groups.renameGroup", root, playerRenameGroup)

addEvent("USGcnr_groups.updateCustomRanks", true)
function playerUpdateCustomRanks(newRanks)
	local member = playerMember[client]
	if(member and memberHasPermissionTo(member, "customRanks")) then
		if(setCustomRanks(member.groupid, newRanks)) then
			exports.USGmsg:msg(client, "Successfully updated custom ranks!", 0, 55, 0)
		else
			exports.USGmsg:msg(client, "Something went wrong trying to set custom ranks, try again later.", 255, 0, 0)
		end
	else
		exports.USGmsg:msg(client, "You do not have permission to update the custom ranks!", 255, 0, 0)
	end
end
addEventHandler("USGcnr_groups.updateCustomRanks", root, playerUpdateCustomRanks)

addEvent("USGcnr_groups.setColor", true)
function playerSetColor(r,g,b)
	local member = playerMember[client]
	if(member and memberHasPermissionTo(member, "setColor")) then
		if(setGroupColor(member.groupid, r,g,b)) then
			exports.USGmsg:msg(client, "Successfully set color!", 0,255,0)
			triggerClientEvent(client, "USGcnr_groups.updateGroupData", client, {myGroup = { color = {r,g,b} } })
		else
			exports.USGmsg:msg(client, "Something went wrong trying to set the color, try again later.", 255,0,0)
		end
	else
		exports.USGmsg:msg(client, "You do not have permission to set the group color!", 255, 0, 0)
	end
end
addEventHandler("USGcnr_groups.setColor", root, playerSetColor)