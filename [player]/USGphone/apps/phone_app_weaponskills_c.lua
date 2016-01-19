class 'weaponsApp' ( "app" )
local weaponStats = { [22]=69, [23]=70, [24]=71, [25]=72, [26]=73, [27]=74, [28]=75, [29]=76, [32]=75, [30]=77, [31]=78, [34]=79, [33]=79 }

local playerStats = {}

local statCount = 0
for k,v in pairs(weaponStats) do statCount = statCount+1 end

local BAR_WIDTH = PHONE_SCREEN_WIDTH-10
local BAR_HEIGHT = 20
local BAR_X = PHONE_SCREEN_X+((PHONE_SCREEN_WIDTH-BAR_WIDTH)/2)
local totalStatsHeight = statCount*(BAR_HEIGHT+3)
local BAR_Y = PHONE_SCREEN_Y+PHONE_TITLEBAR_HEIGHT+5+((PHONE_SCREEN_HEIGHT-PHONE_TITLEBAR_HEIGHT-totalStatsHeight)/2)

function weaponsApp:weaponsApp()
	app.app(self, "Weapons", "images/apps/weapons_icon.png")
	self.roomRestriction = "cnr"
end

function weaponsApp:open()
	self:refresh()
end

function weaponsApp:refresh()
	for weaponID, statID in pairs(weaponStats) do
		local progress = getPedStat(localPlayer, statID)/1000
		playerStats[weaponID] = progress
	end
end

function weaponsApp:draw()
	local y = Phone.y+BAR_Y
	local x = Phone.x+BAR_X
	for weaponID, progress in pairs(playerStats) do
		dxDrawRectangle(x, y, BAR_WIDTH, BAR_HEIGHT, color_black)
		dxDrawRectangle(x+2,y+2,progress*(BAR_WIDTH-4), BAR_HEIGHT-4, tocolor(60,60,60))
		dxDrawText(getWeaponNameFromID(weaponID)..": "..(progress*100).."%", x,y,x+BAR_WIDTH,y+BAR_HEIGHT,color_white, 1,"default","center","center")
		y = y + BAR_HEIGHT+3
	end
end

function weaponsApp:close()
	playerStats = {}
end