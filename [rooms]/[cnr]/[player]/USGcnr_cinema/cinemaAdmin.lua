local cWindow = guiCreateWindow(337, 177, 816, 762, "CINEMA", false)
local browser = guiCreateBrowser(0, 0, 800, 600, false, false, false, cWindow)
 
local theBrowser = guiGetBrowser(browser)
addEventHandler("onClientBrowserCreated", theBrowser,
        function()
                loadBrowserURL(source, "http://www.youtube.com")
        end
)
 
 
CINEMA = {
    button = {},
    window = {},
    edit = {}
}
addEventHandler("onClientResourceStart", resourceRoot,
    function()
        guiWindowSetSizable(cWindow, false)
        guiSetProperty(cWindow, "CaptionColour", "FF0309FB")
		guiSetVisible(cWindow,false)
        CINEMA.button[1] = guiCreateButton(9, 608, 388, 35, "GET URL", false, cWindow)
        guiSetFont(CINEMA.button[1], "default-bold-small")
        guiSetProperty(CINEMA.button[1], "NormalTextColour", "FFFF0000")
        CINEMA.button[2] = guiCreateButton(427, 608, 381, 35, "PUT VIDEO IN CINEMA", false, cWindow)
        guiSetFont(CINEMA.button[2], "default-bold-small")
        guiSetProperty(CINEMA.button[2], "NormalTextColour", "FFFF0000")
        CINEMA.button[3] = guiCreateButton(10, 653, 388, 35, "CLOSE", false, cWindow)
        guiSetFont(CINEMA.button[3], "default-bold-small")
        guiSetProperty(CINEMA.button[3], "NormalTextColour", "FFFF0000")
        CINEMA.button[4] = guiCreateButton(425, 654, 383, 34, "VIEW VIDEO IN FULL SCREEN MODE", false, cWindow)
        guiSetFont(CINEMA.button[4], "default-bold-small")
        guiSetProperty(CINEMA.button[4], "NormalTextColour", "FFFF0000")
        CINEMA.edit[1] = guiCreateEdit(11, 700, 796, 52, "", false, cWindow)
        guiEditSetReadOnly(CINEMA.edit[1], false)    
    end
)
 
 
function geturl()
	if source == CINEMA.button[1] then
	guiSetText(CINEMA.edit[1],getBrowserURL(theBrowser))
	end
end
addEventHandler("onClientGUIClick",root,geturl) 
 
function brow()
        if source == CINEMA.button[2] then
		local URL = guiGetText(CINEMA.edit[1])
		if(not URL or URL == "" or URL == " ")then
		URL = nil
		end
        triggerServerEvent("cinema.saveURL",resourceRoot,URL)
    end
end
addEventHandler("onClientGUIClick",root,brow)
 
 function fullscreen()
local URLs = string.sub(guiGetText(CINEMA.edit[1]),"33")
	if source == CINEMA.button[4] then
	triggerServerEvent("cinema.saveURL",resourceRoot,"https://www.youtube.com/embed/"..URLs.."?autoplay=1&iv_load_policy=3&enablejsapi=1&fs=0&theme=light")
	end
end
addEventHandler("onClientGUIClick",root,fullscreen)
 
function url()
if(exports.USGcnr_jobs:getPlayerJobType() ~= "staff") then return end
guiSetVisible(cWindow,true)
showCursor( true )
guiSetInputEnabled( true )
end
addCommandHandler("cinema",url)
 
function closeman()
if source == CINEMA.button[3] then
guiSetVisible(cWindow,false)
showCursor( false )
guiSetInputEnabled( false )
end
end
addEventHandler("onClientGUIClick",root,closeman)