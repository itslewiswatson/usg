
function err(msg,info)

	defaultErrors = {"Element not found", 'Expected $info at $info, got $info'}

	if type(msg) == 'number' then
	
		msg = defaultErrors[msg]
	
	end
	
	if info and string.find(msg,"$info") then
	
		for i=1,#info do
		
			string.gsub(msg,"$info",info[i])
		
		end
		
	end

	error(msg,3)
	error(msg,2)
	error(msg,1)

end


GUIinfo = {}
GUIelements = {}
onEditDisableControls = true
screenWidth,screenHeight = guiGetScreenSize()
local defaultTextScale = 1
local defaultTextColor = tocolor(255,255,255,255)

leftMouseState = getKeyState("mouse1")
rightMouseState = getKeyState("mouse2")
function gridlistGetSelectedItem(element)

	if not GUIinfo[element] then err(1) return false end
	return GUIinfo[element].selectedRow, GUIinfo[element].selectedColumn

end

function gridlistSetItemText(element, row, column, text)

	if not GUIinfo[element] then err(1) return false end
	if not GUIinfo[element].rows[row] then err("Invalid row") return false end
	if not GUIinfo[element].rows[row][column] then err("Invalid column") return false end
	if type(text) ~= "string" then err(2,{"string","argument 'text'",type(text)..":"..tostring(text)}) return false end
		
	GUIinfo[element].rows[row][column][1] = text
	
end

function gridlistGetItemText(element, row, column)

	if not GUIinfo[element] then err(1) return false end
	if not GUIinfo[element].rows[row] then err("Invalid row") return false end
	if not GUIinfo[element].rows[row][column] then err("Invalid column") return false end
	
	return GUIinfo[element].rows[row][column][1]
		
end

function gridlistSetItemData(element, row, column, data)

	if not GUIinfo[element] then err(1) return false end
	if not GUIinfo[element].rows[row] then err("Invalid row") return false end
	if not GUIinfo[element].rows[row][column] then err("Invalid column") return false end
	
	GUIinfo[element].rows[row][column][2] = data

end

function gridlistGetItemData(element, row, column)

	if not GUIinfo[element] then err(1) return false end
	if not GUIinfo[element].rows[row] then err("Invalid row") return false end
	if not GUIinfo[element].rows[row][column] then err("Invalid column") return false end
	
	return GUIinfo[element].rows[row][column][2]
	
end

function gridlistSetItemColor(element, row, column, color)
	
	if not GUIinfo[element] then err(1) return false end
	if not GUIinfo[element].rows[row] then err("Invalid row") return false end
	if column == nil then err("Invalid column") return false end
	if type(color) ~= 'number' then err(2,{"color ( number )","argument 'color'",type(color)..":"..tostring(color)}) return false end
	
	if column then
		
		GUIinfo[element].rows[row][column].textColor = color
			
	else

		for i=1,#GUIinfo[element].rows[row] do
			
			GUIinfo[element].rows[row][i].textColor = color
			
		end
		
	end

end

function gridlistGetItemColor(element, row, column)

	if not GUIinfo[element] then err(1) return false end
	if not GUIinfo[element].rows[row] then err("Invalid row") return false end
	if not GUIinfo[element].rows[row][column] then err("Invalid column") return false end
		
	local column = column or 1

	return GUIinfo[element].rows[row][column].textColor

end

function gridlistSetSelectionMode(element, mode)

	if not GUIinfo[element] then err(1) return false end
	if type(mode) ~= 'number' then err(2,{"number","argument 'mode'",type(mode)..":"..tostring(mode)}) return false end
	
	GUIinfo[element].selectionMode = mode

end

function getCheckBoxState(element)

	if not GUIinfo[element] then err(1) return false end
	
	return GUIinfo[element].isChecked
	
end

function getSliderSelectedOption(element) -- returns index, value

	if not GUIinfo[element] then err(1) return false end
	
	local key = GUIinfo[element].selection
	local value
	if not key then
	
		value = GUIinfo[element].interpolatedNumber
		
	else
	
		value = GUIinfo[element].options[GUIinfo[element].selection]
	
	end
	return key, value
	
end

function setText(element,newText)

	if not newText then err(1) return false end
	if not GUIinfo[element] then err(1) return false end
	
	GUIinfo[element].text = tostring(newText)

