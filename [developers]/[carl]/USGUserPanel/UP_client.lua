local img1 = dxCreateTexture("account_icon.png")
local img2 = dxCreateTexture("call_icon.png")
local img3 = dxCreateTexture("gps_icon.png")
local img4 = dxCreateTexture("messages_icon.png")
local img5 = dxCreateTexture("money_icon.png")
local img6 = dxCreateTexture("music_icon.png")
local img7 = dxCreateTexture("weapons_icon.png")

local distance = 1.5

local zOff = 0.5

local canSelect = true

local openApp = nil

local panelInfo = {}

--{name , image, img variable, selected? , x offset , y offset , z offset , size , size when selected,Event to trigger , All Rooms}
local apps = {
{"Account Settings" , "account_icon.png" , img1 , true ,-distance,distance-0.25,zOff,0.5,0.75,"UserPanel.App.AccountApp",true},
{"Call","call_icon.png",img2,false,0,distance,zOff,0.5,0.75,"UserPanel.App.CallApp",false},
{"GPS","gps_icon.png",img3,false,distance,distance-0.25,zOff,0.5,0.75,"UserPanel.App.GPSApp",false},
{"Message","messages_icon.png",img4,false,distance+0.25,0,zOff,0.5,0.75,"UserPanel.App.MessageApp",true},
{"Money","money_icon.png",img5,false,distance,-distance+0.25,zOff,0.5,0.75,"UserPanel.App.MoneyApp",false},
{"Music","music_icon.png",img6,false,0,-distance,zOff,0.5,0.75,"UserPanel.App.MusicApp",true},
{"Weapons","weapons_icon.png",img7,false,-distance,-distance+0.25,zOff,0.5,0.75,"UserPanel.App.WeaponApp",false},
}

local showing = false

local function setSelected(ID)
    if(apps[ID])then
        for k,v in ipairs(apps)do
            v[4] = false
        end
        apps[ID][4] = true
    end
end

local function getSelected()
    for k,v in ipairs(apps)do
        if v[4] == true then
            return apps[k]
        end
    end
end

local function getSelectedID()
    for k,v in ipairs(apps)do
        if v[4] == true then
            return k
        end
    end
end

