local sX, sY = guiGetScreenSize()
local nX, nY = 1366, 768
local iX, iY = 1920, 1080
local disabledHUD = {"ammo", "health", "armour", "breath", "clock", "money", "weapon"}
hudEnabled = true

function convertNumber(number)
	local formatted = number  
	while true do      
		formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')    
		if (k == 0) then      
			break   
		end  
	end  
	return formatted
end

function math.round(number, decimals, method)
    decimals = decimals or 0
    local factor = 10 ^ decimals
    if ( method == "ceil" or method == "floor" ) then return math[method]( number * factor ) / factor
    else return tonumber( ( "%."..decimals.."f" ):format( number ) ) end
end

-- Export functions to make life easier
function getDisabledHUD()
	return disabledHUD
end

function isLocalPlayerCustomHUDEnabled()
	if (isPlayerMapVisible() or (not isPlayerHudComponentVisible("radar"))) or (exports.USGrooms:getPlayerRoom(localPlayer) ~= "cnr") or (not hudEnabled) then
		return false
	end
	return true
end

function enableHUD()
	for _, v in pairs(disabledHUD) do
		showPlayerHudComponent(v, false)
	end
	hudEnabled = true
end

function disableHUD()
	if (exports.USGrooms:getPlayerRoom(localPlayer) == "cnr") then
		for _, v in pairs(disabledHUD) do
			showPlayerHudComponent(v, true)
		end
		hudEnabled = nil
	end
end
addEventHandler("onClientResourceStop", resourceRoot, disableHUD)

-- Switch for the player
function toggleHUD()
	if (exports.USGrooms:getPlayerRoom(localPlayer) == "cnr") then
		if (hudEnabled == true) then
			disableHUD()
		else
			enableHUD()
		end
	else
		if (hudEnabled) or (isPlayerHudComponentVisible("clock")) then
			disableHUD()
		end
	end
end
addCommandHandler("hud", toggleHUD)

function foo()
	if (exports.USGrooms:getPlayerRoom(localPlayer) == "cnr") then
		enableHUD()
	end
end
addEventHandler("onClientResourceStart", resourceRoot, foo)

-- Disabled the in-built HUD on room join
addEvent("onPlayerJoinRoom", true)
addEventHandler("onPlayerJoinRoom", localPlayer,
	function (room)
		if (room == "cnr") then
			enableHUD()
		end
	end
)

-- 
addEvent("onPlayerLeaveRoom", true)
addEventHandler("onPlayerLeaveRoom", localPlayer, 
	function (room)
		if (room == "cnr") then
			disableHUD()
		end
	end
)

-- This is still optimized for 1366x768
function renderWeapons2()
	if (not isPlayerHudComponentVisible("radar") or isPlayerMapVisible() or (exports.USGrooms:getPlayerRoom(localPlayer) ~= "cnr") or not hudEnabled) then return end
	
	local wepID = getPedWeapon(localPlayer)
	imagePath = ":USGcnr_hud2/icons/"..getWeaponNameFromID(wepID)..".png"
	dxDrawImage((1064 / nX) * sX, (39 / nY) * sY, (92 / nX) * sX, (90 / nY) * sY, imagePath, 0, 0, 0, tocolor(255, 255, 255, 255), false)
end
addEventHandler("onClientRender", root, renderWeapons2)

