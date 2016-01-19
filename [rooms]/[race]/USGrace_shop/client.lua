local raceshopGUI = {}

function createRaceshopGUI()
    exports.USGGUI:setDefaultTextAlignment("left","center")
    raceshopGUI.window = exports.USGGUI:createWindow("center","center", 600, 600, false,"Race Shop System")
    
    raceshopGUI.color = exports.USGGUI:createImage("left","top",200,100,false,":USGrace_shop/files/color.png",raceshopGUI.window)
    raceshopGUI.nitrous = exports.USGGUI:createImage("center","top",200,100,false,":USGrace_shop/files/nitrous.png",raceshopGUI.window)
    raceshopGUI.flip = exports.USGGUI:createImage("right","top",200,100,false,":USGrace_shop/files/flip.png",raceshopGUI.window)
    raceshopGUI.inv = exports.USGGUI:createImage("left",150,200,100,false,":USGrace_shop/files/inv.png",raceshopGUI.window)
    raceshopGUI.map = exports.USGGUI:createImage("center",150,200,100,false,":USGrace_shop/files/map.png",raceshopGUI.window)
    raceshopGUI.spikes = exports.USGGUI:createImage("right",150,200,100,false,":USGrace_shop/files/spikes.png",raceshopGUI.window)
    raceshopGUI.missiles = exports.USGGUI:createImage("left",300,200,100,false,":USGrace_shop/files/missiles.png",raceshopGUI.window)
    raceshopGUI.selfex = exports.USGGUI:createImage("center",300,200,100,false,":USGrace_shop/files/selfex.png",raceshopGUI.window)
    raceshopGUI.laser = exports.USGGUI:createImage("right",300,200,100,false,":USGrace_shop/files/laser.png",raceshopGUI.window)
    raceshopGUI.rainbow = exports.USGGUI:createImage("center",450,200,100,false,":USGrace_shop/files/rainbow.png",raceshopGUI.window)
   
    raceshopGUI.buycolor = exports.USGGUI:createButton("left","top",200,100,false,"100$", raceshopGUI.window,100,100,100,100)
    raceshopGUI.buynitrous = exports.USGGUI:createButton("center","top",200,100,false,"100$", raceshopGUI.window,100,100,100,100)
    raceshopGUI.buyflip = exports.USGGUI:createButton("right","top",200,100,false,"200$", raceshopGUI.window,100,100,100,100)
    raceshopGUI.buyinv = exports.USGGUI:createButton("left",150,200,100,false,"300$", raceshopGUI.window,100,100,100,100)
    raceshopGUI.buymap = exports.USGGUI:createButton("center",150,200,100,false,"400$", raceshopGUI.window,100,100,100,100)
    raceshopGUI.buyspikes = exports.USGGUI:createButton("right",150,200,100,false,"500$", raceshopGUI.window,100,100,100,100)
    raceshopGUI.buymissiles = exports.USGGUI:createButton("left",300,200,100,false,"600$", raceshopGUI.window,100,100,100,100)
    raceshopGUI.buyselfex = exports.USGGUI:createButton("center",300,200,100,false,"700$", raceshopGUI.window,100,100,100,100)
    raceshopGUI.buylaser = exports.USGGUI:createButton("right",300,200,100,false,"800$", raceshopGUI.window,100,100,100,100)
    raceshopGUI.buyrainbow = exports.USGGUI:createButton("center",450,200,100,false,"1000$", raceshopGUI.window,100,100,100,100)
    
        exports.USGGUI:createLabel("left",100,200,50,false,"Buy a color for your car ",raceshopGUI.window)
        exports.USGGUI:createLabel("center",100,200,50,false,"Add nitrous x10 to your car ",raceshopGUI.window)
        exports.USGGUI:createLabel("right",100,200,50,false,"Flip your vehicle ",raceshopGUI.window)
        exports.USGGUI:createLabel("left",250,200,50,false,"Turn semi-invisible for one game ",raceshopGUI.window)
        exports.USGGUI:createLabel("center",250,200,50,false,"Buy a map and force it to be the next one ",raceshopGUI.window)
        exports.USGGUI:createLabel("right",250,200,50,false,"Drop spikes that flattens vehicle's tires ",raceshopGUI.window)
        exports.USGGUI:createLabel("left",400,200,50,false,"Drop missiles that will shoot all the nearby vehicles, including yours ",raceshopGUI.window)
        exports.USGGUI:createLabel("center",400,200,50,false,"Explode yourself causing damage to nearby vehicles ",raceshopGUI.window)
        exports.USGGUI:createLabel("right",400,200,50,false,"Add a laser coming out of your car that damages other cars, lasts for 20 seconds ",raceshopGUI.window)
        exports.USGGUI:createLabel("center",550,200,50,false,"Add a nyan cat trail to the back of your car ",raceshopGUI.window)
        
    
    raceshopGUI.close = exports.USGGUI:createButton("right","bottom",50,30,false,"Close", raceshopGUI.window)
    addEventHandler("onUSGGUISClick",raceshopGUI.buycolor,onBuyColor,false)
    addEventHandler("onUSGGUISClick",raceshopGUI.buynitrous,onBuyNitrous,false)
    addEventHandler("onUSGGUISClick",raceshopGUI.buyflip,onBuyFlip,false)
    addEventHandler("onUSGGUISClick",raceshopGUI.buyinv,onBuyInv,false)
    addEventHandler("onUSGGUISClick",raceshopGUI.buymap,onItemBuy,false)
    addEventHandler("onUSGGUISClick",raceshopGUI.buyspikes,onItemBuy,false)
    addEventHandler("onUSGGUISClick",raceshopGUI.buymissiles,onItemBuy,false)
    addEventHandler("onUSGGUISClick",raceshopGUI.buyselfex,onBuyExplode,false)
    addEventHandler("onUSGGUISClick",raceshopGUI.buylaser,onItemBuy,false)
    addEventHandler("onUSGGUISClick",raceshopGUI.buyrainbow,onItemBuy,false)
    
    addEventHandler("onUSGGUISClick",raceshopGUI.close,toggleraceGUI,false)
