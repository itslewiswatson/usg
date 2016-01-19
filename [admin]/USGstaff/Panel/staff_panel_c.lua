-- misc vars
punishTextChangeDialog = false
selectedPlayer = false

-- GUI vars

windowWidth,windowHeight = 800, 600
playerSearchHeight = 25
gridWidth, gridHeight = 200, windowHeight-playerSearchHeight
tabWidth, tabHeight = windowWidth - gridWidth - 5, windowHeight-25
tabPanelHeight = tabHeight+25

panelGUI = {}

function createPanel()
	if not ( isElement(panelGUI.window) ) then
		-- containers and main items
		exports.USGGUI:setDefaultTextAlignment("left","center")
		panelGUI.window = exports.USGGUI:createWindow('center','center',windowWidth,windowHeight,false,"USG ~ Staff Panel")
		panelGUI.playersearch = exports.USGGUI:createEditBox('left','top',gridWidth,playerSearchHeight,false,"",panelGUI.window)
			addEventHandler("onUSGGUIChange",panelGUI.playersearch,onPlayerSearchChange, false)
		panelGUI.playergrid = exports.USGGUI:createGridList('left','bottom',gridWidth,gridHeight,false,panelGUI.window)
			addEventHandler("onUSGGUIClick",panelGUI.playergrid,onClickPlayerGrid, false)
			exports.USGGUI:gridlistAddColumn(panelGUI.playergrid,"Players",1)
		panelGUI.tabpanel = exports.USGGUI:createTabPanel('right','center',tabWidth,tabPanelHeight,false,panelGUI.window,tocolor(0,0,0,0))
			exports.USGGUI:setProperty(panelGUI.tabpanel,"tabHeaderHeight", 25)
		-- tabs
			createPlayerInfoTab()
			createPlayerActionsTab()
			createPunishmentsTab()
			panelGUI.accounts = {tab = exports.USGGUI:addTab(panelGUI.tabpanel,"Accounts")}		
			panelGUI.server = {tab = exports.USGGUI:addTab(panelGUI.tabpanel,"Server")}
			createBansTab()
			panelGUI.playerlookup = {tab = exports.USGGUI:addTab(panelGUI.tabpanel,"Look-up")}
		-- tab gui
			
			-- accounts
			
			-- server
			
			-- look-up
		-- misc
		fillPlayerGrid()
		applyACL()
		exports.USGGUI:focus(panelGUI.window)
	end
end

function toggleStaffPanel()
	if ( exports.USGadmin:isPlayerStaff() ) then
		if ( not isElement(panelGUI.window) ) then
			createPanel()
			showCursor(true)
			fillPlayerGrid(exports.USGGUI:getText(panelGUI.playersearch))
		else
			local state = not exports.USGGUI:getVisible(panelGUI.window)
			exports.USGGUI:setVisible(panelGUI.window,state)
			showCursor(state)
			exports.USGGUI:closeDialog(punishTextChangeDialog)
			if(state) then
				exports.USGGUI:focus(panelGUI.window)
			end
		end
	end
end
addCommandHandler("staffpanel",toggleStaffPanel)
