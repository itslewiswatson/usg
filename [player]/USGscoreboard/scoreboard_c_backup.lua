local sX,sY = guiGetScreenSize()
local SCOREBOARD_WIDTH = math.max(600,math.floor(1000*(sX/1440)))
local SCOREBOARD_HEIGHT = math.max(412,math.floor(688*(sY/900)))
local SCOREBOARD_X, SCOREBOARD_Y = math.floor((sX-SCOREBOARD_WIDTH)/2), math.floor((sY-SCOREBOARD_HEIGHT)/2)

local ROOM_BUTTON_WIDTH = 130
local ROOM_BUTTON_HEIGHT = 30

local BOARD_X, BOARD_Y = SCOREBOARD_X+10+ROOM_BUTTON_WIDTH+5, SCOREBOARD_Y+40
local BOARD_WIDTH, BOARD_HEIGHT = SCOREBOARD_X+SCOREBOARD_WIDTH-BOARD_X-15, SCOREBOARD_HEIGHT-20-35

local SELECTION_COLOR = tocolor(175,75,0,210)

local TEXT_SCALE = 1
if(sX < 1440) then
	TEXT_SCALE = (sX/1440*1.3)
end

local collapsedTeams = {} -- hidden teams per room
local teamMouseState = {}
local room
local selectedRoom
local previousRoom

local scoreboardLabel -- prevent clicking of gui in background behind scoreboard
local boardRenderTarget = dxCreateRenderTarget(BOARD_WIDTH, BOARD_HEIGHT-20, true) -- create render target with size of board, minus the column names
local boardScroll = 0

local lastBoardHeight = BOARD_HEIGHT-45
local boardShowing = false
roomColumns = {}

