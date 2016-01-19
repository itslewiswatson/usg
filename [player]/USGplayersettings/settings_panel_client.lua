panelGUI = {}
GUIsettings = {}
settingsGUI = {}
resetSettings = {}
settingsReset = {}
settingPanelInfo = {}
panelTabY = {}
settingDependents = {}
categorySettings = {}

local width, height = 500,350
local settingSpacer = 15

function createSettingsPanel()
	if ( not isElement(panelGUI.window) ) then
		panelGUI = { tabs = {}, areas = {}}
		settingsGUI = {}
		GUIsettings = {}
		settingPanelInfo = {}
		panelTabY = {}
		panelGUI.window = exports.USGGUI:createWindow('center','center',width,height+50,false,"USG ~ Settings")
		panelGUI.tabPanel = exports.USGGUI:createTabPanel('center','top',width,height,false,panelGUI.window)
		panelGUI.close = exports.USGGUI:createButton(375,height+10,75,25,false,"Close",panelGUI.window)
			addEventHandler("onUSGGUIClick",panelGUI.close,toggleSettingsPanel,false)
		panelGUI.resetall = exports.USGGUI:createButton(290,height+10,75,25,false,"Reset all",panelGUI.window)
			addEventHandler("onUSGGUIClick",panelGUI.resetall,resetAllSettings,false)
	end
end

function resetAllSettings()
	for setting,info in pairs(settingPanelInfo) do
		if ( info.default ) then
			setPanelSetting(setting,info.default)
			setGUIValue(setting,info.default)
		end
	end
	exports.USGmsg:msg("All values reset!")
end

function refreshDependent(setting)
	if ( not settingPanelInfo[setting] ) then return false end		

	local depType, depSetting = settingPanelInfo[setting].depType, settingPanelInfo[setting].depSetting
	if ( depType and ( depType == "show" or depType == "hide" or depType == "enable" or depType == "disable" ) ) then
		if ( settingPanelInfo[depSetting] and settingPanelInfo[depSetting].type == "check" ) then
			local val = settingPanelInfo[depSetting].value
			if ( depType == "show" or depType == "hide" ) then
				if (true) then return false end -- disabled
				local state = val
				if ( depType == "hide" ) then state = not val end
				local old = exports.USGGUI:getVisible(settingsGUI[setting])
				for i=1,#settingPanelInfo[setting].relatedGUI do
					exports.USGGUI:setVisible(settingPanelInfo[setting].relatedGUI[i],state)
				end
				exports.USGGUI:setVisible(settingsGUI[setting],state)
				if ( old ~= state ) then
					local reached = false
					local catSettings = categorySettings[settingPanelInfo[setting].cat]
					for i=1,#catSettings do
						if ( settingPanelInfo[catSettings[i]] ) then
							if ( catSettings[i] == setting ) then
								reached = true
							elseif ( reached ) then
								local elements = settingPanelInfo[catSettings[i]].relatedGUI
								table.insert(elements, settingsGUI[setting])
								for elID=1,#elements do
									local x,y = exports.USGGUI:getPosition(elements[elID])
									if ( not state ) then
										exports.USGGUI:setPosition(elements[elID],x,y-settingPanelInfo[setting].totalHeight)
									else
										exports.USGGUI:setPosition(elements[elID],x,y+settingPanelInfo[setting].totalHeight)
									end
								end
							end
						end
					end
				end
				--]]
			else
				local state = val
				if ( depType == "disable" ) then state = not val end
				for i=1,#settingPanelInfo[setting].relatedGUI do
					exports.USGGUI:setEnabled(settingPanelInfo[setting].relatedGUI[i],state)
				end
				exports.USGGUI:setEnabled(settingsGUI[setting],state)
			end
		end
		if not ( settingPanelInfo[setting].addedAsDependent ) then
			if not ( settingDependents[depSetting] ) then settingDependents[depSetting] = {} end
			table.insert(settingDependents[depSetting], setting)
			settingPanelInfo[setting].addedAsDependent = true
		end
	end
end

