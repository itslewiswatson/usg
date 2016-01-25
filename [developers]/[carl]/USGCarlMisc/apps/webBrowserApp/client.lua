screenWidth, screenHeight = guiGetScreenSize()

local function showBrowser()
	if WebBrowserGUI.instance ~= nil then return end
	WebBrowserGUI.instance = WebBrowserGUI:new()
end

local function hideBrowser()
	if(WebBrowserGUI.instance)then
		WebBrowserGUI.instance:CloseButton_Click("left", "up")
		showCursor(false)
	end
end

bindKey(binds.closeAllApps.key,binds.closeAllApps.keyState,hideBrowser)
addEvent(apps.browser.event,true)
addEventHandler(apps.browser.event,root,showBrowser)
