local skin = {}
skin.name = "ABC"

function skin.drawElement(element,x,y,disabled, hovered)
	local info = GUIinfo[element]
	local customChildDraw = false
	local textColor = info.textColor or getSkinColor("text")
	if ( disabled ) then
		textColor = tocolor(95,95,95)
	end
	-- draw element
	local width, height = info.width, info.height
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
			dxDrawImage(x, y-20, 20, 20,"skins/abc/window_title_corner.png",0,0,0, info.titleBarColor or getSkinColor("selection"), post_gui)
			dxDrawImage(x+info.width, y-20, -20, 20,"skins/abc/window_title_corner.png",0,0,0, info.titleBarColor or getSkinColor("selection"), post_gui)
			dxDrawRectangle(x+20, y-20, info.width-40, 20, info.titleBarColor or getSkinColor("selection"), post_gui)
		else
			dxDrawImage(x, y-20, 20, 20,"skins/abc/window_title_corner.png",0,0,0, info.color, post_gui)
			dxDrawImage(x+info.width, y-20, -20, 20,"skins/abc/window_title_corner.png",0,0,0, info.color, post_gui)		
			titleColor =  blendColor(titleColor,tocolor(130,130,130), 255)
			dxDrawRectangle(x+20, y-20, info.width-40, 20, info.color, post_gui)
		end
		dxDrawRectangle(x, y, info.width, info.height, info.color, post_gui)
		dxDrawText(info.text,x,y-20,x+info.width,y,titleColor, defaultTextScale+0.2,"default-bold",'center','center',true,false, post_gui)	
	elseif info.guiType == "button" then
		local btnColor = disabled and tocolor(50,50,50,255) or (hovered and getSkinColor("hover") or info.color)
		local font = "default"
		if(hovered and not disabled) then
			font = "default-bold"
			x, y = x - 2, y - 2
			width, height = width + 2, height + 2
		end
		dxDrawCircle(x+4,y+4,4, btnColor)
		dxDrawCircle(x+4,y+height-6,4, btnColor)
		dxDrawCircle(x+width-6,y+4,4, btnColor)
		dxDrawCircle(x+width-6,y+height-6,4, btnColor)
		dxDrawRectangle(x+4, y, width-8, height, btnColor, post_gui)
		dxDrawRectangle(x,y+4, 4, height-8, btnColor, post_gui)
		dxDrawRectangle(x+width-4, y+4, 4, height-8, btnColor, post_gui)
		dxDrawText(info.text,x,y,x+width,y+height,textColor, defaultTextScale,font,'center','center',true,true, post_gui)
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
			local textWidth = getTextExtentUntilCaret(textToDraw,info.caretIndex-info.scroll)
			dxDrawLine(math.min(x+info.width-2,x+4+textWidth),y+3, math.min(x+info.width-2,x+4+textWidth), y+19, tocolor( 0,0,0,255), 1, post_gui)
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
						if(dxGetTextWidth(word) < avWidth) then
							if(word and #word > 0) then
								line = line:sub(1, #line-(#word))
							end
							lineWidth = dxGetTextWidth(word..char)
							nLine = word..char
							word = ""
						else
							lineWidth = dxGetTextWidth(char)
							nLine = char
						end
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
		dxDrawImage(x,y,info.width,20,"skins/abc/bar_vertical.png",0,0,0,getSkinColor("gridlist_header"),post_gui)
		dxDrawRectangle(x,y+21,info.width,info.height-21, getSkinColor("gridlist_row_bg"), post_gui) -- background for rows
		dxDrawBorderAroundRectangle(x,y+21,info.width,info.height-21,1,tocolor(80,80,80))
		local rows = info.displayedRows
		local totalRowHeight = info.rowCount*20
		info.scrollPixels = math.min(info.scrollPixels,info.rowCount*20)
		dxSetRenderTarget(info.contentRenderTarget,true)
		dxSetBlendMode("modulate_add")
		local firstRow = math.max(1,math.floor(info.scrollPixels/20)-1) -- calculate row to start from
		local rowIndex = firstRow
		for i=rowIndex, info.rowCount do -- draw rows
			local row = rows[i]
			if(info.rows[row]) then
				local rowX,rowY,rowWidth,rowHeight = 0,20*(rowIndex-1)-math.floor(info.scrollPixels),info.width,20
				if(rowY+rowHeight > 0) then
					if(rowY < info.height+20) then
						if info.selectedRow == row and not info.selectedColumn  then
							dxDrawRectangle(rowX+1, rowY, rowWidth-2, rowHeight, info.selectedColor or getSkinColor("gridlist_row_selected"), false) -- selected row color
						end
						local columnStartX = 0
						for i=1,#columns do
							local itemX,itemY,itemWidth,itemHeight = rowX,rowY,columns[i].width*info.width,rowHeight
							itemX = columnStartX
							if info.rows[row][i] then
								if info.selectedRow == row and info.selectedColumn == i then
									dxDrawRectangle(itemX, itemY, itemWidth, itemHeight, info.selectedColor or getSkinColor("gridlist_row_selected"), false) -- selected row+column color
								end
								local rowColor = info.rows[row][i].textColor or textColor
								if info.rows[row][i][1] then
									dxDrawText(info.rows[row][i][1],itemX+5, itemY, itemX+(itemWidth-5), itemY+itemHeight,rowColor, defaultTextScale*1,"default",'left','center',true,false, false) -- row text
								end
							end
							columnStartX = itemX+itemWidth
						end
					else
						break -- last visible row reached, no need to continue loop
					end
				end
				rowIndex = rowIndex + 1
			end
		end
		if ( useRenderTarget ) then
			dxSetRenderTarget(renderTarget)
		else
			dxSetRenderTarget()
		end
		dxSetBlendMode("add")
		dxDrawImage(x,y+22,info.width,info.height-22,info.contentRenderTarget, 0,0,0, color_white, post_gui)
		dxSetBlendMode("blend")
		local columnStartX = x
		for column=1,#columns do -- draw headers
			local columnX, columnY, columnWidth = columnStartX, y, (columns[column].width*info.width)
			columnX = columnStartX
			dxDrawText(columns[column].text,columnX+5,columnY,columnX+columnWidth,columnY+20,tocolor(0,0,0), defaultTextScale*1,"default-bold",'left','center',false,false, post_gui)
			if column ~= #columns then
				dxDrawLine( columnX+columnWidth,columnY+2, columnX+columnWidth, columnY+19, color_white, 0.5, post_gui )
				dxDrawLine( columnX+columnWidth, y+22, columnX+columnWidth, y+info.height, tocolor(10,10,10), 1, post_gui)
			end
			if(column == info.sortColumn) then
				dxDrawImage( columnX+columnWidth-15, columnY+7, 8, 8, "skins/abc/arrow.png",info.sortAscending and 180 or 0,0,0,color_white,post_gui)
			end
			columnStartX = columnX+columnWidth
		end
		dxDrawLine(x,y+20,x+info.width,y+20,tocolor(8,8,8), 1, post_gui)	
		--dxDrawBorderAroundRectangle(x,y,info.width,info.height,1,tocolor(8,8,8))
	elseif info.guiType == "image" then
		local result = dxDrawImage(x,y,info.width,info.height,info.img,0,0,0,info.color,post_gui)
		if(not result) then
			outputDebugString("Error drawing image "..tostring(info.img), 1)
		end
	elseif info.guiType == "treeview" then
	elseif info.guiType == "checkbox" then		
		local checkboxX, checkboxY, checkboxWidth,checkboxHeight = x,y+(info.height-15)/2, 15,15
		if(hovered and not disabled) then
			dxDrawRectangle(checkboxX, checkboxY, checkboxWidth, checkboxHeight, setColorAlpha(getSkinColor("hover"), 100))
		end
		dxDrawBorderAroundRectangle(checkboxX, checkboxY, checkboxWidth, checkboxHeight, 1, tocolor(80,80,80))
		dxDrawText(info.text,x+20,y,x+info.width-15,y+info.height,textColor, defaultTextScale,"default",'left','center',false,false, post_gui)
		if info.isChecked then
			dxDrawImage(checkboxX, checkboxY, 15, 15, "skins/abc/checkbox_tick.png", 0,0,0, getSkinColor("selection"), post_gui)			
		end
	elseif info.guiType == "radiobutton" then
		local radius = 5
		local x0, y0 = x, math.floor(y+(info.height-math.floor(radius*0.5))/2)
		local textHeight = info.height-(y0-y)-radius
		dxDrawText(info.text,x+radius+5,y0-math.floor(radius*1.5),x+info.width-radius-5,y0-radius+textHeight,textColor, defaultTextScale,"default",'left','top',false,false, post_gui)		
		local x, y = radius, 0;
		local radiusError = 1-x;
		local borderColor = tocolor(100,100,100)
		local selectionColor = getSkinColor("selection")
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
		dxDrawRoundRectangle(x,y,info.width,info.height,tocolor(130,130,130))
		if info.currentOption then
			dxDrawText(info.options[info.currentOption],x,y,x+info.width,y+info.height,textColor, defaultTextScale,"default",'center','center',false,false, post_gui)
		else
			dxDrawText(info.text, x,y,x+info.width,y+info.height, textColor, defaultTextScale,"default","center", "center",false,false,post_gui)
		end
		local rot = 180
		if(not info.collapsed) then rot = rot + 180 end
		if(info.direction == "up") then rot = rot + 180 end
		while(rot > 360) do
			rot = rot - 360
		end
		dxDrawImage(x+info.width-16, y+((info.height-12)/2),12,12,"skins/abc/arrow.png", rot, 0,0,tocolor(200,200,200),post_gui)
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
		local selectedTab = false
		local headerHeight = info.tabHeaderHeight
		local headerColor = getSkinColor("tabpanel_header")
		for tab=1,#tabs do
			local tabData = tabs[tab]
			local tabInfo = tabs[tab].info
			local text = tabInfo.text
			local headerWidth = tabData.headerWidth
			local tabX = tabData.tabX
			local color = (tabInfo.disabled or disabled) and tocolor(50,50,50,255) or (info.selectedTab == tabData.element and getSkinColor("selection") or headerColor)
			dxDrawRoundCorner(tabX,y,headerWidth, headerHeight, 0, color)
			dxDrawRoundCorner(tabX,y,headerWidth, headerHeight, 2, color)			
			dxDrawRectangle(tabX,y+4,headerWidth,headerHeight-4,color,post_gui)
			dxDrawRectangle(tabX+4,y,headerWidth-8,4,color,post_gui)
			dxDrawText(text,tabX,y,tabX+headerWidth,y+headerHeight,textColor,info.tabHeaderTextScale, "default", "center", "center", true,false, post_gui)
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
		dxDrawCircle(x+info.width-7,y+location+2,2,info.scrollBarProperties.thumbcolor or getSkinColor("scrollbar_thumb"))
		dxDrawCircle(x+info.width-7,y+location+height-2,2,info.scrollBarProperties.thumbcolor or getSkinColor("scrollbar_thumb"))
		dxDrawRectangle(x+info.width-9,y+location+2,6,height-4,info.scrollBarProperties.thumbcolor or getSkinColor("scrollbar_thumb"),post_gui)
		local lnY1 = math.floor((height-3)/2)
		local lnY2 = lnY1+2
		dxDrawLine(x+info.width-8,y+location+lnY1,x+info.width-4,y+location+lnY1, tocolor(0,0,0),1,post_gui)
		dxDrawLine(x+info.width-8,y+location+lnY2,x+info.width-4,y+location+lnY2, tocolor(0,0,0),1,post_gui)
	end
	return customChildDraw
end

skin.defaultColors = {
	selection = tocolor(70,70,255),
	hover = tocolor(75,75,255),
	window = tocolor(225,225,225),
	gridlist = tocolor(0,0,0,160),
	gridlist_row_bg = tocolor(200,200,200,255),
	gridlist_row_selected = tocolor(160,160,255),
	memo = tocolor(200,200,230),
	editbox = tocolor(200,200,230),
	tabpanel = tocolor(180,180,180,100),
	tabpanel_header = tocolor(190,190,190),
	scrollbar_thumb = tocolor(120,120,255),
	text = tocolor(0,0,0),
}

skin.defaultColors.window_title_bar = skin.defaultColors.selection
skin.defaultColors.button = skin.defaultColors.selection
skin.defaultColors.gridlist_header = skin.defaultColors.selection

registerSkin(skin)
