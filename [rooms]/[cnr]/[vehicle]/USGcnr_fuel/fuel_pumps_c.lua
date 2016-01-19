-- Tables for the fuel markers
local pumpsMarkers = {}
local pumpsTable = {
	-- SF GAS STATION NEAR SFPD
	{-1672.05, 405.35, 6.85, true },
	{-1666.75, 410.37, 6.85 },
	{-1679.24, 412.21, 6.85 },
	{-1673.81, 417.5, 6.85 },

	-- SF Juniper Hallow place.Near Jizzys club>Pay N spray Gas station
	{-2407.49, 971.53, 44.97, true },
	{-2407.56, 982.32, 44.97 },
	{-2414.68, 980.48, 44.97 },
	{-2414.68, 970.04, 44.97 },


	-- Angel Pine GAS STATION
	{-2249.57, -2558.71, 31.58, true },
	{-2239.06, -2563.1, 31.6 },
	{-2244.82, -2561.4, 31.6 },

	-- FLINT COUNTRY TRUCKER JOB GAS STATION
	{-95, -1161.41, 1.91, true },
	{-99.95, -1173.21, 2.12 },
	{-88.1, -1164.68, 1.96 },
	{-92.88, -1176.37, 1.88 },

	-- MONTGOMERY
	{1378.92, 458.36, 19.61, true },
	{1383.41, 456.51, 19.61 },
	{1385.15, 461.04, 19.8 },
	{1380.73, 463.16, 19.8 },

	-- LS DILIMORE PD GAS STATION
	{652.66, -560.14, 16.01, true },
	{652.74, -570.98, 16.01 },
	{658.22, -569.71, 16.01 },
	{658.27, -558.89, 16.01 },

	-- LV NEAR BASEBALL STADIUM GAS STATION
	{1590.09, 2190.96, 10.82, true },
	{1601.8, 2190.69, 10.82 },
	{1590.38, 2196.61, 10.82 },
	{1601.84, 2196.18, 10.82 },
	{1602.17, 2202.28, 10.82 },
	{1590.28, 2201.79, 10.82 },
	{1596, 2206.69, 10.82 },

	-- NORTH OF LV NEAR BURGER SHOT GAS STATION
	{2141.41, 2756.27, 10.82, true },
	{2153.37, 2756.49, 10.82 },
	{2153.23, 2750.65, 10.82 },
	{2141.55, 2750.51, 10.82 },
	{2147.46, 2740.06, 10.82 },

	-- NORTH OF LV NEAR LVPD GAS STATION
	{2194.45, 2470.04, 10.82, true },
	{2194.61, 2480.42, 10.82 },
	{2205.36, 2480.33, 10.82 },
	{2205.01, 2469.95, 10.82 },

	-- LV NEAR MF BASE GUNSHOP STOP/CARSHOP GAS STATIONS
	{622.3, 1679.94, 6.99, true },
	{618.93, 1684.98, 6.99 },
	{615.32, 1689.81, 6.99 },
	{612.02, 1694.95, 6.99 },
	{608.64, 1699.88, 6.99 },
	{605.27, 1704.75, 6.99 },

	-- SOUTH OF LV,GUNSHOP GAS STATION
	{2120.77, 928.59, 10.82, true },
	{2108.88, 928.72, 10.82 },
	{2120.69, 917.61, 10.82 },
	{2109.05, 917.79, 10.82 },

	-- SOUTH EAST OF LV GAS STATION COME A LOT NEAR THE PYRAMID
	{2634.68, 1097.78, 10.82, true },
	{2645.61, 1097.5, 10.82 },
	{2645.34, 1109.25, 10.82 },
	{2634.64, 1109.06, 10.82 },

	-- MF BASE
	{283.12, 2000.55, 17.64 },
	{282.15, 2033.92, 17.64 },

	-- FORT CARSON NEAR CLUCKIN BELL
	{64.56, 1219.51, 18.82, true },
	{70.53, 1218.7, 18.81 },
	{76.42, 1217.21, 18.82 },

	-- EL QUEBRADOS GAS STATION
	{-1328.92, 2672.1, 50.06, true },
	{-1327.91, 2677.47, 50.06 },
	{-1327.51, 2682.94, 50.06 },

	-- LV DESERT-Tiera Robbada near Cluckin bell
	{-1477.61, 1857.44, 32.63, true },
	{-1464.91, 1857.88, 32.63 },
	{-1465.24, 1865.8, 32.63 },
	{-1477.75, 1865.01, 32.63 },

	-- LS GAS STATION NEAR EX.DOD BASE
	{999.97, -940, 42.17, true },
	{1007.03, -939.19, 42.17 },
	{1007.75, -933.45, 42.17 },
	{1000.55, -934.48, 42.17 },

	-- LS GAS STATION "Little Mexico"
	{1944.29, -1776.53, 13.39, true },
	{1944.3, -1769.2, 13.39 },
	{1938.93, -1769.1, 13.38 },
	{1938.91, -1776.63, 13.39 },

	-- Tiera Robbada Gas Station-Trucker stop. 
	{-742.21, 2751.14, 47.22, true },

	-- Whetstone-24/7 shop near Angel Pine Gas station
	{-1602.46, -2709.84, 48.53, true },
	{-1605.85, -2714.2, 48.53 },
	{-1609.22, -2718.53, 48.53 },
	
	-- LS airport
	{1943.16, -2643.56, 13.54, true },
	{1973.68, -2642.29, 13.54 },
	{2006.33, -2641.51, 13.54 },
	{2042.73, -2640.8, 13.54 },
	
	-- LV airport
	{11332.48, 1571.46, 10.82, true },
	{11332.54, 1609.93, 10.82 },
	
	-- SF airport
	{-1308.82, 25.31, 14.14, true },
	{-1292.43, 8.07, 14.14 },
	{-1275.06, -9.45, 14.14 },
	
	-- Others
	{1326.45, 1391.54, 10.47, true },
	{1910.71, -2335.42, 13.25, true },
	{-2175.83, 2427.19, 0.75, true },
	{2372.07, 505.63, 0.47, true },
	{2285.01, -2501.6, 0.61, true },
	{-11.01, -1656.07, 0.53, true },
}

