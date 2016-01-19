addEventHandler("onServerPlayerLogin",localPlayer,
	function ()
		triggerServerEvent("USGadmin.requestRules",localPlayer)
		triggerServerEvent("USGadmin.requestStaffData",localPlayer)
	end
)

addEventHandler("onClientResourceStart",resourceRoot,
	function ()
		if ( getResourceFromName("USGaccounts") and getResourceState(getResourceFromName("USGaccounts")) == "running" and exports.USGaccounts:isPlayerLoggedIn() ) then
			triggerServerEvent("USGadmin.requestRules",localPlayer)
			triggerServerEvent("USGadmin.requestStaffData",localPlayer)
		end
	end
)