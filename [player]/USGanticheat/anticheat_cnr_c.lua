--[[function addCrouchHandler()
    addEventHandler("onClientRender", root,
    function ()
    if(exports.USGrooms:getPlayerRoom() == "cnr") then
            if(getPedWeapon(localPlayer) == 24) then
                toggleControl("crouch", false)
                setControlState("crouch", false)
                if(isPedDucked(localPlayer)) then
                    setControlState("crouch", true)
                    setPedAnimation(localPlayer)
                end 
                toggledCrouch = true
            elseif(toggledCrouch) then
                toggleControl("crouch", true)
                toggledCrouch = false
            end
        end
    end
    )
end]]

addEventHandler("onClientResourceStart", resourceRoot,
    function ()
        if(getResourceFromName("USGaccounts") and getResourceState(getResourceFromName("USGaccounts")) == "running"
        and exports.USGaccounts:isPlayerLoggedIn(localPlayer)) then
            addCrouchHandler()
        else
            addEvent("onServerPlayerLogin", true)
            addEventHandler("onServerPlayerLogin", localPlayer, addCrouchHandler)                   
        end
    end
)