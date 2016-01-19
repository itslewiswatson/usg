local mapGUI = {}
local loadedMaps

function createGUI()
	mapGUI.window = exports.USGGUI:createWindow("right","center",300,560,false,"Maps")
	mapGUI.search = exports.USGGUI:createEditBox("center",5,290,25,false,"", mapGUI.window)
	addEventHandler("onUSGGUIChange", mapGUI.search, onSearchChange, false)
	mapGUI.maps = exports.USGGUI:createGridList("center",35,290,400,false, mapGUI.window)
	exports.USGGUI:gridlistAddColumn(mapGUI.maps, "Name", 0.8)
	exports.USGGUI:gridlistAddColumn(mapGUI.maps, "Room", 0.2)
	mapGUI.remove = exports.USGGUI:createButton(5,445,110,25,false,"Remove", mapGUI.window)
	addEventHandler("onUSGGUISClick", mapGUI.remove, onRemoveMap, false)
	mapGUI.setAsNext = exports.USGGUI:createButton(185,445,110,25,false,"Set as next", mapGUI.window)
	addEventHandler("onUSGGUISClick", mapGUI.setAsNext, onSetMapAsNext, false)

	mapGUI.name = exports.USGGUI:createEditBox("center",490,290,25,false,"",mapGUI.window)
	mapGUI.room = exports.USGGUI:createEditBox(5,520,60,25,false,"",mapGUI.window)
	mapGUI.add = exports.USGGUI:createButton(70,520,80,25,false,"Add",mapGUI.window)
	addEventHandler("onUSGGUISClick", mapGUI.add, onAddMap, false)
	mapGUI.close = exports.USGGUI:createButton(210,520,80,25,false,"Close",mapGUI.window)
	addEventHandler("onUSGGUISClick", mapGUI.close, toggleGUI, false)
end

function toggleGUI()
	if(not isElement(mapGUI.window)) then
		if(exports.USGadmin:isPlayerMapManager()) then
			createGUI()
			requestMapList()
			showCursor(true)
		end
	else
		if(exports.USGGUI:getVisible(mapGUI.window)) then
			showCursor(false)
			exports.USGGUI:setVisible(mapGUI.window, false)
		elseif(exports.USGadmin:isPlayerMapManager()) then
			showCursor(true)
			requestMapList()
			exports.USGGUI:setVisible(mapGUI.window, true)
		end
	end
end
addCommandHandler("maps",toggleGUI, false, false)

function onSearchChange()
	local filter = exports.USGGUI:getText(mapGUI.search)
	loadMaps()
end

function requestMapList()
	triggerServerEvent("USGrace_mapmanager.requestList", localPlayer)
end

addEvent("USGrace_mapmanager.receiveList", true)
function receiveMapList(maps)
	loadedMaps = maps
	loadMaps()
end
addEventHandler("USGrace_mapmanager.receiveList", localPlayer, receiveMapList)

function loadMaps()
	local filter = exports.USG:escapeString(exports.USGGUI:getText(mapGUI.search):lower())
	exports.USGGUI:gridlistClear(mapGUI.maps)
	local roomSort = {}
	local sortID = 0
	for i, map in ipairs(loadedMaps) do
		if(map.name:lower():find(filter)) then
			local row = exports.USGGUI:gridlistAddRow(mapGUI.maps)
			exports.USGGUI:gridlistSetItemText(mapGUI.maps, row, 1, map.name)
			exports.USGGUI:gridlistSetItemText(mapGUI.maps, row, 2, map.room)
			exports.USGGUI:gridlistSetItemData(mapGUI.maps, row, 1, map.id)
			if(not roomSort[map.room]) then
				sortID = sortID+1
				roomSort[map.room] = sortID
			end
			exports.USGGUI:gridlistSetItemSortIndex(mapGUI.maps, row, 2, roomSort[map.room])
		end
	end	
end

--

function onRemoveMap()
	local selectedRow = exports.USGGUI:gridlistGetSelectedItem(mapGUI.maps)
	if(selectedRow) then
		local id = exports.USGGUI:gridlistGetItemData(mapGUI.maps, selectedRow, 1)
		if(id) then
			triggerServerEvent("USGrace_mapmanager.removeMap",localPlayer, id)
		end
	end
end

function onSetMapAsNext()
	local selectedRow = exports.USGGUI:gridlistGetSelectedItem(mapGUI.maps)
	if(selectedRow) then
		local name = exports.USGGUI:gridlistGetItemText(mapGUI.maps, selectedRow, 1)
		local room = exports.USGGUI:gridlistGetItemText(mapGUI.maps, selectedRow, 2)
		if(name and room) then
			triggerServerEvent("USGrace_mapmanager.setAsNext", localPlayer, name, room)
		end
	end
end

function onAddMap()
	local name = exports.USGGUI:getText(mapGUI.name)
	local room = exports.USGGUI:getText(mapGUI.room)
	if(not exports.USGrooms:getRoomDimension(room)) then
		exports.USGmsg:msg("This room does not exist.", 255, 0, 0)
		return
	end
	if(#name == 0) then
		exports.USGmsg:msg("Enter the map name!", 255, 0, 0)
		return
	end
	triggerServerEvent("USGrace_mapmanager.addMap", localPlayer, name, room)
end