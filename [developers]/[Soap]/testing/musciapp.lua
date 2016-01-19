local musicGUI = {}

local settingsReady = function ()
    return getResourceFromName("USGplayersettings") and getResourceState(getResourceFromName("USGplayersettings")) == "running"
end

local screenWidth, screenHeight = guiGetScreenSize()

function createMusicGUI()
    exports.USGGUI:setDefaultTextAlignment("center","center")
    musicGUI.window = exports.USGGUI:createWindow("center","center", 300, 430, false,"Music System")
    musicGUI.grid = exports.USGGUI:createGridList("center","top",298,365,false,musicGUI.window)
        exports.USGGUI:gridlistAddColumn(musicGUI.grid, "Library", 1.0)
    musicGUI.play = exports.USGGUI:createButton("left","bottom",70,25,false," Start  ",musicGUI.window)
    musicGUI.stop = exports.USGGUI:createButton(72,"bottom",70,25,false," Stop ",musicGUI.window)
    musicGUI.add = exports.USGGUI:createButton(158,"bottom",70,25,false," Add ",musicGUI.window)
    musicGUI.remove = exports.USGGUI:createButton("right","bottom",70,25,false," Remove ",musicGUI.window)
    
    addEventHandler("onUSGGUISClick",  musicGUI.play, onPlayClick , false)
    addEventHandler("onUSGGUISClick",  musicGUI.stop, stopPlayback , false)
    addEventHandler("onUSGGUISClick",  musicGUI.add, onAddClick , false)
    addEventHandler("onUSGGUISClick",  musicGUI.remove, onRemoveClick , false)
   
    musicGUI.name = exports.USGGUI:createEditBox("left", 368,120, 30, false, "name", musicGUI.window)
    musicGUI.url = exports.USGGUI:createEditBox("right", 368,165, 30, false, "url", musicGUI.window)
       
    library = exports.USGplayermusic:getLibrary()
    if(library) then
        for i, item in ipairs(library) do
            local row = exports.USGGUI:gridlistAddRow(musicGUI.grid)
            exports.USGGUI:gridlistSetItemText(musicGUI.grid, row, 1, item.name)
            exports.USGGUI:gridlistSetItemData(musicGUI.grid, row, 1, item)
        end
    end
end



function togglemusicGUI()
if(not exports.USGaccounts:isPlayerLoggedIn()) then return end
    if(isElement(musicGUI.window )) then
        if(exports.USGGUI:getVisible(musicGUI.window )) then
         exports.USGGUI:setVisible(musicGUI.window , false)
            showCursor(false)
            exports.USGblur:setBlurDisabled()
            else
            showCursor(true)
            exports.USGGUI:setVisible(musicGUI.window , true)
            exports.USGblur:setBlurEnabled()
        end
    else
        createMusicGUI()
        exports.USGblur:setBlurEnabled()
        showCursor(true)
    end 
end 
addCommandHandler("okok",togglemusicGUI)

