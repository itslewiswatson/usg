local sx, sy = guiGetScreenSize()

local storeLocations = {
	{1223.0185546875, -955.0712890625, 42.9375, 0, 0, "Random"},
}

function initializeWindow()
	local x, y = 711, 466

	clothesWindow = guiCreateWindow((sx / 2) - (x / 2), (sy / 2) - (y / 2), x, y, "Clothes Store", false)
	categoriesGrid = guiCreateGridList(9, 22, 190, 174, false, clothesWindow)
	currentGrid = guiCreateGridList(9, 202, 190, 174, false, clothesWindow)
	allGrid = guiCreateGridList(205, 22, 496, 354, false, clothesWindow)
	buyButton = guiCreateButton(9, 379, 84, 34, "Buy Item", false, clothesWindow)
	buyCJButton = guiCreateButton(9, 417, 84, 34, "Buy CJ Skin", false, clothesWindow)
	closeButton = guiCreateButton(98, 417, 84, 34, "Close", false, clothesWindow)
	
	categ = guiGridListAddColumn(categoriesGrid, "Categories", 0.9)
	names = guiGridListAddColumn(allGrid, "Clothing Names", 0.9)
	current = guiGridListAddColumn(currentGrid, "Current Clothes", 0.9)
	
	guiWindowSetSizable(clothesWindow, false)
	guiSetVisible(clothesWindow, false)
	guiSetAlpha(clothesWindow, 1.00)
	guiSetProperty(buyButton, "NormalTextColour", "FFAAAAAA")
	guiSetProperty(buyCJButton, "NormalTextColour", "FFAAAAAA")
	guiSetProperty(closeButton, "NormalTextColour", "FFAAAAAA")
	
	addEventHandler("onClientGUIClick", closeButton, closeWin, false)
end
addEventHandler("onClientResourceStart", resourceRoot, initializeWindow)

function placeStores()
	for ind, dat in pairs(storeLocations) do
		local x, y, z = dat[1], dat[2], dat[3] - 1
		marker = createMarker(x, y, z, "cylinder", 1, 200, 0, 0, 200)
		addEventHandler("onClientMarkerHit", marker, enterMarker)
	end
end
addEventHandler("onClientResourceStart", resourceRoot, placeStores)

function setUp(state, element)
	guiGridListClear(categoriesGrid)
	guiGridListClear(allGrid)
	if (state) then
		if (not guiGetVisible(clothesWindow)) then
			guiSetVisible(clothesWindow, true)
			showCursor(true)
		end
	
		for index, category in ipairs(categories) do
			if (category.id ~= nil) then
				local row = guiGridListAddRow(categoriesGrid)
				guiGridListSetItemText(categoriesGrid, row, 1, category[1], false, false)
				guiGridListSetItemData(categoriesGrid, row, 1, category[2])
			end
		end
		setupPed(true, element)
	else
		fadeCamera(false)
		setTimer(fadeCamera, 1200, 1, true)
		setTimer(setupPed, 1200, 1, false, element)
		if (guiGetVisible(clothesWindow)) then
			guiSetVisible(clothesWindow, false)
			showCursor(false)
		end
	end
end

function enterMarker(element, md)
	if (element ~= localPlayer) then return end
	if (getElementType(element) == "player" and md) then
		if (not isPedInVehicle(element)) then
			fadeCamera(false)
			setTimer(fadeCamera, 1200, 1, true)
			setTimer(setUp, 1200, 1, true, element)
		end
	end
end

function closeWin()
	guiSetVisible(clothesWindow, false)
	showCursor(false)
end

function test()
	guiSetVisible(clothesWindow, true)
	showCursor(true)
end
addCommandHandler("testcloth", test)