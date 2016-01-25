local helpGUI = {}

addEventHandler("onClientResourceStart", resourceRoot,
    function()
        helpGUI.window = guiCreateWindow(0.78, 0.87, 0.22, 0.13, "", true)
        guiWindowSetSizable(helpGUI.window, false)

        helpGUI.label = guiCreateLabel(0.04, 0.16, 0.95, 0.79, "", true, helpGUI.window)
			
		guiSetVisible(helpGUI.window,false)
    end
)

function showHelpGUI(data)
	guiSetText(helpGUI.window, data.title)
	guiSetText(helpGUI.label, data.text)
	guiSetVisible(helpGUI.window, true)
end

function hideHelpGUI()
	guiSetVisible(helpGUI.window, false)
end
