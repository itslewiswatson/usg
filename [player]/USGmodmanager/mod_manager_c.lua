mods = { -- type 0 = txd, type 1 = dff, type 2 = both
}

function loadMods()
	local xml = false
	if(fileExists("mods.xml")) then
		xml = xmlLoadFile("mods.xml")
	end
	if(not xml) then return end
	local children = xmlNodeGetChildren(xml)
	for i, child in ipairs(children) do
		local name = xmlNodeGetName(child)
		if(mods[name]) then
			mods[name].enabled = xmlNodeGetAttribute(child, "enabled") == "true"
			local txd = mods[name].type == 0 or mods[name].type == 2
			local dff = mods[name].type == 1 or mods[name].type == 2
			local path = mods[name].path
			mods[name].downloaded = (not txd or fileExists(path..".txd")) and (not dff or fileExists(path..".dff"))
			if(mods[name].downloaded and mods[name].enabled) then
				activateMod(name)
			elseif(mods[name].enabled) then -- enabled, but not yet downloaded. start downloading
				downloadMod(name)
			end	
		end
	end
end


addEventHandler("onClientResourceStart", resourceRoot, 
	function ()
		if(getResourceFromName("USGaccounts") and getResourceState(getResourceFromName("USGaccounts")) == "running"
			and exports.USGaccounts:isPlayerLoggedIn(localPlayer)) then
			loadMods()
		end
	end
)
addEvent("onServerPlayerLogin", true)
addEventHandler("onServerPlayerLogin", localPlayer, loadMods)

function activateMod(modName)
	local mod = mods[modName]
	if(not mod) then return false end
	if(mod.type == 0 or mod.type == 2) then
		local txd = engineLoadTXD(mod.path..".txd")
		if(txd) then
			engineImportTXD(txd, mod.model)
		else
			mods[modName].corrupt = true
		end
	end
	if(mod.type == 1 or mod.type == 2) then
		local dff = engineLoadDFF(mod.path..".dff", mod.model)
		if(dff) then
			engineReplaceModel(dff, mod.model)
		else
			mods[modName].corrupt = true
		end	
	end
	if(mod.corrupt and not mod.attemptedRetry) then
		mod.attemptedRetry = true
		downloadMod(modName)
	end
end

addEvent("onDeactivateMod")
function deactivateMod(mod)
	mods[mod].enabled = false
	engineRestoreModel(mods[mod].model)
	triggerEvent("onDeactivateMod", localPlayer, mod)
end

function isModReady(mod)
	return mods[mod] and mods[mod].enabled and mods[mod].downloaded
end

local downloadingFiles = {}

function downloadMod(mod)
	if(mods[mod] and mods[mod].enabled) then
		local txd = mods[mod].type == 0 or mods[mod].type == 2
		local dff = mods[mod].type == 1 or mods[mod].type == 2
		local path = mods[mod].path
		if(not mods[mod].corrupt and (not txd or fileExists(path..".txd")) and (not dff or fileExists(path..".dff"))) then
			activateMod(mod)
			return true
		else
			if(txd) then
				downloadFile(path..".txd", mod)
			end
			if(dff) then
				downloadFile(path..".dff", mod)
			end
			return true
		end
	end
end

function downloadFile(path, mod)
	local file = fileCreate(path)
	if(not file) then return false end
	downloadingFiles[path] = {file, mod}
	triggerServerEvent("USGmodmanager.downloadFile", localPlayer, path)
end

addEvent("USGmodmanager.downloadError", true)
function downloadError(path)
	if(isElement(downloadingFiles[path][1])) then
		fileClose(downloadingFiles[path][1])
	end
	downloadingFiles[path] = nil
end
addEventHandler("USGmodmanager.downloadError", localPlayer, downloadError)

addEvent("USGmodmanager.appendFile", true)
function appendFile(path, data, done)
	local file = downloadingFiles[path] and downloadingFiles[path][1] or false
	if(isElement(file)) then
		fileWrite(file, data)
		if(done) then
			fileClose(file)
		end
	end
	if(done) then
		fileDownloaded(path, downloadingFiles[path][2])
		downloadingFiles[path] = nil
	end
end
addEventHandler("USGmodmanager.appendFile", localPlayer, appendFile)

function fileDownloaded(path, mod)
	if(not fileExists(path)) then error("File was not downloaded @fileDownloaded") end
	local modname = mod	
	local mod = mods[modname]
	if(not mod) then return end
	local txd = mod.type == 0 or mod.type == 2
	local dff = mod.type == 1 or mod.type == 2
	local path = mod.path
	if((not txd or fileExists(path..".txd")) and (not dff or fileExists(path..".dff"))) then
		mod.downloaded = true
		activateMod(modname)
	end
end

function saveMods()
	local xml = xmlCreateFile("mods.xml", "mods")
	for k, mod in pairs(mods) do
		local node = xmlCreateChild(xml, k)
		xmlNodeSetAttribute(node, "enabled", tostring(mod.enabled == true))
	end
	xmlSaveFile(xml)
	xmlUnloadFile(xml)
end
addEventHandler("onClientResourceStop", resourceRoot, saveMods)

