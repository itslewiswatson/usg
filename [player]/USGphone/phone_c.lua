addEvent("onPhoneCreated")
screenWidth, screenHeight = guiGetScreenSize()

color_white = tocolor(255,255,255)
color_black = tocolor(0,0,0)

local enabled = false

local _showCursor = showCursor
local cursorStates = {}
function showCursor(k, state)
    cursorStates[k] = state
    for k, cState in pairs(cursorStates) do
        if(cState ~= state and state == false) then
            return 
        end
    end
    _showCursor(state)
end

class 'phone'

local scaleX = (screenWidth/1440)*1.1 -- scale

local floor = math.floor

local SLIDE_DURATION = 350
PHONE_WIDTH = floor(248*scaleX)
local scaleY = PHONE_WIDTH/256
PHONE_HEIGHT = floor(502*scaleY)
PHONE_X = screenWidth-PHONE_WIDTH-30
PHONE_Y = screenHeight-PHONE_HEIGHT-135

PHONE_SCREEN_X = floor(16*scaleX)
PHONE_SCREEN_Y = floor(75*scaleY)
PHONE_SCREEN_WIDTH = floor(224*scaleX)
PHONE_SCREEN_HEIGHT = floor(395*scaleY)

PHONE_SCREEN_BACKGROUND = fileExists("images/backgrounds/custom.png") and "images/backgrounds/custom.png" or "images/backgrounds/background.png"

PHONE_BACK_X = floor(100*scaleX)
PHONE_BACK_Y = floor(476*scaleY)
PHONE_BACK_WIDTH = floor(54*scaleX)
PHONE_BACK_HEIGHT = floor(20*scaleY)

PHONE_TITLEBAR_HEIGHT = floor(16*scaleY)

ICON_SIZE = floor(48*scaleX)
ICON_SEPERATOR = floor(10*scaleX)

ICONS_PER_ROW = math.floor(PHONE_SCREEN_WIDTH/(ICON_SIZE+ICON_SEPERATOR+ICON_SEPERATOR))

local render = function () Phone:draw() end
local mouseState = getKeyState("mouse1")
local mousePressed = false

function phone:phone(...)
    self.apps = {}
    self.opened = false
    self.x = PHONE_X
    self.slide = false
    self.y = 0
    self.openedApp = false
    self.drawInitalized = false
    self.relativeGUI = {}
    addEventHandler("onClientRestore", root, function () Phone:refreshCache() end) -- when stuff gets reset, redraw the cache
    return self
end

function phone:toggle()
    if(self.opened) then
        if(self.slide and self.slideDirection == "out") then return false end -- already closing
        if(not self.slide) then
            self.slideStart = getTickCount()
        end
        self.slide = true
        self.slideDirection = "out"
        showCursor("phone", false)
    elseif(exports.USGaccounts:isPlayerLoggedIn()) then
        self.opened = true
        if(not self.slide) then
            self.slideStart = getTickCount()
        end
        self.slide = true
        self.slideDirection = "in"
        addEventHandler("onClientRender", root, render)
    end
end

function phone:isAppAvailable(app)
    local pRoom = exports.USGrooms:getPlayerRoom()
    if(type(app.roomRestriction) == "table") then
        for i, room in ipairs(app.roomRestriction) do
            if(pRoom == room) then
                return true
            end
        end
        return false
    elseif(type(app.roomRestriction) == "string") then
        return app.roomRestriction == pRoom
    else
        return true
    end
end

function phone:addRelativeGUI(app, GUI, x, y)
    table.insert(self.relativeGUI, { app=app, element=GUI, x=x, y=y})
end

function phone:positionRelativeGUI()
    for i, gui in ipairs(self.relativeGUI) do
        if(gui.app == self.openedApp) then
            if(isElement(gui.element)) then
                if(getElementType(gui.element) == "USGGUI") then
                    exports.USGGUI:setPosition(gui.element, self.x+PHONE_SCREEN_X+gui.x, self.y+PHONE_SCREEN_Y+PHONE_TITLEBAR_HEIGHT+gui.y)
                else
                    guiSetPosition(gui.element, self.x+PHONE_SCREEN_X+gui.x, self.y+PHONE_SCREEN_Y+PHONE_TITLEBAR_HEIGHT+gui.y, false)
                end
            else
                table.remove(self.relativeGUI, i)
            end
        end
    end
end

function phone:onOpened()
    showCursor("phone", true)
    if(self.openedApp) then
        self.openedApp:refresh()
    end
end

function phone:onClosed()
    self.opened = false
    removeEventHandler("onClientRender", root, render)
    showCursor("phone", false)
    --self:closeOpenedApp()
end

function phone:closeOpenedApp()
    if(self.openedApp) then
        self.openedApp:close()
        self.openedApp = false
        self:refreshCache() -- load normal background
    end
end

function phone:goBack()
    if(self.openedApp) then
        self:closeOpenedApp()
    else
        self:toggle()
    end
end

