---------------------------------------------------------------------
-- Project: irc
-- Author: MCvarial
-- Contact: mcvarial@gmail.com
-- Version: 1.0.3
-- Date: 31.10.2010
---------------------------------------------------------------------

local server
local channel

------------------------------------
-- Ads
------------------------------------
addEventHandler("onClientResourceStart",resourceRoot,
	function ()
		triggerServerEvent("onIRCPlayerDelayedJoin",getLocalPlayer())
	end
)
addEvent("showAd",true)
addEventHandler("showAd",root,
	function (serv,chan,duration)

	end
)