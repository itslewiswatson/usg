local punishments = {
	{"Jail", "jail"}, {"Main/team mute","mute_main"}, {"Support mute","mute_support"}, {"Global mute","mute_global"}
}
local commonTimes = { -- text, minutes number
	{"2 minutes",2},{"5 minutes",5},{"10 minutes",10},{"15 minutes",15}
}

function createPunishmentsTab()
	panelGUI.punishments = {tab = exports.USGGUI:addTab(panelGUI.tabpanel,"Punishments")}
	panelGUI.punishments.punishaccnameL = exports.USGGUI:createLabel(5,5,90, 25, false, "Account name: ", panelGUI.punishments.tab)
	panelGUI.punishments.punishaccname = exports.USGGUI:createEditBox(105,5,150, 25, false, "", panelGUI.punishments.tab)
	panelGUI.punishments.punishserialL = exports.USGGUI:createLabel(265,5,40, 25, false, "Serial: ", panelGUI.punishments.tab)
	panelGUI.punishments.punishserial = exports.USGGUI:createEditBox(315,5,250, 25, false, "", panelGUI.punishments.tab)
	panelGUI.punishments.customreason = exports.USGGUI:createEditBox(5,75,340,25,false,"Custom reason",panelGUI.punishments.tab,tocolor(255,255,255),true)
	
	panelGUI.punishments.daysL = exports.USGGUI:createLabel(5,105,60,25,false,"Days:", panelGUI.punishments.tab)
	panelGUI.punishments.days = exports.USGGUI:createEditBox(80,105,70,25,false,"0", panelGUI.punishments.tab)	
	panelGUI.punishments.hoursL = exports.USGGUI:createLabel(5,140,60,25,false,"Hours:", panelGUI.punishments.tab)
	panelGUI.punishments.hours = exports.USGGUI:createEditBox(80,140,70,25,false,"0", panelGUI.punishments.tab)	
	panelGUI.punishments.minutesL = exports.USGGUI:createLabel(5,175,60,25,false,"Minutes:", panelGUI.punishments.tab)
	panelGUI.punishments.minutes = exports.USGGUI:createEditBox(80,175,70,25,false,"0", panelGUI.punishments.tab)
	panelGUI.punishments.secondsL = exports.USGGUI:createLabel(5,210,60,25,false,"Seconds:", panelGUI.punishments.tab)
	panelGUI.punishments.seconds = exports.USGGUI:createEditBox(80,210,70,25,false,"0", panelGUI.punishments.tab)
	panelGUI.punishments.commontimes = exports.USGGUI:createGridList(250,105,290,130,false, panelGUI.punishments.tab, tocolor(20,20,20,220))
		exports.USGGUI:gridlistAddColumn(panelGUI.punishments.commontimes, "i", 0.1)
		exports.USGGUI:gridlistAddColumn(panelGUI.punishments.commontimes, "Time", 0.8)
		for i=1,#commonTimes do
			local row = exports.USGGUI:gridlistAddRow(panelGUI.punishments.commontimes)
			exports.USGGUI:gridlistSetItemText(panelGUI.punishments.commontimes,row,1,tostring(i))
			exports.USGGUI:gridlistSetItemText(panelGUI.punishments.commontimes,row,2,tostring(commonTimes[i][1]))
		end
		addEventHandler("onUSGGUIClick", panelGUI.punishments.commontimes,onPunishmentCommonTimeClick)
	panelGUI.punishments.punish = exports.USGGUI:createButton('center',265,140,25,false,"Punish",panelGUI.punishments.tab)
	addEventHandler("onUSGGUISClick", panelGUI.punishments.punish, onPunishPlayer, false)
	-- finally add combobxes
	
	panelGUI.punishments.punishments = exports.USGGUI:createComboBox(425,40,150, 25, false, "Punishment", panelGUI.punishments.tab, tocolor(0,0,0,230))
	panelGUI.punishments.punishmentType = exports.USGGUI:createComboBox(215,40,150,25,false,"Type",panelGUI.punishments.tab, tocolor(0,0,0,230))
	exports.USGGUI:comboBoxAddOption(panelGUI.punishments.punishmentType, "Account")
	exports.USGGUI:comboBoxAddOption(panelGUI.punishments.punishmentType, "Serial")
	panelGUI.punishments.reasons = exports.USGGUI:createComboBox(5,40,200, 25, false, "Reason", panelGUI.punishments.tab, tocolor(0,0,0,230))
		local reasons = exports.USGadmin:getPunishmentReasons()
		exports.USGGUI:comboBoxAddOption(panelGUI.punishments.reasons, "Custom reason")
		if ( reasons ) then
			for i=1,#reasons do
				local text = "#"..i.." - "..reasons[i]
				exports.USGGUI:comboBoxAddOption(panelGUI.punishments.reasons, text)
			end
		end
		for i,punishment in ipairs(punishments) do
			exports.USGGUI:comboBoxAddOption(panelGUI.punishments.punishments, punishment[1])
		end

	panelGUI.punishments.onPlayerSelect = onPunishmentsPlayerSelect
