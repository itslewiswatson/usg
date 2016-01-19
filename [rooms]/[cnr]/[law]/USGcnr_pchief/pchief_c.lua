fileDelete("pchief_c.lua")
local policeChiefGUI = {}
local customMsgGUI = {}
local pChief = {}
local access = false
local policeChiefs

addEvent("onPlayerJoinRoom", true)
addEvent("onPlayerExitRoom", true)
addEvent("USGcnr_pchief.receiveBanList", true)

addEvent("USGcnr_pchief.onPoliceChiefConnect", true)
function setPoliceChiefData(chiefs)
    if(not access) then
        addCommandHandler("pchiefpanel", togglePoliceChiefGUI)
        addEventHandler("USGcnr_pchief.updatePoliceChiefList", root, updateChiefList)
        addEventHandler("USGcnr_pchief.receiveBanList", localPlayer, receiveBanList)
        addEventHandler("onClientPlayerChangeNick", root, onPlayerChangeNick)
        addEventHandler("onClientPlayerQuit", root, onPlayerQuit)
        addEventHandler("onPlayerExitRoom", root, onPlayerExitRoom)
        addEventHandler("onPlayerJoinRoom", root, onPlayerJoinRoom)        
    end
    access = true
    policeChiefs = chiefs
end
addEventHandler("USGcnr_pchief.onPoliceChiefConnect", localPlayer, setPoliceChiefData)

addEvent("USGcnr_pchief.onPoliceChiefKicked", true)
function removePoliceChiefData()
    if(access) then
        removeCommandHandler("pchiefpanel", togglePoliceChiefGUI)
        removeEventHandler("USGcnr_pchief.updatePoliceChiefList", root, updateChiefList)
        removeEventHandler("USGcnr_pchief.receiveBanList", localPlayer, receiveBanList)
        removeEventHandler("onClientPlayerChangeNick", root, onPlayerChangeNick)
        removeEventHandler("onClientPlayerQuit", root, onPlayerQuit)
        removeEventHandler("onPlayerExitRoom", root, onPlayerExitRoom)
        removeEventHandler("onPlayerJoinRoom", root, onPlayerJoinRoom)
        closePoliceChiefGUI()
        if(isElement(policeChiefGUI.window)) then
            destroyElement(policeChiefGUI.window)
        end
        closeMSGGUI()
        if(isElement(customMsgGUI.window)) then
            destroyElement(customMsgGUI.window)
        end
    end
    policeChiefs = nil
    access = false
end
addEventHandler("USGcnr_pchief.onPoliceChiefKicked", localPlayer, removePoliceChiefData)

addEvent("USGcnr_pchief.updatePoliceChiefList", true)
function updateChiefList(account, value)
    if(policeChiefs) then
        policeChiefs[account] = value
    end
end

function createPoliceChiefGUI()
    policeChiefGUI.window = exports.USGGUI:createWindow("center","center",650,370,false,"Police Chief")
    policeChiefGUI.grid = exports.USGGUI:createGridList(5,5,200,340,false,policeChiefGUI.window)
    policeChiefGUI.banslist = exports.USGGUI:createGridList(445,5,200,340,false,policeChiefGUI.window)
    policeChiefGUI.column = exports.USGGUI:gridlistAddColumn(policeChiefGUI.grid,"Players", 1.0)
    policeChiefGUI.banscolumn = exports.USGGUI:gridlistAddColumn(policeChiefGUI.banslist,"Banned Players", 1.0)
    policeChiefGUI.kick = exports.USGGUI:createButton(786-454, 225-200, 99, 38,false,"Kick from the Cop Job",policeChiefGUI.window)
    policeChiefGUI.ban = exports.USGGUI:createButton(673-454, 287-200, 99, 38, false,"Ban from the Cop Job",policeChiefGUI.window)
    policeChiefGUI.warn = exports.USGGUI:createButton(673-454, 225-200, 99, 38,false, "Warn Cop",policeChiefGUI.window)
    policeChiefGUI.unban = exports.USGGUI:createButton(786-454, 287-200, 99, 38,false, "Unban from the Cop Job",policeChiefGUI.window)
    policeChiefGUI.givecopjob = exports.USGGUI:createButton(730-454, 345-200, 99, 38,false, "Give Player Cop Job",policeChiefGUI.window)
    policeChiefGUI.giverank = exports.USGGUI:createButton(673-454, 458-200, 212, 38,false, "Promote/Give Police Chief",policeChiefGUI.window)
    policeChiefGUI.removerank = exports.USGGUI:createButton(673-454, 507-200, 212, 38,false, "Demote/Kick Police Chief",policeChiefGUI.window)
    addEventHandler("onUSGGUISClick", policeChiefGUI.kick, kickFromCopJob , false)
    addEventHandler("onUSGGUISClick", policeChiefGUI.ban, banFromCopJob , false)
    addEventHandler("onUSGGUISClick", policeChiefGUI.warn, warnCop , false)
    addEventHandler("onUSGGUISClick", policeChiefGUI.unban, unbanFromCopJob , false)
    addEventHandler("onUSGGUISClick", policeChiefGUI.givecopjob , giveCopJob , false)
    addEventHandler("onUSGGUISClick", policeChiefGUI.giverank , promotePoliceChief , false)
    addEventHandler("onUSGGUISClick", policeChiefGUI.removerank , demotePoliceChief , false)
