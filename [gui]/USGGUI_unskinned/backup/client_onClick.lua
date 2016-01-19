
local mouseXdragOffset, mouseYdragOffset
local timeAdded

addEvent("onGNRGUIClick", true)
addEventHandler("onGNRGUIClick", root,
function (button,state, section, sx, sy)

	outputDebugString("onGNRGUIClick:"..tostring(source)..", "..tostring(button)..", "..tostring(state)..", "..tostring(section) )
	
	if GUIinfo[source].guiType == "window" and section == 'title' and button == '1' then
	
		if state == 'down' then
		
			mouseXdragOffset, mouseYdragOffset = sx-GUIinfo[source].x,sy-GUIinfo[source].y
	
			if not GUIElementBeingHold then
			
				GUIElementBeingHold = source
				timeAdded = getTickCount()
				
			end
	
		else
		
			if GUIElementBeingHold then
			
				GUIElementBeingHold = nil
			
			end
		
		end
		
	end
	
end
)

function getClickedElement(x,y)

	local section
	local clicked
	for element, info in pairs(GUIinfo) do
	
		local parentInfo = GUIinfo[getElementParent(element)]
		local parentX,parentY = 0, 0
		if parentInfo then
			parentX,parentY = parentInfo.x, parentInfo.y
		end
		local elementStartX, elementStartY, elementEndX, elementEndY = info.x+parentX, info.y+parentY, info.x+parentX+info.width, info.y+info.height+parentY	
		if info.guiType == 'window' or ( parentInfo and parentInfo.guiType == 'window' ) then elementStartY = elementStartY - 23 end
		if ( x > elementStartX and x < elementEndX ) and ( y > elementStartY and y < elementEndY ) then

			
			clicked = element
			section = false
			if info.guiType == "window" then
				if y < elementStartY+23 then
					section = "title"
				end
			end
			
		end
	
	end
	
	if clicked then
	
		return clicked, section
	
	end

end

function onClientClick(button,state, sx, sy)

	local element, section = getClickedElement(sx, sy)
	if element then
		triggerEvent( "onGNRGUIClick", element, button, state, section, sx, sy )
	end
	
end

function manageMouseOnRender()

	if not isCursorShowing() then return false end
	local cursorX,cursorY = getCursorPosition()
	cursorX,cursorY = cursorX*screenWidth,cursorY*screenHeight
	
	if GUIinfo[GUIElementBeingHold] then 
	
		if not timeAdded or getTickCount() - 125 > timeAdded then 
	
			GUIinfo[GUIElementBeingHold].x, GUIinfo[GUIElementBeingHold].y = cursorX-mouseXdragOffset,cursorY-mouseYdragOffset
			if timeAdded then setCursorPosition(GUIinfo[GUIElementBeingHold].x+mouseXdragOffset, GUIinfo[GUIElementBeingHold].y+mouseYdragOffset) end
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
	
end