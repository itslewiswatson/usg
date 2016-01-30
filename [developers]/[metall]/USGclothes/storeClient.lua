local sx, sy = guiGetScreenSize()
local rotating = false

local storeLocations = {
	{1223.0185546875, -955.0712890625, 42.9375, 0, 0, "Random"},
}

pedX, pedY, pedZ = 1482.879, -2325.162, 12.547
mX, mY, mZ, mLX, mLY, mLZ = 1481.767, -2328.280, 14.022, 1479.178, -2229.386, -0.582
viewingDim = 10

categories = {
	{"Shirts", 0},
	{"Hair", 1},
	{"Pants", 2},
	{"Shoes", 3},
	{"Necklaces", 13},
	{"Watches", 14},
	{"Glasses", 15},
	{"Hats", 16},
}

cuIds = {
	["a"] = "cj_ped_head",
	["b"] = "cj_ped_torso",
	["c"] = "cj_ped_legs",
	["d"] = "cj_ped_feet",
	["0"] = "cj_ped_torso",
	["1"] = "cj_ped_head",
	["2"] = "cj_ped_legs",
	["3"] = "cj_ped_feet",
	["13"] = "cj_ped_torso",
	["14"] = "Watches",
	["15"] = "cj_ped_head",
	["16"] = "cj_ped_head",
}

function getCurrentPlayerClothes(element)
	guiGridListClear(currentGrid)
	for i = 0, 17 do
		if (not blackListed[i]) then
			local txd, dff = getPedClothes(element, i)
			if (type(txd) ~= "boolean" and type(dff) ~= "boolean") then
				for k, item in ipairs(clothes) do
					if (string.match(item.texture, txd) and string.match(item.model, dff)) then
						local row = guiGridListAddRow(currentGrid)
						guiGridListSetItemText(currentGrid, row, 1, "$"..item.price.." | "..item.name, false, false)
					end
				end
			end
		end
	end
end

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
	
	--addEventHandler("onClientGUIClick", closeButton, closeWin, false)
end
addEventHandler("onClientResourceStart", resourceRoot, initializeWindow)

function getShaderID(id)
	local id = tostring(id)
	if (cuIds[id]) then
		return cuIds[id]
	else
		return false
	end
end

function applyClothes(player, txd, model, id, sid, custom, path)
	if (getElementType(player) == "ped") then
		previewItem(txd, mdl, id)
	else
		addPedClothes(player, txd, md1, md)
	end
	if (custom) then
		applyCustomTexture(player, path, sid)
	else
		removeCustomTexture(player, sid)
	end
end

function placeStores()
	for ind, dat in pairs(storeLocations) do
		local x, y, z = dat[1], dat[2], dat[3] - 1
		marker = createMarker(x, y, z, "cylinder", 1, 200, 0, 0, 200)
		addEventHandler("onClientMarkerHit", marker, enterMarker)
	end
end
addEventHandler("onClientResourceStart", resourceRoot, placeStores)

function setupPed(state, element)
	if (state) then
		if (isElement(element)) then
			if (not isElement(clothPed)) then
				clothPed = createPed(0, pedX, pedY, pedZ + 1)
				setElementDimension(clothPed, viewingDim)
			end
			setElementFrozen(element, true)
			setElementDimension(element, viewingDim)
			setElementInterior(element, 0)
			setCameraMatrix(mX, mY, mZ, mLX, mLY, mLZ)
			if (not rotating) then
				rotating = true
				addEventHandler("onClientRender", root, tickRotation)
			end
		end
	else
		if (isElement(clothPed)) then
			destroyElement(clothPed)
			if (rotating) then
				rotating = false
				removeEventHandler("onClientRender", root, tickRotation)
			end
		end
		if (isElement(element)) then
			local int, dim = getElementInterior(element), getElementDimension(element)
			local int, dim = tonumber(int), tonumber(dim)
			setElementInterior(element, int)
			setElementDimension(element, dim)
			setElementFrozen(element, false)
			setCameraTarget(localPlayer)
		end
	end
end

function tickRotation()
	if (not isElement(clothPed)) then
		removeEventHandler("onClientRender", root, tickRotation)
		rotating = false
		return
	end
	local _, _, crot = getElementRotation(clothPed)
	setElementRotation(clothPed, 0, 0, crot + 0.75)
end

function setUp(state, element)
	guiGridListClear(categoriesGrid)
	guiGridListClear(allGrid)
	if (state) then
		if (not guiGetVisible(clothesWindow)) then
			guiSetVisible(clothesWindow, true)
			showCursor(true)
		end
	
		for index, category in ipairs(categories) do
			if (category[2] ~= nil) then
				local row = guiGridListAddRow(categoriesGrid)
				guiGridListSetItemText(categoriesGrid, row, 1, category[1], false, false)
				guiGridListSetItemData(categoriesGrid, row, 1, category[2])
			end
		end
		setupPed(true, element)
	else
		--fadeCamera(false)
		--setTimer(fadeCamera, 1200, 1, true)
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
			--fadeCamera(false)
			--setTimer(fadeCamera, 1200, 1, true)
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

