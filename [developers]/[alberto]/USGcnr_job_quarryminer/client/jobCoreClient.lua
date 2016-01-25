--Locations of C4 plants
local c4Plants = {
	[1] = {697.09375, 903.54730, -39.88151},
	[2] = {641.20074, 957.58807, -35.19804},
	[3] = {692.69903564453, 729.64056396484, -7.1828298568726},
}

--Rocks that appear when C4 has blown
local blownRocks = {
	--first number represents the number in c4Plants, so make sure they match
	[1] = {	
			--Put locations of rocks that spawn here
			{696.55475, 892.05286, -39.79272},
			{697.27277, 900.74719, -39.85195},
			{691.76123, 902.57916, -40.24347},
		},

	[2] = {
			{637.54663, 955.77673, -35.46286},
			{639.12158, 952.84076, -35.72335},
			{643.44617, 954.09894, -35.44550},
		},

	[3] = {
			{698.24224853516, 733.69323730469, -6.7209587097168},
			{690.13671875, 733.80010986328, -6.3384227752686},
			{691.41143798828, 736.74859619141, -5.8814177513123},
			{691.92498779297, 732.10241699219, -6.7438073158264},
		},
}

--Tables
local rockMarkers = {}
local rockBlips = {}
local rocks = {}

--timer and marker variables
local processMarker = nil
local processBlip = nil
local blowTimer = nil
local processingTimer = nil
local decreaseBlowTime = nil

--Value and boolean variables
local localPlr = getLocalPlayer()
local jobActive = false
local randomNumber = 0
local rocksCollected = 0
local amountOfRocks = 0
local currentProcessingProgress = 0
local dxVariable = 0
local isRendering = false
local blowTime = 6

local screenW, screenH = guiGetScreenSize()