-- This is still optimized for 1366x768
function renderWeapons()
	if (not isPlayerHudComponentVisible("radar") or isPlayerMapVisible() or (exports.USGrooms:getPlayerRoom(localPlayer) ~= "cnr") or not hudEnabled) then return end
	
	local wepSlot = getPedWeaponSlot(localPlayer)
	local clipAmmo = getPedAmmoInClip(localPlayer)
	local totalAmmo = getPedTotalAmmo(localPlayer)
	local wepID = getPedWeapon(localPlayer)
	local ammoIndicatorText = clipAmmo.."/"..totalAmmo - clipAmmo
	
	if (wepSlot == 6) or (wepSlot == 8) or (wepID == 25) or (wepID == 35) or (wepID == 36) then
		ammoIndicatorText = tostring(totalAmmo)
	end

	if (wepSlot == 0) or (wepSlot == 1) or (wepSlot == 10) or (wepSlot == 12) or (wepID == 44) or (wepID == 45) or (wepID == 46) then
		return
	end
	
	dxDrawText(ammoIndicatorText, ((1078 - 1) / nX) * sX, ((110 - 1) / nY) * sY, ((1140 - 1) / nX) * sX, ((134 - 1) / nY) * sY, tocolor(0, 0, 0, 255), 1.50, "default-bold", "center", "top", false, false, false, false, false)
	dxDrawText(ammoIndicatorText, ((1078 + 1) / nX) * sX, ((110 - 1) / nY) * sY, ((1140 + 1) / nX) * sX, ((134 - 1) / nY) * sY, tocolor(0, 0, 0, 255), 1.50, "default-bold", "center", "top", false, false, false, false, false)
	dxDrawText(ammoIndicatorText, ((1078 - 1) / nX) * sX, ((110 + 1) / nY) * sY, ((1140 - 1) / nX) * sX, ((134 + 1) / nY) * sY, tocolor(0, 0, 0, 255), 1.50, "default-bold", "center", "top", false, false, false, false, false)
	dxDrawText(ammoIndicatorText, ((1078 + 1) / nX) * sX, ((110 + 1) / nY) * sY, ((1140 + 1) / nX) * sX, ((134 + 1) / nY) * sY, tocolor(0, 0, 0, 255), 1.50, "default-bold", "center", "top", false, false, false, false, false)
	dxDrawText(ammoIndicatorText, (1078 / nX) * sX, (110 / nY) * sY, (1140 / nX) * sX, (134 / nY) * sY, tocolor(255, 255, 255, 255), 1.50, "default-bold", "center", "top", false, false, false, false, false)	
end
addEventHandler("onClientRender", root, renderWeapons)

-- All functions from here on in are optimized for 1920x1080 (the res they were made in)

function renderArmour()
	if (not isPlayerHudComponentVisible("radar") or isPlayerMapVisible() or (exports.USGrooms:getPlayerRoom(localPlayer) ~= "cnr") or not hudEnabled) then return end	
	local armourLevel = math.round(getPedArmor(localPlayer))
	if armourLevel == 0 then return end
	
	dxDrawRectangle((1639 / iX) * sX, (112 / iY) * sY, (181 / iX) * sX, (18 / iY) * sY, tocolor(0, 0, 0, 255), false)
	dxDrawRectangle((1642 / iX) * sX, (115 / iY) * sY, armourLevel * ((1.75 / iX) * sX), (12 / iY) * sY, tocolor(255, 255, 255, 255), false)
end
addEventHandler("onClientRender", root, renderArmour)

function renderOxygen()
	if (not isPlayerHudComponentVisible("radar") or isPlayerMapVisible() or (exports.USGrooms:getPlayerRoom(localPlayer) ~= "cnr") or not hudEnabled) then return end	
	if not isElementInWater(localPlayer) then return end
	local oxygenLevel = getPedOxygenLevel(localPlayer) / 10
	
	if (getPedStat(localPlayer, 24) == 1000) then
		gY, hY = 147, 150
	else
		gY, hY = 134, 137
	end
	
	dxDrawRectangle((1639 / iX) * sX, (gY / iY) * sY, (181 / iX) * sX, (18 / iY) * sY, tocolor(0, 0, 0, 255), false)
	dxDrawRectangle((1642 / iX) * sX, (hY / iY) * sY, oxygenLevel * (1.75 / iX) * sX, (12 / iY) * sY, tocolor(25, 208, 215, 255), false)
end
addEventHandler("onClientRender", root, renderOxygen)

