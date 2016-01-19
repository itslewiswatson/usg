function addElement()

	local element = createElement("GNRGUI")
	table.insert(GUIelements,element)

	return element
	
end

--[[ element list

* createWindow(x,y,width,height,relative,text,parent,color)
* createEditBox(x,y,width,height,relative,text,parent,color,clearOnFirstClick,masked,maskedAfterClick)
* createCheckBox(x,y,width,height,relative,text,parent,color,state)
* createLabel(x,y,width,height,relative,text,parent,color)
* createButton(x,y,width,height,relative,text,parent,color)
* createSlider(x,y,width,height,relative,parent,color,options,interpolateBetweenNumbers)
* createGridList(x,y,width,height,relative,parent,color)

* createComboBox(x,y,width,height,relative,text,parent,color, direction)

--]]

function createWindow(x,y,width,height,relative,text,parent,color)
	if x and y and width and height then

		if relative then
	
			x,y = math.max(math.min(x,1),0)*screenWidth,math.max(math.min(y,1),0)*screenHeight
			width,height = math.max(math.min(width,1),0)*screenWidth,math.max(math.min(height,1),0)*screenHeight		
			
		end
		if not color then color = tocolor(0,0,0,190) end
		local element = addElement()
		if parent then setElementParent(element,parent) end
		GUIinfo[element] = { guiType = "window", x = x,y = y, width = width,height = height,text = text or "",color = color, visible = true, 
		resource = sourceResourceRoot }
		return element
		
	end
	
end

function createCheckBox(x,y,width,height,relative,text,parent,color,state)

	if x and y and width and height and text then

		if relative then
	
			x,y = math.max(math.min(x,1),0)*screenWidth,math.max(math.min(y,1),0)*screenHeight
			width,height = math.max(math.min(width,1),0)*screenWidth,math.max(math.min(height,1),0)*screenHeight		
			
		end
		if not color then color = tocolor(0,0,0,190) end
		local element = addElement()
		if parent then setElementParent(element,parent) end
		GUIinfo[element] = { guiType = "checkbox", x = x,y = y, width = width,height = height,text = text,color = color, visible = true, resource = sourceResourceRoot, 
		isChecked = state }
		return element
		
	end

end

function createGridList(x,y,width,height,relative,parent,color)

	if x and y and width and height then

		if relative then
	
			x,y = math.max(math.min(x,1),0)*screenWidth,math.max(math.min(y,1),0)*screenHeight
			width,height = math.max(math.min(width,1),0)*screenWidth,math.max(math.min(height,1),0)*screenHeight		
			
		end
		if not color then color = tocolor(0,0,0,190) end
		local element = addElement()
		if isElement(parent) then setElementParent(element,parent) end
		GUIinfo[element] = { guiType = "gridlist", x = x,y = y, width = width,height = height,color = color, visible = true, resource = sourceResourceRoot, 
		scroll = 0, columns = {}, rows = {}, scrollPixels=50 }
		return element
		
	end

end

function gridlistAddColumn(gridlist,text,width)

	if isElement(gridlist) and GUIinfo[gridlist] then
	
		local columnsWidth = 0
		for i=1,#GUIinfo[gridlist].columns do
		
			columnsWidth = columnsWidth + GUIinfo[gridlist].columns[i].width
		end
		if columnsWidth + width > 1 then
		
			width = 1-columnWidth
			if width <= 0 then return false end
		
		end
		table.insert( GUIinfo[gridlist].columns, { text = text, width = width } )
		return #GUIinfo[gridlist].columns
		
	end

end

