function trim(s)
  return s:match'^()%s*$' and '' or s:match'^%s*(.*%S)'
end

local BLIPDATA_KEY = "USGblips_blipData"

local blipsFile
local blipsCategories = {}
local blipToID = {}
local blipToCat = {}
local GUI = {}
local sW,sH = guiGetScreenSize()
local toggleAllState

addEventHandler("onClientResourceStop",resourceRoot,
    function ()
        saveBlips()
        if(isElement(GUI.window)) then
            if(exports.USGGUI:getVisible(GUI.window)) then
                toggleBlipGUI()
            end
            destroyElement(GUI.window)
        end
    end
)

addEventHandler("onClientResourceStart",resourceRoot,
    function ()
        if ( fileExists("blipInfo.xml") ) then
            blipsFile = xmlLoadFile("blipInfo.xml")
        end
        if not blipsFile then
            blipsFile = xmlCreateFile("blipInfo.xml","categories")
            xmlSaveFile(blipsFile)
        end
        local children = xmlNodeGetChildren(blipsFile)
        local visibleCount = 0
        local invisibleCount = 0
        for _,category in ipairs(children) do
            local catTable = { createdBlips = {}, createdBlipsID = 0}
            local name = trim(xmlNodeGetValue(category))
            catTable.visible = xmlNodeGetAttribute(category,"visible") == "true"
            local blips = xmlNodeGetChildren(category)
            if not catTable.visible then
                invisibleCount = invisibleCount + 1
            else
                visibleCount = visibleCount + 1
            end
            catTable.blips = {}
            for _,blip in ipairs(blips) do
                local name = xmlNodeGetValue(blip)
                local visible = xmlNodeGetAttribute(blip,"visible" ) == "true"
                catTable.blips[name] = {visible = visible}
            end
            blipsCategories[name] = catTable
        end
        toggleAllState = visibleCount > invisibleCount
        xmlUnloadFile(blipsFile)
    end
)

function toggleAll(btn,state)
    if btn == 1 and state == "down" then
        toggleAllState = not toggleAllState
        for _,category in pairs(blipsCategories) do
            category.visible = toggleAllStats
        end
        refreshGrids(true)
        local cat = getSelectedCategory()
        if cat then loadCategoryBlips(cat) end
        refreshCreatedBlips()
    end
end

function saveBlips()
    blipsFile = xmlCreateFile("blipInfo.xml","categories")
    for catName,cat in pairs(blipsCategories) do
        local catNode = xmlCreateChild(blipsFile,"category")
        xmlNodeSetValue(catNode,catName)
        xmlNodeSetAttribute(catNode,"visible",tostring(cat.visible))
        for blipName,blip in pairs(cat.blips) do
            local blipNode = xmlCreateChild(catNode,"blip")
            xmlNodeSetValue(blipNode,blipName)
            xmlNodeSetAttribute(blipNode,"visible",tostring(blip.visible))
        end
    end
    xmlSaveFile(blipsFile)
    refreshCreatedBlips()
end

function onSaveClick(btn,state)
    if btn == 1 and state == "down" then
        saveBlips()
        toggleBlipGUI()
    end
end

-- GUI

function refreshGrids(keepSelection)
    if ( isElement(GUI.window) ) then
        exports.USGgui:gridlistClear(GUI.categoryGrid,keepSelection)
        exports.USGgui:gridlistClear(GUI.blipsGrid,keepSelection)
        for catName,cat in pairs(blipsCategories) do
            local row = exports.USGgui:gridlistAddRow(GUI.categoryGrid)
            exports.USGgui:gridlistSetItemText(GUI.categoryGrid,row,1,catName)
            exports.USGgui:gridlistSetItemData(GUI.categoryGrid,row,1,catName)
            if cat.visible then
                exports.USGgui:gridlistSetItemColor(GUI.categoryGrid,row,1,tocolor(0,255,0))
            else
                exports.USGgui:gridlistSetItemColor(GUI.categoryGrid,row,1,tocolor(255,0,0))
            end
        end
    end
end

function loadCategoryBlips(category)
    if ( isElement(GUI.window) ) then
        exports.USGgui:gridlistClear(GUI.blipsGrid)
        for blipName,blip in pairs(category.blips) do
            local row = exports.USGgui:gridlistAddRow(GUI.blipsGrid)
            exports.USGgui:gridlistSetItemText(GUI.blipsGrid,row,1,blipName)
            if blip.visible and category.visible then
                exports.USGgui:gridlistSetItemColor(GUI.blipsGrid,row,1,tocolor(0,255,0))
            else
                exports.USGgui:gridlistSetItemColor(GUI.blipsGrid,row,1,tocolor(255,0,0))
            end     
        end
    end
