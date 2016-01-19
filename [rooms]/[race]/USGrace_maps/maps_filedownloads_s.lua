function cacheFileForDownload(mapName, relPath)
	if(not relPath) then outputDebugString(mapName) end
	local sPath = ":"..mapName.."/"..relPath
	local tPath = fileDownloadPath..mapName.."/"..relPath
	if(fileExists(sPath)) then
		local sFile = fileOpen(sPath)
		if(sFile) then
			local sContent = readFile(sFile)
			if(fileExists(tPath)) then
				local tFile = fileOpen(tPath)
				if(tFile) then
					local tHash = getFileMD5(tFile)
					local sHash = getFileMD5(sContent)
					if(tHash == sHash) then
						fileClose(sFile)
						fileClose(tFile)
						return tPath
					end
				end
			end
			local tFile = fileCreate(tPath)
			fileWrite(tFile, sContent)
			fileClose(tFile)
			return tPath
		else
			return false
		end
	else
		return false
	end
end