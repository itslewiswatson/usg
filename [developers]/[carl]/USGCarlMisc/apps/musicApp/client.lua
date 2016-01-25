musicGUI = {}

addEventHandler("onClientResourceStart", resourceRoot,
    function()
        musicGUI.window = guiCreateWindow(0.75, 0.22, 0.22, 0.58, apps.music.name, true)
        guiWindowSetSizable(musicGUI.window, false)

        musicGUI.gridlistLibrary = guiCreateGridList(0.03, 0.05, 0.94, 0.61, true, musicGUI.window)
        guiGridListAddColumn(musicGUI.gridlistLibrary, "Library", 0.9)
        musicGUI.labelName = guiCreateLabel(0.03, 0.67, 0.37, 0.08, "Name:", true, musicGUI.window)
        guiLabelSetHorizontalAlign(musicGUI.labelName, "center", false)
        guiLabelSetVerticalAlign(musicGUI.labelName, "center")
        musicGUI.editName = guiCreateEdit(0.04, 0.73, 0.36, 0.07, "", true, musicGUI.window)
        musicGUI.labelURL = guiCreateLabel(0.41, 0.68, 0.56, 0.04, "URL:", true, musicGUI.window)
        guiLabelSetHorizontalAlign(musicGUI.labelURL, "center", false)
        guiLabelSetVerticalAlign(musicGUI.labelURL, "center")
        musicGUI.editURL = guiCreateEdit(0.41, 0.73, 0.56, 0.07, "", true, musicGUI.window)
        musicGUI.buttonStart = guiCreateButton(0.04, 0.81, 0.36, 0.07, "Start", true, musicGUI.window)
        guiSetProperty(musicGUI.buttonStart, "NormalTextColour", "FFAAAAAA")
        musicGUI.buttonStop = guiCreateButton(0.04, 0.90, 0.36, 0.07, "Stop", true, musicGUI.window)
        guiSetProperty(musicGUI.buttonStop, "NormalTextColour", "FFAAAAAA")
        musicGUI.buttonAdd = guiCreateButton(0.61, 0.81, 0.36, 0.07, "Add", true, musicGUI.window)
        guiSetProperty(musicGUI.buttonAdd, "NormalTextColour", "FFAAAAAA")
        musicGUI.buttonRemove = guiCreateButton(0.61, 0.90, 0.36, 0.07, "Remove", true, musicGUI.window)
        guiSetProperty(musicGUI.buttonRemove, "NormalTextColour", "FFAAAAAA")  

		guiSetVisible(musicGUI.window,false)
    end
)


local function showMusicGUI()
if(not exports.USGaccounts:isPlayerLoggedIn()) then return end
	if(guiGetVisible(musicGUI.window) == false)then
		guiSetInputMode("no_binds_when_editing")
		guiSetVisible ( musicGUI.window, true )
		gpsfillPlayerGrid()
		gpsfillLocationGrid()
	end
end

addEvent(apps.music.event,true)
addEventHandler(apps.music.event,root,showMusicGUI)

local function hideMusicGUI()
	if(guiGetVisible(musicGUI.window) == true)then
		guiSetVisible ( musicGUI.window, false )
		showCursor(false)
	end
end

bindKey( binds.closeAllApps.key, binds.closeAllApps.keyState,hideMusicGUI)