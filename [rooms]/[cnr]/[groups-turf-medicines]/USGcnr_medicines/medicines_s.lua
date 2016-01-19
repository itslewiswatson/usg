--IMPORTANT STUFF--
loadstring(exports.MySQL:getQueryTool())() --load the custom mysql tool

local defaultMedicines = {}

for k,_ in pairs(medicines) do
    defaultMedicines[k] = 10
end

local listeningPlayers = {}

--END OF IMPORTANT STUFF--

function isResourceReady(name)
    return getResourceFromName(name) and getResourceState(getResourceFromName(name)) == "running"
end

addEventHandler("onResourceStart", root,
    function (res) -- init job if thisResource started, or if USGcnr_jobs (re)started
        if((source == resourceRoot and isResourceReady("USGcnr_inventory")) or res == getResourceFromName("USGcnr_inventory")) then
            for name, medicine in pairs(medicines) do
                exports.USGcnr_inventory:create(medicine.key, "SMALLINT UNSIGNED", 0)
            end
        end
    end
)

function onPlayerRoomExit(prevRoom)
    listeningPlayers[source] = nil
end

function onPlayerQuit()
    listeningPlayers[source] = nil  
end
addEvent("onPlayerExitRoom", true)
addEventHandler("onPlayerExitRoom",root,onPlayerRoomExit)
addEventHandler("onPlayerQuit",root,onPlayerQuit)

function getPlayerMedicines(player)
    if(isElement(player) and exports.USGrooms:getPlayerRoom(player) == "cnr") then
        local pMedicines = {}
        for name, medicine in pairs(medicines) do
            pMedicines[name] = exports.USGcnr_inventory:get(player, medicine.key)
        end
        return pMedicines
    end
    return false
end

function getPlayerMedicineAmount(player, medicineType)
    if (player) and (isElement(player)) then
        if (exports.USGaccounts:isPlayerLoggedIn(player) and exports.USGrooms:getPlayerRoom(player) == "cnr") then
            return exports.USGcnr_inventory:get(player, medicines[medicineType].key) or false
        else
            return false
        end
    else
        return false
    end
end

function givePlayerMedicines(player, medicine, amount)
    if(not isElement(player) or exports.USGrooms:getPlayerRoom(player) ~= "cnr") then return false end
    exports.USGcnr_inventory:add(player, medicines[medicine].key, amount)
    if(listeningPlayers[player]) then
        triggerClientEvent(player, "USGcnr_medicines.recieveMedicines", player, { [medicine] = exports.USGcnr_inventory:get(player, medicines[medicine].key) })
    end 
    return true
end

function takePlayerMedicines(player, medicine, amount)
    if(not isElement(player) or not medicines[medicine]) then return false end
    exports.USGcnr_inventory:take(player, medicines[medicine].key, amount)
    if(listeningPlayers[player]) then
        triggerClientEvent(player, "USGcnr_medicines.recieveMedicines", player, { [medicine] = exports.USGcnr_inventory:get(player, medicines[medicine].key) })
    end 
    return true
end

addEvent("USGcnr_medicines.requestMedicines", true)
function playerRequestMedicines()
    listeningPlayers[client] = true
    triggerClientEvent(client, "USGcnr_medicines.recieveMedicines", client, getPlayerMedicines(client))
end
addEventHandler("USGcnr_medicines.requestMedicines", root, playerRequestMedicines)