function isGUIVisible(element)
    local info = GUIinfo[element] or {}
    local parent = getElementParent(element)
    while GUIinfo[parent] do
        local pInfo = GUIinfo[parent]
        if ( not pInfo.visible ) then
            return false -- depending on parent
        else
            parent = getElementParent(parent)
        end
    end
    return info.visible -- depending on self
end

function destroyGUIElement(theElement)
    if theElement and GUIinfo[theElement] then  
        local children = getElementChildren(theElement)
        for i, element in pairs(children) do
            destroyGUIElement(element)
        end
        if ( GUIinfo[theElement].guiType == "tab" ) then
            local panel = GUIinfo[theElement].tabPanel
            local panelInfo = GUIinfo[panel]
            if ( isElement(panel) and panelInfo ) then
                if ( panelInfo.selectedTab == theElement ) then panelInfo.selectedTab = false end
                removeElementFromTable(theElement,panelInfo.tabs)
            end
        elseif ( GUIinfo[theElement].guiType == "editbox" ) then
            if ( isElement(GUIinfo[theElement].realEdit) ) then
                destroyElement(GUIinfo[theElement].realEdit)
            end
        end

        GUIinfo[theElement] = nil 
        removeElementFromTable(theElement,GUIelements)
    end

end

addEventHandler("onClientResourceStop", root,
function ()
    for element,info in pairs(GUIinfo) do
        if info.resource == source then     
            destroyGUIElement(element)
            destroyElement(element)
        end 
    end
end
)

addEventHandler('onClientResourceStart', resourceRoot,
function ()

    addEventHandler('onClientRender', root, drawElementsOnRender )
    addEventHandler('onClientRender', root, manageMouseOnRender )
    addEventHandler('onClientElementDestroy', root, function () destroyGUIElement(source) end )

    --[[setTimer(
        function ()
            local treeview = createTreeView(300,300,500,500,false,false)
            for i=1,20 do
                local node = treeviewCreateNode()
                local label = createLabel(0,0,50,30,false,"node "..i, node)
                treeviewAddNode(treeview,node)
            end
        end, 500,1)
        
        setTimer(
            function ()
                local grid = createGridList(300,300,500,500,false)
                gridlistAddColumn(grid,"1",1)
                for i=1,150 do
                    local row = gridlistAddRow(grid)
                    gridlistSetItemText(grid,row,1,tostring(i))
                end
            end,500,1)
        
        --
        setTimer(
            function ()
                local scroll = createScrollArea(300,300,500,500,false)
                local grid = createGridList(20,30,460,300,false,scroll)
                    gridlistAddColumn(grid,"1",1)
                local grid2 = createGridList(20,700,460,500,false,scroll)
                    gridlistAddColumn(grid2,"2",1)
                for i=1,500 do
                    local r = gridlistAddRow(grid)
                    gridlistSetItemText(grid,r,1,"der")
                    local r2 = gridlistAddRow(grid2)
                    gridlistSetItemText(grid2,r2,1,"der")
                end
            end,1000,1)
            --
        local text = string.rep("ABCDEFGHIJKLMNOPQRSTXYZ||",8)
        setTimer(
            function ()
                local memo = createMemo(screenWidth-310,screenHeight-600,300,300,false,text)
            end,500,1)
            --]]
end)