function onRender()
	local sw,sh = guiGetScreenSize()
	local pre = getTickCount()
	if(not isElement(scoreboardLabel) and getResourceFromName("USGGUI") and getResourceState(getResourceFromName("USGGUI")) == "running") then 
		scoreboardLabel = exports.USGGUI:createLabel(SCOREBOARD_X,SCOREBOARD_Y,SCOREBOARD_WIDTH,SCOREBOARD_HEIGHT, false, "") 
	end
	if(not getKeyState("tab") or not exports.USGaccounts:isPlayerLoggedIn(localPlayer)) then 
		showCursor(false)
		if(isElement(scoreboardLabel) and getResourceFromName("USGGUI") and getResourceState(getResourceFromName("USGGUI")) == "running") then
			exports.USGGUI:setVisible(scoreboardLabel, false)
		end
		boardShowing = false
		return false
	end
	boardShowing = true
	if(getKeyState("mouse2")) then showCursor(true) else showCursor(false) end
	setControlState("action", false)
	setControlState("aim_weapon", false)
	if(isElement(scoreboardLabel) and getResourceFromName("USGGUI") and getResourceState(getResourceFromName("USGGUI")) == "running") then
		exports.USGGUI:setVisible(scoreboardLabel, true)
		exports.USGGUI:bringToFront(scoreboardLabel)
	end
	local cursorX, cursorY = 0, 0
	local cursorDown = false
	if(isCursorShowing()) then
		cursorX, cursorY = getCursorPosition()
		cursorX, cursorY = cursorX*sX, cursorY*sY
		cursorDown = getKeyState("mouse1")
	end
	local rooms = exports.USGrooms:getRooms()
	table.insert(rooms, 1, "lobby")
	-- background
	dxDrawRectangle(SCOREBOARD_X, SCOREBOARD_Y, SCOREBOARD_WIDTH, SCOREBOARD_HEIGHT, tocolor(10, 10, 10, 190), true)
	-- server / player info
	dxDrawText("USG | http://www.USGmta.co", SCOREBOARD_X+5, SCOREBOARD_Y,SCOREBOARD_X+math.floor(SCOREBOARD_WIDTH/2),SCOREBOARD_Y+30,
		tocolor(90,90,90,255),1,"default","left","center",false,false,true)
	dxDrawText("players: "..(#getElementsByType("player")), SCOREBOARD_X+math.floor(SCOREBOARD_WIDTH/2), SCOREBOARD_Y,
		SCOREBOARD_X+SCOREBOARD_WIDTH-5,SCOREBOARD_Y+30,tocolor(90,90,90,255),1,"default","right","center",false,false,true)
	dxDrawText("hold right-mouse for cursor", SCOREBOARD_X, SCOREBOARD_Y+SCOREBOARD_HEIGHT-25,
		SCOREBOARD_X+math.floor(SCOREBOARD_WIDTH/2),SCOREBOARD_Y+SCOREBOARD_HEIGHT,tocolor(90,90,90,255),0.8,"default","left","bottom",false,false,true)

	if(not selectedRoom) then selectedRoom = exports.USGrooms:getPlayerRoom() or rooms[1] end
	-- room tabs
	local y = 35
	for i, room in ipairs(rooms) do
		if(cursorDown and cursorX >= SCOREBOARD_X+20 and cursorX <= SCOREBOARD_X+20+ROOM_BUTTON_WIDTH
		and cursorY >= SCOREBOARD_Y+y and cursorY <= SCOREBOARD_Y+y+ROOM_BUTTON_HEIGHT) then
			previousRoom = selectedRoom
			selectedRoom = room
		end
		local selected = room == selectedRoom
		dxDrawRectangle(SCOREBOARD_X+10,SCOREBOARD_Y+y,ROOM_BUTTON_WIDTH,ROOM_BUTTON_HEIGHT,selected and SELECTION_COLOR or tocolor(5,5,5,255), true)
		dxDrawText(room == "lobby" and "Lobby" or exports.USGrooms:getRoomName(room), SCOREBOARD_X+10,SCOREBOARD_Y+y, 
			SCOREBOARD_X+20+ROOM_BUTTON_WIDTH,SCOREBOARD_Y+y+ROOM_BUTTON_HEIGHT,tocolor(255,255,255),1,selected and "default-bold" or "default", "center", "center",false,false,true)
		y = y+ROOM_BUTTON_HEIGHT+2
	end
	-- draw board
	dxDrawRectangle(BOARD_X-5, BOARD_Y-5, BOARD_WIDTH+10, BOARD_HEIGHT+10, SELECTION_COLOR, true)
	dxDrawRectangle(BOARD_X, BOARD_Y, BOARD_WIDTH, BOARD_HEIGHT, tocolor(0,0,0,240), true)
	-- draw rows first, then auto-size columns
	if(not roomColumns[selectedRoom]) then roomColumns[selectedRoom] = {} insertDefaultColumns(roomColumns[selectedRoom]) end
	local columns = roomColumns[selectedRoom]
	local players
	if(selectedRoom == "lobby") then
		players = {}
		for i,player in ipairs(getElementsByType("player")) do
			if(not exports.USGrooms:getPlayerRoom(player)) then
				table.insert(players, player)
			end
		end
	else
		players = exports.USGrooms:getPlayersInRoom(selectedRoom)
	end
	local teams = getElementsByType("team")
	local totWidth = 0
	dxDrawRectangle(BOARD_X, BOARD_Y, BOARD_WIDTH, 20, tocolor(30,30,30,230), true)
	dxSetRenderTarget(boardRenderTarget, true)
	dxSetBlendMode("modulate_add")
	for i,column in ipairs(columns) do
		local y = -boardScroll
		local maxWidth = dxGetTextWidth(column[1], TEXT_SCALE)
		for _, player in ipairs(players) do -- draw players without team
			if(selectedRoom ~= "cnr" or not getPlayerTeam(player)) then
				local value = tostring(column[2](player))
				local width = dxGetTextWidth(value, TEXT_SCALE)
				if(width > maxWidth) then maxWidth = width end
				if(y > -20) then -- only draw if visible
					dxDrawText(value, 3+totWidth,y,3+totWidth+width,y+20,tocolor(255,255,255),TEXT_SCALE,"default","left","center")
				end
				y = y + 22
			end
		end
		if(selectedRoom == "cnr") then -- if CnR room, draw teams
			for _, team in ipairs(teams) do
				local r,g,b = getTeamColor(team)
				if(i == 1 and y > -20) then -- only need to draw team name once
					dxDrawRectangle(0,y,BOARD_WIDTH,20,tocolor(r,g,b,150))
					dxDrawText(getTeamName(team), 3, y,BOARD_WIDTH-70,y+20,tocolor(255,255,255),TEXT_SCALE,"default-bold","left","center")
					dxDrawText(countPlayersInTeam(team).." players "..(collapsedTeams[team] and "+" or "-"), BOARD_WIDTH-70, y,BOARD_WIDTH-5,y+20,tocolor(255,255,255),TEXT_SCALE,"default","right","center")
					if(cursorDown and cursorX >= BOARD_X and cursorX <= BOARD_X+BOARD_WIDTH and cursorY >= BOARD_Y+20+y and cursorY <= BOARD_Y+y+40) then
						if(teamMouseState[team] == false) then
							collapsedTeams[team] = not collapsedTeams[team]
							teamMouseState[team] = true
						end
					else
						teamMouseState[team] = false
					end					
				end

				y = y + 22
				if(not collapsedTeams[team]) then
					for _, player in ipairs(getPlayersInTeam(team)) do
						if(exports.USGrooms:getPlayerRoom(player) == selectedRoom) then
							local value = tostring(column[2](player))
							local width = dxGetTextWidth(value, TEXT_SCALE)
							if(width > maxWidth) then maxWidth = width end
							if(y > -20) then -- only draw if visible
								dxDrawText(value, 3+totWidth,y,3+totWidth+width,y+20,tocolor(r,g,b,255),TEXT_SCALE,"default","left","center")
							end
							y = y + 22
						end
					end
				end
			end
			local oldHeight = lastBoardHeight
			lastBoardHeight = math.max(0,y+boardScroll-20)
			if(oldHeight ~= lastBoardHeight) then
				-- adjust scroll to fit new height
				boardScroll = math.max(0,math.min(lastBoardHeight-20,boardScroll))
			end
		end
		-- draw column name
		dxSetRenderTarget()
		dxDrawText(column[1], BOARD_X+3+totWidth,BOARD_Y,BOARD_X+3+totWidth+maxWidth,BOARD_Y+20,tocolor(255,255,255),TEXT_SCALE,"default-bold","left","center",false,false,true)
		if(i ~= #columns) then
			dxDrawLine(BOARD_X+3+totWidth+maxWidth, BOARD_Y+20,BOARD_X+3+totWidth+maxWidth,BOARD_Y+BOARD_HEIGHT,tocolor(30,30,30,120),TEXT_SCALE,true) -- draw lines for overview between columns
			dxSetRenderTarget(boardRenderTarget, false) -- if not the last, go back to the board rendertarget
		end
		totWidth = totWidth + maxWidth+10
	end
	dxSetBlendMode("blend")
	dxDrawImage(BOARD_X, BOARD_Y+20, BOARD_WIDTH, BOARD_HEIGHT-20, boardRenderTarget,0,0,0,tocolor(255,255,255,255),true)	
	-- draw scrollbar?
	if(lastBoardHeight > BOARD_HEIGHT-20) then
		local scrollY, size = getBoardScrollBarDimensions()
		dxDrawRectangle(BOARD_X+BOARD_WIDTH-10, BOARD_Y+20, 10, BOARD_HEIGHT-20,tocolor(0,0,0,200), true)
		dxDrawRectangle(BOARD_X+BOARD_WIDTH-8,BOARD_Y+20+scrollY,6,size,tocolor(255,255,255), true)
	end
end
addEventHandler("onClientRender", root, onRender)

addEventHandler("onClientResourceStart", resourceRoot,
	function ()
		for room, columns in pairs(roomColumns) do -- insert default columns
			insertDefaultColumns(columns)
		end
	end
)

addEventHandler("onClientKey", root,
	function (key)
		if(not boardShowing) then return end
		if(key == "mouse_wheel_up") then
			boardScroll = math.max(0,boardScroll - 50)
		elseif(key == "mouse_wheel_down") then
			boardScroll = math.min(lastBoardHeight,boardScroll + 50)
		end
	end
)

addEvent("onPlayerJoinRoom", true)
addEvent("onPlayerExitRoom", true)
addEventHandler("onPlayerJoinRoom", localPlayer,
	function (room)
		selectedRoom = room
	end
)
addEventHandler("onPlayerExitRoom", localPlayer,
	function (room)
		selectedRoom = "lobby"
	end
)

function getPlayerPlayTime(player)
	local minutes = getElementData(player, "playTime") or 0
	return string.format("%.0f hours", minutes/60)
end

function insertDefaultColumns(tab)
	table.insert(tab, 1, {"Name",getPlayerName})
	table.insert(tab, {"Playtime",getPlayerPlayTime})
	table.insert(tab, {"Ping",getPlayerPing})
end

function getBoardScrollBarDimensions()
	local location, height = false, false
	local maxScroll = lastBoardHeight
	if ( maxScroll > 0 ) then
		local maxScroll = maxScroll + BOARD_HEIGHT-20
		height = math.max(20, ((BOARD_HEIGHT-20)/(maxScroll)*(BOARD_HEIGHT-20)))
		location = ((boardScroll)/(maxScroll-(BOARD_HEIGHT-20)))*((BOARD_HEIGHT-20)-height-4)
	end
	return location,height
end