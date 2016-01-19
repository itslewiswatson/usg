local previewGUI = {}

currentSkin = nil

local skins = {}

function registerSkin(skin)
	if(skin.drawElement and skin.defaultColors) then
		table.insert(skins, skin)
		return true
	else
		return false
	end
end

addEventHandler("onClientResourceStart", resourceRoot,
	function ()
		if(fileExists("skins/skin.conf")) then
			local file = fileOpen("skins/skin.conf")
			local savedSkin = fileRead(file, math.max(1,fileGetSize(file)))
			fileClose(file)
			for i, skin in ipairs(skins) do
				if(skin.name == savedSkin) then
					currentSkin = skin
				end
			end
		end
		if(not currentSkin) then
			currentSkin = skins[1]
		end		
	end
)

local skinGUI = {}

local function createPreviewGUI(x,y)
	previewGUI.window = createWindow(x,y,500,400,false,"Preview window of skin")
	local scroll = createScrollArea("center",0,500,400,false,previewGUI.window)
	local grid = createGridList(3, 3, 420, 150, false, scroll)
	gridlistAddColumn(grid, "Preview grid", 0.75)
	gridlistAddColumn(grid, "Preview", 0.25)
	for i=1,100 do
		local row = gridlistAddRow(grid)
		gridlistSetItemText(grid, row, 1, tostring(i))
		gridlistSetItemText(grid, row, 2, tostring(i*i))
	end
	local btn = createButton('center', 165,110,30,false,"Preview Button",scroll)
	createMemo('center',205,400,170,false,("Preview Memo\n"):rep(10),scroll)
	createEditBox('center',380,400,30,false,("Preview EditBox"),scroll)
	local pan = createTabPanel("center", 415, 400, 80, false,scroll )
	addTab(pan,"Preview tabpanel") addTab(pan,"tab2")
	createRadioButton("center", 500, 400, 30, false, "Preview Radio Button",scroll)
	local cmb = createComboBox("center", 535, 200, 30, false,("Preview Combo box"), scroll,nil,"up")
	for i =1,5 do comboBoxAddOption(cmb, "Combo-"..tostring(i), i) end
	createCheckBox("center", 570, 400, 30, false, "Preview checkbox", scroll)
end

local function createSkinGUI()
	skinGUI.window = createWindow("center", "center", 200,250,false,"Skins")
	local y = 5
	skinGUI.info = createLabel(0,5,200,50,false,"Note: changing the skin might make some windows unusable until reconnecting.", skinGUI.window)
	y = y + 55
	setProperty(skinGUI.info, 'textColor', tocolor(255,0,0))
	skinGUI.skins = {}
	for i, skin in ipairs(skins) do
		skinGUI.skins[i] = createRadioButton(5,y, 190,25,false,skin.name or "Unnamed",skinGUI.window,nil,skin == currentSkin)
		addEventHandler("onUSGGUISClick", skinGUI.skins[i], onSkinSelect,false)
		y = y + 30
	end
	setSize(skinGUI.window,200, y+35)
	skinGUI.close = createButton(125,y,70,30,false,"Close",skinGUI.window)
	addEventHandler("onUSGGUISClick", skinGUI.close, closeSkinGUI,false)
	local x,y = getPosition(skinGUI.window)
	createPreviewGUI(x+200,y)
	showCursor(true)
end

addCommandHandler("gui", 
	function ()
		if(isElement(skinGUI.window)) then
			closeSkinGUI()
		else
			createSkinGUI()
		end
	end
)

function closeSkinGUI()
	destroyElement(previewGUI.window)
	destroyElement(skinGUI.window)
	skinGUI = {}
	previewGUI = {}
	showCursor(false)
end

local function setElementColorToSkin(element)
	if(getSkinColor(GUIinfo[element].guiType)) then
		GUIinfo[element].color = getSkinColor(GUIinfo[element].guiType)
		if(GUIinfo[element].textColor) then
			GUIinfo[element].textColor = getSkinColor("text") or defaultTextColor
		end
	end
	local children = getElementChildren(element)
	for i, child in ipairs(children) do
		setElementColorToSkin(child)
	end
end

function onSkinSelect()
	for i, radio in ipairs(skinGUI.skins) do
		if(radio == source) then
			currentSkin = skins[i]
			break
		end
	end
	destroyElement(previewGUI.window)
	local x,y = getPosition(skinGUI.window)
	createPreviewGUI(x+200,y)
	setElementColorToSkin(skinGUI.window)
	setProperty(skinGUI.info, 'textColor', tocolor(255,0,0))
	local file = fileCreate("skins/skin.conf")
	fileWrite(file, currentSkin.name)
	fileClose(file)
end
