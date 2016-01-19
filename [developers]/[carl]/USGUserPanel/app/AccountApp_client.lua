local accGUI = {}


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

function toggleaccGUI()
if(not exports.USGaccounts:isPlayerLoggedIn()) then return end
    if(isElement(accGUI.window )) then
        if(exports.USGGUI:getVisible(accGUI.window )) then
        exports.USGGUI:setVisible(accGUI.window , false)
            showCursor(false)
            exports.USGblur:setBlurDisabled()
			showPlayerHudComponent("radar",true)
        else
            showCursor(true)
            exports.USGGUI:setVisible(accGUI.window , true)
            exports.USGblur:setBlurEnabled()
			showPlayerHudComponent("radar",false)
        end
    else
        createAccountGUI()
        showCursor(true)
        exports.USGblur:setBlurEnabled()
		showPlayerHudComponent("radar",true)
    end 
end 
addEvent("UserPanel.App.AccountApp",true)
addEventHandler("UserPanel.App.AccountApp",root,toggleaccGUI)

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