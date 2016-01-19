function createBansTab()
	panelGUI.bans = {tab = exports.USGGUI:addTab(panelGUI.tabpanel,"Bans")}
	panelGUI.bans.list = exports.USGGUI:createGridList(5, 5, math.ceil(tabWidth/2)-5, tabHeight-10, false, panelGUI.bans.tab)
	exports.USGGUI:gridlistAddColumn(panelGUI.bans.list, "Type", 0.25)
	exports.USGGUI:gridlistAddColumn(panelGUI.bans.list, "Target", 0.75)
	addEventHandler("onUSGGUISClick", panelGUI.bans.list, onClickBanList, false)
	local listEnd = math.ceil(tabWidth/2)+5
	panelGUI.bans.selectedBanReason = exports.USGGUI:createLabel(listEnd,5,math.ceil(tabWidth/2)-10,100,false,"Reason:", panelGUI.bans.tab)
	exports.USGGUI:setTextAlignment(panelGUI.bans.selectedBanReason,"left","top")
	panelGUI.bans.selectedBanExpireDate = exports.USGGUI:createLabel(listEnd,110,math.ceil(tabWidth/2)-10,40,false,"Expires on:", panelGUI.bans.tab)
	exports.USGGUI:setTextAlignment(panelGUI.bans.selectedBanExpireDate,"left","top")
	panelGUI.bans.removeSelected = exports.USGGUI:createButton(listEnd+math.floor(((listEnd)-100)/2), 145,100,30,false,"Remove", panelGUI.bans.tab)
	addEventHandler("onUSGGUISClick", panelGUI.bans.removeSelected, removeSelectedBan, false)
	
	panelGUI.bans.addBanType = exports.USGGUI:createSlider(listEnd+80, 200, 100,30,false,panelGUI.bans.tab,nil,{"Serial", "Account"})
	panelGUI.bans.addBanTargetLabel = exports.USGGUI:createLabel(listEnd, 235, math.floor(tabWidth/2)-10,25,false,"Target ( account / serial ) and reason",panelGUI.bans.tab)
	panelGUI.bans.addBanTarget = exports.USGGUI:createEditBox(listEnd, 260, math.floor(tabWidth/2)-10, 25, false, "",panelGUI.bans.tab)
	panelGUI.bans.addBanReason = exports.USGGUI:createMemo(listEnd, 290, math.floor(tabWidth/2)-10, 150, false, "",panelGUI.bans.tab)
	panelGUI.bans.durationLabel = exports.USGGUI:createLabel(listEnd, 445, 70, 25, false, "Duration:", panelGUI.bans.tab)
	panelGUI.bans.duration = exports.USGGUI:createEditBox(listEnd+70, 445, 100, 25, false, "", panelGUI.bans.tab)
	panelGUI.bans.durationType = exports.USGGUI:createComboBox(tabWidth-105, 445, 100, 25, false, "", panelGUI.bans.tab)
	exports.USGGUI:comboBoxAddOption(panelGUI.bans.durationType, "weeks")
	exports.USGGUI:comboBoxAddOption(panelGUI.bans.durationType, "days")
	exports.USGGUI:comboBoxAddOption(panelGUI.bans.durationType, "hours")
	exports.USGGUI:comboBoxAddOption(panelGUI.bans.durationType, "minutes")
	panelGUI.bans.addBan = exports.USGGUI:createButton(listEnd+50, 495, 100, 30, false, "Add ban", panelGUI.bans.tab)
	addEventHandler("onUSGGUISClick", panelGUI.bans.addBan, addBan, false)
	addEventHandler("onUSGGUITabSwitch", panelGUI.tabpanel, onBanTabSwitch)
end

function onBanTabSwitch(tab)
	if(tab == panelGUI.bans.tab) then
		triggerServerEvent("USGstaff.panel.requestBans", localPlayer)
	end
end
addEvent("USGstaff.panel.recieveBans", true)
function recieveBans(bans)
	exports.USGGUI:gridlistClear(panelGUI.bans.list)
	for i, ban in ipairs(bans) do
		local row = exports.USGGUI:gridlistAddRow(panelGUI.bans.list)
		exports.USGGUI:gridlistSetItemText(panelGUI.bans.list, row, 1, ban.type)
		exports.USGGUI:gridlistSetItemText(panelGUI.bans.list, row, 2, ban.target)
		exports.USGGUI:gridlistSetItemData(panelGUI.bans.list, row, 1, ban)
	end
end
addEventHandler("USGstaff.panel.recieveBans", localPlayer, recieveBans)


function onClickBanList()
	local selected = exports.USGGUI:gridlistGetSelectedItem(panelGUI.bans.list)
	if(selected) then
		local ban = exports.USGGUI:gridlistGetItemData(panelGUI.bans.list, selected, 1)
		exports.USGGUI:setText(panelGUI.bans.selectedBanReason, "Reason: "..ban.reason)
		exports.USGGUI:setText(panelGUI.bans.selectedBanExpireDate, "Expires on: "..exports.USG:getDateTimeString(ban.endtimestamp))
	else
		exports.USGGUI:setText(panelGUI.bans.selectedBanReason, "Reason:")
		exports.USGGUI:setText(panelGUI.bans.selectedBanExpireDate, "Expires on:")
	end
end

function removeSelectedBan()
	local selected = exports.USGGUI:gridlistGetSelectedItem(panelGUI.bans.list)
	if(selected) then
		local ban = exports.USGGUI:gridlistGetItemData(panelGUI.bans.list, selected, 1)
		triggerServerEvent("USGstaff.panel.removeBan", localPlayer, ban.id)
	else
		exports.USGmsg:msg("You did not select a ban!", 255, 0,0)
	end
end

function addBan()
	local _,banType = exports.USGGUI:getSliderSelectedOption(panelGUI.bans.addBanType)
	if(not banType) then
		exports.USGmsg:msg("Please select a ban-type.", 255,0,0)
		return
	end
	banType = banType:lower()
	local target = exports.USGGUI:getText(panelGUI.bans.addBanTarget)
	if(#target == 0) then
		exports.USGmsg:msg("Please enter a ban target.", 255,0,0)
		return
	end
	local reason = exports.USGGUI:getText(panelGUI.bans.addBanReason)
	if(#reason == 0) then
		exports.USGmsg:msg("Please enter a ban reason.", 255,0,0)
		return
	end
	local duration = tonumber(exports.USGGUI:getText(panelGUI.bans.duration))
	if(not duration or duration <= 0) then
		exports.USGmsg:msg("Duration must be a valid number above zero.", 255,0,0)
		return
	end
	local _,durationType = exports.USGGUI:comboBoxGetCurrentOption(panelGUI.bans.durationType) -- convert duration to seconds
	if(not durationType) then
		exports.USGmsg:msg("You must select a duration type.", 255,0,0)
		return
	end
	if(durationType == "weeks") then duration = duration*7*24*60*60
	elseif(durationType == "days") then duration = duration*24*60*60
	elseif(durationType == "hours") then duration = duration*60*60
	elseif(durationType == "minutes") then duration = duration*60
	else
		exports.USGmsg:msg("You must select a duration type.", 255,0,0)
		return
	end
	triggerServerEvent("USGstaff.panel.addBan", localPlayer, banType, target, reason, duration)
end