function renderClock()
	if (not isPlayerHudComponentVisible("radar") or isPlayerMapVisible() or (exports.USGrooms:getPlayerRoom(localPlayer) ~= "cnr") or not hudEnabled) then return end	
	local h, m = getTime()
	if m < 10 then
		m = "0"..m
	end
	if h < 10 then
		h = "0"..h
	end
	
	dxDrawText(h..":"..m, (1636 / iX) * sX, (66 / iY) * sY, (1821 / iX) * sX, (108 / iY) * sY, tocolor(0, 0, 0, 255), 3.35, "default", "right", "bottom", false, false, false, false, false)
	dxDrawText(h..":"..m, (1638 / iX) * sX, (66 / iY) * sY, (1823 / iX) * sX, (108 / iY) * sY, tocolor(0, 0, 0, 255), 3.35, "default", "right", "bottom", false, false, false, false, false)
	dxDrawText(h..":"..m, (1636 / iX) * sX, (68 / iY) * sY, (1821 / iX) * sX, (110 / iY) * sY, tocolor(0, 0, 0, 255), 3.35, "default", "right", "bottom", false, false, false, false, false)
	dxDrawText(h..":"..m, (1638 / iX) * sX, (68 / iY) * sY, (1823 / iX) * sX, (110 / iY) * sY, tocolor(0, 0, 0, 255), 3.35, "default", "right", "bottom", false, false, false, false, false)
	dxDrawText(h..":"..m, (1637 / iX) * sX, (67 / iY) * sY, (1822 / iX) * sX, (109 / iY) * sY, tocolor(255, 255, 255, 255), 3.35, "default", "right", "bottom", false, false, false, false, false)
	
end
addEventHandler("onClientRender", root, renderClock)

function renderMoney()
	if (not isPlayerHudComponentVisible("radar") or isPlayerMapVisible() or (exports.USGrooms:getPlayerRoom(localPlayer) ~= "cnr") or not hudEnabled) then return end
	local finalOutputM = convertNumber(getPlayerMoney(localPlayer))
	local maxHealth = math.round(getPedStat(localPlayer, 24))
	
	if (maxHealth == 1000) then
		aY, bY, cY = 208, 210, 209
		dY, eY, fY = 243, 245, 244
	else
		aY, bY, cY = 182, 184, 183	
		dY, eY, fY = 217, 219, 218
	end
	
	dxDrawText("$"..finalOutputM, (1505 / iX) * sX, (aY / iY) * sY, (1821 / iX) * sX, (dY / iY) * sY, tocolor(0, 0, 0, 255), 1.80, "pricedown", "right", "top", false, false, false, false, false)
	dxDrawText("$"..finalOutputM, (1507 / iX) * sX, (aY / iY) * sY, (1823 / iX) * sX, (dY / iY) * sY, tocolor(0, 0, 0, 255), 1.80, "pricedown", "right", "top", false, false, false, false, false)
	dxDrawText("$"..finalOutputM, (1506 / iX) * sX, (bY / iY) * sY, (1821 / iX) * sX, (eY / iY) * sY, tocolor(0, 0, 0, 255), 1.80, "pricedown", "right", "top", false, false, false, false, false)
	dxDrawText("$"..finalOutputM, (1507 / iX) * sX, (bY / iY) * sY, (1823 / iX) * sX, (dY / iY) * sY, tocolor(0, 0, 0, 255), 1.80, "pricedown", "right", "top", false, false, false, false, false)
	dxDrawText("$"..finalOutputM, (1506 / iX) * sX, (cY / iY) * sY, (1822 / iX) * sX, (fY / iY) * sY, tocolor(0, 128, 128, 255), 1.80, "pricedown", "right", "top", false, false, false, false, false)
end
addEventHandler("onClientRender", root, renderMoney)

