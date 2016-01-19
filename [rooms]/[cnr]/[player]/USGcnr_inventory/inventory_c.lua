local screenWidth, screenHeight = guiGetScreenSize()
local thumbSize = 128
local itemWidth, itemHeight = 134, 143
local thumbX, thumbY = math.floor((itemWidth-thumbSize)/2), itemHeight-thumbSize
local panelWidth, panelHeight = itemWidth*4, itemHeight*4
local windowWidth, windowHeight = panelWidth+150, panelHeight+50
local panelX, panelY = 5, 30
local windowX, windowY = (screenWidth-windowWidth)/2, (screenHeight-windowHeight)/2
local buttonWidth, buttonHeight = windowWidth-panelWidth-panelX-10, 30
local slotBGColor = tocolor(255,255,255,50)
local hoveredSlotBGColor = tocolor(255,255,255,80)
local selectedSlotBGColor = tocolor(255,255,255,110)
local color_white = tocolor(255,255,255)
local color_button = tocolor(175,75,0)
local buttons

local itemTypes = { }
local typeList = {}
local inventory = {}
local receivedInventory = false
local inventoryState = false
local selectedItem = nil

function create(ID, name, iconPath)
	if(not itemTypes[ID]) then
		local iconWidth, iconHeight = thumbSize, thumbSize
		local iconX, iconY = 0, 0
		local pixels = getIconPixels(iconPath)
		if(pixels) then
			local width, height = dxGetPixelsSize(pixels)
			local iconScale = math.min(thumbSize/width, thumbSize/height)
			iconWidth, iconHeight = width*iconScale, height*iconScale
			iconX, iconY = (itemWidth-iconWidth)/2, (thumbSize-iconHeight)/2
		end
		table.insert(typeList, ID)
		itemTypes[ID] = { name = name, icon = iconPath, 
			iconWidth = iconWidth, iconHeight = iconHeight, iconX = iconX, iconY = iconY }
	end
	if(not inventory[ID]) then
		inventory[ID] = 0
	end
end

function getIconPixels(iconPath)
	local file = fileOpen(iconPath)
	if(file) then
		local pixels = fileRead(file, fileGetSize(file))
		fileClose(file)
		return pixels
	end
	return false
end

addEvent("USGcnr_inventory.receiveInventory", true)
function receiveInventory(newInventory)
	inventory = newInventory
	receivedInventory = true
end
addEventHandler("USGcnr_inventory.receiveInventory", localPlayer, receiveInventory)

addEvent("USGcnr_inventory.updateInventory", true)
function updateInventory(ID, value)
	inventory[ID] = value
end
addEventHandler("USGcnr_inventory.updateInventory", localPlayer, updateInventory)

function openInventory()
	if(not inventoryState) then
		if(not receivedInventory) then
			triggerServerEvent("USGcnr_inventory.requestInventory", localPlayer)
		end
		inventoryState = true
		showCursor(true)
		addEventHandler("onClientRender", root, renderInventory)
	end
end

function hideInventory()
	if(inventoryState) then
		inventoryState = false
		showCursor(false)
		removeEventHandler("onClientRender", root, renderInventory)
	end
end

function toggleInventory()
	if(inventoryState) then
		hideInventory()
	elseif(exports.USGrooms:getPlayerRoom() == "cnr") then
		openInventory()
	end
end
addCommandHandler("inventory", toggleInventory, false, false)

