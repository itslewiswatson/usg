rules, reasons = false, false

addEvent("USGadmin.receiveRules", true)
function recieveRules(nRules, nReasons)
	rules, reasons = nRules, nReasons
	if(timeout) then
		displayRules()
	end
end
addEventHandler("USGadmin.receiveRules", root,recieveRules)

local rulesGUI = false
local allowedToClose = false
local timeout
local timeoutTimer

function closeRulesGUI()
	if(not allowedToClose or not rulesGUI or not isElement(rulesGUI.window)) then outputChatBox("Returning in closeRulesGUI") return end
	destroyElement(rulesGUI.window)
	timeout = false
	rulesGUI = false
	showCursor("rules", false)
	outputChatBox("Closed rules menu")
end

function displayRules()
	local text = "Please wait"
	if(rules) then
		text = ""
		for i, rule in ipairs(rules) do
			if(i ~= 1) then
				text = text .. "\n"
			end
			text = text .. "#"..rule.id.." "..rule.text
			for _, info in ipairs(rule.infos) do
				info:gsub("\n", "\n"..string.rep(" ", #("#"..rule.id)))
				text = text .. "\n"..string.rep(" ", #("#"..rule.id))..info
			end
			text = text.."\n"
		end
	end
	exports.USGGUI:setText(rulesGUI.memo, text)
end

function openRulesGUI(canClose)
	if(rulesGUI and isElement(rulesGUI.window)) then return end
	allowedToClose = canClose
	rulesGUI = {}
	if(canClose) then
		rulesGUI.window = exports.USGGUI:createWindow("center", "center", 400,600,false,"Rules")
		rulesGUI.memo = exports.USGGUI:createMemo("center", 5, 380, 555, false, "", rulesGUI.window)
		rulesGUI.close = exports.USGGUI:createButton(315, 565, 70, 30, false, "Close", rulesGUI.window)
		addEventHandler("onUSGGUISClick", rulesGUI.close, closeRulesGUI)
	else
		rulesGUI.window = exports.USGGUI:createWindow("center", "center", 400, 575, false,"Rules")
		rulesGUI.memo = exports.USGGUI:createMemo("center", 5, 380, 555, false, "", rulesGUI.window)
	end
	exports.USGGUI:setProperty(rulesGUI.window, "movable", false)
	exports.USGGUI:setProperty(rulesGUI.memo, "readOnly", true)
	showCursor("rules", true)
	displayRules()
end

addCommandHandler("rules", 
	function () 
		if(rulesGUI and isElement(rulesGUI.window)) then
			closeRulesGUI()
		else
			openRulesGUI(true) 
		end
	end
)
bindKey("F9","down","rules")

addEvent("USGadmin.showRules", true)
function showRules(nTimeout) -- timeout in seconds
	if(not exports.USGAccounts:isPlayerLoggedIn()) then return false end
	local nTimeout = (nTimeout or 60)
	if(timeout) then
		timeout = nTimeout+timeout
	else
		timeout = nTimeout
	end
	openRulesGUI(false)
	updateTimeout()
	if(not isTimer(timeoutTimer)) then
		timeoutTimer = setTimer(updateTimeout, 1000, 0)
	end
	return true
end
addEventHandler("USGadmin.showRules", localPlayer, showRules)

function updateTimeout()
	if (timeout) then
		if (timeout > 1) then
			timeout = timeout - 1
			exports.USGGUI:setText(rulesGUI.window, "Rules - "..timeout.." seconds left")
		else
			closeRulesGUI()
			killTimer(timeoutTimer)
			outputChatBox("Closed on updateTimeout")
		end
	else
		killTimer(timeoutTimer)
	end
end