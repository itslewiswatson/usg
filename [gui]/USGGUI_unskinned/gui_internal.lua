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