end

function getText(element)

	if not GUIinfo[element] then err(1) return false end
	
	return GUIinfo[element].text

end

function getVisible(element)

	if not GUIinfo[element] then err(1) return false end
	
	return GUIinfo[element].visible

end

function setControlsEnabledWhileEditing(newState)

	onEditDisableControls = newState

end

function setVisible(element,state)

	if not GUIinfo[element] then err(1) return false end
	
	if state ~= false and state ~= true then state = not GUIinfo[element].visible end
	GUIinfo[element].visible = state
	if GUIinfo[element].guiType == "checkbox" then
	
		guiSetVisible(GUIinfo[element].realEdit,state)
	
	end

end

function removeElementFromTable(element,theTable)
	
	for i=1,#theTable do
	
		if theTable[i] == element then
		
			table.remove(theTable,i)
			return true
			
		end
		
	end
	
	return false

end

function bringToFront(element)

	if not GUIinfo[element] then err(1) return false end
	
	removeElementFromTable(element,GUIelements)
	table.insert(GUIelements, element)
	
end

function moveToBack(element)

	if not GUIinfo[element] then err(1) return false end
	
	removeElementFromTable(element,GUIelements)
	table.insert(GUIelements, 1, element)
	
end

function moveWithEffect(element,newX,newY,easingFunc,moveTime)

	if not GUIinfo[element] then err(1) return false end
	if type(newX) ~= 'number' then err(2,{"number","argument 'newX'",type(newX)..":"..tostring(newX)}) return false end
	if type(newY) ~= 'number' then err(2,{"number","argument 'newY'",type(newY)..":"..tostring(newY)}) return false end
	
	GUIinfo[element].moveTo = { orgX = GUIinfo[element].x, orgY = GUIinfo[element].y, movex = newX, movey = newY, easing = easingFunc or "Linear", startTime = getTickCount(), moveTime = ( moveTime or 3000  ) }
	
end


function resizeWithEffect(element,newWidth,newHeight,easingFunc,resizeTime)

	if not GUIinfo[element] then err(1) return false end
	if type(newWidth) ~= 'number' then err(2,{"number","argument 'newWidth'",type(newWidth)..":"..tostring(newWidth)}) return false end
	if type(newHeight) ~= 'number' then err(2,{"number","argument 'newHeight'",type(newHeight)..":"..tostring(newHeight)}) return false end	
	
	GUIinfo[element].resizeTo = { orgX = GUIinfo[element].width, orgY = GUIinfo[element].height,sizex = newWidth, sizey = newHeight, easing = easingFunc or "Linear", startTime = getTickCount(),resizeTime = ( resizeTime or 3000 ) }

end

function comboBoxAddOption(element, text, ID)

	if type(text) ~= "string" then err(2,{"string","argument 'text'",type(text)..":"..tostring(text)}) return false end
	if not GUIinfo[element] then err(1) return false end

	if type(ID) ~= "number" then ID = #GUIinfo[element].options+1 end
	table.insert(GUIinfo[element].options,ID,text)
		
end

function comboBoxGetCurrentOption(element)

	if not GUIinfo[element] then err(1) return false end
	
	return GUIinfo[element].currentOption, GUIinfo[element].options[GUIinfo[element].currentOption]
	
end


function comboBoxSetCurrentOption(element,optionID)

	if not GUIinfo[element] then err(1) return false end
	if not GUIinfo[element].options[optionID] then err("Option ID invalid") return false end
	
	GUIinfo[element].currentOption = optionID
	
end

function comboBoxGetOptions(element)

	if not GUIinfo[element] then return false end

	return GUIinfo[element].options
	
end

function comboBoxRemoveOption(element,ID)

	if type(ID) ~= "number" then err(2,{"number","argument 'ID'",type(ID)..":"..tostring(ID)}) return false end
	if not GUIinfo[element] then err(1) return false end
	
	table.remove(GUIinfo[element].options,ID)
	
end

function setTextScale(element,scale)

	if not GUIinfo[element] then err(1) return false end
	if not type(scale) == 'number' then err("Invalid text scale, use a number") return false end
	if scale <= 0 then err("Text scale too small") return false end
	GUIinfo[element].textScale = scale
