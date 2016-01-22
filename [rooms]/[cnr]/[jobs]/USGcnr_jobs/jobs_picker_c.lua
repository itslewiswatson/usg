local selectedJob
local selectJobGUI = {}
local skin = getElementModel(localPlayer)
local pickSkin

addEventHandler("onPlayerExitRoom", localPlayer,
    function (prevRoom)
        if(isElement(selectJobGUI.window)) then
            closeJobGUI()
            destroyElement(selectJobGUI.window)
        end
        if(isElement(jobMenuGUI.window)) then
            closeJobMenu()
            destroyElement(jobMenuGUI.window)
        end
    end
)

function openJobPicker(jobID)
    if(not jobs[jobID]) then return end
    local occupation, skins, description = jobs[jobID].occupation, jobs[jobID].skins, jobs[jobID].description
    pickSkin = (skins and type(skins) == "table" and #skins > 0)
    selectedJob = jobID
    skin = getElementModel(localPlayer)
    showJobGUI(jobID, occupation, skins, description)
end

function createSelectJobGUI()
    if (  not isElement(selectJobGUI.window) ) then
    local screenW, screenH = guiGetScreenSize()
        selectJobGUI.window = guiCreateWindow(screenW - 274 - 10, (screenH - 447) / 2, 274, 447, "USG - Job panel", false)
        guiWindowSetSizable(selectJobGUI.window, false)
        selectJobGUI.info = guiCreateLabel(1, 17, 273, 132, "", false, selectJobGUI.window)
        guiLabelSetHorizontalAlign(selectJobGUI.info, "center", false)
        guiLabelSetVerticalAlign(selectJobGUI.info, "center")
        selectJobGUI.skins = guiCreateGridList(9, 150, 255, 222, false, selectJobGUI.window)
        guiGridListAddColumn(selectJobGUI.skins, "ID", 0.3)
        guiGridListAddColumn(selectJobGUI.skins, "Name", 0.7)
        selectJobGUI.cancel = guiCreateButton(21, 397, 100, 40, "Close", false, selectJobGUI.window)
        guiSetProperty(selectJobGUI.cancel, "NormalTextColour", "FFAAAAAA")
        selectJobGUI.OK = guiCreateButton(154, 397, 100, 40, "Select", false, selectJobGUI.window)
        guiSetProperty(selectJobGUI.OK, "NormalTextColour", "FFAAAAAA")    
        addEventHandler("onClientGUIClick",selectJobGUI.cancel, 
            function ( btn, state ) 
            --  if ( btn == 1 and state == "down" ) then 
                    setElementModel(localPlayer,skin) 
                    closeJobGUI() 
                    --   end 
            end, false)

            addEventHandler("onClientGUIClick",selectJobGUI.OK, onSelectJob, false)
            addEventHandler("onClientGUIClick",selectJobGUI.skins, onClickSkins, false)
    end
end

function onClickSkins(btn,state)
   -- if ( btn == 1 and state == "down" ) then
        local selRow = guiGridListGetSelectedItem(selectJobGUI.skins)
        if ( selRow ) then
            local id = tonumber(guiGridListGetItemText(selectJobGUI.skins,selRow,1))
            if ( id ) then
                setElementModel(localPlayer,id)
            end
        elseif ( skin ) then
            setElementModel(localPlayer,skin)
        end
        -- end
end

function onSelectJob(btn,state)
    --if ( btn == 1 and state == "down" ) then
        if ( pickSkin ) then
            local selRow = guiGridListGetSelectedItem(selectJobGUI.skins)
            if ( selRow ) then
                local skinID = tonumber(guiGridListGetItemText(selectJobGUI.skins,selRow,1))
                setPlayerJob(selectedJob, skinID)
                closeJobGUI()
            else
                exports.USGmsg:msg("You must select a skin!",255,0,0)
            end
        else
            setPlayerJob(selectedJob,false)
            closeJobGUI()
        end
        --end
end

function closeJobGUI()
    if ( isElement(selectJobGUI.window) ) then
        guiSetVisible(selectJobGUI.window,false)
        showCursor("picker", false)
        selectedJob = false
        if ( skin ) then
            setElementModel(localPlayer,skin)
        end 
    end
end

function showJobGUI(jobID, occupation, skins, description)
    if not ( isElement(selectJobGUI.window) ) then createSelectJobGUI() else guiSetVisible(selectJobGUI.window,true) end
        guiSetText(selectJobGUI.window, occupation)
        guiSetText(selectJobGUI.info,description or "No description")
        guiGridListClear(selectJobGUI.skins)
    if ( pickSkin ) then
        for i=1,#skins do
            local skinID = skins[i].id
            local skinName = skins[i].name or "#"..i
            local row = guiGridListAddRow(selectJobGUI.skins)
            guiGridListSetItemText(selectJobGUI.skins,row,1,tostring(skinID),false,false)
            guiGridListSetItemText(selectJobGUI.skins,row,2,tostring(skinName),false,false)
        end
    else
    local row = guiGridListAddRow(selectJobGUI.skins)
        guiGridListSetItemText(selectJobGUI.skins,row,1,"",false,false)
        guiGridListSetItemText(selectJobGUI.skins,row,2,"Regular skin",false,false)     
    end
    showCursor("picker", true)
end

function setPlayerJob(jobID,skinID)
    triggerServerEvent("USGcnr_jobs.jobPicked",localPlayer,jobID,skinID)
end