local screenWidth, screenHeight = guiGetScreenSize()
local rel = { 	pos_x = 0.0625,
				pos_y = 0.76333333333333333333333333333333,
				size_x = 0.15,
				size_y = 0.175,
				radar_blip_y = 0.03333333333333333333333333333333,
}

local abs = { 	pos_x = math.floor(rel.pos_x * screenWidth),
				pos_y = math.floor(rel.pos_y * screenHeight),
				size_x = math.floor(rel.size_x * screenWidth),
				size_y = math.floor(rel.size_y * screenHeight),
				radar_blip_y = math.floor(rel.radar_blip_y * screenHeight)
}
abs.half_size_x =  abs.size_x/2
abs.half_size_y =  abs.size_y/2
abs.center_x = abs.pos_x + abs.half_size_x
abs.center_y = abs.pos_y +abs.half_size_y
local minBound = 0.1*screenHeight

function getRadarScreenRadius ( angle ) --Since the radar is not a perfect ciricle, we work out the screen size of the radius at a certain angle
	return math.max(math.abs((math.sin(angle)*(abs.half_size_x - abs.half_size_y))) + abs.half_size_y,minBound)
end

elementBlip = {}
local visibleElements = {}
function createCustomBlip(x,y, width, height, path, radius)
	if(not fileExists(path)) then
		path = ":"..getResourceName(sourceResource).."/"..path
		if(not fileExists(path)) then
			error("could not find image")
		end
	end
	local element = createElement("customblip")
	addEventHandler("onClientElementDestroy", element, onBlipDestroyed)
	local blip = {x=x, y=y, width=width,height=height,path=path,radius=radius, element=element, visible = true}
	elementBlip[element] = blip
	table.insert(visibleElements, element)
	initBlipRadarInfo(blip)
	return element
end

function onBlipDestroyed()
	if(elementBlip[source]) then
		local blip = elementBlip[source]
		removeBlipFromRadar(blip)
		elementBlip[source] = nil
		for i, element in ipairs(visibleElements) do
			if(element == source) then
				table.remove(visibleElements, i)
				break
			end
		end
	end
end

function isCustomBlipVisible(blip)
	if(elementBlip[blip]) then blip = elementBlip[blip] end
	return blip and blip.visible or nil
end

function setCustomBlipVisible(blip, state)
	if(elementBlip[blip]) then blip = elementBlip[blip] end
	if(blip and blip.visible ~= state) then
		blip.visible = state
		if(state) then
			initBlipRadarInfo(blip)
			table.insert(visibleElements, blip.element)
		else
			for i, element in ipairs(visibleElements) do
				if(element == blip.element) then
					table.remove(visibleElements, i)
					break
				end
			end
			removeBlipFromRadar( blip )
		end
	end
end

local MAP_SIZE_MULTIPLIER = 0.5

function renderVisibleBlips()
	local mapVisible = isPlayerMapVisible()
	if(mapVisible) then
		local mapX, mapY, mapEndX, mapEndY = getPlayerMapBoundingBox()
		local mapWidth, mapHeight = mapEndX-mapX,mapEndY-mapY
		for i, element in ipairs(visibleElements) do
			local blip = elementBlip[element]
			local width,height = math.floor(MAP_SIZE_MULTIPLIER*blip.width), math.floor(MAP_SIZE_MULTIPLIER*blip.height)
			local relX, relY = (blip.x+3000)/6000, 1-((blip.y+3000)/6000)
			local x,y = mapX+math.floor((relX*mapWidth)-(width/2)), mapY+math.floor((relY*mapHeight)-(height/2))
			dxDrawImage(x,y,width, height, blip.path)
		end
	end
end
addEventHandler("onClientRender", root, renderVisibleBlips)


-- drawing blips on radar

local tiles = {}
local OVERLAY_WIDTH      = 256
local OVERLAY_HEIGHT     = 256

function isBlipInRadarRange(blip)
	local cX, cY
	if(getCameraTarget()) then cX,cY,_ = getElementPosition(getCameraTarget() or localPlayer)
	else cX,cY,_,_,_,_,_,_,_,_,_,_ = getCameraMatrix() end
	local blipX,blipY = blip.x, blip.y
	local dist = getDistanceBetweenPoints2D(cX,cY,x,y)
	return dist < getRadarScreenRadius()
end

