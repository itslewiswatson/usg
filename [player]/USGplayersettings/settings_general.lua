function initGeneralSettings()
	if ( getResourceFromName("USGaccounts") and getResourceState(getResourceFromName("USGaccounts")) == "running" and exports.USGaccounts:isPlayerLoggedIn() ) then
		addEventHandler("onPlayerSettingChange",localPlayer,loadGeneralSetting)
		-- add settings
		addSetting("syncrealtime",true,
			{ guiType = "check", category = "General", description = "Sync GTA time with real time"})
		addSetting("syncrealtimeoffset",0,
			{ guiType = "slider", category = "General", description = "Real time offset in GTA", args={{-12,12},true}, dependencyType = "enable", dependencySetting = "syncrealtime" })
		addSetting("timeminuteduration",1,
			{ guiType = "slider", category = "General", description = "Set how long a GTA minute takes in real life minutes", args={{1,120},true, 0}, dependencyType = "disable", dependencySetting = "syncrealtime" })
		addSetting("blur", false,
			{ guiType = "check", category = "General", description = "Enable blur"})
		-- load settings
		
		loadGeneralSetting("syncrealtime")
		loadGeneralSetting("blur")	
	end
end
addEventHandler("onClientResourceStart",resourceRoot,initGeneralSettings)
addEvent("onServerPlayerLogin", true)
addEventHandler("onServerPlayerLogin", localPlayer,initGeneralSettings)

function loadGeneralSetting(setting, value)
	if ( setting == "syncrealtime" or setting == "syncrealtimeoffset" or setting == "timeminuteduration" ) then
		local sync = value
		if ( setting ~= "syncrealtime" ) then sync = getSetting("syncrealtime") == "true" end
		if ( sync ) then
			local offset = tonumber(( setting == "syncrealtimeoffset" and value) or getSetting("syncrealtimeoffset")) or 0
			local theTime = getRealTime()
			local nHour = theTime.hour+offset
			if ( nHour >= 24 ) then
				nHour = nHour-24
			end
			setTime(nHour,theTime.minute+1)
			setMinuteDuration(60000) -- 1 minute = 1 minute
		else
			local tmDuration = math.max(1,tonumber(( setting == "timeminuteduration" and value) or getSetting("timeminuteduration") ) or 1)
			setMinuteDuration(tmDuration*1000) -- value*second
		end
	elseif ( setting == "blur" ) then
		if ( value ) then
			setBlurLevel(36)
		else
			setBlurLevel(0)
		end
	end
end

