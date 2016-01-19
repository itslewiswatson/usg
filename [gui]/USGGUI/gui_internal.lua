_getCursorPosition = getCursorPosition
function getCursorPosition()
	local cx,cy,_,_,_ = _getCursorPosition()
	if(cx and cy) then
		return cx*screenWidth, cy*screenHeight
	end
	return cx, cy
end

function selectRadioButton(element)
	local info = GUIinfo[element]
	local parent = getElementParent(element)
	if(not GUIinfo[parent]) then
		parent = getResourceDynamicElementRoot(getThisResource())
	end
	local parentChildren = getElementChildren(parent, "USGGUI")
	for i, child in ipairs(parentChildren) do
		if(child ~= element) then
			local cInfo = GUIinfo[child]
			if(cInfo and cInfo.guiType == "radiobutton") then
				cInfo.selected = false
			end
		end
	end
	info.selected = true
end

function sortGridList(grid)
	local info = GUIinfo[grid]
	for row=1,info.rowCount do
		local itemValue = gridlistGetItemText(grid, row, info.sortColumn)
		if(itemValue and not info.rows[row][info.sortColumn].sortIndex) then
			info.rows[row][info.sortColumn].sortIndex = tonumber(itemValue) or 0
		end
	end
	table.sort(info.displayedRows, function (a, b)
		local rowA = info.rows[a]
		local rowB = info.rows[b]
		if(not rowA or not rowB) then return false end
		if(info.sortAscending) then
			return rowA[info.sortColumn].sortIndex > rowB[info.sortColumn].sortIndex
		else
			return rowB[info.sortColumn].sortIndex > rowA[info.sortColumn].sortIndex
		end
	end)
end

function getElementParentTotalPosition(element)
	local info = GUIinfo[element]
	if(info) then
		local parent = getElementParent(element)
		local x, y = 0, 0
		while(parent and GUIinfo[parent]) do
			x = x + GUIinfo[parent].x
			y = y + GUIinfo[parent].y
			parent = getElementParent(element)
		end

		return x, y
	end
	return false
end

function isElementHovered(element, parentX, parentY)
	if(not isCursorShowing()) then return false end
	local info = GUIinfo[element]
	if(info) then
		if(not parentX or not parentY) then
			parentX, parentY = getElementParentTotalPosition(element)
		end
		local cx, cy = getCursorPosition()
		local x,y = info.x+(parentX or 0), info.y+(parentY or 0)
		local elX,elY = x,y
		local elementStartX, elementStartY, elementEndX, elementEndY = x, y, x+info.width, y+info.height	
		local originalX,originalY,originalEndX,originalEndY = elementStartX, elementStartY, elementEndX, elementEndY
		local hovered, section = false, false
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
			hovered = true
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
		end
		return hovered, section
	end
	return false
end