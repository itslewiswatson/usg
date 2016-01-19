local keyTable = {
 ["0"]=')', ["1"]='!', ["2"]='@', ["3"]='#', ["4"]='$', ["5"]='%', ["6"]='^', ["7"]='&', ["8"]='*', ["9"]='(', ["a"]=true, ["b"]=true, ["c"]=true, ["d"]=true, ["e"]=true, 
 ["f"]=true, ["g"]=true, ["h"]=true, ["i"]=true, ["j"]=true, ["k"]=true,
 ["l"]=true,["m"]=true, ["n"]=true, ["o"]=true, ["p"]=true, ["q"]=true, ["r"]=true, ["s"]=true, ["t"]=true, ["u"]=true, ["v"]=true, ["w"]=true, ["x"]=true, ["y"]=true, ["z"]=true,
["["]='{', ["]"]='}', [";"]=':', [","]='<', ["-"]='_', ["."]='>',["/"]='?', ["\\"]='|', ["="]='+' }
local differentKeysTable = {['num_mul'] = '*',['num_add'] = '+',['num_sub'] = '-',['num_div'] = '/',
['num_dec'] = ".",['space'] = " "}

for i=1,9 do
	differentKeysTable['num_'..tostring(i)] = tostring(i)
end
local checkKeyHoldTimers = {}
local holdKeyTimers = {}

leftMouseState = getKeyState("mouse1")
rightMouseState = getKeyState("mouse2")
midMouseState = getKeyState("mouse3")

