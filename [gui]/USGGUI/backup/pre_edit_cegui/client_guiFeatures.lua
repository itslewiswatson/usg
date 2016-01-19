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

function onClientCharacter(key)

	if not isElement(editInFocus) then return end
	local info = GUIinfo[editInFocus]
	local oldText = info.text
	local firstPart = string.sub(oldText, 0,info.caretIndex)
	local lastPart = string.sub(oldText, info.caretIndex+1)
	setText(editInFocus, firstPart..key..lastPart )
	info.caretIndex = math.min(#firstPart+1)
	
	if info.caretIndex >= info.scroll+#getTextBeingDrawnIntoEdit(info.text,info.scroll, info.scrollEnd or #info.text, info.width-4) then

		info.scroll = info.scroll + 1
		outputDebugString('addScroll')
	
	end
	
end

function onClientKey(orgKey,pressed)

	if not getKeyState(orgKey) and isTimer(holdKeyTimers[orgKey]) then killTimer(holdKeyTimers[orgKey]) return end
	if not isElement(editInFocus) or not pressed then return end
	
	if orgKey == "arrow_r" or orgKey == 'arrow_l' then
	
		local caret = GUIinfo[editInFocus].caretIndex
		if caret > 0 and orgKey == "arrow_l" then
		
			GUIinfo[editInFocus].caretIndex = caret - 1
			
		elseif caret < #GUIinfo[editInFocus].text and orgKey == "arrow_r" then
		
			GUIinfo[editInFocus].caretIndex = caret + 1
			
		end		
		
	elseif orgKey == 'backspace' or orgKey == 'delete' then
		
		if orgKey == 'backspace' and GUIinfo[editInFocus].caretIndex >= 1 then
		
			local oldText = getText(editInFocus)
			local firstPart = string.sub(oldText, 0, GUIinfo[editInFocus].caretIndex-1)
			local lastPart = string.sub(oldText, GUIinfo[editInFocus].caretIndex+1)	
			GUIinfo[editInFocus].text = firstPart..lastPart
			GUIinfo[editInFocus].caretIndex = GUIinfo[editInFocus].caretIndex-1
			
		elseif orgKey == 'delete' and GUIinfo[editInFocus].caretIndex < #GUIinfo[editInFocus].text then
		
			local oldText = getText(editInFocus)
			local firstPart = string.sub(oldText, 0, GUIinfo[editInFocus].caretIndex)
			local lastPart = string.sub(oldText, GUIinfo[editInFocus].caretIndex+2)	
			GUIinfo[editInFocus].text = firstPart..lastPart	
			GUIinfo[editInFocus].caretIndex = GUIinfo[editInFocus].caretIndex
		end
		
	else return
		
	end
	
	if GUIinfo[editInFocus].caretIndex < GUIinfo[editInFocus].scroll then
	
		GUIinfo[editInFocus].scroll = GUIinfo[editInFocus].scroll-1		
		
	end

	if not isTimer(holdKeyTimers[orgKey]) then --not isTimer(checkKeyHoldTimers[orgKey]) and not isTimer(holdKeyTimers[orgKey]) then
		if isTimer(checkKeyHoldTimers[orgKey]) then killTimer(checkKeyHoldTimers[orgKey]) end
		checkKeyHoldTimers[orgKey] = setTimer( 
		function (key) 
			if getKeyState(key) and not isTimer(holdKeyTimers[key]) then 
				holdKeyTimers[key] = setTimer(onClientKey, 60, 0, key,true)
			end
		end, 200, 1, orgKey )
		
	end
end
addEventHandler("onClientKey",root,onClientKey)
addEventHandler("onClientCharacter",root,onClientCharacter)

local GUIElementBeingHeld
local mouseXdragOffset, mouseYdragOffset
local timeAdded

addEvent("onGNRGUIClick", true)
addEventHandler("onGNRGUIClick", root,
function (button,state, section, sx, sy)

	outputDebugString("onGNRGUIClick:"..tostring(source)..", "..tostring(button)..", "..tostring(state)..", "..tostring(section) )
	
end
)

function getPositionInElementTable(element)

	for i=1,#GUIelements do
	
		if GUIelements[i] == element then
		
			return i
			
		end
		
	end

end

function getClickedElement(x,y)

	local section
	local clicked
	local clickedPos
	
	for elementID=1,#GUIelements do
	
		local element = GUIelements[elementID]
		local info = GUIinfo[element]	
		local parentInfo = GUIinfo[getElementParent(element)]
		local parentX,parentY = 0, 0
		if parentInfo then
			parentX,parentY = parentInfo.x, parentInfo.y
		end

		local elementStartX, elementStartY, elementEndX, elementEndY = info.x+parentX, info.y+parentY, info.x+parentX+info.width, info.y+info.height+parentY	
		local originalX,originalY,originalEndX,originalEndY = elementStartX, elementStartY, elementEndX, elementEndY
		if info.guiType == "window" then
			elementStartY = elementStartY-23
			
		elseif info.guiType == "combobox" then
			local yoffset = 0
			local heightoffset = #info.options*info.height
			if info.direction == 'up' then
				yoffset = -(#info.options*info.height)
			end
			elementStartY = elementStartY+yoffset
			elementEndY = elementStartY+heightoffset+info.height
			
		end
		if ( x > elementStartX and x < elementEndX ) and ( y > elementStartY and y < elementEndY ) and ( not clickedPos or getPositionInElementTable(element) > clickedPos ) then
	
			clicked = element
			clickedPos = getPositionInElementTable(element)
			section = false
			if info.guiType == "window" then
				if y < elementStartY+23 then
					section = "title"
				end
			elseif info.guiType == "combobox" then
			
				if ( x > originalX and x < originalEndX ) and ( y > originalY and y < originalEndY ) then
				
					section = 'current'
					
				elseif info.direction == 'up' and y < originalY then
					
					local distanceFromTop = y - elementStartY
					local option = math.floor(distanceFromTop/info.height)
					option = #info.options - option
					if info.currentOption and option >= info.currentOption then option = option + 1 end	
					section = tostring(option)
					
				elseif info.direction == 'down' and y > originalEndY then
					
					local distanceFromTop = y - originalEndY
					local option = math.ceil(distanceFromTop/info.height)
					if info.currentOption and option >= info.currentOption then option = option + 1 end
	
					section = tostring(option)
					
				end
				
			end
			
		end
	
	end
	
	if clicked then
	
		return clicked, section
	
	end

end

local sliderBeingHeld

function onClientClick(button,state, sx, sy)

	local element, section = getClickedElement(sx, sy)
	if isElement(element) then
	
		if editInFocus then
			toggleAllControls(true)
		end	
		editInFocus = nil
		local info = GUIinfo[element]
		
		if info.guiType == "window" and section == 'title' and button == '1' then
			
			if state == 'down' then
		
				mouseXdragOffset, mouseYdragOffset = sx-info.x,sy-info.y
	
				if not GUIElementBeingHeld then
			
					GUIElementBeingHeld = element
					timeAdded = getTickCount()
				
				end
				
			end
		
		elseif info.guiType == "editbox" then 
		
			if info.clearOnClick then
				--guiSetText(info.realEdit,"")
				setText(element,"")
				info.clearOnClick = false
			end
			if info.maskedAfterClick then
			
				info.maskedAfterClick = false
				info.masked = true
			
			end
			editInFocus = element
			toggleAllControls(not onEditDisableControls)
			
		elseif info.guiType == "gridlist" then 
		
			if state == 'down' then
				local parentInfo = GUIinfo[getElementParent(element)]
				local parentX,parentY = 0, 0
				if parentInfo then
					parentX,parentY = parentInfo.x, parentInfo.y
				end
				
				local rows = info.rows
				table.sort(rows, function (a,b) return a.sortIndex < b.sortIndex end )
				local x,y = sx-parentX, sy-parentY
				local gy = info.y+20
				local rowClicked, columnClicked
				for rowIndex=1,#rows do
					
					if y > gy+((rowIndex-1)*20) and y < gy+(((rowIndex+1)-1)*20) then
						
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
				outputDebugString('rowClicked='..tostring(rowClicked) )
				outputDebugString('columnClicked='..tostring(columnClicked) )
				
			end
			
		elseif info.guiType == "checkbox" and state == 'down' then
		
			info.isChecked = not info.isChecked
			
		elseif info.guiType == "slider" and state == 'down' then
		
			local _,opY = sliderGetOptionPosition(element,1)
			if sy >= opY-7 and sy <= opY+8 then 		
			
				local options = info.options
				local optionSet
				for i=1,#options do
			
					local opX,_ = sliderGetOptionPosition(element,i)
					if sx >= opX and sx <= opX+15 and sy >= opY-7 and sy <= opY+8 then
				
						info.selection = i
						info.selectionPos = nil
						optionSet = true
						break
				
					end
					
				end
			
				if not optionSet and info.interpolateNumbers then		
			
					sliderBeingHeld = element
					info.selectionPos = sx-info.x-(info.selOptionSize/2)
					info.selection = nil
				
				end
				
			end
			
		elseif info.guiType == "combobox" and state == 'down' then
		
			if section == 'current' then
		
				info.collapsed = not info.collapsed
				outputDebugString("new collapsed state: "..tostring(info.collapsed))
				
			else
			
				local option = tonumber(section)
				triggerEvent( "onGNRGUIComboBoxChange", element, option, info.currentOption )
				info.currentOption = option
				
			end
		
		end
		triggerEvent( "onGNRGUIClick", element, button, state, section, sx, sy )
		
	end
	
	if GUIElementBeingHeld and state == 'up' then
	
		GUIElementBeingHeld = nil
	
	end	
	
end

function manageMouseOnRender()

	if not isCursorShowing() then return false end
	local cursorX,cursorY = getCursorPosition()
	cursorX,cursorY = cursorX*screenWidth,cursorY*screenHeight
	
	if GUIinfo[GUIElementBeingHeld] then 
	
		if not timeAdded or getTickCount() - 125 > timeAdded then 
	
			GUIinfo[GUIElementBeingHeld].x, GUIinfo[GUIElementBeingHeld].y = cursorX-mouseXdragOffset,cursorY-mouseYdragOffset
			if timeAdded then setCursorPosition(GUIinfo[GUIElementBeingHeld].x+mouseXdragOffset, GUIinfo[GUIElementBeingHeld].y+mouseYdragOffset) end
			timeAdded = nil
			
		end
		
	end
	
	local mouseButton, state
	local currentLeftMouseState = getKeyState("mouse1")
	local currentRightMouseState = getKeyState("mouse2")
	if currentLeftMouseState ~= leftMouseState then
	
		if currentLeftMouseState == false then
		
			mouseButton, state = '1','up'
			
		else
		
			mouseButton, state = '1','down'
			
		end
		leftMouseState = currentLeftMouseState
	
	end
	if currentRightMouseState ~= rightMouseState then
	
		if currentRightMouseState == false then
		
			mouseButton, state = '2','up'
			
		else
		
			mouseButton, state = '2','down'
			
		end
		
		rightMouseState = currentRightMouseState
		
	end
	
	if mouseButton and state then
	
		onClientClick(mouseButton, state,cursorX,cursorY)
	
	end
	
	-- slider
	
	if sliderBeingHeld then
	
		local opX,opY = sliderGetOptionPosition(sliderBeingHeld,1)
		if cursorX >= opX+(GUIinfo[sliderBeingHeld].selOptionSize/2) and cursorX <= GUIinfo[sliderBeingHeld].x+GUIinfo[sliderBeingHeld].width-(GUIinfo[sliderBeingHeld].selOptionSize/2) and ( leftMouseState or rightMouseState ) and cursorY >= opY-7 and cursorY <= opY+8 then

			GUIinfo[sliderBeingHeld].selectionPos = cursorX-GUIinfo[sliderBeingHeld].x-(GUIinfo[sliderBeingHeld].selOptionSize/2)
			local option1,option2 = 1,2
			for i=1,#GUIinfo[sliderBeingHeld].options do
			
				local opX,opY = sliderGetOptionPosition(sliderBeingHeld,i)
				if cursorX >= opX then
				
					if GUIinfo[sliderBeingHeld].options[i+1] then
					
						option1,option2 = i,i+1
					
					end
				
				end
			
			end
			local op1X, _,widthFromStart = sliderGetOptionPosition(sliderBeingHeld,option1)
			local op2X, _ = sliderGetOptionPosition(sliderBeingHeld,option2)
			local widthBetweenOptions = op2X-op1X
			local relative = (GUIinfo[sliderBeingHeld].selectionPos-widthFromStart)/widthBetweenOptions
			GUIinfo[sliderBeingHeld].interpolatedNumber = math.floor(interpolateBetween(GUIinfo[sliderBeingHeld].options[option1], 0, 0, GUIinfo[sliderBeingHeld].options[option2], 0, 0, relative, "Linear"))
			setCursorPosition(cursorX,opY)
			
			
		else
		
			sliderBeingHeld = false
		
		end
	
	end
	
end