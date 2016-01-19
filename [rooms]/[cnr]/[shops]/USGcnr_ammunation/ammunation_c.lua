chatLayout = getChatboxLayout()

screenWidth, screenHeight = guiGetScreenSize()

local CAT_LIST_X = 20
local CAT_LIST_Y = 30+((1+chatLayout["chat_lines"])*chatLayout["chat_scale"][2]*15)
local CAT_LIST_WIDTH = 220
local categoryCount = 0
for k, _ in pairs(categories) do categoryCount = categoryCount+1 end
local CAT_LIST_HEIGHT = 50+(30*categoryCount)

local WEP_ITEMS = 1
local WEP_ITEM_SIZE = 300
local WEP_ITEM_SEPERATOR = 15
local WEP_LIST_WIDTH = WEP_ITEMS*(WEP_ITEM_SIZE+WEP_ITEM_SEPERATOR)
local WEP_LIST_HEIGHT = WEP_ITEM_SIZE
local WEP_LIST_X = (screenWidth - WEP_LIST_WIDTH)/2
local WEP_LIST_Y = (screenHeight - WEP_ITEM_SIZE)/2

local currentCategory

local selectedWeapon = 1
local catListScroll = 0
local wepListFocused = false
local catListFocused = false

local catListRenderTarget = dxCreateRenderTarget(CAT_LIST_WIDTH,CAT_LIST_HEIGHT, true)

local buyMenuPressed = false

local weaponBought = {}

