
function createWindow(x,y,width,height,relative,title,parent,color)
	if x and y and width and height and title then

		if relative then
	
			x,y = math.max(math.min(x,1),0)*screenWidth,math.max(math.min(y,1),0)*screenHeight
			width,height = math.max(math.min(width,1),0)*screenWidth,math.max(math.min(height,1),0)*screenHeight		
			
		end
		if not color then color = tocolor(0,0,0,190) end
		local element = addElement()
		if parent then setElementParent(element,parent) end
		GUIinfo[element] = { guiType = "window", x = x,y = y, width = width,height = height,text = title,color = color, order = getTickCount(), visible = true, resource = sourceResourceRoot }
		sortGUI()
		return element
		
	end
	
end

function addElement()

	return createElement("GNRGUI")
	
end

function createButton(x,y,width,height,relative,title,parent,color)
	if x and y and width and height and title then

		if relative then
	
			x,y = math.max(math.min(x,1),0)*screenWidth,math.max(math.min(y,1),0)*screenHeight
			width,height = math.max(math.min(width,1),0)*screenWidth,math.max(math.min(height,1),0)*screenHeight		
			
		end
		if not color then color = tocolor(0,0,0,190) end
		local element = addElement()
		if isElement(parent) then setElementParent(element,parent) end
		GUIinfo[element] = { guiType = "button", x = x,y = y, width = width,height = height,text = title,color = color, order = getTickCount(), visible = true, resource = sourceResourceRoot }
		sortGUI()
		return element
		
	end
	
end