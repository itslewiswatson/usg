local sx, sy = guiGetScreenSize()

function initializeWindow()

	clothesWindow = guiCreateWindow((sx / 2) - 816, (sy / 2) - 201, 711, 466, "Clothes Store", false)
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
	guiSetAlpha(clothesWindow, 1.00)
	guiSetVisible(clothesWindow, true)
	guiSetProperty(buyButton, "NormalTextColour", "FFAAAAAA")
	guiSetProperty(buyCJButton, "NormalTextColour", "FFAAAAAA")
	guiSetProperty(closeButton, "NormalTextColour", "FFAAAAAA")
end
addCommandHandler("test", initializeWindow)
--addEventHandler("onClientResourceStart", resourceRoot, initializeWindow)