function onAddClick()
    local name, url = exports.USGGUI:getText(musicGUI.name), exports.USGGUI:getText(musicGUI.url)
    if(url and #url > 4) then
        if(exports.USGplayermusic:addToLibrary(url, #name > 0 and name or false)) then
            exports.USGmsg:msg("Added to library!", 0, 255, 0)
            local item = { url = url, name = #name > 0 and name or url}
            table.insert(library, item)
            local row = exports.USGGUI:gridlistAddRow(musicGUI.grid)
            exports.USGGUI:gridlistSetItemText(musicGUI.grid, row, 1, #name > 0 and name or url)
            exports.USGGUI:gridlistSetItemData(musicGUI.grid, row, 1, item)
            exports.USGGUI:setText(musicGUI.name, "")
            exports.USGGUI:setText(musicGUI.url, "")
        end
    end
end

function onRemoveClick()
    local selected = exports.USGGUI:gridlistGetSelectedItem(musicGUI.grid)
    if(selected) then
        local item = exports.USGGUI:gridlistGetItemData(musicGUI.grid, selected, 1)
        if(item) then
            if(exports.USGplayermusic:removeFromLibrary(item.url)) then
                exports.USGmsg:msg("Removed from library!", 0, 255, 0)
                exports.USGGUI:gridlistRemoveRow(musicGUI.grid, selected)
                for i, lItem in ipairs(library) do
                    if(lItem.url == item.url) then
                        table.remove(library, i)
                    end
                end
            else
                exports.USGmsg:msg("Could not remove from library.", 255, 0, 0)
            end
        else
            exports.USGmsg:msg("Could not find related URL!", 255, 0, 0)
        end
    else
        exports.USGmsg:msg("You need to select an item to remove!", 255, 0, 0)
    end
end

function onPlayClick()
    local selected = exports.USGGUI:gridlistGetSelectedItem(musicGUI.grid)
    if(selected) then
        local item = exports.USGGUI:gridlistGetItemData(musicGUI.grid, selected, 1)
        if(item) then
            playItem(item)
        else
            exports.USGmsg:msg("Could not find related URL!", 255, 0, 0)
        end
    else
        exports.USGmsg:msg("You need to select an item!", 255, 0, 0)
    end
end

function onSettingChange(setting, new)
    if(setting == "musiccontroller") then
        if(new) then
            if(playback and not controllerAdded) then
                addEventHandler("onClientRender", root, utilRenderMusic)
                controllerAdded = true
            end
        else
            if(playback and controllerAdded) then
                controllerAdded = false
                removeEventHandler("onClientRender", root, utilRenderMusic)
            end
        end
    end
end

function startPlayback()
    if(not playback) then
        playback = true
        if(settingsReady() and exports.USGplayersettings:getSetting("musiccontroller")) then
            addEventHandler("onClientRender", root, utilRenderMusic)
            controllerAdded = true
        end
    end
end

function playItem(item)
    if(not playback) then
        startPlayback()
    end
    if(isElement(activeSound)) then
        stopSound(activeSound)
        activeSound = nil
    end
    if(library) then
        for i, lItem in ipairs(library) do
            if(lItem.url == item.url) then
                playlistPosition = i
            end
        end
    end
    currentItem = item
    activeSound = playSound(item.url, false)
    addEventHandler("onClientSoundStopped", activeSound, soundFinished)
    addEventHandler("onClientSoundStream", activeSound, soundStream)
    addEventHandler("onClientSoundFinishedDownload", activeSound, soundDownloaded)
    return true
end

function stopPlayback()
    if(playback) then
        playback = false
        if(controllerAdded == true) then
            controllerAdded = false
            removeEventHandler("onClientRender", root, utilRenderMusic)
        end
        musicMouseState = false
        if(controlling) then showCursor("musicControl", false) end
        controlling = false        
    end
    if(isElement(activeSound)) then
        destroyElement(activeSound)
    end
    currentItem = nil
end

function togglePause()
    if(isElement(activeSound)) then
        setSoundPaused(activeSound, not isSoundPaused(activeSound))
    end
end

function previous()
    if(playlistPosition and library) then
        local item = library[playlistPosition-1] or library[#library]
        if(item) then
            playItem(item)
        else
            return false
        end
    else
        return false
    end
end

function next()
    if(playlistPosition and library) then
        local item = library[playlistPosition+1] or library[1]
        if(item) then
            return playItem(item)
        else
            return false
        end
    else
        return false
    end 
end

function soundStream(success, length, name)
    if(not success) then
        exports.USGmsg:msg("Invalid stream/URL ( "..currentItem.name..")!", 255, 0, 0)
        next()
    else
        if(length == 0) then
            currentItem.isStream = true
        end
    end
end

function soundFinished(reason)
    if(reason == "finished") then
        if(not next()) then
            stopPlayback()
        end
    end
end

function soundDownloaded()
    if(currentItem) then
        local tags = getSoundMetaTags(activeSound)
        currentItem.length = getSoundLength(activeSound)
        currentItem.isStream = false
        if((tags.artist or tags.album_artist) and tags.title) then
            currentItem.artist = tags.artist or tags.album_artist
            currentItem.title = tags.title
        end
    end
end

local musicY = screenHeight-25
local musicMouseState = getKeyState("mouse1")
local color_white = tocolor(255,255,255)
function mrender()
    local mouse = getKeyState("mouse1")
    local mouseDown = mouse and mouse ~= musicMouseState
    musicMouseState = mouse
    local controlling = getKeyState("m")
    if(controlling and not controlling) then showCursor("musicControl", true) 
    elseif(controlling and not controlling) then showCursor("musicControl", false) end
    controlling = controlling
    if(not isElement(activeSound)) then return end
    local displayName = getItemDisplayName()
    if(not controlling) then
        if(currentItem) then
            local pos, progress, length = getSoundPosition(activeSound), 0, 0
            if(currentItem.length and not currentItem.isStream) then
                length = currentItem.length
                progress = pos/length
            end
            local text
            if(currentItem.isStream) then
                text = string.format("%s %02i:%02i", displayName, math.floor(pos/60), pos%60)
            else
                text = string.format("%s%s %02i:%02i/%02i:%02i", currentItem.length and "" or "loading ", displayName, 
                math.floor(pos/60), pos%60, math.floor(length/60), length%60)
            end
            local width = dxGetTextWidth(text)
            local x = math.max(0, (screenWidth-width)/2)
            dxDrawRectangle(x-5, musicY, width+10,25, tocolor(0,0,0,200))
            dxDrawRectangle(x-5, musicY, progress*(width+10),25, tocolor(255,255,255,20))
            dxDrawText(text, x, musicY, x+width, screenHeight, color_white, 1,"default","left", "center")
        else
            local x = math.max(0, (screenWidth-100)/2)
            dxDrawRectangle(x-5, musicY, 100+10, 25, tocolor(0,0,0,200))
            dxDrawText("loading...", x, musicY, x+100, screenHeight, color_white, 1, "default", "center", "center")
        end
    else
        -- render buttons
        local totWidth = displayName and dxGetTextWidth(displayName)+20 or 60*4 
        local paused = isSoundPaused(activeSound)
        local buttonWidth = math.max(60, math.floor((totWidth+10)/4))
        local x =  math.max(0, (screenWidth-(buttonWidth*4))/2)
        local cx, cy = getCursorPosition()
        cx, cy = cx * screenWidth, cy * screenHeight
        local backX = x-5
        local backHovered = cx > backX and cx < backX+buttonWidth and cy > musicY
        dxDrawRectangle(backX, musicY, buttonWidth, 25, tocolor(0,0,0,backHovered and 170 or 200))
        dxDrawText("previous", backX, musicY, backX+buttonWidth, screenHeight, color_white, 1, backHovered and "default-bold" or "default", "center", "center")
        local pauseX = backX+buttonWidth
        local pauseHovered = cx > pauseX and cx < pauseX+buttonWidth and cy > musicY
        dxDrawRectangle(pauseX, musicY, buttonWidth, 25, tocolor(0,0,0,pauseHovered and 170 or 200))
        dxDrawText(paused and "play" or "pause", pauseX, musicY, pauseX+buttonWidth, screenHeight, color_white, 1, pauseHovered and "default-bold" or "default", "center", "center")
        local stopX = pauseX+buttonWidth
        local stopHovered = cx >stopX and cx < stopX+buttonWidth and cy > musicY
        dxDrawRectangle(stopX, musicY, buttonWidth, 25, tocolor(0,0,0,stopHovered and 170 or 200))          
        dxDrawText("stop", stopX, musicY, stopX+buttonWidth, screenHeight, color_white, 1, stopHovered and "default-bold" or "default", "center", "center")
        local nextX = stopX+buttonWidth
        local nextHovered = cx > nextX and cx < nextX+buttonWidth and cy > musicY
        dxDrawRectangle(nextX, musicY, buttonWidth, 25, tocolor(0,0,0,nextHovered and 170 or 200))
        dxDrawText("next", nextX, musicY, nextX+buttonWidth, screenHeight, color_white, 1, nextHovered and "default-bold" or "default", "center", "center")
        if(mouseDown) then
            if(backHovered) then
                previous()
            elseif(pauseHovered) then
                togglePause()
            elseif(stopHovered) then
                stopPlayback()
            elseif(nextHovered) then
                next()
            end
        end
    end
end

function utilRenderMusic()
   mrender()
end

function getItemDisplayName()
    if(currentItem and currentItem.name) then
        local name = currentItem.name
        if(currentItem.title and currentItem.artist) then
            if(currentItem.title == currentItem.artist and #currentItem.title > 0) then
                name = currentItem.title
            elseif(name == currentItem.url) then
                name = string.format("%s - %s", currentItem.artist, currentItem.title)
            end
        end
        return name
    end
    return false
end       
   