function renderHealthBar()
	if (not isPlayerHudComponentVisible("radar") or isPlayerMapVisible() or (exports.USGrooms:getPlayerRoom(localPlayer) ~= "cnr") or not hudEnabled) then return end	
	local maxHealth = math.round(getPedStat(localPlayer, 24))
	health = math.round(getElementHealth(localPlayer))
	
	if (maxHealth == 1000) then
		dxDrawRectangle((1498 / iX) * sX, (185 / iY) * sY, (323 / iX) * sX, (18 / iY) * sY, tocolor(0, 0, 0, 255), false)
		dxDrawRectangle((1501 / iX) * sX, (188 / iY) * sY, health * ((1.585 / iX) * sX), (12 / iY) * sY, tocolor(255, 0, 0, 255), false)
	
	else
		dxDrawRectangle((1639 / iX) * sX, (156 / iY) * sY, (181 / iX) * sX, (18 / iY) * sY, tocolor(0, 0, 0, 255), false)
		dxDrawRectangle((1642 / iX) * sX, (159 / iY) * sY, health * ((1.75 / iX) * sX), (12 / iY) * sY, tocolor(255, 0, 0, 255), false)	
	end
end
addEventHandler("onClientRender", root, renderHealthBar)

--[[
24 = 100:
	dxDrawRectangle(1498, 185, 323, 18, tocolor(0, 0, 0, 255), false)
	dxDrawRectangle(1501, 188, 317, 12, tocolor(255, 255, 255, 255), false)
else:
	dxDrawRectangle(1639, 161, 181, 18, tocolor(0, 0, 0, 255), false)
	dxDrawRectangle(1642, 164, 175, 12, tocolor(255, 255, 255, 255), false)
	
$$$$$
	-- health 1000
        dxDrawText("$99,999,999", 1505, 208, 1821, 244 - 1, tocolor(0, 0, 0, 255), 1.80, "pricedown", "right", "top", false, false, false, false, false)
        dxDrawText("$99,999,999", 1507, 208, 1823, 244 - 1, tocolor(0, 0, 0, 255), 1.80, "pricedown", "right", "top", false, false, false, false, false)
        dxDrawText("$99,999,999", 1506, 210, 1821, 244 + 1, tocolor(0, 0, 0, 255), 1.80, "pricedown", "right", "top", false, false, false, false, false)
        dxDrawText("$99,999,999", 1507, 210, 1823, 244 + 1, tocolor(0, 0, 0, 255), 1.80, "pricedown", "right", "top", false, false, false, false, false)
        dxDrawText("$99,999,999", 1506, 209, 1822, 244, tocolor(255, 255, 255, 255), 1.80, "pricedown", "right", "top", false, false, false, false, false)
		
		dxDrawText("$99,999,999", 1505, 182, 1821, 217, tocolor(0, 0, 0, 255), 1.80, "pricedown", "right", "top", false, false, false, false, false)
        dxDrawText("$99,999,999", 1507, 182, 1823, 217, tocolor(0, 0, 0, 255), 1.80, "pricedown", "right", "top", false, false, false, false, false)
        dxDrawText("$99,999,999", 1506, 184, 1821, 219, tocolor(0, 0, 0, 255), 1.80, "pricedown", "right", "top", false, false, false, false, false)
        dxDrawText("$99,999,999", 1507, 184, 1823, 219, tocolor(0, 0, 0, 255), 1.80, "pricedown", "right", "top", false, false, false, false, false)
        dxDrawText("$99,999,999", 1506, 183, 1822, 218, tocolor(255, 255, 255, 255), 1.80, "pricedown", "right", "top", false, false, false, false, false)
		
		-- arm
        dxDrawRectangle(1639, 112, 181, 18, tocolor(0, 0, 0, 255), false)
        dxDrawRectangle(1642, 115, 175, 12, tocolor(255, 255, 255, 255), false)
		
		-- oxygenLevel
		dxDrawRectangle(1639, 134, 181, 18, tocolor(0, 0, 0, 255), false)
		dxDrawRectangle(1642, 137, 175, 12, tocolor(255, 255, 255, 255), false)
--]]
