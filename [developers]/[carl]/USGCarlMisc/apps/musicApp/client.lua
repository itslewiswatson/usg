musicGUI = {}

addEventHandler("onClientResourceStart", resourceRoot,
    function()
        musicGUI.window = guiCreateWindow(0.75, 0.22, 0.22, 0.58, apps.music.name, true)
        guiWindowSetSizable(musicGUI.window, false)

        musicGUI.gridlistLibrary = guiCreateGridList(0.03, 0.05, 0.94, 0.61, true, musicGUI.window)
        guiGridListAddColumn(musicGUI.gridlistLibrary, "Library", 0.9)
        musicGUI.labelName = guiCreateLabel(0.03, 0.67, 0.37, 0.08, "Name:", true, musicGUI.window)
        guiLabelSetHorizontalAlign(musicGUI.labelName, "center", false)
        guiLabelSetVerticalAlign(musicGUI.labelName, "center")
        musicGUI.editName = guiCreateEdit(0.04, 0.73, 0.36, 0.07, "", true, musicGUI.window)
        musicGUI.labelURL = guiCreateLabel(0.41, 0.68, 0.56, 0.04, "URL:", true, musicGUI.window)
        guiLabelSetHorizontalAlign(musicGUI.labelURL, "center", false)
        guiLabelSetVerticalAlign(musicGUI.labelURL, "center")
        musicGUI.editURL = guiCreateEdit(0.41, 0.73, 0.56, 0.07, "", true, musicGUI.window)
        musicGUI.buttonStart = guiCreateButton(0.04, 0.81, 0.36, 0.07, "Start", true, musicGUI.window)
        guiSetProperty(musicGUI.buttonStart, "NormalTextColour", "FFAAAAAA")
        musicGUI.buttonStop = guiCreateButton(0.04, 0.90, 0.36, 0.07, "Stop", true, musicGUI.window)
        guiSetProperty(musicGUI.buttonStop, "NormalTextColour", "FFAAAAAA")
        musicGUI.buttonAdd = guiCreateButton(0.61, 0.81, 0.36, 0.07, "Add", true, musicGUI.window)
        guiSetProperty(musicGUI.buttonAdd, "NormalTextColour", "FFAAAAAA")
        musicGUI.buttonRemove = guiCreateButton(0.61, 0.90, 0.36, 0.07, "Remove", true, musicGUI.window)
        guiSetProperty(musicGUI.buttonRemove, "NormalTextColour", "FFAAAAAA")  

		library = exports.USGplayermusic:getLibrary()
			if(library) then
				for i, item in ipairs(library) do
					local row = guiGridListAddRow ( musicGUI.gridlistLibrary )
					guiGridListSetItemText(musicGUI.gridlistLibrary, row, 1, item.name, false, false)
					guiGridListSetItemData(musicGUI.gridlistLibrary, row, 1, item)
				end
			end
			
		addEventHandler("onClientGUIClick",musicGUI.buttonStart, onPlayClick, false)
		addEventHandler("onClientGUIClick",  musicGUI.buttonStop, stopPlayback , false)
		addEventHandler("onClientGUIClick", musicGUI.buttonAdd, onAddClick , false)
		addEventHandler("onClientGUIClick", musicGUI.buttonRemove, onRemoveClick , false)
		
		guiSetVisible(musicGUI.window,false)
    end
)

local function showMusicGUI()
if(not exports.USGaccounts:isPlayerLoggedIn()) then return end
	if(guiGetVisible(musicGUI.window) == false)then
		guiSetInputMode("no_binds_when_editing")
		guiSetVisible ( musicGUI.window, true )
		gpsfillPlayerGrid()
		gpsfillLocationGrid()
	end
end

addEvent(apps.music.event,true)
addEventHandler(apps.music.event,root,showMusicGUI)

local function hideMusicGUI()
	if(guiGetVisible(musicGUI.window) == true)then
		guiSetVisible ( musicGUI.window, false )
		showCursor(false)
	end
end

bindKey( binds.closeAllApps.key, binds.closeAllApps.keyState,hideMusicGUI)

function onAddClick()
    local name, url = guiGetText(musicGUI.editName), guiGetText(musicGUI.editURL)
    if(url and #url > 4) then
        if(exports.USGplayermusic:addToLibrary(url, #name > 0 and name or false)) then
            exports.USGmsg:msg("Added to library!", 0, 255, 0)
            local item = { url = url, name = #name > 0 and name or url}
            table.insert(library, item)
            local row = guiGridListAddRow(musicGUI.gridlistLibrary)
            guiGridListSetItemText(musicGUI.gridlistLibrary, row, 1, #name > 0 and name or url, false, false)
            guiGridListSetItemData(musicGUI.gridlistLibrary, row, 1, item)
            guiSetText(musicGUI.editName, "")
            guiSetText(musicGUI.editURL, "")
        end
    end
end

function onRemoveClick()
    local selected = guiGridListGetSelectedItem(musicGUI.gridlistLibrary)
    if(selected) then
        local item = guiGridListGetItemData(musicGUI.gridlistLibrary, selected, 1)
        if(item) then
            if(exports.USGplayermusic:removeFromLibrary(item.url)) then
                exports.USGmsg:msg("Removed from library!", 0, 255, 0)
                guiGridListRemoveRow ( musicGUI.gridlistLibrary, selected )
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
    local selected = guiGridListGetSelectedItem(musicGUI.gridlistLibrary)
    if(selected) then
        local item = guiGridListGetItemData(musicGUI.gridlistLibrary, selected, 1)
        if(item) then
            playItem(item)
        else
            exports.USGmsg:msg("Could not find related URL!", 255, 0, 0)
        end
    else
        exports.USGmsg:msg("You need to select an item!", 255, 0, 0)
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
   