local panelGUI = {}
local markedPlayers = {}

function createPolicePanel()
	panelGUI.window = exports.USGGUI:createWindow("center","center",500,600, false, "Police")
	panelGUI.grid = exports.USGGUI:createGridList(5,5,490,540,false,panelGUI.window)
	exports.USGGUI:gridlistAddColumn(panelGUI.grid, "Player", 0.65)
	exports.USGGUI:gridlistAddColumn(panelGUI.grid, "Level", 0.2)
	exports.USGGUI:gridlistAddColumn(panelGUI.grid, "Distance", 0.15)
	panelGUI.close = exports.USGGUI:createButton(5, 565, 70, 30, false, "Close", panelGUI.window)
	panelGUI.clearAll = exports.USGGUI:createButton(80,565,70,30,false,"Clear all", panelGUI.window)
	panelGUI.markAll = exports.USGGUI:createButton(350,565,70,30,false,"Mark all", panelGUI.window)
	panelGUI.markSelected = exports.USGGUI:createButton(425,565,70,30,false,"Mark selected", panelGUI.window)
	addEventHandler("onUSGGUISClick", panelGUI.close, togglePolicePanel, false)
	addEventHandler("onUSGGUISClick", panelGUI.clearAll, clearAllBlips, false)
	addEventHandler("onUSGGUISClick", panelGUI.markAll, markAllPlayers, false)
	addEventHandler("onUSGGUISClick", panelGUI.markSelected, markSelectedPlayer, false)
end

function togglePolicePanel()
	local isPolice = exports.USGcnr_jobs:getPlayerJobType() == jobType
	if(not isElement(panelGUI.window)) then
		if(isPolice) then-- only open when police
			createPolicePanel()
			showCursor(true)
			fillPanel()
		end
	else
		if(exports.USGGUI:getVisible(panelGUI.window)) then
			exports.USGGUI:setVisible(panelGUI.window, false)
			showCursor(false)
			exports.USGGUI:gridlistClear(panelGUI.grid) -- save some memory
		elseif(isPolice) then -- only open when police
			fillPanel()
			exports.USGGUI:setVisible(panelGUI.window, true)
			showCursor(true)
		end
	end
end

function fillPanel()
	exports.USGGUI:gridlistClear(panelGUI.grid)
	local x,y,z = getElementPosition(localPlayer)
	for i, player in ipairs(getElementsByType("player")) do
		if(exports.USGrooms:getPlayerRoom(player) == "cnr") then
			local wlvl = exports.USGcnr_wanted:getPlayerWantedLevel(player)
			if(wlvl > 0) then
				local px,py,pz = getElementPosition(player)
				local distance = math.floor(getDistanceBetweenPoints2D(x,y,px,py))
				local row = exports.USGGUI:gridlistAddRow(panelGUI.grid)
				exports.USGGUI:gridlistSetItemText(panelGUI.grid, row, 1, getPlayerName(player))
				exports.USGGUI:gridlistSetItemText(panelGUI.grid, row, 2, tostring(wlvl))
				exports.USGGUI:gridlistSetItemText(panelGUI.grid, row, 3, tostring(distance))
				exports.USGGUI:gridlistSetItemData(panelGUI.grid, row, 1, player)
			end
		end
	end
end

function removePlayerBlip(player)
	local blip = markedPlayers[player]
	if(isElement(blip)) then
		destroyElement(blip)
	end
end

function clearAllBlips()
	for player, blip in pairs(markedPlayers) do
		removePlayerBlip(player)
	end
	markedPlayers = {}
end

function markPlayer(player)
	if(not isElement(markedPlayers[player])) then
		local blip = createBlipAttachedTo(player, 0, 3)
		markedPlayers[player] = blip
	end
end

function markAllPlayers()
	for i, player in ipairs(getElementsByType("player")) do
		if(exports.USGrooms:getPlayerRoom(player) == "cnr") then
			local wlvl = exports.USGcnr_wanted:getPlayerWantedLevel(player)
			if(wlvl > 0) then
				markPlayer(player)
			end
		end
	end
end

function markSelectedPlayer()
	local selected = exports.USGGUI:gridlistGetSelectedItem(panelGUI.grid)
	if(selected) then
		local player = exports.USGGUI:gridlistGetItemData(panelGUI.grid, selected, 1)
		if(isElement(player)) then
			markPlayer(player)
		end
	end
end

addEvent("onPlayerExitRoom", true)
function onPlayerExitRoom(room)
	if(room == "cnr") then
		if(source == localPlayer) then
			clearAllBlips()
			if(isElement(panelGUI.window)) then
				destroyElement(panelGUI.window)
			end
			unbindKey("F5","down",togglePolicePanel)
		end
		removePlayerBlip(source)
	end
end
addEventHandler("onPlayerExitRoom", root, onPlayerExitRoom)

function onPlayerQuit()
	removePlayerBlip(source)
end
addEventHandler("onPlayerQuit", root, onPlayerQuit)

addEvent("onPlayerChangeJob", true)
function onPlayerChangeJob()
	clearAllBlips()
	if(isElement(panelGUI.window)) then
		destroyElement(panelGUI.window)
	end
end
addEventHandler("onPlayerChangeJob", localPlayer, onPlayerChangeJob)

addEvent("onPlayerJoinCNR", true)
function onPlayerJoinCNR()
	bindKey("F5","down",togglePolicePanel)
end
addEventHandler("onPlayerJoinCNR", localPlayer, onPlayerJoinCNR)

addEventHandler("onClientResourceStart", resourceRoot,
	function ()
		if(getResourceFromName("USGrooms") and getResourceState(getResourceFromName("USGrooms")) == "running" 
			and exports.USGrooms:getPlayerRoom() == "cnr") then
				bindKey("F5","down",togglePolicePanel)
		end
	end
)