end

function getSelectedCategory()
    if ( isElement(GUI.window) ) then
        local selectedRow = exports.USGgui:gridlistGetSelectedItem(GUI.categoryGrid)
        if selectedRow then
            local catName = exports.USGgui:gridlistGetItemData(GUI.categoryGrid,selectedRow,1)
            local cat = blipsCategories[catName]
            return cat, selectedRow
        end
    end
    return false
end

function onCategoryGridClick(btn,state)
    if state == "down" then
        local cat, selectedRow = getSelectedCategory()
        if cat then
            if btn == 1 then
                loadCategoryBlips(cat)
            elseif btn == 2 then
                cat.visible = not cat.visible
                if cat.visible then
                    exports.USGgui:gridlistSetItemColor(source,selectedRow,1,tocolor(0,255,0))
                else
                    exports.USGgui:gridlistSetItemColor(source,selectedRow,1,tocolor(255,0,0))
                end
                loadCategoryBlips(cat)
                refreshCategoryBlips(cat)
            end
        end 
    end
end

function onBlipGridClick(btn,state)
    if state == "down" then
        local selectedRow = exports.USGgui:gridlistGetSelectedItem(source)
        if selectedRow then
            local blipName = exports.USGgui:gridlistGetItemText(source,selectedRow,1)
            local cat, catRow = getSelectedCategory()
            if cat then
                if btn == 1 or btn == 2 then
                    cat.blips[blipName].visible = not cat.blips[blipName].visible
                    if cat.blips[blipName].visible and cat.visible then
                        exports.USGgui:gridlistSetItemColor(source,selectedRow,1,tocolor(0,255,0))
                        cat.visible = true
                        exports.USGgui:gridlistSetItemColor(GUI.categoryGrid,catRow,1,tocolor(0,255,0))
                    else
                        exports.USGgui:gridlistSetItemColor(source,selectedRow,1,tocolor(255,0,0))
                    end

                    loadCategoryBlips(cat)
                    refreshCategoryBlips(cat)
                end
            end
        end     
    end
end

function initGUI()
    if ( getResourceFromName("USGGUI") and exports.USGrooms:getPlayerRoom() == "cnr" ) then -- gui running
        local width,height = 600,500

        GUI.window = exports.USGgui:createWindow("center","center",width,height,false,"USG ~ Blip manager",false)
        GUI.infoLabel = exports.USGgui:createLabel(0,0,width,50,false,"Toggle blips here.\nDisable an entire category or a specific blip by using the gridlists.",GUI.window)
        GUI.categoryGrid = exports.USGgui:createGridList(5,50,290,400,false,GUI.window)
        GUI.blipsGrid = exports.USGgui:createGridList(305,50,290,400,false,GUI.window)
        exports.USGgui:gridlistAddColumn(GUI.categoryGrid,"Category",1)
        exports.USGgui:gridlistAddColumn(GUI.blipsGrid,"Blip",1)
        exports.USGgui:gridlistSetSelectedItemColor(GUI.blipsGrid,tocolor(0,0,0,0)) -- invisible selection
        
        GUI.toggleButton = exports.USGgui:createButton(100,460,100,30,false,"Toggle all",GUI.window)
        GUI.saveButton = exports.USGgui:createButton(400,460,100,30,false,"Save & close",GUI.window)
        
        addEventHandler("onUSGGUIClick",GUI.categoryGrid,onCategoryGridClick, false)
        addEventHandler("onUSGGUIClick",GUI.blipsGrid,onBlipGridClick, false)
        addEventHandler("onUSGGUIClick",GUI.toggleButton,toggleAll, false)
        addEventHandler("onUSGGUIClick",GUI.saveButton,onSaveClick, false)
        
        refreshGrids()
        return true
    end
    return false
end

function toggleBlipGUI()
    if isElement(GUI.window) then
        if not exports.USGgui:getVisible(GUI.window) then
            exports.USGgui:setVisible(GUI.window,true)
            showCursor(true)
            refreshGrids()
        else
            exports.USGgui:setVisible(GUI.window,false)
            showCursor(false)       
        end
    elseif(exports.USGrooms:getPlayerRoom() == "cnr") then
        local result = initGUI()
        showCursor(result)
    end
end
addCommandHandler("blips",toggleBlipGUI)

addEvent("onPlayerExitRoom", true)
addEventHandler("onPlayerExitRoom", localPlayer,
    function ()
        if isElement(GUI.window) then
            if exports.USGgui:getVisible(GUI.window) then
                showCursor(false)
            end
            destroyElement(GUI.window)
        end             
    end
)

-- blip creating

local createdBlipsInfo = {}

