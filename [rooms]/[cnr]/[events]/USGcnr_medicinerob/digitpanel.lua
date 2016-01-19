fileDelete("digitpanel.lua")
local digitGUI = {}

local Digit1,Digit2,Digit3,Digit4

function createDigitGUI()
    exports.USGGUI:setDefaultTextAlignment("center","center")
    digitGUI.window = exports.USGGUI:createWindow("center","center", 200, 150, false,"Password Panel")
    digitGUI.memo1 = exports.USGGUI:createMemo("left", "top", 45, 30, false,  " ",digitGUI.window)
    digitGUI.memo2 = exports.USGGUI:createMemo(50, "top", 45, 30, false,  " ",digitGUI.window)
    digitGUI.memo3 = exports.USGGUI:createMemo(105, "top", 45, 30, false,  " ",digitGUI.window)
    digitGUI.memo4 = exports.USGGUI:createMemo("right", "top", 45, 30, false,  " ",digitGUI.window)
        exports.USGGUI:setProperty( digitGUI.memo1, "readOnly", true)
        exports.USGGUI:setProperty( digitGUI.memo2, "readOnly", true)
        exports.USGGUI:setProperty( digitGUI.memo3, "readOnly", true)
        exports.USGGUI:setProperty( digitGUI.memo4, "readOnly", true)
        exports.USGGUI:createLabel("center",30, 198, 30,false,"Wrong/Right",digitGUI.window)
        
    digitGUI.one = exports.USGGUI:createButton("left",65,90,25,false," 1 ",digitGUI.window,100,100,100)
    digitGUI.two = exports.USGGUI:createButton("right",65,90,25,false," 2 ",digitGUI.window,100,100,100)
    digitGUI.three = exports.USGGUI:createButton("left",90,90,25,false," 3 ",digitGUI.window,100,100,100)
    
    digitGUI.try = exports.USGGUI:createButton("left","bottom",70,25,false," Try ",digitGUI.window)
    digitGUI.close = exports.USGGUI:createButton("right","bottom",70,25,false," Close ",digitGUI.window)
    
    addEventHandler("onUSGGUISClick",  digitGUI.one, onPressOne , false)
    addEventHandler("onUSGGUISClick",  digitGUI.two, onPressTwo , false)
    addEventHandler("onUSGGUISClick",  digitGUI.three, onPressThree , false)
    addEventHandler("onUSGGUISClick",  digitGUI.try, onTrying , false)
    addEventHandler("onUSGGUISClick",  digitGUI.close, toggledigitGUI , false)

end

function close()
    if(not exports.USGaccounts:isPlayerLoggedIn()) then return end
        if(isElement(digitGUI.window )) then
             exports.USGGUI:setVisible(digitGUI.window , false)
                showCursor(false)
         end

end

addEvent("USGcnr_medicinerob.HackPanel.hide",true)
addEventHandler("USGcnr_medicinerob.HackPanel.hide",root,close)

function open(digit1,digit2,digit3,digit4)
    if(not exports.USGaccounts:isPlayerLoggedIn()) then return end
        if(isElement(digitGUI.window )) then
            showCursor(true)
            exports.USGGUI:setVisible(digitGUI.window , true)
        else
            createDigitGUI()
            showCursor(true)
            Digit1 = tostring(digit1)
            Digit2 = tostring(digit2)
            Digit3 = tostring(digit3)
            Digit4 = tostring(digit4)
        end  
    outputChatBox("First digit is: "..tostring(Digit1))
end
addEvent("USGcnr_medicinerob.HackPanel.show",true)
addEventHandler("USGcnr_medicinerob.HackPanel.show",root,open)

function toggledigitGUI(digit1,digit2,digit3,digit4)
if(not exports.USGaccounts:isPlayerLoggedIn()) then return end
    if(isElement(digitGUI.window )) then
        if(exports.USGGUI:getVisible(digitGUI.window )) then
         exports.USGGUI:setVisible(digitGUI.window , false)
            showCursor(false)
            else
            showCursor(true)
            exports.USGGUI:setVisible(digitGUI.window , true)
        end
    else
        createDigitGUI()
        showCursor(true)
        Digit1 = tostring(digit1)
        Digit2 = tostring(digit2)
        Digit3 = tostring(digit3)
        Digit4 = tostring(digit4)
    end 
end 
addEvent("USGcnr_medicinerob.HackPanel",true)
addEventHandler("USGcnr_medicinerob.HackPanel",root,toggledigitGUI)

function onPressOne()
    if(isElement(digitGUI.memo1)) and (isElement(digitGUI.memo2)) and (isElement(digitGUI.memo3)) and (isElement(digitGUI.memo4)) then
        if (exports.USGGUI:getText(digitGUI.memo1) == " ") then
            exports.USGGUI:setText(digitGUI.memo1, "1")  return end
            if (exports.USGGUI:getText(digitGUI.memo2) == " ") then
                exports.USGGUI:setText(digitGUI.memo2, "1")  return end
                if (exports.USGGUI:getText(digitGUI.memo3) == " ") then
                    exports.USGGUI:setText(digitGUI.memo3, "1") return end
                    if (exports.USGGUI:getText(digitGUI.memo4) == " ") then
                        exports.USGGUI:setText(digitGUI.memo4, "1") 
                        return end
                    end

end

function onPressTwo()
    if(isElement(digitGUI.memo1)) and (isElement(digitGUI.memo2)) and (isElement(digitGUI.memo3)) and (isElement(digitGUI.memo4)) then
        if (exports.USGGUI:getText(digitGUI.memo1) == " ") then
            exports.USGGUI:setText(digitGUI.memo1, "2")  return end
            if (exports.USGGUI:getText(digitGUI.memo2) == " ") then
                exports.USGGUI:setText(digitGUI.memo2, "2")  return end
                if (exports.USGGUI:getText(digitGUI.memo3) == " ") then
                    exports.USGGUI:setText(digitGUI.memo3, "2") return end
                    if (exports.USGGUI:getText(digitGUI.memo4) == " ") then
                        exports.USGGUI:setText(digitGUI.memo4, "2") 
                        return end
                    end
end

function onPressThree()
    if(isElement(digitGUI.memo1)) and (isElement(digitGUI.memo2)) and (isElement(digitGUI.memo3)) and (isElement(digitGUI.memo4)) then
        if (exports.USGGUI:getText(digitGUI.memo1) == " ") then
            exports.USGGUI:setText(digitGUI.memo1, "3")  return end
            if (exports.USGGUI:getText(digitGUI.memo2) == " ") then
                exports.USGGUI:setText(digitGUI.memo2, "3")  return end
                if (exports.USGGUI:getText(digitGUI.memo3) == " ") then
                    exports.USGGUI:setText(digitGUI.memo3, "3") return end
                    if (exports.USGGUI:getText(digitGUI.memo4) == " ") then
                        exports.USGGUI:setText(digitGUI.memo4, "3") 
                        return end
                    end
end


function onTrying()
    if (exports.USGGUI:getText(digitGUI.memo1) == Digit1) and (exports.USGGUI:getText(digitGUI.memo2) == Digit2) and (exports.USGGUI:getText(digitGUI.memo3) == Digit3) and (exports.USGGUI:getText(digitGUI.memo4) == Digit4) then
    triggerServerEvent("USGcnr_medicinerob.onPanelHacked",resourceRoot)
    close()
    else exports.USGGUI:setText(digitGUI.memo1, " ")
        exports.USGGUI:setText(digitGUI.memo2, " ")
        exports.USGGUI:setText(digitGUI.memo3, " ")
        exports.USGGUI:setText(digitGUI.memo4, " ")
    end  
end