--Renders the rocks the player has got and the processing progress
function renderDX()
	if (isRendering) then
		if (dxVariable == 1) then
		    dxDrawText("Timer: " .. blowTime, (screenW * 0.8680) - 1, (screenH * 0.3945) - 1, (screenW * 0.9805) - 1, (screenH * 0.4349) - 1, tocolor(0, 0, 0, 255), 2.00, "default-bold", "center", "center", false, false, false, false, false)
		    dxDrawText("Timer: " .. blowTime, (screenW * 0.8680) + 1, (screenH * 0.3945) - 1, (screenW * 0.9805) + 1, (screenH * 0.4349) - 1, tocolor(0, 0, 0, 255), 2.00, "default-bold", "center", "center", false, false, false, false, false)
		    dxDrawText("Timer: " .. blowTime, (screenW * 0.8680) - 1, (screenH * 0.3945) + 1, (screenW * 0.9805) - 1, (screenH * 0.4349) + 1, tocolor(0, 0, 0, 255), 2.00, "default-bold", "center", "center", false, false, false, false, false)
		    dxDrawText("Timer: " .. blowTime, (screenW * 0.8680) + 1, (screenH * 0.3945) + 1, (screenW * 0.9805) + 1, (screenH * 0.4349) + 1, tocolor(0, 0, 0, 255), 2.00, "default-bold", "center", "center", false, false, false, false, false)
		    dxDrawText("Timer: " .. blowTime, screenW * 0.8680, screenH * 0.3945, screenW * 0.9805, screenH * 0.4349, tocolor(255, 255, 255, 255), 2.00, "default-bold", "center", "center", false, false, false, false, false)
		elseif (dxVariable == 2) then
		    dxDrawText("Rocks: " .. rocksCollected .. "/" .. amountOfRocks, (screenW * 0.8680) - 1, (screenH * 0.3945) - 1, (screenW * 0.9805) - 1, (screenH * 0.4349) - 1, tocolor(0, 0, 0, 255), 2.00, "default-bold", "center", "center", false, false, false, false, false)
		    dxDrawText("Rocks: " .. rocksCollected .. "/" .. amountOfRocks, (screenW * 0.8680) + 1, (screenH * 0.3945) - 1, (screenW * 0.9805) + 1, (screenH * 0.4349) - 1, tocolor(0, 0, 0, 255), 2.00, "default-bold", "center", "center", false, false, false, false, false)
		    dxDrawText("Rocks: " .. rocksCollected .. "/" .. amountOfRocks, (screenW * 0.8680) - 1, (screenH * 0.3945) + 1, (screenW * 0.9805) - 1, (screenH * 0.4349) + 1, tocolor(0, 0, 0, 255), 2.00, "default-bold", "center", "center", false, false, false, false, false)
		    dxDrawText("Rocks: " .. rocksCollected .. "/" .. amountOfRocks, (screenW * 0.8680) + 1, (screenH * 0.3945) + 1, (screenW * 0.9805) + 1, (screenH * 0.4349) + 1, tocolor(0, 0, 0, 255), 2.00, "default-bold", "center", "center", false, false, false, false, false)
		    dxDrawText("Rocks: " .. rocksCollected .. "/" .. amountOfRocks, screenW * 0.8680, screenH * 0.3945, screenW * 0.9805, screenH * 0.4349, tocolor(255, 255, 255, 255), 2.00, "default-bold", "center", "center", false, false, false, false, false)
		elseif (dxVariable == 3) then
		    dxDrawText("Processing: " .. currentProcessingProgress .. "%", (screenW * 0.3977) - 1, (screenH * 0.3867) - 1, (screenW * 0.5891) - 1, (screenH * 0.4362) - 1, tocolor(0, 0, 0, 255), 2.00, "default-bold", "center", "center", false, false, false, false, false)
		    dxDrawText("Processing: " .. currentProcessingProgress .. "%", (screenW * 0.3977) + 1, (screenH * 0.3867) - 1, (screenW * 0.5891) + 1, (screenH * 0.4362) - 1, tocolor(0, 0, 0, 255), 2.00, "default-bold", "center", "center", false, false, false, false, false)
		    dxDrawText("Processing: " .. currentProcessingProgress .. "%", (screenW * 0.3977) - 1, (screenH * 0.3867) + 1, (screenW * 0.5891) - 1, (screenH * 0.4362) + 1, tocolor(0, 0, 0, 255), 2.00, "default-bold", "center", "center", false, false, false, false, false)
		    dxDrawText("Processing: " .. currentProcessingProgress .. "%", (screenW * 0.3977) + 1, (screenH * 0.3867) + 1, (screenW * 0.5891) + 1, (screenH * 0.4362) + 1, tocolor(0, 0, 0, 255), 2.00, "default-bold", "center", "center", false, false, false, false, false)
		    dxDrawText("Processing: " .. currentProcessingProgress .. "%", screenW * 0.3977, screenH * 0.3867, screenW * 0.5891, screenH * 0.4362, tocolor(255, 255, 255, 255), 2.00, "default-bold", "center", "center", false, false, false, false, false)
		end
	end
end

-- *** initializing and unloading ***
function initJob()
	if (exports.USGrooms:getPlayerRoom() == "cnr") then
		exports.USGcnr_jobs:addJob(jobID, jobType, occupation, jobDescription, jobMarkers, jobSkins, jobVehicleMarkers, jobBlip)
	end
end

addEvent("onPlayerJoinRoom", true)
addEventHandler("onPlayerJoinRoom", localPlayer, 
	function (room)
		if (room == "cnr") then
			initJob()
		end
	end
)

addEventHandler("onClientResourceStart", resourceRoot,
	function () -- init job if thisResource started, or if USGcnr_jobs (re)started
		initJob()
	end
)

-- *** job loading ***
local miners = {}
addEvent("onPlayerChangeJob", true)
function onChangeJob(ID)
	if (ID == jobID) then
		if (not miners[localPlayer]) then
			miners[localPlayer] = true
			outputChatBox("Get inside a #FFFF00Dozer", 255, 255, 255, true)

			if (jobActive == false) then
				addEventHandler("onClientVehicleEnter", root, startJob)
			end
		end
	else
		clearData()
		miners[localPlayer] = false
	end
end
addEventHandler("onPlayerChangeJob", localPlayer, onChangeJob)

addEvent("onPlayerExitRoom", true)
addEventHandler("onPlayerExitRoom", localPlayer, 
	function (prevRoom)
		if (prevRoom == "cnr") then
			clearData()
		end
	end
)

