class 'app'

function app:app(name, icon, quickBar)
	self.name = name
	self.icon = icon
	self.opened = false
	self.roomRestriction = false
	self.quickBar = quickBar == true
	table.insert(Phone.apps, self)
	return self
end

function app:open()

end

function app:draw()

end

function app:close()

end

function app:refresh()

end

addEventHandler("onPhoneCreated", localPlayer,
	function ()
		MessageApp = messageApp()
		PhoneApp = phoneApp()
		GPSApp = gpsApp()
		WeaponsApp = weaponsApp()
		MoneyApp = moneyApp()
		AccountApp = accountApp()
		MusicApp = musicApp()
	end
)