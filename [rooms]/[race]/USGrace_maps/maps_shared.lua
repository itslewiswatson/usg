function readFile(file)
	if(not isElement(file)) then return false end
	local content = ""
	while not fileIsEOF(file) do
		content = content .. fileRead(file, 524288)
	end
	return content
end

function getFileMD5(file)
	local content
	if(not isElement(file)) then 
		content = file
	else
		content = readFile(file)
	end
	if(not content) then return false end
	return md5(content)
end