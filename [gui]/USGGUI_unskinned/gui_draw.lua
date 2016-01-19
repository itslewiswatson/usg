local renderTarget
local useRenderTarget = false

function drawElementOnRender(element,startX,startY,disabled)
	if ( useRenderTarget ) then
		dxSetRenderTarget(renderTarget)
	end
	post_gui = not isConsoleActive() and not useRenderTarget
	dxSetBlendMode("blend")
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
			dxDrawImage(x,y,info.width,info.height,renderTarget,0,0,0,color_white,post_gui)	
		elseif info.guiType == "window" then
			local titleColor = textColor
			if ( isChildInFocus(element) and not disabled ) then
				dxDrawRectangle(x, y-23, info.width, 20, info.titleBarColor, post_gui)
			else
				titleColor =  blendColor(titleColor,tocolor(130,130,130), 255)
				dxDrawRectangle(x, y-23, info.width, 20, info.color, post_gui)
			end
			dxDrawRectangle(x, y, info.width, info.height, info.color, post_gui)
			dxDrawText(info.text,x,y-23,x+info.width,y-3,titleColor, defaultTextScale+0.2,"default-bold",'center','center',true,false, post_gui)	
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
			if ( not info.readOnly and elementInFocus == element and info.caretIndex >= info.scroll and info.caretIndex <= info.scroll+#textToDraw ) then
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
			local i = 1
			local word = ""
			for char in text:gmatch ( "." ) do		
				local lineN = #lines-startLine
				local nWidth = lineWidth + dxGetTextWidth(char)
				if ( not info.readOnly and i-1 == info.caretIndex and lineN >= 0 and lineN*lineHeight < info.height and elementInFocus == element) then
					caretLine = lineN+1
					dxDrawLine(x+lineWidth+2,y+(#lines*lineHeight),x+2+lineWidth,y+((#lines+1)*lineHeight),tocolor(0,0,0),1, post_gui)
				end
				if ( char ~= string.char(10) and nWidth < avWidth ) then
					lineWidth = nWidth
					line = line..char
					if(char ~= " ") then
						word = word..char
					else
						word = ""
					end
				else
					local nLine
					if ( char == string.char(10) ) then
						lineWidth = 0
						nLine = ""
						word = ""
					else
						if(char == " ") then -- no need to put space as first character
							lineWidth = 0
							nLine = ""
						else
							if(word and #word > 0) then
								line = line:sub(1, #line-(#word))
							end
							lineWidth = dxGetTextWidth(char)
							nLine = word..char
						end
					end
					if ( #lines >= startLine and lineN*lineHeight < info.height ) then
						dxDrawText(line,x+2,y+(lineN*lineHeight),x+avWidth,y+((lineN+1)*lineHeight),tocolor(0,0,0),1,"default","left","top", false,false,post_gui)
					end							
					table.insert(lines,line)
					line = nLine
				end
				i = i + 1
			end
			-- manage final line
			local lineN = #lines-startLine
			if ( lineN*lineHeight < info.height ) then
				dxDrawText(line,x+2,y+(lineN*lineHeight),x+avWidth,y+((lineN+1)*lineHeight),tocolor(0,0,0),1,"default","left","top",false,false,post_gui)
			end
			if ( not info.readOnly and info.caretIndex == #text and elementInFocus == element) then
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
			table.sort(rows, function (a,b) if(b) then return a.sortIndex < b.sortIndex else return false end end )
			dxSetRenderTarget(info.contentRenderTarget,true)
			local rowIndex = 1
			for row=1, info.rowCount do -- draw rows
				if(info.rows[row]) then
					local rowX,rowY,rowWidth,rowHeight = 0,20*(rowIndex-1)-info.scrollPixels,info.width,20			
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
					rowIndex = rowIndex + 1
				end
			end
			if ( useRenderTarget ) then
				dxSetRenderTarget(renderTarget)
			else
				dxSetRenderTarget()
			end
			dxDrawImage(x,y+22,info.width,info.height-22,info.contentRenderTarget, 0,0,0, color_white, post_gui)
			local columnStartX = x
			for column=1,#columns do -- draw headers
				local columnX, columnY, columnWidth = columnStartX, y, (columns[column].width*info.width)
				columnX = columnStartX
				dxDrawText(columns[column].text,columnX+5,columnY,columnX+columnWidth,columnY+20,textColor, defaultTextScale*1,"default-bold",'left','center',false,false, post_gui)
				if column ~= #columns then
					dxDrawLine( columnX+columnWidth,columnY+2, columnX+columnWidth, columnY+16, color_white, 0.5, post_gui )
					dxDrawLine( columnX+columnWidth, y+22, columnX+columnWidth, y+info.height, tocolor(10,10,10), 1, post_gui)
				end
				columnStartX = columnX+columnWidth
			end
			dxDrawLine(x,y+20,x+info.width,y+20,tocolor(8,8,8), 1, post_gui)	
			dxDrawBorderAroundRectangle(x,y,info.width,info.height,1,tocolor(8,8,8))
			--[[ draw scrollbar
			local location,height = getGridListScrollBarDimensions(element)
			if ( location and height ) then
				dxDrawRectangle(x+info.width-12,y+22,12,info.height-22,tocolor(0,0,0,200), post_gui)
				dxDrawRectangle(x+info.width-9,y+location,6,height,tocolor(255,255,255),post_gui)
			end--]]
		elseif info.guiType == "image" then
			local result = dxDrawImage(x,y,info.width,info.height,info.img,0,0,0,info.color,post_gui)
			if(not result) then
				outputDebugString("Error drawing image "..tostring(info.img), 1)
			end
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
				dxDrawLine(checkboxX+1,checkboxY+1,checkboxX+checkboxWidth-2, checkboxY+checkboxHeight-2, color_white,0.8,post_gui)
				dxDrawLine(checkboxX+1,checkboxY+checkboxHeight-2,checkboxX+checkboxWidth-2, checkboxY+1, color_white,0.8,post_gui)				
			end
		elseif info.guiType == "radiobutton" then
			local radius = 5
			local x0, y0 = x, math.floor(y+(info.height-math.floor(radius*0.5))/2)
			local textHeight = info.height-(y0-y)-radius
			dxDrawText(info.text,x+radius+5,y0-math.floor(radius*1.5),x+info.width-radius-5,y0-radius+textHeight,textColor, defaultTextScale,"default",'left','top',false,false, post_gui)		
			local x, y = radius, 0;
			local radiusError = 1-x;
			local borderColor = tocolor(100,100,100)
			local selectionColor = color_white
			while(x >= y) do
				dxDrawRectangle(x + x0, y + y0, 1,1,borderColor,post_gui);
				dxDrawRectangle(y + x0, x + y0, 1,1,borderColor,post_gui);
				dxDrawRectangle(-x + x0, y + y0, 1,1,borderColor,post_gui);
				dxDrawRectangle(-y + x0, x + y0, 1,1,borderColor,post_gui);
				dxDrawRectangle(-x + x0, -y + y0, 1,1,borderColor,post_gui);
				dxDrawRectangle(-y + x0, -x + y0, 1,1,borderColor,post_gui);
				dxDrawRectangle(x + x0, -y + y0, 1,1,borderColor,post_gui);
				dxDrawRectangle(y + x0, -x + y0, 1,1,borderColor,post_gui);
				y = y + 1;
				if (radiusError<0) then
					radiusError = radiusError + ( 2 * y + 1);
				else
					x = x - 1;
					radiusError = radiusError + ( 2* (y - x + 1));
				end
			end
			if(info.selected) then
				local radius = 5
				local x, y = radius, 0;
				while(x >= y) do
					dxDrawLine(x+x0,y+y0,-x+x0,y+y0,selectionColor, 1,post_gui)
					dxDrawLine(y+x0,x+y0,-y+x0,x+y0,selectionColor,1,post_gui)
					dxDrawLine(-x+x0,-y+y0,x+x0,-y+y0,selectionColor,1,post_gui)
					dxDrawLine(-y+x0,-x+y0,y+x0,-x+y0,selectionColor,1,post_gui)
					dxDrawLine(y+x0,x+y0,-y+x0,x+y0,selectionColor,1,post_gui)
					y = y + 1;
					if (radiusError<0) then
						radiusError = radiusError + ( 2 * y + 1);
					else
						x = x - 1;
						radiusError = radiusError + ( 2* (y - x + 1));
					end
				end
			end
		elseif info.guiType == "slider" then		
			dxDrawLine( x, y+(info.height/2), x+info.width, y+(info.height/2), info.color, 1 ) -- draw line
			local spaceBetweenOptions = (info.width-info.optionSize)/(#info.options-1)
			local posOption1, posOption2 = 0, info.width
			local selOpColor = color_white
			if ( disabled ) then selOpColor = tocolor(50,50,50) end
			for i=1,#info.options do
				local opX,opY = sliderGetOptionPosition(element,i)
				dxDrawText(tostring(info.options[i]),x+opX+2, y+opY-22,x+opX+14, y+opY-10,textColor, defaultTextScale,"default",'center','center',false,false, post_gui)
				dxDrawRectangle(x+opX,y+opY-(info.optionSize/2), info.optionSize, info.optionSize,setColorAlpha(info.color,250), post_gui ) -- draw option rectangle
				dxDrawBorderAroundRectangle(x+opX,y+opY-(info.optionSize/2),info.optionSize,info.optionSize, 1, tocolor(18,18,18))
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
			dxDrawBorderAroundRectangle(x,y,info.width,info.height, 0.5, color_white)
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
							if info.direction == 'down' then dxDrawLine(optionX+3,optionY,optionX+optionSizeX-6,optionY,color_white, 1, post_gui)
							else dxDrawLine(optionX+3,optionY+optionSizeY,optionX+optionSizeX-6,optionY+optionSizeY,color_white, 1, post_gui) end
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
					dxDrawText(text,tabX,y,tabX+headerWidth,y+info.tabHeaderHeight,color_white,info.tabHeaderTextScale, "default", "center", "center", true,false, post_gui)
				else -- selected
					dxDrawRectangle(tabX,y,headerWidth,info.tabHeaderHeight,tocolor(175,75,0,220),post_gui)
					dxDrawText(text,tabX,y,tabX+headerWidth,y+info.tabHeaderHeight,color_white,info.tabHeaderTextScale, "default-bold", "center", "center", true,false, post_gui)
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
			dxDrawRectangle(x+info.width-9,y+location,6,height,info.scrollBarProperties.thumbcolor or color_white,post_gui)
		end
		return customChildDraw
	end
	dxSetBlendMode("blend")
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
				height = math.max(20,(info.height/(info.height+maxScroll))*(info.height-22))
				location = ((info.scrollPixels)/(maxScroll))*(info.height-22-height-4)
				return location+24,height
			end
			return location,height
		elseif ( info.guiType == "scrollarea" or info.guiType == "memo" ) then
			if ( maxScroll > 0 ) then
				local maxScroll = maxScroll + info.height
				height = math.max(20, (info.height/maxScroll)*(info.height))
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
	if not color then color = color_white end
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
end

function blendColor(color,color2, alpha)
	local r,g,b = getColorRGB(color)
	local r2,g2,b2 = getColorRGB(color2)
	local blendR, blendG, blendB = (r+r2)/2, (g+g2)/2, (b+b2)/2
	return tocolor(blendR,blendG,blendB, alpha or 255)
end

function getColorRGB(color)
	return bitExtract(color,0,8),bitExtract(color,8,8),bitExtract(color,16,8)
end

function setColorAlpha(color,alpha)
	local r,g,b = getColorRGB(color)
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