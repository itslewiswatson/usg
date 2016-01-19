local _showCursor = showCursor
local cursorStates = {}
function showCursor(k, state)
	cursorStates[k] = state
	for k, cState in pairs(cursorStates) do
		if(cState ~= state and state == false) then
			return 
		end
	end
	_showCursor(state)
end

staffAccounts = {}
staffPlayers = {}

addEvent("USGadmin.onRecieveStaffData",true)
function onReceiveStaffData(accounts)
	staffAccounts = accounts
	for _,player in ipairs(getElementsByType("player")) do
		setPlayerStaffData(player)
	end
end
addEventHandler("USGadmin.onRecieveStaffData",root,onReceiveStaffData)