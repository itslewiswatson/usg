loadstring(exports.mysql:getQueryTool())()

fileDownloadPath = "maps/files/"
fileDownloadURL = "http://USGmta.co/downloads/"

addEvent("USGrace_maps.onMapLoaded", true)
local roomMaps
local nameMap
local loadID = 0
local LOAD_MAX = 5

function loadMaps()
    roomMaps = {}
    nameMap = {}    
    query(loadMapsCallback, {}, "SELECT * FROM race_maps LIMIT ?",LOAD_MAX)
end
addEventHandler("onResourceStart", resourceRoot, loadMaps)

function loadMapsCallback(result)
    for i, map in ipairs(result) do
        addMap(map.name, map.room)
    end
    if(#result ~= 0) then
        setTimer(loadNextMaps,750,1)
    end
end

function loadNextMaps()
    loadID = loadID+LOAD_MAX
    query(loadMapsCallback, {}, "SELECT * FROM race_maps LIMIT ?, ?", loadID, LOAD_MAX)
end

function loadMap(name, room)
    if(fileExists(":"..name.."/meta.xml")) then
        local map = { name = name, settings = {}, spawns = {}, objects = {}, scripts = {}, files = {}, pickups = {} }
        if(room == "tct") then
            map.spawns = { team1 = {}, team2 = {}}
        end
        local meta = xmlLoadFile(":"..name.."/meta.xml")
        local children = xmlNodeGetChildren(meta)
        local success = true
        for i, child in ipairs(children) do
            if(not parseMetaNode(map, room, child)) then
                success = false
                break
            end
        end
        xmlUnloadFile(meta)
        if(success) then
            return map
        else
            return false
        end
    else
        return false
    end
end

function addMap(name, room)
    local lMap = loadMap(name, room)
    if(lMap) then
        lMap.name = name
        lMap.room = room
        if(not roomMaps[room]) then
            roomMaps[room] = {}
        end
        table.insert(roomMaps[room], lMap)
        nameMap[name] = lMap
        return true
    end
    return false
end

function unloadMap(name) -- unload it from random selection, but let it exist for rooms that had already selected it
    if(nameMap[name]) then
        local room = nameMap[name].room
        for i, map in ipairs(roomMaps[room]) do
            if(map.name == name) then
                table.remove(roomMaps[room], i)
                break
            end
        end
    end 
end

function reloadMap(name)
    if(nameMap[name]) then
        nameMap[name] = loadMap(name)
        for i, map in ipairs(roomMaps[nameMap[name].room]) do
            if(map.name == name) then
                roomMaps[nameMap[name].room][i] = nameMap[name]
                break
            end
        end
    end
end

function reloadMaps()
    loadMaps()
end

function getMetaNodeFileContent(rootPath, node)
    local srcPath = xmlNodeGetAttribute(node, "src")
    if(srcPath) then
        local path = rootPath.."/"..srcPath
        if(fileExists(path)) then
            local file = fileOpen(path)
            if(file) then
                local content = fileRead(file, fileGetSize(file))
                fileClose(file)
                return content
            else
                return false
            end
        end
    end
    return false
end

function parseMetaNode(map, room, node)
    local name = xmlNodeGetName(node)
    if(name == "map") then
        local xml = xmlLoadFile(":"..map.name.."/"..xmlNodeGetAttribute(node,"src"))
        if(xml) then
            local children = xmlNodeGetChildren(xml)
            for i, child in ipairs(children) do
                parseMapNode(map, room, child)
            end
            xmlUnloadFile(xml)
        else
            return false
        end
    elseif(name == "file") then
        local cachedPath, fileHash = parseFile(map, node)
        if(cachedPath and fileHash) then
            table.insert(map.files, {relPath = xmlNodeGetAttribute(node,"src"), url = fileDownloadURL..cachedPath, hash = fileHash})
        end
    elseif(name == "script") then
        if(xmlNodeGetAttribute(node, "type") == "client") then
            local content = getMetaNodeFileContent(":"..map.name, node)
            if(content) then
                table.insert(map.scripts, content)
            end
        end
    elseif(name == "settings") then
        local children = xmlNodeGetChildren(node)
        for i, child in ipairs(children) do
            local setting = xmlNodeGetAttribute(child, "name")
            local value = xmlNodeGetAttribute(child, "value")
            table.insert(map.settings, {key=setting,value=value})
        end
    elseif(name == "info") then
        map.author = xmlNodeGetAttribute(node, "author") or "Unknown"
        map.title = xmlNodeGetAttribute(node, "name") or "Unnamed"      
    end
    return true
end

function parseFile(map, node)
    local relPath = xmlNodeGetAttribute(node, "src")
    if(relPath) then
        local sPath = ":"..map.name.."/"..relPath
        local tPath = fileDownloadPath..map.name.."/"..relPath
        if(fileExists(sPath)) then
            local sFile = fileOpen(sPath)
            if(sFile) then
                local sContent = readFile(sFile)
                local sHash = getFileMD5(sContent)
                if(fileExists(tPath)) then
                    local tFile = fileOpen(tPath)
                    if(tFile) then
                        local tHash = getFileMD5(tFile)
                        if(tHash == sHash) then
                            fileClose(sFile)
                            fileClose(tFile)
                            return tPath, sHash
                        end
                    end
                end
                fileClose(sFile)
                local tFile = fileCreate(tPath)
                fileWrite(tFile, sContent)
                fileClose(tFile)
                return tPath, sHash
            else
                return false
            end
        else
            return false
        end
    end
end

function parseMapNode(map, room, node)
    local name = xmlNodeGetName(node)
    if(room == "tct") then
        if(name == "Team1" or name == "Team2") then
            local spawn = parseTeamSpawn(map, node)
            table.insert(name == "Team1" and map.spawns.team1 or map.spawns.team2, spawn)
        end
    end
    if(name == "spawnpoint") then 
        local spawn = parseSpawn(map, node)
        table.insert(map.spawns, spawn)
    elseif(name == "object") then
        parseObject(map, node)
    elseif(name == "racepickup") then
        parsePickup(map, node)  
    end
end

function parseObject(map, node)
    local object = {
        tonumber(xmlNodeGetAttribute(node, "model")),
        tonumber(xmlNodeGetAttribute(node, "posX")),
        tonumber(xmlNodeGetAttribute(node, "posY")),
        tonumber(xmlNodeGetAttribute(node, "posZ")),
        tonumber(xmlNodeGetAttribute(node, "rotX")),
        tonumber(xmlNodeGetAttribute(node, "rotY")),
        tonumber(xmlNodeGetAttribute(node, "rotZ")),
        xmlNodeGetAttribute(node, "collisions") ~= "false",
        xmlNodeGetAttribute(node, "doublesided") == "true",
        xmlNodeGetAttribute(node, "breakable") ~= "false",
    }
    table.insert(map.objects, object)
end

function parsePickup(map, node)
    local pickup = {}
    pickup.type = xmlNodeGetAttribute(node, "type")
    pickup.x = tonumber(xmlNodeGetAttribute(node, "posX"))
    pickup.y = tonumber(xmlNodeGetAttribute(node, "posY"))
    pickup.z = tonumber(xmlNodeGetAttribute(node, "posZ"))
    if(pickup.type == "vehiclechange") then
        pickup.args = {tonumber(xmlNodeGetAttribute(node, "vehicle"))}
    end
    table.insert(map.pickups, pickup)
end

function parseSpawn(map, node)
    local spawn = {}
    spawn.model = tonumber(xmlNodeGetAttribute(node, "vehicle"))    
    spawn.x = tonumber(xmlNodeGetAttribute(node, "posX"))
    spawn.y = tonumber(xmlNodeGetAttribute(node, "posY"))
    spawn.z = tonumber(xmlNodeGetAttribute(node, "posZ"))
    spawn.rx = tonumber(xmlNodeGetAttribute(node, "rotX"))
    spawn.ry = tonumber(xmlNodeGetAttribute(node, "rotY"))
    spawn.rz = tonumber(xmlNodeGetAttribute(node, "rotZ"))
    return spawn
end

function parseTeamSpawn(map, node)
    local spawn = {}
    spawn.x = tonumber(xmlNodeGetAttribute(node, "posX"))
    spawn.y = tonumber(xmlNodeGetAttribute(node, "posY"))
    spawn.z = tonumber(xmlNodeGetAttribute(node, "posZ"))
    spawn.rz = tonumber(xmlNodeGetAttribute(node, "rotZ"))
    spawn.int = tonumber(xmlNodeGetAttribute(node, "interior"))
    return spawn
end
--
local roomNextMap = {}

function getRandomMap(room)
    if(roomNextMap[room]) then
        local name = roomNextMap[room]
        roomNextMap[room] = nil
        return name
    end
    local maps = roomMaps[room]
    if(maps) then
        math.randomseed(getTickCount())
        local mapID = math.random(#maps)
        local map = maps[mapID]
        return map.name
    else
        return false
    end
end

function setRoomNextMap(room, name)
    if(nameMap[name]) then
        roomNextMap[room] = name
        return true
    end
    return false
end

function getMapTitle(name)
    return nameMap[name] and nameMap[name].title or false
end

function getMapAuthor(name)
    return nameMap[name] and nameMap[name].author or false
end

function getMapSpawns(name)
    return nameMap[name] and nameMap[name].spawns or false
end

function startMap(name, clients)
    local map = nameMap[name]
    if(map) then
        triggerLatentClientEvent(clients, "USGrace_maps.loadMap", 2097152, false, resourceRoot, 
            map.name, map.title,map.author, map.objects, map.pickups, map.settings, map.scripts, {}, map.room)
    end
end