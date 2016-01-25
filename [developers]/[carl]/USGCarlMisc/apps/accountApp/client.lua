local accGUI = {}

addEventHandler("onClientResourceStart", resourceRoot,
    function()
        accGUI.window = guiCreateWindow(0.78, 0.27, 0.21, 0.51, apps.account.name, true)
        guiWindowSetSizable(accGUI.window, false)

        accGUI.labelUsername = guiCreateLabel(0.03, 0.08, 0.21, 0.03, "Username:", true, accGUI.window)
        accGUI.editUsername = guiCreateEdit(0.03, 0.13, 0.94, 0.06, "", true, accGUI.window)
        accGUI.labelPassword = guiCreateLabel(0.03, 0.25, 0.21, 0.03, "Password:", true, accGUI.window)
        accGUI.editPassword = guiCreateEdit(0.03, 0.29, 0.94, 0.07, "", true, accGUI.window)
        accGUI.labelNewPassword = guiCreateLabel(0.03, 0.40, 0.29, 0.03, "New Password:", true, accGUI.window)
        accGUI.editNewPassword = guiCreateEdit(0.03, 0.45, 0.93, 0.07, "", true, accGUI.window)
        accGUI.buttonPassword = guiCreateButton(0.32, 0.54, 0.35, 0.10, "Update Password", true, accGUI.window)
        guiSetProperty(accGUI.buttonPassword, "NormalTextColour", "FFAAAAAA")
        accGUI.labelEmail = guiCreateLabel(0.03, 0.66, 0.29, 0.05, "New Email:", true, accGUI.window)
        accGUI.editEmail = guiCreateEdit(0.04, 0.71, 0.93, 0.06, "", true, accGUI.window)
        accGUI.buttonEmail = guiCreateButton(0.32, 0.82, 0.35, 0.10, "Update Email", true, accGUI.window)
        guiSetProperty(accGUI.buttonEmail, "NormalTextColour", "FFAAAAAA")    
		
		addEventHandler("onClientGUIClick", accGUI.buttonPassword, updatePass, false)    
		addEventHandler("onClientGUIClick", accGUI.buttonEmail, updateEmail, false)		
		
		guiSetVisible ( accGUI.window, false )
    end
)

local function showAccountGUI()
if(not exports.USGaccounts:isPlayerLoggedIn()) then return end
	if(guiGetVisible(accGUI.window) == false)then
		guiSetInputMode("no_binds_when_editing")
		guiSetVisible ( accGUI.window, true )
	end
end

addEvent(apps.account.event,true)
addEventHandler(apps.account.event,root,showAccountGUI)

local function hideAccountGUI()
	if(guiGetVisible(accGUI.window) == true)then
		guiSetVisible ( accGUI.window, false )
		showCursor(false)
	end
end

bindKey(binds.closeAllApps.key,binds.closeAllApps.keyState,hideAccountGUI)

function getInput()
    local user = guiGetText ( accGUI.editUsername )
    local pass = guiGetText ( accGUI.editPassword )
    if(#user == 0) then
        exports.USGmsg:msg(apps.account.messages.enterUsername, messages.color.alert.r, messages.color.alert.g, messages.color.alert.b)
        return false
    elseif(#pass == 0) then
        exports.USGmsg:msg(apps.account.messages.enterPassword, messages.color.alert.r, messages.color.alert.g, messages.color.alert.b)
        return false
    end
    return user,pass
end

function updatePass()
    local user, pass = getInput()
    if(user) then
        local newPass = guiGetText ( accGUI.editNewPassword )
        if(#newPass < 6) then
            exports.USGmsg:msg(apps.account.messages.passwordTooShort, messages.color.alert.r, messages.color.alert.g, messages.color.alert.b)
            return
        end
        triggerServerEvent("USGphone.changePassword", localPlayer, user, pass, newPass)
    end
end

function updateEmail()
    local user, pass = getInput()
    if(user) then
        local newEmail = guiGetText ( accGUI.editEmail )
        if(#newEmail < 4) then
            exports.USGmsg:msg(apps.account.messages.emailTooLong, messages.color.alert.r, messages.color.alert.g, messages.color.alert.b)
            return
        end
        triggerServerEvent("USGphone.changeEmail", localPlayer, user, pass, newEmail)
    end
end