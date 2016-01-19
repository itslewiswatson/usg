local increases = {
    small = 15,
    medium = 30,
    large = 50,
    sprunk = 10,
}

--ShopsnTurfs= {
--[9] = 54,
--}

addEvent("USGcnr_foodshops.purchase", true)
function onPlayerPurchase(item)
    local maxHealth = exports.USG:getPedMaxHealth(client)
    local health = getElementHealth(client)
    if(health >= maxHealth-1) then
        exports.USGmsg:msg(client, "You don't need any more health!", 255, 0, 0)
        return false
    end
    local price = prices[item]
    local name =  "a "..(item ~= "sprunk" and (item.." menu") or "sprunk")
    if(exports.USGcnr_money:buyItem(client, price, name)) then
        setElementHealth(client, health+increases[item])
        exports.USGcnr_money:logTransaction(client, "bought a "..name.." for $"..price)
    end
    --   if (USGcnr_turfs:getTurfbyID(ShopsnTurfs[9]).ownerGroup == exports.USGcnr_groups:getPlayerGroup(client))then
    --  outputChatBox("This shop is owned by you sir")
    -- end
end
addEventHandler("USGcnr_foodshops.purchase", root, onPlayerPurchase)
