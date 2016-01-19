jobMenuGUI = {}

function createJobMenu()
	jobMenuGUI.window = exports.USGGUI:createWindow("center", "center", 200, 150, false, "Jobs")
	jobMenuGUI.info = exports.USGGUI:createLabel("center", 5, 190, 25, false, "Currently: "..getPlayerOccupation() or "unemployed", jobMenuGUI.window)
	jobMenuGUI.quit = exports.USGGUI:createButton("center", 80, 125, 30, false, "Quit job", jobMenuGUI.window)
	jobMenuGUI.close = exports.USGGUI:createButton("center", 115, 125, 30, false, "Close", jobMenuGUI.window)
	addEventHandler("onUSGGUISClick", jobMenuGUI.quit, onQuitJob, false)
	addEventHandler("onUSGGUISClick", jobMenuGUI.close, closeJobMenu, false)
end

function openJobMenu()
	if(not isElement(jobMenuGUI.window)) then
		createJobMenu()
		showCursor("menu", true)
	elseif(not exports.USGGUI:getVisible(jobMenuGUI.window)) then
		showCursor("menu", true)
		exports.USGGUI:setVisible(jobMenuGUI.window, true)
	end
	exports.USGGUI:setText(jobMenuGUI.info, "Currently: "..getPlayerOccupation() or "unemployed")
end

function closeJobMenu()
	if(isElement(jobMenuGUI.window) and exports.USGGUI:getVisible(jobMenuGUI.window)) then
		exports.USGGUI:setVisible(jobMenuGUI.window, false)
		showCursor("menu", false)
	end
end

function toggleJobMenu()
	if(isElement(jobMenuGUI.window) and exports.USGGUI:getVisible(jobMenuGUI.window)) then
		closeJobMenu()
	elseif(exports.USGrooms:getPlayerRoom() == "cnr") then
		openJobMenu()
	end
end
bindKey("F2", "down", toggleJobMenu)

function onQuitJob()
	triggerServerEvent("USGcnr_jobs.quitJob", localPlayer)
end