function renderShop()
    local cursorX, cursorY = 0,0
    if(isCursorShowing()) then
        cursorX,cursorY,_,_,_ = getCursorPosition()
        cursorX, cursorY = cursorX*screenWidth, cursorY*screenHeight
    end
    wepListFocused = cursorX >= WEP_LIST_X and cursorX <= WEP_LIST_X+WEP_LIST_WIDTH
                        and cursorY >= WEP_LIST_Y and cursorY <= WEP_LIST_Y+WEP_LIST_HEIGHT
    catListFocused = cursorX >= CAT_LIST_X and cursorX <= CAT_LIST_X+CAT_LIST_WIDTH
                        and cursorY >= CAT_LIST_Y and cursorY <= CAT_LIST_Y+CAT_LIST_HEIGHT
    -- draw category list
    dxDrawRectangle(CAT_LIST_X, CAT_LIST_Y, CAT_LIST_WIDTH, CAT_LIST_HEIGHT, tocolor(0,0,0,130))
        -- draw columns
        dxDrawText("Category", CAT_LIST_X+10, CAT_LIST_Y, CAT_LIST_X+CAT_LIST_WIDTH-70, CAT_LIST_Y+30, tocolor(255,255,255), 1.6, "default-bold", "left", "center")
        dxDrawText("Ammo", CAT_LIST_X+CAT_LIST_WIDTH-70, CAT_LIST_Y, CAT_LIST_X+CAT_LIST_WIDTH, CAT_LIST_Y+30, tocolor(255,255,255), 1.6,  "default-bold", "right", "center")           
    dxSetRenderTarget(catListRenderTarget, true)
    dxSetBlendMode("modulate_add")
    local catY = -catListScroll+1+35
    for slot, category in pairs(categories) do
        local hovered = cursorX >= CAT_LIST_X and cursorX <= CAT_LIST_X+CAT_LIST_WIDTH
                        and cursorY >= CAT_LIST_Y+catY and cursorY <= CAT_LIST_Y+catY+30
        if(hovered) then
            local color = tocolor(170,170,170,80)
            if(getKeyState("mouse1")) then
                currentCategory = slot
                selectedWeapon = 1
                color = tocolor(120,120,120,80)
            end
            dxDrawRectangle(0,catY,CAT_LIST_WIDTH,30, color)
        end
        dxDrawText(category.name, 10, catY, CAT_LIST_WIDTH-70, catY+30, tocolor(255,255,255), 1.5, hovered and "default-bold" or "default", "left", "center")
        dxDrawText(category.ammo, CAT_LIST_WIDTH-70, catY, CAT_LIST_WIDTH-10, catY+30, tocolor(255,255,255), 1.5, hovered and "default-bold" or "default", "right", "center")
        catY = catY+30+3
    end
    dxSetRenderTarget()
    dxSetBlendMode("add")
    dxDrawImage(CAT_LIST_X, CAT_LIST_Y, CAT_LIST_WIDTH, CAT_LIST_HEIGHT, catListRenderTarget)
    dxSetBlendMode("blend") -- draw weapon list
    -- exit button
    local exitHovered = cursorX >= CAT_LIST_X and cursorX <= CAT_LIST_X+CAT_LIST_WIDTH
                        and cursorY >= CAT_LIST_Y+CAT_LIST_HEIGHT and cursorY <= CAT_LIST_Y+CAT_LIST_HEIGHT+30
    local color = exitHovered and tocolor(90,90,90,130) or tocolor(80,80,80,130)
    if(exitHovered and getKeyState("mouse1")) then
        closeShop()
        return
    end
    dxDrawRectangle(CAT_LIST_X,CAT_LIST_Y+CAT_LIST_HEIGHT, CAT_LIST_WIDTH, 30, color)
    dxDrawText("Exit", CAT_LIST_X,CAT_LIST_Y+CAT_LIST_HEIGHT, CAT_LIST_X+CAT_LIST_WIDTH, CAT_LIST_Y+CAT_LIST_HEIGHT+30, tocolor(255,255,255), 1.75, exitHovered and "default-bold" or "default", "center", "center")
    -- draw amount of weapons in this category
    local selX = 1
    for i=1, #categories[currentCategory] do
        if(i == selectedWeapon) then
            dxDrawRectangle(WEP_LIST_X+selX, WEP_LIST_Y-20, 10,10, tocolor(130,230,130,255))
        else
            dxDrawRectangle(WEP_LIST_X+selX, WEP_LIST_Y-20, 10,10, tocolor(130,130,130,255))
        end
        selX = selX+15
    end
    -- draw selected weapon
    local weapon = categories[currentCategory][selectedWeapon].id
    local weaponName = categories[currentCategory][selectedWeapon].name
    local weaponOwned = weaponBought[weapon] == true or getPedWeapon(localPlayer, currentCategory) == weapon

    dxDrawRectangle(WEP_LIST_X+1, WEP_LIST_Y, WEP_ITEM_SIZE, WEP_ITEM_SIZE, tocolor(0,0,0,140))
    if(fileExists("images/weapon_id_"..weapon..".png")) then
        dxDrawImage(WEP_LIST_X, WEP_LIST_Y, WEP_ITEM_SIZE, WEP_ITEM_SIZE, "images/weapon_id_"..weapon..".png")
    end
    dxDrawText(weaponName, WEP_LIST_X+1, WEP_LIST_Y+WEP_ITEM_SIZE-60, WEP_LIST_X+1+WEP_ITEM_SIZE, WEP_LIST_Y+WEP_ITEM_SIZE-25, tocolor(255,255,255), 1.75, "default", "center", "center")
    local wepInfoText
    if(weaponOwned) then
        local ammoShared = categories[currentCategory].ammoShared
        local wepAmmo = 0
        if(ammoShared or getPedWeapon(localPlayer, currentCategory) == weapon) then
            wepAmmo = getPedTotalAmmo(localPlayer, currentCategory)
        end
        wepInfoText = "owned with "..wepAmmo.." ammo"
    else
        wepInfoText = "not owned"
    end
    dxDrawText(wepInfoText, WEP_LIST_X+1, WEP_LIST_Y+WEP_ITEM_SIZE-25, WEP_LIST_X+1+WEP_ITEM_SIZE, WEP_LIST_Y+WEP_ITEM_SIZE-5, tocolor(255,255,255), 1.25, "default", "center", "center")
    -- buy button
    local buyHovered = cursorX >= WEP_LIST_X and cursorX <= WEP_LIST_X+WEP_LIST_WIDTH
                        and cursorY >= WEP_LIST_Y+WEP_ITEM_SIZE+10 and cursorY <= WEP_LIST_Y+WEP_ITEM_SIZE+10+45
    local color = buyHovered and tocolor(90,90,90,130) or tocolor(80,80,80,130)
    if(buyHovered and getKeyState("mouse1")) then
        if(not buyMenuPressed) then
            buyWeapon()
            buyMenuPressed = true
        end
        color = tocolor(60,60,60,130)
    else
        buyMenuPressed = false
    end
    dxDrawRectangle(WEP_LIST_X,WEP_LIST_Y+WEP_ITEM_SIZE+10, WEP_ITEM_SIZE, 45, color)
    local buyButtonText
    if(weaponOwned) then
        buyButtonText = "Buy ammo for "..exports.USG:formatMoney(categories[currentCategory].ammoPrice)
    else
        buyButtonText = "Buy for "..exports.USG:formatMoney(categories[currentCategory][selectedWeapon].price)
    end
    dxDrawText(buyButtonText, WEP_LIST_X+1, WEP_LIST_Y+WEP_ITEM_SIZE+10, WEP_LIST_X+1+WEP_ITEM_SIZE, WEP_LIST_Y+WEP_ITEM_SIZE+10+45, tocolor(255,255,255), 1.75, buyHovered and "default-bold" or "default", "center", "center")
