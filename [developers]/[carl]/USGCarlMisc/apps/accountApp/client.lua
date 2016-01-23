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

bindKey("lctrl","down",hideAccountGUI)

function createAccountGUI()
    exports.USGGUI:setDefaultTextAlignment("left","center")
    accGUI.window = exports.USGGUI:createWindow("center","center", 300, 430, false,"Account Settings")
        exports.USGGUI:createLabel("center",5, 290, 35,false,"Username:",accGUI.window)
    accGUI.usernamebox = exports.USGGUI:createEditBox("center",36,298,25,false,"",accGUI.window)
        exports.USGGUI:createLabel("center",55, 290, 35,false,"Password:",accGUI.window)
    accGUI.passwordbox = exports.USGGUI:createEditBox("center",87,298,25,false,"",accGUI.window)
        exports.USGGUI:createLabel("center",115, 290, 35,false,"New Password:",accGUI.window)
    accGUI.newpasswordbox = exports.USGGUI:createEditBox("center",150,298,25,false,"",accGUI.window)
    accGUI.updatePass = exports.USGGUI:createButton("center",192,110,25,false,"Update password",accGUI.window)
    addEventHandler("onUSGGUISClick", accGUI.updatePass, updatePass, false)      
        exports.USGGUI:createLabel("center",235, 290, 35,false,"New Email:",accGUI.window)
    accGUI.newemailbox = exports.USGGUI:createEditBox("center",272,298,25,false,"",accGUI.window)
    accGUI.updateEmail = exports.USGGUI:createButton("center",300,110,25,false,"Update email",accGUI.window)
    addEventHandler("onUSGGUISClick", accGUI.updateEmail, updateEmail, false)
end

function getInput()
    local user = exports.USGGUI:getText(accGUI.usernamebox)
    local pass = exports.USGGUI:getText(accGUI.passwordbox)
    if(#user == 0) then
        exports.USGmsg:msg("Enter your username.", 255, 0, 0)
        return false
    elseif(#pass == 0) then
        exports.USGmsg:msg("Enter your password.", 255, 0, 0)
        return false
    end
    return user,pass
end

function updatePass()
    local user, pass = getInput()
    if(user) then
        local newPass = exports.USGGUI:getText(accGUI.newpasswordbox)
        if(#newPass < 6) then
            exports.USGmsg:msg("Your password must be 6 characters long.", 255, 0, 0)
            return
        end
        triggerServerEvent("USGphone.changePassword", localPlayer, user, pass, newPass)
    end
end

function updateEmail()
    local user, pass = getInput()
    if(user) then
        local newEmail = exports.USGGUI:getText(accGUI.newemailbox )
        if(#newEmail < 4) then
            exports.USGmsg:msg("Your email must be 4 characters long.", 255, 0, 0)
            return
        end
        triggerServerEvent("USGphone.changeEmail", localPlayer, user, pass, newEmail)
    end
end