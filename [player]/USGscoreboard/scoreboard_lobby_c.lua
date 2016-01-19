lobby = {}

function lobby.isPlayerLoggedIn(player)
	return exports.USGaccounts:isPlayerLoggedIn(player) and "Yes" or "No"
end

roomColumns["lobby"] = {
	{ "Logged in", lobby.isPlayerLoggedIn },
}
