local key = "F10"

reportGUI = {
    label = {},
    button = {},
    window = {},
    edit = {},
    memo = {}
}
addEventHandler("onClientResourceStart", resourceRoot,
    function()
        reportGUI.window[1] = guiCreateWindow(0.32, 0.31, 0.37, 0.39, "Report System", true)
        guiWindowSetSizable(reportGUI.window[1], false)

        reportGUI.button[1] = guiCreateButton(0.04, 0.80, 0.22, 0.13, "Report", true, reportGUI.window[1])
        guiSetProperty(reportGUI.button[1], "NormalTextColour", "FFAAAAAA")
        reportGUI.button[2] = guiCreateButton(0.75, 0.80, 0.22, 0.13, "Close", true, reportGUI.window[1])
        guiSetProperty(reportGUI.button[2], "NormalTextColour", "FFAAAAAA")
        reportGUI.button[3] = guiCreateButton(0.38, 0.80, 0.22, 0.13, "Clear", true, reportGUI.window[1])
        guiSetProperty(reportGUI.button[3], "NormalTextColour", "FFAAAAAA")
        reportGUI.label[1] = guiCreateLabel(0.02, 0.07, 0.22, 0.06, "Rule breaker name:", true, reportGUI.window[1])
		reportGUI.edit[1] = guiCreateEdit(0.75, 0.07, 0.21, 0.06, "", true, reportGUI.window[1])
        guiLabelSetHorizontalAlign(reportGUI.label[1], "right", false)
        guiLabelSetVerticalAlign(reportGUI.label[1], "center")
        reportGUI.label[2] = guiCreateLabel(0.53, 0.07, 0.22, 0.06, "Rule broken:", true, reportGUI.window[1])
		reportGUI.edit[2] = guiCreateEdit(0.24, 0.07, 0.21, 0.06, "", true, reportGUI.window[1])
        guiLabelSetHorizontalAlign(reportGUI.label[2], "right", false)
        guiLabelSetVerticalAlign(reportGUI.label[2], "center")
        reportGUI.label[3] = guiCreateLabel(0.02, 0.23, 0.22, 0.06, "What happened:", true, reportGUI.window[1])
		reportGUI.memo[1] = guiCreateMemo(0.24, 0.23, 0.74, 0.24, "", true, reportGUI.window[1])
        guiLabelSetHorizontalAlign(reportGUI.label[3], "right", false)
        guiLabelSetVerticalAlign(reportGUI.label[3], "center")
        reportGUI.label[4] = guiCreateLabel(0.02, 0.60, 0.22, 0.06, "Screenshot(s):", true, reportGUI.window[1])
		reportGUI.edit[3] = guiCreateEdit(0.24, 0.59, 0.74, 0.06, "", true, reportGUI.window[1]) 
        guiLabelSetHorizontalAlign(reportGUI.label[4], "right", false)
        guiLabelSetVerticalAlign(reportGUI.label[4], "center")
		guiSetVisible(reportGUI.window[1], false)
		guiSetInputMode ( "no_binds_when_editing" )
		addEventHandler ( "onClientGUIClick", reportGUI.button[3], function()
			if(source == reportGUI.button[3])then
			clearInput()
			end
		end)
		addEventHandler ( "onClientGUIClick", reportGUI.button[2], function()
			if(source == reportGUI.button[2])then
			toggleReportGUIV2()
			end		
		end)
		addEventHandler ( "onClientGUIClick", reportGUI.button[1], function()
			if(source == reportGUI.button[1])then
			sendReport()
			end		
		end)
    end
)



function toggleReportGUIV2()
	if(not exports.USGaccounts:isPlayerLoggedIn()) then return end
	if(isElement(reportGUI.window[1])) then
		if(guiGetVisible(reportGUI.window[1])) then
			guiSetVisible(reportGUI.window[1], false)
			showCursor(false)
		else
			showCursor(true)
			guiSetVisible(reportGUI.window[1], true)
		end
	else
		createReportGUI()
		showCursor(true)
	end 
end 
bindKey(key, "down", toggleReportGUIV2) 

function clearInput()
	guiSetText ( reportGUI.edit[1], "" )
	guiSetText ( reportGUI.edit[2], "" )
	guiSetText ( reportGUI.edit[3], "" )
	guiSetText ( reportGUI.memo[1], "" )
end

function getPlayerFromPartialName(name)
    local name = name and name:gsub("#%x%x%x%x%x%x", ""):lower() or nil
    if name then
        for _, player in ipairs(getElementsByType("player")) do
            local name_ = getPlayerName(player):gsub("#%x%x%x%x%x%x", ""):lower()
            if name_:find(name, 1, true) then
                return player
            end
        end
    end
end

function sendReport()
	local name = guiGetText(reportGUI.edit[1])
	if(getPlayerFromPartialName(name))then
	name = getPlayerName(getPlayerFromPartialName(name))
	end
	local rule = guiGetText(reportGUI.edit[2])
	local description = guiGetText(reportGUI.memo[1])
	local images = guiGetText(reportGUI.edit[3])
	if(#name > 0 and #rule > 0 and #description > 0) then
		triggerServerEvent("USGreport.report", localPlayer, name, rule, description, images)
		clearInput()
		exports.USGmsg:msg("You have sent a report to the staff team.", 0,255,0)
	else
		exports.USGmsg:msg("You must fill all forms except image.", 255,0,0)
	end
end