openDialogs = {}
groupGUI = {}
groupData = { myGroup = {} }

function toggleGroupGUI()
	if(exports.USGrooms:getPlayerRoom() ~= "cnr") then return false end
	if(not isElement(groupGUI.window)) then
		exports.USGGUI:setDefaultTextAlignment('left','center')
		groupGUI.window = exports.USGGUI:createWindow('center','center',600,450,false, "Groups")
		groupGUI.tabpanel = exports.USGGUI:createTabPanel('center',0,590,400,false,groupGUI.window)
		groupGUI.close = exports.USGGUI:createButton(500,410,70,30,false,"Close",groupGUI.window)
			addEventHandler("onUSGGUISClick",groupGUI.close, toggleGroupGUI, false)
		groupGUI.general = {}
		groupGUI.general.tab = exports.USGGUI:addTab(groupGUI.tabpanel, "General")		
		-- when in group
		groupGUI.general.inGroupPanel = exports.USGGUI:createLabel(0,0,590,400,false,"",groupGUI.general.tab)
		groupGUI.general.group = exports.USGGUI:createLabel(5,0,590,20,false,"Current group: none", groupGUI.general.inGroupPanel)
		groupGUI.general.alliance = exports.USGGUI:createLabel(5,20,590,20,false,"Current group's alliance: none", groupGUI.general.inGroupPanel)
		groupGUI.general.groupcount = exports.USGGUI:createLabel(5,40,590,20,false,"Current group's member count: 0", groupGUI.general.inGroupPanel)
		groupGUI.general.groupfounder = exports.USGGUI:createLabel(5,60,590,20,false,"Group founder: none", groupGUI.general.inGroupPanel)
		exports.USGGUI:createLabel(5,80,80,20,false,"Group color: ",groupGUI.general.inGroupPanel)
		groupGUI.general.groupcolor = exports.USGGUI:createButton(200,80,250,20,false,"",groupGUI.general.inGroupPanel,tocolor(0,0,0,0))
		groupGUI.general.leaveGroup = exports.USGGUI:createButton(490,105, 90, 20,false,"Leave group",groupGUI.general.inGroupPanel)
			addEventHandler("onUSGGUISClick",groupGUI.general.leaveGroup, onLeaveGroup, false)
		groupGUI.general.updateInfo = exports.USGGUI:createButton(5,105, 90, 20,false,"Update info",groupGUI.general.inGroupPanel)
			addEventHandler("onUSGGUISClick",groupGUI.general.updateInfo, onUpdateInfo, false)
		exports.USGGUI:setEnabled(groupGUI.general.updateInfo, false)
		groupGUI.general.groupinfo = exports.USGGUI:createMemo(5,140,580,235,false,"group info",groupGUI.general.inGroupPanel)
		exports.USGGUI:setProperty(groupGUI.general.groupinfo,"readOnly",true)
		-- when not in group
		groupGUI.general.grouplessPanel = exports.USGGUI:createLabel(0,0,590,400,false,"",groupGUI.general.tab)
		groupGUI.general.createGroupName = exports.USGGUI:createEditBox(5,5,480,30,false,"",groupGUI.general.grouplessPanel)
		groupGUI.general.createGroup = exports.USGGUI:createButton(490,5,90,30,false,"Create group",groupGUI.general.grouplessPanel)
			addEventHandler("onUSGGUISClick",groupGUI.general.createGroup, onCreateGroup, false)
		groupGUI.general.myInvites = exports.USGGUI:createGridList(5,130,580,200,false,groupGUI.general.grouplessPanel)
		exports.USGGUI:gridlistAddColumn(groupGUI.general.myInvites, "Group",0.7)
		exports.USGGUI:gridlistAddColumn(groupGUI.general.myInvites, "Invited by",0.3)
		groupGUI.general.acceptInvite = exports.USGGUI:createButton(120, 90, 90, 30, false, "Accept invite", groupGUI.general.grouplessPanel)
			addEventHandler("onUSGGUISClick",groupGUI.general.acceptInvite, onAcceptInvite, false)
		groupGUI.general.rejectInvite = exports.USGGUI:createButton(5, 90, 90, 30, false, "Reject invite", groupGUI.general.grouplessPanel)
			addEventHandler("onUSGGUISClick",groupGUI.general.rejectInvite, onRejectInvite, false)
		groupGUI.members = {}
		groupGUI.members.tab = exports.USGGUI:addTab(groupGUI.tabpanel, "Members")
		groupGUI.members.list = exports.USGGUI:createGridList(5,5,425,360,false,groupGUI.members.tab)
		groupGUI.members.listAccountColumn = exports.USGGUI:gridlistAddColumn(groupGUI.members.list,"Account",0.25)
		groupGUI.members.listNameColumn = exports.USGGUI:gridlistAddColumn(groupGUI.members.list,"Name",0.25)
		groupGUI.members.listRankColumn = exports.USGGUI:gridlistAddColumn(groupGUI.members.list,"Rank",0.15)
		groupGUI.members.listLastSeenColumn = exports.USGGUI:gridlistAddColumn(groupGUI.members.list,"Last seen",0.35)
		groupGUI.members.kick = exports.USGGUI:createButton(460,5,90,30,false,"Kick",groupGUI.members.tab)
			addEventHandler("onUSGGUISClick",groupGUI.members.kick, onKickMember, false)
		groupGUI.members.promote = exports.USGGUI:createButton(460,40,90,30,false,"Promote",groupGUI.members.tab)
			addEventHandler("onUSGGUISClick",groupGUI.members.promote, onPromoteMember, false)
		groupGUI.members.demote = exports.USGGUI:createButton(460,75,90,30,false,"Demote",groupGUI.members.tab)
			addEventHandler("onUSGGUISClick",groupGUI.members.demote, onDemoteMember, false)
		groupGUI.members.invites = exports.USGGUI:createButton(450,285,110,30,false,"Invites",groupGUI.members.tab)
			addEventHandler("onUSGGUISClick",groupGUI.members.invites, onOpenInvites, false)
		groupGUI.members.invite = exports.USGGUI:createButton(450,320,110,30,false,"Invite a member",groupGUI.members.tab)
			addEventHandler("onUSGGUISClick",groupGUI.members.invite, onInvitePlayer, false)
		groupGUI.management = {}
		groupGUI.management.tab = exports.USGGUI:addTab(groupGUI.tabpanel, "Management")
		groupGUI.management.delete = exports.USGGUI:createButton(50,5,90,30,false,"Delete group",groupGUI.management.tab)
			addEventHandler("onUSGGUISClick",groupGUI.management.delete, onDeleteGroup, false)
		groupGUI.management.rename = exports.USGGUI:createButton(245,5,90,30,false,"Rename group",groupGUI.management.tab)
			addEventHandler("onUSGGUISClick",groupGUI.management.rename, onRenameGroup, false)
		groupGUI.management.setColor = exports.USGGUI:createButton(460,5,110,30,false,"Set group color",groupGUI.management.tab)
			addEventHandler("onUSGGUISClick",groupGUI.management.setColor, onSetColor, false)
		exports.USGGUI:createLabel(50,45,80,40,false,"Custom rank: ",groupGUI.management.tab)
		groupGUI.management.customRankSelector = exports.USGGUI:createSlider(140,45,200,40,false,groupGUI.management.tab, nil, {1,2},false)
			addEventHandler("onUSGGUIClick",groupGUI.management.customRankSelector, onClickRankSelector, false)
		exports.USGGUI:createLabel(50,95,80,25,false,"Rank name: ",groupGUI.management.tab)
		groupGUI.management.customRankName = exports.USGGUI:createEditBox(145,95,200,25,false, "",groupGUI.management.tab)
		exports.USGGUI:createLabel(50,145,80,20,false,"Rank order: ",groupGUI.management.tab)
		groupGUI.management.customRankOrder = exports.USGGUI:createSlider(145,145,300,30,false, groupGUI.management.tab, nil, {1,2,3,4,5,6},false)
		groupGUI.management.customRankPermissions = exports.USGGUI:createGridList(50,195,350,150,false,groupGUI.management.tab)
		exports.USGGUI:gridlistAddColumn(groupGUI.management.customRankPermissions, "Permissions",1)
		groupGUI.management.customRankAddPermission = exports.USGGUI:createButton( 420, 195, 120, 30, false, "Add permission", groupGUI.management.tab)
			addEventHandler("onUSGGUISClick",groupGUI.management.customRankAddPermission, addCustomRankPermission, false)
		groupGUI.management.customRankRemovePermission = exports.USGGUI:createButton( 420, 245, 120, 30, false, "Remove permission", groupGUI.management.tab)
			addEventHandler("onUSGGUISClick",groupGUI.management.customRankRemovePermission, removeCustomRankPermission, false)
		groupGUI.management.customRankUpdate = exports.USGGUI:createButton( 420, 315, 120, 30, false, "Update ranks", groupGUI.management.tab)
			addEventHandler("onUSGGUISClick",groupGUI.management.customRankUpdate, onUpdateCustomRanks, false)
		groupGUI.alliance = {}
		groupGUI.alliance.tab = exports.USGGUI:addTab(groupGUI.tabpanel, "Alliance")
		-- when in alliance
		groupGUI.alliance.inAlliancePanel = exports.USGGUI:createLabel(0,0,590,400,false,"",groupGUI.alliance.tab)
		groupGUI.alliance.alliance = exports.USGGUI:createLabel(5,0,590,20,false,"Current group's alliance: none", groupGUI.alliance.inAlliancePanel)
		groupGUI.alliance.groupcount = exports.USGGUI:createLabel(5,20,590,20,false,"Current alliance's group count: 0", groupGUI.alliance.inAlliancePanel)
		groupGUI.alliance.alliancefounder = exports.USGGUI:createLabel(5,40,590,20,false,"Alliance founder group: none", groupGUI.alliance.inAlliancePanel)
		exports.USGGUI:createLabel(5,60,80,20,false,"Alliance color: ",groupGUI.alliance.inAlliancePanel)
		groupGUI.alliance.alliancecolor = exports.USGGUI:createButton(200,60,250,20,false,"",groupGUI.alliance.inAlliancePanel,tocolor(0,0,0,0))
		groupGUI.alliance.updateInfo = exports.USGGUI:createButton(5,105, 90, 25,false,"Update info",groupGUI.alliance.inAlliancePanel)
			addEventHandler("onUSGGUISClick",groupGUI.alliance.updateInfo, onUpdateAllianceInfo, false)
		exports.USGGUI:setEnabled(groupGUI.alliance.updateInfo, false)
		groupGUI.alliance.allianceinfo = exports.USGGUI:createMemo(5,140,580,240,false,"alliance info",groupGUI.alliance.inAlliancePanel)
		exports.USGGUI:setProperty(groupGUI.alliance.allianceinfo,"readOnly",true)
		groupGUI.alliance.leaveAlliance = exports.USGGUI:createButton(495,105,90,25,false,"Leave alliance",groupGUI.alliance.inAlliancePanel)
			addEventHandler("onUSGGUISClick",groupGUI.alliance.leaveAlliance, onLeaveAlliance, false)
		-- when not in alliance
		groupGUI.alliance.noAlliancePanel = exports.USGGUI:createLabel(0,0,590,400,false,"",groupGUI.alliance.tab)
		groupGUI.alliance.createAllianceName = exports.USGGUI:createEditBox(5,5,465,30,false,"",groupGUI.alliance.noAlliancePanel)
		groupGUI.alliance.createAlliance = exports.USGGUI:createButton(480,5,100,30,false,"Create alliance",groupGUI.alliance.noAlliancePanel)
			addEventHandler("onUSGGUISClick",groupGUI.alliance.createAlliance, onCreateAlliance, false)	
		groupGUI.alliance.myInvites = exports.USGGUI:createGridList(5,130,580,200,false,groupGUI.alliance.noAlliancePanel)
		exports.USGGUI:gridlistAddColumn(groupGUI.alliance.myInvites, "Alliance",0.7)
		exports.USGGUI:gridlistAddColumn(groupGUI.alliance.myInvites, "Invited by",0.3)
		groupGUI.alliance.acceptInvite = exports.USGGUI:createButton(120, 90, 90, 30, false, "Accept invite", groupGUI.alliance.noAlliancePanel)
			addEventHandler("onUSGGUISClick",groupGUI.alliance.acceptInvite, onAcceptAllianceInvite, false)
		groupGUI.alliance.rejectInvite = exports.USGGUI:createButton(5, 90, 90, 30, false, "Reject invite", groupGUI.alliance.noAlliancePanel)
			addEventHandler("onUSGGUISClick",groupGUI.alliance.rejectInvite, onRejectAllianceInvite, false)		
		exports.USGGUI:setVisible(groupGUI.alliance.noAlliancePanel, true)
		exports.USGGUI:setVisible(groupGUI.alliance.inAlliancePanel, false)	
		-- alliance management
		groupGUI.alliancemanagement = {}
		groupGUI.alliancemanagement.tab = exports.USGGUI:addTab(groupGUI.tabpanel, "Alliance management")		
		groupGUI.alliancemanagement.delete = exports.USGGUI:createButton(50,5,90,30,false,"Delete alliance",groupGUI.alliancemanagement.tab)
			addEventHandler("onUSGGUISClick",groupGUI.alliancemanagement.delete, onDeleteAlliance, false)
		groupGUI.alliancemanagement.rename = exports.USGGUI:createButton(245,5,90,30,false,"Rename alliance",groupGUI.alliancemanagement.tab)
			addEventHandler("onUSGGUISClick",groupGUI.alliancemanagement.rename, onRenameAlliance, false)
		groupGUI.alliancemanagement.setColor = exports.USGGUI:createButton(455,5,120,30,false,"Set alliance color",groupGUI.alliancemanagement.tab)
			addEventHandler("onUSGGUISClick",groupGUI.alliancemanagement.setColor, onSetAllianceColor, false)
		groupGUI.alliancemanagement.groups = exports.USGGUI:createGridList(50,40, 400, 195,false,groupGUI.alliancemanagement.tab)
		exports.USGGUI:gridlistAddColumn(groupGUI.alliancemanagement.groups, "Group",1.0)
		groupGUI.alliancemanagement.kick = exports.USGGUI:createButton(460,62,70,30,false,"Kick",groupGUI.alliancemanagement.tab)
			addEventHandler("onUSGGUISClick",groupGUI.alliancemanagement.kick, onKickGroupFromAlliance, false)
		groupGUI.alliancemanagement.invites = exports.USGGUI:createGridList(50,240,400,130,false,groupGUI.alliancemanagement.tab)
		exports.USGGUI:gridlistAddColumn(groupGUI.alliancemanagement.invites, "Group",1.0)
		groupGUI.alliancemanagement.removeInvite = exports.USGGUI:createButton(460,262,70,30,false,"Remove",groupGUI.alliancemanagement.tab)
			addEventHandler("onUSGGUISClick",groupGUI.alliancemanagement.removeInvite, onRemoveGroupInviteFromAlliance, false)
		groupGUI.alliancemanagement.invite = exports.USGGUI:createButton(460,297,70,30,false,"Invite new",groupGUI.alliancemanagement.tab)
			addEventHandler("onUSGGUISClick",groupGUI.alliancemanagement.invite, onAllianceInviteGroup, false)	
		showCursor(true)
		triggerServerEvent("USGcnr_groups.requestGroupData", localPlayer)
		if(groupData.myPermissions) then loadACL() end
	else
		if(exports.USGGUI:getVisible(groupGUI.window)) then
			-- close main, AND DIALOGS
			showCursor(false)
			exports.USGGUI:setVisible(groupGUI.window,false)
			for dialogname, dialog in pairs(openDialogs) do
				if(isElement(dialog)) then
					destroyElement(dialog)
				end
			end
			openDialogs = {}
		else
			showCursor(true)
			exports.USGGUI:setVisible(groupGUI.window,true)
			triggerServerEvent("USGcnr_groups.requestGroupData", localPlayer)
		end
	end
