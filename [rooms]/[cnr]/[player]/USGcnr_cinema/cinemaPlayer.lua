
local currentURL = "http://usgmta.co/"
local watching = false

local screenWidth, screenHeight = guiGetScreenSize()
 
local webBrowser = createBrowser(screenWidth, screenHeight, false, false)
 
function webBrowserRender()
local x, y = 110.7, 1024.15
dxDrawMaterialLine3D(x, y, 23.25, x, y, 14.75, webBrowser, 18.2, tocolor(255, 255, 255, 255), x, y+1, 19)
end

addEvent("cinema.sendUrlToPlayer",true)
addEventHandler("cinema.sendUrlToPlayer",resourceRoot,function(URL)
currentURL = URL
requestBrowserDomains({ URL },true)
	watching = false
	setBrowserRenderingPaused ( webBrowser,watching )
	removeEventHandler("onClientRender", root, webBrowserRender)
end)

addCommandHandler("watchcinema",function()
	loadBrowserURL (  webBrowser, currentURL )
	setBrowserRenderingPaused ( webBrowser,watching )
	if(watching)then
	watching = false
	removeEventHandler("onClientRender", root, webBrowserRender)
	exports.USGmsg:msg("You are no longer watching: "..currentURL, 255, 255, 255)
	elseif(not watching)then
	watching = true
	addEventHandler("onClientRender", root, webBrowserRender)
	exports.USGmsg:msg("You are now watching: "..currentURL, 255, 255, 255)
	end
end)