
function ClientStarted ()
setWaterColor( 0 , 125 , 255 ) -- RGB colors
setSkyGradient( 83 , 134 , 139 , 93 , 104 , 205 ) -- 1st RGB colors top sky, 2nd RGB colors bottom sky
end 

Me = getLocalPlayer()
Root = getRootElement()
local screenWidth, screenHeight = guiGetScreenSize() -- Get the screen resolution


setTimer(outputChatBox,1000,1,"", 255, 125, 0, true)
setTimer(outputChatBox,1000,1,"", 255, 125, 0, true)
setTimer(outputChatBox,1000,1,"", 255, 125, 0, true)
setTimer(outputChatBox,1000,1,"", 255, 125, 0, true)
setTimer(outputChatBox,1000,1,"", 255, 125, 0, true)
setTimer(outputChatBox,1000,1,"", 255, 125, 0, true)
setTimer(outputChatBox,1000,1,"", 255, 125, 0, true)
setTimer(outputChatBox,1000,1,"", 255, 125, 0, true)
setTimer(outputChatBox,1000,1,"", 255, 125, 0, true)
setTimer(outputChatBox,1000,1,"", 255, 125, 0, true)
setTimer(outputChatBox,1000,1,"", 255, 125, 0, true)
setTimer(outputChatBox,1000,1,"", 255, 125, 0, true)
setTimer(outputChatBox,1000,1,"", 255, 125, 0, true)
setTimer(outputChatBox,1000,1,"#ffffff-Le#00babaon-: #FFFFFFHello! Here is my new map, hope you like it.", 255, 125, 0, true)
setTimer(outputChatBox,1000,1,"#ffffff-Le#00babaon-: #FFFFFFOnly playable on WTF server.", 255, 125, 0, true)
setTimer(outputChatBox,1000,1,"#ffffff-Le#00babaon-: #FFFFFFPress #0099ff'M'#FFFFFF to toggle the music On/Off.", 255, 125, 0, true)		
setTimer(outputChatBox,1000,1,"#ffffff-Le#00babaon-: #FFFFFFGood Luck & Have Fun!", 255, 125, 0, true)
setTimer(outputChatBox,1000,1,"", 255, 125, 0, true)

addEventHandler( "onClientResourceStart", getResourceRootElement(getThisResource()), Main )

