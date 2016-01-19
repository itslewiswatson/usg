activeMedicines = {} -- [medicine] = {start,end}

function takeMedicine(medicine,amount)
    local amount = math.floor(amount)
    triggerServerEvent("USGcnr_medicines.takeMedicine", localPlayer, medicine, amount) -- server will deal with checking amount ( safer )
end


addEvent("USGcnr_medicines.onMedicineTaken", true)
function onMedicineTaken(medicine, activeTime)
    if(not activeMedicines[medicine]) then
        activeMedicines[medicine] = {getTickCount(), getTickCount()+activeTime}
    else
        activeMedicines[medicine][2] = activeMedicines[medicine][2]+activeTime
    end
end
addEventHandler("USGcnr_medicines.onMedicineTaken", localPlayer, onMedicineTaken)

addEvent("USGcnr_medicines.applyEffect", true)
function applyMedicineEffect(medicine)
    if(medicine == "Steroid") then
    
    elseif(medicine == "Aspirin") then
	
	elseif(medicine == "Adderall")then
    else
        return false
    end
    return true
end
addEventHandler("USGcnr_medicines.applyEffect", localPlayer, applyMedicineEffect)

addEvent("USGcnr_medicines.removeEffect", true)
function removeMedicineEffect(medicine)
    if(medicine == "Steroid") then
    
    elseif(medicine == "Aspirin") then
	
    elseif(medicine == "Adderall")then
    else
        return false
    end
    return true
end
addEventHandler("USGcnr_medicines.removeEffect", localPlayer, removeMedicineEffect)

addEventHandler("onClientResourceStop", resourceRoot,
    function ()
        if(activeMedicines) then
            for medicine, endTick in pairs(activeMedicines) do
                removeMedicineEffect(medicine)
            end
        end
    end
)


function cmdTakeMedicine(cmd, arg1, arg2)
    if(exports.USGrooms:getPlayerRoom() ~= "cnr") then return false end
    local medicine, amount
    if(tonumber(arg1) and not arg2 or arg2 == "") then
        medicine = getSelectedMedicine()
        amount = tonumber(arg1)
    elseif(arg1 and arg2) then
        medicine = arg1
        amount = tonumber(arg2)
    end
    if(not amount or math.floor(amount) <= 0) then
        exports.USGmsg:msg("Amount must be more than 0, syntaxes: /cmd medicine amount | /cmd amount",255,0,0)
        return false
    end
    amount = math.floor(amount)
    if(medicine) then
        for i, medicineType in ipairs(getMedicineTypes()) do
            if(medicineType:lower() == medicine:lower()) then
                medicine = medicineType
                break
            end
        end
    end
    if(not medicine or not medicines[medicine]) then
        exports.USGmsg:msg(
            tonumber(arg1) and "You have not selected any medicines!" 
            or "This medicine doesn't exist, syntaxes: /cmd medicine amount | /cmd amount"
        , 255, 0, 0)
        return false
    end
    takeMedicine(medicine, amount)
end
addCommandHandler("takemedicine", cmdTakeMedicine, false, false)
addCommandHandler("takehit", cmdTakeMedicine, false, false)

function renderMedicines()
    local x = 15
    local layout = getChatboxLayout()
    local y = 20+(1+layout["chat_lines"])*layout["chat_scale"][2]*15
    for medicine, times in pairs(activeMedicines) do
        local progress = (getTickCount()-times[1])/(times[2]-times[1])
        if(progress >= 1) then
            activeMedicines[medicine] = nil
        else
            local r,g,b = progress*255, (1-progress)*255, 0
            dxDrawRectangle(x, y, 150,20,tocolor(0,0,0,200))
            dxDrawRectangle(x+2, y+2, 146*(1-progress),16,tocolor(r,g,b,255))
            dxDrawText(medicine,x,y,x+150,y+20,tocolor(255,255,255),1,"default-bold","center","center")
            y = y +25
        end
    end
end
