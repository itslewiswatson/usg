local file = fileOpen("skins.txt")
local content = fileRead(file,fileGetSize(file))

local tableFile = fileCreate("skintable.txt")
fileWrite(tableFile,"{ ")

local lastFind = 0
local skinsFound = 0
local columns = 0

while lastFind do
	local IDStart, IDEnd = string.find(content,"<b>Skin ID</b>:", lastFind)
	local NameStart, NameEnd = string.find(content,"<b>Skin Name/Type</b>:", IDEnd)
	lastFind = IDEnd
	if IDStart then
		local endOfID,_ = string.find(content,"<br />",IDEnd)
		local endOfName,_ = string.find(content,"<br />",NameEnd)
		if endOfID and endOfName then
			local skinID = string.sub(content,IDEnd+1,endOfID-1)
			local skinName = string.sub(content,NameEnd+2,endOfName-1)
			skinID = string.gsub(skinID," ","")
			columns = columns+1
			if(columns > 6) then
				fileWrite(tableFile,"\n")
				columns = 0
			end
			fileWrite(tableFile,"["..skinID.."]=\""..skinName.."\", ")
			outputDebugString(skinID.." > "..skinName)
			skinsFound = skinsFound+1
			--break
		end		
	else
		break
	end
end

fileWrite(tableFile," }")

fileFlush(tableFile)
fileClose(tableFile)

outputServerLog("Done, "..skinsFound.." skins found.")