end

function onClientKey(key,pressed)
    if(not pressed) then return false end
    if(key == "mouse_wheel_down" or key == "arrow_l") then
        local max = #categories[currentCategory]
        selectedWeapon = math.max(1, selectedWeapon-1)
    elseif(key == "mouse_wheel_up" or key == "arrow_r") then
        local max = #categories[currentCategory]
        selectedWeapon = math.min(max, selectedWeapon+1)
    end
end

-- actual shopping
local shops = {
    {x = 307.97, y = -141.04, z = 999.6, int = 7, dim = 1},
    {x = 313.95, y = -133.69, z = 999.6, int = 7, dim = 1},
    {x = 290.15, y = -109.42, z = 1001.51, int = 6, dim = 10},
    {x = 291.49, y = -83.97, z = 1001.51, int = 4, dim = 3},
    {x = 291.4, y = -83.96, z = 1001.51, int = 4, dim = 4},
    {x = 291.49, y = -83.9, z = 1001.51, int = 4, dim = 5},
    {x = 291.46, y = -83.8, z = 1001.51, int = 4, dim = 6},
    {x = 290.07, y = -109.36, z = 1001.51, int = 6, dim = 1},
    {x = 290.07, y = -109.36, z = 1001.51, int = 6, dim = 2},
    {x = 290.07, y = -109.36, z = 1001.51, int = 6, dim = 3},
    {x = 290.07, y = -109.36, z = 1001.51, int = 6, dim = 4},
    {x = 290.07, y = -109.36, z = 1001.51, int = 6, dim = 5},
    {x = 290.07, y = -109.36, z = 1001.51, int = 6, dim = 6},
    {x = 290.07, y = -109.36, z = 1001.51, int = 6, dim = 7},
    {x = 290.02, y = -109.51, z = 1001.51, int = 6, dim = 8},
    {x = 295.64, y = -38,z =  1001.51, int = 1, dim = 2},
    {x = 290.13, y = -109.46, z = 1001.51, int = 6, dim = 9},
    {x = 311.88, y = -164.52, z = 999.6, int = 6, dim = 11},
    {x = 295.529296875, y = -37.72265625, z = 1001.515625, int = 1, dim = 0},
    {x = 295.529296875, y = -37.72265625, z = 1001.515625, int = 1, dim = 1},
    {x = 296.076171875, y = -80.28515625, z = 1001.515625, int = 4, dim = 0},
    {x = 296.076171875, y = -80.28515625, z = 1001.515625, int = 4, dim = 1},
    {x = 296.076171875, y = -80.28515625, z = 1001.515625, int = 4, dim = 2},
    {x = 2172.0888671875, y = 935.1142578125, z = 11.093437194824,int = 0, dim = 0},
    {x = 1373.462890625, y = -1290.3564453125, z = 13.55681228637, int =0 , dim = 0 },
}

