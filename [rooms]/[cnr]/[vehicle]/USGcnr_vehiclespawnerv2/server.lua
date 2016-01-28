local cars = {
-- [ID] = colsize --easier to change in case of vehicles getting stuck
-- NB when adding a new spawner check that the vehicle is listed here
[402] = 6,
[426] = 6,
[416] = 6,
[596] = 6,
[599] = 6,
[497] = 6,
[598] = 6,
[525] = 6,
[422] = 6,
[553] = 15,
[511] = 8,
[519] = 17, -- shamal
[487] = 8,
[403] = 7,
[515] = 7,
[468] = 3,
[574] = 7,
[485] = 6,
[453] = 11,
[597] = 6,
[448] = 6,
[433] = 8, -- Barracks
[427] = 6, -- Enforcer
[528] = 6, -- FBI Truck
[490] = 6, -- FBI Rancher
[523] = 6, -- HPV-1000
[432] = 10, -- Rhino
[601] = 6, -- S.W.A.T
[560] = 6, -- Sultan
[476] = 10, -- Rustler
[447] = 10, -- Sea Sparrow
[425] = 10, -- Hunter
[520] = 10, -- Hydra
[513] = 10, -- Stuntplane
[417] = 10, -- Leviathan
[548] = 10, -- cargobob
[500] = 6, -- Mesa
[470] = 6, -- Patriot
[471] = 6, -- quadbike
[541] = 6, -- bullet
[486] = 6, --Dozer
}

