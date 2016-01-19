loadstring(exports.MySQL:getQueryTool())()

groups = {}
usedGroupNames = {}
accountInvites = {}
accountMember = {}
playerMember = {}
local defaultCustomRanks = {[7] = {rankname="Custom Rank 1", permissions = {}, rankorder = 1},[8] = {rankname="Custom Rank 2", permissions={}, rankorder = 1}} 

function loadGroups()
	multiQuery(loadGroupsCallback,{},{{"SELECT * FROM cnr__groups"},{"SELECT * FROM cnr__groups_members"},{"SELECT * FROM cnr__groups_invites"}})
end

function loadGroupsCallback(dbGroups, members, invites)
	for i, group in ipairs(dbGroups) do
		local ranks
		if(not group.customranks) then
			ranks = defaultCustomRanks
		else 
			ranks = fromJSON(group.customranks)
		end
		group.ranks = {}
		for k,rank in pairs(ranks) do
			local perms = {}
			for i, perm in ipairs(rank.permissions) do
				perms[perm] = true
			end
			rank.permissions = perms
			group.ranks[tonumber(k)] = rank
		end
		group.groupname = exports.USG:trimString(group.groupname)
		group.players = {}
		group.invites = {}
		groups[group.groupid] = group
		usedGroupNames[group.groupname] = true
	end
	for i, groupmember in ipairs(members) do
		local group = groups[groupmember.groupid]
		if(group) then
			if(group.members) then
				table.insert(group.members, groupmember)
			else
				group.members = {groupmember}
			end
			accountMember[groupmember.membername] = groupmember
			local player = exports.USGaccounts:getPlayerFromAccount(groupmember.membername)
			if(isElement(player) and exports.USGrooms:getPlayerRoom(player) == "cnr") then
				playerMember[player] = groupmember
				table.insert(group.players, player)
			end
		end
	end
	for i,invite in ipairs(invites) do
		local group = groups[invite.groupid]
		invite.groupname = group.groupname
		if(group) then
			if(group.invites) then
				table.insert(group.invites, invite)
			else
				group.invites = {invite}
			end
		end
		if(accountInvites[invite.membername]) then
			table.insert(accountInvites[invite.membername], invite)
		else
			accountInvites[invite.membername] = {invite}
		end
	end
	addEvent("onPlayerJoinRoom", true)
	addEventHandler("onPlayerJoinRoom", root, playerJoinRoom)
	loadAlliances()
end
addEventHandler("onResourceStart", resourceRoot, loadGroups)

addEvent("USGcnr_groups.initGroupData", true)
function sendPlayerGroupData(player)
	if(exports.USGrooms:getPlayerRoom(player) == "cnr") then
		local data = { myGroup = {}	}
		local member = playerMember[player]
		if(member) then
			local group = groups[member.groupid]
			data.myGroup.name = group.groupname
			data.myGroup.id = group.groupid
			triggerClientEvent(player, "USGcnr_groups.updateGroupData", player, data)
		end
	end
end

addEventHandler("USGcnr_groups.initGroupData", root, function () sendPlayerGroupData(client) end)

function playerJoinRoom(room)
	if(room ~= "cnr") then return end
	local account = exports.USGaccounts:getPlayerAccount(source)
	playerMember[source] = accountMember[account]
	if(accountMember[account]) then
		local groupid = accountMember[account].groupid
		if(groupid and groups[groupid]) then
			table.insert(groups[groupid].players, source)
		end
		sendPlayerGroupData(source)
	end
end

function playerExit()
	if(playerMember[source] and groups[playerMember[source].groupid]) then
		for i, player in ipairs(groups[playerMember[source].groupid].players) do
			if(player == source) then
				table.remove(groups[playerMember[source].groupid].players, i)
				break
			end
		end
	end
	playerMember[source] = nil
end
addEvent("onPlayerExitRoom", true)
addEventHandler("onPlayerExitRoom", root, playerExit)
addEventHandler("onPlayerQuit", root, playerExit)


function createGroup(name,source)
	if(not exports.USGaccounts:getPlayerAccount(source)) then return false end
	local name = exports.USG:trimString(name)
	if(usedGroupNames[name]) then
		exports.USGmsg:msg(source,"This group name is already in use! Pick a new name.", 255,0,0)
		return false
	end
	local account = exports.USGaccounts:getPlayerAccount(source)
	insert(addGroup,{source, name, account},"INSERT INTO cnr__groups SET groupname=?, groupfounder=?, customranks=?", name, account, toJSON(defaultCustomRanks))
	return true
end

