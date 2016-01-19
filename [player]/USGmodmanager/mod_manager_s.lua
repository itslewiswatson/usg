addEvent("USGmodmanager.downloadFile", true)
function downloadFile(path)
	if(fileExists(path)) then
		local file = fileOpen(path, true)
		if(not file) then 
			triggerClientEvent(client, "USGmodmanager.downloadError", client, path)
		else
			local size = fileGetSize(file)
			if(size >= 314572) then -- more than 3 MB
				setTimer(appendDownload, 2500, 0, file, path, client)
			else
				local content = fileRead(file, math.max(1,fileGetSize(file)))
				triggerLatentClientEvent(client, "USGmodmanager.appendFile", 1048576, client, path, content, true) -- 1MB a second max rate
				fileClose(file)
			end
		end
	else
		triggerClientEvent(client, "USGmodmanager.downloadError", client, path)
	end
end
addEventHandler("USGmodmanager.downloadFile", root, downloadFile)

function appendDownload(file, path, player)
	local size = fileGetSize(file)
	local content = fileRead(file,1048576)
	local done = fileGetPos(file) >= size
	triggerLatentClientEvent(client, "USGmodmanager.appendFile", 1048576, player, path, content, done) -- 1MB a second max rate
	if(done) then
		fileClose(file)
	end
end