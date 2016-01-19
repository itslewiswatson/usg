local statLabels = {
	{key="cnr_kills", desc = "CnR - Kills:"},
	--{key="cnr_deaths", desc = "CnR - Deaths:"},
	--{key="cnr_killdeathratio", desc = "CnR - K/D ratio:"},
	{key="cnr_arrests", desc = "CnR - Players arrested:"},
	{key="cnr_turfstaken", desc = "CnR - Turfs captured:"},
	{key="dd_wins", desc = "DD - wins:"},
	{key="dm_wins", desc = "DM - wins:"},
	{key="str_wins", desc = "Shooter - wins:"},
}

local statCount = #statLabels
local statsPerColumn = math.ceil(statCount/2)
local statsGUI = {}
local selectedPlayer
function createStatsGUI()
	statsGUI.window = exports.USGGUI:createWindow("center","center",500,385,false,"Stats")
	statsGUI.search = exports.USGGUI:createEditBox(5,5,140,25,false,"",statsGUI.window)
	addEventHandler("onUSGGUIChange",statsGUI.search, onSearchChange, false)
	statsGUI.grid = exports.USGGUI:createGridList(5,40,140,325,false,statsGUI.window)
	exports.USGGUI:gridlistAddColumn(statsGUI.grid, "Player",1.0)
	addEventHandler("onUSGGUISClick",statsGUI.grid,onPlayerGridClick, false)
	statsGUI.myStats = exports.USGGUI:createButton(150,5,70,25,false,"Your stats",statsGUI.window)
	addEventHandler("onUSGGUISClick",statsGUI.myStats, loadMyStats, false)
	statsGUI.status = exports.USGGUI:createLabel(230,5,260,25,false,"Click a player to load his stats.",statsGUI.window)
	statsGUI.statsScroll = exports.USGGUI:createScrollArea(150,40,340,205,false,statsGUI.window)
	statsGUI.stats = {}
	local y = 0
	local x = 5
	for i, stat in ipairs(statLabels) do
		if(i == statsPerColumn+1) then
			x = 170
			y = 0
		end
		local label = exports.USGGUI:createLabel(x, y, 170, 20, false, stat.desc, statsGUI.statsScroll)
		exports.USGGUI:setTextAlignment(label, "left", "center")
		statsGUI.stats[stat.key] = label
		y = y + 20
	end
	statsGUI.close = exports.uSGGUI:createButton(425,350,70,30,false,"Close",statsGUI.window)
	addEventHandler("onUSGGUISClick",statsGUI.close, closeStatsGUI, false)
	fillPlayerGrid()
end

function toggleStatsGUI()
	if(not exports.USGAccounts:isPlayerLoggedIn(localPlayer)) then return end
	if(not isElement(statsGUI.window)) then
		createStatsGUI()
		showCursor(true)
	else
		if(exports.USGGUI:getVisible(statsGUI.window)) then
			closeStatsGUI()
		else
			fillPlayerGrid()
			showCursor(true)
			exports.USGGUI:setVisible(statsGUI.window)
		end
	end
end
addCommandHandler("stats",toggleStatsGUI,false,false)

function onPlayerGridClick()
	local selected = exports.USGGUI:gridlistGetSelectedItem(statsGUI.grid)
	if(selected) then
		local player = exports.USGGUI:gridlistGetItemData(statsGUI.grid, selected, 1)
		if(isElement(player)) then
			requestPlayerStats(player)
		else
			exports.USGmsg:msg("This player has quit.", 255, 0, 0)
			fillPlayerGrid()
		end
	end
end

function onSearchChange()
	fillPlayerGrid()
end

function fillPlayerGrid()
	local filter = exports.USG:escapeString(exports.USGGUI:getText(statsGUI.search))
	exports.USGGUI:gridlistClear(statsGUI.grid)
	for i, player in ipairs(getElementsByType("player")) do
		if(exports.USGaccounts:isPlayerLoggedIn(player)) then
			if(not filter or getPlayerName(player):find(filter)) then
				local row = exports.USGGUI:gridlistAddRow(statsGUI.grid)
				exports.USGGUI:gridlistSetItemText(statsGUI.grid, row, 1, getPlayerName(player))
				exports.USGGUI:gridlistSetItemData(statsGUI.grid, row, 1, player)
			end
		end
	end
end

function loadMyStats()
	requestPlayerStats(localPlayer)
end


local lastReceive = 0
function requestPlayerStats(player)
	if(isElement(player)) then
		if(selectedPlayer ~= player or getTickCount()-lastReceive > 10000) then
			selectedPlayer = player
			exports.USGGUI:setText(statsGUI.status, "Loading "..getPlayerName(player).." his stats...")
			triggerServerEvent("USGplayerstats.request",player)
		end
	end
end

function closeStatsGUI()
	if(isElement(statsGUI.window)) then
		showCursor(false)
		exports.USGGUI:setVisible(statsGUI.window, false)
	end
end

addEvent("USGplayerstats.receive", true)
addEventHandler("USGplayerstats.receive", root, 
	function (stats)
		if(selectedPlayer == source) then
			lastReceive = getTickCount()
			exports.USGGUI:setText(statsGUI.status, "Viewing "..getPlayerName(source).." his stats.")
			loadStats(stats)
		end
	end
)

function loadStats(stats)
	for i, stat in ipairs(statLabels) do
		if(stats[stat.key]) then
			local str = stat.desc.." "..tostring(stats[stat.key])
			exports.USGGUI:setText(statsGUI.stats[stat.key], str)
		end
	end
end