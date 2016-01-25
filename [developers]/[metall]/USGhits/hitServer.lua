local hits = {}
local blip = {}

function placeHit(plr, cmd, target, amount)
	local target = findPlayer(target)
	if (target) then
		if (hits[target]) then return end
		local amount = math.floor(amount)
		if (amount < 10000) then
			outputChatBox("You have to enter something greater than $10,000", plr, 255, 0, 0)
			return
		end
		if (amount > 100000) then
			outputChatBox("You have to enter something smaller than $100,000", plr, 255, 0, 0)
			return
		end
		if (exports.USGadmin:getPlayerStaffLevel(plr) >= 2) then
			hits[target] = amount
			setElementData(target, "hit", true)
			outputChatBox("A hit has been placed on "..getPlayerName(target).." kill him to get $"..amount, root, 255, 255, 0)
			if (not isElement(blip[target])) then
				local int, dim = getElementInterior(target), getElementDimension(target)
				blip[target] = createBlipAttachedTo(target, 41)
				setElementInterior(blip[target], int)
			end
		end
	end
end
addCommandHandler("placehit", placeHit)

function onWasted(ammo, killer)
	if (hits[source] ~= false and getElementData(source, "hit")) then
		if (source ~= killer) then
			local pay = hits[source]
			givePlayerMoney(killer, pay)
			if (isElement(blip[source])) then
				destroyElement(blip[source])
			end
			hits[source] = false
			setElementData(source, "hit", false)
			outputChatBox(getPlayerName(killer).." has killed "..getPlayerName(source).." and has gotten $"..pay, root, 255, 255, 0)
		else
			if (isElement(blip[source])) then
				destroyElement(blip[source])
			end
			hits[source] = false
			setElementData(source, "hit", false)
			outputChatBox(getPlayerName(source).." has killed himself. Hit event cancelled!", root, 200, 0, 0)
		end
	end
end
addEventHandler("onPlayerWasted", root, onWasted)

function onQuit()
	if (hits[source] ~= false and getElementData(source, "hit")) then
		if (isElement(blip[source])) then destroyElement(blip[source]) end
		outputChatBox("The hit event has been cancelled due to "..getPlayerName(source).." quiting!", root, 200, 0, 0)
	end
end
addEventHandler("onPlayerQuit", root, onQuit)

function findPlayer(name, plr)
	if (not name) then return end
	local matches = {}
	for ind, plr2 in pairs(getElementsByType("player")) do
		if (getPlayerName(plr2) == name) then
			return plr2
		end
		if (getPlayerName(plr2):lower():find(name:lower())) then
			table.insert(matches, plr2)
		end
	end
	if (#matches == 1) then
		return matches[1]
	else
		return false
	end
	return false
end