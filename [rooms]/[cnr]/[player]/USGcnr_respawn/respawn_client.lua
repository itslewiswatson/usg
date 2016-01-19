-- constants
screenWidth,screenHeight = guiGetScreenSize()
button_height = 40
button_width = 125
button_spacer = 20
button_y = (screenHeight-30)/2

function onLocalPlayerWasted(killer)
	if(exports.USGrooms:getPlayerRoom() ~= "cnr") then return end
	local players = getElementsByType("player")
	if isElement(killer) then
		exports.USGmsg:msg("Watching your killer: "..getPlayerName(killer).." who has "..math.floor(getElementHealth(killer) or 0).." health left.",255,255,0)
		setCameraTarget(killer)
	end
	fadeOutTimer = setTimer(fadeCamera,2000,1,false,3)
end

addEventHandler("onClientPlayerWasted",localPlayer,onLocalPlayerWasted)

function cancelDamage()
	cancelEvent()
end

addEvent("onClientPlayerReSpawn",true)
function onLocalPlayerSpawn()
	setTimer(fadeCamera,500,1,true,3)
	setTimer(setCameraTarget,250,1,localPlayer)
	addEventHandler("onClientPlayerDamage",localPlayer,cancelDamage)
end

addEventHandler("onClientPlayerReSpawn",localPlayer,onLocalPlayerSpawn)

addEvent("onClientSpawnProtectionEnd",true)
function onSpawnProtectionEnd()
	removeEventHandler("onClientPlayerDamage",localPlayer,cancelDamage)
end
addEventHandler("onClientSpawnProtectionEnd",localPlayer,onSpawnProtectionEnd)

local spawnGUI = {}
local spawnOptions = {}
local autoChooseTimer
local updateButtonTimer
local timeLeft
local defaultOption

addEvent("onSpawnOfferChoices",true)
function offerSpawnChoices(choices)
	local roomStartX = (screenWidth-#choices*(button_width+button_spacer)-(button_spacer*2))/2
	local defaultSet
	timeLeft = 5
	for i=1,#choices do
		local x = roomStartX+(i-1)*(button_width+button_spacer)-button_spacer 
		local button = exports.USGgui:createButton(x,button_y,button_width,button_height,false,choices[i].name)
		addEventHandler("onUSGGUISClick",button,onClickChoice, false)
		if choices[i].default == true and not defaultSet then
			defaultOption = i
		end
		table.insert(spawnGUI,button)
	end
	if not defaultOption then defaultOption = 1 end
	updateButtonTimer = setTimer(updateButtonTime,1000,5)	
	showCursor(true)
	spawnOptions = choices
end
addEventHandler("onSpawnOfferChoices",root,offerSpawnChoices)

function onClickChoice(btn,state)
	local choice
	for i=1,#spawnGUI do
		if spawnGUI[i] == source then
			choice = spawnOptions[i]
			break
		end
	end
	if ( choice ) then
		 makeChoice(choice)		
	end
end

function makeChoice(choice)
	fadeCamera(false)
	if isTimer(autoChooseTimer) then killTimer(autoChooseTimer) end
	if isTimer(updateButtonTimer) then killTimer(updateButtonTimer) end
	triggerServerEvent("onSpawnClickChoice",localPlayer,choice, timeLeft or 0)
	for i=1,#spawnGUI do
		destroyElement(spawnGUI[i])
	end
	spawnGUI = {}
	spawnOptions = {}
	showCursor(false)
end

function updateButtonTime()
	timeLeft = math.max(0,timeLeft - 1)
	if defaultOption then
		if timeLeft < 1 and defaultOption then
			makeChoice(spawnOptions[defaultOption])
			return
		end
		local button = spawnGUI[defaultOption]
		local name = spawnOptions[defaultOption].name
		exports.USGGUI:setText(button,name.."["..timeLeft.."]")
	end
end