local blips = {}

local shopMarkers = {}

_createBlip = createBlip
createBlip = function (...)
    local blip = _createBlip(...)
    exports.USGcnr_blips:setBlipUserInfo(blip,"Shops","Ammunation")
    exports.USGcnr_blips:setBlipDimension(blip,0)
    table.insert(blips, blip)
end

function createShops()
    for i, shop in ipairs(shops) do
        local marker = createMarker(shop.x,shop.y,shop.z-1, "cylinder",1, 255,0,0,170)
        addEventHandler("onClientMarkerHit", marker, onShopMarkerHit)
        addEventHandler("onClientMarkerLeave", marker, onShopMarkerExit)
        setElementInterior(marker, shop.int)
        setElementDimension(marker, shop.dim)
        table.insert(shopMarkers, marker)
    end
    createBlip ( 1368.35, -1279.06, 12.55, 18, 2, 0, 0, 0, 0, 0, 270 )
    createBlip ( -2625.85, 208.345,3.98935, 18, 2, 0, 0, 0, 0, 0, 270 )
    createBlip ( 242.668, -178.478, 0.621441, 18, 2, 0, 0, 0, 0, 0, 270 )
    createBlip ( 2333.43, 61.5173, 25.7342, 18, 2, 0, 0, 0, 0, 0, 270 )
    createBlip ( 2159.51, 943.329, 9.82339, 18, 2, 0, 0, 0, 0, 0, 270 )
    createBlip ( 2539.04, 2083.56, 9.82222, 18, 2, 0, 0, 0, 0, 0, 270 )
    createBlip ( 777.231, 1871.47, 3.97687, 18, 2, 0, 0, 0, 0, 0, 270 )
    createBlip ( -315.676, 829.868, 13.4266, 18, 2, 0, 0, 0, 0, 0, 270 )
    createBlip ( -2093.51, -2464.79, 29.6404, 18, 2, 0, 0, 0, 0, 0, 270 )
    createBlip ( 2400.5, -1981.48, 12.5604, 18, 2, 0, 0, 0, 0, 0, 270 )
    createBlip ( -1508.95, 2608.75, 55.83, 18, 2, 0, 0, 0, 0, 0, 270 )
end

function removeShops()
    for i, marker in ipairs(shopMarkers) do
        if(isElement(marker)) then
            destroyElement(marker)
        end
    end
    shopMarkers = {}
    for i,blip in ipairs(blips) do
        destroyElement(blip)
    end
    blips = {}
end

addEvent("onPlayerJoinRoom", true)
addEventHandler("onPlayerJoinRoom", localPlayer,
    function (room)
        if(room == "cnr") then
            createShops()
        end
    end
)
addEvent("onPlayerExitRoom", true)
addEventHandler("onPlayerExitRoom", localPlayer,
    function (prevRoom)
        if(prevRoom == "cnr") then
            removeShops()
            closeShop() 
        end
    end
)
addEventHandler("onClientResourceStart", resourceRoot,
    function ()
        if(getResourceFromName("USGrooms") and getResourceState(getResourceFromName("USGrooms")) == "running" and exports.USGrooms:getPlayerRoom() == "cnr") then
            createShops()
        end
    end
)

local weappanelInfo = {}

function createpanelInfo()
 weappanelInfo.window = exports.USGGUI:createWindow("right","bottom",170,100,false,"Ammunation Info Panel")
 weappanelInfo.label = exports.USGGUI:createLabel(1,1,170,100,false,"Use your mouse to choose any weapon Slot, then Scroll up or Scroll down to get your weapon/ammo ",weappanelInfo.window)
