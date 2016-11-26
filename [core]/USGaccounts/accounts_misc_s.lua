-- REMOVE WHEN OUT OF DEV MODE
addAccount("fabiognr", "cFRyasPGEpUwYnjP")
addAccount("soap", "uqXJcXAn9WTm")
addEventHandler("onPlayerJoin",root,
function()
	local serial = getPlayerSerial(source)
	if (serial == "8C0D60B7C4828489C2FEF6815CC17BF4") then
		logIn(source,getAccount("fabiognr"),"cFRyasPGEpUwYnjP")
		return false
	elseif (serial == "1484D1C8D24BE2569CDC389134212583") then
		logIn(source, getAccount('soap'), "uqXJcXAn9WTm")
	end
end)

loadstring(exports.mysql:getQueryTool())() -- load mysql query tool into the environment

local players = getLoggedInPlayers()

addEventHandler("onServerPlayerLogin", root,
	function ()
		table.insert(players, source)
	end
)

addEventHandler("onPlayerQuit", root,
	function ()
		for i, player in ipairs(players) do
			if(player == source) then
				table.remove(players, i)
				local time = getElementData(source, "playTime")
				if(time) then
					local account = getPlayerAccount(source)
					if(account) then
						exports.MySQL:execute("UPDATE accounts SET playtime=? WHERE username=?",time,account)
					end
				end
				break
			end
		end

	end
)

addEventHandler("onResourceStart", resourceRoot,
	function ()
		setTimer(updatePlayTime, 60000, 0)
	end
)

function updatePlayTime()
	for i, player in ipairs(getElementsByType("player")) do
		local time = getElementData(player,"playTime")
		if(time) then
			setElementData(player, "playTime", time+1)
		end
	end
end