function phone:openApp(app)
    app:open()
    self.openedApp = app
    self:refreshCache() -- load app background
end

function phone:refreshCache()
    dxSetBlendMode("add")
    if(isElement(self.cache)) then 
        dxSetRenderTarget(self.cache, true) 
    else
        self.cache = dxCreateRenderTarget(PHONE_WIDTH, PHONE_HEIGHT, true)
        dxSetRenderTarget(self.cache)
    end
    dxDrawImage(7,7,PHONE_WIDTH,PHONE_HEIGHT, "images/case.png")

    dxDrawImage(PHONE_SCREEN_X, PHONE_SCREEN_Y, PHONE_SCREEN_WIDTH, PHONE_SCREEN_HEIGHT, 
        self.openedApp and "images/backgrounds/appbackground.png" or PHONE_SCREEN_BACKGROUND)

    -- draw titlebar
    dxDrawRectangle(PHONE_SCREEN_X,PHONE_SCREEN_Y,PHONE_SCREEN_WIDTH,PHONE_TITLEBAR_HEIGHT,tocolor(0,0,0,120))
    dxDrawRectangle(PHONE_SCREEN_X, PHONE_SCREEN_Y+PHONE_TITLEBAR_HEIGHT-1, PHONE_SCREEN_WIDTH,1, tocolor(90,90,90,230)) -- small seperator line
    dxSetBlendMode("blend")
    dxSetRenderTarget()
end

function phone:draw()
    if(not isElement(self.cache)) then
        self:refreshCache()
    end
    local mouse = getKeyState("mouse1")
    if(mouse and not mouseState) then
        mousePressed = true
    else
        mousePressed = false
    end
    mouseState = mouse

    if(mousePressed and doesMouseHover(self.x+PHONE_BACK_X, self.y+PHONE_BACK_Y, PHONE_BACK_WIDTH, PHONE_BACK_HEIGHT)) then
        self:goBack()
    end
    local tick = getTickCount()
    if(self.slide) then
        local progress = (tick-self.slideStart)/SLIDE_DURATION
        if(progress >= 1) then
            self.slide = false
            if(self.slideDirection == "out") then
                self:onClosed()
            else
                self:onOpened()
            end
        else
            local y,_ = PHONE_Y, nil
            if(self.slideDirection == "in") then
                _,y,_ = interpolateBetween(0,screenHeight,0,0,PHONE_Y,0,progress,"Linear")
            else
                _,y,_ = interpolateBetween(0,PHONE_Y,0,0,screenHeight,0,progress,"Linear")
            end
            self.y = math.floor(y)
        end
    end
    dxDrawImage(self.x, self.y, PHONE_WIDTH, PHONE_HEIGHT, self.cache)
    if(self.openedApp) then
        self:positionRelativeGUI()
        --dxDrawImage(self.x+PHONE_SCREEN_X, self.y+PHONE_SCREEN_Y, PHONE_SCREEN_WIDTH, PHONE_SCREEN_HEIGHT, "images/appbackground.png")
        self.openedApp:draw()
    else
        --dxDrawImage(self.x+PHONE_SCREEN_X, self.y+PHONE_SCREEN_Y, PHONE_SCREEN_WIDTH, PHONE_SCREEN_HEIGHT, PHONE_SCREEN_BACKGROUND)
        self:drawApps()
    end
    -- draw titlebar
    --dxDrawRectangle(self.x+PHONE_SCREEN_X, self.y+PHONE_SCREEN_Y, PHONE_SCREEN_WIDTH,PHONE_TITLEBAR_HEIGHT, tocolor(0,0,0,120))
    --dxDrawRectangle(self.x+PHONE_SCREEN_X, self.y+PHONE_SCREEN_Y+PHONE_TITLEBAR_HEIGHT-1, PHONE_SCREEN_WIDTH,1, tocolor(90,90,90,230)) -- small seperator line
    local time = exports.USG:getDateTimeString()
    dxDrawText(time, self.x+PHONE_SCREEN_X, self.y+PHONE_SCREEN_Y, self.x+PHONE_SCREEN_X+PHONE_SCREEN_WIDTH-2,self.y+PHONE_SCREEN_Y+PHONE_TITLEBAR_HEIGHT, 
        tocolor(255,255,255), 1, "default", "right","center")
end

