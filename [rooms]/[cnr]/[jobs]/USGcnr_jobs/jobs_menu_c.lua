jobMenuGUI = {}


function createJobMenu()
    local screenW, screenH = guiGetScreenSize()
    jobMenuGUI.window = guiCreateWindow((screenW - 264) / 2, (screenH - 259) / 2, 264, 259, "Employment", false)
    guiWindowSetSizable(jobMenuGUI.window, false)
    jobMenuGUI.close  = guiCreateButton(66, 183, 104, 37, "Close", false, jobMenuGUI.window)
    jobMenuGUI.quit = guiCreateButton(65, 143, 105, 35, "Quit job", false,jobMenuGUI.window)
    jobMenuGUI.info = guiCreateLabel(42, 44, 190, 42, "Currently: "..getPlayerOccupation() or "unemployed", false, jobMenuGUI.window)
    addEventHandler("onClientGUIClick", jobMenuGUI.quit, onQuitJob, false)
    addEventHandler("onClientGUIClick", jobMenuGUI.close, closeJobMenu, false)
end

function openJobMenu()
    if(not isElement(jobMenuGUI.window)) then
        createJobMenu()
        showCursor("menu", true)
    elseif(not guiGetVisible(jobMenuGUI.window)) then
        showCursor("menu", true)
        guiGetVisible(jobMenuGUI.window, true)
    end
    guiSetText(jobMenuGUI.info, "Currently: "..getPlayerOccupation() or "unemployed")
end

function closeJobMenu()
    if(isElement(jobMenuGUI.window) and guiGetVisible(jobMenuGUI.window)) then
        guiGetVisible(jobMenuGUI.window, false)
        showCursor("menu", false)
    end
end

function toggleJobMenu()
    if(isElement(jobMenuGUI.window) and guiGetVisible(jobMenuGUI.window)) then
        closeJobMenu()
    elseif(exports.USGrooms:getPlayerRoom() == "cnr") then
        openJobMenu()
    end
end
bindKey("F2", "down", toggleJobMenu)

function onQuitJob()
    triggerServerEvent("USGcnr_jobs.quitJob", localPlayer)
end