end

function getTextScale(element)

	if not GUIinfo[element] then err(1) return false end
	return GUIinfo[element].textScale
end

function drawElementsOnRender(element)

	for elementID=1,#GUIelements do
	
		local element = GUIelements[elementID]
	--	if not element then break end
		local info = GUIinfo[element]	
		local parentInfo = GUIinfo[getElementParent(element)]
		
		if info.visible and ( not parentInfo or parentInfo.visible ) then
		
			if info.moveTo then
			
				local ticks = getTickCount()
				local progress = (ticks-info.moveTo.startTime)/info.moveTo.moveTime
				info.x, info.y,_ = interpolateBetween(info.moveTo.orgX,info.moveTo.orgY,0,info.moveTo.movex,info.moveTo.movey, 0, progress, info.moveTo.easing)
				if progress >= 1 then
				
					info.moveTo = nil
					
				end
			
			end		
			if info.resizeTo then
			
				local ticks = getTickCount()
				local progress = (ticks-info.resizeTo.startTime)/info.resizeTo.resizeTime
				info.width, info.height,_ = interpolateBetween(info.resizeTo.orgX,info.resizeTo.orgY,0,info.resizeTo.sizex,info.resizeTo.sizey, 0, progress, info.resizeTo.easing)
				if progress >= 1 then
				
					info.resizeTo = nil
					
				end
			
			end
			local x,y = info.x, info.y
			local textColor = info.textColor or defaultTextColor
			if parentInfo then
				x,y = parentInfo.x+x,parentInfo.y+y
			end			
			
			if info.guiType == "window" then

				dxDrawRectangle(x, y-23, info.width, 20, info.color)
				dxDrawRectangle(x, y, info.width, info.height, info.color)
				dxDrawText(info.text,x,y-23,x+info.width,y-3,textColor, defaultTextScale+0.2,"default",'center','center',true,false)	

			elseif info.guiType == "button" then

				dxDrawRectangle(x, y, info.width, info.height, info.color)
				dxDrawText(info.text,x,y,x+info.width,y+info.height,textColor, defaultTextScale,"default",'center','center',true,true)		
			
			elseif info.guiType == "label" then

				dxDrawText(info.text,x,y,x+info.width,y+info.height,textColor, info.textScale or defaultTextScale,"default",'center','center',true,true)			
				
			elseif info.guiType == "editbox" then
			
				info.text = guiGetText(info.realEdit)
				guiSetPosition(info.realEdit,x,y,false)
				guiSetSize(info.realEdit,info.width,info.height,false)
				--guiBringToFront(info.realEdit)
				local text = info.text
				--dxDrawRectangle(x, y, info.width, info.height, info.color,false)
				if info.masked then text = string.rep("*",#text) end
				--[[
				local textToDraw = getTextBeingDrawnIntoEdit(text,info.scroll, scrollEnd or #text, info.width-4)
				
				guiSetPosition(info.realEdit,x,y,false)
				guiSetSize(info.realEdit,info.width, info.height,false)
				
				dxDrawText(textToDraw,x+4,y,x+info.width-8,y+info.height,textColor, defaultTextScale,"default",'left','center',false,false)		
				--draw caret

				if editInFocus == element then
				
					local width = dxGetTextWidth(text)
					dxDrawLine( math.min(x+info.width-2,x+4+width),y+3, math.min(x+info.width-2,x+4+width), y+19, tocolor( 255,255,255,255), 0.5 )
				
				end
				--]]
				
			elseif info.guiType == 'gridlist' then
			
				local startRow = info.scrollRow
				local columns = info.columns
				dxDrawRectangle(x,y,info.width, 20, info.color) -- column bar
				dxDrawRectangle(x,y+21,info.width,info.height-21, info.color) -- background for rows
				local rows = info.rows
				table.sort(rows, function (a,b) return a.sortIndex < b.sortIndex end )
				for row=1,#rows do
				
					if info.selectedRow == row and not info.selectedColumn  then 
						dxDrawRectangle(x, y+1+((row)*20), info.width, 20, tocolor(50,50,100,200)) -- selected row color
					end
					
					local width = 0
					for i=1,#columns do	
				
						local columnX, columnY, columnWidth = x+width, y, (columns[i].width*info.width)
						width = width + (columns[i].width*info.width)
						if row == 1 then -- draw column header
							dxDrawText(columns[i].text,columnX+5,columnY,columnX+columnWidth,columnY+20,textColor, defaultTextScale,"default",'left','center',false,false)
							if i ~= #columns then
								dxDrawLine( columnX+columnWidth,columnY+2, columnX+columnWidth, columnY+16, tocolor( 255,255,255,255), 0.5 )
							end							
						end
						
						if rows[row][i] then
						
							if info.selectedRow == row and info.selectedColumn == i then
							
								dxDrawRectangle(columnX, columnY+1+((row)*20), columnWidth, 20, tocolor(50,50,100,200)) -- selected row+column color
								
							end
							local rowColor = rows[row][i].textColor or defaultTextColor
							if rows[row][i][1] then
								dxDrawText(rows[row][i][1],columnX+5, columnY+21+((row-1)*20), columnX+columnWidth, 20+columnY+21+((row-1)*20),rowColor, defaultTextScale*0.95,"default",'left','center',false,false) -- row text
							end
							
						end			
						
					end
					
				end
					
			elseif info.guiType == "checkbox" then
				
				local checkboxX, checkboxY, checkboxWidth,checkboxHeight = x,y+(info.height-15)/2, 15,15
				
				dxDrawRectangle(checkboxX, checkboxY, checkboxWidth,checkboxHeight,info.color)
				dxDrawText(info.text,x+20,y,x+info.width-15,y+info.height,textColor, defaultTextScale,"default",'left','center',false,false)
				if info.isChecked then
					
					dxDrawLine(checkboxX+1,checkboxY+1,checkboxX+checkboxWidth-2, checkboxY+checkboxHeight-2, tocolor(255,255,255,255),0.6)
					dxDrawLine(checkboxX+1,checkboxY+checkboxHeight-2,checkboxX+checkboxWidth-2, checkboxY+1, tocolor(255,255,255,255),0.6)
					
				end
				
			elseif info.guiType == "slider" then
			
				dxDrawLine( x, y+(info.height/2), x+info.width, y+(info.height/2), info.color, 1 ) -- draw line
				local spaceBetweenOptions = (info.width-info.optionSize)/(#info.options-1)
				for i=1,#info.options do
				
					local opX,opY = sliderGetOptionPosition(element,i)
					dxDrawText(tostring(info.options[i]),opX+2, opY-22,opX+14, opY-10,textColor, defaultTextScale,"default",'center','center',false,false)
					dxDrawRectangle(opX,opY-(info.optionSize/2), info.optionSize, info.optionSize,info.color ) -- draw option rectangle
				
				end

				if info.selectionPos then
				
					local interpolatedNumber = info.interpolatedNumber
					local _,opY = sliderGetOptionPosition(element,info.selectionPos)
					dxDrawRectangle(x+info.selectionPos,opY-(info.selOptionSize/2), info.selOptionSize, info.selOptionSize, tocolor(255,255,255,255) )
					dxDrawText(tostring(interpolatedNumber), x+info.selectionPos, opY-(info.selOptionSize/2)-20,x+info.selectionPos+info.selOptionSize, opY-(info.selOptionSize/2),textColor, defaultTextScale,"default",'center','center',false,false)
					
				elseif info.selection then 
				
					local opX,opY = sliderGetOptionPosition(element,info.selection)
					dxDrawRectangle(opX+3,opY-(info.selOptionSize/2), info.selOptionSize, info.selOptionSize, tocolor(255,255,255,255) )
				
				end
				
			elseif info.guiType == "combobox" then
			
				dxDrawRectangle(x,y,info.width,info.height,info.color)
				if info.currentOption then
					dxDrawText(info.options[info.currentOption],x,y,x+info.width,y+info.height,textColor, defaultTextScale,"default",'center','center',false,false)
				end
				dxDrawBorderAroundRectangle(x,y,info.width,info.height,nil, info.color)
				if not info.collapsed then
					local optionSizeX,optionSizeY = info.width,info.height
					for ID=1,#info.options do
				
						if ID ~= info.currentOption then
				
						local optionText = info.options[ID]
						if info.currentOption and ID > info.currentOption then ID = ID - 1 end	
						local optionX,optionY = x,y+(ID*info.height)
						if info.direction == "up" then
					
							optionX,optionY = x,y-(ID*optionSizeY)

						end
					
						dxDrawRectangle(optionX,optionY,optionSizeX,optionSizeY,info.color)
						dxDrawText(optionText,optionX,optionY,optionX+optionSizeX,optionY+optionSizeY,textColor, defaultTextScale,"default",'center','center',false,false)
						if ID ~= 1 then
							if info.direction == 'down' then dxDrawLine(optionX+3,optionY,optionX+optionSizeX-6,optionY,tocolor(255,255,255,255))
							else dxDrawLine(optionX+3,optionY+optionSizeY,optionX+optionSizeX-6,optionY+optionSizeY,tocolor(255,255,255,255)) end
						end
						
						end
					
					end
				
				end
				
			end
	
		end
		
	end
	
end

function dxDrawBorderAroundRectangle(x,y,width,height,lineWidth,color)

	if not lineWidth then lineWidth = 1.75 end
	local width = width - 1
	if not color then color = tocolor( 255,255,255,255) end
	dxDrawLine(x,y,x+width,y,color,lineWidth)
	dxDrawLine(x,y,x,y+height,color,lineWidth)
	dxDrawLine(x+width,y,x+width,y+height,color,lineWidth)
	dxDrawLine(x,y+height,x+width,y+height,color,lineWidth)

end

function sliderGetOptionPosition(slider,option)

	local sliderInfo = GUIinfo[slider]
	if not sliderInfo then return false end
	local x,y = sliderInfo.x, sliderInfo.y
	local parentInfo = GUIinfo[getElementParent(slider)]
	if parentInfo then
		x,y = parentInfo.x+x,parentInfo.y+y
	end			
	local spaceBetweenOptions = (sliderInfo.width-16)/(#sliderInfo.options-1)
	return x+(option-1)*spaceBetweenOptions, y+(sliderInfo.height/2),(option-1)*spaceBetweenOptions

end

function getTextBeingDrawnIntoEdit(text,scroll, scrollEnd, maxWidth)

	local textToDraw = ""
	local length = 0
	local textSeperated = {}
	for char in text:gmatch ( "." ) do 
		table.insert( textSeperated, char ) 
	end

	for i=scroll,scrollEnd do
	
		if textSeperated[i] then
	
			local width = dxGetTextWidth(textSeperated[i])
			if width + length < maxWidth then
			
				textToDraw = textToDraw..textSeperated[i]
				length = length + width
				
			end
			
		end
		
	end

	return textToDraw	

	--return string.sub(text,scroll, scrollEnd)

end

function getTextExtentUntilCaret(text,caretIndex)

	local length = 0
	local textSeperated = {}
	for char in text:gmatch ( "." ) do 
		table.insert( textSeperated, char ) 
	end

	for i=1,caretIndex do
	
		if textSeperated[i] then
	
			local width = dxGetTextWidth(textSeperated[i])
			length = width + length
			
		end
		
	end

	return length

end

function destroyGUIElement(theElement)

	if theElement then
	
		local children = getElementChildren(theElement)
		for i, element in pairs(children) do
			destroyGUIOnElementDestroyed(element)
		end

		GUIinfo[theElement] = nil 
		removeElementFromTable(theElement,GUIelements)	
	
	end
	
end

function destroyGUIOnElementDestroyed()
	if GUIinfo[source] then	
		destroyGUIElement(source)	
	end
end

addEventHandler("onClientResourceStop", root,
function ()
	for element,info in pairs(GUIinfo) do	
		if info.resource == source then 		
			GUIinfo[element] = nil
			removeElementFromTable(element,GUIelements)
			local children = getElementChildren(element)
			for i=1,#children do
				GUIinfo[children[i]] = nil
				removeElementFromTable(children[i],GUIelements)
				destroyElement(children[i])
			end
			destroyElement(element)
		end	
	end
end
)

addEventHandler('onClientResourceStart', resourceRoot,
function ()

	addEventHandler('onClientRender', root, drawElementsOnRender )
	addEventHandler('onClientRender', root, manageMouseOnRender )
	addEventHandler('onClientElementDestroy', root, destroyGUIOnElementDestroyed )
	dxSetBlendMode("overwrite")

end)
