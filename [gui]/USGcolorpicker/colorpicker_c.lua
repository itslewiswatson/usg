local ID = 0
local pickers = {}
local screenWidth, screenHeight = guiGetScreenSize()
local pixels = false
local clickRenderTarget = false
local cursorCount = 0
local preview

function setPixels()
	local texture = dxCreateRenderTarget(256,256,false)
	dxSetRenderTarget(texture)
	dxDrawImage(0,0,256,256,"colorpicker.png")
	dxSetRenderTarget()
	pixels = dxGetTexturePixels(texture)
	preview = dxCreateRenderTarget(150,20,false)
	dxSetRenderTarget(preview)
	dxDrawRectangle(0,0,150,20,tocolor(255,255,255))
	dxSetRenderTarget()
	clickRenderTarget = dxCreateRenderTarget(5,5,false)

	removeEventHandler("onClientRender", root, setPixels)
end
addEventHandler("onClientRender", root, setPixels)

function openPicker(text)
	if(not pixels) then return false end
	ID = ID + 1
	local picker = {ID = ID}
	picker.window = exports.USGGUI:createWindow("center", "center", 300, 420, false, "Pick a color")
	picker.label = exports.USGGUI:createLabel(0,0,300,70,false,text,picker.window)
	picker.image = exports.USGGUI:createImage("center", 80, 256, 256, false, ":USGcolorpicker\\colorpicker.png", picker.window)
	picker.clickPosition = exports.USGGUI:createButton(0,0,5,5,false,"",picker.image,tocolor(255,0,0))
	exports.USGGUI:setVisible(picker.clickPosition, false)
	picker.previewImage = exports.USGGUI:createImage("center", 340, 150, 20, false, preview, picker.window)
	picker.OK = exports.USGGUI:createButton(220,380,70,30,false,"OK",picker.window)
		addEventHandler("onUSGGUISClick", picker.OK, onPickColor, false)
	picker.cancel = exports.USGGUI:createButton(10,380,70,30,false,"Cancel",picker.window)
		addEventHandler("onUSGGUISClick", picker.cancel, onCancel, false)
	showCursor(true)
	cursorCount = cursorCount + 1
	exports.USGGUI:focus(picker.window)
	pickers[getResourceRootElement(sourceResource)] = picker
	return ID
end

addEvent("onColorPickerChange")
function onPickerRender()
	for k, picker in pairs(pickers) do
		if(isElement(picker.window) and ( ( picker.color and picker.x and picker.y ) or getKeyState("mouse1") ) ) then
			local windowX, windowY = exports.USGGUI:getPosition(picker.window)
			local imgX, imgY = exports.USGGUI:getPosition(picker.image)
			if(getKeyState("mouse1")) then
				local x, y = windowX+imgX, windowY+imgY
				local sx,sy,_,_,_ = getCursorPosition()
				sx, sy = sx * screenWidth, sy * screenHeight
				local offsetX, offsetY = sx-x, sy-y
				if(offsetX > 0 and offsetY > 0 and offsetX < 256 and offsetY < 256) then
					local r,g,b,a = dxGetPixelColor(pixels,math.floor(offsetX), math.floor(offsetY))
					picker.color = {r,g,b,a}
					exports.USGGUI:setVisible(picker.clickPosition, true)
					exports.USGGUI:setPosition(picker.clickPosition, offsetX-3,offsetY-2)
					triggerEvent("onColorPickerChange", k, picker.ID, r,g,b,a)
				else
					return false
				end
				picker.x = offsetX
				picker.y = offsetY		
			end
			local x, y = windowX+imgX+picker.x, windowY+imgY+picker.y
			exports.USGGUI:setProperty(picker.previewImage, "color", tocolor(unpack(picker.color)))
		elseif not (isElement(picker.window)) then
			pickers[k] = nil
		end
	end
end
addEventHandler("onClientRender", root, onPickerRender)

addEvent("onPickColor")
function onPickColor()
	for k, picker in pairs(pickers) do
		if(source == picker.OK) then
			if(picker.color) then
				local r,g,b,a = unpack(picker.color)
				triggerEvent("onPickColor", k, picker.ID, r,g,b,a)	
				destroyElement(picker.window)
				cursorCount = cursorCount -1
				if(cursorCount <= 0) then
					showCursor(false)
				end
				pickers[k] = nil
			else
				exports.USGmsg:msg("You did not select a color!", 255, 0, 0)
			end
			break
		end
	end
end

function closePicker(ID)
	for k, picker in pairs(pickers) do
		if(picker.ID == ID) then
			destroyElement(picker.window)
			pickers[k] = nil
			cursorCount = cursorCount -1
			if(cursorCount <= 0) then
				showCursor(false)
			end
			break
		end
	end
end

addEvent("onCancelPickColor")
function onCancel()
	for k, picker in pairs(pickers) do
		if(source == picker.cancel) then
			triggerEvent("onCancelPickColor", k, picker.ID)	
			destroyElement(picker.window)
			pickers[k] = nil
			cursorCount = cursorCount -1
			if(cursorCount <= 0) then
				showCursor(false)
			end
			break
		end
	end
end

addEventHandler("onClientResourceStop", root,
	function()
		for res, picker in pairs(pickers) do
			if(source == res) then
				destroyElement(picker.window)
				pickers[k] = nil
				cursorCount = cursorCount -1
				if(cursorCount <= 0) then
					showCursor(false)
				end
				break
			end
		end
	end
)