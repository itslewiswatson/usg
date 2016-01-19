local medicinesGUI = {}
function createDedicinesGUI()
    medicinesGUI.window = exports.USGGUI:createWindow("center","center",200,255,false,"Medicines")
    exports.USGGUI:setDefaultTextAlignment("left","center")
    medicinesGUI.medicineLabels = {}
    medicinesGUI.medicineRadios = {}
    local y = 5
    for medicine, _ in pairs(medicines) do
    medicinesGUI.medicineLabels[medicine] = exports.USGGUI:createLabel(5,y,135,30,false,medicine..":",medicinesGUI.window)
    medicinesGUI.medicineRadios[medicine] = exports.USGGUI:createRadioButton(145,y,60,35,false, myMedicines and tostring(myMedicines[medicine]) or "0", medicinesGUI.window)
        y = y+35
    end
    medicinesGUI.amount = exports.USGGUI:createEditBox(5,y+5,110,25,false,"",medicinesGUI.window)
    medicinesGUI.take = exports.USGGUI:createButton(130,y+5,60,25,false,"Take",medicinesGUI.window)
    exports.USGGUI:setSize(medicinesGUI.window, 200, y+35, false)
    addEventHandler("onUSGGUISClick", medicinesGUI.take, onTakeMedicine, false)
end

function updateMyMedicines(new)
    for medicine, amount in pairs(new) do
        myMedicines[medicine] = amount
    end
end

addEvent("USGcnr_medicines.recieveMedicines", true)
function recieveMedicines(medicines)
    if(not myMedicines) then myMedicines = medicines
    else updateMyMedicines(medicines) end
    if(isElement(medicinesGUI.window)) then
        for medicine, amount in pairs(medicines) do
        if(medicinesGUI.medicineRadios[medicine]) then
            exports.USGGUI:setText(medicinesGUI.medicineRadios[medicine], amount)
            end
        end
    end
end
addEventHandler("USGcnr_medicines.recieveMedicines", localPlayer, recieveMedicines)

function toggleDedicinesGUI()
    if(not isElement(medicinesGUI.window) or not exports.USGGUI:getVisible(medicinesGUI.window)) then
        openDedicinesGUI()
    else
        closeDedicinesGUI()
    end
end
addCommandHandler("medicines", toggleDedicinesGUI)
bindKey("F4","down","medicines")

function openDedicinesGUI()
    if(exports.USGrooms:getPlayerRoom() ~= "cnr") then return false end
    if(not isElement(medicinesGUI.window)) then
        createDedicinesGUI()
    else
        exports.USGGUI:setVisible(medicinesGUI.window, true)
    end
    showCursor(true)
end

function closeDedicinesGUI()
    exports.USGGUI:setVisible(medicinesGUI.window, false)
    showCursor(false)
end

addEventHandler("onPlayerExitRoom", localPlayer,
    function (prevRoom)
        if(prevRoom == "cnr") then
            myMedicines = nil
            activeMedicines = nil
            removeEventHandler("onClientRender", root, renderMedicines)         
            if(isElement(medicinesGUI.window)) then
                closeDedicinesGUI()
                destroyElement(medicinesGUI.window)
            end
        end
    end
)

addEventHandler("onClientResourceStart", root,
    function (res)
        if(source == resourceRoot and getResourceFromName("USGrooms") and getResourceState(getResourceFromName("USGrooms")) == "running"
        and exports.USGRooms:getPlayerRoom() == "cnr") then
            activeMedicines = {}
            triggerServerEvent("USGcnr_medicines.requestMedicines", localPlayer) -- this will also subscribe the user to updates
            addEventHandler("onClientRender", root, renderMedicines)
            addMedicineTypesToInventory()
        elseif(getResourceName(res) == "USGcnr_inventory") then
            addMedicineTypesToInventory()
        end
    end
)

function isResourceReady(name)
    return getResourceFromName(name) and getResourceState(getResourceFromName(name)) == "running"
end

function addMedicineTypesToInventory()
    if(isResourceReady("USGcnr_inventory")) then
        for name, medicine in pairs(medicines) do
            exports.USGcnr_inventory:create(medicine.key,name, ":USGcnr_medicines/"..medicine.key..".png")
        end
    end
end

addEventHandler("onPlayerJoinRoom", localPlayer,
    function (room)
        if(room == "cnr") then
            addMedicineTypesToInventory()
            activeMedicines = {}
            triggerServerEvent("USGcnr_medicines.requestMedicines", localPlayer) -- this will also subscribe the user to updates
            addEventHandler("onClientRender", root, renderMedicines)            
        end
    end
)

----

function getSelectedMedicine()
    for medicine, radio in pairs(medicinesGUI.medicineRadios) do
        if(exports.USGGUI:getRadioButtonState(radio)) then
            return medicine
        end
    end
    return false
end

function onTakeMedicine()
    local amount = tonumber(exports.USGGUI:getText(medicinesGUI.amount))
    if(not amount or amount <= 0) then
        exports.USGmsg:msg("Invalid number, must be more than 0!", 255, 0, 0)
        return
    end
    local medicine = getSelectedMedicine()
    if(not medicine) then
        exports.USGmsg:msg("You must select a medicine!", 255, 0, 0)
        return      
    end
    takeMedicine(medicine, amount)
end