defaultTextAlignments = {}

function getDimensionsData(element,x,y,width,height,relative)
	local parent = getElementParent(element)
	local parentWidth,parentHeight = screenWidth,screenHeight
	if isElement(parent) and GUIinfo[parent] then
		parentWidth,parentHeight = GUIinfo[parent].width,GUIinfo[parent].height
	end
	
	if ( x == 'center' ) then
		x = math.floor((parentWidth-width)/2)
	elseif ( x == 'left' ) then
		x = 1
	elseif ( x == 'right' ) then
		x = parentWidth-width
	end
	if ( y == 'center' ) then
		y = math.floor((parentHeight-height)/2)
	elseif ( y == 'top' ) then
		y = 0
	elseif ( y == 'bottom' ) then
		y = parentHeight-height
	end	
	
	if relative then
		x,y = math.max(math.min(x,1),0)*parentWidth,math.max(math.min(y,1),0)*parentHeight
		width,height = math.floor(math.max(math.min(width,1),0)*parentWidth),math.floor(math.max(math.min(height,1),0)*parentHeight)
	end
	return x, y, width, height
end

local initGUI = function (x,y,width,height,relative,parent)
	local element = addElement()
	if isElement(parent) and GUIinfo[parent] then			
		setElementParent(element,parent)
		triggerEvent("onUSGGUIElementBirth",parent,element)
	end
	local x,y,width,height = getDimensionsData(element,x,y,width,height,relative)
	return element, x,y, width, height,false
end

local orderID = 0

function addElement()
	local element = createElement("USGGUI")
	table.insert(GUIelements,element)
	table.insert(GUIvisibleElements,element)
	GUIorder[element] = getTickCount()
	return element
end

--[[ element list

* createScrollArea(x,y,width,height,relative,parent, noScrollBar)
* createWindow(x,y,width,height,relative,text,parent,color)
* createEditBox(x,y,width,height,relative,text,parent,color,clearOnFirstClick,masked,maskedAfterClick)
* createCheckBox(x,y,width,height,relative,text,parent,color,state)
* createLabel(x,y,width,height,relative,text,parent,color)
* createButton(x,y,width,height,relative,text,parent,color)
* createSlider(x,y,width,height,relative,parent,color,options,interpolateBetweenNumbers)
* createGridList(x,y,width,height,relative,parent,color)
* createComboBox(x,y,width,height,relative,text,parent,color, direction)
* createTabPanel(x,y,width,height,relative,parent,color)
* addTab(tabpanel,text)
* createImage(x,y,width,height,relative,path,parent)

//* createTreeView(x,y,width,height,relative,parent)
--]]

function createScrollArea(x,y,width,height,relative,parent, noScrollBar)
	if x and y and width and height then		
		local element, x,y,width,height,ignoreOnRender = initGUI(x,y,width,height,relative,parent)
		if not color then color = tocolor(0,0,0,190) end
		GUIinfo[element] = { guiType = "scrollarea", x = x,y = y, width = width,height = height,color = color, visible = true, 
		resource = sourceResourceRoot, scrollbar = not noScrollBar,ignoreOnRender=ignoreOnRender,
		contentRenderTarget = dxCreateRenderTarget(width,height,true), scrollPixels=0, scrollBarProperties = {} }
		return element
	end
end

function createWindow(x,y,width,height,relative,text,parent,color)
	if x and y and width and height then		
		local element, x,y,width,height,ignoreOnRender,ignoreOnRender = initGUI(x,y,width,height,relative,parent)
		if not color then color = tocolor(0,0,0,190) end
		GUIinfo[element] = { guiType = "window", x = x,y = y, width = width,height = height,text = text or "",color = color, visible = true, 
		resource = sourceResourceRoot, titleBarColor = tocolor(175,75,0,200), textColor = tocolor(0,0,0,200),ignoreOnRender=ignoreOnRender }
		if(not elementInFocus) then -- focus it
			--elementInFocus = element
		end
		return element
	end
end

function createCheckBox(x,y,width,height,relative,text,parent,color,state)
	if x and y and width and height and text then
		local element, x,y,width,height,ignoreOnRender = initGUI(x,y,width,height,relative,parent)
		if not color then color = tocolor(0,0,0,190) end
		GUIinfo[element] = { guiType = "checkbox", x = x,y = y, width = width,height = height,text = text,color = color, visible = true, resource = sourceResourceRoot, 
		isChecked = state,ignoreOnRender=ignoreOnRender}
		return element	
	end
end

function createRadioButton(x,y,width,height,relative,text,parent,color,state)
	if x and y and width and height and text then
		local element, x,y,width,height,ignoreOnRender = initGUI(x,y,width,height,relative,parent)
		if not color then color = tocolor(0,0,0,190) end
		GUIinfo[element] = { guiType = "radiobutton", x = x,y = y, width = width,height = height,text = text,color = color, visible = true, resource = sourceResourceRoot, 
		selected = state,ignoreOnRender=ignoreOnRender}
		return element
	end
