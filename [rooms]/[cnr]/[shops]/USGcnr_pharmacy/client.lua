local medsellGUI = {}


function createMedsellGUI()


        medsellGUI.window = guiCreateWindow(593, 271, 232, 198, "USG - Pharmacy", false)
        guiWindowSetSizable(medsellGUI.window, false)

        medsellGUI.label[1] = guiCreateLabel(11, 38, 137, 28, "Steroid for 500$ per hit", false, medsellGUI.window)
        guiLabelSetHorizontalAlign(medsellGUI.label[1], "center", false)
        guiLabelSetVerticalAlign(medsellGUI.label[1], "center")
        medsellGUI.label[2] = guiCreateLabel(11, 76, 137, 28, "Aspirin for 500$ per hit", false, medsellGUI.window)
        guiLabelSetHorizontalAlign(medsellGUI.label[2], "center", false)
        guiLabelSetVerticalAlign(medsellGUI.label[2], "center")
        medsellGUI.label[3] = guiCreateLabel(11, 114, 137, 28, "Adderall for 500$ per hit", false, medsellGUI.window)
        guiLabelSetHorizontalAlign(medsellGUI.label[3], "center", false)
        guiLabelSetVerticalAlign(medsellGUI.label[3], "center")
        medsellGUI.buysteroid = guiCreateButton(160, 40, 62, 26, "Buy", false, medsellGUI.window)
        guiSetProperty(medsellGUI.buysteroid, "NormalTextColour", "FFAAAAAA")
        medsellGUI.buyaspirin  = guiCreateButton(160, 116, 62, 26, "Buy", false, medsellGUI.window)
        guiSetProperty(medsellGUI.buyaspirin , "NormalTextColour", "FFAAAAAA")
        medsellGUI.button[3] = guiCreateButton(160, 76, 62, 26, "Buy", false, medsellGUI.window)
        guiSetProperty(medsellGUI.button[3], "NormalTextColour", "FFAAAAAA")
        medsellGUI.close = guiCreateButton(76, 155, 82, 33, "Close", false, medsellGUI.window)
        guiSetProperty(medsellGUI.close, "NormalTextColour", "FFAAAAAA")    

    
        addEventHandler("onClientGUIClick",  medsellGUI.buysteroid, onBuySteroid , false)
    addEventHandler("onClientGUIClick",  medsellGUI.buyaspirin, onBuyAspirin , false)
    addEventHandler("onClientGUIClick",  medsellGUI.close, toggle , false)
end

function toggle()
if(not exports.USGaccounts:isPlayerLoggedIn()) then return end
    if(isElement(medsellGUI.window )) then
    if(guiGetVisible(medsellGUI.window )) then
    guiSetVisible(medsellGUI.window , false)
            showCursor(false)
            exports.USGblur:setBlurDisabled()
            else
            showCursor(true)
            guiSetVisible(medsellGUI.window , true)
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
    if(not guiGetVisible(medsellGUI.window )) then
            showCursor(true)
            guiSetVisible(medsellGUI.window , true)
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
    if(guiGetVisible(medsellGUI.window )) then
            showCursor(false)
            guiSetVisible(medsellGUI.window , false)
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