local mouseState = getKeyState("mouse1")
function renderInventory()
	if(not receivedInventory) then return end -- wait for receiving of the inventory
	local post_gui = not isConsoleActive()
	-- render background
	dxDrawRectangle(windowX, windowY, windowWidth, windowHeight, tocolor(0,0,0,200), post_gui)
	dxDrawRectangle(windowX, windowY, windowWidth, 25, tocolor(0,0,0,200), post_gui)
	dxDrawText("Inventory", windowX, windowY, windowX+windowWidth, windowY+25, color_white, 1.3, "default-bold", "center", "center",false,false,post_gui)
	dxDrawRectangle(windowX+panelX, windowY+panelY, panelWidth, panelHeight, tocolor(0,0,0,100),post_gui)
	-- manage input
	local mouse = getKeyState("mouse1")
	local mouseDown = mouse and mouse ~= mouseState
	mouseState = mouse
	local cursorX, cursorY = getCursorPosition()
	cursorX, cursorY = cursorX*screenWidth, cursorY*screenHeight	
	-- render items
	local startX, startY = windowX+panelX, windowY+panelY
	local row, column = 0, 0
	local index = 0
	while row*itemHeight < panelHeight do
		index = index + 1
		local x, y = column*itemWidth, row*itemHeight
		local ID = typeList[index]
		local hovered = cursorX >= startX+x and cursorX <= startX+x+itemWidth and cursorY >= startY+y and cursorY <= startY+y+itemHeight
		local bgColor = slotBGColor
		if(ID and selectedItem == ID) then
			bgColor = selectedSlotBGColor
		elseif(hovered) then
			bgColor = hoveredSlotBGColor
		end		
		dxDrawImage(startX+x+thumbX, startY+y+thumbY, thumbSize, thumbSize, "inventory-slot.png", 0, 0, 0, bgColor, post_gui)
		if(ID) then
			local itemType = itemTypes[ID]
			if(itemType) then
				if(hovered and mouseDown) then
					selectedItem = ID
				end	
				local icon = itemType.icon
				dxDrawImage(startX+x+itemType.iconX, startY+y+itemType.iconY+thumbY, itemType.iconWidth, itemType.iconHeight, icon,0,0,0,color_white,post_gui)
				--dxDrawRectangle(startX+x, startY+y, thumbSize, 15, tocolor(0,0,0,200), post_gui)
				dxDrawText(itemType.name, startX+x, startY+y, startX+x+itemWidth, startY+y+itemHeight, color_white, 1, "default", "left", "top",false,false,post_gui)
				local amount = inventory[ID]
				local amountWidth = dxGetTextWidth(amount)
				dxDrawRectangle(startX+x+itemWidth-amountWidth-5, startY+y+thumbSize, amountWidth+5, 15, tocolor(0,0,0,180), post_gui)
				dxDrawText(amount, startX+x, startY+y, startX+x+itemWidth, startY+y+itemHeight, color_white, 1, "default", "right", "bottom",false,false,post_gui)
			end
		end
		if(x+itemWidth+itemWidth > panelWidth) then
			row = row + 1
			column = 0
		else
			column = column + 1
		end		
	end
	-- render buttons
	local buttonX = windowX+panelX+panelWidth+5
	for i, button in ipairs(buttons) do
		local hovered = cursorX >= buttonX and cursorX <= buttonX+buttonWidth and cursorY >= windowY+button.y and cursorY <= windowY+button.y+buttonHeight
		dxDrawRectangle(buttonX, windowY+button.y, buttonWidth, buttonHeight, color_button, post_gui)
		dxDrawText(button.text, buttonX, windowY+button.y, buttonX+buttonWidth, windowY+button.y+buttonHeight, color_white, 1, hovered and "default-bold" or "default", "center", "center", false, false, post_gui)
		if(hovered and mouseDown and button.click) then
			button.click()
		end
	end
end

function useSelectedItem()
	if(selectedItem) then
		local amountAvailable = inventory[selectedItem]
		if(amountAvailable and amountAvailable > 0) then

		else
			exports.USGmsg:msg("You've ran out of this item!", 255, 0, 0)
		end
	else
		exports.USGmsg:msg("You need to select an item!", 255, 0, 0)
	end
end

buttons = {{text="Use", y = panelY+50, click = useSelectedItem}, {text="Close", y = windowHeight-buttonHeight-20, click = toggleInventory}}