local function selectNext()
if(canSelect)then
	local nextID = getSelectedID() + 1
		if(nextID > #apps )then
		nextID = 1
		end
		setSelected(nextID)
	end
end

local function selectPrevious()
if(canSelect)then
	local previousID = getSelectedID() - 1
		if(previousID < 1 )then
		previousID = #apps
		end
		setSelected(previousID)
	end
end

local function render()
    local x,y,z = getElementPosition(localPlayer)
    for k,v in ipairs(apps)do
    local size = v[8] 
        if(v[4] == true)then
            dxDrawMaterialLine3D ( x + v[5] , y + v[6] , z + v[7] + v[9], x + v[5] , y + v[6] ,  z + v[7] , v[3], v[9])
        else dxDrawMaterialLine3D ( x + v[5] , y + v[6] , z + v[7] + v[8], x + v[5] , y + v[6] ,  z + v[7] , v[3], v[8])
        end
    end
end
    
function panel()
end

function createpanelInfo()
 panelInfo.window = exports.USGGUI:createWindow("right","bottom",170,100,false,"User Control Panel")
 panelInfo.label = exports.USGGUI:createLabel(1,1,170,100,false,"This is a 3D Panel, use  <  and  >  for next and preview. Left ALT to select. B to go back ",panelInfo.window)
end


function openIfnoPanel()
    if(not isElement(panelInfo.window)) then
        createpanelInfo()
    else
        exports.USGGUI:setVisible(panelInfo.window, true)
    end
end

function closeIfnoPanel()
    if (isElement(panelInfo.window) and exports.USGGUI:getVisible(panelInfo.window))then
        exports.USGGUI:setVisible(panelInfo.window, false)
    end
end

local function start()
    if(not showing)then
        setSelected(1)
        local selected = getSelected()
        addEventHandler("onClientRender", root,render)
        showing = true
        openIfnoPanel()
    elseif(showing)then
		if(openApp)then
			fadeCamera ( false)
			setTimer(function()
				fadeCamera ( true)
				setElementFrozen(localPlayer,false)
			if(getPedOccupiedVehicle ( localPlayer ))then
			setElementFrozen(getPedOccupiedVehicle ( localPlayer ),false)
			end
			if(not getCameraTarget())then
				setCameraTarget(localPlayer)
			end
			canSelect = true
			end,1000,1)
			triggerEvent ( openApp[10], root)
		elseif(not openApp)then
			removeEventHandler ( "onClientRender", root,render)
			showing = false
			closeIfnoPanel()
		end
		openApp = nil
    end
end

local sm = {}
sm.moov = 0
sm.object1,sm.object2 = nil,nil
 
local function removeCamHandler()
	if(sm.moov == 1)then
		sm.moov = 0
	end
end
 
local function camRender()
	if (sm.moov == 1) then
		local x1,y1,z1 = getElementPosition(sm.object1)
		local x2,y2,z2 = getElementPosition(sm.object2)
		setCameraMatrix(x1,y1,z1,x2,y2,z2)
	end
end
addEventHandler("onClientPreRender",root,camRender)
 
function smoothMoveCamera(x1,y1,z1,x1t,y1t,z1t,x2,y2,z2,x2t,y2t,z2t,time)
	if(sm.moov == 1)then return false end
	sm.object1 = createObject(1337,x1,y1,z1)
	sm.object2 = createObject(1337,x1t,y1t,z1t)
	setElementCollisionsEnabled ( sm.object1, false )
	setElementCollisionsEnabled ( sm.object2, false )
	setElementAlpha(sm.object1,0)
	setElementAlpha(sm.object2,0)
	setObjectScale(sm.object1,0.01)
	setObjectScale(sm.object2,0.01)
	moveObject(sm.object1,time,x2,y2,z2,0,0,0,"InOutQuad")
	moveObject(sm.object2,time,x2t,y2t,z2t,0,0,0,"InOutQuad")
	sm.moov = 1
	setTimer(removeCamHandler,time,1)
	setTimer(destroyElement,time,1,sm.object1)
	setTimer(destroyElement,time,1,sm.object2)
	return true
end

function Selected(time)
	if(isPedInVehicle(localPlayer))then
		if(not getVehicleType ( getPedOccupiedVehicle(localPlayer) ) == "Plane")then
			setElementFrozen(localPlayer,true)
			if(getPedOccupiedVehicle ( localPlayer ))then
				setElementFrozen(getPedOccupiedVehicle ( localPlayer ),true)
			end
		end
	else
		setElementFrozen(localPlayer,true)
	end
	local x,y,z,lx,ly,lz = getCameraMatrix()
	local px,py,pz = getElementPosition(localPlayer)
	local sel = getSelected()
	smoothMoveCamera(x,y,z,lx,ly,lz,px,py,pz + 3,px + sel[5] , py + sel[6] , pz + sel[7] + 1.25 , time)
	setTimer ( function()
		openApp = getSelected()
		triggerEvent ( openApp[10], root)
	end, time, 1 )
end


function Select()
	if(canSelect)then
		if (showing)then
		local sel = getSelected()
				if(sel[10] == "")then return end
			if(exports.USGrooms:getPlayerRoom(localPlayer) == "cnr" or sel[11] == true)then
				canSelect = false
				Selected(500)
			else exports.USGmsg:msg("You cannot use "..sel[1].." App in this room", 0, 255, 0)
			end
		end
	end
end

bindKey ( "b", "down", start )
bindKey ( ",", "down", selectPrevious )
bindKey ( ".", "down", selectNext )
bindKey ( "lalt", "down", Select )
local enabled = true
addCommandHandler("toggleUPphone",function()
	if(enabled)then
		if(showing)then start() end
	unbindKey ( "b", "down", start )
	unbindKey ( ",", "down", selectPrevious )
	unbindKey ( ".", "down", selectNext )
	unbindKey ( "lalt", "down", Select )
	else
	bindKey ( "b", "down", start )
	bindKey ( ",", "down", selectPrevious )
	bindKey ( ".", "down", selectNext )
	bindKey ( "lalt", "down", Select )
	end
	enabled = not enabled
end)