local walkstyleGUI = {}

local positions = {
	{209.6611328125, -127.73828125, 1003.507812, 0, 3},
	{207.419921875, -100.9599609375, 1005.2578125, 0, 15},
	{217.6328125, -6.5048828125, 1001.2109375, 0, 5},
	{203.83203125, -43.4541015625, 1001.804687, 1, 1},
	{169.6767578125, -83.5224609375, 1001.8119506836, 0, 18},
}

local positions2 = {
	-- LS
	{207.419921875, -100.9599609375, 1005.2578125, 0, 15},
	{169.6767578125, -83.5224609375, 1001.8119506836, 0, 18},
	{209.6611328125, -127.73828125, 1003.507812, 0, 3},
	{217.6328125, -6.5048828125, 1001.2109375, 0, 5},
	
	-- SF
	{203.83203125, -43.4541015625, 1001.804687, 1, 1},
	{207.419921875, -100.9599609375, 1005.2578125, 1, 15},
	{169.6767578125, -83.5224609375, 1001.8119506836, 1, 18},
	
	-- LV
	{207.419921875, -100.9599609375, 1005.2578125, 2, 15},
	{207.419921875, -100.9599609375, 1005.2578125, 3, 15},
	{169.6767578125, -83.5224609375, 1001.8119506836, 3, 18},
	{217.6328125, -6.5048828125, 1001.2109375, 2, 5},
	{203.83203125, -43.4541015625, 1001.804687, 2, 1},
	{169.6767578125, -83.5224609375, 1001.8119506836, 2, 18},
}

local styles = {
    {"Default", 0},
    {"Normal", 54},
    {"Fat", 55},
    {"Muscular", 56},
    {"Man", 118},
    {"Fat Man", 124},
    {"Jogger Man", 125},
    {"Old Man", 120},
    {"Old Fat Man", 123},
    {"Woman", 129},
    {"Busy Woman", 131},
    {"Sexy Woman", 132},
    {"Sexy Woman 2", 133},
    {"Fat Woman", 135},
    {"Jogger Woman", 136},
    {"Old Woman", 134},
    {"Old Fat Woman", 137},
    
    -- Others
    {"Sneak", 69},
    {"Blind", 127},
}

function createWalkstyleGUI()
    exports.USGGUI:setDefaultTextAlignment("left","center")
    walkstyleGUI.window = exports.USGGUI:createWindow("center","center", 300, 400, false,"Walking Style")
    walkstyleGUI.gridlist = exports.USGGUI:createGridList("left","top",298,360,false, walkstyleGUI.window)
        walkstyleGUI.name = exports.USGGUI:gridlistAddColumn(walkstyleGUI.gridlist, "Name", 0.7)
        walkstyleGUI.price = exports.USGGUI:gridlistAddColumn(walkstyleGUI.gridlist, "Price", 0.3)
    walkstyleGUI.buy = exports.USGGUI:createButton("left","bottom",145,30,false,"Buy", walkstyleGUI.window)
    walkstyleGUI.close = exports.USGGUI:createButton("right","bottom",145,30,false,"Close", walkstyleGUI.window)
    addEventHandler("onUSGGUISClick",walkstyleGUI.close,togglewalkstyleGUI)
    addEventHandler("onUSGGUISClick", walkstyleGUI.buy,selectThings)
end

function listStyles()
    exports.USGGUI:gridlistClear( walkstyleGUI.gridlist)
    for index, vagina in ipairs(styles) do
        local row = exports.USGGUI:gridlistAddRow(walkstyleGUI.gridlist)
        exports.USGGUI:gridlistSetItemText(walkstyleGUI.gridlist, row, 1, tostring(vagina[1]), false, false)
        exports.USGGUI:gridlistSetItemData(walkstyleGUI.gridlist, row, 1, tostring(vagina[2]))
        exports.USGGUI:gridlistSetItemText(walkstyleGUI.gridlist, row, 2, "500")
    end
end

function togglewalkstyleGUI()
if(not exports.USGaccounts:isPlayerLoggedIn()) then return end
    if(isElement(walkstyleGUI.window )) then
        if(exports.USGGUI:getVisible(walkstyleGUI.window )) then
         exports.USGGUI:setVisible(walkstyleGUI.window , false)
            showCursor(false)
            else
            showCursor(true)
            exports.USGGUI:setVisible(walkstyleGUI.window , true)
            listStyles()
        end
    else
        createWalkstyleGUI()
        listStyles()
        showCursor(true)
    end 
end 
addCommandHandler("walkstyle",togglewalkstyleGUI)

function onHit(hitElement)
    if (getElementType(hitElement) == "player" and (hitElement == localPlayer)) then
        togglewalkstyleGUI()
    end
end

function selectThings()
    local selected = exports.USGGUI:gridlistGetSelectedItem(walkstyleGUI.gridlist)
    if(selected) then
        local styleType = exports.USGGUI:gridlistGetItemText(walkstyleGUI.gridlist, selected, 1)
        local model = tonumber(exports.USGGUI:gridlistGetItemData(walkstyleGUI.gridlist, selected, 1))
            if (model ~= "") then
				local money = getPlayerMoney(localPlayer)
				if (money > 500) then
					triggerServerEvent("USGwalkingstyles.setPedWalkingStyle", localPlayer, model)
					outputChatBox("You have changed your walking style for $500!", 0, 255, 0)
					takePlayerMoney(500, localPlayer)
					showCursor(false)
					togglewalkstyleGUI()
				else
					outputChatBox("You can not afford to buy a walking style", 200, 0, 0)
					return
				end
            end
        
    end
end

for k, v in pairs(positions) do
	local marker = createMarker(v[1], v[2], v[3] - 1, "cylinder", 1, 0,255,255, 0)
	setElementDimension(marker, v[4])
	setElementInterior(marker, v[5])
	addEventHandler("onClientMarkerHit", marker, onHit)
end

for b, s in pairs(positions2) do
	local marker2 = createMarker(s[1], s[2], s[3] - 1, "cylinder", 1, 0,255,255)
	setElementDimension(marker2, s[4])
	setElementInterior(marker2, s[5])
end