function initBlipRadarInfo(blip)
	local posX, posY = blip.x, blip.y
	-- Calculate the row and column of the radar tile we will be targeting
	local row = 11 - math.floor  ( ( posY + 3000 ) / 500 )
	local col =      math.floor ( ( posX + 3000 ) / 500 )
	
	-- If it's off the map, don't bother
	if row < 0 or row > 11 or col < 0 or col > 11 then
		return false
	end
	
	-- Check the start position of the tile
	local startX = col * 500 - 3000
	local startY = 3000 - row * 500
	
	-- Now get the tile position (We don't want to calculate this for every point on render)
	local tileX = ( posX - startX ) / 500 * OVERLAY_WIDTH
	local tileY = ( startY - posY ) / 500 * OVERLAY_HEIGHT

	-- Now calulcate the ID and get the name of the tile
	local id   = col + row * 12
	local name = string.format ( "radar%02d", id )
	if(not tiles[name]) then tiles[name] = {} end
	blip.radarInfo = {tile = name, posX = tileX, posY = tileY}
	table.insert(tiles[name], blip)
	if(tiles[name].loaded) then
		unloadRadarTile(name)
		loadRadarTile(name)
	end
	return true
end

function removeBlipFromRadar( blip )
	if(blip.radarInfo and blip.radarInfo.tile) then
		local tile = tiles[blip.radarInfo.tile]
		if(tile and tile.loaded) then -- reload it
			unloadRadarTile(blip.radarInfo.tile)
			for i, b in ipairs(tile) do
				if(blip == b) then
					table.remove(tile, i)
					break
				end
			end
			loadRadarTile(blip.radarInfo.tile)
		end
	end
end

function unloadRadarTile ( name )
	if(tiles[name].loaded) then
		if(isElement(tiles[name].radar)) then
			destroyElement ( tiles[name].shader )
		end
		if(isElement(tiles[name].rt)) then
			destroyElement ( tiles[name].rt )
		end
		tiles[name].loaded = false
		return true
	else
		return false
	end
end

function loadRadarTile ( name )
	-- Create our fabulous shader. Abort on failure
	local shader = dxCreateShader ( "customblips/overlay.fx" )
	if not shader then
		return false
	end
	
	-- Create a render target. Again, abort on failure (don't forget to delete the shader!)
	local rt = dxCreateRenderTarget ( OVERLAY_WIDTH, OVERLAY_HEIGHT, true )
	if not rt then
		destroyElement ( shader )
		return false
	end
	
	-- Mix 'n match
	dxSetShaderValue ( shader, "gOverlay", rt )
	
	-- Start drawing
	dxSetRenderTarget ( rt )
	
	-- Get the blips involved, and get the starting position
	local blips = tiles [ name ]
	
	-- Loop through all points we have to draw, and draw them
	for index, blip in ipairs ( blips ) do
		local newX = math.floor(blip.radarInfo.posX-(blip.width/2))
		local newY = math.floor(blip.radarInfo.posY-(blip.height/2))
		
		dxDrawImage(newX, newY, blip.width, blip.height, blip.path)
	end
	
	-- Now let's show our fabulous work to the commoners!
	engineApplyShaderToWorldTexture ( shader, name )
	
	-- Store the stuff in memories
	tiles [ name ].shader = shader
	tiles [ name ].rt = rt
	tiles [ name ].loaded = true
	-- We won
	return true
end

function table.find ( tbl, val )
	for index, value in ipairs ( tbl ) do
		if value == val then
			return index
		end
	end
	return false
end

function table.merge ( ... )
	local ret = { }
	for index, tbl in ipairs ( {...} ) do
		for index, val in ipairs ( tbl ) do
			table.insert ( ret, val )
		end
	end
	return ret
end

addEventHandler ( "onClientHUDRender", root,
	function ( )
		local visibleTileNames = table.merge ( engineGetVisibleTextureNames ( "radar??" ), engineGetVisibleTextureNames ( "radar???" ) )
		
		for name, data in pairs ( tiles ) do
			if data.loaded and not table.find ( visibleTileNames, name ) then
				unloadRadarTile ( name )
			end
		end
		
		for index, name in ipairs ( visibleTileNames ) do
			if tiles [ name ] and not tiles [ name ].loaded then
				loadRadarTile ( name )
			end
		end
	end
)