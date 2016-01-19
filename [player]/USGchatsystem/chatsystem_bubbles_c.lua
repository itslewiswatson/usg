local textsToDraw = {}

local hideown
local showtime
local characteraddition
local maxbubbles

local showthebubbles = true

function removeHEX( message )
	return string.gsub(message,"#%x%x%x%x%x%x", "")
end

function income(message,messagetype)
	if source ~= getLocalPlayer() or not hideown then
		if messagetype == 2 then
			if getPlayerTeam(source) == getPlayerTeam(getLocalPlayer()) then
				addText(source,removeHEX( message ),messagetype)
			end
		else
			addText(source,removeHEX( message ),messagetype)
		end
	end
end

function addText(source,message,messagetype)
	local notfirst = false
	for i,v in ipairs(textsToDraw) do
		if v[1] == source then
			v[4] = v[4] + 1
			notfirst = true
		end
	end
	local infotable = {source,message,messagetype,0}
	table.insert(textsToDraw,infotable)
	if not notfirst then
		setTimer(removeText,8000 + (#message * 50),1,infotable)
	end
end

function removeText(infotable)
	for i,v in ipairs(textsToDraw) do
		if v[1] == infotable[1] and v[2] == infotable[2] then
			for i2,v2 in ipairs(textsToDraw) do
				if v2[1] == v[1] and v[4] - v2[4] == 1 then
					setTimer(removeText,8000 + (#v2[2] * 50),1,v2)
				end
			end
			table.remove(textsToDraw,i)
			break
		end
	end
end

function getTextsToRemove()
	for i,v in ipairs(textsToDraw) do
		if v[1] == source then
			removeText(v)
		end
	end
end

function handleDisplay()
	if showthebubbles then
		for i,v in ipairs(textsToDraw) do
			if isElement(v[1]) then
				if getElementHealth(v[1]) > 0 then
					local camPosXl, camPosYl, camPosZl = getPedBonePosition (v[1], 6)
					local camPosXr, camPosYr, camPosZr = getPedBonePosition (v[1], 7)
					local x,y,z = (camPosXl + camPosXr) / 2, (camPosYl + camPosYr) / 2, (camPosZl + camPosZr) / 2
					--local posx,posy = getScreenFromWorldPosition(x,y,z+0.25)
					local cx,cy,cz = getCameraMatrix()
					local px,py,pz = getElementPosition(v[1])
					local distance = getDistanceBetweenPoints3D(cx,cy,cz,px,py,pz)
					local posx,posy = getScreenFromWorldPosition(x,y,z+0.6)

					local elementtoignore1 = getPedOccupiedVehicle(getLocalPlayer()) or getLocalPlayer()
					local elementtoignore2 = getPedOccupiedVehicle(v[1]) or v[1]
					if posx and distance <= 45 and ( isLineOfSightClear(cx,cy,cz,px,py,pz,true,true,false,true,false,true,true,elementtoignore1) or isLineOfSightClear(cx,cy,cz,px,py,pz,true,true,false,true,false,true,true,elementtoignore2) ) and ( not maxbubbles or  v[4] < maxbubbles ) then -- change this when multiple ignored elements can be specified
						local width = dxGetTextWidth(v[2],1,"default")
						posy = posy-(45/distance)-15
						
						dxDrawRectangle(posx - (3 + (0.5 * width)),posy - (2 + (v[4] * 20)),width + 5,19,tocolor(0,0,0,125))
						--[[
						dxDrawRectangle(posx - (6 + (0.5 * width)),posy - (2 + (v[4] * 20)),width + 11,19,tocolor(0,0,0,40))
						dxDrawRectangle(posx - (8 + (0.5 * width)),posy - (1 + (v[4] * 20)),width + 15,17,tocolor(0,0,0,255))
						dxDrawRectangle(posx - (10 + (0.5 * width)),posy - (1 + (v[4] * 20)),width + 19,17,tocolor(0,0,0,40))
						dxDrawRectangle(posx - (10 + (0.5 * width)),posy - (v[4] * 20) + 1,width + 19,13,tocolor(0,0,0,255))
						dxDrawRectangle(posx - (12 + (0.5 * width)),posy - (v[4] * 20) + 1,width + 23,13,tocolor(0,0,0,40))
						dxDrawRectangle(posx - (12 + (0.5 * width)),posy - (v[4] * 20) + 4,width + 23,7,tocolor(0,0,0,255))
						--]]
						
						local r,g,b = 255,255,255
						if v[3] == 2 and getPlayerTeam(v[1]) then
							r,g,b = getTeamColor(getPlayerTeam(v[1]))
						end
						
						dxDrawText(v[2],posx - (0.5 * width),posy - (v[4] * 20),posx - (0.5 * width),posy - (v[4] * 20),tocolor(r,g,b,255),1,"default","left","top",false,false,false)
					end
				end
			end
		end
	end
end

function getServerSettings()
    triggerServerEvent("onAskForBubbleSettings",getLocalPlayer())
end

function saveSettings(settings)
	showtime = 8000
	characteraddition = 50
	maxbubbles = 3
	hideown = true
end

function toggleBubblesOnOff()
	showthebubbles = not showthebubbles
	outputChatBox("Toggled chatbubbles " ..( not showthebubbles and "#FF0000off#FFFFFF." or "#00FF00on#FFFFFF." ),255,255,255,true)
end

addEvent("onChatbubblesMessageIncome",true)
addEventHandler("onChatbubblesMessageIncome",getRootElement(),income)
addEventHandler("onClientPlayerQuit",getRootElement(),getTextsToRemove)
addEventHandler("onClientRender",getRootElement(),handleDisplay)
addCommandHandler("chatbubbles",toggleBubblesOnOff)