-------- SETTINGS THERE --------
local kamikaze_rate = 4000		-- spawning hydra rate 
local warning_size = 87.5			-- warning_size x warning_size is warning area for players, where will kamikaze drop
local warning_time = 4000		-- flashing area time before hydra spawn
--------------------------------


-- setting more const
local root = getRootElement()
warning_size = warning_size/2
local how_many = math.floor(160000 / kamikaze_rate)

addEvent("onMapStart")
addEventHandler("onMapStart", root, function()
	setTimer( function()
		local random_area_x = 3870 + math.random(0,140)
		local random_area_y = 1970 + math.random(0,140)
		local rdx = random_area_x - (random_area_x % warning_size)
		local rdy = random_area_y - (random_area_y % warning_size)
		local area = createRadarArea(rdx, rdy, warning_size, warning_size, 255,0,0,200)
		setRadarAreaFlashing(area, true)
		local kamikaze = createVehicle(520, random_area_x, random_area_y, 1000, 270, 0, math.random(0,360))
		setTimer( function()
			setElementPosition(kamikaze, random_area_x, random_area_y, 50)
			setElementVelocity(kamikaze, 0,0,-2)
		end, warning_time, 1)
		setTimer( function() 
			blowVehicle(kamikaze, true)
			setTimer( destroyElement, 2500, 1, area)
			setTimer( destroyElement, 2000, 1, kamikaze )
		end, warning_time+1, 1)
	end, kamikaze_rate, how_many)
	
end )