addCommandHandler("setjob", 
	function()
		outputChatBox("Job set", 255, 255, 0)
		outputChatBox("Spawn and get inside a #FFFF00Dozer", 255, 255, 255, true)
		if (jobActive == false) then
			addEventHandler("onClientVehicleEnter", root, startJob)
		end
	end
)

function startJob(player, seat)
	if (player == localPlr) then
		if (seat == 0) then	
			local vehModel = getElementModel(source)
			if (vehModel == 486) then
				jobActive = true
				removeEventHandler("onClientVehicleEnter", root, startJob)
				createNewLocation()
			end
		end
	end
end

--Clears all the data for when the player quits, has finished the job or resigns
function clearData()
	jobActive = false
	amountOfRocks = 0
	rocksCollected = 0
	randomNumber = 0
	currentProcessingProgress = 0
	dxVariable = 0
	blowTime = 6
	removeEventHandler("onClientRender", root, renderDX)

	if (isElement(blowMarker)) then
		destroyElement(blowMarker)
		blowMarker = nil
	end

	if (isElement(blowBlip)) then
		destroyElement(blowBlip)
		blowBlip = nil
	end

	if (isElement(c4Object)) then
		destroyElement(c4Object)
		c4Object = nil
	end

	if (isTimer(blowTimer)) then
		killTimer(blowTimer)
		blowTimer = nil
	end

	if (isTimer(processingTimer)) then
		killTimer(processingTimer)
		processingTimer = nil
	end

	if (isTimer(decreaseBlowTime)) then
		killTimer(decreaseBlowTime)
		decreaseBlowTime = nil
	end

	for i,markers in pairs(rockMarkers) do
		if (isElement(markers)) then
			destroyElement(markers)
		end
	end

	for i,blips in pairs(rockBlips) do
		if (isElement(blips)) then
			destroyElement(blips)
		end
	end

	for i,rockObj in pairs(rocks) do
		if (isElement(rockObj)) then
			destroyElement(rockObj)
		end
	end

	if (isElement(processMarker)) then
		destroyElement(processMarker)
		processMarker = nil
	end

	if (isElement(processBlip)) then
		destroyElement(processBlip)
		processBlip = nil
	end

	--if (isElementFrozen(localPlr)) then
		--setElementFrozen(localPlr, false)

	if (isCursorShowing()) then
		showCursor(false, false)
	end

	if (getPedOccupiedVehicle(localPlr)) then
		setElementFrozen(getPedOccupiedVehicle(localPlr), false)
	end
	--end

	rockMarkers = {}
	rockBlips = {}
end
addEventHandler("onClientPlayerQuit", root, clearData)
addEventHandler("onClientPlayerWasted", root, clearData)

function cancelJob(player, seat)
	clearData()
	removeEventHandler("onClientVehicleEnter", root, startJob)

	outputChatBox("You quit, job has canceled", 255, 255, 0)
end
addCommandHandler("quitjob", cancelJob)