end

function createCustomMsgGUI()
    customMsgGUI.window = exports.USGGUI:createWindow("center","center",400,90,false,"Custom Message")
    customMsgGUI.editbox = exports.USGGUI:createEditBox(5,5,390,30,false,"Enter your Custom Message here | Time", customMsgGUI.window,nil,true)
    customMsgGUI.done = exports.USGGUI:createButton(150,42, 99, 38,false,"Done",customMsgGUI.window)
    addEventHandler("onUSGGUISClick", customMsgGUI.done, submitAction, false)   
end

function submitAction()
    pChief.message = exports.USGGUI:getText(customMsgGUI.editbox)
    if(pChief.action == "warn")then
        triggerServerEvent("USGcnr_pchief.warnCop", pChief.target, pChief.message)
    elseif (pChief.action == "ban")then
        if(tonumber(pChief.message))then
            triggerServerEvent("USGcnr_pchief.banCop", pChief.target, pChief.message)
        else 
            exports.USGmsg:msg("Please specify the amount of minutes.", 255, 0, 0)
        end
    end
    closeMSGGUI()
end

function togglePoliceChiefGUI()
    if(not isElement(policeChiefGUI.window) or not exports.USGGUI:getVisible(policeChiefGUI.window)) then
        openPoliceChiefGUI()
    else
        closePoliceChiefGUI()
        closeMSGGUI()
    end
end

function openMSGGUI()
    if(exports.USGrooms:getPlayerRoom() ~= "cnr") then return false end
    if(not isElement(customMsgGUI.window)) then
        createCustomMsgGUI()
    else
        exports.USGGUI:setVisible(customMsgGUI.window, true)
    end
end

function closeMSGGUI()
    if(isElement(customMsgGUI.window) and exports.USGGUI:setVisible(customMsgGUI.window)) then
        exports.USGGUI:setVisible(customMsgGUI.window, false)
    end
end

function openPoliceChiefGUI()
    if(exports.USGrooms:getPlayerRoom() ~= "cnr") then return false end
    if(not isElement(policeChiefGUI.window)) then
        createPoliceChiefGUI()
    else
        exports.USGGUI:setVisible(policeChiefGUI.window, true)
    end
    showCursor(true)
    fillPlayerGrid()
    triggerServerEvent("USGcnr_pchief.requestBanList", localPlayer)
end

function closePoliceChiefGUI()
    if (isElement(policeChiefGUI.window) and exports.USGGUI:getVisible(policeChiefGUI.window))then
        exports.USGGUI:setVisible(policeChiefGUI.window, false)
        showCursor(false)
        exports.USGGUI:gridlistClear(policeChiefGUI.grid)
    end
end

function receiveBanList(bans)
    if(isElement(policeChiefGUI.banslist)) then
        exports.USGGUI:gridlistClear(policeChiefGUI.banslist)
        for i, player in ipairs(getElementsByType("player")) do
            if(exports.USGaccounts:isPlayerLoggedIn(player) and exports.USGrooms:getPlayerRoom(player) == "cnr") then
                if(bans[exports.USGaccounts:getPlayerAccount(player)]) then
                    local row = exports.USGGUI:gridlistAddRow(policeChiefGUI.banslist)
                    exports.USGGUI:gridlistSetItemText(policeChiefGUI.banslist, row, 1, getPlayerName(player))
                end
            end
        end
    end
end