function phone:drawApps()
    local screenX = self.x+PHONE_SCREEN_X+ICON_SEPERATOR+((PHONE_SCREEN_WIDTH-(ICONS_PER_ROW*(ICON_SIZE+ICON_SEPERATOR)))/2)
    local screenY = self.y+PHONE_SCREEN_Y+ICON_SEPERATOR+PHONE_TITLEBAR_HEIGHT
    local row = 0
    local column = 0
    local hoveredApp, hoveredX, hoveredY
    local quickBarApps = {}
    for i, app in ipairs(self.apps) do
        if(self:isAppAvailable(app)) then
            if(not app.quickBar or #quickBarApps >= ICONS_PER_ROW) then
                local x,y = screenX+column*(ICON_SIZE+ICON_SEPERATOR), screenY+(row*(ICON_SIZE+ICON_SEPERATOR))
                local hovered = doesMouseHover(x,y,ICON_SIZE,ICON_SIZE)
                local size = ICON_SIZE
                if(hovered) then
                    x,y,size = x-2,y-2,size+4
                    hoveredApp, hoveredX, hoveredY = app, x, y
                    if(mousePressed) then
                        self:openApp(app)
                        break
                    end
                end
                if(app.icon) then
                    dxDrawImage(x,y,size,size,app.icon)
                else
                    dxDrawRectangle(x,y,size,size,tocolor(255,0,0))
                end
                column = column+1
                if(column >= ICONS_PER_ROW) then
                    column = 0
                    row = row + 1
                end
            else
                table.insert(quickBarApps, app)
            end
        end
    end
    if(#quickBarApps > 0) then
        dxDrawRectangle(PHONE_SCREEN_X+self.x, self.y+PHONE_SCREEN_Y+PHONE_SCREEN_HEIGHT-(ICON_SEPERATOR*2), PHONE_SCREEN_WIDTH, (ICON_SEPERATOR*2), tocolor(170,170,170,30))
    end
    for i, app in ipairs(quickBarApps) do
        local x,y = screenX+(i-1)*(ICON_SIZE+ICON_SEPERATOR), self.y+PHONE_SCREEN_Y+PHONE_SCREEN_HEIGHT-ICON_SIZE-ICON_SEPERATOR
        local hovered = doesMouseHover(x,y,ICON_SIZE,ICON_SIZE)
        local size = ICON_SIZE
        if(hovered) then
            x,y,size = x-2,y-2,size+4
            hoveredApp, hoveredX, hoveredY = app, x, y
            if(mousePressed) then
                self:openApp(app)
                break
            end
        end
        if(app.icon) then
            dxDrawImage(x,y,size,size,app.icon)
        else
            dxDrawRectangle(x,y,size,size,tocolor(255,0,0))
        end
    end
    if(hoveredApp and hoveredApp.name) then -- draw app name with shadows, must be after loop so icons won't overlap
        local x,y,size, font = hoveredX, hoveredY, ICON_SIZE+3, "default-bold"
        -- thin border
            --dxDrawText(hoveredApp.name, x-1, y+size,x+size,y+size+ICON_SIZE,tocolor(0,0,0),1.01,font,"center","top")
            --dxDrawText(hoveredApp.name, x+1, y+size,x+size,y+size+ICON_SIZE,tocolor(0,0,0),1.01,font,"center","top")
            --dxDrawText(hoveredApp.name, x, y-1+size,x+size,y+size+ICON_SIZE,tocolor(0,0,0),1.01,font,"center","top")
            --dxDrawText(hoveredApp.name, x, y+1+size,x+size,y+size+ICON_SIZE,tocolor(0,0,0),1.01,font,"center","top")
        -- thick border
            dxDrawText(hoveredApp.name, x-1, y-1+size,x+size,y+size+ICON_SIZE,tocolor(0,0,0),1.01,font,"center","top")
            dxDrawText(hoveredApp.name, x+1, y-1+size,x+size,y+size+ICON_SIZE,tocolor(0,0,0),1.01,font,"center","top")
            dxDrawText(hoveredApp.name, x-1, y+1+size,x+size,y+size+ICON_SIZE,tocolor(0,0,0),1.01,font,"center","top")
            dxDrawText(hoveredApp.name, x+1, y+1+size,x+size,y+size+ICON_SIZE,tocolor(0,0,0),1.01,font,"center","top")
        dxDrawText(hoveredApp.name, x,y+size, x+size,y+size+ICON_SIZE,tocolor(255,255,255),1,font,"center","top")
    end
end

function doesMouseHover(x,y,width,height)
    if(isCursorShowing()) then
        local cx,cy = getCursorPosition()
        cx, cy = cx*screenWidth,cy*screenHeight
        return cx>=x and cx<=x+width and cy>=y and cy<=y+height
    else
        return false
    end
end

function createPhone()
    if(not Phone) then 
        Phone = phone() 
	
        triggerEvent("onPhoneCreated", localPlayer)
    end
end
    

addEventHandler("onClientResourceStart", resourceRoot,
    function ()
        if(getResourceFromName("USGaccounts") and getResourceState(getResourceFromName("USGaccounts")) == "running"
        and exports.USGaccounts:isPlayerLoggedIn() and not Phone) then
            createPhone()
        else
            addEventHandler("onServerPlayerLogin", localPlayer,createPhone)
        end
    end
)


	addCommandHandler("toggleUPphone",function()
		if(enabled)then
			unbindKey("N","down",function () 
					Phone:toggle()
			end)
		else 
			bindKey("N","down",function () 
					Phone:toggle()
			end) 
		end
		enabled = not enabled
	end)