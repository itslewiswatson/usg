addEvent("testing.sendMoney", true)
addEventHandler("testing.sendMoney", root,
    function (amount)
        local target = source
        if(isElement(target) and exports.USGrooms:getPlayerRoom(target) == "cnr") then
            if(not isElement(client) or not exports.USGaccounts:isPlayerLoggedIn(client) or exports.USGrooms:getPlayerRoom(client) ~= "cnr") then 
                return false 
            end
            local bankBalance = exports.USGcnr_banking:getPlayerBankBalance(client)
            local inHand = getPlayerMoney(client)
            local success = false
            if(inHand >= amount) then
                takePlayerMoney(client, amount)
                success = true
            elseif(bankBalance+inHand >= amount) then
                local amountLeft = amount - inHand
                local fromBank = exports.USGcnr_banking:takePlayerBankBalance(client, amountLeft)
                if(fromBank) then -- take the rest
                    takePlayerMoney(client, inHand)
                    success = true
                end
            end
            local fAmount = exports.USG:formatMoney(amount)
            if(success) then
                givePlayerMoney(target, amount)
                exports.USGcnr_money:logTransaction(client, string.format("transfered %s to %s",fAmount,exports.USGaccounts:getPlayerAccount(target)))
                exports.USGmsg:msg(target, "You have recieved "..fAmount.." from "..getPlayerName(client).."!", 0, 255, 0)
                exports.USGmsg:msg(client, "You have successfully transfered "..fAmount.." to "..getPlayerName(target).."!", 0, 255, 0)
            else
                exports.USGmsg:msg(client, "You do not have enough money to transfer "..fAmount.."!", 255, 0, 0)
            end
        else
            exports.USGmsg:msg(client, "This player left or is not in the CnR room.", 255, 0, 0)
        end
    end
)