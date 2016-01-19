function openSettingsFile()
	local xml
	if ( fileExists("settings.xml") ) then
		xml = xmlLoadFile("settings.xml")
	end
	if not ( xml ) then
		xml = xmlCreateFile("settings.xml","settings")
	end
	return xml
end

function addSetting(key,defaultValue,extraArgs)
	local settings = openSettingsFile()
	if ( settings ) then
		if ( type(key) == "string") then
			if not ( xmlFindChild(settings,key,0) ) then
				local valType = type(defaultValue)
				if ( valType == "table" ) then value = toJSON(value) end
				local node = xmlCreateChild(settings,key)
				xmlNodeSetAttribute(node,"type",valType)
				xmlNodeSetAttribute(node,"panelType",tostring(extraArgs.guiType))
				xmlNodeSetAttribute(node,"panelCategory",tostring(extraArgs.category))
				xmlNodeSetAttribute(node,"panelDescription",tostring(extraArgs.description))
				xmlNodeSetAttribute(node,"panelDependencyType",tostring(extraArgs.dependencyType))
				xmlNodeSetAttribute(node,"panelDependencySetting",tostring(extraArgs.dependencySetting))
				xmlNodeSetAttribute(node,"panelArgs",toJSON(extraArgs.args or {}))
				xmlNodeSetAttribute(node,"defaultValue",tostring(defaultValue))
				xmlNodeSetValue(node,tostring(defaultValue))
				xmlSaveFile(settings)
				xmlUnloadFile(settings)	
				return true
			else
				local node = xmlFindChild(settings,key,0)
				xmlNodeSetAttribute(node,"panelType",tostring(extraArgs.guiType))
				xmlNodeSetAttribute(node,"panelCategory",tostring(extraArgs.category))
				xmlNodeSetAttribute(node,"panelDescription",tostring(extraArgs.description))
				xmlNodeSetAttribute(node,"panelDependencyType",tostring(extraArgs.dependencyType))
				xmlNodeSetAttribute(node,"panelDependencySetting",tostring(extraArgs.dependencySetting))
				xmlNodeSetAttribute(node,"panelArgs",toJSON(extraArgs.args or {}))
				xmlNodeSetAttribute(node,"defaultValue",tostring(defaultValue))
				xmlSaveFile(settings)
				xmlUnloadFile(settings)	
				return true				
			end
			xmlUnloadFile(settings)	
			return false
		end
		xmlUnloadFile(settings)	
		return false
	end
	return false
end

addEvent("onPlayerSettingChange", true)
function setSetting(key,value)
	local settings = openSettingsFile()
	if ( settings ) then
		if ( type(key) == "string" ) then
			local valType = type(value)
			local settingNode = xmlFindChild(settings,key,0)
			if not ( settingNode ) then
				settingNode = xmlCreateChild(settings,key)
			end
			if ( settingNode ) then
				if ( valType == "table" ) then value = toJSON(value) end
				xmlNodeSetAttribute(settingNode,"type",valType)
				xmlNodeSetValue(settingNode,tostring(value))
				xmlSaveFile(settings)
				xmlUnloadFile(settings)
				triggerEvent("onPlayerSettingChange",localPlayer,key,value)
				return true
			end
			xmlUnloadFile(settings)
			return false
		end
		xmlUnloadFile(settings)
		return false
	end
	return false
end

function getSetting(key)
	local settings = openSettingsFile()
	if ( settings ) then
		if ( type(key) == "string" ) then
			local node = xmlFindChild(settings,key,0)
			if ( node ) then
				local value = xmlNodeGetValue(node)
				local valType = xmlNodeGetAttribute(node,"type")
				if ( valType == "bool" ) then
					if ( value == "true" or value == "false" ) then value = value == "true" end
				elseif ( valType == "number" ) then
					value = tonumber(value)
				elseif ( valType == "nil" ) then
					value = nil
				elseif ( valType == "table" ) then
					value = fromJSON(value)
				end
				xmlUnloadFile(settings)
				return value
			end
			return nil
		end
		xmlUnloadFile(settings)
		return nil
	end
	return nil
end