addEvent("onUSGGUIChange",true)
function onClientCharacter(key)
	local info = GUIinfo[elementInFocus]
	if not isElement(elementInFocus) or ( info.guiType ~= "editbox" and info.guiType ~= "memo" ) then return true end
	if not ( isGUIVisible(elementInFocus) ) then return true end
	
	local oldText = info.text
	local firstPart = string.sub(oldText, 0,info.caretIndex)
	local lastPart = string.sub(oldText, info.caretIndex+1)
	setText(elementInFocus, firstPart..key..lastPart )
	info.caretIndex = #firstPart+1
	
	if info.caretIndex > info.scroll+#getTextBeingDrawnIntoEdit(info.text,info.scroll, #info.text, info.width-8) then
		info.scroll = info.scroll + 1
	end
	--[[outputDebugString(info.caretIndex.." "..#info.text.." "..getElementMaxScroll(elementInFocus).." "..info.height)
	if ( info.caretIndex == #info.text and getElementMaxScroll(elementInFocus) > 0 ) then
		info.scrollPixels = getElementMaxScroll(elementInFocus)
	end--]]
	triggerEvent("onUSGGUIChange",elementInFocus, oldText, info.text)
end

function onClientKey(orgKey,pressed)
	if not isElement(elementInFocus) or not pressed then return true end
	local info = GUIinfo[elementInFocus]
	if not ( isGUIVisible(elementInFocus) ) then return true end
	if ( info.guiType == "gridlist" or info.guiType == "treeview" or info.guiType == "scrollarea" or info.guiType == "memo" ) then
		if orgKey == "mouse_wheel_up" or orgKey == "mouse_wheel_down" then		
			local height = info.height
			local maxScroll = getElementMaxScroll(elementInFocus)
			if ( maxScroll) then
				if orgKey == "mouse_wheel_down" then
					if ( info.scrollPixels+(0.08*maxScroll) < maxScroll and info.scrollPixels < maxScroll) then
						info.scrollPixels = math.min(getElementMaxScroll(elementInFocus),info.scrollPixels+(0.08*maxScroll))
					end
				elseif orgKey == "mouse_wheel_up" then
					info.scrollPixels = math.max(0,info.scrollPixels-(0.08*(maxScroll)))
				end
			end
		end
	end
	if ( info.guiType == "editbox" or info.guiType == "memo" ) then
		if not getKeyState(orgKey) and isTimer(holdKeyTimers[orgKey]) then killTimer(holdKeyTimers[orgKey]) return end
		if orgKey == "arrow_r" or orgKey == 'arrow_l' or orgKey == "arrow_u" or orgKey == "arrow_d" then
			local caret = info.caretIndex
			if caret > 0 and orgKey == "arrow_l" then
				info.caretIndex = caret - 1
			elseif caret < #info.text and orgKey == "arrow_r" then		
				info.caretIndex = caret + 1
			elseif ( orgKey == "arrow_d" ) then -- add 1 line
				--
			elseif ( orgKey == "arrow_u" ) then -- substract 1 line
				--info.caretIndex = caret - #info.lines[1]
			end			
		elseif orgKey == 'backspace' or orgKey == 'delete' then		
			local oldText = getText(elementInFocus)
			if orgKey == 'backspace' and (info.caretIndex or 1) >= 1 then		
				local firstPart = string.sub(oldText, 0, info.caretIndex-1)
				local lastPart = string.sub(oldText, info.caretIndex+1)	
				info.text = firstPart..lastPart
				info.caretIndex = info.caretIndex-1
				info.scroll = math.max(0,info.scroll-1)
			elseif orgKey == 'delete' and info.caretIndex <= #info.text then		
				local firstPart = string.sub(oldText, 0, info.caretIndex)
				local lastPart = string.sub(oldText, info.caretIndex+2)	
				info.text = firstPart..lastPart	
				info.caretIndex = info.caretIndex
			end
			triggerEvent("onUSGGUIChange",elementInFocus, oldText, info.text)
		elseif orgKey == "enter" then
			onClientCharacter(string.char(1))
		else return
		end
		if ( getElementMaxScroll(elementInFocus) and info.scrollPixels > getElementMaxScroll(elementInFocus) ) then
			info.scrollPixels = 0
		end
		
		if info.caretIndex < info.scroll then
			info.scroll = info.caretIndex
		elseif info.caretIndex > info.scroll+#getTextBeingDrawnIntoEdit(info.text,info.scroll, #info.text, info.width-8) then
			info.scroll = info.scroll + 1
		end
		if not isTimer(holdKeyTimers[orgKey]) then --not isTimer(checkKeyHoldTimers[orgKey]) and not isTimer(holdKeyTimers[orgKey]) then
			if isTimer(checkKeyHoldTimers[orgKey]) then killTimer(checkKeyHoldTimers[orgKey]) end
			checkKeyHoldTimers[orgKey] = setTimer(
			function (key)
				if getKeyState(key) and not isTimer(holdKeyTimers[key]) then
					holdKeyTimers[key] = setTimer(onClientKey, 60, 0, key,true)
				end
			end, 125, 1, orgKey )
		end
	end
end
addEventHandler("onClientKey",root,onClientKey)
addEventHandler("onClientCharacter",root,onClientCharacter)

local GUIElementBeingHeld
local mouseXdragOffset, mouseYdragOffset
local timeAdded

addEvent("onUSGGUIClick", true)
addEvent("onUSGGUITabSwitch", true)

function getPositionInElementTable(element)
	for i=1,#GUIelements do
		if GUIelements[i] == element then		
			return i			
		end		
	end
end

function checkElementForClick(element,startx,starty,cx,cy)
	local section, clicked, elX, elY
	if GUIinfo[element] and not ( GUIinfo[element].ignoreOnRender or GUIinfo[element].visible == false or GUIinfo[element].disabled == true ) then
		local x,y = GUIinfo[element].x+startx, GUIinfo[element].y+starty
		elX,elY = x,y
		local info = GUIinfo[element]	
		local elementStartX, elementStartY, elementEndX, elementEndY = x, y, x+info.width, y+info.height	
		local originalX,originalY,originalEndX,originalEndY = elementStartX, elementStartY, elementEndX, elementEndY
		if info.guiType == "window" then
			elementStartY = elementStartY-23
		elseif info.guiType == "combobox" then
			local yoffset = 0
			local heightoffset = 0
			if not info.collapsed then
				heightoffset = #info.options*info.height
				if info.direction == 'up' then
					yoffset = -(#info.options*info.height)
				end
			end
			elementStartY = elementStartY+yoffset
			elementEndY = elementStartY+heightoffset+info.height				
		end
		if ( cx > elementStartX and cx < elementEndX ) and ( cy > elementStartY and cy < elementEndY ) then
			clicked = element
			section = false
			if info.guiType == "window" then
				if cy < elementStartY+23 then
					section = "title"
				end
			elseif info.guiType == "tabpanel" then
				if cy < elementStartY+info.tabHeaderHeight then
					section = "tabheader"
				end
			elseif info.guiType == "combobox" then
				if ( cx > originalX and cx < originalEndX ) and ( cy > originalY and cy < originalEndY ) then
					section = 'current'	
				elseif not info.collapsed and info.direction == 'up' and cy < originalY then
					local distanceFromTop = cy - elementStartY
					local option = math.floor(distanceFromTop/info.height)
					option = #info.options - option
					if info.currentOption and option >= info.currentOption then option = option + 1 end
					section = tostring(option)
				elseif not info.collapsed and info.direction == 'down' and cy > originalEndY then
					local distanceFromTop = cy - originalEndY
					local option = math.ceil(distanceFromTop/info.height)
					if info.currentOption and option >= info.currentOption then option = option + 1 end
					section = tostring(option)			
				end
			end
			local children = getElementChildren(element)
			for i=1,#children do
				local csection, cclicked, celX, celY
				if ( info.guiType == "scrollarea" ) then
					local cInfo = GUIinfo[children[i]]
					local scroll = info.scrollPixels
					if ( cInfo and cInfo.y-scroll >= 0 and cInfo.y-scroll <= info.height ) then
						csection, cclicked, celX, celY = checkElementForClick(children[i],x,y-info.scrollPixels, cx,cy)
					end
				else
					csection, cclicked, celX, celY = checkElementForClick(children[i],x,y, cx,cy)
				end
				if ( isElement(cclicked) ) then
					section, clicked, elX, elY = csection, cclicked, celX, celY
				end
			end
		end
	end
	return section, clicked, elX, elY
end

function getClickedElement(sx,sy)
	local section, clicked
	local children = getElementChildren(getResourceDynamicElementRoot(getThisResource()),"USGGUI")
	table.sort(children, function (a,b) return GUIorder[a] > GUIorder[b] end)
	for i=1,#children do
		local csection, cclicked, celX, celY = checkElementForClick(children[i],0,0,sx,sy)
		if ( isElement(cclicked) ) then
			section, clicked, elX, elY = csection, cclicked, celX, celY
			break
		end
	end
	elementInFocus = clicked
	return clicked, section, elX, elY
end

local sliderBeingHeld
local elementScrollHeld = {}

function onClientClick(button,state, sx, sy)
	local element, section, elX, elY = getClickedElement(sx, sy)
	if isElement(element) then
		local info = GUIinfo[element]
		local loc,height = getElementScrollBarDimensions(element)
		if ( info.guiType == "gridlist" or info.guiType == "scrollarea" or info.guiType == "memo" ) and
		( loc and height and loc+elY <= sy and loc+elY+height >= sy and sx > elX+info.width-12 ) then
			mouseXdragOffset, mouseYdragOffset = sx-info.x,sy-info.y	
			if not GUIElementBeingHeld then			
				GUIElementBeingHeld = element
				timeAdded = getTickCount()				
			end
			local scrollLoc, _ = getElementScrollBarDimensions(element)
			if not ( elementScrollHeld.element ) then
				elementScrollHeld = { element = element, Yoffset = sy-elY-scrollLoc+2, elY = elY }
			end
		elseif info.guiType == "window" and section == 'title' and button == 1 then			
			if state == 'down' then		
				mouseXdragOffset, mouseYdragOffset = sx-info.x,sy-info.y	
				if not GUIElementBeingHeld then			
					GUIElementBeingHeld = element
					timeAdded = getTickCount()				
				end				
			end
		elseif info.guiType == "tabpanel" then
			if ( section == "tabheader" ) then
				local tabs = getTabPanelHeaders(element, elX) or {}
				for i=1,#tabs do
					local startX,endX = tabs[i].tabX,tabs[i].tabX+tabs[i].headerWidth
					if ( startX <= sx and endX >= sx and not tabs[i].info.disabled ) then
						if ( info.selectedTab ~= tabs[i].element ) then
							triggerEvent("onUSGGUITabSwitch",element,tabs[i].element)
						end
						info.selectedTab = tabs[i].element
						tabs[i].info.visible = true
						break
					end
				end
				for i=1,#tabs do	
					if ( tabs[i].element ~= info.selectedTab ) then -- unselect
						tabs[i].info.visible = false
					end
				end
			end
		elseif info.guiType == "editbox" or info.guiType == "memo" then 		
			if info.clearOnClick then
				setText(element,"")
				info.clearOnClick = false
			end
			if info.maskedAfterClick then
				info.maskedAfterClick = false
				info.masked = true
			end
			elementInFocus = element
		elseif info.guiType == "gridlist" then 		
			if state == 'down' then
				-- check for scrollbar first
				local loc,height = getElementScrollBarDimensions(element)
				if ( loc and height and loc+elY <= sy and loc+elY+height >= sy and sx > elX+info.width-12 ) then

				else
					local rows = info.rows
					table.sort(rows, function (a,b) return a.sortIndex < b.sortIndex end )
					local x,y = sx-elX, sy-elY-22
					local rowClicked, columnClicked
					for rowIndex=1,#rows do
						local rowY = ((rowIndex-1)*20)-info.scrollPixels
						if y > rowY and y < rowY+20 then					
							rowClicked = rowIndex
							if info.selectionMode ~= 0 then					
								local width = 0
								for column=1,#rows[rowIndex] do				
									local columnX, columnY, columnWidth = info.x+width, info.y, (info.columns[column].width*info.width)
									width = width + (info.columns[column].width*info.width)
									if x > columnX and x < columnX+columnWidth then
										columnClicked = column
										break
									end			
								end							
							end						 
							break					
						end			
					end				
					info.selectedRow = rowClicked
					info.selectedColumn = columnClicked
				end
			end			
		elseif info.guiType == "checkbox" and state == 'down' then		
			info.isChecked = not info.isChecked			
		elseif info.guiType == "slider" and state == 'down' then		
			local _,opY = sliderGetOptionPosition(element,1)
			if sy-elY >= opY-7 and sy-elY <= opY+8 then
				local options = info.options
				local optionSet
				for i=1,#options do
					local opX,_ = sliderGetOptionPosition(element,i)
					if sx-elX >= opX and sx-elX <= opX+15 and sy-elY >= opY-7 and sy-elY <= opY+8 then
						info.selection = i
						info.selectionPos = nil
						optionSet = true
						break
					end
				end
				if not optionSet and info.interpolateNumbers then
					sliderBeingHeld = {element=element,elX=elX,elY=elY}
					info.selectionPos = sx-elX-(info.selOptionSize/2)
					info.selection = nil
				end
			end
		elseif info.guiType == "combobox" and state == 'down' then
			if section == 'current' then
				info.collapsed = not info.collapsed
			else			
				local option = tonumber(section)
				triggerEvent( "onUSGGUIComboBoxChange", element, option, info.currentOption )
				info.currentOption = option
				info.collapsed = true
			end		
		end
		triggerEvent( "onUSGGUIClick", element, button, state, section, sx, sy )		
	end
	
	if state == 'up' then	
		GUIElementBeingHeld = nil
		elementScrollHeld = {}
	end		
end

function manageMouseOnRender()
	if ( isElement(elementInFocus) and ( GUIinfo[elementInFocus].guiType == "editbox" or GUIinfo[elementInFocus].guiType == "memo" )
	and isGUIVisible(elementInFocus) ) then
		toggleAllControls(not onEditDisableControls)
	else
		toggleAllControls(true)
	end
	if not isCursorShowing() then return false end
	local cursorX,cursorY = getCursorPosition()
	cursorX,cursorY = cursorX*screenWidth,cursorY*screenHeight

	if GUIinfo[GUIElementBeingHeld] and GUIinfo[GUIElementBeingHeld].guiType == "window" then
		if not timeAdded or getTickCount() - 50 > timeAdded then
			GUIinfo[GUIElementBeingHeld].x, GUIinfo[GUIElementBeingHeld].y = cursorX-mouseXdragOffset,cursorY-mouseYdragOffset
			if timeAdded then setCursorPosition(GUIinfo[GUIElementBeingHeld].x+mouseXdragOffset, GUIinfo[GUIElementBeingHeld].y+mouseYdragOffset) end
			timeAdded = nil
		end	
	end	
	if ( elementScrollHeld.element ) then
		local loc,height = getElementScrollBarDimensions(elementScrollHeld.element)
		local info = GUIinfo[elementScrollHeld.element]
		local scrollBarY = elementScrollHeld.elY+loc
		local scrollBarEndY = scrollBarY+height
		--outputDebugString(cursorY)
		--outputDebugString(cursorY-elementScrollHeld.Yoffset)
		--outputDebugString(elementScrollHeld.Yoffset)
		local relCursorY
		if ( info.guiType == "gridlist" ) then
			relCursorY = (cursorY-elY-elementScrollHeld.Yoffset-22)/(info.height-22-elementScrollHeld.Yoffset)
		else
			relCursorY = (cursorY-elY-elementScrollHeld.Yoffset)/(info.height-elementScrollHeld.Yoffset)
		end
		local scrollPos = relCursorY * getElementMaxScroll(elementScrollHeld.element)
		info.scrollPixels = math.min(getElementMaxScroll(elementScrollHeld.element),math.max(0,scrollPos))
	end
	local mouseButton, state
	local currentLeftMouseState = getKeyState("mouse1")
	local currentRightMouseState = getKeyState("mouse2")
	local currentMidMouseState = getKeyState("mouse3")
	if currentLeftMouseState ~= leftMouseState then
		if currentLeftMouseState == false then
			mouseButton, state = 1,'up'
		else
			mouseButton, state = 1,'down'
		end
		leftMouseState = currentLeftMouseState
	end
	if currentRightMouseState ~= rightMouseState then
		if currentRightMouseState == false then
			mouseButton, state = 2,'up'
		else
			mouseButton, state = 2,'down'
		end
		rightMouseState = currentRightMouseState
	end
	if currentMidMouseState ~= midMouseState then
		if currentMidMouseState == false then
			mouseButton, state = 3,'up'
		else
			mouseButton, state = 3,'down'
		end
		midMouseState = currentMidMouseState
	end
	-- slider
	
	if sliderBeingHeld and isElement(sliderBeingHeld.element) then
		local el = sliderBeingHeld.element
		local info = GUIinfo[el]
		local elX,elY = sliderBeingHeld.elX, sliderBeingHeld.elY
		local opX,opY = sliderGetOptionPosition(el,1)
		if cursorX-elX >= opX+(info.selOptionSize/2) and cursorX-elX <= info.width-(info.selOptionSize/2)
		and ( leftMouseState or rightMouseState ) and cursorY-elY >= opY-7 and cursorY-elY <= opY+8 then
			info.selectionPos = cursorX-elX-(info.selOptionSize/2)
			local option1,option2 = 1,2
			for i=1,#info.options do
				local opX,opY = sliderGetOptionPosition(el,i)
				if cursorX-elX >= opX then
					if info.options[i+1] then
						option1,option2 = i,i+1
					end
				end
			end
			local op1X, _,widthFromStart = sliderGetOptionPosition(el,option1)
			local op2X, _ = sliderGetOptionPosition(el,option2)
			local widthBetweenOptions = op2X-op1X
			local relative = (info.selectionPos-widthFromStart)/widthBetweenOptions
			local vStart,vEnd = info.options[option1], info.options[option2]-info.options[option1]

			info.interpolatedNumber = tonumber(string.format("%."..info.numOfDecimals.."f", (relative*vEnd)+vStart))
			setCursorPosition(cursorX,opY+elY)
		else
			if ( info.interpolatedNumber ) then
				for i=1,#info.options do
					local opX,opY = sliderGetOptionPosition(el,i)
					if ( cursorX-elX >= opX and cursorX-elX <= opX+info.optionSize ) or info.interpolatedNumber == info.options[i] then
						info.selectionPos = false
						info.selection = i
						break
					end
				end				
			end
			sliderBeingHeld = false		
		end
	end	
	
	if mouseButton and state then
		onClientClick(mouseButton, state,cursorX,cursorY)
	end
end