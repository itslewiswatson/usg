addEvent("onUSGGUIDialogFinish", true)

local dialogs = {}

function createDialog(title,text,dialogType, ...)
	local args = {...}
	if ( type(text) == "string" and type(dialogType) == "string" ) then
		local dialog = {dialogType = dialogType}
		if ( dialogType == "confirm" ) then
			dialog.window = createWindow('center','center',400,150,false,"USG ~ "..title)
			createLabel('center','top',400,75,false,text,dialog.window)
			dialog.OK = createButton(250,100,75,25,false,"OK",dialog.window)
			dialog.cancel = createButton(50,100,75,25,false,"Cancel",dialog.window)
		elseif ( dialogType == "input" ) then
			dialog.window = createWindow('center','center',400,150,false,"USG ~ "..title)
			createLabel('center','top',380,25,false,text,dialog.window)
			dialog.input = createEditBox('center',30,380,25,false,"",dialog.window)
			dialog.OK = createButton(250,100,75,25,false,"OK",dialog.window)
			dialog.cancel = createButton(50,100,75,25,false,"Cancel",dialog.window)
			dialog.match = args[1]
		elseif ( dialogType == "select" and type(args[1]) == "table" ) then
			if ( args[2] ) then -- with searchbox
				dialog.window = createWindow('center','center',400,385,false,"USG ~ "..title)
				createLabel('center','top',380,25,false,text,dialog.window)
				dialog.search = createEditBox('center',30,380,25,false,"",dialog.window)
					addEventHandler("onUSGGUIChange",dialog.search,onDialogSearchChange)
				dialog.grid = createGridList('center',60,380,280,false,dialog.window)
				dialog.OK = createButton(250,350,75,25,false,"OK",dialog.window)
				dialog.cancel = createButton(50,350,75,25,false,"Cancel",dialog.window)
			else -- without
				dialog.window = createWindow('center','center',400,350,false,"USG ~ "..title)
				createLabel('center','top',380,25,false,text,dialog.window)
				dialog.grid = createGridList('center',30,380,280,false,dialog.window)
				dialog.OK = createButton(250,320,75,25,false,"OK",dialog.window)
				dialog.cancel = createButton(50,320,75,25,false,"Cancel",dialog.window)						
			end
			gridlistAddColumn(dialog.grid,"Name",1)
			for value,name in pairs(args[1]) do
				local row = gridlistAddRow(dialog.grid)
				gridlistSetItemText(dialog.grid,row,1,name)
				gridlistSetItemData(dialog.grid,row,1,value)
			end
			dialog.data = args[1]
		end
		if ( isElement(dialog.window) ) then
			dialogs[dialog.window] = dialog
			addEventHandler("onUSGGUIClick",dialog.OK,onDialogClick, false)
			addEventHandler("onUSGGUIClick",dialog.cancel,onDialogClick, false)
		end
		return dialog.window
	end
	return false
end

function closeDialog(dialog)
	if ( isElement(dialog) ) then
		dialogs[dialog] = nil
		destroyElement(dialog)
	end
end

function onDialogClick(btn,state)
	if ( state == "down" and btn == 1 ) then
		for window, dialog in pairs(dialogs) do
			if ( source == dialog.OK or source == dialog.cancel ) then -- this is the dialog
				local close = true
				if ( dialog.dialogType == "confirm" ) then
					triggerEvent("onUSGGUIDialogFinish", window, source == dialog.OK)
					closeDialog(window)
				elseif ( dialog.dialogType == "input" ) then
					if ( dialog.OK == source ) then
						local input = getText(dialog.input)
						if not ( dialog.match and string.match(input,dialog.match) ) then
							triggerEvent("onUSGGUIDialogFinish", window, input)
						else
							close = false
							exports.USGmsg:msg("Invalid input!",255,0,0)
						end
					else
						triggerEvent("onUSGGUIDialogFinish", window, false)
					end
				elseif ( dialog.dialogType == "select" ) then
					if ( dialog.OK == source ) then
						local selRow = gridlistGetSelectedItem(dialog.grid)
						if ( selRow ) then
							local data = gridlistGetItemData(dialog.grid,selRow,1)
							triggerEvent("onUSGGUIDialogFinish", window, data)
						else
							close = false
							exports.USGmsg:msg("You didn't select anything!",255,0,0)
						end
					elseif ( dialog.cancel == source ) then
						triggerEvent("onUSGGUIDialogFinish", window, false)
					end
				end
				if ( close ) then closeDialog(window) end
				return
			end
		end
	end
end

function onDialogSearchChange(old,new)
	for window, dialog in pairs(dialogs) do
		if ( source == dialog.search ) then -- this is the dialog
			local filter = getText(dialog.search)
			gridlistClear(dialog.grid)
			for value,name in pairs(dialog.data) do
				if ( not filter or #filter == 0 or string.find(name:lower(),exports.USG:escapeString(filter):lower()) ) then
					local row = gridlistAddRow(dialog.grid)
					gridlistSetItemText(dialog.grid,row,1,name)
					gridlistSetItemData(dialog.grid,row,1,value)
				end
			end
			return
		end
	end
end