function gridlistAddRow(gridlist)

	if isElement(gridlist) and GUIinfo[gridlist] then
	
		table.insert( GUIinfo[gridlist].rows, { sortIndex = #GUIinfo[gridlist].rows+1 } )
		for i=1,#GUIinfo[gridlist].columns do
			table.insert( GUIinfo[gridlist].rows[#GUIinfo[gridlist].rows], { } )
		end
		return #GUIinfo[gridlist].rows
	
	end

end

function createEditBox(x,y,width,height,relative,text,parent,color,clearOnFirstClick,masked,maskedAfterClick)
	if x and y and width and height and text then

		if relative then
	
			x,y = math.max(math.min(x,1),0)*screenWidth,math.max(math.min(y,1),0)*screenHeight
			width,height = math.max(math.min(width,1),0)*screenWidth,math.max(math.min(height,1),0)*screenHeight		
			
		end
		if not color then color = tocolor(0,0,0,190) end
		local element = addElement()
		if isElement(parent) then setElementParent(element,parent) end
		local guiElement = guiCreateEdit(x,y,width,height,text,false)
		setElementParent(guiElement,element)
		--guiSetAlpha(guiElement,0)
		guiEditSetMasked(guiElement,masked or false)
		GUIinfo[element] = { guiType = "editbox", x = x,y = y, width = width,height = height,text = text,color = color, 
		visible = true, resource = sourceResourceRoot, realEdit = guiElement, scroll = 0,
		clearOnClick = clearOnFirstClick, masked = masked, maskedAfterClick = maskedAfterClick, caretIndex = 0, renderTarget = dxCreateRenderTarget(width,height,true) }
		return element
		
	end
	
end

function createLabel(x,y,width,height,relative,text,parent,color)
	if x and y and width and height and text then

		if relative then
	
			x,y = math.max(math.min(x,1),0)*screenWidth,math.max(math.min(y,1),0)*screenHeight
			width,height = math.max(math.min(width,1),0)*screenWidth,math.max(math.min(height,1),0)*screenHeight		
			
		end
		if not color then color = tocolor(255,255,255,255) end
		local element = addElement()
		if parent then setElementParent(element,parent) end
		GUIinfo[element] = { guiType = "label", x = x,y = y, width = width,height = height,text = text,color = color, visible = true, textScale,
		resource = sourceResourceRoot, renderTarget = dxCreateRenderTarget(width,height,true) }
		return element
		
	end
	
end

function createButton(x,y,width,height,relative,text,parent,color)
	if x and y and width and height and text then

		if relative then
	
			x,y = math.max(math.min(x,1),0)*screenWidth,math.max(math.min(y,1),0)*screenHeight
			width,height = math.max(math.min(width,1),0)*screenWidth,math.max(math.min(height,1),0)*screenHeight		
			
		end
		if not color then color = tocolor(0,0,0,190) end
		local element = addElement()
		if isElement(parent) then setElementParent(element,parent) end
		GUIinfo[element] = { guiType = "button", x = x,y = y, width = width,height = height,text = text,color = color, visible = true, 
		resource = sourceResourceRoot }
		return element
		
	end
	
end

function createSlider(x,y, width,height,relative,parent,color,options,interpolateBetweenNumbers, optionSize, selOptionSize)

	if x and y and width and height and options[1] and options[2] then

		if relative then
	
			x,y = math.max(math.min(x,1),0)*screenWidth,math.max(math.min(y,1),0)*screenHeight
			width,height = math.max(math.min(width,1),0)*screenWidth,math.max(math.min(height,1),0)*screenHeight		
			
		end
		if not color then color = tocolor(0,0,0,190) end
		local element = addElement()
		if interpolateBetweenNumbers then
		
			for i=1,#options do
			
				if type(options[i]) ~= "number" then
				
					interpolateBetweenNumbers = false
				
				end
				
			end
		
		end
		if isElement(parent) then setElementParent(element,parent) end
		GUIinfo[element] = { guiType = "slider", x = x,y = y, width = width,height = height,color = color, visible = true, options = options,
		interpolateNumbers = interpolateBetweenNumbers,resource = sourceResourceRoot, optionSize = optionSize or 16, selOptionSize = selectedOptionSize or 10
				}
		return element
		
	end

end

function createComboBox(x,y,width,height,relative,text,parent,color,direction)

	if x and y and width and height and ( not text or type(text) == "string" ) then

		if relative then
	
			x,y = math.max(math.min(x,1),0)*screenWidth,math.max(math.min(y,1),0)*screenHeight
			width,height = math.max(math.min(width,1),0)*screenWidth,math.max(math.min(height,1),0)*screenHeight		
			
		end
		if not color then color = tocolor(0,0,0,190) end
		local element = addElement()

		if isElement(parent) then setElementParent(element,parent) end
		GUIinfo[element] = { guiType = "combobox", x = x,y = y, width = width,height = height,color = color, visible = true, options = {},
		resource = sourceResourceRoot, direction = direction or "down", collapsed = true, currentOption = nil }
		return element
		
	end	

end