end


function toggleraceGUI()
if(not exports.USGaccounts:isPlayerLoggedIn()) then return end
if( exports.USGrooms:getPlayerRoom(localPlayer) == "cnr" or exports.USGrooms:getPlayerRoom(localPlayer) == "tct") then return end
    if(isElement(raceshopGUI.window )) then
        if(exports.USGGUI:getVisible(raceshopGUI.window )) then
         exports.USGGUI:setVisible(raceshopGUI.window , false)
            showCursor(false)
            exports.USGblur:setBlurDisabled()
            else
            showCursor(true)
            exports.USGblur:setBlurEnabled()
            exports.USGGUI:setVisible(raceshopGUI.window , true)
        end
    else
        createRaceshopGUI()
        exports.USGblur:setBlurEnabled()
        showCursor(true)
    end 
end 
addCommandHandler("shop",toggleraceGUI)

function onItemBuy()

end

function onBuyExplode()
	if (getPlayerMoney(localPlayer) < 750) then
		exports.USGmsg:msg("You don't have enough money to buy this!", 255, 0, 0)
		return
	end
	if (getPlayerMoney(localPlayer) >= 750) then
		triggerServerEvent("USGrace_shop.buyexplode", localPlayer)
	end
end

function onBuyColor()
	if (getPlayerMoney(localPlayer) < 100) then
		exports.USGmsg:msg("You don't have enough money to buy this!", 255, 0, 0)
		return
	end
	if (getPlayerMoney(localPlayer) >= 100) then
		exports.USGcolorpicker:openPicker("Select Color")
	end
end

function onPick222(r, g, b)
	triggerServerEvent("USGrace_shop.buycolor", localPlayer, r, g, b)
end
addEventHandler("onPickColor", root, onPick222)

function onBuyNitrous()
if (getPlayerMoney(localPlayer) < 100 ) then exports.USGmsg:msg("You don't have enought money", 0,255,0) return end
    if (getPlayerMoney(localPlayer) >= 100 ) then
        triggerServerEvent("USGrace_shop.buynitrous",localPlayer)
    end
end

function onBuyFlip()
if (getPlayerMoney(localPlayer) < 200 ) then exports.USGmsg:msg("You don't have enought money", 0,255,0) return end
    if (getPlayerMoney(localPlayer) >= 200 ) then
        triggerServerEvent("USGrace_shop.buyflip",localPlayer)
    end
end

function onBuyInv()
if (getPlayerMoney(localPlayer) < 300 ) then exports.USGmsg:msg("You don't have enought money", 0,255,0) return end
    if (getPlayerMoney(localPlayer) >= 300 ) then
        triggerServerEvent("USGrace_shop.buyinv",localPlayer)
    end
end

