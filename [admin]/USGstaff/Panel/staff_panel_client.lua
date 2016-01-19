-- GUI vars
windowWidth,windowHeight = 800, 600
playerSearchHeight = 25
gridWidth, gridHeight = 200, windowHeight-playerSearchHeight
tabWidth, tabHeight = windowWidth - gridWidth - 5, windowHeight-25
tabPanelHeight = tabHeight+25

local panelGUI = {}

function createPanel()
	if not ( isElement(panelGUI.window) ) then
		-- containers and main items
		panelGUI.window = exports.USGGUI:createWindow('center','center',windowWidth,windowHeight,false,"USG ~ Staff Panel")
		panelGUI.playersearch = exports.USGGUI:createEditBox('left','top',gridWidth,playerSearchHeight,false,"",panelGUI.window)
		panelGUI.playergrid = exports.USGGUI:createGridList('left','bottom',gridWidth,gridHeight,false,panelGUI.window)
			addEventHandler("onUSGGUIClick",panelGUI.playergrid,onClickPlayerGrid)
			exports.USGGUI:gridlistAddColumn(panelGUI.playergrid,"Players",1)
		panelGUI.tabpanel = exports.USGGUI:createTabPanel('right','center',tabWidth,tabPanelHeight,false,panelGUI.window)
			exports.USGGUI:setProperty(panelGUI.tabpanel,"tabHeaderHeight", 25)
		-- tabs
			panelGUI.playerinfo = {tab = exports.USGGUI:addTab(panelGUI.tabpanel,"Player info")}
			panelGUI.playeractions = {tab = exports.USGGUI:addTab(panelGUI.tabpanel,"Player actions")}
			panelGUI.punishing = {tab = exports.USGGUI:addTab(panelGUI.tabpanel,"Punishments")}
			panelGUI.accounts = {tab = exports.USGGUI:addTab(panelGUI.tabpanel,"Accounts")}
			panelGUI.server = {tab = exports.USGGUI:addTab(panelGUI.tabpanel,"Server")}
			panelGUI.bans = {tab = exports.USGGUI:addTab(panelGUI.tabpanel,"Bans")}
			panelGUI.playerlookup = {tab = exports.USGGUI:addTab(panelGUI.tabpanel,"Look-up")}
		-- tab gui
			--player info
			exports.USGGUI:setDefaultTextAlignment("left","center")
			panelGUI.playerinfo.ip = exports.USGGUI:createLabel("left", "top", tabWidth/2, 20,false,"IP: 127.0.0.1",panelGUI.playerinfo.tab)
			panelGUI.playerinfo.serial = exports.USGGUI:createLabel("right", "top", tabWidth/2, 20,false,"Serial: 12321321312sdfawdw",panelGUI.playerinfo.tab)
			panelGUI.playerinfo.account = exports.USGGUI:createLabel("left", 20, tabWidth/2, 20,false,"Account: account",panelGUI.playerinfo.tab)
			panelGUI.playerinfo.logintime = exports.USGGUI:createLabel("right", 20, tabWidth/2, 20,false,"Logged in at: time",panelGUI.playerinfo.tab)
			panelGUI.playerinfo.position = exports.USGGUI:createLabel("left", 40, tabWidth, 20,false,"Position : x,y,z ( zone [city] )",panelGUI.playerinfo.tab)
			panelGUI.playerinfo.dim = exports.USGGUI:createLabel("left", 60, tabWidth/2, 20,false,"Dimension: 0",panelGUI.playerinfo.tab)
			panelGUI.playerinfo.int = exports.USGGUI:createLabel("right", 60, tabWidth/2, 20,false,"Interior: 0",panelGUI.playerinfo.tab)
			panelGUI.playerinfo.vehicle = exports.USGGUI:createLabel("left", 80, tabWidth/2, 20,false,"Vehicle: Infernus(411)",panelGUI.playerinfo.tab)
			panelGUI.playerinfo.vehiclehp = exports.USGGUI:createLabel("right", 80, tabWidth/2, 20,false,"Health: 1000%",panelGUI.playerinfo.tab)
			panelGUI.playerinfo.health = exports.USGGUI:createLabel("left", 100, tabWidth/2, 20,false,"Health: 150",panelGUI.playerinfo.tab)
			panelGUI.playerinfo.armor = exports.USGGUI:createLabel("right", 100, tabWidth/2, 20,false,"Armor: 0",panelGUI.playerinfo.tab)
			panelGUI.playerinfo.skin = exports.USGGUI:createLabel("left", 120, tabWidth/2, 20,false,"Skin: 0",panelGUI.playerinfo.tab)
			panelGUI.playerinfo.playtime = exports.USGGUI:createLabel("right", 120, tabWidth/2, 20,false,"Hours played: 50",panelGUI.playerinfo.tab)
			panelGUI.playerinfo.team = exports.USGGUI:createLabel("left", 140, tabWidth/2, 20,false,"Team: Staff",panelGUI.playerinfo.tab)
			panelGUI.playerinfo.occupation = exports.USGGUI:createLabel("right", 140, tabWidth/2, 20,false,"Occupation: noob staff",panelGUI.playerinfo.tab)
			panelGUI.playerinfo.money = exports.USGGUI:createLabel("left", 160, tabWidth/2, 20,false,"Money: $2,000",panelGUI.playerinfo.tab)
			panelGUI.playerinfo.bankmoney = exports.USGGUI:createLabel("right", 160, tabWidth/2, 20,false,"Bank money: $5,000",panelGUI.playerinfo.tab)
			panelGUI.playerinfo.premium = exports.USGGUI:createLabel("left", 180, tabWidth/2, 20,false,"Premium hours: 2",panelGUI.playerinfo.tab)
			panelGUI.playerinfo.group = exports.USGGUI:createLabel("right", 180, tabWidth/2, 20,false,"Group: smurfs",panelGUI.playerinfo.tab)
			panelGUI.playerinfo.email = exports.USGGUI:createLabel("left", 200, tabWidth, 20,false,"Email: ex@ex.com",panelGUI.playerinfo.tab)
			panelGUI.playerinfo.punishments = exports.USGGUI:createGridList("center",220,tabWidth-20,tabHeight-225,false,panelGUI.playerinfo.tab, tocolor(10,10,10))
				exports.USGGUI:gridlistAddColumn(panelGUI.playerinfo.punishments, "Punishment", 0.75)
				exports.USGGUI:gridlistAddColumn(panelGUI.playerinfo.punishments, "Date", 0.25)
			-- player actions
			
			-- punishments
			
			-- accounts
			
			-- server
			
			-- bans
			
			-- look-up
		-- misc
		fillPlayerGrid()
	end
end

function toggleStaffPanel()
	if ( exports.USGadmin:isPlayerStaff() ) then
		if ( not isElement(panelGUI.window) ) then
			createPanel()
			showCursor(true)
		else
			local state = exports.USGGUI:getVisible(panelGUI.window)
			exports.USGGUI:setVisible(panelGUI.window,not state)
			showCursor(state)
		end
	end
end
addCommandHandler("staffpanel",toggleStaffPanel)
