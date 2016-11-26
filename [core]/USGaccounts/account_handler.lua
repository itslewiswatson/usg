function onPlayerJoin()
	local rX,rY = guiGetScreenSize()
	if (rX >= 800) and (rY >= 600) then
		triggerServerEvent("checkForBan",localPlayer)
	else
		showInstructions()
	end
end
addEventHandler("onClientPlayerJoin",root,onPlayerJoin)
addEventHandler("onClientResourceStart",resourceRoot,onPlayerJoin)

function showInstructions()
	local rX,rY = guiGetScreenSize()
	local width,height = 571,371
	local x,y = (rX/2) - (width/2), (rY/2) - (height/2)
	instructionWindow = guiCreateWindow(x,y,width,height,"USG ~ Resolution Change Tutorial",false)
		guiSetAlpha(instructionWindow,1)
		guiWindowSetMovable(instructionWindow,false)
		guiWindowSetSizable(instructionWindow,false)
	label1 = guiCreateLabel(88,133,382,24,"Sorry, but your resolution is below our minimum requirements!",false,instructionWindow)
		guiLabelSetColor(label1,255,0,0)
		guiLabelSetVerticalAlign(label1,"center")
		guiLabelSetHorizontalAlign(label1,"center",false)
		guiSetFont(label1,"default-bold-small")
	label2 = guiCreateLabel(5,163,560,201,"At USG, we require your resolution to be at least than 800 x 600. Yours is: "..rX.." x "..rY..".\nTo proceed to play at USG, please follow these instructions to change your resolution\n\n\nStep 1: Press ESC and click \"Settings\" on MTA's main menu.\nStep 2: Click on the \"Video\" tab\nStep 3: Change your resolution to be at least 800 x 600.\n\nOnce thats done, restart your MTA and rejoin to be able to get onto the server.\nThanks for reading, and sorry for this incident!\n\n\n~Community of Social Gaming~",false,instructionWindow)
		guiLabelSetHorizontalAlign(label2,"center",true)
	image = guiCreateStaticImage(207,20,142,116,"images/disc-logo.png",false,instructionWindow)
end