end
addCommandHandler("groups", toggleGroupGUI)
bindKey("F6", "down", toggleGroupGUI)

addEventHandler("onPlayerExitRoom", localPlayer,
	function (prevRoom)
		if(prevRoom == "cnr" and isElement(groupGUI.window)) then
			if(exports.USGGUI:getVisible(groupGUI.window)) then
				showCursor(false)
			end
			for dialogname, dialog in pairs(openDialogs) do
				if(isElement(dialog)) then
					destroyElement(dialog)
				end
			end	
			destroyElement(groupGUI.window)
			groupGUI = {}
			openDialogs = {}
			groupData = {}
		end
	end
)

addEvent("USGcnr_groups.recieveGroupData", true)
function setGroupData(data) -- resets all values and if available, assigns new values.
	if(data) then
		groupData = data
		if(not isElement(groupGUI.window)) then return end -- no need to update gui
		-- general
		exports.USGGUI:setText(groupGUI.general.group, "Current group: " .. ( data.myGroup.name or "none" ))
		exports.USGGUI:setText(groupGUI.general.alliance, "Current group's alliance: " .. ( data.myAlliance and data.myAlliance.alliancename or "none" ))
		exports.USGGUI:setText(groupGUI.general.groupcount, "Current group's member count: " .. ( #(data.myGroup.members or {}) or "0" ))
		exports.USGGUI:setText(groupGUI.general.groupfounder, "Group founder: " .. ( data.myGroup.founder or "none" ))
		exports.USGGUI:setProperty(groupGUI.general.groupcolor, "color", tocolor(unpack(data.myGroup.color or {0,0,0,0,})))
		exports.USGGUI:setText(groupGUI.general.groupinfo, data.myGroup.info or "")
		-- members
		exports.USGGUI:gridlistClear(groupGUI.members.list)
		if(data.myGroup.members) then
			for _, member in ipairs(data.myGroup.members) do
				local row = exports.USGGUI:gridlistAddRow(groupGUI.members.list)
				if(exports.USGaccounts:getPlayerFromAccount(member.membername)) then
					exports.USGGUI:gridlistSetItemColor(groupGUI.members.list, row, false,
						 tocolor(0,255,0))
				end				
				exports.USGGUI:gridlistSetItemText(groupGUI.members.list, row, 1, member.membername)
				exports.USGGUI:gridlistSetItemData(groupGUI.members.list, row, 1, member.membername)
				exports.USGGUI:gridlistSetItemText(groupGUI.members.list, row ,2, member.nick or "N/A")
				exports.USGGUI:gridlistSetItemText(groupGUI.members.list, row, 3, tostring(member.rank))
				exports.USGGUI:gridlistSetItemData(groupGUI.members.list, row, 3, member.rank)
				exports.USGGUI:gridlistSetItemText(groupGUI.members.list, row, 4, member.lastseen or "N/A")
				local sortOrder = getDateSortOrder(member.lastseen)
				exports.USGGUI:gridlistSetItemSortIndex(groupGUI.members.list, row, 4, sortOrder or 0)				
			end
		end
		exports.USGGUI:gridlistClear(groupGUI.general.myInvites)
		if(data.invites) then
			for _, invite in ipairs(data.invites) do
				local row = exports.USGGUI:gridlistAddRow(groupGUI.general.myInvites)
				exports.USGGUI:gridlistSetItemText(groupGUI.general.myInvites, row, 1, invite.groupname)
				exports.USGGUI:gridlistSetItemText(groupGUI.general.myInvites, row ,2, invite.invitedby)
				exports.USGGUI:gridlistSetItemData(groupGUI.general.myInvites, row, 1, invite.inviteid)
			end
		end		
		if(data.myGroup.id) then
			exports.USGGUI:setVisible(groupGUI.general.grouplessPanel, false)
			exports.USGGUI:setVisible(groupGUI.general.inGroupPanel, true)
			exports.USGGUI:setEnabled(groupGUI.members.tab, true)
			exports.USGGUI:setEnabled(groupGUI.management.tab, true)
		else
			exports.USGGUI:setVisible(groupGUI.general.grouplessPanel, true)
			exports.USGGUI:setVisible(groupGUI.general.inGroupPanel, false)
			exports.USGGUI:setEnabled(groupGUI.members.tab, false)
			exports.USGGUI:setEnabled(
			groupGUI.management.tab, false)
		end
		-- alliances
		exports.USGGUI:setText(groupGUI.alliance.alliance, "Current group's alliance: "..(data.myAlliance and data.myAlliance.alliancename or "none"))
		exports.USGGUI:setText(groupGUI.alliance.groupcount, "Current alliance's group count: "..(data.myAlliance and #data.myAlliance.groups or ""))
		exports.USGGUI:setText(groupGUI.alliance.alliancefounder, "Alliance founder group: "..(data.myAlliance and data.myAlliance.founder or ""))
		exports.USGGUI:setProperty(groupGUI.alliance.alliancecolor, "color", tocolor(unpack(data.myAlliance and data.myAlliance.color or {0,0,0,0})))
		exports.USGGUI:setText(groupGUI.alliance.allianceinfo, data.myAlliance and (data.myAlliance.info or "") or "")
		exports.USGGUI:gridlistClear(groupGUI.alliance.myInvites)
		exports.USGGUI:gridlistClear(groupGUI.alliancemanagement.groups)
		exports.USGGUI:gridlistClear(groupGUI.alliancemanagement.invites)
		if(data.myAlliance) then
			if(data.myAlliance.invites) then
				if(groupData.myAlliance.isFounder or data.myAlliance.isFounder) then
					for _, invite in ipairs(data.myAlliance.invites) do
						local row = exports.USGGUI:gridlistAddRow(groupGUI.alliancemanagement.invites)
						exports.USGGUI:gridlistSetItemText(groupGUI.alliancemanagement.invites, row, 1, invite.groupname)
						exports.USGGUI:gridlistSetItemData(groupGUI.alliancemanagement.invites, row, 1, invite.groupid)
					end
				end
			end
			if(data.myAlliance.groups) then
				if(groupData.myAlliance.isFounder or data.myAlliance.isFounder) then
					for _, groups in ipairs(data.myAlliance.groups) do
						local row = exports.USGGUI:gridlistAddRow(groupGUI.alliancemanagement.groups)
						exports.USGGUI:gridlistSetItemText(groupGUI.alliancemanagement.groups, row, 1, groups.groupname)
						exports.USGGUI:gridlistSetItemData(groupGUI.alliancemanagement.groups, row, 1, groups.groupid)
					end
				end
			end
			exports.USGGUI:setVisible(groupGUI.alliance.noAlliancePanel, false)
			exports.USGGUI:setVisible(groupGUI.alliance.inAlliancePanel, true)
			exports.USGGUI:setEnabled(groupGUI.alliancemanagement.tab, true)
		else
			if(groupData.allianceInvites) then
				for i, invite in ipairs(groupData.allianceInvites) do
					local row = exports.USGGUI:gridlistAddRow(groupGUI.alliance.myInvites)
					exports.USGGUI:gridlistSetItemText(groupGUI.alliance.myInvites, row, 1, invite.alliancename)
					exports.USGGUI:gridlistSetItemData(groupGUI.alliance.myInvites, row, 1, invite.allianceid)
				end
			end
			exports.USGGUI:setVisible(groupGUI.alliance.noAlliancePanel, true)
			exports.USGGUI:setVisible(groupGUI.alliance.inAlliancePanel, false)
			exports.USGGUI:setEnabled(groupGUI.alliancemanagement.tab, false)		
		end
		loadACL()
	end
end
addEventHandler("USGcnr_groups.recieveGroupData", localPlayer, setGroupData)

function updateTable(table,newTable)
	for key, value in pairs(table) do
		if(type(value) == "table") then
			if(not newTable[key]) then newTable[key] = {} end
			updateTable(value,newTable[key])
		elseif(value ~= nil) then -- if value is defined
			newTable[key] = value
		end
	end
end

addEvent("USGcnr_groups.updateGroupData", true)
function updateGroupData(data) -- only sets values if new one is provided
	if(data) then
		if(not groupData) then groupData = {} end
		updateTable(data,groupData)
		if(not isElement(groupGUI.window)) then return end -- no need to update gui
		if(data.myGroup and data.myGroup.name) then
			exports.USGGUI:setText(groupGUI.general.group, "Current group: " .. ( data.myGroup.name or "none" ))
		end
		exports.USGGUI:setText(groupGUI.general.alliance, "Current group's alliance: " .. ( data.myAlliance and data.myAlliance.alliancename or "none" ))
		if(data.myGroup and data.myGroup.members) then
			exports.USGGUI:setText(groupGUI.general.groupcount, "Current group's member count: " .. ( #(data.myGroup.members or {}) or "0" ))
			exports.USGGUI:gridlistClear(groupGUI.members.list)
			for _, member in ipairs(data.myGroup.members) do
				local row = exports.USGGUI:gridlistAddRow(groupGUI.members.list)
				if(exports.USGaccounts:getPlayerFromAccount(member.membername)) then
					exports.USGGUI:gridlistSetItemColor(groupGUI.members.list, row, false, 
						 tocolor(0,255,0))
				end
				exports.USGGUI:gridlistSetItemText(groupGUI.members.list, row, 1, member.membername)
				exports.USGGUI:gridlistSetItemData(groupGUI.members.list, row, 1, member.membername)
				exports.USGGUI:gridlistSetItemText(groupGUI.members.list, row ,2, member.nick or "N/A")
				exports.USGGUI:gridlistSetItemText(groupGUI.members.list, row, 3, tostring(member.rank))
				exports.USGGUI:gridlistSetItemData(groupGUI.members.list, row, 3, member.rank)
				exports.USGGUI:gridlistSetItemText(groupGUI.members.list, row, 4, member.lastseen or "N/A")
				local sortOrder = getDateSortOrder(member.lastseen)
				exports.USGGUI:gridlistSetItemSortIndex(groupGUI.members.list, row, 4, sortOrder or 0)
			end	
		end
		if(data.myGroup and data.myGroup.founder) then
			exports.USGGUI:setText(groupGUI.general.groupfounder, "Group founder: " .. ( data.myGroup.founder or "none" ))
		end
		if(data.myGroup and data.myGroup.color) then
			exports.USGGUI:setProperty(groupGUI.general.groupcolor, "color", tocolor(unpack(data.myGroup.color or {0,0,0,0,})))
		end
		if(data.myGroup and data.myGroup.info) then
			exports.USGGUI:setText(groupGUI.general.groupinfo, data.myGroup.info or "")
		end
		-- members
		if(data.invites) then
			exports.USGGUI:gridlistClear(groupGUI.general.myInvites)
			for _, invite in ipairs(data.invites) do
				local row = exports.USGGUI:gridlistAddRow(groupGUI.general.myInvites)
				exports.USGGUI:gridlistSetItemText(groupGUI.general.myInvites, row, 1, invite.groupname)
				exports.USGGUI:gridlistSetItemText(groupGUI.general.myInvites, row ,2, invite.invitedby)
				exports.USGGUI:gridlistSetItemData(groupGUI.general.myInvites, row, 1, invite.inviteid)
			end
		end
		if(data.myGroup and data.myGroup.id) then
			exports.USGGUI:setVisible(groupGUI.general.grouplessPanel, false)
			exports.USGGUI:setVisible(groupGUI.general.inGroupPanel, true)
		elseif(data.myGroup and data.myGroup.id ~= nil) then
			exports.USGGUI:setVisible(groupGUI.general.grouplessPanel, true)
			exports.USGGUI:setVisible(groupGUI.general.inGroupPanel, false)	
		end
		if(data.myAlliance) then
			if(data.myAlliance.alliancename) then
				exports.USGGUI:setText(groupGUI.alliance.alliance, "Current group's alliance: "..data.myAlliance.alliancename)
			end
			if(data.myAlliance.groups) then
				exports.USGGUI:setText(groupGUI.alliance.groupcount, "Current alliance's group count: "..(#data.myAlliance.groups))
				exports.USGGUI:gridlistClear(groupGUI.alliancemanagement.groups)
				if(groupData.myAlliance.isFounder or data.myAlliance.isFounder) then
					for _, group in ipairs(data.myAlliance.groups) do
						local row = exports.USGGUI:gridlistAddRow(groupGUI.alliancemanagement.groups)
						exports.USGGUI:gridlistSetItemText(groupGUI.alliancemanagement.groups, row, 1, group.groupname)
						exports.USGGUI:gridlistSetItemData(groupGUI.alliancemanagement.groups, row, 1, group.groupid)
					end
				end
			end
			if(data.myAlliance.invites ~= nil) then
				exports.USGGUI:gridlistClear(groupGUI.alliancemanagement.invites)
				if(data.myAlliance.invites and (groupData.myAlliance.isFounder or data.myAlliance.isFounder)) then
					for _, invite in ipairs(data.myAlliance.invites) do
						local row = exports.USGGUI:gridlistAddRow(groupGUI.alliancemanagement.invites)
						exports.USGGUI:gridlistSetItemText(groupGUI.alliancemanagement.invites, row, 1, invite.groupname)
						exports.USGGUI:gridlistSetItemData(groupGUI.alliancemanagement.invites, row, 1, invite.groupid)
					end
				end
			end			
			if(data.myAlliance.founder) then
				exports.USGGUI:setText(groupGUI.alliance.alliancefounder, "Alliance founder group: "..data.myAlliance.founder)
			end
			if(data.myAlliance.info) then
				exports.USGGUI:setText(groupGUI.alliance.allianceinfo, data.myAlliance and (data.myAlliance.info or "") or "")			
			end
			if(data.myAlliance.color) then
				exports.USGGUI:setProperty(groupGUI.alliance.alliancecolor, "color", tocolor(unpack(data.myAlliance.color or {0,0,0,0})))
			end	
			exports.USGGUI:setVisible(groupGUI.alliance.noAlliancePanel, false)
			exports.USGGUI:setVisible(groupGUI.alliance.inAlliancePanel, true)
			exports.USGGUI:setEnabled(groupGUI.alliancemanagement.tab, true)
		elseif(data.myAlliance ~= nil) then
			exports.USGGUI:gridlistClear(groupGUI.alliancemanagement.invites)
			exports.USGGUI:gridlistClear(groupGUI.alliancemanagement.groups)
			exports.USGGUI:setText(groupGUI.alliance.alliance, "Current group's alliance: none")
			exports.USGGUI:setText(groupGUI.alliance.groupcount, "Current alliance's group count:")
			exports.USGGUI:setText(groupGUI.alliance.alliancefounder, "Alliance founder group:")
			exports.USGGUI:setProperty(groupGUI.alliance.alliancecolor, "color", tocolor({0,0,0,0}))
			exports.USGGUI:setText(groupGUI.alliance.allianceinfo, "")			
			exports.USGGUI:setVisible(groupGUI.alliance.noAlliancePanel, true)
			exports.USGGUI:setVisible(groupGUI.alliance.inAlliancePanel, false)
			exports.USGGUI:setEnabled(groupGUI.alliancemanagement.tab, false)		
		end
		if(data.allianceInvites ~= nil) then
			exports.USGUI:gridlistClear(groupGUI.alliance.myInvites)
			if(data.allianceInvites) then
				for i, invite in ipairs(groupData.allianceInvites) do
					local row = exports.USGGUI:gridlistAddRow(groupGUI.alliance.myInvites)
					exports.USGGUI:gridlistSetItemText(groupGUI.alliance.myInvites, row, 1, invite.alliancename)
					exports.USGGUI:gridlistSetItemData(groupGUI.alliance.myInvites, row, 1, invite.allianceid)
				end
			end
		end
		loadACL()
	end
end
addEventHandler("USGcnr_groups.updateGroupData", localPlayer, updateGroupData)


function getDateSortOrder(date)
	if(type(date) ~= "string") then return false end
	local year, month, day, hour, minute, second = date:match("(%d+)-(%d+)-(%d+)%s(%d+):(%d+):(%d+)")
	local year, month, day, hour, minute, second = tonumber(year), tonumber(month), tonumber(day), tonumber(hour), tonumber(minute), tonumber(second)
	if(year and month and day and hour and minute and second) then
		local order = year*365*24*60*60
		order = order + month*30*24*60*60
		order = order + day*24*60*60
		order = order + hour*60*60
		order = order + minute*60
		order = order + second
		return order
	end
end