-- Create the markers and blips

local loaded = false
local markers = {}
local blips = {}

function loadPumps()
	if(loaded) then return end
	loaded = true
	for i=1,#pumpsTable do
		local x, y, z = pumpsTable[i][1], pumpsTable[i][2], pumpsTable[i][3]
		local theMarker = createMarker ( x, y, z -1, "cylinder", 3.0, 135, 132, 134, 70 )
		addEventHandler ( "onClientMarkerHit", theMarker, onFuelPumpMarkerHit, false )
		addEventHandler ( "onClientMarkerLeave", theMarker, onFuelPumpMarkerLeave, false )
		
		--if ( pumpsTable[i][4] ) then exports.customblips:createCustomBlip ( x, y, 16, 16, "blip.png", 100 ) end
	end
end

function removePumps()
	if(loaded) then
		loaded = false
		for i, blip in ipairs(blips) do
			if(isElement(blip)) then destroyElement(blip) end
		end		
		for i, marker in ipairs(markers) do
			if(isElement(marker)) then destroyElement(marker) end
		end		
		blips = nil
		markers = nil
	end
end

function onPlayerJoinRoom(room)
	if(room == "cnr") then loadPumps() end
end
addEventHandler("onPlayerJoinRoom", localPlayer, onPlayerJoinRoom)

function onPlayerExitRoom(room)
	removePumps()
end
addEventHandler("onPlayerExitRoom", localPlayer, onPlayerExitRoom)

addEventHandler("onClientResourceStart",resourceRoot,
	function ()
		if ( getResourceFromName("USGaccounts") and getResourceState(getResourceFromName("USGaccounts")) == "running" and exports.USGaccounts:isPlayerLoggedIn()
		and getResourceFromName("USGrooms") and getResourceState(getResourceFromName("USGrooms")) == "running" and exports.USGrooms:getPlayerRoom() == "cnr") then
			loadPumps()
		end
	end
)