local gate = createObject(3114,364.20001220703,-3525.6999511719,2.2999999523163,90)
function movegate ()
setTimer(moveObject,30000,1,gate,2000,349.60000610352,-3525.6000976563,2.2999999523163)
end
addEventHandler("onResourceStart",root,movegate)
