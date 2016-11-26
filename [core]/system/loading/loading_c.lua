local loadingTimer = nil
local drawState = false
local fadeAlpha = 0
local fade = false
local fadeState = false

function showLoadingScreen(state,text, noTimeout)
	if (state == true) and (type(text) == "string" and #text > 0) then
		drawLoadingScreen(true)
		loadingText = text
		if ( isTimer(loadingTimer) ) then killTimer(loadingTimer) end
		if ( not noTimeout ) then
			loadingTimer = setTimer(drawLoadingScreen,1000*30,1,false)  --timeout
		end
		return true
	elseif (state == false) then
		drawLoadingScreen(false)
		if (isTimer(loadingTimer)) then
			killTimer(loadingTimer)
		end
		return true
	else
		return false
	end
end

function drawLoadingScreen(state)
	if (state == true and drawState ~= true) then
		addEventHandler("onClientRender",root,drawScreen)
		drawState = true
	elseif (state == false) then
		loadingText = "" --reset
		if(drawState == true) then
			removeEventHandler("onClientRender",root,drawScreen)
			drawState = false
		end
	else
		return false
	end
	return true
end

function prepLoadingFade(state)
	if (state == true) then
		if (fade ~= true) then
			fade = true
			addEventHandler("onClientRender",root,fade)
		else
			return --we don't need to do anything now :)
		end
	elseif (state == false) then
		if (fade ~= false) then
			fade = false
			addEventHandler("onClientRender",root,fade)
		else
			return --we don't need to do anything now :)
		end
	end
end

function fade()
	if (fade == true) then
		if (alpha <= 0) then
			alpha = alpha - 0.50
		else
			removeEventHandler("onClientRender",root,fade)
		end
	elseif (fade == false) then
		if (alpha >= 255) then
			alpha = alpha + 0.50
		else
			removeEventHandler("onClientRender",root,fade)
		end
	else
		return false
	end
end

function drawScreen()
	local rX,rY = guiGetScreenSize()
	--[[
	local spinRot = 0 --define the rotation
	dxDrawRectangle(0,0,rX,rY,tocolor(0,0,0,fadeAlpha),false) --Darkish box
	dxDrawImage(rX/2,rY/1.6,rX/2,10,"images/line.png",0,0,0,tocolor(0,0,0,fadeAlpha),false)
	dxDrawImage(rX/2,rY/2.6,rX/2,10,"images/line.png",0,0,0,tocolor(0,0,0,fadeAlpha),false)
	dxDrawImage(rX/2,rY/2+50,500,500,"images/load_icon.png",spinRot,0,0,tocolor(0,0,0,fadeAlpha),false)
	--dxDrawText(loadingText,
	
	if(spinRot ~= 359) then
		spinRot = spinRot + 1
	else
		spinRot = 1
	end
	--]]
	dxDrawRectangle(0,rY-35,rX,35,tocolor(0,0,0,230))
	dxDrawText(loadingText,0,rY-35,rX,rY,tocolor(255,255,255),1.4,"default-bold","center","center")
end