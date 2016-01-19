local sandboxEventHandlers = {}
local sandboxTimers = {}
local sandboxElements = {}
local sandboxBoundKeys = {}
local sandboxResourceRoot = createElement("resource")
local sandboxOnStartHandlers = {}
local sandboxOnStopHandlers = {}
_addEventHandler = addEventHandler
_createVehicle = createVehicle
_createMarker = createMarker
_setTimer = setTimer
_killTimer = killTimer
_removeEventHandler = removeEventHandler
_bindKey = bindKey
_unbindKey = unbindKey
_engineLoadDFF = engineLoadDFF
_engineLoadTXD = engineLoadTXD
_engineLoadCOL = engineLoadCOL
_dxCreateShader = dxCreateShader
_getResourceRootElement = getResourceRootElement
local dummyFunc = function ( ) end

local safeEnvironment = {
	addEventHandler = function (...)
		local args = {...}
		if(args[1] == "onClientResourceStart") then
			table.insert(sandboxOnStartHandlers, args[3])
			return true
		elseif(args[1] == "onClientResourceStop") then
			table.insert(sandboxOnStopHandlers, args[3])
			return true
		else
			local result = _addEventHandler(...)
			if(result) then
				local handler = {event = args[1], element = args[2], func = args[3]}
				table.insert(sandboxEventHandlers, handler)
			end
			return result
		end
	end,
	removeEventHandler = function (...)
		local args = {...}
		for i, handler in ipairs(sandboxEventHandlers) do
			if(handler.event == args[1] and handler.element == args[2] and handler.func == args[3]) then
				return _removeEventHandler(...)
			end
		end
	end,
	setTimer = function (...)
		local timer = _setTimer(...)
		table.insert(sandboxTimers, timer)
		return timer
	end,
	killTimer = function ( ... )
		local success = _killTimer(...)
		if(success) then
			local tTimer = ({...})[1]
			for i, timer in ipairs(sandboxTimers) do
				if(timer == tTimer) then
					table.remove(sandboxTimers, i)
					break
				end
			end
		end
		return success
	end,
	createVehicle = function ( ... )
		local veh = _createVehicle(...)
		if(veh) then
			setElementDimension(veh, exports.USGrooms:getRoomDimension(exports.USGrooms:getPlayerRoom() or "dm") or getElementDimension(localPlayer))
			table.insert(sandboxElements, veh)
		end
		return veh
	end,
	createMarker = function ( ... )
		local marker = _createMarker(...)
		if(marker) then
			setElementDimension(marker, exports.USGrooms:getRoomDimension(exports.USGrooms:getPlayerRoom() or "dm") or getElementDimension(localPlayer))
			table.insert(sandboxElements, marker)
		end
		return marker
	end,
	bindKey = function ( ... )
		local args = {...}
		if(args[1] == "lshift") then
			args[1] = "lalt"
		end
		local success = _bindKey( unpack(args) )
		if(success) then
			table.insert(sandboxBoundKeys, { key = args[1], state = args[2], target = args[3]})
		end
		return success
	end,
	unbindKey = function ( ... )
		local success = _unbindKey( ... )
		if(success) then
			local args = { ... }
			for i, boundKey in ipairs(sandboxBoundKeys) do
				if(boundKey.key == args[1] and boundKey.state == args[2] and boundKey.target == args[3]) then
					table.remove(sandboxBoundKeys, i)
					break
				end
			end
		end
		return success
	end,
	engineLoadDFF = dummyFunc--[[function ( ... )
		local args = {...}
		args[1] = "maps/"..loadedMap.name.."/"..args[1]	
		local element = _engineLoadDFF(unpack(args))
		if(element) then
			table.insert(sandboxElements, element)
		end
		return element
	end]],
	engineLoadTXD = dummyFunc--[[function ( ... )
		local args = {...}
		args[1] = "maps/"..loadedMap.name.."/"..args[1]
		local element = _engineLoadTXD(unpack(args))
		if(element) then
			table.insert(sandboxElements, element)
		end
		return element
	end]],
	engineLoadCOL = dummyFunc--[[function ( ... )
		local args = {...}
		args[1] = "maps/"..loadedMap.name.."/"..args[1]
		local element = _engineLoadCOL(unpack(args))
		if(element) then
			table.insert(sandboxElements, element)
		end
		return element
	end]],
	dxCreateShader = function ( ... )
		local args = {...}
		args[1] = "maps/"..loadedMap.name.."/"..args[1]	
		local element = _dxCreateShader(unpack(args))
		if(element) then
			table.insert(sandboxElements, element)
		end
	end,
	resourceRoot = sandboxResourceRoot,
	getResourceRootElement = function ( res )
		if(res == resource) then
			return sandboxResourceRoot
		else
			return _getResourceRootElement(res)
		end
	end,
	addCommandHandler = dummyFunc,
	--engineImportTXD = dummyFunc,
	--engineReplaceModel = dummyFunc,
	outputChatBox = dummyFunc,
	setRadioChannel = dummyFunc,
	dxDrawText = dummyFunc,
	createProjectile = dummyFunc,
	playSound = dummyFunc,
	playSound3D = dummyFunc,
	setSoundVolume = dummyFunc,
	stopSound = dummyFunc,
	showCursor = dummyFunc,
	engineImportTXD = dummyFunc,
	engineReplaceModel = dummyFunc,
	engineReplaceCOL = dummyFunc,
}

local safeVariables = {
"setElementVelocity","getElementVelocity","setElementRotation","getElementRotation",
"setElementModel", "getElementModel","getDistanceBetweenPoints2D", "getDistanceBetweenPoints3D",
"getThisResource", "getRootElement","isElementOnGround","isElementInWater",
"getLocalPlayer","localPlayer","root","resource","isVehicleOnGround","isPedInVehicle",
"guiGetScreenSize","setCloudsEnabled", "setFogDistance", "setFarClipDistance","getPedOccupiedVehicle",
"getBoundKeys","pairs","ipairs","error","isPlayerDead","isPedDead","getElementHealth","setElementHealth",
--[["engineImportTXD","engineReplaceModel","engineReplaceCOL",]]"cancelEvent","dxSetShaderValue",
"getElementPosition","setElementPosition","engineSetModelLODDistance","getElementType",
"getElmentDimension","setElementDimension","getVersion","math"
}

for i, func in ipairs(safeVariables) do
	safeEnvironment[func] = _G[func]
end

function applySafeEnvironment(env)
	for k, v in pairs(safeEnvironment) do
		env[k] = v
	end
	return env
end

function onEnvironmentLoaded(env)
	for i, func in ipairs(sandboxOnStartHandlers) do
		pcall(func)
	end
end

function onDestroyEnvironment(env)
	for i, func in ipairs(sandboxOnStopHandlers) do
		pcall(func)
	end
	for i, boundKey in ipairs(sandboxBoundKeys) do
		_unbindKey(boundKey.key, boundKey.state, boundKey.target)
	end
	for i, handler in ipairs(sandboxEventHandlers) do
		_removeEventHandler(handler.event, handler.element, handler.func)
	end
	for i, element in ipairs(sandboxElements) do
		if(isElement(element)) then
			destroyElement(element)
		end
	end
	for i, timer in ipairs(sandboxTimers) do
		if(isTimer(timer)) then
			_killTimer(timer)
		end
	end
	sandboxEventHandlers = {}
	sandboxTimers = {}
	sandboxElements = {}
	sandboxBoundKeys = {}
	sandboxOnStartHandlers = {}
	sandboxOnStopHandlers = {}
end