function addPlayerToGrid(player,filter)
    if ( isElement(policeChiefGUI.grid) ) then
        local nick = getPlayerName(player)
        local r, g, b = exports.USG:getPlayerTeamColor(player)
        local row = exports.USGGUI:gridlistAddRow(policeChiefGUI.grid)
        exports.USGGUI:gridlistSetItemText(policeChiefGUI.grid,row,1,nick)
        exports.USGGUI:gridlistSetItemColor(policeChiefGUI.grid,row,1,tocolor(r,g,b))
        exports.USGGUI:gridlistSetItemData(policeChiefGUI.grid,row,1,player)
        playerRow[player] = row
    end
end

function fillPlayerGrid()
    if ( isElement(policeChiefGUI.grid) ) then
        playerRow = {}
        exports.USGGUI:gridlistClear(policeChiefGUI.grid)
        local players = getElementsByType("player")
        for i, player in ipairs(players) do
            if(exports.USGaccounts:isPlayerLoggedIn(player) and exports.USGrooms:getPlayerRoom(player) == "cnr") then
                addPlayerToGrid(player)
            end
        end
    end
end

function onPlayerChangeNick(old, new)
    if(isElement(policeChiefGUI.grid)) then
        if(playerRow[source]) then
            exports.USGGUI:gridlistSetItemText(policeChiefGUI.grid,playerRow[source],1,new)
        else
            fillPlayerGrid()
        end
    end
end

function onPlayerJoinRoom(room)
    if(room == "cnr") then
        addPlayerToGrid(source)
    end
end

function onPlayerExitRoom(room)
    if(source == localPlayer) then
        removePoliceChiefData()
    end
    if(room == "cnr") then
        fillPlayerGrid()
    end
end

function onPlayerQuit()
    if(exports.USGrooms:getPlayerRoom(source) == "cnr") then
        fillPlayerGrid()
    end
end

function gridlistGetPlayer()
    local selected = exports.USGGUI:gridlistGetSelectedItem(policeChiefGUI.grid)
    if(selected) then
        local player = exports.USGGUI:gridlistGetItemData(policeChiefGUI.grid, selected, 1)
        if(isElement(player)) then
            return player
        end
    end
    return false
end

function kickFromCopJob()
    local player = gridlistGetPlayer()
    if (player) then
        triggerServerEvent("USGcnr_pchief.kickCop", player)
    else 
        exports.USGmsg:msg("Please select a player.", 255, 0, 0)
    end
end

function banFromCopJob()
    local player = gridlistGetPlayer()
    if (player) then
        pChief.action = "ban"
        pChief.target = player
        openMSGGUI()
    else 
        exports.USGmsg:msg("Please select a player.", 255, 0, 0)
    end
end

function warnCop()
    local player = gridlistGetPlayer()
    if (player ) then
        pChief.action = "warn"
        pChief.target = player
        openMSGGUI()
    else 
        exports.USGmsg:msg("Please select a player.", 255, 0, 0)
    end
end

function unbanFromCopJob()
    local player = gridlistGetPlayer()
    if (player) then
        triggerServerEvent("USGcnr_pchief.unbanCop", player)
    else 
        exports.USGmsg:msg("Please select a player.", 255, 0, 0)
    end
end

function giveCopJob()
    local player = gridlistGetPlayer()
    if (player ) then
        triggerServerEvent("USGcnr_pchief.giveCop", player)
    else 
        exports.USGmsg:msg("Please select a player.", 255, 0, 0)
    end
end

function isPlayerPoliceChief(player)
    if(isElement(player) and exports.USGaccounts:isPlayerLoggedIn(player)) then
        return policeChiefs[exports.USGaccounts:getPlayerAccount(player)] ~= nil
    end
    return false
end

function getPoliceChiefLevel(player)
    if(isPlayerPoliceChief(player)) then
        return policeChiefs[exports.USGaccounts:getPlayerAccount(player)]
    end
    return false
end

function promotePoliceChief()
    local player = gridlistGetPlayer()
    if (player and player ~= localPlayer) then
        triggerServerEvent("USGcnr_pchief.promotePchief", player)
    else 
        exports.USGmsg:msg("Please select a player that isn't you.", 255, 0, 0)
    end
end

function demotePoliceChief()
    local player = gridlistGetPlayer()
    if (player and player ~= localPlayer) then
        if(isPlayerPoliceChief(player)) then
            triggerServerEvent("USGcnr_pchief.demotePchief", player)
        else
            exports.USGmsg:msg("This player is not a police chief.", 255, 0, 0)
        end
    else 
        exports.USGmsg:msg("Please select a player that isn't you.", 255, 0, 0)
    end
end