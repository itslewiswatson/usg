local medsellGUI = {}


function createMedsellGUI()
    exports.USGGUI:setDefaultTextAlignment("center","center")
    medsellGUI.window = exports.USGGUI:createWindow("center","center",300, 100, false,"Medicine Seller.")
    exports.USGGUI:createLabel("left",0, 198, 30,false,"Steroid for 500$ per hit",medsellGUI.window)
    exports.USGGUI:createLabel("left",30, 198, 30,false,"Aspirin for 500$ per hit",medsellGUI.window)
    
    medsellGUI.buysteroid = exports.USGGUI:createButton("right",00,70,25,false," Buy ",medsellGUI.window)
    medsellGUI.buyaspirin = exports.USGGUI:createButton("right",30,70,25,false," Buy ",medsellGUI.window)
    
    medsellGUI.close = exports.USGGUI:createButton("center","bottom",70,25,false," Close ",medsellGUI.window)
    
    addEventHandler("onUSGGUISClick",  medsellGUI.buysteroid, onBuySteroid , false)
    addEventHandler("onUSGGUISClick",  medsellGUI.buyaspirin, onBuyAspirin , false)
    addEventHandler("onUSGGUISClick",  medsellGUI.close, toggle , false)
end

function toggle()
if(not exports.USGaccounts:isPlayerLoggedIn()) then return end
    if(isElement(medsellGUI.window )) then
        if(exports.USGGUI:getVisible(medsellGUI.window )) then
         exports.USGGUI:setVisible(medsellGUI.window , false)
            showCursor(false)
            exports.USGblur:setBlurDisabled()
            else
            showCursor(true)
            exports.USGGUI:setVisible(medsellGUI.window , true)
            exports.USGblur:setBlurEnabled()
        end
    else
        createMedsellGUI()
        exports.USGblur:setBlurEnabled()
        showCursor(true)
    end 
end 

function open()
if(not exports.USGaccounts:isPlayerLoggedIn()) then return end
    if(isElement(medsellGUI.window )) then
        if(not exports.USGGUI:getVisible(medsellGUI.window )) then
            showCursor(true)
            exports.USGGUI:setVisible(medsellGUI.window , true)
            exports.USGblur:setBlurEnabled()
        end
    else
        createMedsellGUI()
        exports.USGblur:setBlurEnabled()
        showCursor(true)
    end 
end
addEvent("USGcnr_pharmacy.sell.open",true)
addEventHandler("USGcnr_pharmacy.sell.open",root,open)

function close()
if(not exports.USGaccounts:isPlayerLoggedIn()) then return end
    if(isElement(medsellGUI.window )) then
        if(exports.USGGUI:getVisible(medsellGUI.window )) then
            showCursor(false)
            exports.USGGUI:setVisible(medsellGUI.window , false)
            exports.USGblur:setBlurDisabled()
        end
	end
end
addEvent("USGcnr_pharmacy.sell.close",true)
addEventHandler("USGcnr_pharmacy.sell.close",root,close)

function onBuyAspirin()
triggerServerEvent ( "buyAspirin",resourceRoot)
end

function onBuySteroid()
triggerServerEvent ( "buySteroid",resourceRoot)
end