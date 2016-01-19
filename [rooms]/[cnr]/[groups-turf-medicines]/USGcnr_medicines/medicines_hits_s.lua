local playerActiveMedicines = {}
local TIME_PER_HIT = 60000

function takeMedicine(player, medicine, amount)
    if(not isElement(player) or exports.USGrooms:getPlayerRoom(player) ~= "cnr" or not medicines[medicine]) then
        return false
    end
    amount = math.floor(amount)
	if (amount > getPlayerMedicineAmount(player,medicine))then
		exports.USGmsg:msg(player, "You do not have enough "..medicine.." to take "..amount.." hits!", 255, 0, 0)
		return false
	end
    if(takePlayerMedicines(player, medicine, amount)) then
        local activeTime = TIME_PER_HIT*amount
        if(playerActiveMedicines[player]) then
            if(playerActiveMedicines[player][medicine]) then
                playerActiveMedicines[player][medicine] = playerActiveMedicines[player][medicine] + activeTime -- already applied
            else
                playerActiveMedicines[player][medicine] = activeTime+getTickCount()
                applyMedicineEffect(player, medicine)
            end
        else
            playerActiveMedicines[player] = { [medicine] = activeTime+getTickCount() }
            applyMedicineEffect(player, medicine)
        end
        triggerClientEvent(player, "USGcnr_medicines.onMedicineTaken", player, medicine, activeTime)
    else
        exports.USGmsg:msg(player, "You do not have enough "..medicine.." to take "..amount.." hits!", 255, 0, 0)
        return false
    end
end

function decreaseActiveMedicines()
    local tick = getTickCount()
    for player, medicines in pairs(playerActiveMedicines) do
        local canDelete = true
        for medicine, endTick in pairs(medicines) do
            if(tick >= endTick) then
                removeMedicineEffect(player, medicine)
                medicines[medicine] = nil
            else
                canDelete = false -- still an active medicine
            end
        end
        if(canDelete) then -- no more active medicines, remove this player
            playerActiveMedicines[player] = nil
        end
    end
end
setTimer(decreaseActiveMedicines,1000,0)

local timer = {}

function applyMedicineEffect(player, medicine)
local player = player
    if(medicine == "Steroid") then
        setPedStat(player, 24, 1000)
    elseif(medicine == "Aspirin") then
        timer[player] = setTimer(function()
			if(isElement(player))then
				local hp = getElementHealth(player)
					if(hp > 2)then
						setElementHealth(player,hp + 10)
					end
			else killTimer(timer[player])
			end
		end,5000,0)
    elseif (medicine == "Adderall")then
	else
        return false
    end
	triggerClientEvent(player,"USGcnr_medicines.applyEffect",player,medicine)
    return true
end

function removeMedicineEffect(player, medicine)
    if(medicine == "Steroid") then
        setPedStat(player, 24, 569)
        local hp = getElementHealth(player)
			if (hp > 100) then
				setElementHealth(player, 100)
			end
        --[[
		if (hp < 90) then
            setElementHealth(player, hp + 10)
        end
		--]]
    elseif(medicine == "Aspirin") then
		killTimer(timer[player])
    elseif (medicine == "Adderall")then
	else
		return false
    end
	triggerClientEvent(player,"USGcnr_medicines.removeEffect",player,medicine)
    return true
end

addEvent("USGcnr_medicines.takeMedicine", true)
function onPlayerTakeMedicine(medicine, amount)
    takeMedicine(client, medicine, amount)
end
addEventHandler("USGcnr_medicines.takeMedicine", root, onPlayerTakeMedicine)



function onPlayerExit()
    --aspirinTimeout[source] = nil
    if(playerActiveMedicines[source]) then
        for medicine, amount in pairs(playerActiveMedicines[source]) do
            removeMedicineEffect(source, medicine)
        end
    end
    playerActiveMedicines[source] = nil
end

addEventHandler("onPlayerExitRoom",root,onPlayerExit)
addEventHandler("onPlayerQuit",root,onPlayerExit)