local spawners = {
--{x,y,z,rot,vehicleID,col,job}

    --LV Hosp
    {1626.224609375, 1850.3798828125, 10.651918411255, 180,402,nil},-- Buffalo
    {1620.431640625, 1850.3525390625, 10.563329696655, 180,426,nil},--Premiere
    {1590.8046875, 1819.12109375, 11.035227775574, 358.38223266602,416,nil,job = "medic"},--Ambulance  
    {1616.03125, 1806.146484375, 31.170415878296, 116.327,563,nil,job = "medic"},
    --LS Jefferson Hospital
    {2034.037109375, -1448.876953125, 16.98240852356, 90,402,nil},--Buffalo
    {2001.884765625, -1418.666015625, 16.735631942749, 180,426,nil},--Premiere
    {2001.2138671875, -1410.435546875, 17.143705368042,0,416,nil,job = "medic"},--Ambulance
    --LS ALl Saints Hospital
    {1177.2607421875, -1338.755859375, 14.062466621399, 272.92306518555,416,nil,job = "medic"},--Ambulance
    {1174.2216796875, -1310.2939453125, 13.822687149048, 270.02197265625,402,nil},--Buffalo
    {1174.2724609375, -1306.8740234375, 13.742555618286, 269.58242797852,426,nil},--Premier
     
    --SF Hospital
    {-2622.564453125, 607.7490234375, 14.602592468262, 90,416,nil,job = "medic"},--Ambulance
    {-2688.4111328125, 632.05078125, 14.249059677124, 180,402,nil},--Buffalo
    {-2682.1640625, 632.0751953125, 14.21791934967,180,426,nil},--Premier
    --LSPD
    {1584.1142578125, -1606.8544921875, 13.106273651123, 180,596,nil,job = "police"},--LSPD vehicle
    {1569.4150390625, -1606.845703125, 13.575127601624, 180,599,nil,job = "police"},-- Ranger
    {1566.3134765625, -1645.2138671875, 28.597248077393, 90,497,nil,job = "airsupport"},-- Police Mav
    --LVPD
    {2256.357421875, 2443.6591796875, 10.8203125, 0.04669189453125,598,nil,job = "police"},--LVPD veh
    {2269.1904296875, 2443.656875, 10.8203125, 0,599,nil,job="police"}, --ranger
    {2260.630859375, 2443.65939453125, 10.99203125, 0,598,nil,job = "police"}, --LVPD veh
    --- Mechanic LV
    {1958.7783203125, 2145.171875, 10.8203125, 0,525,nil,job = "Mechanic"}, --towtruck
    {1950.3974609375, 2145.1494140625, 10.8203125, 0,422,nil,job = "Mechanic"} ,-- bobcut
    {2383.1005859375, 1030.2451171875, 10.8203125, 270,422,nil,job = "Mechanic"}, 
    --- Pilot LV
    {1526.95703125, 1828.36328125, 12.8203125, 90,553,nil, job = "pilot"},
    {1433.654296875, 1645.119140625, 11.812978744507, 270,511,nil, job = "pilot"},
    {1281.658203125, 1361.41796875, 11.8203125, 270,519,nil,job = "pilot"},
    {1285.9677734375, 1399.58984375, 11.8203125, 270,487,nil,job = "pilot" },
    --- Trucker LV
    {1446.80859375, 975.34375, 11.967693901062, 0.75189208984,403,nil,job = "trucker"},
    {1434.0791015625, 975.343753125, 11.912976837158, 0,515,nil,job = "trucker"},
    -- crim LV
    {1820.537109375, 810.0224609375, 10.8203125, 270,468,nil,job = "criminal"},
    --montogery ls 
    {1238.8818359375, 339.736328125, 19.5546875, 270,402,nil},--buff
    -- mechanic dillimore
    {697.892578125, -467.5302734375, 16.34375, 270,422,nil,job = "Mechanic"},
    {705.4462890625, -454.521484375, 16.34375, 90,525,nil, job = "Mechanic"},
    --- police dillimore
    {624.1474609375, -609.490234375, 16.981948852539, 270,599,nil,job = "police"},
    {619.126953125, -596.9833984375, 17.233013153076, 270,596,nil,job = "police"},
   --- mechanic ls 
    {1049.111328125, -1031.337890625, 32.061866760254, 180,422,nil,job = "Mechanic"},
    {1037.373046875, -1031.2958984375, 32.039161682129, 180.80,525,nil,job = "Mechanic"},
    {2061.9716796875, -1879.9296875, 13.546875, 0,422,nil,job = "Mechanic"},
    --ls crim
    {1298.6591796875, -1064.1708984375, 29.275272369385, 270,468,nil,job="criminal"},
    --- trucker ls
    {2204.6572265625, -2236.501953125, 14.546875, 220.6,515,nil,job = "trucker"},
    {2208.900390625, -2223.9365234375, 14.546875, 220,403,nil,job = "trucker"},
    --- cleaner ls
    {1621.69140625, -1891.1923828125, 13.549010276794, 360,574,nil,job = "Street Cleaner"},
    ---ls trucker
    {-73.9248046875, -1115.8359375, 2.078125, 159.2,403,nil,job="trucker"},
    {1705.958984375, 1619.51171875, 9.8048543930054, 71.428558349609, 485,nil,job = "pilot"},
    {1974.669921875, -2233.1376953125, 13.087753295898, 180, 485,nil,job = "pilot"},
    {1991.220703125, -2388.6630859375, 14.446349143982, 204.51635742188, 487,nil,job = "pilot"},
    {2001.7880859375, -2494.9248046875, 14.460969924927, 86.901092529297, 519,nil,job = "pilot"},
    {728.4013671875, -1497.625, -0.34746506810188, 180, 453,nil,job = "Fisherman"},
    {738.646484375, -1495.9296875, -0.35091948509216, 180, 453,nil,job = "Fisherman"},
    {-1739.7763671875, 154.5322265625, 4.5382804870605, 179.91760253906, 515,nil,job = "trucker"},
    {-1917.1748046875, 284.6025390625, 40.928638458252, 181.84616088867, 525,nil,job = "Mechanic"},
    {-1400.3017578125, 2650.287109375, 55.876068115234, 93.230773925781, 599,nil,job = "police"},
    {-1503.83984375, 2525.4638671875, 55.519214630127, 1.4505615234375, 402, nil},
    {-306.3564453125, 1071.6171875, 19.569778442383, 269.31869506836, 426, nil},
    {-323.9873046875, 1069.0009765625, 19.890743255615, 4.6153869628906, 416,nil,job = "medic"},
    {1961.302734375, 2200.0078125, 10.536145210266, 269.84616088867, 468,nil,job = "criminal"},
    --{1961.302734375, 2200.0078125, 10.536145210266, 269.84616088867, 510, nil},
    {-84.3798828125, 1128.09765625, 19.619455337524, 181.75823974609, 525,nil,job = "Mechanic"},
    {-224.4296875, 996.2900390625, 19.727449417114, 271.54498291016, 599,nil,job = "police"},
    {-2170.4501953125, -2360.13671875, 30.817443847656, 50.417572021484, 599,nil,job = "police"},
    {68.8798828125, 30.394155502319, 53.582427978516, 597,nil,job = "police"},
    {2302.587890625, 2428.2958984375, 10.8203125, 181.80178833008, 426, nil},
    {-2186.10546875, -2307.4326171875, 30.774681091309, 140.61538696289, 416,nil,job = "medic"},
    {2096.53515625, -1797.474609375, 12.99011516571, 22.558013916016, 448,nil,job = "Pizza Delivery"},
    {381.3525390625, -1730.482421875, 8.0763454437256, 0.00274658203125, 468,nil,job = "criminal"},   
    {824, 830, 12, 0, 486, nil, job = "quarryMiner"},
  --- SFPD
    {-1599.29296875, 651.572265625, 7.18,0 ,597,nil,job = "police"},
    {-1610.7734375, 651.5722046875, 7.18,0,599,nil,job = "police"},
     ----------NG BASE
    {273.1533203125, 2036.064453125, 18.363571166992, 268.70330810547, 520,nil,job = "nationalguard"}, --hydra
    {276.396484375, 1977.9169921875, 18.345245361328, 270.63735961914, 476,nil,job = "nationalguard"}, --rustler
    {208.0390625, 1993.15234375, 20.432022094727, 359.69232177734,497,nil,job = "nationalguard"}, --police maverick
    {351.03125, 1932.9775390625, 20.769550323486, 89.802185058594,425,nil,job = "nationalguard"}, --hunter
    {207.4541015625, 1961.201171875, 21.845531463623, 359.9560546875,548,nil,job = "nationalguard"}, --Cargobob
    { 229.3125, 1877.6220703125, 17.649295806885, 0.30767822265625,432,nil,job = "nationalguard"}, --rhino
    {174.7158203125, 1936.4013671875, 18.193231582642, 178.41760253906,470,nil,job = "nationalguard"}, --patriot
    {167.8984375, 1938.15234375, 18.563920974731, 182.19779968262,500,nil,job = "nationalguard"}, --mesa
    { 192.2109375, 1903.861328125, 17.120859146118, 32.219787597656,471,nil,job = "nationalguard"}, --quadbike
    {182.3955078125, 1936.6376953125, 17.524379730225, 177.36260986328,541,nil,job = "nationalguard"}, --bullet
    {197.8125, 1878.3984375, 18.081888198853, 0.21978759765625,433,nil,job = "nationalguard"}, --barracks
    {336.0791015625, 1984.7587890625, 18.560224533081, 128.30770874023,519,nil,job = "nationalguard"}, --shamal
   
}

