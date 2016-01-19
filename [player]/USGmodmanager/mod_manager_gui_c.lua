local modGUI = {}

function createModGUI()
	modGUI.window = exports.USGGUI:createWindow("center","center", 400,500,false,"Mods")
	modGUI.list = exports.USGGUI:createGridList("center", 5, 390, 450, false, modGUI.window)
	exports.USGGUI:gridlistAddColumn(modGUI.list, "Mod", 1)
	modGUI.close = exports.USGGUI:createButton(325, 465, 70, 30, false, "Close", modGUI.window)
	addEventHandler("onUSGGUISClick", modGUI.close, closeModGUI, false)
	addEventHandler("onUSGGUIClick", modGUI.list, onModClick, false)
	-- fill in mods
	for k, mod in pairs(mods) do
		local row = exports.USGGUI:gridlistAddRow(modGUI.list)
		exports.USGGUI:gridlistSetItemText(modGUI.list, row, 1, mod.name)
		exports.USGGUI:gridlistSetItemData(modGUI.list, row, 1, k)
		local r,g,b = 255,0,0
		if(mod.enabled) then r,g,b = 0,255,0 end
		exports.USGGUI:gridlistSetItemColor(modGUI.list, row, 1, tocolor(r,g,b))
	end
end

function closeModGUI()
	if(isElement(modGUI.window) and exports.USGGUI:getVisible(modGUI.window)) then
		exports.USGGUI:setVisible(modGUI.window, false)
		showCursor(false)
	end
end

function openModGUI()
	if(not isElement(modGUI.window)) then
		createModGUI()
	elseif(not exports.USGGUI:getVisible(modGUI.window)) then
		exports.USGGUI:setVisible(modGUI.window, true)
	else
		return -- already showing
	end
	showCursor(true)
end

function toggleModGUI()
	if(isElement(modGUI.window) and exports.USGGUI:getVisible(modGUI.window)) then
		closeModGUI()
	else
		openModGUI()
	end
end
addCommandHandler("mods", toggleModGUI)

function onModClick(btn, state)
	if(btn == 2 and state == "up") then
		-- toggle mod
		local selected = exports.USGGUI:gridlistGetSelectedItem(modGUI.list)
		if(selected) then
			local mod = exports.USGGUI:gridlistGetItemData(modGUI.list, selected, 1)
			if(not mods[mod].enabled) then
				exports.USGGUI:gridlistSetItemColor(modGUI.list, selected, 1, tocolor(0,255,0))
				mods[mod].enabled = true
				downloadMod(mod)
			else
				exports.USGGUI:gridlistSetItemColor(modGUI.list, selected, 1, tocolor(255,0,0))
				deactivateMod(mod)			
			end
		end
	end
end