function loadPanelSettings()
	local settings = openSettingsFile()
	local children = xmlNodeGetChildren(settings)
	for _,child in ipairs(children) do
		local panType = xmlNodeGetAttribute(child,"panelType")
		if ( panType ) then
			local setting = xmlNodeGetName(child)
			if not ( settingPanelInfo[setting] ) then
				local cat = xmlNodeGetAttribute(child,"panelCategory")
				if ( cat ) then
					categorySettings[cat] = categorySettings[cat] or {}
					local depType, depSetting = xmlNodeGetAttribute(child,"panelDependencyType"), xmlNodeGetAttribute(child,"panelDependencySetting")	
					local panDescription = xmlNodeGetAttribute(child,"panelDescription")
					local panArgs = fromJSON(xmlNodeGetAttribute(child,"panelArgs") or "[[]]") or {}
					local value = xmlNodeGetValue(child)
					settingPanelInfo[setting] = {cat=cat,type=panType,desc =panDescription,value=value,default=xmlNodeGetAttribute(child,"defaultValue"),
						depType = depType, depSetting = depSetting, relatedGUI = {}, args = panArgs}
					if not ( cat ) then cat = "General" end
					panelTabY[cat] = panelTabY[cat] or 5
					local oldTabY = panelTabY[cat]
					if not ( panelGUI.tabs[cat] ) then
						panelGUI.tabs[cat] = exports.USGGUI:addTab(panelGUI.tabPanel,cat)
						panelGUI.areas[cat] = exports.USGGUI:createScrollArea(0,0,width,height-exports.USGGUI:getProperty(panelGUI.tabPanel,"tabHeaderHeight"),false,panelGUI.tabs[cat])
						exports.USGGUI:setScrollBarColor(panelGUI.areas[cat],tocolor(10,10,10,255),tocolor(255,255,255))
					end
					local reset = exports.USGGUI:createButton(width-70,panelTabY[cat],60,25,false,"Reset",panelGUI.areas[cat])
					resetSettings[reset] = setting
					table.insert(settingPanelInfo[setting].relatedGUI, reset)
					addEventHandler("onUSGGUIClick",reset,onResetSetting,false)
					if ( panType == "check" ) then
						settingsGUI[setting] = exports.USGGUI:createCheckBox('center',panelTabY[cat],300, 25,false, panDescription,panelGUI.areas[cat],tocolor(20,20,20,220),value == "true")
						settingPanelInfo[setting].value = value == "true"
						panelTabY[cat] = panelTabY[cat] + 25
						addEventHandler("onUSGGUIClick",settingsGUI[setting],onSettingClick,false)		
					elseif ( panType == "text" or panType == "number" or panType == "bind" ) then
						table.insert(settingPanelInfo[setting].relatedGUI, exports.USGGUI:createLabel(25,panelTabY[cat],width-85,25,false,panDescription,panelGUI.areas[cat]))
						settingsGUI[setting] = exports.USGGUI:createEditBox('center',panelTabY[cat]+30,300, 25,false, value,panelGUI.areas[cat])
						panelTabY[cat] = panelTabY[cat] + 55
						addEventHandler("onUSGGUIChange",settingsGUI[setting],function () onSettingChange(GUIsettings[source],source) end,false)					
					elseif ( panType == "slider" ) then
						-- figure out how to set value ( interpolated value )
						table.insert(settingPanelInfo[setting].relatedGUI, exports.USGGUI:createLabel(25,panelTabY[cat],width-85,25,false,panDescription,panelGUI.areas[cat]))
						settingsGUI[setting] = exports.USGGUI:createSlider('center',panelTabY[cat]+55, 300, 25,false,panelGUI.areas[cat],tocolor(20,20,20,220),unpack(panArgs))
						exports.USGGUI:setSliderSelectedOption(settingsGUI[setting], tonumber(value), true)
						addEventHandler("onUSGGUIClick",settingsGUI[setting],onSettingClick,false)
						panelTabY[cat] = panelTabY[cat] + 80
					end
					if ( isElement(settingsGUI[setting]) ) then
						GUIsettings[settingsGUI[setting]] = setting
						panelTabY[cat] = panelTabY[cat] + settingSpacer
						local spaceTaken = panelTabY[cat]-oldTabY
						if ( settingDependents[setting] ) then
							for i=1,#settingDependents[setting] do
								refreshDependent(settingDependents[setting][i])
							end
							--settingDependents[setting] = false
						end
						settingPanelInfo[setting].totalHeight = spaceTaken
						refreshDependent(setting)
						table.insert(categorySettings[cat], setting)
					end
				end
			end
		end
	end
end

function setPanelSetting(setting,value)
	if ( settingPanelInfo[setting].value ~= value ) then
		settingPanelInfo[setting].value = value
		setSetting(setting,value)
		if ( settingDependents[setting] ) then
			for i=1,#settingDependents[setting] do
				refreshDependent(settingDependents[setting][i])
			end
		end
	end
end

function setGUIValue(setting,nValue)
	local sInfo = settingPanelInfo[setting]
	if ( sInfo and isElement(settingsGUI[setting]) ) then
		if ( sInfo.type == "check" ) then
			exports.USGGUI:setCheckBoxState(settingsGUI[setting], nValue == true or nValue == "true")
		elseif ( sInfo.type == "text" or sInfo.type == "number" ) then
			exports.USGGUI:setText(settingsGUI[setting], tostring(nValue))
		elseif ( sInfo.type == "slider" and tonumber(nValue) ) then
			exports.USGGUI:setSliderSelectedOption(settingsGUI[setting], tonumber(nValue), true)
		end
	end
end

function onSettingChange(setting,gui,state)
	local settingInfo = settingPanelInfo[setting]
	local panType = settingInfo.type
	if ( panType == "text" or panType == "number" ) then
		local value = exports.USGGUI:getText(gui)
		if ( panType == "number" and not tonumber(value) ) then
			exports.USGGUI:setText(gui, settingInfo.value)
			exports.USGmsg:msg("Must be a number!",255,0,0)
		else
			setPanelSetting(setting,value)
		end
	elseif ( panType == "check" ) then
		local value = exports.USGGUI:getCheckBoxState(gui)
		setPanelSetting(setting,value)
	elseif ( panType == "slider" and state == "up" ) then
		local key,value = exports.USGGUI:getSliderSelectedOption(gui)
		if ( key or value ~= nil ) then
			setPanelSetting(setting,value)
		end
	end
end

function onSettingClick(btn,state)
	if ( GUIsettings[source] ) then
		onSettingChange(GUIsettings[source],source,state)
	end
end

function onResetSetting(btn,state)
	if ( resetSettings[source] ) then
		setPanelSetting(resetSettings[source],settingPanelInfo[resetSettings[source]].default)
		setGUIValue(resetSettings[source],settingPanelInfo[resetSettings[source]].default)
	end
end

function toggleSettingsPanel()
	if ( not isElement(panelGUI.window) ) then
		createSettingsPanel()
		loadPanelSettings()
		showCursor(true)
	else
		if ( exports.USGGUI:getVisible(panelGUI.window) ) then
			exports.USGGUI:setVisible(panelGUI.window,false)
			showCursor(false)
		else
			loadPanelSettings()
			exports.USGGUI:setVisible(panelGUI.window,true)
			showCursor(true)		
		end
	end
end
addCommandHandler("settings",toggleSettingsPanel)