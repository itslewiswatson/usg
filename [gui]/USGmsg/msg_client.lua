local DURATION = 3500
local BOX_HEIGHT = 20
local FADE_TIME = 550
local MAX_MSG = 3
local OUTPUT_CONSOLE = true

-- manage settings

function loadSetting(setting,value,new)
	if ( setting == "USGmsg.duration" and type(value) == "number" ) then
		if ( value >= 1 ) then
			DURATION = value*1000 --seconds to ms
			if ( new ) then
				msg("Example of new setting(s)")
			end
		else
			msg("Duration must be at least 1 second.",255,0,0)
		end
	elseif ( setting == "USGmsg.boxheight" and type(value) == "number" ) then
		if ( value >= 20 ) then
			BOX_HEIGHT = value
			if ( new ) then
				msg("Example of new setting(s)")
			end
		else
			msg("Box height must be at least 20.",255,0,0)
		end
	elseif ( setting == "USGmsg.fadetime" and type(value) == "number" ) then
		FADE_TIME = value
		if ( new ) then
			msg("Example of new setting(s)")
		end
	elseif ( setting == "USGmsg.maxmessages" and type(value) == "number" ) then
		MAX_MSG = value
		if ( new ) then
			msg("Example of new setting(s)")
		end
	elseif ( setting == "USGmsg.outputconsole" ) then
		OUTPUT_CONSOLE = value
	end
end
addEventHandler("onPlayerSettingChange", localPlayer, function(a,b) loadSetting(a,b,true) end)

function onResourceStart(res)
	if ( getResourceFromName("USGplayersettings") == res ) then
		loadSettings() 
		removeEventHandler("onClientResourceStart",root,onResourceStart) 
	end
end

function loadSettings()
	if ( not getResourceFromName("USGplayersettings")) then
		addEventHandler("onClientResourceStart", root,onResourceStart)
	else
		exports.USGplayersettings:addSetting("USGmsg.duration",3.5,
			{ guiType = "slider", category = "GUI", description = "Set how long to show messages in seconds", args = {{1,10},true, 2} })
		exports.USGplayersettings:addSetting("USGmsg.boxheight",20,
			{ guiType = "slider", category = "GUI", description = "Set how high the message boxes are in pixels", args = {{20,50},true, 2} })
		exports.USGplayersettings:addSetting("USGmsg.fadetime",550,
			{ guiType = "slider", category = "GUI", description = "Set how long fading a message is in miliseconds", args = {{50,2000},true} })	
		exports.USGplayersettings:addSetting("USGmsg.maxmessages",3,
			{ guiType = "slider", category = "GUI", description = "Set how many messages to display at once", args = {{1,2,3,4,5},true} })
		exports.USGplayersettings:addSetting("USGmsg.outputconsole",true,
			{ guiType = "check", category = "GUI", description = "Set whether to output messages to the console ( F8 )" })
		loadSetting("USGmsg.duration",exports.USGplayersettings:getSetting("USGmsg.duration"))
		loadSetting("USGmsg.boxheight",exports.USGplayersettings:getSetting("USGmsg.boxheight"))
		loadSetting("USGmsg.fadetime",exports.USGplayersettings:getSetting("USGmsg.fadetime"))
		loadSetting("USGmsg.maxmessages",exports.USGplayersettings:getSetting("USGmsg.maxmessages"))
		loadSetting("USGmsg.outputconsole",exports.USGplayersettings:getSetting("USGmsg.outputconsole"))
	end
end
addEvent("onServerPlayerLogin", true)
addEventHandler("onServerPlayerLogin", localPlayer, loadSettings)
addEventHandler("onClientResourceStart", resourceRoot,
	function()
		if( getResourceFromName("USGaccounts") and getResourceState(getResourceFromName("USGaccounts")) == "running"
		and exports.USGaccounts:isPlayerLoggedIn()) then
			loadSettings()
		end
	end
)

-- messages
addEvent("USGmsg.newMsg", true)

local messages = {}

local sX,sY = guiGetScreenSize()

function msg(text,r,g,b,duration)
	if(OUTPUT_CONSOLE and text) then
		outputConsole(text)
	end
	for i=1,#messages do
		if ( text == messages[i].text ) then
			messages[i].duration = duration or DURATION
			if ( messages[i].startTick ) then
				messages[i].startTick = getTickCount()
				messages[i].endTick = messages[i].startTick+messages[i].duration		
			end
			messages[i].count = messages[i].count + 1
			return false
		end
	end
	local r,g,b,duration = r or 255, g or 255, b or 255, tonumber(duration) or DURATION
	if ( text and type(text) == "string" or type(text) =="number" ) then
		local text = tostring(text)
		table.insert(messages,{text=text, color = {r,g,b,255},bgalpha=220, duration=duration, y = math.min(#messages*BOX_HEIGHT,3*BOX_HEIGHT), count = 1})
	end
end
addEventHandler("USGmsg.newMsg",root,msg)

function onRender()
	if(#messages > 0) then
		processMessages()
		onDraw()
	end
end
addEventHandler("onClientHUDRender",root,onRender)

function processMessages()
	local i = 1
	for _=1,#messages do
		local rem
		if ( ( not messages[i].fadeStart ) and i <= MAX_MSG ) then
			messages[i].fade = "in"
			messages[i].fadeStart = getTickCount()
		end
		if ( not messages[i].startTick and i == 1 ) then
			messages[i].startTick = getTickCount()
			messages[i].endTick = messages[i].startTick+messages[i].duration			
		end
		if ( messages[i].endTick and messages[i].endTick <= getTickCount() and not messages[i].fade ) then
			messages[i].fade = "out"
			messages[i].fadeStart = getTickCount()
		end
		if ( messages[i].fade ) then
			local relTick = getTickCount() - messages[i].fadeStart
			local progress = relTick/FADE_TIME
			local fade = messages[i].fade
			if ( progress >= 1 ) then
				messages[i].fade = false
				if ( fade == "out" ) then
					table.remove(messages,i)
					i = i -1
					rem = true
				end
			else
				if ( messages[i].fade == "out" ) then progress = 1-progress end
				messages[i].color[4] = progress*255
				messages[i].bgalpha = progress*220
			end
		end
		if ( not rem and i <= MAX_MSG and messages[i].y > (i-1)*BOX_HEIGHT ) then
			messages[i].y = math.max((i-1)*BOX_HEIGHT,messages[i].y-3)
		end
		i = i+1
	end
end

function onDraw()
	for i=1,math.min(MAX_MSG,#messages) do
		dxDrawRectangle(0,math.max((i-1)*BOX_HEIGHT,messages[i].y),sX,BOX_HEIGHT,tocolor(0,0,0,messages[i].bgalpha), false)
		dxDrawText(messages[i].text,0,math.max((i-1)*BOX_HEIGHT,messages[i].y),sX-20,messages[i].y+BOX_HEIGHT,
			tocolor(unpack(messages[i].color)),1,"default","center","center",false,false,true,true)
		if(messages[i].count > 1) then -- draw number of messages with same text
			dxDrawText("( "..messages[i].count.." )", sX-20,math.max((i-1)*BOX_HEIGHT,messages[i].y),sx,messages[i].y+BOX_HEIGHT, tocolor(255,255,0), 1, "default", "center", "center",false,false,true,true)
		end
	end
end