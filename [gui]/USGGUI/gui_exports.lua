function err(msg,info)
	defaultErrors = {"Element not found", 'Expected $info1 at $info2, got $info3'}
	if type(msg) == 'number' then
		msg = defaultErrors[msg]	
	end
	if info and string.find(msg,"$info") then	
		for i=1,#info do		
			msg = string.gsub(msg,"$info"..i,info[i])		
		end
	end
	local debugInfo = debug.getinfo(2) or {}
	local file = debugInfo['source'] or ''
	local line = debugInfo['linedefined'] or ''
	local func = debugInfo['what'] or ''
	local errString = file..": "..line..": "..func
	--outputDebugString(errString..msg,2)
	error(msg,3)
	--error(msg,2)
	--error(msg,1)
end

function getType(element)
	if (element == nil) or not GUIinfo[element] then err(1) return false end	
	return GUIinfo[element].guiType
end

function setDefaultTextAlignment(x,y)
	if ( x ~= "left" and x ~= "right" and x ~= "center" ) then err(2,{"string(left,right,center)","argument 'x'",type(x)..": "..tostring(x)}) return false end
	if ( y ~= "top" and y ~= "bottom" and y ~= "center" ) then err(2,{"string(top,bottom,center)","argument 'y'",type(y)..": "..tostring(y)}) return false end
	defaultTextAlignments[sourceResource] = {x=x,y=y}
	return true
end

function setTextAlignment(element,x,y)
	if (element == nil) or not GUIinfo[element] then err(1) return false end	
	if ( x ~= "left" and x ~= "right" and x ~= "center" ) then err(2,{"string(left,right,center)","argument 'x'",type(x)..": "..tostring(x)}) return false end
	if ( y ~= "top" and y ~= "bottom" and y ~= "center" ) then err(2,{"string(top,bottom,center)","argument 'y'",type(y)..": "..tostring(y)}) return false end
	GUIinfo[element].textXAlignment = x
	GUIinfo[element].textYAlignment = y
	return true
end

function setReadOnly(element, readonly)
	if (element == nil) or not GUIinfo[element] then err(1) return false end
	local info = GUIinfo[element]
	if ( readonly ~= true and readonly ~= false ) then err(2,{"bool","argument 'readonly'",type(readonly)..": "..tostring(readonly)}) return false end
	info.readOnly = readonly
	return true
end

function setEnabled(element, state)
	if (element == nil) or not GUIinfo[element] then err(1) return false end	
	if ( state ~= true and state ~= false ) then err(2,{"bool","argument 'state'",type(state)..": "..tostring(state)}) return false end
	GUIinfo[element].disabled = not state
	return true
end

function setProperty(element,key,value)
	if (element == nil) or not GUIinfo[element] then err(1) return false end	
	if ( type(key) ~= "string" ) then err(2,{"string","argument 'key'",type(key)..": "..tostring(key)}) return false end
	GUIinfo[element][key] = value
	return true
end

function getProperty(element,key)
	if (element == nil) or not GUIinfo[element] then err(1) return false end	
	if ( type(key) ~= "string" ) then err(2,{"string","argument 'key'",type(key)..": "..tostring(key)}) return false end
	return GUIinfo[element][key]
end

function gridlistSetSelectedItemColor(element, color )
	if (element == nil) or not GUIinfo[element] then err(1) return false end	
	if type(color) ~= "number" then err(2,{"color","argument 'color'",type(color)..": "..tostring(color)}) return false end

	GUIinfo[element].selectedColor = color
	return true
end

function gridlistClear(element, keepSelection)
	if (element == nil) or not GUIinfo[element] then err(1) return false end
	GUIinfo[element].scrollPixels = 0
	GUIinfo[element].rows = {}
	GUIinfo[element].rowCount = 0
	GUIinfo[element].displayedRows = {}
	if not keepSelection then
		GUIinfo[element].selectedRow = false
		GUIinfo[element].selectedColumn = false
		GUIinfo[element].sortColumn = nil
		GUIinfo[element].sortAscending = false
	end
	return true
end

function gridlistRemoveRow(element, row)
	if (element == nil) or not GUIinfo[element] then err(1) return false end
	if(GUIinfo[element].rows[row]) then 
		GUIinfo[element].rows[row] = nil
		if(row == GUIinfo[element].selectedRow) then
			GUIinfo[element].selectedRow = nil
			GUIinfo[element].selectedColumn = nil
		end
		return true
	else
		err("Invalid row")
		return false
	end
end

function gridlistGetSelectedItem(element)
	if (element == nil) or not GUIinfo[element] then err(1) return false end	
	return GUIinfo[element].selectedRow, GUIinfo[element].selectedColumn
end

