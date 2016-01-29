local weponblocker = {}--записывает тик

local blocketime = { --ид оружия и время задержки в мс
	[24]=570, -- Deagle
}

addEventHandler("onClientResourceStart",getResourceRootElement(getThisResource()),
	function()
		toggleControl("fire", true)
	end
)

addEventHandler("onClientResourceStop",getResourceRootElement(getThisResource()),
	function()
		toggleControl("fire", true)
	end
)

addEventHandler("onClientPlayerWeaponFire",localPlayer, --эвент на выстрел из пушки. записывает тик и отрубает кнопку стрельбы
	function(weapon, ammo, ammoInClip, hitX, hitY, hitZ, hitElement)
		if(blocketime[weapon]) then
			weponblocker[weapon] = getTickCount()
			toggleControl("fire", false)
		end
	end
)

addEventHandler("onClientPlayerWeaponSwitch",localPlayer,--эвент на смену слота. если во время задержки игрок сменил оружие, то стрельба врубается и тик не сбрасывается, а считается дальше.
	function(prevSlot, newSlot)--                                если при возвращении на "тиковый" слот время не вышло, то кнопка стрельбы вновь вырубается
		local wpn = getPedWeapon(localPlayer, newSlot)
		if(weponblocker[wpn]) then
			if((getTickCount() - weponblocker[wpn]) < blocketime[wpn]) then
				toggleControl("fire", false)
			else
				if(not isControlEnabled("fire")) then toggleControl("fire", true) end
				weponblocker[wpn] = nil
			end
		else
			if(not isControlEnabled("fire")) then toggleControl("fire", true) end
		end		
	end
)


addEventHandler("onClientRender",getRootElement(),--собственно, считает тики, а когда время выходит, то сбрасывает его и врубает контрол
	function()
		local wpn = getPedWeapon(localPlayer)
		if(weponblocker[wpn]) then
			if((getTickCount() - weponblocker[wpn]) > blocketime[wpn]) then
				if(not isControlEnabled("fire")) then toggleControl("fire", true) end
				weponblocker[wpn] = nil
			--else
				--dxDrawRectangle(0,700,100, 100, tocolor(155,0,0))   --технический прогрессбар для просмотра времени задержки
				--dxDrawRectangle(0,700,((getTickCount() - weponblocker[wpn])/blocketime[wpn])*100, 100, tocolor(255,0,0))
			end
		end
	end
)