function addGroup(groupID, player, name, account)
	if(not groupID) then return end
	local member = { membername = account, groupid = groupID, rank = 6}
	groups[groupID] = { groupid = groupID, groupname = name, groupfounder = account, colorR = 255, colorG = 0, colorB = 0, 
		members = {member}, invites = {}, ranks = defaultCustomRanks, players = { player } }
	usedGroupNames[name] = true
	exports.MySQL:execute("INSERT INTO cnr__groups_members SET groupid=?, membername=?, rank=?",groupID,account,6) -- add founder as member
	accountMember[account] = member
	playerMember[player] = member
	requestGroupData(player)
	groupMessage(groupID, "Welcome to your new group!")
end
addEvent("onGroupDelete",true)
function deleteGroup(groupID)
	if(not groupID or not groups[groupID]) then return false end
	groupMessage(groupID, "The group has been deleted.")
	local group = groups[groupID]
	for i, member in ipairs(group.members) do
		accountMember[member.membername] = nil
		local player = exports.USGaccounts:getPlayerFromAccount(member.membername)
		if(isElement(player)) then
			playerMember[player] = nil
		end
	end
	for _, invite in ipairs(group.invites) do
		if(accountInvites[invite.membername]) then
			for i, accInvite in ipairs(accountInvites[invite.membername]) do
				if(accInvite.inviteid == invite.inviteid) then
					table.remove(accountInvites[invite.membername], i)
					break
				end
			end
		end
	end
	usedGroupNames[group.groupname] = nil
	groups[groupID] = nil
	exports.MySQL:execute("DELETE FROM cnr__groups WHERE groupid=?",groupID)
	exports.MySQL:execute("DELETE FROM cnr__groups_invites WHERE groupid=?",groupID)
	exports.MySQL:execute("DELETE FROM cnr__groups_members WHERE groupid=?",groupID)
	triggerEvent("onGroupDelete", root, groupID)
	return true
end

function setCustomRanks(groupID, ranks)
	local group = groups[groupID]
	if(group) then
		group.ranks = ranks
		exports.Mysql:execute("UPDATE cnr__groups SET customranks=? WHERE groupid=?", toJSON(ranks), groupID)
		return true
	else
		return false
	end
end
addEvent("onGroupColorChange",true)
function setGroupColor(groupID, r, g, b)
	if(groups[groupID]) then
		groups[groupID].colorR, groups[groupID].colorG, groups[groupID].colorB = r, g, b
		triggerEvent("onGroupColorChange", root, groupID, r,g,b)
		groupMessage(groupID, "The group color was changed to "..exports.USG:convertRGBToHEX(r,g,b).."this.")
		return exports.mysql:execute("UPDATE cnr__groups SET colorR=?,colorG=?,colorB=?", r,g,b)
	else
		return false
	end
end

