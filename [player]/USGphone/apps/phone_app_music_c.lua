class 'musicApp' 'app'

local settingsReady = function ()
    return getResourceFromName("USGplayersettings") and getResourceState(getResourceFromName("USGplayersettings")) == "running"
end

function musicApp:musicApp()
    app.app(self, "Music","images/apps/music_icon.png")
    self.roomRestriction = "cnr"
    self.GUI = {}
    addEventHandler("onPlayerSettingChange", localPlayer, function (...) MusicApp:onSettingChange(...) end)
end

function musicApp:open()
    if(not isElement(self.GUI.grid)) then
        self.GUI.grid = exports.USGGUI:createGridList(screenWidth, screenHeight, PHONE_SCREEN_WIDTH,PHONE_SCREEN_HEIGHT-PHONE_TITLEBAR_HEIGHT-66, false)
        exports.USGGUI:gridlistAddColumn(self.GUI.grid, "Library", 1.0)
        Phone:addRelativeGUI(self, self.GUI.grid, 0,0)

        self.GUI.name = exports.USGGUI:createEditBox(screenWidth, screenHeight, PHONE_SCREEN_WIDTH*0.6, 25, false, "name", nil, nil, true)
        Phone:addRelativeGUI(self, self.GUI.name, 1,PHONE_SCREEN_HEIGHT-PHONE_TITLEBAR_HEIGHT-57)

        self.GUI.url = guiCreateEdit(screenWidth, screenHeight, PHONE_SCREEN_WIDTH*0.4-2, 25, "", false)
        Phone:addRelativeGUI(self, self.GUI.url, PHONE_SCREEN_WIDTH*0.6+1,PHONE_SCREEN_HEIGHT-PHONE_TITLEBAR_HEIGHT-57)

        self.GUI.add = exports.USGGUI:createButton(screenWidth, screenHeight, 70, 25, false, "Add")
        Phone:addRelativeGUI(self, self.GUI.add, 1,PHONE_SCREEN_HEIGHT-PHONE_TITLEBAR_HEIGHT-26)
        addEventHandler("onUSGGUISClick", self.GUI.add, function () MusicApp:onAddClick() end, false)

        self.GUI.remove = exports.USGGUI:createButton(screenWidth, screenHeight, 50, 25, false, "Remove")
        Phone:addRelativeGUI(self, self.GUI.remove, 72,PHONE_SCREEN_HEIGHT-PHONE_TITLEBAR_HEIGHT-26)
        addEventHandler("onUSGGUISClick", self.GUI.remove, function () MusicApp:onRemoveClick() end, false)

        self.GUI.stop = exports.USGGUI:createButton(screenWidth, screenHeight, 40, 25, false, "Stop")
        Phone:addRelativeGUI(self, self.GUI.stop, PHONE_SCREEN_WIDTH*0.53,PHONE_SCREEN_HEIGHT-PHONE_TITLEBAR_HEIGHT-26)
        addEventHandler("onUSGGUISClick", self.GUI.stop, function () MusicApp:stopPlayback() end, false)

        self.GUI.play = exports.USGGUI:createButton(screenWidth, screenHeight, 70, 25, false, "Play")
        Phone:addRelativeGUI(self, self.GUI.play, PHONE_SCREEN_WIDTH-71,PHONE_SCREEN_HEIGHT-PHONE_TITLEBAR_HEIGHT-26)
        addEventHandler("onUSGGUISClick", self.GUI.play, function () MusicApp:onPlayClick() end, false)
        -- probably first time opening:
        if(settingsReady()) then
            exports.USGplayersettings:addSetting("musiccontroller",true,
                { guiType = "check", category = "General", description = "Show a controller when playing music ( hold m to use )"})
        end
    else
        for k, element in pairs(self.GUI) do
            if(getElementType(element) == "USGGUI") then
                exports.USGGUI:setVisible(element, true)
            else
                guiSetVisible(element, true)
            end
        end
    end
    self.library = exports.USGplayermusic:getLibrary()
    if(self.library) then
        for i, item in ipairs(self.library) do
            local row = exports.USGGUI:gridlistAddRow(self.GUI.grid)
            exports.USGGUI:gridlistSetItemText(self.GUI.grid, row, 1, item.name)
            exports.USGGUI:gridlistSetItemData(self.GUI.grid, row, 1, item)
        end
    end