end

function createGridList(x,y,width,height,relative,parent,color)
	if x and y and width and height then
		local element, x,y,width,height,ignoreOnRender = initGUI(x,y,width,height,relative,parent)
		if not color then color = tocolor(0,0,0,100) end
		GUIinfo[element] = { guiType = "gridlist", x = x,y = y, width = width,height = height,color = color, visible = true, resource = sourceResourceRoot, 
		contentRenderTarget = dxCreateRenderTarget(width,height-21,true), columns = {}, rows = {}, rowCount = 1, scrollPixels=0, selectionMode=0,ignoreOnRender=ignoreOnRender
		, scrollBarProperties = {}}
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
			width = 1-width
			if width <= 0 then return false end		
		end
		table.insert( GUIinfo[gridlist].columns, { text = text, width = width } )
		return #GUIinfo[gridlist].columns		
	end
end

function gridlistAddRow(gridlist)
	if isElement(gridlist) and GUIinfo[gridlist] then
		GUIinfo[gridlist].rowCount = GUIinfo[gridlist].rowCount + 1
		GUIinfo[gridlist].rows[GUIinfo[gridlist].rowCount] = { sortIndex = GUIinfo[gridlist].rowCount }
		for i=1,#GUIinfo[gridlist].columns do
			table.insert( GUIinfo[gridlist].rows[GUIinfo[gridlist].rowCount], { } )
		end
		return GUIinfo[gridlist].rowCount
	end
end

function createImage(x,y,width,height,relative,img,parent,color)
	if x and y and width and height then
		if(type(img) ~= "string" and not isElement(img)) then err("Image invalid") return false end
		if(type(img) == "string") then
			if(not fileExists(img)) then
				err("Image file "..img.." not found")
				return false
			end
		elseif(getElementType(img) ~= "texture" and getElementType(img) ~= "material") then
			err("Image invalid")
			return false
		end
		local element, x,y,width,height,ignoreOnRender = initGUI(x,y,width,height,relative,parent)
		GUIinfo[element] = { guiType = "image", x = x,y = y, width = width,height = height, visible = true, resource = sourceResourceRoot, 
		contentRenderTarget = dxCreateRenderTarget(width,height,true),ignoreOnRender = ignoreOnRender, img = img, color = color or tocolor(255,255,255) }
		return element
	end
end

function createTreeView(x,y,width,height,relative,parent)
	if x and y and width and height then
		local element, x,y,width,height,ignoreOnRender = initGUI(x,y,width,height,relative,parent)
		GUIinfo[element] = { guiType = "treeview", x = x,y = y, width = width,height = height, visible = true, resource = sourceResourceRoot, 
		contentRenderTarget = dxCreateRenderTarget(width,height,true), scrollPixels=0, nodes = {}, color = tocolor(0,0,0,200),ignoreOnRender=ignoreOnRender }
		return element
	end
end

addEvent("onUSGGUIElementBirth",true)
function treeviewNodeAddElement(element)
	if GUIinfo[source] and GUIinfo[source].guiType == "treenode" then
		GUIinfo[element].ignoreOnRender = true
		table.insert(GUIinfo[source].elements,element)
	end
end

function treeviewCreateNode()
	local element = addElement()
	GUIinfo[element] = {guiType = "treenode", elements = {}, ignoreOnRender = true, visible = true }
	
	return element
end

function treeviewAddNode(treeview, node)
	if isElement(treeview) and GUIinfo[treeview] then	
		if isElement(node) and GUIinfo[node] then
			GUIinfo[node].sortIndex = #GUIinfo[treeview].nodes
			table.insert(GUIinfo[treeview].nodes,node)
		end
	end
end

function createEditBox(x,y,width,height,relative,text,parent,color,clearOnFirstClick,masked,maskedAfterClick)
	if x and y and width and height and text then
		local element, x,y,width,height,ignoreOnRender = initGUI(x,y,width,height,relative,parent)
		if not color then color = tocolor(255,255,255,220) end
		--local guiElement = guiCreateEdit(x,y,width,height,text,false)
		--setElementParent(guiElement,element)
		--guiSetAlpha(guiElement,0)
		--guiEditSetMasked(guiElement,masked or false)
		GUIinfo[element] = { guiType = "editbox", x = x,y = y, width = width,height = height,text = text,color = color, 
		visible = true, resource = sourceResourceRoot, realEdit = guiElement, scroll = 0,
		clearOnClick = clearOnFirstClick, masked = masked, maskedAfterClick = maskedAfterClick, caretIndex = 0, renderTarget = dxCreateRenderTarget(width,height,true),
		textColor = tocolor(0,0,0,255), ignoreOnRender=ignoreOnRender, readOnly = false}
		return element
		
	end
end

