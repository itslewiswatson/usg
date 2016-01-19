addEvent("onPlayerJoinRoom", true)
addEvent("onPlayerExitRoom", true)

function onPlayerSetWeather(cmd, arg1)
	local id = tonumber(arg1)
	if(id) then
		setWeather(id)
	else
		exports.USGmsg:msg("You need to specify a weather ID", 255, 0, 0)
	end
end


local added = false
function init()
	if(not added) then
		added = true
		addCommandHandler("weather", onPlayerSetWeather)
	end
end

function remove()
	if(added) then
		added = false
		removeCommandHandler("weather", onPlayerSetWeather)
	end
end

addEventHandler("onClientResourceStart", resourceRoot,
	function ()
		if(getResourceFromName("USGrooms") and getResourceState(getResourceFromName("USGrooms")) == "running"
		and exports.USGrooms:getPlayerRoom() == "cnr") then
			init()
		end
	end
)

addEventHandler("onPlayerJoinRoom", localPlayer,
	function ()
		init()
	end
)

addEventHandler("onPlayerExitRoom", localPlayer,
	function ()
		remove()
		setWeather(0)
	end
)

addCommandHandler( "Reload weapon",
	function()
		local task = getPedSimplestTask( localPlayer )
		
		if ( ( task == "TASK_SIMPLE_JUMP" or task == "TASK_SIMPLE_IN_AIR" or task == "TASK_SIMPLE_LAND" ) and not doesPedHaveJetPack( localPlayer ) ) then return end
		
		if ( isControlEnabled( "jump" ) ) then
			toggleControl( "jump", false )
			addEventHandler( "onClientRender", root, enableJump )
		end
		
		triggerServerEvent( "onPlayerReloadWeapon", localPlayer )
	end
)

bindKey( "r","down","Reload weapon" )

local frames = 0

function enableJump()
	if (frames >= 3) then
		toggleControl("jump", true)
		removeEventHandler("onClientRender", root, enableJump)
		frames = 0
	else
		frames = frames + 1
	end
end