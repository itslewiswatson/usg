local startX, startY
local screenWidth, screenHeight = guiGetScreenSize()
local layoutType = 1
local radarOriginalStart = 630
local radarStart

local initalized = false
local rankList

function loadPosition()
	-- calculate radar start
	local graphicStatus = dxGetStatus()
	if(not graphicStatus.SettingHUDMatchAspectRatio) then
		radarStart = 0.75*screenHeight
	else
		local targetRatio = screenWidth/screenHeight
		if(graphicStatus.SettingAspectRatio ~= "auto") then
			local ratioNumbers = graphicStatus.SettingAspectRatio:split(":")
			targetRatio = tonumber(ratioNumbers[1])/tonumber(ratioNumbers[2])
		end	
	   	local m_fToRelMul, m_fFromRelMul = 2 / screenHeight, screenHeight / 2
	    local m_fTargetBase, m_fSourceBase = 1 - 0.36 * targetRatio, 1 - 0.36 * 1.6
	    local m_fConvertScale = 1.6/targetRatio
	    local fRelY = 1 - radarOriginalStart * m_fToRelMul
	    local fNewRelY = ((( math.abs( fRelY ) - m_fSourceBase ) * m_fConvertScale + m_fTargetBase) * (fRelY < 0 and -1 or 1))
	    radarStart = ( 1 - fNewRelY ) * m_fFromRelMul
	end
	-- calculate list position	
	local chatLayout = getChatboxLayout()
	local chatEnd = (chatLayout.chat_lines+1)*15*chatLayout.chat_scale[2]
	if(chatEnd+210 > radarStart) then -- no space for list due to radar or chat
		startX = screenWidth-120
		startY = 0.3*screenHeight
		layoutType = 2
	else
		startX = 24
		startY = chatEnd+10
		layoutType = 1
	end
end

function init()
	if(not initalized) then
		loadPosition()
		initalized = true
		rankList = {}
		addEventHandler("onClientRender", root, renderList)
		return true
	end
	return false
end

function add(player, rank, time, nick)
	if(initalized) then
		local item = { nick = nick, rank = rank, time = time, player = player}
		table.insert(rankList, item)
		return true
	else
		return false
	end
end

function clear()
	rankList = {}
end

function close()
	if(initalized) then
		initalized = false
		removeEventHandler("onClientRender", root, renderList)
		return true
	end
	return false
end

function getRankItemText(i)
	local item = rankList[i]
	if(not item) then return false end
	if(isElement(item.player) and exports.USGrooms:getPlayerRoom(item.player) == exports.USGrooms:getPlayerRoom()) then
		item.nick = exports.USG:getPlayerColoredName(item.player)
	end
	return item.rank.." - "..item.nick.." | "..item.time
end

local color_white = tocolor(255,255,255)
local color_black = tocolor(0,0,0)
function renderList()
	local x = startX
	local y = startY
	for i=#rankList, 1, -1 do
		y = y + 18
		local text = getRankItemText(i)
		if(text) then
			-- draw outline without color codes
			dxDrawText(text:gsub("#%x%x%x%x%x%x",""), x+2, y+1, x+122, y+19, color_black, 1, "default", "left", "center", false, false, false)
			dxDrawText(text, x, y, x+120, y+18, color_white, 1, "default", "left", "center", false, false, false, true)
		end
		if(y > (layoutType == 1 and radarStart or 150)) then -- if it reaches hud, jump to new column
			x = x + (layoutType == 1 and 120 or -120)
			y = startY
		end
	end
end

-- event interface
addEvent("USGrace_ranklist.init", true)
addEvent("USGrace_ranklist.add", true)
addEvent("USGrace_ranklist.clear", true)
addEvent("USGrace_ranklist.close", true)

addEventHandler("USGrace_ranklist.init", localPlayer, init)
addEventHandler("USGrace_ranklist.add", root, 
	function (rank, time, nick)
		add(source, rank, time, nick)
	end
)
addEventHandler("USGrace_ranklist.clear", localPlayer, clear)
addEventHandler("USGrace_ranklist.close", localPlayer, close)