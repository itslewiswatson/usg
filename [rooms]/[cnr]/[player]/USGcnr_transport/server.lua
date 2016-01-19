addEvent("USGcnr.transport.onPlayerWarp",true)
addEventHandler("USGcnr.transport.onPlayerWarp", root,
	function (price)
		takePlayerMoney(client, price)
	end
)