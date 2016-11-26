local version = "1.0" --default version

addEventHandler("onResourceStart",resourceRoot,
function()
	setGameType("USG V"..version)
	exports.system:logNotice("[System V"..version.."] System is loading...")
	
	setMinuteDuration(60000)
	local realtime = getRealTime()
	setTime(realtime.hour,realtime.minute)
end)

addEventHandler("onResourceStop",resourceRoot,
function()
	--Kick everyone to prevent rollback!--
	exports.system:logNotice("System shutting down...")
	for _,player in ipairs(getElementsByType("player")) do
		--kickPlayer(player,"System","System shutting down / restarting.") -- OFF for debug
	end
end)