function previewItem(txd, dff, id)
	if (txd and dff and id) then
		local ctxd, cdff = getPedClothes(clothPed, id)
		if (ctxd and cdff) then
			if (string.match(ctxd, txd) and string.match(cdff, dff)) then
				getCurrentPlayerClothes(clothPed, txd, dff)
			else
				if (isElement(clothPed)) then
					addPedClothes(clothPed, txd, dff, id)
					getCurrentPlayerClothes(clothPed, txd, dff)
				end
			end
		else
			if (isElement(clothPed)) then
				addPedClothes(clothPed, txd, dff, id)
				getCurrentPlayerClothes(clothPed, txd, dff)
			end
		end
	end
end

function findClothes(ctype, idex)
	if (ctype == 0) then
		index = 67
	elseif (ctype == 1) then
		index = 32
	elseif (ctype == 2) then
		index = 44
	elseif (ctype == 3) then
		index = 37
	end
	
	local rValue
	if (not idex) then
		local ctable = {}
		for k = 0, index do
			local ctex, cmod = getClothesByTypeIndex(ctype, k)
			if (ctex and cmod) then
				table.insert(ctable, {name = ctex, texture = ctex, model = cmod, id = ctype, price = 150, custom = false})
			end
		end
		return ctable
	else
		local texture, model = getClothesByTypeIndex(ctype, idex)
		return texture, model
	end
end
	

function getClothesFromID(id)
	guiGridListClear(allGrid)
	if (type(id) == "number") then
		local ctable = findClothes(id)
		for ind, item in ipairs(ctable) do
			if (item.id ~= nil) then
				local row = guiGridListAddRow(allGrid)
				guiGridListSetItemText(allGrid, row, 1, "$"..item.price.." - "..item.name, false, false)
				guiGridListSetItemData(allGrid, row, 1, item.texture..";"..item.model..";"..item.id..";0")
			end
		end
	else
		for name, category in pairs(custom) do
			local catRow = guiGridListAddRow(allGrid)
			guiGridListSetItemText(allGrid, catRow, 1, name, true, false)
			for ind, item in pairs(category) do
				local itemRow = guiGridListAddRow(allGrid)
				guiGridListSetItemText(allGrid, itemRow, 1, "$"..item.price.." - "..item.name, false, false)
				guiGridListSetItemData(allGrid, itemRow, 1, item.texture..";"..item.model..";"..item.id..";1;"..item.custom)
			end
		end
	end
end

function handleButtons()
	if (source == closeButton) then
		if (guiGetVisible(clothesWindow)) then
			setUp(false, localPlayer)
			triggerServerEvent("USGclothes.loadItems", localPlayer, localPlayer, false)
		end
	elseif (source == buyButton) then
		local itemRow, itemCol = guiGridListGetSelectedItem(allGrid)
		local data = guiGridListGetItemData(allGrid, itemRow, itemCol)
		
		if (data) then
			local data = split(data, ";")
			local txd, dff, id = data[1], data[2], data[3]
			
			local shaderID = getShaderID(id)
			local custom = tonumber(data[4])
			
			if (custom == 0) then
				triggerServerEvent("USGclothes.buyItem", localPlayer, txd..";"..dff..";"..id..";"..shaderID)
				setUp(false, localPlayer)
			elseif (custom == 1) then
				local path = data[5]
				triggerServerEvent("USGclothes.buyItem", localPlayer, txd..";"..dff..";"..id..";"..shaderID)
				setUp(false, localPlayer)
			end
		end
	elseif (source == categoriesGrid) then
		local catRow, catCol = guiGridListGetSelectedItem(categoriesGrid)
		local clothID = guiGridListGetItemData(categoriesGrid, catRow, catCol)
		getClothesFromID(clothID)
	elseif (source == allGrid) then
		local itemRow, itemCol = guiGridListGetSelectedItem(allGrid)
		local data = guiGridListGetItemData(allGrid, itemRow, itemCol)
		
		if (data) then
			local data = split(data, ";")
			local txd, dff, id = data[1], data[2], data[3]
			local shaderID = getShaderID(id)
			local custom = tonumber(data[4])
			
			if (custom == 0) then
				applyClothes(clothPed, txd, dff, id, shaderID, false)
			elseif (custom == 1) then
				local path = data[5]
				local path = directory..path
				
				if (doesCustomFileExist(path)) then
					applyClothes(clothPed, txd, dff, id, shaderID, true, path)
				else
					triggerServerEvent("USGclothes.downloadSkin", root, localPlayer, path, shaderID)
				end
			end
		end
	end
end
addEventHandler("onClientGUIClick", root, handleButtons)