function createMemo(x,y,width,height,relative,text,parent,color)
	if x and y and width and height and text then
		local element, x,y,width,height,ignoreOnRender = initGUI(x,y,width,height,relative,parent)
		if not color then color = tocolor(255,255,255,220) end
		GUIinfo[element] = { guiType = "memo", x = x,y = y, width = width,height = height,text = text,color = color, 
		visible = true, resource = sourceResourceRoot, realEdit = guiElement, scroll = 0, 
		caretIndex = 0, renderTarget = dxCreateRenderTarget(width,height,true),
		textColor = tocolor(0,0,0,255), ignoreOnRender=ignoreOnRender, lines = {}, scrollPixels = 0, scrollBarProperties = {}, readOnly = false}
		return element
	end
end

function createLabel(x,y,width,height,relative,text,parent,color)
	if x and y and width and height and text then
		local element, x,y,width,height,ignoreOnRender = initGUI(x,y,width,height,relative,parent)
		if not color then color = tocolor(255,255,255,255) end
		GUIinfo[element] = { guiType = "label", x = x,y = y, width = width,height = height,text = text,color = color, textColor = color, visible = true, textScale,
		resource = sourceResourceRoot, renderTarget = dxCreateRenderTarget(width,height,true), 
		textXAlignment = (defaultTextAlignments[sourceResource] or {x="center"} ).x, textYAlignment = (defaultTextAlignments[sourceResource] or {y="center"} ).y
		,ignoreOnRender=ignoreOnRender}
		return element
	end
end

function createButton(x,y,width,height,relative,text,parent,color)
	if x and y and width and height and text then
		local element, x,y,width,height,ignoreOnRender = initGUI(x,y,width,height,relative,parent)
		if not color then color = tocolor(175,75,0,210) end
		GUIinfo[element] = { guiType = "button", x = x,y = y, width = width,height = height,text = text,color = color, visible = true, 
		resource = sourceResourceRoot,ignoreOnRender=ignoreOnRender }
		return element	
	end
end

function createSlider(x,y, width,height,relative,parent,color,options,interpolateBetweenNumbers, numOfDecimals, optionSize, selOptionSize)
	if x and y and width and height and options[1] and options[2] then
		local element, x,y,width,height,ignoreOnRender = initGUI(x,y,width,height,relative,parent)
		if not color then color = tocolor(0,0,0,190) end
		if interpolateBetweenNumbers then
			for i=1,#options do
				if type(options[i]) ~= "number" then
					interpolateBetweenNumbers = false				
				end				
			end
		end
		GUIinfo[element] = { guiType = "slider", x = x,y = y, width = width,height = height,color = color, visible = true, options = options,
		interpolateNumbers = interpolateBetweenNumbers,resource = sourceResourceRoot, optionSize = optionSize or 16, selOptionSize = selectedOptionSize or 10
		,ignoreOnRender=ignoreOnRender, numOfDecimals = numOfDecimals or 0}
		return element	
	end
end

function createComboBox(x,y,width,height,relative,text,parent,color,direction)
	if x and y and width and height and ( not text or type(text) == "string" ) then
		local element, x,y,width,height,ignoreOnRender = initGUI(x,y,width,height,relative,parent)
		if not color then color = tocolor(0,0,0,190) end

		GUIinfo[element] = { guiType = "combobox", x = x,y = y, width = width,height = height,color = color, visible = true, options = {},
		resource = sourceResourceRoot, direction = direction or "down", collapsed = true, currentOption = nil , text = text
		,ignoreOnRender=ignoreOnRender}
		return element	
	end	
end

function createTabPanel(x,y,width,height,relative,parent,color)
	if x and y and width and height then
		local element, x,y,width,height,ignoreOnRender = initGUI(x,y,width,height,relative,parent)
		if not color then color = tocolor(0,0,0,190) end

		GUIinfo[element] = { guiType = "tabpanel", x = x,y = y, width = width,height = height,color = color, visible = true,
		resource = sourceResourceRoot, tabs = {}, tabHeaderHeight = 20, tabHeaderTextScale = 1,ignoreOnRender=ignoreOnRender }
		return element	
	end
end

function addTab(tabPanel,text)
	local panelInfo = GUIinfo[tabPanel]
	if ( tabPanel and panelInfo and panelInfo.guiType == "tabpanel" and text and type(text) == "string" ) then
		local element = addElement()
		GUIinfo[element] = { guiType = "tab", text=text, tabpanel = tabPanel, x=0,y=panelInfo.tabHeaderHeight,width = panelInfo.width, 
		height = panelInfo.height - panelInfo.tabHeaderHeight, visible = false, resource = sourceResourceRoot
		,ignoreOnRender=ignoreOnRender}
		table.insert(panelInfo.tabs, element)
		setElementParent(element,tabPanel)
		if ( #panelInfo.tabs == 1 ) then
			panelInfo.selectedTab = element
			GUIinfo[element].visible = true
		end
		return element
	end
end