end

function musicApp:close()
    exports.USGGUI:gridlistClear(self.GUI.grid)
    for k, element in pairs(self.GUI) do
        if(getElementType(element) == "USGGUI") then
            exports.USGGUI:setVisible(element, false)
        else
            guiSetVisible(element, false)
        end
    end
end

function musicApp:onAddClick()
    local name, url = exports.USGGUI:getText(self.GUI.name), guiGetText(self.GUI.url)
    if(url and #url > 4) then
        if(exports.USGplayermusic:addToLibrary(url, #name > 0 and name or false)) then
            exports.USGmsg:msg("Added to library!", 0, 255, 0)
            local item = { url = url, name = #name > 0 and name or url}
            table.insert(self.library, item)
            local row = exports.USGGUI:gridlistAddRow(self.GUI.grid)
            exports.USGGUI:gridlistSetItemText(self.GUI.grid, row, 1, #name > 0 and name or url)
            exports.USGGUI:gridlistSetItemData(self.GUI.grid, row, 1, item)
            exports.USGGUI:setText(self.GUI.name, "")
            guiSetText(self.GUI.url, "")
        end
    end
end

function musicApp:onRemoveClick()
    local selected = exports.USGGUI:gridlistGetSelectedItem(self.GUI.grid)
    if(selected) then
        local item = exports.USGGUI:gridlistGetItemData(self.GUI.grid, selected, 1)
        if(item) then
            if(exports.USGplayermusic:removeFromLibrary(item.url)) then
                exports.USGmsg:msg("Removed from library!", 0, 255, 0)
                exports.USGGUI:gridlistRemoveRow(self.GUI.grid, selected)
                for i, lItem in ipairs(self.library) do
                    if(lItem.url == item.url) then
                        table.remove(self.library, i)
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

function musicApp:onPlayClick()
    local selected = exports.USGGUI:gridlistGetSelectedItem(self.GUI.grid)
    if(selected) then
        local item = exports.USGGUI:gridlistGetItemData(self.GUI.grid, selected, 1)
        if(item) then
            self:playItem(item)
        else
            exports.USGmsg:msg("Could not find related URL!", 255, 0, 0)
        end
    else
        exports.USGmsg:msg("You need to select an item!", 255, 0, 0)
    end
end

function musicApp:onSettingChange(setting, new)
    if(setting == "musiccontroller") then
        if(new) then
            if(self.playback and not self.controllerAdded) then
                addEventHandler("onClientRender", root, utilRenderMusic)
                self.controllerAdded = true
            end
        else
            if(self.playback and self.controllerAdded) then
                self.controllerAdded = false
                removeEventHandler("onClientRender", root, utilRenderMusic)
            end
        end
    end
end

function musicApp:startPlayback()
    if(not self.playback) then
        self.playback = true
        if(settingsReady() and exports.USGplayersettings:getSetting("musiccontroller")) then
            addEventHandler("onClientRender", root, utilRenderMusic)
            self.controllerAdded = true
        end
    end
end

function musicApp:playItem(item)
    if(not self.playback) then
        self:startPlayback()
    end
    if(isElement(self.activeSound)) then
        stopSound(self.activeSound)
        self.activeSound = nil
    end
    if(self.library) then
        for i, lItem in ipairs(self.library) do
            if(lItem.url == item.url) then
                self.playlistPosition = i
            end
        end
    end
    self.currentItem = item
    self.activeSound = playSound(item.url, false)
    addEventHandler("onClientSoundStopped", self.activeSound, function (...) MusicApp:soundFinished(...) end)
    addEventHandler("onClientSoundStream", self.activeSound, function (...) MusicApp:soundStream(...) end)
    addEventHandler("onClientSoundFinishedDownload", self.activeSound, function (...) MusicApp:soundDownloaded(...) end)
    return true
end

function musicApp:stopPlayback()
    if(self.playback) then
        self.playback = false
        if(self.controllerAdded == true) then
            self.controllerAdded = false
            removeEventHandler("onClientRender", root, utilRenderMusic)
        end
        musicMouseState = false
        if(self.controlling) then showCursor("musicControl", false) end
        self.controlling = false        
    end
    if(isElement(self.activeSound)) then
        destroyElement(self.activeSound)
    end
    self.currentItem = nil
end

function musicApp:togglePause()
    if(isElement(self.activeSound)) then
        setSoundPaused(self.activeSound, not isSoundPaused(self.activeSound))
    end
end

function musicApp:previous()
    if(self.playlistPosition and self.library) then
        local item = self.library[self.playlistPosition-1] or self.library[#self.library]
        if(item) then
            self:playItem(item)
        else
            return false
        end
    else
        return false
    end
end

function musicApp:next()
    if(self.playlistPosition and self.library) then
        local item = self.library[self.playlistPosition+1] or self.library[1]
        if(item) then
            return self:playItem(item)
        else
            return false
        end
    else
        return false
    end 
end

function musicApp:soundStream(success, length, name)
    if(not success) then
        exports.USGmsg:msg("Invalid stream/URL ( "..self.currentItem.name..")!", 255, 0, 0)
        self:next()
    else
        if(length == 0) then
            self.currentItem.isStream = true
        end
    end
end

function musicApp:soundFinished(reason)
    if(reason == "finished") then
        if(not self:next()) then
            self:stopPlayback()
        end
    end
end

function musicApp:soundDownloaded()
    if(self.currentItem) then
        local tags = getSoundMetaTags(self.activeSound)
        self.currentItem.length = getSoundLength(self.activeSound)
        self.currentItem.isStream = false
        if((tags.artist or tags.album_artist) and tags.title) then
            self.currentItem.artist = tags.artist or tags.album_artist
            self.currentItem.title = tags.title
        end
    end
end

local musicY = screenHeight-25
local musicMouseState = getKeyState("mouse1")
local color_white = tocolor(255,255,255)
function musicApp:render()
    local mouse = getKeyState("mouse1")
    local mouseDown = mouse and mouse ~= musicMouseState
    musicMouseState = mouse
    local controlling = getKeyState("m")
    if(controlling and not self.controlling) then showCursor("musicControl", true) 
    elseif(self.controlling and not controlling) then showCursor("musicControl", false) end
    self.controlling = controlling
    if(not isElement(self.activeSound)) then return end
    local displayName = self:getItemDisplayName()
    if(not self.controlling) then
        if(self.currentItem) then
            local pos, progress, length = getSoundPosition(self.activeSound), 0, 0
            if(self.currentItem.length and not self.currentItem.isStream) then
                length = self.currentItem.length
                progress = pos/length
            end
            local text
            if(self.currentItem.isStream) then
                text = string.format("%s %02i:%02i", displayName, math.floor(pos/60), pos%60)
            else
                text = string.format("%s%s %02i:%02i/%02i:%02i", self.currentItem.length and "" or "loading ", displayName, 
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
        local paused = isSoundPaused(self.activeSound)
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
                self:previous()
            elseif(pauseHovered) then
                self:togglePause()
            elseif(stopHovered) then
                self:stopPlayback()
            elseif(nextHovered) then
                self:next()
            end
        end
    end
end

function utilRenderMusic()
    MusicApp:render()
end

function musicApp:getItemDisplayName()
    if(self.currentItem and self.currentItem.name) then
        local name = self.currentItem.name
        if(self.currentItem.title and self.currentItem.artist) then
            if(self.currentItem.title == self.currentItem.artist and #self.currentItem.title > 0) then
                name = self.currentItem.title
            elseif(name == self.currentItem.url) then
                name = string.format("%s - %s", self.currentItem.artist, self.currentItem.title)
            end
        end
        return name
    end
    return false
end