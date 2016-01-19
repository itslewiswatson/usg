local flagID = 2993
local TimeToStayInMarker = 1000 * 60 * 2
local prize = 5000
local prizeTime = 1000 * 60 * 5

local shops = {
--{interior,dimension,x,y,z,OwnerPlayer,marker}
{10,9,377.8837890625, -59.509765625, 1001.5078125,nil},
{10,8,377.8837890625, -59.509765625, 1001.5078125,nil},
{5,11,378.1083984375, -114.572265625, 1001.4921875,nil},
{9,11,380.12890625, -8.7041015625, 1001.8515625,nil},
{5,10,378.1083984375, -114.572265625, 1001.4921875,nil},
{10,7,377.8837890625, -59.509765625, 1001.5078125,nil},
{5,9,378.1083984375, -114.572265625, 1001.4921875,nil},
{9,10,380.12890625, -8.7041015625, 1001.8515625,nil},
{10,6,377.8837890625, -59.509765625, 1001.5078125,nil},
{9,9,380.12890625, -8.7041015625, 1001.8515625,nil},
{10,5,377.8837890625, -59.509765625, 1001.5078125,nil},
{5,8,378.1083984375, -114.572265625, 1001.4921875,nil},
{9,8,380.12890625, -8.7041015625, 1001.8515625,nil},
}

local timer = {}

function getPlayerOwnedShop(player)
	for k,v in ipairs(shops)do
		if(v[6] == player)then
		return shops[k]
		end
	end
	return false
end

addEventHandler("onPlayerAttemptExitRoom",root,function(room)
	if(room == "cnr")then
		if(getPlayerOwnedShop(source))then
		local shop = getPlayerOwnedShop(source)
			setMarkerColor(shop[7],255,255,255,255)
			shop[6] = nil
		end
	end
end)

function payPlayer(player)
	if(isElement(player) and exports.USGcnr_groups:getPlayerGroup(player))then
	local playerGroup = exports.USGcnr_groups:getPlayerGroup(player)
	local groupPlayerOnline = 0
		for id, p in ipairs(getElementsByType("player")) do
				if(exports.USGcnr_groups:getPlayerGroup(p) == playerGroup)then
				groupPlayerOnline = groupPlayerOnline + 1
				end
		end
		for id, p in ipairs(getElementsByType("player")) do
				if(exports.USGcnr_groups:getPlayerGroup(p) == playerGroup)then
				givePlayerMoney(p,math.floor(prize / groupPlayerOnline))
				exports.USGmsg:msg(p, "You earned "..math.floor(prize / groupPlayerOnline).."$ from "..getPlayerName(player).."'s shop!",255,0,0)
				end
		end
	else 
		if(isTimer(timer[player]))then
		killTimer(timer[player])
		end
	end
end

function onShopOwnerChange(player)
timer[player] = setTimer( payPlayer,prizeTime,0,player)
	addEventHandler("onPlayerExitRoom",player,function()
		if(isTimer(timer[player]))then
			killTimer(timer[player])
		end
	end)
end

function setPlayerOwnedShop(player,shop)
	if(exports.USGcnr_groups:getPlayerGroup(player) and not getPlayerOwnedShop(player))then
			shop[6] = player
			local r,g,b = exports.USGcnr_groups:getGroupColor(exports.USGcnr_groups:getPlayerGroup(player))
			setMarkerColor(shop[7],r,g,b,255)
				if(timer[shops[6]])then
				killTimer(timer[shops[6]])
				end
			onShopOwnerChange(player)
	else exports.USGmsg:msg(player, "You need to be part of a group to takeover a shop",255,0,0)
	end
end

function getShop(marker)
	for k,v in ipairs(shops)do
		if(v[7] == marker)then
		return shops[k]
		end
	end
	return false
end

addEventHandler ( "onResourceStart", resourceRoot, function()
	for k,v in ipairs(shops)do
		local flag = createObject(flagID,v[3],v[4],v[5] )
		local marker = createMarker(v[3],v[4],v[5] - 0.8 ,"cylinder", 1,255,255,255)
		addEventHandler( "onMarkerHit", marker, onHitMarker )
		setElementInterior(flag,v[1])
		setElementInterior(marker,v[1])
		setElementDimension(flag,v[2])
		setElementDimension(marker,v[2])
		v[7] = marker
	end
end)

function liberateShop(player,shop)
	local shopOwner = shop[6]
		if(timer[shopOwner])then
			if(shopOwner ~= player)then
				killTimer(timer[shopOwner])
				exports.USGmsg:msg(shopOwner, "Your shop has been liberated by law enforcement",255,0,0)
				exports.USGmsg:msg(player, "Thank you for liberating this store here is "..prize.."$",255,0,0)
				givePlayerMoney(player,prize)
				setMarkerColor(shop[7],255,255,255,255)
				shop[6] = nil
			else exports.USGmsg:msg(player, "You cannot liberate your own shop",255,0,0)
			end
		end
end

function onHitMarker(hitElement)
local shop = getShop(source)
local shopOwner = shop[6]
local hitMarker = source
	if(getElementInterior(hitElement) == shop[1] and getElementDimension(hitElement) == shop[2] and exports.USGrooms:getPlayerRoom(hitElement) == "cnr")then
				if(exports.USGcnr_jobs:getPlayerJobType(hitElement) == "criminal")then
					if(exports.USGcnr_groups:getPlayerGroup(hitElement))then
						if(exports.USGcnr_groups:getPlayerGroup(hitElement) ~= exports.USGcnr_groups:getPlayerGroup(shopOwner))then
							if(not getPlayerOwnedShop(hitElement))then
								setTimer( function ()
									if(isElementWithinMarker (hitElement,hitMarker))then
											setPlayerOwnedShop(hitElement,shop)
									end
								end,TimeToStayInMarker,1)
							else exports.USGmsg:msg(hitElement, "You already own a shop",255,0,0)
							end
						else  exports.USGmsg:msg(hitElement, "You cannot interact with a shop already owned by a member of your group",255,0,0)
						end
					else exports.USGmsg:msg(hitElement, "You need to be part of a group to take over a shop",255,0,0)
					end	
				elseif(exports.USGcnr_jobs:getPlayerJobType(hitElement) == "police")then
					if(exports.USGcnr_groups:getPlayerGroup(hitElement) ~= exports.USGcnr_groups:getPlayerGroup(shopOwner))then
						setTimer( function ()
							if(isElementWithinMarker (hitElement,hitMarker) and shopOwner)then
								liberateShop(hitElement,shop)
							end
						end,TimeToStayInMarker,1)
					else  exports.USGmsg:msg(hitElement, "You cannot interact with a shop already owned by a member of your group",255,0,0)
					end
				end
	end
end