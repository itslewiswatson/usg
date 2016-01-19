-- parse map file, parse scripts with setfenv, wrapping environment to easily destroy
local preLoadSettings = {}
local fetchID = 0

addEvent("onPlayerExitRoom", true)
function unloadMap()
    if(loadedMap) then
        removeEventHandler("onClientRender", root, renderMap)
        if(loadedMap.started) then
            for i, object in ipairs(loadedMap.objects) do
                if(isElement(object)) then
                    destroyElement(object)
                end
            end
            exports.USGrace_pickups:clearPickups()
            onDestroyEnvironment(loadedMap.environment)
            for key, value in pairs(preLoadSettings) do
                if(key == "time") then
                    setTime(unpack(value))
                end
            end
        end
    end
    preLoadSettings = nil
    loadedMap = nil
end
addEventHandler("onPlayerExitRoom", localPlayer, unloadMap)

addEvent("USGrace_maps.loadMap", true)
function loadMap(mapName, title, author, objects, pickups, settings, scripts, files, room)
    unloadMap()
    
    preLoadSettings = {}
    loadedMap = { name = mapName, title = title or "unknown", author = author or "unknown", started = false, environment = {}, objects = objects, pickups = pickups, 
        room = room, scripts = scripts, settings = settings, pendingFetches = {} }
    addEventHandler("onClientRender", root, renderMap)
    applySafeEnvironment(loadedMap.environment)
    startLoadedMap()
    --initalizeProgressInfo(downloads)
    --verifyFiles(mapName, files)   
end
addEventHandler("USGrace_maps.loadMap", root, loadMap)

function startLoadedMap()
    if(not loadedMap.started) then
        loadMapSettings()
        loadedMap.started = true
        createMapObjects()
        createMapPickups()
        for i, script in ipairs(loadedMap.scripts) do
            -- load script into safe environment
            local func = loadstring(script)
            if(func) then
                setfenv(func, loadedMap.environment)
                pcall(func)
            end
        end
        onEnvironmentLoaded(loadedMap.environment)
        triggerServerEvent("USGrace_maps.onMapLoaded", localPlayer)
    end
end

function verifyFiles(mapName, files)
    if(not loadedMap or loadedMap.name ~= mapName) then return false end
    local downloadCount = 0
    for i, file in ipairs(files) do
        local path = "maps/"..mapName.."/"..file.relPath
        local download = false
        if(not fileExists(path)) then
            download = true
            downloadCount = downloadCount+1
        else
            local tFile = fileOpen(path)
            if(tFile) then
                local tMD5 = getFileMD5(tFile)
                fileClose(tFile)
                if(tMD5 ~= file.hash) then
                    download = true
                    downloadCount = downloadCount+1
                end
            end
        end
        if(download) then
            fetchID = fetchID + 1
            local fetching = fetchRemote(file.url, onFileFetched, "", false, fetchID)
            if(fetching) then
                loadedMap.pendingFetches[fetchID] = file.relPath
            end
        end
    end
    loadedMap.progressInfo.fileCount = downloadCount
    loadedMap.progressInfo.files = 0
    if(downloadCount == 0) then
        startLoadedMap()
    end
    return downloadCount
end

function onFileFetched(response, errno, fetchID)
    if(not loadedMap) then return end
    local relPath = loadedMap.pendingFetches[fetchID]
    if(relPath) then
        loadedMap.pendingFetches[fetchID] = nil
        loadedMap.progressInfo.files = loadedMap.progressInfo.files+1
        if(response and response ~= "ERROR" and errno == 0) then
            local path = "maps/"..loadedMap.name.."/"..relPath
            local file = fileCreate(path)
            fileWrite(file, response)
            fileFlush(file)
            fileClose(file)
        end
        local downloadingFiles = false
        for id, _ in pairs(loadedMap.pendingFetches) do
            downloadingFiles = true
            break
        end
        if(not downloadingFiles) then
            startLoadedMap()
        end
    end
end

function createMapFile(mapName, path, content)
    local root = "maps/"..mapName.."/"
    local file = fileCreate(root..path)
    if(file) then
        fileWrite(file, content)
        fileClose(file)
    end
end