end


function openIfnoPanel()
    if(not isElement(weappanelInfo.window)) then
        createpanelInfo()
    else
    exports.USGGUI:setVisible(weappanelInfo.window, true)
    end
end



function onShopMarkerExit(hitElement)
    if(hitElement == localPlayer) then
        closeShop()
        closeIfnoPanel()
    end
end

local shopping = false

function closeIfnoPanel()
    if (isElement(weappanelInfo.window) and exports.USGGUI:getVisible(weappanelInfo.window))then
    exports.USGGUI:setVisible(weappanelInfo.window, false)
    end
end

function onShopMarkerHit(hitElement, dimensions)
    if(hitElement ~= localPlayer or not dimensions or isPedInVehicle(localPlayer)) then return end
    if(not exports.USG:validateMarkerZ(source, hitElement)) then return end
    openShop()
    openIfnoPanel()
end

function openShop()
    if(not shopping) then
        weaponBought = {}
        triggerServerEvent("USGcnr_ammunation.getBoughtWeapons", localPlayer) -- get bought weapons
        for slot, _ in pairs(categories) do
            currentCategory = slot
            break
        end
        selectedWeapon = 1
        addEventHandler("onClientRender", root, renderShop)
        showCursor(true)
        shopping = true
        showPlayerHudComponent("radar", false)
        addEventHandler("onClientKey", root, onClientKey)
    end
end

function closeShop()
    if(shopping) then
        removeEventHandler("onClientRender", root, renderShop)
        showCursor(false)
        shopping = false
        closeIfnoPanel()
        showPlayerHudComponent("radar", true)
        removeEventHandler("onClientKey", root, onClientKey)
    end
end

function buyWeapon()
	if(isPedInVehicle(localPlayer))then exports.USGmsg:msg("You cannot shop while inside a vehicle!", 255,128,0) return end
    if(currentCategory and selectedWeapon) then
        local weapon = categories[currentCategory][selectedWeapon].id
        triggerServerEvent("USGcnr_ammunation.buyWeapon", localPlayer, currentCategory, weapon)
    end
end

addEvent("USGcnr_ammunation.receiveBoughtWeapons", true)
addEventHandler("USGcnr_ammunation.receiveBoughtWeapons", localPlayer,
    function (weapons)
        weaponBought = {}
        if(weapons) then
            for i, weapon in ipairs(weapons) do
                weaponBought[weapon] = true
            end
        end
    end
)

--[[ to generate pictures, don't use!
local sSource = dxCreateScreenSource(1920,1080)

local models = {
    346,
    347,
    348,
    349,
    350,
    351,
    352,
    353,
    372,
    355,
    356,
    357,
    358,
    342,
    343,
    344,
    363,
}

setElementInterior(localPlayer, 10)
setWeather(40)
setTime(14,00)

local i = 12
local lastLoad = getTickCount()
local object = createObject(models[1], -0.2,0,0)
setElementInterior(object, 10)
setCameraMatrix(0,2,0,0,0,0)
function render()
    if(getTickCount()-lastLoad > 1000) then
        dxUpdateScreenSource ( sSource, true )
        local pixels = dxGetTexturePixels(sSource, 560, 210, 750, 750)
        pixels = dxConvertPixels(pixels, 'png')
        local file = fileCreate("weapon_"..i..".png")
        fileWrite(file, pixels)
        fileClose(file)
        lastLoad = getTickCount()
        i = i + 1
        destroyElement(object)
        if(models[i]) then
            object = createObject(models[i], -0.2, 0,0)
            setElementInterior(object, 10)
            if(models[i] == 342) then
                setCameraMatrix(2,0,0,0,0,0)
            else
                setCameraMatrix(0,2,0,0,0,0)
            end
        else
            removeEventHandler("onClientRender", root, render)
        end
    end
end
addEventHandler("onClientRender", root, render)
--]]