local countingDown = false
local countdownDuration
local countdownStart

addEvent("USGrace_countdown.startCountdown", true)
function startCountdown(duration, compensate)
	countdownStart = getTickCount()+((event or compensate) and getPlayerPing(localPlayer) or 0) -- attempt to compensate for any lag if sent from event
	countdownDuration = duration
	if(not countingDown) then
		countingDown = true
		addEventHandler("onClientRender", root, renderCountdown)
		addEventHandler("onPlayerExitRoom", localPlayer, stopCountdown)
	end
end
addEventHandler("USGrace_countdown.startCountdown", root, startCountdown)

local screenWidth, screenHeight = guiGetScreenSize()
local center, y = (screenWidth/2), screenHeight*0.8
function renderCountdown()
	local timeIn = getTickCount()-countdownStart
	local ticksLeft = 1000+(countdownDuration*1000)-timeIn
	local secondsLeft = math.min(countdownDuration, countdownDuration-math.floor(timeIn/1000))
	if(secondsLeft < 0) then
		stopCountdown()
		return
	end
	local ticksPast = (1000*(secondsLeft+1))-ticksLeft
	local animationProgress = math.max(0, math.min(secondsLeft == 0 and 0.5 or 1, (ticksPast-250)/500))
	local x = center-((ticksLeft/1000)*30)
	for i=0, countdownDuration do
		local text = i == 0 and "GO" or i
		local distance = math.abs((ticksLeft/1000)-i)
		local multiplier = i == secondsLeft and 1+getEasingValue(animationProgress, "SineCurve") or 1
		local scale = math.max(0.6, multiplier*4.25-(distance*0.8))
		dxDrawText(text, x, y, x+100, y+30,(secondsLeft == i and i == 0) and tocolor(120,255,120) or tocolor(255,255,255),scale)
		x = x + dxGetTextWidth(text, scale)+50
	end
end

function stopCountdown()
	if(countingDown) then
		countingDown = false
		removeEventHandler("onClientRender", root, renderCountdown)
		removeEventHandler("onPlayerExitRoom", localPlayer, stopCountdown)
	end
end