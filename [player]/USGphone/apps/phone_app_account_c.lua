class 'accountApp' 'app'

function accountApp:accountApp()
	app.app(self, "Account", "images/apps/account_icon.png")
	self.GUI = {}
end

function accountApp:open()
	if(not isElement(self.GUI.user)) then
		self.GUI.userLabel = exports.USGGUI:createLabel(screenWidth, screenHeight, PHONE_SCREEN_WIDTH-2, 25, false, "Username:")
		self.GUI.user = exports.USGGUI:createEditBox(screenWidth, screenHeight, PHONE_SCREEN_WIDTH-2, 25, false, "")
		Phone:addRelativeGUI(self, self.GUI.userLabel, 1,1)
		Phone:addRelativeGUI(self, self.GUI.user, 1,26)
		self.GUI.passLabel = exports.USGGUI:createLabel(screenWidth, screenHeight, PHONE_SCREEN_WIDTH-2, 25, false, "Password:")
		self.GUI.pass = exports.USGGUI:createEditBox(screenWidth, screenHeight, PHONE_SCREEN_WIDTH-2, 25, false, "",nil,nil,nil,true)
		Phone:addRelativeGUI(self, self.GUI.passLabel, 1,51)
		Phone:addRelativeGUI(self, self.GUI.pass, 1,76)
		self.GUI.newPassLabel = exports.USGGUI:createLabel(screenWidth, screenHeight, PHONE_SCREEN_WIDTH-2, 25, false, "New password:")
		self.GUI.newPass = exports.USGGUI:createEditBox(screenWidth, screenHeight, PHONE_SCREEN_WIDTH-2, 25, false, "",nil,nil,nil,true)
		Phone:addRelativeGUI(self, self.GUI.newPassLabel, 1,111)
		Phone:addRelativeGUI(self, self.GUI.newPass, 1,136)
		self.GUI.updatePass = exports.USGGUI:createButton(screenWidth,screenHeight,110,25,false,"Update password")
		addEventHandler("onUSGGUISClick", self.GUI.updatePass, function () AccountApp:updatePass() end, false)		
		Phone:addRelativeGUI(self, self.GUI.updatePass, math.floor((PHONE_SCREEN_WIDTH-110)/2),165)
		self.GUI.newEmailLabel = exports.USGGUI:createLabel(screenWidth, screenHeight, PHONE_SCREEN_WIDTH-2, 25, false, "New email:")
		self.GUI.newEmail = exports.USGGUI:createEditBox(screenWidth, screenHeight, PHONE_SCREEN_WIDTH-2, 25, false, "")
		Phone:addRelativeGUI(self, self.GUI.newEmailLabel, 1,200)
		Phone:addRelativeGUI(self, self.GUI.newEmail, 1,225)
		self.GUI.updateEmail = exports.USGGUI:createButton(screenWidth,screenHeight,110,25,false,"Update email")
		addEventHandler("onUSGGUISClick", self.GUI.updateEmail, function () AccountApp:updateEmail() end, false)
		Phone:addRelativeGUI(self, self.GUI.updateEmail, math.floor((PHONE_SCREEN_WIDTH-110)/2),255)
	else
		for k, element in pairs(self.GUI) do
			exports.USGGUI:setVisible(element, true)
		end
	end
end

function accountApp:close()
	for k, element in pairs(self.GUI) do
		exports.USGGUI:setVisible(element, false)
	end
end

function accountApp:getInput()
	local user = exports.USGGUI:getText(self.GUI.user)
	local pass = exports.USGGUI:getText(self.GUI.pass)
	if(#user == 0) then
		exports.USGmsg:msg("Enter your username.", 255, 0, 0)
		return false
	elseif(#pass == 0) then
		exports.USGmsg:msg("Enter your password.", 255, 0, 0)
		return false
	end
	return user,pass
end

function accountApp:updatePass()
	local user, pass = self:getInput()
	if(user) then
		local newPass = exports.USGGUI:getText(self.GUI.newPass)
		if(#newPass < 6) then
			exports.USGmsg:msg("Your password must be 6 characters long.", 255, 0, 0)
			return
		end
		triggerServerEvent("USGphone.changePassword", localPlayer, user, pass, newPass)
	end
end

function accountApp:updateEmail()
	local user, pass = self:getInput()
	if(user) then
		local newEmail = exports.USGGUI:getText(self.GUI.newEmail)
		if(#newEmail < 4) then
			exports.USGmsg:msg("Your email must be 4 characters long.", 255, 0, 0)
			return
		end
		triggerServerEvent("USGphone.changeEmail", localPlayer, user, pass, newEmail)
	end
end