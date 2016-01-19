loadstring(exports.MySQL:getQueryTool())()

addEvent("USGphone.changePassword", true)
addEvent("USGphone.changeEmail", true)
addEventHandler("USGphone.changePassword", root,
	function (user, pass, newPass)
		local account = exports.USGaccounts:getPlayerAccount(client)
		if(user ~= account) then
			exports.USGmsg:msg(client, "This is not your username!", 255, 0, 0)
			return 
		elseif(#newPass < 6) then
			exports.USGmsg:msg(client, "New password is too short! Must have minimum length of 6.", 255, 0, 0)
			return
		end
		local hashedPass = exports.USGaccounts:hash(account, pass)
		singleQuery(changePasswordCallback, {client,newPass},"SELECT password FROM accounts WHERE username=? AND password=?",account,hashedPass)
	end
)

function changePasswordCallback(result, player, newPass)
	if(not isElement(player)) then return end
	if(result) then
		local account = exports.USGaccounts:getPlayerAccount(player)
		if(account) then
			local hashedPass = exports.USGaccounts:hash(account, newPass)
			exports.MySQL:execute("UPDATE accounts SET password=? WHERE username=?",hashedPass, account)
			exports.USGmsg:msg(player, "Your password has been changed.", 0, 255, 0)
		end
	else
		exports.USGmsg:msg(player, "Invalid password!", 255, 0, 0)
	end
end

addEventHandler("USGphone.changeEmail", root,
	function (user, pass, email)
		local account = exports.USGaccounts:getPlayerAccount(client)
		if(user ~= account) then
			exports.USGmsg:msg(client, "This is not your username!", 255, 0, 0)
			return 
		elseif(#email < 4) then
			exports.USGmsg:msg(client, "New email is too short! Must have minimum length of 4.", 255, 0, 0)
			return
		end
		local hashedPass = exports.USGaccounts:hash(account, pass)
		singleQuery(changeEmailCallback, {client,email},"SELECT 1 FROM accounts WHERE username=? AND password=?",account,hashedPass)
	end
)

function changeEmailCallback(result, player, email)
	if(not isElement(player)) then return end
	if(result) then
		local account = exports.USGaccounts:getPlayerAccount(player)
		exports.MySQL:execute("UPDATE accounts SET email=? WHERE username=?",email, account)
		exports.USGmsg:msg(player, "Your email has been changed.", 0, 255, 0)
	else
		exports.USGmsg:msg(player, "Invalid password!", 255, 0, 0)
	end
end