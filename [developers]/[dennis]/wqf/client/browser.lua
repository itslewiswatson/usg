local screenWidth, screenHeight = guiGetScreenSize()
 
local browser = guiCreateBrowser(screenWidth/2, screenWidth/2, 100, 100, false, false, false)

addEventHandler("onClientBrowserCreated", guiGetBrowser(browser), 
	function()
		loadBrowserURL(source, "http://www.youtube.com")
	end
)