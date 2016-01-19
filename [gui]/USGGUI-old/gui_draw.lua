local renderTarget
local useRenderTarget = false

function drawElementOnRender(element,startX,startY,disabled)
	if ( useRenderTarget ) then
		dxSetRenderTarget(renderTarget)
	end
	post_gui = not isConsoleActive() and not useRenderTarget
	dxSetBlendMode("modulate_add")
	local info = GUIinfo[element]	
	local parentInfo = GUIinfo[getElementParent(element)]
	disabled = disabled or info.disabled
	local customChildDraw = false
	if info.visible then
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
		local x,y = startX+info.x, startY+info.y
		local textColor = info.textColor or defaultTextColor
		if ( disabled ) then
			textColor = tocolor(75,75,75)
		end
		-- draw element
		if ( info.guiType == "scrollarea" ) then
			customChildDraw = true
			renderTarget = info.contentRenderTarget
			dxSetRenderTarget(renderTarget,true)
			useRenderTarget = true
			local children = getElementChildren(element)
			local maxScroll = 0
			for i=1,#children do
				local cInfo = GUIinfo[children[i]]
				if ( cInfo.y+cInfo.height+20 > maxScroll ) then
					maxScroll = cInfo.y+cInfo.height + 20
				end
				if ( cInfo and cInfo.y+cInfo.height >= info.scrollPixels and cInfo.y-info.scrollPixels <= info.height ) then -- draw
					processElementOnRender(children[i],0,-info.scrollPixels,disabled)
				end
			end
			info.maxScroll = maxScroll
			useRenderTarget = false
			dxSetRenderTarget()
			post_gui = not isConsoleActive()
			dxDrawImage(x,y,info.width,info.height,renderTarget,0,0,0,tocolor(255,255,255),post_gui)	
		elseif info.guiType == "window" then
			if ( isElement(elementInFocus) and not disabled ) then -- crappy way but ok
				dxDrawRectangle(x, y-23, info.width, 20, info.titleBarColor, post_gui)
			else
				dxDrawRectangle(x, y-23, info.width, 20, info.color, post_gui)
			end
			dxDrawRectangle(x, y, info.width, info.height, info.color, post_gui)
			dxDrawText(info.text,x,y-23,x+info.width,y-3,textColor, defaultTextScale+0.2,"default-bold",'center','center',true,false, post_gui)	
		elseif info.guiType == "button" then
			if ( not disabled ) then
				dxDrawRectangle(x, y, info.width, info.height, info.color, post_gui)
			else
				dxDrawRectangle(x, y, info.width, info.height, tocolor(50,50,50,200), post_gui)
			end
			dxDrawText(info.text,x,y,x+info.width,y+info.height,textColor, defaultTextScale,"default",'center','center',true,true, post_gui)				
		elseif info.guiType == "label" then
			dxDrawText(info.text,x,y,x+info.width,y+info.height,textColor, info.textScale or defaultTextScale,"default",info.textXAlignment,info.textYAlignment,true,true, post_gui)
		elseif info.guiType == "editbox" then				
			local text = info.text
			dxDrawRectangle(x, y, info.width, info.height, info.color, post_gui)
			
			if info.masked then text = string.rep("*",#text) end
			
			local textToDraw = getTextBeingDrawnIntoEdit(text,info.scroll, #text, info.width-8)
			dxDrawText(textToDraw,x+4,y,x+info.width-8,y+info.height,textColor, defaultTextScale,"default",'left','center',false,false, post_gui)
			
			--draw caret
			if ( elementInFocus == element and info.caretIndex >= info.scroll and info.caretIndex <= info.scroll+#textToDraw ) then
				local width = getTextExtentUntilCaret(textToDraw,info.caretIndex-info.scroll)
				dxDrawLine(math.min(x+info.width-2,x+4+width),y+3, math.min(x+info.width-2,x+4+width), y+19, tocolor( 0,0,0,255), 1, post_gui)
			end
		elseif info.guiType == "memo" then
			local text = info.text
			dxDrawRectangle(x, y, info.width, info.height, info.color, post_gui)
			local avWidth = info.width-4
			if ( getElementScrollBarDimensions(element) ) then
				avWidth = avWidth - 10
			end
			local lineHeight = 15
			local startLine = math.min(#info.lines-1,math.floor((info.scrollPixels or 0)/lineHeight))
			local lines = {}
			local caretLine = 1
			local line = ""
			local lineWidth = 0
			local i = 0 
			for char in text:gmatch ( "." ) do
				local lineN = #lines-startLine
				if ( i == info.caretIndex and lineN >= 0 and lineN*lineHeight < info.height ) then
					caretLine = lineN+1
					dxDrawLine(x+lineWidth+2,y+(#lines*lineHeight),x+2+lineWidth,y+((#lines+1)*lineHeight),tocolor(0,0,0),1, post_gui)
				end
				local nWidth = lineWidth + dxGetTextWidth(char)
				if ( char ~= string.char(1) and nWidth < avWidth ) then
					lineWidth = nWidth
					line = line..char
				else
					if ( #lines >= startLine and lineN*lineHeight < info.height ) then
						dxDrawText(line,x+2,y+(lineN*lineHeight),x+avWidth,y+((lineN+1)*lineHeight),tocolor(0,0,0),1,"default","left","top", false,false,post_gui)
					end
					table.insert(lines,line)
					if ( char == string.char(1) ) then
						lineWidth = 0
						line = ""
					else
						lineWidth = dxGetTextWidth(char)
						line = char
					end
				end
				i=i+1
			end
			-- manage final line
			local lineN = #lines-startLine
			if ( lineN*lineHeight < info.height ) then
				dxDrawText(line,x+2,y+(lineN*lineHeight),x+avWidth,y+((lineN+1)*lineHeight),tocolor(0,0,0),1,"default","left","top",false,false,post_gui)
			end
			if ( info.caretIndex == #text ) then
				caretLine = #lines
				if ( lineN*lineHeight < info.height ) then
					dxDrawLine(2+x+lineWidth,y+(lineN*lineHeight),x+lineWidth+2,y+((lineN+1)*lineHeight),tocolor(0,0,0),1,post_gui)
				end
			end
			table.insert(lines,line)
			info.lines = lines
		elseif info.guiType == 'gridlist' then
			local startRow = info.scrollRow
			local columns = info.columns
			dxDrawRectangle(x,y,info.width, 20, info.color, post_gui) -- column bar
			dxDrawRectangle(x,y+21,info.width,info.height-21, info.color, post_gui) -- background for rows
			local rows = info.rows
			local totalRowHeight = #rows*20
			info.scrollPixels = math.min(info.scrollPixels,#rows*20)
			table.sort(rows, function (a,b) return a.sortIndex < b.sortIndex end )
			local columnStartX = x
			for column=1,#columns do -- draw headers
				local columnX, columnY, columnWidth = columnStartX, y, (columns[column].width*info.width)
				columnX = columnStartX
				dxDrawText(columns[column].text,columnX+5,columnY,columnX+columnWidth,columnY+20,textColor, defaultTextScale*1,"default-bold",'left','center',false,false, post_gui)
				if column ~= #columns then
					dxDrawLine( columnX+columnWidth,columnY+2, columnX+columnWidth, columnY+16, tocolor( 255,255,255,255), 0.5, post_gui )
				end
				columnStartX = columnX+columnWidth
			end
			dxSetRenderTarget(info.contentRenderTarget,true)
			for row=1,#rows do -- draw rows
				local rowX,rowY,rowWidth,rowHeight = 0,20*(row-1)-info.scrollPixels,info.width,20			
				if info.selectedRow == row and not info.selectedColumn  then 
					dxDrawRectangle(rowX, rowY, rowWidth, rowHeight, info.selectedColor or tocolor(50,50,100,200), false) -- selected row color
				end			
				local columnStartX = 0
				for i=1,#columns do				
					local itemX,itemY,itemWidth,itemHeight = rowX,rowY,columns[i].width*info.width,rowHeight
					itemX = columnStartX
					if rows[row][i] then				
						if info.selectedRow == row and info.selectedColumn == i then						
							dxDrawRectangle(itemX, itemY, itemWidth, itemHeight, info.selectedColor or tocolor(50,50,100,200), false) -- selected row+column color						
						end
						local rowColor = rows[row][i].textColor or defaultTextColor
						if rows[row][i][1] then
							dxDrawText(rows[row][i][1],itemX+5, itemY, itemX+(itemWidth-5), itemY+itemHeight,rowColor, defaultTextScale*1,"default",'left','center',false,false, false) -- row text
						end
					end	
					columnStartX = itemX+itemWidth
				end
			end
			dxSetRenderTarget()
			dxDrawImage(x,y+22,info.width,info.height-22,info.contentRenderTarget, 0,0,0, tocolor(255,255,255), post_gui)
			--[[ draw scrollbar
			local location,height = getGridListScrollBarDimensions(element)
			if ( location and height ) then
				dxDrawRectangle(x+info.width-12,y+22,12,info.height-22,tocolor(0,0,0,200), post_gui)
				dxDrawRectangle(x+info.width-9,y+location,6,height,tocolor(255,255,255),post_gui)
			end--]]
		elseif info.guiType == "treeview" then
			--[[local nodes = info.nodes
			dxDrawRectangle(x,y,info.width,info.height, info.color, post_gui) -- background for nodes
			table.sort(nodes, function (a,b) return GUIinfo[a].sortIndex < GUIinfo[b].sortIndex end )
			dxSetRenderTarget(info.contentRenderTarget,true)
			local nodesDrawn = 0
			local nodeStartX,nodeStartY = x,y
			local drawNode = 
				function (nodeID,node,levels)
					local nodeX,nodeY = nodeStartX+(levels*20),nodeStartY+(nodesDrawn*30)
					nodesDrawn = nodesDrawn+1
					local nodeWith, nodeHeight = info.width-nodeX, 30
					local children = getElementChildren(node)
					GUIinfo[node].x, GUIinfo[node].y = nodeX, nodeY
					for i=1,#children do
						drawElementOnRender(children[i])
					end
				end
			for node=1,#nodes do -- draw nodes			
				drawNode(node,nodes[node], 0)
			end
			dxSetRenderTarget()
			if not drawedgrid then
				dxDrawImage(x,y,info.width,info.height,info.contentRenderTarget)
			end
			--]]
		elseif info.guiType == "checkbox" then		
			local checkboxX, checkboxY, checkboxWidth,checkboxHeight = x,y+(info.height-15)/2, 15,15			
			dxDrawRectangle(checkboxX, checkboxY, checkboxWidth,checkboxHeight,info.color, post_gui)
			dxDrawText(info.text,x+20,y,x+info.width-15,y+info.height,textColor, defaultTextScale,"default",'left','center',false,false, post_gui)
			if info.isChecked then				
				dxDrawLine(checkboxX+1,checkboxY+1,checkboxX+checkboxWidth-2, checkboxY+checkboxHeight-2, tocolor(255,255,255,255),0.6)
				dxDrawLine(checkboxX+1,checkboxY+checkboxHeight-2,checkboxX+checkboxWidth-2, checkboxY+1, tocolor(255,255,255,255),0.6)				
			end			
		elseif info.guiType == "slider" then		
			dxDrawLine( x, y+(info.height/2), x+info.width, y+(info.height/2), info.color, 1 ) -- draw line
			local spaceBetweenOptions = (info.width-info.optionSize)/(#info.options-1)
			local posOption1, posOption2 = 0, info.width
			local selOpColor = tocolor(255,255,255,255)
			if ( disabled ) then selOpColor = tocolor(50,50,50) end
			for i=1,#info.options do
				local opX,opY = sliderGetOptionPosition(element,i)
				dxDrawText(tostring(info.options[i]),x+opX+2, y+opY-22,x+opX+14, y+opY-10,textColor, defaultTextScale,"default",'center','center',false,false, post_gui)
				dxDrawRectangle(x+opX,y+opY-(info.optionSize/2), info.optionSize, info.optionSize,setColorAlpha(info.color,250), post_gui ) -- draw option rectangle
				if ( info.selectionPos and info.selectionPos >= opX ) then
					posOption1 = opX
				elseif ( info.selectionPos and info.selectionPos < opX ) then
					posOption2 = opX+(info.optionSize/2)
				end
			end
			if info.selectionPos then
				local interpolatedNumber = info.interpolatedNumber
				local opX,opY = sliderGetOptionPosition(element,info.selectionPos)
				dxDrawRectangle(x+info.selectionPos,y+opY-(info.selOptionSize/2), info.selOptionSize, info.selOptionSize, selOpColor, post_gui )
				dxDrawText(tostring(info.interpolatedNumber), x+posOption1, y+opY-(info.selOptionSize/2)-20,x+posOption2, y+opY-(info.selOptionSize/2),textColor, defaultTextScale,"default",'center','center',false,false, post_gui)				
			elseif info.selection then
				local opX,opY = sliderGetOptionPosition(element,info.selection)
				dxDrawRectangle(x+opX+3,y+opY-(info.selOptionSize/2), info.selOptionSize, info.selOptionSize, selOpColor, post_gui )
			end
		elseif info.guiType == "combobox" then
			dxDrawRectangle(x,y,info.width,info.height,info.color, post_gui)
			if info.currentOption then
				dxDrawText(info.options[info.currentOption],x,y,x+info.width,y+info.height,textColor, defaultTextScale,"default",'center','center',false,false, post_gui)
			else
				dxDrawText(info.text, x,y,x+info.width,y+info.height, textColor, defaultTextScale,"default","center", "center",false,false,post_gui)
			end
			dxDrawBorderAroundRectangle(x,y,info.width,info.height, 0.5, tocolor(255,255,255))
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
						dxDrawRectangle(optionX,optionY,optionSizeX,optionSizeY,info.color, post_gui)
						dxDrawText(optionText,optionX,optionY,optionX+optionSizeX,optionY+optionSizeY,textColor, defaultTextScale,"default",'center','center',false,false, post_gui)
						if ID ~= 1 then
							if info.direction == 'down' then dxDrawLine(optionX+3,optionY,optionX+optionSizeX-6,optionY,tocolor(255,255,255,255), 1, post_gui)
							else dxDrawLine(optionX+3,optionY+optionSizeY,optionX+optionSizeX-6,optionY+optionSizeY,tocolor(255,255,255,255), 1, post_gui) end
						end	
					end				
				end			
			end
		elseif info.guiType == "tabpanel" then
			-- draw tab headers
			local tabs = getTabPanelHeaders(element,x)

			for tab=1,#tabs do
				local tabData = tabs[tab]
				local tabInfo = tabs[tab].info
				local text = tabInfo.text
				local headerWidth = tabData.headerWidth
				local tabX = tabData.tabX
				if ( tabInfo.disabled or disabled ) then -- panel or tab disabled
					dxDrawRectangle(tabX,y,headerWidth,info.tabHeaderHeight,tocolor(50,50,50,200),post_gui)
					dxDrawText(text,tabX,y,tabX+headerWidth,y+info.tabHeaderHeight,tocolor(100,100,100),info.tabHeaderTextScale, "default", "center", "center", true,false, post_gui)						
				elseif ( info.selectedTab ~= tabData.element ) then -- unselected
					dxDrawRectangle(tabX,y,headerWidth,info.tabHeaderHeight,tocolor(33,21,3,220),post_gui)
					dxDrawText(text,tabX,y,tabX+headerWidth,y+info.tabHeaderHeight,tocolor(255,255,255),info.tabHeaderTextScale, "default", "center", "center", true,false, post_gui)
				else -- selected
					dxDrawRectangle(tabX,y,headerWidth,info.tabHeaderHeight,tocolor(175,75,0,220),post_gui)
					dxDrawText(text,tabX,y,tabX+headerWidth,y+info.tabHeaderHeight,tocolor(255,255,255),info.tabHeaderTextScale, "default-bold", "center", "center", true,false, post_gui)
				end
			end
			-- draw background
			dxDrawRectangle(x,y+info.tabHeaderHeight,info.width, info.height-info.tabHeaderHeight,info.color, post_gui)
		end
		-- draw scrollbars
		local location,height = getElementScrollBarDimensions(element)
		if ( location and height ) then
			if ( info.guiType == "gridlist" ) then 
				dxDrawRectangle(x+info.width-12,y+22,12,info.height-22,info.scrollBarProperties.bgcolor or tocolor(0,0,0,200), post_gui)
			else
				dxDrawRectangle(x+info.width-12,y,12,info.height,info.scrollBarProperties.bgcolor or tocolor(0,0,0,200), post_gui)
			end
			dxDrawRectangle(x+info.width-9,y+location,6,height,info.scrollBarProperties.thumbcolor or tocolor(255,255,255,255),post_gui)
		end
		return customChildDraw
	end
	dxSetBlendMode("blend")
end

function memoGetCharacterLine(info, charIndex)
	if ( info and charIndex ) then
		local lineWidth = 0
		local lineText = ""
		local textSeperated = {}
		for char in info.text:gmatch ( "." ) do 
			table.insert( textSeperated, char ) 
		end
		local line = 0
		local char = 0
		local charReached = false
		for i=0,#textSeperated do
			if textSeperated[i] then
				local width = dxGetTextWidth(textSeperated[i])
				if i == charIndex then
					charReached = true
				end
				if width + lineWidth < info.width-20 then
					lineWidth = lineWidth + width
					lineText = lineText..textSeperated[i]
					if not charReached then
						char = char+1
					end
				else
					if charReached then
						return line,lineText, char
					end
					line = line + 1
					lineText = ""
					lineWidth = 0
					char = 0
				end
			end	
		end
		return line, lineText, char
	end
end

function processElementOnRender(element,x,y,disabled)
	if GUIinfo[element] and not ( GUIinfo[element].ignoreOnRender or GUIinfo[element].visible == false ) then
		disabled = disabled or GUIinfo[element].disabled
		local customChildDraw = drawElementOnRender(element,x,y, disabled)
		local nX,nY = GUIinfo[element].x+x, GUIinfo[element].y+y
		if not ( customChildDraw ) then
			local children = getElementChildren(element)
			for i=1,#children do
				processElementOnRender(children[i],nX,nY, disabled)
			end
		end
	end
end

function drawElementsOnRender()
	local children = getElementChildren(getResourceDynamicElementRoot(getThisResource()),"USGGUI")
	table.sort(children, function (a,b) return GUIorder[a] < GUIorder[b] end)
	for i=1,#children do
		processElementOnRender(children[i],0,0, false)
	end
end

-- drawing aids
function getTabPanelHeaders(tabPanel,panelX)
	local info = GUIinfo[tabPanel]
	if ( isElement(tabPanel) and info and info.guiType == "tabpanel" ) then
		local tabStartX = panelX
		local maxHeaderSize = math.max(info.width/4,info.width/#info.tabs)
		local tabsInfo = {}
		for i=1,#info.tabs do
			if ( info.tabs[i] ) then
				local element = info.tabs[i]
				local tabInfo = GUIinfo[element]
				local textWidth = dxGetTextWidth(tabInfo.text)
				local headerWidth = math.min(maxHeaderSize,textWidth+info.tabHeaderHeight)
				local tabX = tabStartX
				tabStartX = tabStartX + headerWidth + 2
				table.insert(tabsInfo,{element=element,info = tabInfo, headerWidth = headerWidth, tabX = tabX })
			end
		end
		return tabsInfo
	end
end

function getElementScrollBarDimensions(element)
	local info = GUIinfo[element]
	local location, height = false, false
	local maxScroll = getElementMaxScroll(element) or 0
	if ( info ) then
		if ( info.guiType == "gridlist" ) then
			if ( #info.rows*20 >= info.height-22 ) then
				height = math.max(20,(info.height/(maxScroll)*(info.height-22)))
				location = ((info.scrollPixels)/(maxScroll))*(info.height-22-height-4)
				return location+24,height
			end
			return location,height
		elseif ( info.guiType == "scrollarea" or info.guiType == "memo" ) then
			if ( maxScroll > 0 ) then
				local maxScroll = maxScroll + info.height
				height = math.max(20, (info.height/(maxScroll)*(info.height)))
				location = ((info.scrollPixels)/(maxScroll-info.height))*(info.height-height-4)
			end
		end
	end
	return location,height
end

function getElementMaxScroll(element)
	local info = GUIinfo[element]
	if ( info ) then
		if ( info.guiType == "gridlist" ) then
			return (#info.rows*20)-info.height+20
		elseif ( info.guiType == "scrollarea" ) then
			return info.maxScroll-info.height
		elseif ( info.guiType == "memo" ) then
			return ((#info.lines)*15)-info.height
		end
	end
end

function dxDrawBorderAroundRectangle(x,y,width,height,lineWidth,color)
	if not lineWidth then lineWidth = 1.75 end
	local width = width - 1
	if not color then color = tocolor( 255,255,255,255) end
	dxDrawLine(x,y,x+width,y,color,lineWidth, post_gui)
	dxDrawLine(x,y,x,y+height,color,lineWidth, post_gui)
	dxDrawLine(x+width,y,x+width,y+height,color,lineWidth, post_gui)
	dxDrawLine(x,y+height,x+width,y+height,color,lineWidth, post_gui)
end

function sliderGetOptionPosition(slider,option)
	local sliderInfo = GUIinfo[slider]
	if not sliderInfo then return false end
	local x,y = sliderInfo.x, sliderInfo.y	
	local spaceBetweenOptions = (sliderInfo.width-16)/(#sliderInfo.options-1)
	return (option-1)*spaceBetweenOptions, (sliderInfo.height/2),(option-1)*spaceBetweenOptions,spaceBetweenOptions
end

function getTextBeingDrawnIntoEdit(text, scroll, scrollEnd, maxWidth)
	local textToDraw = ""
	local length = 0
	local textSeperated = {}
	for char in text:gmatch ( "." ) do 
		table.insert( textSeperated, char ) 
	end
	local index = 0
	for i=scroll+1,scrollEnd+1 do
		if textSeperated[i] then
			local width = dxGetTextWidth(textSeperated[i])
			if width + length < maxWidth then
				textToDraw = textToDraw..textSeperated[i]
				length = length + width
			else
				break
			end
		end	
	end
	return textToDraw
	--return string.sub(text,scroll, scrollEnd)
end

function setColorAlpha(color,alpha)
	local r,g,b = bitExtract(color,0,8),bitExtract(color,8,8),bitExtract(color,16,8)
	return tocolor(r,g,b,alpha)
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