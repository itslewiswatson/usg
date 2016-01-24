function isPlayerPremium()
	if (not localPlayer:getData("p") or not exports.USGaccounts:isPlayerLoggedIn(localPlayer) ) then
		return true
	end
	return false
end