local vehicles = {}

local spawnedVehs = {}

local canDJV = {}

local function replaceVehicle(theColShape)
    if(theColShape == spawnedVehs[source].spawner[6])then
        placeVehicle(spawnedVehs[source].spawner)
        removeEventHandler("onElementColShapeLeave", source,replaceVehicle)
    end
end

function placeVehicle(spawner)
	local carId = spawner[5]
	if (not isElement(spawner[6])) then
		spawner[6] = createColSphere(spawner[1], spawner[2], spawner[3], cars[carId] or 6)
	end

	local vehicle = createVehicle(carId, spawner[1], spawner[2], spawner[3], 0, 0, spawner[4])
	spawnedVehs[vehicle] = {}
	spawnedVehs[vehicle].spawner = spawner
	setVehicleColor(vehicle, 1, 1, 1, 1)
	setElementFrozen(vehicle, true)
	--setElementCollisionsEnabled(vehicle,false)
	setVehicleDamageProof(vehicle, true)
	addEventHandler("onElementColShapeLeave", vehicle, replaceVehicle)

	addEventHandler("onElementColShapeHit", vehicle, 
		function (col)
			if (col == spawnedVehs[source].spawner[6]) then
				canDJV[source] = false
			end
		end
	)
	addEventHandler("onElementColShapeLeave", vehicle, 
		function (col)
			if (col == spawnedVehs[source].spawner[6]) then
				canDJV[source] = true
			end
		end
	)
	addEventHandler("onVehicleExplode", vehicle,
		function ()
			source:destroy()
		end
	)
	addEventHandler("onVehicleStartEnter", vehicle, 
		function (enteringPlayer, seat)
			if (exports.USGcnr_wanted:getPlayerWantedLevel(enteringPlayer) > 0 and seat == 0) then
				exports.USGmsg:msg(enteringPlayer, "You cannot take free a vehicle if you are wanted!", 255, 255, 255)
				cancelEvent()
			end
		end
	)
	addEventHandler("onVehicleEnter", vehicle, 
		function (player, seat)
			if(seat == 0)then
				if (isElement(vehicles[player]) and vehicles[player] ~= source) then
					destroyElement(vehicles[player])
				end
				vehicles[player] = source
				local r, g, b = player.team:getColor()
				if (isElement(vehicle)) then
					setVehicleColor(vehicle, r, g, b)
					setElementFrozen(vehicle, false)
					--setElementCollisionsEnabled(vehicle, true)
					setVehicleDamageProof(vehicle, false)
				end
			end	
		end
	)
	addEventHandler("onElementDestroy", vehicle, 
		function ()
			if (isElementWithinColShape(source, spawnedVehs[source].spawner[6])) then
				placeVehicle(spawner)
			end
		end
	)
	if (spawner.job) then
		addEventHandler("onVehicleStartEnter", vehicle, 
			function (enteringPlayer, seat)
				if (spawner.job ~= exports.USGcnr_jobs:getPlayerJob(enteringPlayer) and seat == 0 and exports.USGcnr_jobs:getPlayerJobType(enteringPlayer) ~= "staff") then
					exports.USGmsg:msg(enteringPlayer, "You need to be a "..spawner.job.." to use this vehicle", 255, 255, 255)
					cancelEvent()
				end
			end
		)
	end
	addEventHandler("onVehicleStartExit", vehicle, 
		function (exitingPlayer, seat)
			if (isElementWithinColShape(source, spawner[6]) and seat == 0) then
				cancelEvent()
				exports.USGmsg:msg(exitingPlayer, "You need to leave the area to get out of the vehicle", 255, 255, 255)
			end
		end
	)
	return vehicle