--Creates a new location to plant the C4
function createNewLocation()
	randomNumber = math.random(#c4Plants)

	blowMarker = createMarker(c4Plants[randomNumber][1], c4Plants[randomNumber][2], c4Plants[randomNumber][3], "cylinder", 2, 255, 0, 0)
	blowBlip = createBlipAttachedTo(blowMarker, 0, 2, 255, 0, 0)
	outputChatBox("Go to the #FF0000marker #FFFFFFand plant an explosive.", 255, 255, 255, true)
	addEventHandler("onClientMarkerHit", blowMarker, blowUp)
end

--Function to handle the planting and blowing up of the C4
function blowUp(player)
	if (player == localPlr and isElement(localPlr)) then
		if (not isPedInVehicle(localPlr)) then
			c4Object = createObject(1654, c4Plants[randomNumber][1], c4Plants[randomNumber][2], c4Plants[randomNumber][3])
			destroyElement(blowMarker)
			outputChatBox("Planted explosive, please move away from the area!", 255, 255, 255)
			isRendering = true
			addEventHandler("onClientRender", root, renderDX)
			dxVariable = 1

			decreaseBlowTime = setTimer(function()
					blowTime = blowTime - 1
				end
			, 1000, 0)

			blowTimer = setTimer(function()
				blowTime = blowTime - 1
				createExplosion(c4Plants[randomNumber][1], c4Plants[randomNumber][2], c4Plants[randomNumber][3], 11, true, -1.0, false)
				destroyElement(c4Object)
				killTimer(decreaseBlowTime)
				createRocks()
				outputChatBox("Explosive has blown! Get into your #FFFF00Dozer #FFFFFFand pick up the #FF0000Rocks#FFFFFF!", 255, 255, 255, true)
			end, (blowTime * 1000), 1)
		end
	end
end

--Creates the rocks that spawn once C4 has exploded
function createRocks()
	destroyElement(blowBlip)
	dxVariable = 2

	--for a,b in pairs(blownRocks) do
		if (blownRocks[randomNumber]) then
			amountOfRocks = #blownRocks[randomNumber]
			for k,v in pairs(blownRocks[randomNumber]) do
				local rock = createObject(3929, v[1], v[2], v[3])
				setElementCollisionsEnabled(rock, false)
				local rockMarker = createMarker(v[1], v[2], v[3], "cylinder", 2, 0, 0, 0, 0)
				local rockBlip = createBlipAttachedTo(rockMarker, 0, 1, 255, 0, 0)
				rockMarkers[rockMarker] = rockMarker
				rocks[rockMarker] = rock
				rockBlips[rockMarker] = rockBlip
				addEventHandler("onClientMarkerHit", rockMarker, collectBlownRocks)
			end
		end
	--end
end

--Function to handle the collection of the rocks
function collectBlownRocks(player)
	if (isPedInVehicle(localPlr) and isElement(localPlr) and player == localPlr) then
		if (getElementModel(getPedOccupiedVehicle(localPlr)) == 486) then
			destroyElement(rockMarkers[source])
			destroyElement(rockBlips[source])
			destroyElement(rocks[source])
			rocksCollected = rocksCollected + 1
			if (rocksCollected == amountOfRocks) then
				createProcessing()
			end
		end
	end
end

--Creates the processing marker
function createProcessing()
	processMarker = createMarker(632.40137, 893.42865, -43.96094, "cylinder", 4, 255, 255, 0, 255)
	processBlip = createBlipAttachedTo(processMarker, 0, 2, 255, 255, 0)

	outputChatBox("Go to the #FFFF00processing marker", 255, 255, 255, true)

	addEventHandler("onClientMarkerHit", processMarker, processRocks)
end

--Function to handle the processing and final part of the job
function processRocks(player)
	if (player == localPlr and isElement(localPlr)) then
		local veh = getPedOccupiedVehicle(localPlr)
		if (getElementModel(veh) == 486) then
			dxVariable = 3
			--outputChatBox("Processing finished!", 255, 255, 0)
			--triggerServerEvent("payPlayer", localPlr, amountOfRocks)
			--clearData()
			--setTimer(createNewLocation, 2000, 1)

			if (isTimer(processingTimer)) then
				killTimer(processingTimer)
			end

			setElementFrozen(veh, true)
			--setElementFrozen(localPlr, true)
			showCursor(true, true)

			processingTimer = setTimer(
				function()
					currentProcessingProgress = currentProcessingProgress + 1
					if (currentProcessingProgress == 100) then
						if (isRendering) then
							removeEventHandler("onClientRender", root, renderDX)
						end
						setElementFrozen(veh, false)
						setElementFrozen(localPlr, false)
						killTimer(processingTimer)
						outputChatBox("Processing finished!", 255, 255, 0)
						triggerServerEvent("payPlayer", localPlr, amountOfRocks)
						showCursor(false, false)
						clearData()
						setTimer(createNewLocation, 2000, 1)
					end
				end
			, 500, 0)
		end
	end
end

addCommandHandler("fre", 
	function()
		showCursor(false, false)
		setElementFrozen(getPedOccupiedVehicle(localPlr), false)
	end
)

addCommandHandler("pos",
	function()
		local x, y, z = getElementPosition(localPlayer)
		outputChatBox(x .. ", " .. y .. ", " .. z)
	end
)