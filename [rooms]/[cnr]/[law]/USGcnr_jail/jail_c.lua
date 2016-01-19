fileDelete("jail_c.lua")
local jailed = false

local jailGUI = {}
local timeLeftTimer
local timeLeft
local jailDuration

addEvent("USGcnr_jail.onJailed", true)
function onJailed(jailedby, duration)
    if(not jailed) then
        jailed = true
        jailDuration = duration
        jailGUI.window = exports.USGGUI:createWindow("left","center", 200,130,false,"Jail")
        jailGUI.jailedby = exports.USGGUI:createLabel(0, 5, 200, 25, false, "Jailed by: "..jailedby, jailGUI.window)
        jailGUI.duration = exports.USGGUI:createLabel(0, 35, 200, 25, false,"Duration: "..duration.." seconds.", jailGUI.window)
        timeLeft = duration
        jailGUI.timeleft = exports.USGGUI:createLabel(0, 65, 200, 25, false,"Time left: "..timeLeft.." seconds.", jailGUI.window)
        jailGUI.info = exports.USGGUI:createLabel(0, 95, 200, 25, false,"Press x to toggle this window.", jailGUI.window)
        timeLeftTimer = setTimer(updateTimeLeft, 1000, 0)
        bindKey("x","down",toggleWindow)
        addEventHandler("onClientPlayerDamage", localPlayer, disableDamageInJail)
    else
        timeLeft = timeLeft + duration
        jailDuration = jailDuration+duration
        exports.USGGUI:setText(jailGUI.duration, "Duration: "..jailDuration.." seconds.")
    end
end
addEventHandler("USGcnr_jail.onJailed", localPlayer, onJailed)

function disableDamageInJail()
    if(jailed) then
        cancelEvent()
    else
        removeEventHandler("onClientPlayerDamage", localPlayer, disableDamageInJail)
    end
end

function updateTimeLeft()
    timeLeft = timeLeft - 1
    exports.USGGUI:setText(jailGUI.timeleft, "Time left: "..timeLeft.." seconds.")
    if(timeLeft <= 0) then
        onLeaveJail()
    end
end

function toggleWindow()
    exports.USGGUI:setVisible(jailGUI.window, not exports.USGGUI:getVisible(jailGUI.window))
end

addEvent("USGcnr_jail.onLeaveJail", true)
function onLeaveJail()
    if(jailed) then
        jailed = false
        if(isTimer(timeLeftTimer)) then killTimer(timeLeftTimer) end
        if(isElement(jailGUI.window)) then destroyElement(jailGUI.window) end
        unbindKey("x","down",toggleWindow)
        removeEventHandler("onClientPlayerDamage", localPlayer, disableDamageInJail)
    end
end
addEventHandler("USGcnr_jail.onLeaveJail", localPlayer, onLeaveJail)