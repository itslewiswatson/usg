GUIinfo = {}
screenWidth,screenHeight = guiGetScreenSize()
local defaultTextScale = 1
local defaultTextColor = tocolor(255,255,255,255)

local leftMouseState = getKeyState("mouse1")
local rightMouseState = getKeyState("mouse2")

function sortGUI()

	table.sort(GUIinfo,function(a,b) return a.order < b.order end)
	
end

function setVisible(element,state)

	if state ~= false and state ~= true then state = not GUIinfo[element].visible end
	GUIinfo[element].visible = state

end

function bringToFront(element)

	GUIinfo[element].order = #GUIinfo
	sortGUI()
	
end

function moveToBack(element)

	GUIinfo[element].order = 1
	sortGUI()
	
end

function moveWithEffect(element,newX,newY,easingFunc,moveTime)

	if GUIinfo[element] then
	
		GUIinfo[element].moveTo = { orgX = GUIinfo[element].x, orgY = GUIinfo[element].y, movex = newX, movey = newY, easing = easingFunc or "Linear", startTime = getTickCount(), moveTime = ( moveTime or 3000  ) }
	
	end

end


function resizeWithEffect(element,newWidth,newHeight,easingFunc,resizeTime)
	if GUIinfo[element] then
	
		GUIinfo[element].resizeTo = { orgX = GUIinfo[element].width, orgY = GUIinfo[element].height,sizex = newWidth, sizey = newHeight, easing = easingFunc or "Linear", startTime = getTickCount(),resizeTime = ( resizeTime or 3000 ) }
	
	end

end

function drawElementsOnRender(element)

	for element, info in pairs(GUIinfo) do
	
		local info = GUIinfo[element]
		local parentInfo = GUIinfo[getElementParent(element)]
		
		if info.visible and ( not parentInfo or parentInfo.visible ) then
		
			if info.moveTo then
			
				local ticks = getTickCount()
				local progress = (ticks-info.moveTo.startTime)/info.moveTo.moveTime
				info.x, info.y,_ = interpolateBetween(info.moveTo.orgX,info.moveTo.orgY,0,info.moveTo.movex,info.moveTo.movey, 0, progress, info.moveTo.easing)
				if progress >= 1 then
				
					info.moveTo = nil
					
				end
			
			end		
			if info.resizeTo then
			
				local ticks = getTickCount()
				local progress = (ticks-info.resizeTo.startTime)/info.resizeTo.resizeTime
				info.width, info.height,_ = interpolateBetween(info.resizeTo.orgX,info.resizeTo.orgY,0,info.resizeTo.sizex,info.resizeTo.sizey, 0, progress, info.resizeTo.easing)
				if progress >= 1 then
				
					info.resizeTo = nil
					
				end
			
			end
			local x,y = info.x, info.y
			
			if info.guiType == "window" then
		
				if parentInfo then
					x,y = parentInfo.x+x,parentInfo.y+y
				end
				dxDrawRectangle(x, y-23, info.width, 20, info.color)
				dxDrawRectangle(x, y, info.width, info.height, info.color)
				dxDrawText(info.text,x,y-23,x+info.width,y,defaultTextColor, defaultTextScale,"default",'center','center',false,false)	

			elseif info.guiType == "button" then
		
				if parentInfo then
					if parentInfo.guiType == "window" then
						x,y = parentInfo.x+x,parentInfo.y+y
					else
						x,y = parentInfo.x+x,parentInfo.y+y
					end
				end
				dxDrawRectangle(x, y, info.width, info.height, info.color)
				dxDrawText(info.text,x,y,x+info.width,y+info.height,defaultTextColor, defaultTextScale,"default",'center','center',false,true)		
			
			end
	
		end
		
	end
	
end

function destroyGUIOnElementDestroyed()

	if GUIinfo[source] then GUIinfo[source] = nil end

end

addEventHandler("onClientResourceStop", root,
function ()

	for element,info in pairs(GUIinfo) do
	
		if info.resource == source then 
		
			GUIinfo[element] = nil
			destroyElement(element)
			
		end
	
	end

end
)

addEventHandler('onClientResourceStart', resourceRoot,
function ()

	addEventHandler('onClientRender', root, drawElementsOnRender )
	addEventHandler('onClientRender', root, manageMouseOnRender )
	addEventHandler('onClientElementDestroy', root, destroyGUIOnElementDestroyed )
	dxSetBlendMode("overwrite")

end)