end

function onPunishmentCommonTimeClick()
	local selRow = exports.USGGUI:gridlistGetSelectedItem(panelGUI.punishments.commontimes)
	if ( selRow and commonTimes[selRow] ) then
		exports.USGGUI:setText(panelGUI.punishments.minutes, tostring(commonTimes[selRow][2]))
	end
end

function onPunishmentsPlayerSelect(player)
	local serial = getPlayerSerial(player)
	local acc = exports.USGaccounts:getPlayerAccount(player)
	if ( acc ) then
		exports.USGGUI:setText(panelGUI.punishments.punishaccname, acc)
	end
	exports.USGGUI:setText(panelGUI.punishments.punishserial, serial)
end

function getPunishmentDuration()
	local duration = 0
	local seconds = tonumber(exports.USGGUI:getText(panelGUI.punishments.seconds))
	if(not seconds or seconds < 0) then
		exports.USGmsg:msg("Invalid input @ seconds", 255, 0, 0)
		return false
	end
	duration = duration+seconds
	local minutes = tonumber(exports.USGGUI:getText(panelGUI.punishments.minutes))
	if(not minutes or minutes < 0) then
		exports.USGmsg:msg("Invalid input @ minutes", 255, 0, 0)
		return false
	end
	duration = duration+(minutes*60)
	local hours = tonumber(exports.USGGUI:getText(panelGUI.punishments.hours))
	if(not hours or hours < 0) then
		exports.USGmsg:msg("Invalid input @ hours", 255, 0, 0)
		return false
	end
	duration = duration+(hours*60*60)
	local days = tonumber(exports.USGGUI:getText(panelGUI.punishments.days))
	if(not days or days < 0) then
		exports.USGmsg:msg("Invalid input @ days", 255, 0, 0)
		return false
	end
	duration = duration+(days*24*60*60)
	return duration
end

function onPunishPlayer()
	--local i, punishType = exports.USGGUI:comboBoxGetCurrentOption(panelGUI.punishments.punishmentType)
	--if(not i) then
		--exports.USGmsg:msg("You have to select a punishment type.", 255, 0, 0)
		--return false
	--end
	--punishType = punishType:lower()
	local duration = getPunishmentDuration()
	if(duration < 1) then
		exports.USGmsg:msg("Duration has to be at least 1 second.", 255, 0, 0)
		return false
	end
	local punishID, punishment = exports.USGGUI:comboBoxGetCurrentOption(panelGUI.punishments.punishments)
	if(not punishID) then
		exports.USGmsg:msg("You have to select a punishment.", 255, 0, 0)
		return false
	end
	punishment = punishments[punishID][2]
	local reasonID, reason = exports.USGGUI:comboBoxGetCurrentOption(panelGUI.punishments.reasons)
	if(not reasonID) then
		exports.USGmsg:msg("You have to select a reason.", 255, 0, 0)
		return false
	end
	if(reasonID == 1) then
		reason = exports.USGGUI:getText(panelGUI.punishments.customreason)
		if(#reason == 0) then
			exports.USGmsg:msg("You didn't input a custom reason.", 255, 0, 0)
			return false
		end
	end
	local serial = exports.USGGUI:getText(panelGUI.punishments.punishserial)
	local account = exports.USGGUI:getText(panelGUI.punishments.punishaccname)
	if(#account == 0) then
		exports.USGmsg:msg("Invalid account length.", 255, 0, 0)
		return false		
	elseif(#serial ~= 32) then
		exports.USGmsg:msg("Invalid serial length.", 255, 0, 0)
		return false
	end
	triggerServerEvent("USGstaff.panel.punish", localPlayer, serial, account, duration, punishment, reason)
end