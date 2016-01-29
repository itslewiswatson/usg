local commandLine
 
function makeUI()
    settingsWindow = guiCreateWindow(666, 373, 290, 405, "Settings", false)
	guiWindowSetSizable(settingsWindow, false)
	guiSetAlpha(settingsWindow, 0.92)

	phoneLabel = guiCreateLabel(10, 24, 211, 21, "Toggle between new and old phone:", false, settingsWindow)
	applyButton = guiCreateButton(217, 363, 63, 32, "Apply", false, settingsWindow)	
	guiSetProperty(applyButton, "NormalTextColour", "FFAAAAAA")
	settingsPhoneCombo = guiCreateComboBox(10, 40, 211, 79, "", false, settingsWindow)
	guiComboBoxAddItem(settingsPhoneCombo, "Use new phone")
	guiComboBoxAddItem(settingsPhoneCombo, "Use old phone")
   
    addEventHandler("onClientGUIClick", applyButton, apply, false)
end
addCommandHandler("settings", makeUI)

function apply()
    guiSetVisible(settingsWindow, false)
    showCursor(false)
    if (commandLine) then
        outputChatBox(commandLine, 255, 255, 0)
        executeCommandHandler(commandLine)
    else
        commandLine = ""
    end
end
 
function testCheckbox()
    if (getElementType(source) ~= "gui-checkbox") then return end
end
addEventHandler("onClientGUIClick", root, testCheckbox)