end

for _, v in ipairs(spawners) do
    placeVehicle(v)
end

function destroyVehicle()
    if (isElement(vehicles[source]))then
        destroyElement(vehicles[source])
        removeEventHandler("onPlayerWasted", source, destroyVehicle)
    end
end
addEventHandler("onPlayerWasted",root, destroyVehicle)
addEventHandler("onPlayerQuit", root, destroyVehicle)
addEventHandler("onPlayerExitRoom", root, destroyVehicle)

addEvent("onPlayerChangeJob", true)
function onChangeJob(player, ID)
    local currentPlrJob = exports.USGcnr_jobs:getPlayerJob(player)
    outputChatBox("Triggered job change", player)

    if (currentPlrJob ~= ID) then
    	outputChatBox("Not same, proceed", player)
	    if (isElement(vehicles[player]))then
	    	outputChatBox("Destroying...", player)
	        destroyElement(vehicles[player])
	        removeEventHandler("onPlayerWasted", player, destroyVehicle)
	    else
	    	outputChatBox("No vehicle found under this player in the table.", player)
	    end
	else
		outputChatBox("Same, something is wrong", player)
    end
end
addEventHandler("onPlayerChangeJob", root, onChangeJob)

addCommandHandler("djv",
	function (player)
		if (isElement(vehicles[player]) and canDJV[vehicles[player]])then 
			destroyElement(vehicles[player])
			removeEventHandler("onPlayerWasted", player, destroyVehicle)
			exports.USGmsg:msg(player, "Here is $10 for keeping the server clean! :)", 255, 255, 255)
			player:giveMoney(10)
		end
	end
)
