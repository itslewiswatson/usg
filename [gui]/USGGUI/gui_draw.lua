useRenderTarget = false

function drawElementOnRender(element,startX,startY,disabled)
	if ( useRenderTarget ) then
		dxSetRenderTarget(renderTarget)
	end
	post_gui = not isConsoleActive() and not useRenderTarget
	dxSetBlendMode("blend")
	local info = GUIinfo[element]
	if(info.visible) then
		processElementAnimation(element)
		local hovered, section = isElementHovered(element, startX, startY)
		return currentSkin.drawElement(element, startX+info.x, startY+info.y, disabled or GUIinfo[element].disabled, hovered)
	else
		return false
	end
end

function processElementAnimation(element)
	local info = GUIinfo[element]
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

local DEBUG_FRAME_TIME = false
local lastSecond = 0
local frames_in_second = 0
local frames_per_second = 0

function drawElementsOnRender()
	local pre = DEBUG_FRAME_TIME and getTickCount() or nil
	local children = getElementChildren(getResourceDynamicElementRoot(getThisResource()),"USGGUI")
	table.sort(children, function (a,b) return GUIorder[a] < GUIorder[b] end)
	for i=1,#children do
		processElementOnRender(children[i],0,0, false)
	end
	if(DEBUG_FRAME_TIME) then
		local tick = getTickCount()
		dxDrawText(tick-pre,0,0,screenWidth, screenHeight, color_white,1.5,"default","right","top")
		dxDrawText(frames_per_second,0,0,screenWidth-150, screenHeight, color_white,1.5,"default","right","top")
		if(tick > lastSecond+1000) then
			frames_per_second = frames_in_second
			frames_in_second = 0
			lastSecond = tick
		end
		frames_in_second = frames_in_second + 1
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
				location = (((info.scrollPixels)/(maxScroll))*(info.height-22-height-4))+24
			end
		elseif ( info.guiType == "scrollarea" or info.guiType == "memo" ) then
			if ( maxScroll > 0 ) then
				local maxScroll = maxScroll + info.height
				height = math.max(20, (info.height/(maxScroll)*(info.height)))
				location = ((info.scrollPixels)/(maxScroll-info.height))*(info.height-height-4)
			end
		end
	end
	return location and math.floor(location) or false,height and math.floor(height) or false
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

function dxDrawCircle(cx,cy,radius, color)
	for y = -radius, radius do
		for x = -radius, radius do
			if ((x * x) + (y * y) <= (radius * radius)) then
				dxDrawRectangle (cx+x, cy+y, 2,2,color,post_gui)
			end
		end
	end
end

function dxDrawArc (cx, cy, a, b, color, seg)
    -- Originally written from scratch by Ulrich Mierendorff, 06/2006
    if(seg == 0) then xp = 1; yp = -1; xa = 1; ya = -1; 
    elseif(seg == 1) then xp = -1; yp = -1; xa = 0; ya = -1;
    elseif(seg == 2) then xp = -1; yp = 1; xa = 0; ya = 0;
    elseif(seg == 3) then xp = 1; yp = 1; xa = 1; ya = 0; end
    for x = 0, a do
        y = b * math.sqrt( 1 - (x*x)/(a*a) );
        local err = y - math.floor(y);
        y = math.floor(y)
        dxDrawLine(cx+xp*x+xa, cy+yp*y+ya, cx+xp*x+xa, cy+ya,color,1, post_gui)--setColorAlpha(color, 255*err), post_gui)
    end
    for y = 0, b do
        x = a * math.sqrt( 1 - (y*y)/(b*b) );
        local err = x - math.floor(x);
        x = math.floor(x)
        dxDrawRectangle(cx+xp*(x+1)+xa, cy+yp*y+ya, 1,1,color, post_gui)--setColorAlpha(color, 255*err), post_gui)
    end
end

function dxDrawRoundCorners(x,y, width, height, color)
	dxDrawRoundCorner(x+4,y+4,4, 0, color)
	dxDrawRoundCorner(x+4,y+height-2,4, 1, color)
	dxDrawRoundCorner(x+width-2,y+4,4, 2, color)
	dxDrawRoundCorner(x+width-2,y+height-2,4, 3, color)
end

function dxDrawRoundCorner(x,y,width, height, corner,color)
	if(corner == 0) then
		dxDrawCircle(x+4,y+4,4, color)
	elseif(corner == 1) then
		dxDrawCircle(x+4,y+height-6,4, color)
	elseif(corner == 2) then
		dxDrawCircle(x+width-6,y+4,4, color)
	elseif(corner == 3) then
		dxDrawCircle(x+width-6,y+height-6,4, color)
	end
end

function dxDrawRoundRectangle(x,y,width,height,color)
	dxDrawCircle(x+4,y+4,4, color)
	dxDrawCircle(x+4,y+height-6,4, color)
	dxDrawCircle(x+width-6,y+4,4, color)
	dxDrawCircle(x+width-6,y+height-6,4, color)
	dxDrawRectangle(x+4, y, width-8, height, color, post_gui)
	dxDrawRectangle(x,y+4, 4, height-8, color, post_gui)
	dxDrawRectangle(x+width-4, y+4, 4, height-8, color, post_gui)
	--[[
	dxDrawRoundCorners(x,y, width, height, color)
	dxDrawRectangle(x+4, y, width-8, height, color, post_gui)
	dxDrawRectangle(x,y+4, 4, height-8, color, post_gui)
	dxDrawRectangle(x+width-4, y+4, 4, height-8, color, post_gui)
	--]]
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