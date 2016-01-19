function getVehicleSellPrice(price, player) -- bought price, player
	if not isElement(player) then
		player = localPlayer
	end
	local sellPrice = ( price * 0.9 )
	if exports.USGpremium:isPlayerPremium(player) then
		sellPrice = ( price * 0.99 )
	end
	return math.floor(sellPrice)
end