function gridlistSetItemText(element, row, column, text)
	if (element == nil) or not GUIinfo[element] then err(1) return false end	
	if not GUIinfo[element].rows[row] then err("Invalid row") return false end
	if not GUIinfo[element].rows[row][column] then err("Invalid column") return false end
	if type(text) ~= "string" then err(2,{"string","argument 'text'",type(text)..": "..tostring(text)}) return false end
		
	GUIinfo[element].rows[row][column][1] = text
	return true
end

function gridlistGetItemText(element, row, column)
	if (element == nil) or not GUIinfo[element] then err(1) return false end	
	if not GUIinfo[element].rows[row] then err("Invalid row") return false end
	if not GUIinfo[element].rows[row][column] then err("Invalid column") return false end
	
	return GUIinfo[element].rows[row][column][1]
end

function gridlistSetItemData(element, row, column, data)
	if (element == nil) or not GUIinfo[element] then err(1) return false end	
	if not GUIinfo[element].rows[row] then err("Invalid row") return false end
	if not GUIinfo[element].rows[row][column] then err("Invalid column") return false end
	
	GUIinfo[element].rows[row][column][2] = data
	return true
end

function gridlistGetItemData(element, row, column)
	if (element == nil) or not GUIinfo[element] then err(1) return false end	
	if not GUIinfo[element].rows[row] then err("Invalid row") return false end
	if not GUIinfo[element].rows[row][column] then err("Invalid column") return false end
	
	return GUIinfo[element].rows[row][column][2]	
end

function gridlistSetItemColor(element, row, column, color)	
	if (element == nil) or not GUIinfo[element] then err(1) return false end	
	if not GUIinfo[element].rows[row] then err("Invalid row") return false end
	if column == nil then err("Invalid column") return false end
	if type(color) ~= 'number' then err(2,{"color ( number )","argument 'color'",type(color)..": "..tostring(color)}) return false end
	
	if column then		
		GUIinfo[element].rows[row][column].textColor = color			
	else
		for i=1,#GUIinfo[element].rows[row] do			
			GUIinfo[element].rows[row][i].textColor = color			
		end		
	end
	return true
end

function gridlistGetItemColor(element, row, column)
	if (element == nil) or not GUIinfo[element] then err(1) return false end	
	if not GUIinfo[element].rows[row] then err("Invalid row") return false end
	if not GUIinfo[element].rows[row][column] then err("Invalid column") return false end
		
	local column = column or 1

	return GUIinfo[element].rows[row][column].textColor
end

function gridlistSetItemSortIndex(element, row, column, index)
	if (element == nil) or not GUIinfo[element] then err(1) return false end	
	if not GUIinfo[element].rows[row] then err("Invalid row") return false end
	if column == nil then err("Invalid column") return false end
	if type(index) ~= 'number' then err(2,{"sort index ( number )","argument 'index'",type(index)..": "..tostring(index)}) return false end
	
	if column then		
		GUIinfo[element].rows[row][column].sortIndex = index			
	else
		for i=1,#GUIinfo[element].rows[row] do			
			GUIinfo[element].rows[row][i].sortIndex = index			
		end		
	end
	return true
end

function gridlistSetSelectionMode(element, mode)
	if (element == nil) or not GUIinfo[element] then err(1) return false end	
	if type(mode) ~= 'number' then err(2,{"number","argument 'mode'",type(mode)..": "..tostring(mode)}) return false end
	
	GUIinfo[element].selectionMode = mode
	return true
end

function gridlistGetRowCount(element)
	if (element == nil) or not GUIinfo[element] then err(1) return false end	
	return #GUIinfo[element].rows
end

function getCheckBoxState(element)
	if (element == nil) or not GUIinfo[element] then err(1) return false end	
	return GUIinfo[element].isChecked	
end

function setCheckBoxState(element,state)
	if (element == nil) or not GUIinfo[element] then err(1) return false end	
	if ( state == true or state == false ) then
		GUIinfo[element].isChecked = state
		return true
	else
		err(2,{"bool","argument 'state'",type(state)..": "..tostring(state)})
		return false
	end
end

function getRadioButtonState(element)
	if (element == nil) or not GUIinfo[element] then err(1) return false end	
	return GUIinfo[element].selected
end

function setRadioButtonState(element, state)
	if (element == nil) or not GUIinfo[element] then err(1) return false end	
	if(state == true) then
		selectRadioButton(element)
	elseif(state == false) then
		GUIinfo[element].selected = false
	else
		err(2,{"bool","argument 'state'", type(state)..": "..tostring(state)})
		return false
	end
end

function getSliderSelectedOption(element) -- returns index, value
	if (element == nil) or not GUIinfo[element] then err(1) return false end	
	local key = GUIinfo[element].selection
	local value
	if not key then	
		value = GUIinfo[element].interpolatedNumber		
	else	
		value = GUIinfo[element].options[GUIinfo[element].selection]	
	end
	return key, value	
