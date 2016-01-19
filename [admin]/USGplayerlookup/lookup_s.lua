loadstring(exports.MySQL:getQueryTool())()
local lookupID = 0
local accountNick = {}
local accountLastLogin = {}

addEvent("onPlayerLookupComplete")
function getAccountNick(account)
	return accountNick[account]
end

function getAccountLastSeen(account)
	return accountLastLogin[account]
end

addEventHandler("onResourceStart", resourceRoot,
	function ()
		query(loadAccounts, {}, "SELECT loginnick,loginaccount,max(logindate) FROM logins GROUP BY(loginaccount)")
	end
)

function loadAccounts(result)
	for i, login in ipairs(result) do
		accountNick[login.loginaccount] = login.loginnick
		accountLastLogin[login.loginaccount] = login["max(logindate)"]
	end
end

addEvent("onServerPlayerLogin")
addEventHandler("onServerPlayerLogin", root,
	function ()
		local account = exports.USGAccounts:getPlayerAccount(source)
		accountNick[account] = getPlayerName(source)
		accountLastLogin[account] = exports.USG:getDateTimeString()
	end
)