function onCreateGroup()
	local groupName = exports.USGGUI:getText(groupGUI.general.createGroupName)
	if(#groupName:gsub(" ","") == 0) then
		exports.USGmsg:msg("You need to specify a name", 255,0,0)
		return false
	end
	triggerServerEvent("USGcnr_groups.createGroup", localPlayer, groupName)
end

function onLeaveGroup()
	if(groupData.myGroup and groupData.myGroup.id) then
		if(not isElement(openDialogs.leaveGroup)) then
			openDialogs.leaveGroup = exports.USGGUI:createDialog("Leave group", "Are you sure that you want to leave the group "..groupData.myGroup.name.."?","confirm")
			addEventHandler("onUSGGUIDialogFinish", openDialogs.leaveGroup, onLeaveGroupFinish, false)
		else
			exports.USGGUI:focus(openDialogs.leaveGroup)
		end
	end
end

function onLeaveGroupFinish(result)
	if(result) then
		triggerServerEvent("USGcnr_groups.leaveGroup", localPlayer)
	end
end

function onUpdateInfo()
	local newInfo = exports.USGGUI:getText(groupGUI.general.groupinfo)
	if(newInfo ~= groupData.myGroup.info) then
		triggerServerEvent("USGcnr_groups.updateInfo", localPlayer, newInfo)
	else
		exports.USGmsg:msg("You have to change the group info!", 255, 0, 0)
	end
end

function onOpenAlliances()
end

function onAcceptInvite()
	local selected = exports.USGGUI:gridlistGetSelectedItem(groupGUI.general.myInvites)
	if(selected) then
		local id = exports.USGGUI:gridlistGetItemData(groupGUI.general.myInvites,selected,1)
		triggerServerEvent("USGcnr_groups.acceptInvite", localPlayer, id)
	end
end

function onRejectInvite()
	local selected = exports.USGGUI:gridlistGetSelectedItem(groupGUI.general.myInvites)
	if(selected) then
		local id = exports.USGGUI:gridlistGetItemData(groupGUI.general.myInvites,selected,1)
		triggerServerEvent("USGcnr_groups.rejectInvite", localPlayer, id)
	end
end

function onOpenInvites()
	if(not isElement(openDialogs.invites)) then
		if(#groupData.myGroup.invites == 0) then
			exports.USGmsg:msg("There are currently no invites.", 255,0,0)
			return false
		end
		local invites = {}
		for _, invite in ipairs(groupData.myGroup.invites) do
			invites[invite.inviteid] =invite.membername
		end
		openDialogs.invites = exports.USGGUI:createDialog("View and remove invites", "Select the invite to remove","select",invites,true)
		addEventHandler("onUSGGUIDialogFinish", openDialogs.invites, onInvitesFinish, false)
	else
		exports.USGGUI:focus(openDialogs.invites)
	end
end

function onInvitesFinish(result)
	if(result) then
		if(groupData.myPermissions.invite) then
			triggerServerEvent("USGcnr_groups.removeInvite", localPlayer, result)
		else
			exports.USGmsg:msg("You do not have permission to remove invites!", 255,0,0)
		end
	end
end

function onInvitePlayer()
	if(groupData.myPermissions.invite) then	
		if(not isElement(openDialogs.invitePlayer)) then
			local players = {}
			for i, player in ipairs(getElementsByType("player")) do
				if(player ~= localPlayer) then
					players[player] = getPlayerName(player)
				end
			end
			openDialogs.invitePlayer = exports.USGGUI:createDialog("Invite a member","Select the member to invite","select", players, true)
			addEventHandler("onUSGGUIDialogFinish", openDialogs.invitePlayer, onInvitePlayerFinish, false)
		else
			exports.USGGUI:focus(openDialogs.invitePlayer)
		end
	else
		exports.USGmsg:msg("You do not have permission to invite members!", 255,0,0)
	end
end

function onInvitePlayerFinish(result)
	if(result and isElement(result)) then
		triggerServerEvent("USGcnr_groups.invitePlayer", localPlayer, result)
	end
end

function getRankOrder()
	if(groupData.myRank and groupData.myRank <= 6) then
		return groupData.myRank
	elseif(groupData.myRank and groupData.myGroup.ranks[groupData.myRank] and groupData.myGroup.ranks[groupData.myRank].rankorder) then
		return groupData.myGroup.ranks[groupData.myRank].rankorder
	else
		return 0
	end
end

function onKickMember()
	local selected = exports.USGGUI:gridlistGetSelectedItem(groupGUI.members.list)
	if(selected) then
		local membername = exports.USGGUI:gridlistGetItemData(groupGUI.members.list, selected, 1)
		local rank = exports.USGGUI:gridlistGetItemData(groupGUI.members.list, selected, 3)
		if((groupData.myPermissions.ranks and rank < getRankOrder()) or groupData.myRank == 6) then
			if(membername ~= exports.USGaccounts:getPlayerAccount()) then
				if(not isElement(openDialogs.kickMember)) then
					openDialogs.kickMember = exports.USGGUI:createDialog("Kick a member", "Are you sure that you want to kick "..membername.."?", "confirm")
					addEventHandler("onUSGGUIDialogFinish", openDialogs.kickMember, onKickMemberFinish, false)
				else
					exports.USGGUI:focus(openDialogs.kickMember)
				end
			else
				exports.USGmsg:msg("You can not kick yourself, leave instead.", 255, 0, 0)
			end
		else
			exports.USGmsg:msg("You do not have enough permission to kick this member!", 255, 0, 0)
		end
	else
		exports.USGmsg:msg("You haven't selected a member!", 255, 0, 0)
	end
end

function onKickMemberFinish(result)
	if(result) then
		local selected = exports.USGGUI:gridlistGetSelectedItem(groupGUI.members.list)
		if(selected) then
			local membername = exports.USGGUI:gridlistGetItemData(groupGUI.members.list, selected, 1)
			triggerServerEvent("USGcnr_groups.kickMember", localPlayer, membername)
		else
			exports.USGmsg:msg("You haven't selected a member!", 255, 0, 0)
		end
	end
end

function onPromoteMember()
	local selected = exports.USGGUI:gridlistGetSelectedItem(groupGUI.members.list)
	if(selected) then
		local membername = exports.USGGUI:gridlistGetItemData(groupGUI.members.list, selected, 1)
		local rank = exports.USGGUI:gridlistGetItemData(groupGUI.members.list, selected, 3)
		local newRank = rank+1
		if(newRank == 6) then newRank = 7 end
		if(newRank > 8) then
			exports.USGmsg:msg("You can't promote this member any more.", 255, 0, 0)
			return false
		end
		local newRankOrder = groupData.myGroup.ranks[newRank] and groupData.myGroup.ranks[newRank].rankorder or newRank
		if((rank ~= 6 and groupData.myPermissions.ranks and newRankOrder < getRankOrder()) or groupData.myRank == 6) then -- newRank < rank
			if(membername ~= exports.USGaccounts:getPlayerAccount()) then
				if(not isElement(openDialogs.promoteMember)) then
					openDialogs.promoteMember = exports.USGGUI:createDialog("Promote a member", "Are you sure that you want to promote "..membername.."?", "confirm")
					addEventHandler("onUSGGUIDialogFinish", openDialogs.promoteMember, onPromoteMemberFinish, false)
				else
					exports.USGGUI:focus(openDialogs.promoteMember)
				end
			else
				exports.USGmsg:msg("You can not promote yourself.", 255, 0, 0)
			end
		else
			exports.USGmsg:msg("You do not have enough permission to promote this member!", 255, 0, 0)
		end
	else
		exports.USGmsg:msg("You haven't selected a member!", 255, 0, 0)
	end
end

function onPromoteMemberFinish(result)
	if(result) then
		local selected = exports.USGGUI:gridlistGetSelectedItem(groupGUI.members.list)
		if(selected) then
			local membername = exports.USGGUI:gridlistGetItemData(groupGUI.members.list, selected, 1)
			triggerServerEvent("USGcnr_groups.promoteMember", localPlayer, membername)
		else
			exports.USGmsg:msg("You haven't selected a member!", 255, 0, 0)
		end
	end
end

function onDemoteMember()
	local selected = exports.USGGUI:gridlistGetSelectedItem(groupGUI.members.list)
	if(selected) then
		local membername = exports.USGGUI:gridlistGetItemData(groupGUI.members.list, selected, 1)
		local rank = exports.USGGUI:gridlistGetItemData(groupGUI.members.list, selected, 3)
		local newRank = rank-1
		if(newRank == 6) then newRank = 5 end
		if(newRank < 1) then
			exports.USGmsg:msg("You can't demote this member any more, kick them instead.", 255, 0, 0)
			return false
		end
		local newRankOrder = groupData.myGroup.ranks[newRank] and groupData.myGroup.ranks[newRank].rankorder or newRank
		if((rank ~= 6 and groupData.myPermissions.ranks and newRankOrder < getRankOrder()) or groupData.myRank == 6) then
			if(membername ~= exports.USGaccounts:getPlayerAccount()) then
				if(not isElement(openDialogs.demoteMember)) then
					openDialogs.demoteMember = exports.USGGUI:createDialog("Demote a member", "Are you sure that you want to demote "..membername.."?", "confirm")
					addEventHandler("onUSGGUIDialogFinish", openDialogs.demoteMember, onDemoteMemberFinish, false)
				else
					exports.USGGUI:focus(openDialogs.demoteMember)
				end
			else
				exports.USGmsg:msg("You can not demote yourself.", 255, 0, 0)
			end
		else
			exports.USGmsg:msg("You do not have enough permission to demote this member!", 255, 0, 0)
		end
	else
		exports.USGmsg:msg("You haven't selected a member!", 255, 0, 0)
	end
end

function onDemoteMemberFinish(result)
	if(result) then
		local selected = exports.USGGUI:gridlistGetSelectedItem(groupGUI.members.list)
		if(selected) then
			local membername = exports.USGGUI:gridlistGetItemData(groupGUI.members.list, selected, 1)
			triggerServerEvent("USGcnr_groups.demoteMember", localPlayer, membername)
		else
			exports.USGmsg:msg("You haven't selected a member!", 255, 0, 0)
		end
	end
end

function onDeleteGroup()
	if(groupData.myRank == 6 or #groupData.myGroup.member == 1) then
		if(not isElement(openDialogs.deleteGroup)) then
			openDialogs.deleteGroup = exports.USGGUI:createDialog("Delete the group", 
			"If you are sure that you want to delete "..groupData.myGroup.name..", enter your password below.",
			"password")
			addEventHandler("onUSGGUIDialogFinish", openDialogs.deleteGroup, onDeleteGroupFinish, false)
		else
			exports.USGGUI:focus(openDialogs.deleteGroup)
		end		
	end
end

function onDeleteGroupFinish(result)
	if(result) then
		triggerServerEvent("USGcnr_groups.deleteGroup", localPlayer, result)
	end
end

function onRenameGroup()
	if(groupData.myRank == 6) then
		if(not isElement(openDialogs.renameGroup)) then
			openDialogs.renameGroup = exports.USGGUI:createDialog("Rename the group", 
			"If you are sure that you want to rename "..groupData.myGroup.name..", enter the new name below.",
			"input",nil, NAME_MINIMUM_LENGTH)
			addEventHandler("onUSGGUIDialogFinish", openDialogs.renameGroup, onRenameGroupFinish, false)
		else
			exports.USGGUI:focus(openDialogs.renameGroup)
		end		
	end
end

function onRenameGroupFinish(result)
	if(result) then
		triggerServerEvent("USGcnr_groups.renameGroup", localPlayer, result)
	end
end

local pickingColor = false

function onSetColor()
	if(not pickingColor) then
		exports.USGcolorpicker:openPicker("Select a new colour for your group, this will be used for turfs.")
		addEventHandler("onPickColor", resourceRoot, onGroupColorPicked)
		addEventHandler("onCancelPickColor", resourceRoot, onGroupColorCancel)
		pickingColor = true
	end
end

function onGroupColorPicked(ID, r,g,b,a)
	pickingColor = false
	triggerServerEvent("USGcnr_groups.setColor", localPlayer, r,g,b)
	removeEventHandler("onPickColor", resourceRoot, onGroupColorPicked)
	removeEventHandler("onCancelPickColor", resourceRoot, onGroupColorCancel)	
end

function onGroupColorCancel(ID)
	pickingColor = false
	removeEventHandler("onPickColor", resourceRoot, onGroupColorPicked)
	removeEventHandler("onCancelPickColor", resourceRoot, onGroupColorCancel)
end

local loadedRank = false

function onClickRankSelector(btn,state)
	if(btn == 1 and state == "up") then
		local selection,_ = exports.USGGUI:getSliderSelectedOption(groupGUI.management.customRankSelector)
		local rank = selection+6 -- custom ranks start at 7
		if(not loadedRank or rank ~= loadedRank) then
			selectCustomRank(rank) 
		end
	end
end

function selectCustomRank(rank)
	if(groupData.myGroup.ranks[rank]) then
		if(loadedRank) then
			groupData.myGroup.ranks[loadedRank].rankorder, _ = exports.USGGUI:getSliderSelectedOption(groupGUI.management.customRankOrder, false)
			groupData.myGroup.ranks[loadedRank].rankname = exports.USGGUI:getText(groupGUI.management.customRankName)
		end	
		exports.USGGUI:setText(groupGUI.management.customRankName, groupData.myGroup.ranks[rank].rankname)
		exports.USGGUI:setSliderSelectedOption(groupGUI.management.customRankOrder, groupData.myGroup.ranks[rank].rankorder or 1, false)
		exports.USGGUI:gridlistClear(groupGUI.management.customRankPermissions)
		for i, permission in ipairs(groupData.myGroup.ranks[rank].permissions) do
			local row = exports.USGGUI:gridlistAddRow(groupGUI.management.customRankPermissions)
			exports.USGGUI:gridlistSetItemText(groupGUI.management.customRankPermissions, row, 1, permissions[permission] or "Unknown")
			exports.USGGUI:gridlistSetItemData(groupGUI.management.customRankPermissions, row, 1, permission)
		end
		loadedRank = rank
	end
end

local addCustomRankPermissionGUI = {}

function addCustomRankPermission()
	if(groupData.myPermissions.customRanks) then
		if(not isElement(openDialogs.addCustomRankPermission)) then
			openDialogs.addCustomRankPermission = exports.USGGUI:createWindow("center", "center", 250,350,false,"Add permission")
			addCustomRankPermissionGUI.window = openDialogs.addCustomRankPermission
			addCustomRankPermissionGUI.permissionGrid = exports.USGGUI:createGridList("center", 5,240,300,false,addCustomRankPermissionGUI.window)
			exports.USGGUI:gridlistAddColumn(addCustomRankPermissionGUI.permissionGrid, "Permission", 1)
			addCustomRankPermissionGUI.OK = exports.USGGUI:createButton(160, 315,70,30,false,"OK",addCustomRankPermissionGUI.window)
				addEventHandler("onUSGGUISClick", addCustomRankPermissionGUI.OK, onAddCustomRankPermissionOK, false)
			addCustomRankPermissionGUI.cancel = exports.USGGUI:createButton(5, 315,70,30,false,"Cancel",addCustomRankPermissionGUI.window)
				addEventHandler("onUSGGUISClick", addCustomRankPermissionGUI.cancel, onAddCustomRankPermissionCancel, false)
			local addedPermissions = {}
			for _, permission in ipairs(groupData.myGroup.ranks[loadedRank].permissions) do
				addedPermissions[permission] = true
			end
			for permission, desc in pairs(permissions) do
				if(not addedPermissions[permission]) then
					local row = exports.USGGUI:gridlistAddRow(addCustomRankPermissionGUI.permissionGrid)
					exports.USGGUI:gridlistSetItemText(addCustomRankPermissionGUI.permissionGrid, row, 1, desc)
					exports.USGGUI:gridlistSetItemData(addCustomRankPermissionGUI.permissionGrid, row, 1, permission)
				end
			end
		end
		exports.USGGUI:focus(openDialogs.addCustomRankPermission)
	else
		exports.USGmsg:msg("You do not have permission to edit custom ranks!", 255,0,0)
	end
end

function onAddCustomRankPermissionOK()
	local selected = exports.USGGUI:gridlistGetSelectedItem(addCustomRankPermissionGUI.permissionGrid)
	if(selected) then
		local permission = exports.USGGUI:gridlistGetItemData(addCustomRankPermissionGUI.permissionGrid, selected, 1)
		table.insert(groupData.myGroup.ranks[loadedRank].permissions, permission)
		local row = exports.USGGUI:gridlistAddRow(groupGUI.management.customRankPermissions)
		exports.USGGUI:gridlistSetItemText(groupGUI.management.customRankPermissions, row, 1, permissions[permission] or "Unknown")
		exports.USGGUI:gridlistSetItemData(groupGUI.management.customRankPermissions, row, 1, permission)
		destroyElement(openDialogs.addCustomRankPermission)
		addCustomRankPermissionGUI = {}
	end
end

function onAddCustomRankPermissionCancel()
	destroyElement(openDialogs.addCustomRankPermission)
	addCustomRankPermissionGUI = {}
end

function removeCustomRankPermission()
	local selected = exports.USGGUI:gridlistGetSelectedItem(groupGUI.management.customRankPermissions)
	if(selected) then
		local permission = exports.USGGUI:gridlistGetItemData(groupGUI.management.customRankPermissions, selected, 1)
		for i, perm in ipairs(groupData.myGroup.ranks[loadedRank].permissions) do
			if(perm == permission) then
				table.remove(groupData.myGroup.ranks[loadedRank].permissions,i)
			end
		end
		exports.USGGUI:gridlistRemoveRow(groupGUI.management.customRankPermissions,selected)
	end
end

function onUpdateCustomRanks()
	if(groupData.myPermissions.customRanks) then
		triggerServerEvent("USGcnr_groups.updateCustomRanks", localPlayer, groupData.myGroup.ranks)
	end
end

function onCreateAlliance()
	if(groupData.myRank == 6) then
		local allianceName = exports.USGGUI:getText(groupGUI.alliance.createAllianceName)
		if(#allianceName:gsub(" ","") == 0) then
			exports.USGmsg:msg("You need to specify a name!", 255,0,0)
			return false
		end
		triggerServerEvent("USGcnr_groups.createAlliance", localPlayer, allianceName)
	else
		exports.USGmsg:msg("Only group founders can create alliances.", 255,0,0)
		return false
	end
end

function onUpdateAllianceInfo()
	if(groupData.myAlliance and groupData.myAlliance.isFounder) then	
		local info = exports.USGGUI:getText(groupGUI.alliance.allianceinfo)
		if(info ~= groupData.myAlliance.info) then
			triggerServerEvent("USGcnr_groups.setAllianceInfo", localPlayer, info)
		else
			exports.USGmsg:msg(client,"You didn't change the info.", 255, 0, 0)
		end
	end
end

function onDeleteAlliance()
	if(groupData.myAlliance and groupData.myAlliance.isFounder) then
		if(isElement(openDialogs.deleteAlliance)) then
			exports.USGGUI:focus(openDialogs.deleteAlliance)
		else
			openDialogs.deleteAlliance = exports.USGGUI:createDialog("Delete alliance", "Confirm that you are sure that you want to delete the alliance.","confirm")
			addEventHandler("onUSGGUIDialogFinish", openDialogs.deleteAlliance, onDeleteAllianceFinish)
		end
	else
		exports.USGmsg:msg("Only group founders can create alliances.", 255,0,0)
		return false
	end
end

function onDeleteAllianceFinish(result)
	if(result) then
		triggerServerEvent("USGcnr_groups.deleteAlliance", localPlayer)
	end
end

function onRenameAlliance()
	if(groupData.myAlliance and groupData.myAlliance.isFounder) then
		if(isElement(openDialogs.renameAlliance)) then
			exports.USGGUI:focus(openDialogs.renameAlliance)
		else
			openDialogs.renameAlliance = exports.USGGUI:createDialog("Rename alliance", "Enter the new name for the alliance.","input", nil, NAME_MINIMUM_LENGTH)
			addEventHandler("onUSGGUIDialogFinish", openDialogs.renameAlliance, onRenameAllianceFinish)
		end
	else
		exports.USGmsg:msg("Only group founders can create alliances.", 255,0,0)
		return false
	end
end

function onRenameAllianceFinish(name)
	if(name) then
		triggerServerEvent("USGcnr_groups.renameAlliance", localPlayer, name)
	end
end

function onSetAllianceColor()
	if(groupData.myAlliance and groupData.myAlliance.isFounder) then	
		if(not pickingColor) then
			exports.USGcolorpicker:openPicker("Select a new colour for your alliance, this will be used for turfs.")
			addEventHandler("onPickColor", resourceRoot, onAllianceColorPicked)
			addEventHandler("onCancelPickColor", resourceRoot, onAllianceColorCancel)
			pickingColor = true
		end
	else
		exports.USGmsg:msg("You do not have permission to change the alliance color!", 255,0,0)
	end
end

function onAllianceColorPicked(ID, r,g,b,a)
	pickingColor = false
	triggerServerEvent("USGcnr_groups.setAllianceColor", localPlayer, r,g,b)
	removeEventHandler("onPickColor", resourceRoot, onAllianceColorPicked)
	removeEventHandler("onCancelPickColor", resourceRoot, onAllianceColorCancel)	
end

function onAllianceColorCancel(ID)
	pickingColor = false
	removeEventHandler("onPickColor", resourceRoot, onGroupColorPicked)
	removeEventHandler("onCancelPickColor", resourceRoot, onAllianceColorCancel)
end

function onKickGroupFromAlliance()
	if(groupData.myAlliance and groupData.myAlliance.isFounder) then
		local selected = exports.USGGUI:gridlistGetSelectedItem(groupGUI.alliancemanagement.groups)
		if(selected) then
			local group = exports.USGGUI:gridlistGetItemData(groupGUI.alliancemanagement.groups, selected, 1)
			triggerServerEvent("USGcnr_groups.allianceKickGroup", localPlayer, group)
		end
	else
		exports.USGmsg:msg("You do not have permission to kick groups!", 255,0,0)
	end	
end

function onRemoveGroupInviteFromAlliance()
	if(groupData.myAlliance and groupData.myAlliance.isFounder) then
		local selected = exports.USGGUI:gridlistGetSelectedItem(groupGUI.alliancemanagement.invites)
		if(selected) then
			local inviteid = exports.USGGUI:gridlistGetItemData(groupGUI.alliancemanagement.invites, selected, 1)
			triggerServerEvent("USGcnr_groups.allianceRemoveInvite", localPlayer, inviteid)
		end
	else
		exports.USGmsg:msg("You do not have permission to remove invites!", 255,0,0)
	end	
end

function onAllianceInviteGroup()
	if(groupData.myAlliance and groupData.myAlliance.isFounder) then
		triggerServerEvent("USGcnr_groups.requestGroupList", localPlayer)
	else
		exports.USGmsg:msg("You do not have permission to invite groups!", 255,0,0)
	end
end

addEvent("USGcnr_groups.recieveGroupList", true)
function onAllianceGroupListRecieved(groups)
	if(not isElement(openDialogs.allianceInviteGroup)) then
		local groupList = {}
		for i, group in ipairs(groups) do
			if(group.id ~= groupData.myGroup.id) then
				groupList[group.id] = group.groupname
			end
		end
		openDialogs.allianceInviteGroup = exports.USGGUI:createDialog("Invite a group","Select the group to invite","select", groupList, true)
		addEventHandler("onUSGGUIDialogFinish", openDialogs.allianceInviteGroup, onInviteGroupFinish, false)
	else
		exports.USGGUI:focus(openDialogs.allianceInviteGroup)
	end
end
addEventHandler("USGcnr_groups.recieveGroupList", localPlayer, onAllianceGroupListRecieved)

function onInviteGroupFinish(group)
	if(group) then
		triggerServerEvent("USGcnr_groups.allianceInviteGroup", localPlayer, group)
	end
end

function onAcceptAllianceInvite()
	local selected = exports.USGGUI:gridlistGetSelectedItem(groupGUI.alliance.myInvites)
	if(selected) then
		local allianceid = exports.USGGUI:gridlistGetItemData(groupGUI.alliance.myInvites, selected, 1)
		if(allianceid) then
			triggerServerEvent("USGcnr_groups.acceptAllianceInvite", localPlayer, allianceid)
		end
	end
end

function onRejectAllianceInvite()
	local selected = exports.USGGUI:gridlistGetSelectedItem(groupGUI.alliance.myInvites)
	if(selected) then
		local allianceid = exports.USGGUI:gridlistGetItemData(groupGUI.alliance.myInvites, selected, 1)
		if(allianceid) then
			triggerServerEvent("USGcnr_groups.rejectAllianceInvite", localPlayer, allianceid)
		end
	end
end

function onLeaveAlliance()
	if(groupData.myAlliance and groupData.myRank == 6) then
		if(not isElement(openDialogs.leaveAlliance)) then
			openDialogs.leaveAlliance = exports.USGGUI:createDialog("Leave alliance", 
				"Are you sure that you want to leave the alliance "..groupData.myAlliance.alliancename.."?","confirm")
			addEventHandler("onUSGGUIDialogFinish", openDialogs.leaveAlliance, onLeaveAllianceFinish, false)
		else
			exports.USGGUI:focus(openDialogs.leaveAlliance)
		end
	end
end

function onLeaveAllianceFinish(result)
	if(result) then
		triggerServerEvent("USGcnr_groups.leaveAlliance", localPlayer)
	end
end