function scanBlips()
    for _,blip in ipairs(getElementsByType("blip")) do
        if not ( createdBlipsInfo[blip] ) then
            local blipType = "default"
            if ( getElementAttachedTo(blip) ) then
                blipType = "attached"
            end
            addBlip(blip,blipType)
        end
    end
    for _,cblip in ipairs(getElementsByType("customblip")) do
        if not ( createdBlipsInfo[cblip] ) then
            addBlip(cblip,"custom")
        end 
    end
end

function addBlip(element,blipType)
    local blipData = getElementData(element,BLIPDATA_KEY)
    local cat, name = unpack(fromJSON(blipData or "[[]]"))
    if not name then name = "Unknown" else name = trim(name) end
    if not cat then cat = "Unknown" else cat = trim(cat) end
    local dimension
    if not getElementData(element,"USGblips_dimension") then
        dimension = elementBlip[element] and elementBlip[element].radius or getElementDimension(element)
    end
    local blipTable = {dimension = dimension, blipType = blipType, category = cat, name = name, 
        element = element, id = getElementData(element,"USGblips_customblipID") }
        
    if blipsCategories[cat] then
        blipsCategories[cat].createdBlipsID = blipsCategories[cat].createdBlipsID + 1
        blipsCategories[cat].createdBlips[blipsCategories[cat].createdBlipsID] = blipTable
    else
        blipsCategories[cat] = { createdBlips = {blipTable}, visible = true, blips = {}, createdBlipsID = 1}
    end
    if name and not blipsCategories[cat].blips[name] then
        blipsCategories[cat].blips[name] = {visible = true}
    end
    createdBlipsInfo[element] = { id = blipsCategories[cat].createdBlipsID, cat = cat, name = name };
    refreshCategoryBlips(blipsCategories[cat])
    addEventHandler("onClientElementDataChange", element,
        function (data) 
            if data == BLIPDATA_KEY then
                updateBlip(source)
            elseif data == "USGblips_dimension" then
                updateBlipDimension(source, getElementData(source, "USGblips_dimension"))
            end
        end
    )
end

function updateBlip(blip)
    local blipData = getElementData(blip,BLIPDATA_KEY)
    local cat, name = unpack(fromJSON(blipData or {}))
    if ( createdBlipsInfo[blip] ) then
        local info = createdBlipsInfo[blip]
        blipsCategories[info.cat].createdBlips[info.id].category = cat
        blipsCategories[info.cat].createdBlips[info.id].name = name
        -- refresh the blips
        refreshCategoryBlips(info.cat)
        refreshCategoryBlips(cat)
    end
end

function updateBlipDimension(blip,dimension)
    if ( createdBlipsInfo[blip] ) then
        local info = createdBlipsInfo[blip]
        blipsCategories[info.cat].createdBlips[info.id].dimension = dimension
        -- refresh the blips
        refreshCategoryBlips(info.cat)
    end
end

function refreshCreatedBlips()
    for catName,cat in ipairs(blipsCategories) do
        refreshCategoryBlips(cat)
    end
end

function refreshCategoryBlips(cat)
    for i, blip in ipairs(cat.createdBlips) do
        if isElement(blip.element) then
            local name = blip.name
            local shouldShow = false
            if name and ( cat.blips[name].visible and cat.visible ) then
                shouldShow = true
            elseif name and ( not cat.blips[name].visible or not cat.visible ) then
                shouldShow = false
            elseif cat.visible then
                shouldShow = true
            else
                shouldShow = false
            end
            if blip.blipType == "default" or blip.blipType == "attached" then
                if getElementDimension(blip.element) ~= 65535 and not shouldShow then
                    setElementDimension(blip.element, 65535)
                elseif ( getElementDimension(blip.element) == 65535 and shouldShow ) then
                    setElementDimension(blip.element, blip.dimension or 0)
                end
            else
                if isCustomBlipVisible(blip.element) and not shouldShow then
                    setCustomBlipVisible(blip.element,false)
                elseif ( not isCustomBlipVisible(blip.element) ) and shouldShow then
                    setCustomBlipVisible(blip.element,true)
                end
            end
        end
    end
end

addEventHandler("onClientResourceStart",resourceRoot,
    function ()
        setTimer(scanBlips,5000,0)
    end
)

function setBlipDimension(blip,dimension)
    setElementData(blip,"USGblips_dimension",dimension,false)
end

function setBlipUserInfo(blip,cat,name)
    local data = {cat,name}
    setElementData(blip,BLIPDATA_KEY,toJSON(data),false)
end

_setBlipVisibleDistance = setBlipVisibleDistance
function setBlipVisibleDistance(blip,distance)
    setElementData(blip,"USGblips_visibleDistance",distance,false)
end