function setGroupName(groupID, newName, player)
	if(not groups[groupID]) then return false end
	if(#newName < NAME_MINIMUM_LENGTH) then 
		if(isElement(player)) then 
			exports.USGmsg:msg(player, "This name is too short, it must be "..NAME_MINIMUM_LENGTH.." characters long!",255,0,0) 
		end 
		return false 
	end
	if(not usedGroupNames[newName]) then
		query(setGroupNameCallback, {player,newName,groupID},"UPDATE cnr__groups SET groupname=? WHERE groupid=?",newName,groupID)
		return true
	else
		if(isElement(player)) then
			exports.USGmsg:msg(player, "This name is already being used!")
		end
		return false
	end
end

function setGroupNameCallback(result, player, newName, groupID)
	if(not result and isElement(player)) then
		exports.USGmsg:msg(player, "Error updating name, this name may have already been taken.", 255, 0, 0)
	else
		groupMessage(groupID, "This group has been renamed to "..newName.."!")
		usedGroupNames[groups[groupID].groupname] = false
		groups[groupID].groupname = newName
		usedGroupNames[newName] = true
		if(isElement(player)) then
			exports.USGmsg:msg(player, "Successfully renamed group!", 0, 255, 0)
		end
	end
end

function addMember(groupID, account)
	if(groups[groupID]) then
		if(accountMember[account]) then
			return false -- already in a group
		else
			local member = {membername = account, groupid = groupID, rank = 1}
			table.insert(groups[groupID].members, member)
			accountMember[account] = member
			local player = exports.USGaccounts:getPlayerFromAccount(account)
			if(isElement(player)) then
				playerMember[player] = member
				table.insert(groups[groupID].players, player)
			end
			groupMessage(groupID, "Welcome "..account.." into the group!")
			return exports.MySQL:execute("INSERT INTO cnr__groups_members SET membername=?, groupid=?, rank=?",account,groupID,1)
		end
	end
end

function setMemberRank(groupID, account, rank)
	if(groups[groupID]) then
		if(accountMember[account] and accountMember[account].groupid == groupID) then
			exports.Mysql:execute("UPDATE cnr__groups_members SET rank=? WHERE membername=?",rank, account)
			for i, member in ipairs(groups[groupID].members) do
				if(member.membername == account) then
					member.rank = rank
					break
				end
			end
			local player = exports.USGaccounts:getPlayerFromAccount(account)
			if(isElement(player)) then
				playerMember[player].rank = rank
			end	
			accountMember[account].rank = rank
			return true
		end
	end
end

function removeMember(groupID, account)
	if(groups[groupID]) then
		if(accountMember[account] and accountMember[account].groupid == groupID) then
			exports.Mysql:execute("DELETE FROM cnr__groups_members WHERE membername=?",account)
			for i, member in ipairs(groups[groupID].members) do
				if(member.membername == account) then
					table.remove(groups[groupID].members, i)
					break
				end
			end
			local player = exports.USGaccounts:getPlayerFromAccount(account)
			if(isElement(player)) then
				playerMember[player] = nil
				for i, p in ipairs(groups[groupID].players) do
					if(p == player) then
						table.remove(groups[groupID].players, i)
						break
					end
				end
			end	
			accountMember[account] = nil
			return true
		end
	end
end

function inviteMember(groupID, account, inviter)
	if(groups[groupID] and account) then
		if(accountMember[account] and accountMember[account].groupid == groupID) then
			exports.USGmsg:msg(inviter, "This account already has a group!", 255, 0, 0)
			return false
		end
		local inviterAccount = exports.USGaccounts:getPlayerAccount(inviter)
		local invites = accountInvites[account]
		if(invites) then
			for i, invite in ipairs(invites) do
				if(invite.groupid == groupID) then
					exports.USGmsg:msg(inviter, "This account already has an invite from your group!", 0, 255, 0)
					return
				end
			end
		end
		insert(memberInvited,{groupID, account, inviterAccount},"INSERT INTO cnr__groups_invites SET groupid=?, membername=?, invitedby=?",groupID, account, inviterAccount)
		exports.USGmsg:msg(inviter, "You have invited the account "..account.." to your group!", 0, 255, 0)
	end
end

function memberInvited(inviteID, groupID, account, inviterAccount)
	local invite = { groupname = groups[groupID].groupname, groupid = groupID, inviteid = inviteID, membername = account, invitedby = inviterAccount }
	if(not accountInvites[account]) then accountInvites[account] = {} end
	if(not groups[groupID].invites) then groups[groupID].invites = {} end
	table.insert(accountInvites[account], invite)
	table.insert(groups[groupID].invites, invite)
	local player = exports.USGaccounts:getPlayerFromAccount(account)
	if(player) then
		exports.USGmsg:msg(player, "You have recieved an invite for "..invite.groupname, 0, 255, 0)
	end
end

function memberHasPermissionTo(member, permission)
	if(isElement(member)) then member = playerMember[member] end
	if(not member) then return false end
	local rank = member.rank
	if(defaultRanks[rank]) then
		return defaultRanks[rank].permissions[permission] or defaultRanks[rank].permissions["all"]
	else
		return groups[member.groupid].ranks[rank].permissions[permission] or groups[member.groupid].ranks[rank].permissions["all"]
	end
	return false
end

function groupMessage(groupID, message)
	if(groups[groupID]) then
		for i, player in ipairs(groups[groupID].players) do
			outputChatBox("["..groups[groupID].groupname.."] "..message, player, 150,0,0, true)
		end
	end
end

local antiSpam = {}

function onCommandGroupChat(pSource, cmd, ...)
	local message = table.concat({...}, " ")
	local pMute = exports.USGadmin:getPlayerMute(pSource)
	if(pMute and pMute == "global") then
		exports.USGmsg:msg(pSource, "You are muted ( "..pMute.." ), you can't talk.", 255, 0, 0)
		return false
	end		
	if(not antiSpam[pSource] or antiSpam[pSource] < getTickCount()-1500) then
		groupChat(pSource, message)
	else
		exports.USGmsg:msg(pSource,"Calm down, wait before talking in group chat again.", 255,0,0)
	end
end
addCommandHandler("gc", onCommandGroupChat, false)
addCommandHandler("group", onCommandGroupChat, false)
addCommandHandler("groupchat", onCommandGroupChat, false)

function groupChat(player, message)
	if(playerMember[player]) then
		antiSpam[player] = getTickCount()
		groupMessage(playerMember[player].groupid, exports.USG:getPlayerColoredName(player,":#FFFFFF ")..message)
	end
end