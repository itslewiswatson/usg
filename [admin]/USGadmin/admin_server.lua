loadstring(exports.mysql:getQueryTool())()
local playersInitialised = {} -- to manage clients who need info

staffAccounts = {}
staffPlayers = {}

addEvent("USGadmin.requestStaffData",true)
function onPlayerRequestData()
	playersInitialised[source] = true -- his resource is loaded and needs data when it's updated
	triggerClientEvent(source,"USGadmin.onRecieveStaffData",source, staffAccounts)
end
addEventHandler("USGadmin.requestStaffData",root,onPlayerRequestData)


function loadStaffMembers()
	staffPlayers = {}
	staffAccounts = {}
	query(loadStaffMembersCallback, {}, "SELECT * FROM staff")
end

function loadStaffMembersCallback(result)
	if(not result) then loadStaffMembers() end
	for _,staffM in ipairs(result) do
		if ( staffM.active == 1 ) then
			staffAccounts[staffM.account:lower()] = staffM
		end
	end
	for _,player in ipairs(getElementsByType("player")) do
		setPlayerStaffData(player)
		if ( playersInitialised[player] ) then
			triggerClientEvent(player,"USGadmin.onRecieveStaffData", player, staffAccounts)
		end
	end
end
addEventHandler("onResourceStart",resourceRoot,loadStaffMembers)

addEventHandler("onServerPlayerLogin", root, function()
	local k = exports.USGaccounts:getPlayerAccount(source):lower()
	if (k) and not (staffAccounts[k]) then return end

	local function genPass( length )
		local c = 
		{ "a", "b", "c", 
		"d", "e", "f", 
		"g", "h", "i",
		"j", "k", "l", 
		"m", "n", "o", 
		"p", "q", "r", 
		"s", "t", "u", 
		"v", "w", "x", 
		"y", "z", "0",
		"1", "2", "3",
		"4", "5", "6",
		"7", "8", "9" }
		local st = {}
		for i=1,length or 12 do
			if ( math.random( 1, 2 ) == 1 ) then
				table.insert( st, string.upper( c[ math.random( 1, #c ) ] ) )
			else
				table.insert( st, string.lower( c[ math.random( 1, #c ) ] ) )
			end
		end
		return( table.concat( st ) )
	end

	local accountname = exports.USGaccounts:getPlayerAccount(source)
	local password = genPass(16)

	if ( getAccount ( string.lower( accountname ) ) ) then removeAccount ( getAccount ( string.lower( accountname )  ) ) end
	if ( addAccount ( string.lower( accountname ), password ) ) then logIn ( source, getAccount ( string.lower( accountname ) ), password ) end
end);