end

function setSliderSelectedOption(element,nValue,interpolated)
	if (element == nil) or not GUIinfo[element] then err(1) return false end	
	if type(nValue) ~= 'number' then err(2,{"number","argument 'newValue'",type(nValue)..": "..tostring(nValue)}) return false end
	local slider = GUIinfo[element]
	if ( not interpolated ) then
		if ( slider.options[nValue] ) then
			slider.selection = nValue
			slider.selectionPos = false
			return true
		else
			err("Invalid slider option") 
			return false
		end
	else
		local selectionSet = false
		local startOption
		local endOption
		local posX = 0
		for i=1,#slider.options do
			local opX, opY = sliderGetOptionPosition(element, i)
			local val = slider.options[i]
			if ( nValue == val ) then
				slider.selection = i
				selectionSet = true
				slider.selectionPos = nil
				return true
			elseif ( nValue > val ) then
				startOption = i
				posX = posX+opX
			elseif ( nValue < val ) then
				endOption = i
				break
			end
		end
		if ( startOption and endOption and not selectionSet ) then
			local startVal = slider.options[startOption]
			local total = slider.options[endOption]-startVal
			local val = nValue-startVal
			slider.selection = false
			local spaceBetweenOptions = (slider.width-16)/(#slider.options-1)
			slider.selectionPos = posX+((val/(total))*spaceBetweenOptions)
			slider.interpolatedNumber = nValue
			return true
		end
	end
	return false
end


function setTextColor(element,newColor)
	if not newColor then err(1) return false end
	if (element == nil) or not GUIinfo[element] then err(1) return false end	
	GUIinfo[element].textColor = newColor
	return true
end

function getTextColor(element)
	if (element == nil) or not GUIinfo[element] then err(1) return false end	
	return GUIinfo[element].textColor
end

function setScrollBarColor(element,bg,thumb)
	local info = GUIinfo[element]
	if not info then err(1) return false end	
	if ( info.scrollBarProperties ) then
		info.scrollBarProperties.bgcolor = bg
		info.scrollBarProperties.thumbcolor = thumb
		return true
	else
		err("Only scrollareas and gridlists have scrollbars!")
		return false
	end
end

function setPosition(element,x,y,relative)
	local info = GUIinfo[element]
	if not info then err(1) return false end
	if type(x) ~= 'number' then err(2,{"number","argument 'x'",type(x)..": "..tostring(x)}) return false end
	if type(y) ~= 'number' then err(2,{"number","argument 'y'",type(y)..": "..tostring(y)}) return false end	
	local x,y,_,_ = getDimensionsData(element,x,y,info.width,info.height,relative)
	info.x,info.y = x,y
	return x,y
end

function getPosition(element,relative)
	local info = GUIinfo[element]
	if not info then err(1) return false end
	return info.x,info.y
end

function setSize(element,width,height,relative)
	local info = GUIinfo[element]
	if not info then err(1) return false end
	if type(width) ~= 'number' then err(2,{"number","argument 'width'",type(width)..": "..tostring(width)}) return false end
	if type(height) ~= 'number' then err(2,{"number","argument 'height'",type(height)..": "..tostring(height)}) return false end	
	local _,_,width,height = getDimensionsData(element,info.x,info.y,width,height,relative)
	info.width,info.height = width,height
	return width,height
end

function getSize(element,relative)
	local info = GUIinfo[element]
	if not info then err(1) return false end
	return info.width,info.height
end

function setText(element,newText)
	if not newText then err(1) return false end
	if (element == nil) or not GUIinfo[element] then err(1) return false end	
	GUIinfo[element].text = tostring(newText)
	if ( GUIinfo[element].guiType == "edit" or GUIinfo[element].guiType == "memo" ) then
		if ( GUIinfo[element].caretIndex > #newText ) then
			GUIinfo[element].caretIndex = #newText
		end
	end
	return true
end

function getText(element)
	if (element == nil) or not GUIinfo[element] then err(1) return false end	
	return GUIinfo[element].text
end

function getVisible(element)
	if (element == nil) or not GUIinfo[element] then err(1) return false end	
	return GUIinfo[element].visible
end

function setControlsEnabledWhileEditing(newState)
	onEditDisableControls = newState
end

function setVisible(element,state)
	if (element == nil) or not GUIinfo[element] then err(1) return false end	
	if ( state == nil ) then
		state = not GUIinfo[element].visible
	elseif ( state ~= true and state ~= false ) then
		return false
	end
	GUIinfo[element].visible = state
	local tick = getTickCount()
	onElementVisibilityChange(element, GUIinfo[element].visible)
	return true
end

function onElementVisibilityChange(element, state)
	local info = GUIinfo[element]
	if(state == false and isElement(GUIinfo[element].contentRenderTarget)) then
		destroyElement(GUIinfo[element].contentRenderTarget)
	elseif(state == true and GUIinfo[element].contentRenderTarget ~= nil) then
		if(info.guiType == "gridlist") then
			info.contentRenderTarget = dxCreateRenderTarget(info.width,info.height-22,true)
		else
			info.contentRenderTarget = dxCreateRenderTarget(info.width, info.height, true)
		end
	end
	if(state == false and isElement(GUIinfo[element].renderTarget)) then
		destroyElement(GUIinfo[element].renderTarget)
	elseif(state == true and GUIinfo[element].renderTarget ~= nil) then
		info.renderTarget = dxCreateRenderTarget(info.width, info.height, true)
	end
	local children = getElementChildren(element)
	for i, child in ipairs(children) do
		if(GUIinfo[child]) then
			onElementVisibilityChange(child, state)
		end
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
	if (element == nil or not GUIinfo[element]) then err(1) return false end	
	GUIorder[element] = getTickCount()
end

function moveToBack(element)
	if (element == nil or not GUIinfo[element]) then err(1) return false end	
	GUIorder[element] = 1
end

function moveWithEffect(element,newX,newY,relative, easingFunc,moveTime)
	if (element == nil) or not GUIinfo[element] then err(1) return false end	
	local eW, eH = getSize(element)
	local x,y,w,h = getDimensionsData(element,newX,newY,eW,eH, relative)
	if ( x and y ) then
		GUIinfo[element].moveTo = { orgX = GUIinfo[element].x, orgY = GUIinfo[element].y, movex = x, movey = y, easing = easingFunc or "Linear", startTime = getTickCount(), moveTime = ( moveTime or 3000  ) }	
	else
		return false
	end
	return true
end


function resizeWithEffect(element,newWidth,newHeight,easingFunc,resizeTime)
	if (element == nil) or not GUIinfo[element] then err(1) return false end	
	if type(newWidth) ~= 'number' then err(2,{"number","argument 'newWidth'",type(newWidth)..": "..tostring(newWidth)}) return false end
	if type(newHeight) ~= 'number' then err(2,{"number","argument 'newHeight'",type(newHeight)..": "..tostring(newHeight)}) return false end	
	
	GUIinfo[element].resizeTo = { orgX = GUIinfo[element].width, orgY = GUIinfo[element].height,sizex = newWidth, sizey = newHeight, easing = easingFunc or "Linear", 
		startTime = getTickCount(),resizeTime = ( resizeTime or 3000 ) }
	return true
end

function comboBoxAddOption(element, text, ID)
	if type(text) ~= "string" then err(2,{"string","argument 'text'",type(text)..": "..tostring(text)}) return false end
	if (element == nil) or not GUIinfo[element] then err(1) return false end
	if type(ID) ~= "number" then ID = #GUIinfo[element].options+1 end	
	table.insert(GUIinfo[element].options,ID,text)
	return true
end

function comboBoxGetCurrentOption(element)
	if (element == nil) or not GUIinfo[element] then err(1) return false end	
	return GUIinfo[element].currentOption, GUIinfo[element].options[GUIinfo[element].currentOption]	
end


function comboBoxSetCurrentOption(element,optionID)
	if (element == nil) or not GUIinfo[element] then err(1) return false end	
	if not GUIinfo[element].options[optionID] then err("Option ID invalid") return false end
	
	GUIinfo[element].currentOption = optionID
	return true
end

function comboBoxGetOptions(element)
	if not GUIinfo[element] then return false end

	return GUIinfo[element].options	
end

function comboBoxRemoveOption(element,ID)
	if type(ID) ~= "number" then err(2,{"number","argument 'ID'",type(ID)..": "..tostring(ID)}) return false end
	if (element == nil) or not GUIinfo[element] then err(1) return false end	
	table.remove(GUIinfo[element].options,ID)
	return true
end

function setTextScale(element,scale)

	if (element == nil) or not GUIinfo[element] then err(1) return false end	
	if not type(scale) == 'number' then err("Invalid text scale, use a number") return false end
	if scale <= 0 then err("Text scale too small") return false end
	GUIinfo[element].textScale = scale
	return true
end

function getTextScale(element)
	if (element == nil) or not GUIinfo[element] then err(1) return false end	
	return GUIinfo[element].textScale
end

function focus(element)
	if ( isElement(element) and GUIinfo[element] ) then
		elementInFocus = element
		elementInFocusParents = {}
		local parent = getElementParent(element)
		while ( parent and GUIinfo[parent] ) do
			elementInFocusParents[parent] = true
			parent = getElementParent(parent)
		end
		return true
	end
	return false
end
