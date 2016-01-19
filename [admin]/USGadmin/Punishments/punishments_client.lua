local punishmentsGUI = {}

function togglePunishments()
	if(not (getResourceFromName("USGaccounts") and getResourceState(getResourceFromName("USGaccounts")) == "running"
	and exports.USGaccounts:isPlayerLoggedIn())) then return end
	if(isElement(punishmentsGUI.window)) then
		if(exports.USGGUI:getVisible(punishmentsGUI.window)) then
			exports.USGGUI:setVisible(punishmentsGUI.window, false)
			exports.USGGUI:gridlistClear(punishmentsGUI.grid)
			showCursor("punishments", false)
		else
			exports.USGGUI:setVisible(punishmentsGUI.window, true)
			exports.USGGUI:gridlistSetItemText(punishmentsGUI.grid, exports.USGGUI:gridlistAddRow(punishmentsGUI.grid), 1, "Loading...")
			showCursor("punishments", true)
			triggerServerEvent("USGadmin.requestPlayerPunishments", localPlayer)
		end
	else
		punishmentsGUI.window = exports.USGGUI:createWindow('center', 'center', 400, 460, false, "Punishments")
		punishmentsGUI.grid = exports.USGGUI:createGridList('center', 5, 390, 410, false, punishmentsGUI.window)
		exports.USGGUI:gridlistAddColumn(punishmentsGUI.grid, "Text", 0.6)
		exports.USGGUI:gridlistAddColumn(punishmentsGUI.grid, "Admin account", 0.25)
		exports.USGGUI:gridlistAddColumn(punishmentsGUI.grid, "Account", 0.15)
		exports.USGGUI:gridlistSetItemText(punishmentsGUI.grid, exports.USGGUI:gridlistAddRow(punishmentsGUI.grid), 1, "Loading...")
		punishmentsGUI.close = exports.USGGUI:createButton(325, 425, 70, 30, false, "Close", punishmentsGUI.window)
		addEventHandler("onUSGGUISClick", punishmentsGUI.close, togglePunishments, false)
		showCursor("punishments", true)
		triggerServerEvent("USGadmin.requestPlayerPunishments", localPlayer)
	end
end
addCommandHandler("punishments",togglePunishments, false, false)

addEvent("USGadmin.receivePlayerPunishments", true)
function loadPlayerPunishments(punishments)
	exports.USGGUI:gridlistClear(punishmentsGUI.grid)
	if(punishments) then
		local account = exports.USGaccounts:getPlayerAccount(localPlayer)
		for i, punishment in ipairs(punishments) do
			local row = exports.USGGUI:gridlistAddRow(punishmentsGUI.grid)
			exports.USGGUI:gridlistSetItemText(punishmentsGUI.grid, row, 1, punishment.punishtext)
			exports.USGGUI:gridlistSetItemText(punishmentsGUI.grid, row, 2, punishment.punisheraccount or "N/A")
			exports.USGGUI:gridlistSetItemText(punishmentsGUI.grid, row, 3, punishment.username == account and "Yes" or "No")
		end
	else
		exports.USGGUI:gridlistSetItemText(punishmentsGUI.grid, exports.USGGUI:gridlistAddRow(punishmentsGUI.grid), 1, "Error - try again")
	end
end
addEventHandler("USGadmin.receivePlayerPunishments", localPlayer, loadPlayerPunishments)