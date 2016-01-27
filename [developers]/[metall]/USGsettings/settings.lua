local commandLine

function makeUI()
	settingsWindow = guiCreateWindow(666, 373, 290, 405, "Settings", false)
	phoneLabel = guiCreateLabel(10, 24, 211, 21, "Toggle between new and old phone:", false, settingsWindow)
	newPhoneLabel = guiCreateLabel(221, 45, 30, 15, "New", false, settingsWindow)
	oldPhoneLabel = guiCreateLabel(259, 45, 21, 15, "Old", false, settingsWindow)
	newPhoneCheckbox = guiCreateCheckBox(224, 25, 20, 17, "", false, false, settingsWindow)
	oldPhoneCheckbox = guiCreateCheckBox(259, 25, 20, 17, "", false, false, settingsWindow)
	applyButton = guiCreateButton(217, 363, 63, 32, "Apply", false, settingsWindow)
	
	guiSetVisible(settingsWindow, true)
	showCursor(true)
	guiWindowSetSizable(settingsWindow, false)
	guiSetProperty(applyButton, "NormalTextColour", "FFAAAAAA")
	guiSetAlpha(settingsWindow, 0.92)
	guiCheckBoxSetSelected(newPhoneCheckbox, true)
	
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

local hasChanged = false

function testCheckbox()
	if (getElementType(source) ~= "gui-checkbox") then return end
	
	if (guiCheckBoxGetSelected(oldPhoneCheckbox)) then
		guiCheckBoxSetSelected(newPhoneCheckbox, false)
		outputChatBox("Old phone", 255, 0, 0)
		hasChanged = true
		commandLine = "toggleUPphone"
	elseif (guiCheckBoxGetSelected(newPhoneCheckbox) and not hasChanged) then
		guiCheckBoxSetSelected(oldPhoneCheckbox, false)
		hasChanged = false
		outputChatBox("New phone", 0, 255, 0)
	end
	
	--[[if (guiCheckBoxGetSelected(oldPhoneCheckbox)) then
		guiCheckBoxSetSelected(newPhoneCheckbox, false)
		outputChatBox("Old phone", 255, 0, 0)
		commandLine = "toggleUPphone"
	else
		guiCheckBoxSetSelected(newPhoneCheckbox, true)
	end--]]
end
addEventHandler("onClientGUIClick", root, testCheckbox)