function loadMapSettings()
    for i, setting in ipairs(loadedMap.settings) do
        if(setting.key == "#time") then
            local hr,min = unpack(split(setting.value, ":"))
            if(tonumber(hr) and tonumber(min)) then
                preLoadSettings.time = {getTime()}
                setTime(tonumber(hr),tonumber(min))
            end
        end
    end
end

function createMapObjects()
    local objects = {}
    for i, object in ipairs(loadedMap.objects) do
        local element = createObject(object[1], object[2], object[3], object[4], object[5], object[6], object[7])
        if(element) then
            setElementDimension(element, exports.USGrooms:getRoomDimension(loadedMap.room))
            setElementCollisionsEnabled(element, object[8])
            setElementDoubleSided(element, object[9])
            setObjectBreakable(element, object[10])
            table.insert(objects, element)
        end
    end
    loadedMap.objects = objects
end

function createMapPickups()
    for i, pickup in ipairs(loadedMap.pickups) do
        exports.USGrace_pickups:createPickup(pickup.x, pickup.y, pickup.z, pickup.type, pickup.args)
    end
end

function parseMapFile(path)
    local xml = xmlLoadFile(path)
    if(xml) then
        for i, node in ipairs(xmlNodeGetChildren(xml)) do
            parseMapNode(node)
        end
    end
end

function parseMapNode(node)
    local name = xmlNodeGetName(node)
    if(name == "object") then
        parseObject(node)
    elseif(name == "racepickup") then
        parsePickup(node)
    end
end

function parseObject(node)
    local object = {}
    object.model = tonumber(xmlNodeGetAttribute(node, "model"))
    object.x = tonumber(xmlNodeGetAttribute(node, "posX"))
    object.y = tonumber(xmlNodeGetAttribute(node, "posY"))
    object.z = tonumber(xmlNodeGetAttribute(node, "posZ"))
    object.rx = tonumber(xmlNodeGetAttribute(node, "rotX"))
    object.ry = tonumber(xmlNodeGetAttribute(node, "rotY"))
    object.rz = tonumber(xmlNodeGetAttribute(node, "rotZ"))
    object.collisions =  xmlNodeGetAttribute(node, "collisions") and xmlNodeGetAttribute(node, "collisions") == "true" or true
    object.doublesided = xmlNodeGetAttribute(node, "doublesided") == "true"
    object.breakable = xmlNodeGetAttribute(node, "breakable") and xmlNodeGetAttribute(node, "breakable") == "true" or true
    table.insert(loadedMap.objects, object)
    loadedMap.progressInfo.objects = loadedMap.progressInfo.objects+1
end

function parsePickup(node)
    local pickup = {}
    pickup.type = xmlNodeGetAttribute(node, "type")
    pickup.x = tonumber(xmlNodeGetAttribute(node, "posX"))
    pickup.y = tonumber(xmlNodeGetAttribute(node, "posY"))
    pickup.z = tonumber(xmlNodeGetAttribute(node, "posZ"))
    if(pickup.type == "vehiclechange") then
        pickup.args = {tonumber(xmlNodeGetAttribute(node, "vehicle"))}
    end
    table.insert(loadedMap.pickups, pickup)
    loadedMap.progressInfo.pickups = loadedMap.progressInfo.pickups+1
end

function initalizeProgressInfo(fileCount)
    loadedMap.progressInfo = { stage = "files" }
    loadedMap.progressInfo.files = 0
    loadedMap.progressInfo.objectCount = #loadedMap.objects
    loadedMap.progressInfo.pickupCount = #loadedMap.pickups
    loadedMap.progressInfo.settingCount = #loadedMap.settings
    loadedMap.progressInfo.fileCount = fileCount
    loadedMap.progressInfo.scriptCount = #loadedMap.scripts
end

local screenWidth, screenHeight = guiGetScreenSize()
local totalWidth, totalHeight = 400, 250
local loadingScreenX, loadingScreenY = (screenWidth-totalWidth)/2, (screenHeight-totalHeight)/2
local color_done = tocolor(160,255,160)
local color_in_progress = tocolor(255,230,230)
function renderMap()
    if(loadedMap) then
        dxDrawText(loadedMap.title.." - "..loadedMap.author,0,0,screenWidth,screenHeight-10,tocolor(255,255,255), 1.2,"default","left","bottom")
    end
end