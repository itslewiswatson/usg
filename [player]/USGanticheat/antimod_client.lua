local modInfoGUI = {}

addEvent("USGanticheat.onShowModInfo",true)
addEventHandler("USGanticheat.onShowModInfo",root,
	function (newModInfo)
		if not isElement(modInfoGUI.window) then
			modInfoGUI.window = exports.USGGUI:createWindow('center','center',600,400,false,"Illegal mods")
			modInfoGUI.mainlabel = exports.USGgui:createLabel(0,0,600,20,false,"You have illegal mods installed, please restore the following mods:",modInfoGUI.window,tocolor(255,0,0))
			modInfoGUI.grid = exports.USGgui:createGridList(0,20,600,400-80,false,modInfoGUI.window)
				exports.USGgui:gridlistAddColumn(modInfoGUI.grid, "Name",1)
			modInfoGUI.infolabel = exports.USGgui:createLabel(0,400-20,600,20,false,
				"Lost your backup? Download a backup at https://USGmta.co/downloads/GTA/gta3.rar",modInfoGUI.window, tocolor(255,255,0))
			modInfoGUI.close = exports.USGGUI:createButton("center", 400-55, 100, 30, false, "Close", modInfoGUI.window)
			addEventHandler("onUSGGUISClick",modInfoGUI.close, closeModGUI, false)
			showCursor(true)
		end
		loadMods(newModInfo)
	end
)

function loadMods(modInfo)
	if ( isElement ( modInfoGUI.grid ) and modInfo ) then
		exports.USGgui:gridlistClear(modInfoGUI.grid)
		for i, name in ipairs(modInfo) do
			local row = exports.USGgui:gridlistAddRow(modInfoGUI.grid)
			exports.USGgui:gridlistSetItemText(modInfoGUI.grid,row,1,name)
		end
	end
end

function closeModGUI()
	if(isElement(modInfoGUI.window)) then
		destroyElement(modInfoGUI.window)
		showCursor(false)
	end
end