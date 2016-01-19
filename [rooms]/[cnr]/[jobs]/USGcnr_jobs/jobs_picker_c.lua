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
    if ( getResourceFromName("USGGUI") and not isElement(selectJobGUI.window) ) then
        selectJobGUI.window = exports.USGGUI:createWindow('right','bottom',250,400,false)
        selectJobGUI.info = exports.USGGUI:createLabel('center','top', 250,100,false, "No description",selectJobGUI.window)
        selectJobGUI.skins = exports.USGGUI:createGridList('center',100,240,250,false,selectJobGUI.window)
            exports.USGGUI:gridlistAddColumn(selectJobGUI.skins,"ID",0.3)
            exports.USGGUI:gridlistAddColumn(selectJobGUI.skins,"Name",0.7)
        selectJobGUI.cancel = exports.USGGUI:createButton(50, 360, 75, 20,false,"Cancel",selectJobGUI.window)
            addEventHandler("onUSGGUIClick",selectJobGUI.cancel, 
            function ( btn, state ) 
                if ( btn == 1 and state == "down" ) then 
                    setElementModel(localPlayer,skin) 
                    closeJobGUI() 
                end 
            end, false)
        selectJobGUI.OK = exports.USGGUI:createButton(175, 360, 75, 20,false,"Select",selectJobGUI.window)
            addEventHandler("onUSGGUIClick",selectJobGUI.OK, onSelectJob, false)
            addEventHandler("onUSGGUIClick",selectJobGUI.skins, onClickSkins, false)
    end
end

function onClickSkins(btn,state)
    if ( btn == 1 and state == "down" ) then
        local selRow = exports.USGGUI:gridlistGetSelectedItem(selectJobGUI.skins)
        if ( selRow ) then
            local id = tonumber(exports.USGGUI:gridlistGetItemText(selectJobGUI.skins,selRow,1))
            if ( id ) then
                setElementModel(localPlayer,id)
            end
        elseif ( skin ) then
            setElementModel(localPlayer,skin)
        end
    end
end

function onSelectJob(btn,state)
    if ( btn == 1 and state == "down" ) then
        if ( pickSkin ) then
            local selRow = exports.USGGUI:gridlistGetSelectedItem(selectJobGUI.skins)
            if ( selRow ) then
                local skinID = tonumber(exports.USGGUI:gridlistGetItemText(selectJobGUI.skins,selRow,1))
                setPlayerJob(selectedJob, skinID)
                closeJobGUI()
            else
                exports.USGmsg:msg("You must select a skin!",255,0,0)
            end
        else
            setPlayerJob(selectedJob,false)
            closeJobGUI()
        end
    end
end

function closeJobGUI()
    if ( isElement(selectJobGUI.window) ) then
        exports.USGGUI:setVisible(selectJobGUI.window,false)
        showCursor("picker", false)
        selectedJob = false
        if ( skin ) then
            setElementModel(localPlayer,skin)
        end 
    end
end

function showJobGUI(jobID, occupation, skins, description)
    if not ( isElement(selectJobGUI.window) ) then createSelectJobGUI() else exports.USGGUI:setVisible(selectJobGUI.window,true) end
    exports.USGGUI:setText(selectJobGUI.window, occupation)
    exports.USGGUI:setText(selectJobGUI.info,description or "No description")
    exports.USGGUI:gridlistClear(selectJobGUI.skins)
    if ( pickSkin ) then
        for i=1,#skins do
            local skinID = skins[i].id
            local skinName = skins[i].name or "#"..i
            local row = exports.USGGUI:gridlistAddRow(selectJobGUI.skins)
            exports.USGGUI:gridlistSetItemText(selectJobGUI.skins,row,1,tostring(skinID))
            exports.USGGUI:gridlistSetItemText(selectJobGUI.skins,row,2,tostring(skinName))
        end
    else
        local row = exports.USGGUI:gridlistAddRow(selectJobGUI.skins)
        exports.USGGUI:gridlistSetItemText(selectJobGUI.skins,row,1,"")
        exports.USGGUI:gridlistSetItemText(selectJobGUI.skins,row,2,"Regular skin")     
    end
    showCursor("picker", true)
end

function setPlayerJob(jobID,skinID)
    triggerServerEvent("USGcnr_jobs.jobPicked",localPlayer,jobID,skinID)
end