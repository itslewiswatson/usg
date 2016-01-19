addEvent("USGcnr_skins.buySkin", true)
function onPlayerBuySkin(skin)
	local playerSkin = getPlayerGeneralSkin(client)
	if(playerSkin == skin) then
		exports.USGmsg:msg(client, "This is already your skin!", 255,0,0)
		return false
	end
	if(exports.USGcnr_money:buyItem(client, 150, "skin "..skin)) then
		setPlayerGeneralSkin(client, skin)
		triggerClientEvent(client, "USGcnr_skins.onSkinBought", client)
		if(not exports.USGcnr_jobs:doesPlayerHaveJobSkin(client)) then
			restorePlayerSkin(client)
		end
	end
end
addEventHandler("USGcnr_skins.buySkin", root, onPlayerBuySkin)

addEvent("USGcnr_skins.buyClothes", true)
function onPlayerBuyClothes(clothes)
	local totalPrice = 0
	local bareClothes = {}
	for slot=0,17 do
		local slotClothes = clothes[slot]
		if(slotClothes) then 
			totalPrice = totalPrice + slotClothes.price
			bareClothes[slot] = {slotClothes.tex, slotClothes.mod}
		end
	end
	if(exports.USGcnr_money:buyItem(client, totalPrice, "a new set of clothes")) then
		setPlayerCJClothes(client, bareClothes)
		triggerClientEvent(client, "USGcnr_skins.onClothesBought", client)
		if(getElementModel(client) == 0) then
			restorePlayerCJClothes(client)
		end
	end	
end
addEventHandler("USGcnr_skins.buyClothes", root, onPlayerBuyClothes)