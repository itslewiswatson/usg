local s = "[%s*%.*%d*%p*]*"

local abbrivationList = {
	{"S","A","E","S"},
	{"S","A","U","R"},
	{"G","T","I"},
	{"W","S","S"},
	{"C","G","G"},
	{"C","S","F"},
	{"F","S","S"},
	{"T","G"},
	{"C","I","T"},
}

local patternPrefixes = {
	"[%s*%.*%d*%p*]+", -- space, puncuation or w/e
	"^", -- or it's the first in string
}

local patternSuffixes = {
	"[%s*%.*%d*%p*]+", -- space, puncuation or w/e
	"$", -- last in string
}
	

local patternList = {
	
}

for _, abbrivation in ipairs(abbrivationList) do
	local pattern = ""
	for i=1,#abbrivation do
		pattern = pattern..abbrivation[i].."+"..s
	end
	table.insert(patternList,pattern)
end


addEvent("onUSGPlayerChat")
function onPlayerChat(message, chat)
	if(type(message) ~= "string") then return end
	for i, pattern in ipairs(patternList) do
		for i, prefix in ipairs(patternPrefixes) do
			for i, suffix in ipairs(patternSuffixes) do
				local match, matchEnd = message:upper():find(prefix..pattern..suffix)
				if(match and match ~= matchEnd) then
					local matchText = message:sub(match, matchEnd)
					if(#matchText > 0) then
						cancelEvent(true, "Advertisement")
						onPlayerCaught(source, message, matchText)
						return
					end
				end
			end
		end
	end
end
addEventHandler("onUSGPlayerChat", root, onPlayerChat)

function onPlayerCaught(player, text, match)
	outputChatBox("WARNING: do not advertise!", player, 255, 0, 0)
	outputChatBox("WARNING: the following text triggered our filter:", player, 255, 0, 0)
	outputChatBox("'"..text.."' | match: '"..match.."'", player, 255, 0, 0)
	outputChatBox("WARNING: incorrect filter? please contact staff.", player, 255, 0, 0)
end