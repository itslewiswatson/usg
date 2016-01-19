local duelGUI = {}
noob = exports.USGGUI
hp = false
armor = false
setElementData(localPlayer, "wanttoduel", false)

addEvent("onPlayerJoinRoom", true)
addEvent("onPlayerExitRoom", true)

function createduelGUI()
    duelGUI.window = exports.USGGUI:createWindow("center","center",700,410,false,"USG ~ Duel System")
    duelGUI.grid = exports.USGGUI:createGridList(5,5,200,390,false,duelGUI.window)
    duelGUI.duelgrid = exports.USGGUI:createGridList(210,45,380,300,false,duelGUI.window)
    duelGUI.column = exports.USGGUI:gridlistAddColumn(duelGUI.grid,"Players", 0.70)
    duelGUI.column = exports.USGGUI:gridlistAddColumn(duelGUI.grid,"Ping", 0.25)
    duelGUI.column = exports.USGGUI:gridlistAddColumn(duelGUI.duelgrid,"Requests", 0.35)
    duelGUI.column = exports.USGGUI:gridlistAddColumn(duelGUI.duelgrid,"Money", 0.20)
 --   duelGUI.column = exports.USGGUI:gridlistAddColumn(duelGUI.duelgrid,"Allow Drugs", 0.22)
    duelGUI.column = exports.USGGUI:gridlistAddColumn(duelGUI.duelgrid,"Health & Armor", 0.18)
    duelGUI.invite = exports.USGGUI:createButton(590,5,100,30,false,"Invite",duelGUI.window)
    duelGUI.refresh = exports.USGGUI:createButton(250,360,100,30,false,"Refresh",duelGUI.window)
    duelGUI.reject = exports.USGGUI:createButton(390,360,100,30,false,"Reject",duelGUI.window)
    duelGUI.accept = exports.USGGUI:createButton(530,360,100,30,false,"Accept",duelGUI.window)
    duelGUI.available = exports.USGGUI:createCheckBox(215,8,10,10,false,"Available",duelGUI.window)
    duelGUI.allowHA = exports.USGGUI:createCheckBox(215,28,10,10,false,"Allow Armor & 200% Health",duelGUI.window)
--    duelGUI.allowdrugs = exports.USGGUI:createCheckBox(320,28,10,10,false,"Allow Drugs",duelGUI.window)
    duelGUI.money = exports.USGGUI:createEditBox(430,5,150,30,false,"5000",duelGUI.window,clearOnFirstClick)
    duelGUI.info1 = exports.USGGUI:createLabel(585,20,100,100,false,"Player Info:\n__________",duelGUI.window)
    duelGUI.label1 = exports.USGGUI:createLabel(585,50,100,100,false,"Won Duels",duelGUI.window)
    duelGUI.label2 = exports.USGGUI:createLabel(585,70,100,100,false,"Lost Duels",duelGUI.window)
    duelGUI.labelclose1 = exports.USGGUI:createLabel(585,90,100,100,false,"__________",duelGUI.window)


	duelGUI.info2 = exports.USGGUI:createLabel(585,150,100,100,false,"My Info:\n__________",duelGUI.window)
    duelGUI.label3 = exports.USGGUI:createLabel(585,180,100,100,false,"Won Duels",duelGUI.window)
    duelGUI.label4 = exports.USGGUI:createLabel(585,200,100,100,false,"Lost Duels",duelGUI.window)
    duelGUI.labelclose2 = exports.USGGUI:createLabel(585,220,100,100,false,"__________",duelGUI.window)


		noob:setTextColor(duelGUI.label1,tocolor(0,255,0))
		noob:setTextColor(duelGUI.label2,tocolor(255,0,0))
		noob:setTextColor(duelGUI.label3,tocolor(0,255,0))
		noob:setTextColor(duelGUI.label4,tocolor(255,0,0))
    --noob:setTextScale(duelGUI.label,1.5)
    addEventHandler("onUSGGUIChange", duelGUI.money, removeLetters)
    addEventHandler("onUSGGUISClick", duelGUI.money , function() noob:setText(duelGUI.money,"5000") end )
    addEventHandler("onUSGGUISClick", duelGUI.invite , send)
	addEventHandler("onUSGGUISClick", duelGUI.available,check)
	addEventHandler("onUSGGUISClick", duelGUI.refresh,check2)
	addEventHandler("onUSGGUISClick", duelGUI.accept,accept)
	addEventHandler("onUSGGUISClick", duelGUI.reject,reject)
	addEventHandler("onUSGGUISClick", duelGUI.grid,syncStats)
end

function toggleduelGUI()
local wanted = getElementData(localPlayer,"wantedLevel")
if wanted and getElementData(localPlayer,"wantedLevel") <= 10 then
    if(not isElement(duelGUI.window) or not exports.USGGUI:getVisible(duelGUI.window)) then
		triggerServerEvent("SyncloadData",localPlayer)
    else
        closeduelGUI()
    end
	else
	exports.USGmsg:msg("You can't do this action while you're wanted!!",255,0,0)
    end
end
addCommandHandler("duel", toggleduelGUI)

function forceSetStats()
triggerServerEvent("loadData",localPlayer)
local player2Win = getElementData(localPlayer,"won")
	local player2lose = getElementData(localPlayer,"lost")
		if player2Win and tonumber(player2Win) and player2lose and tonumber(player2lose) then
			noob:setText(duelGUI.label1, "Won Duels")
        		noob:setText(duelGUI.label2, "Lost Duels")
    	    noob:setText(duelGUI.label3, "Won Duels: "..player2Win)
		noob:setText(duelGUI.label4, "Lost Duels: "..player2lose)
	end
end

addEvent("getDuelGUI",true)
addEventHandler("getDuelGUI",root,function()
if source ~= localPlayer then return false end
	openduelGUI()
	forceSetStats()
end)


function openduelGUI()
    if(exports.USGrooms:getPlayerRoom() ~= "cnr") then return false end
    if(not isElement(duelGUI.window)) then
        createduelGUI()
    else
        exports.USGGUI:setVisible(duelGUI.window, true)
    end
    showCursor(true)
    fillPlayerGrid()
end

function closeduelGUI()
    if (isElement(duelGUI.window) and exports.USGGUI:getVisible(duelGUI.window))then
        exports.USGGUI:setVisible(duelGUI.window, false)
        showCursor(false)
        exports.USGGUI:gridlistClear(duelGUI.grid)
    end
end



function addPlayerToGrid(player,filter)
    if ( isElement(duelGUI.grid) ) then
        local nick = getPlayerName(player)
        local r, g, b = exports.USG:getPlayerTeamColor(player)
        local row = exports.USGGUI:gridlistAddRow(duelGUI.grid)
		local ping = getPlayerPing(player)
        setElementData(player,"duelPing",ping)
		local pPing = getElementData(player,"duelPing")
        exports.USGGUI:gridlistSetItemText(duelGUI.grid,row,2,tostring(pPing))
        exports.USGGUI:gridlistSetItemText(duelGUI.grid,row,1,nick)
        exports.USGGUI:gridlistSetItemColor(duelGUI.grid,row,1,tocolor(r,g,b))
        exports.USGGUI:gridlistSetItemData(duelGUI.grid,row,1,player)
        playerRow[player] = row
    end
end

function fillPlayerGrid()
    if ( isElement(duelGUI.grid) ) then
        playerRow = {}
        exports.USGGUI:gridlistClear(duelGUI.grid)
        local players = getElementsByType("player")
        for i, player in ipairs(players) do
		if player ~= localPlayer then
            if(exports.USGaccounts:isPlayerLoggedIn(player) and exports.USGrooms:getPlayerRoom(player) == "cnr") then
			if noob:getCheckBoxState(duelGUI.available) then
			if getElementData(player,"wanttoduel") == true then
                addPlayerToGrid(player)
           end
            end
            end
            end
        end
    end
end

function onPlayerChangeNick(old, new)
    if(isElement(duelGUI.grid)) then
        if(playerRow[source]) then
            exports.USGGUI:gridlistSetItemText(duelGUI.grid,playerRow[source],1,new)
        else
            fillPlayerGrid()
        end
    end
end

function onPlayerJoinRoom(room)
    if(room == "cnr") then
        addPlayerToGrid(source)
    end
end
addEventHandler("onPlayerJoinRoom",localPlayer,onPlayerJoinRoom)
function onPlayerExitRoom(room)
    if (source == localPlayer) then
	if (room == "cnr") then
        fillPlayerGrid()
        end
    end
end
addEventHandler("onPlayerExitRoom",localPlayer,onPlayerExitRoom)

function onPlayerQuit()
    if(exports.USGrooms:getPlayerRoom(source) == "cnr") then
        fillPlayerGrid()
    end
end

function gridlistGetPlayer()
    local selected = exports.USGGUI:gridlistGetSelectedItem(duelGUI.grid)
    if(selected) then
        local player = exports.USGGUI:gridlistGetItemData(duelGUI.grid, selected, 1)
        if(isElement(player)) then
            return player
        end
    end
    return false
end


function syncStats()
local guiGrid = noob:gridlistGetSelectedItem(duelGUI.grid)
	if guiGrid then
		local playerName = noob:gridlistGetItemText(duelGUI.grid, guiGrid, 1)
			local player = getPlayerFromName(playerName)
				if player then
					triggerServerEvent("loadData",player)
					forceSetStats()
						player1 = player
						local player1Win = getElementData(player1,"won")
					local player1lose = getElementData(player1,"lost")
				if player1Win and tonumber(player1Win) and player1lose and tonumber(player1lose) then
						noob:setText(duelGUI.label1, "Won Duels: "..player1Win)
					noob:setText(duelGUI.label2, "Lost Duels: "..player1lose)
				else
					noob:setText(duelGUI.label1, "Won Duels: 0")
				noob:setText(duelGUI.label2, "Lost Duels: 0")
		    end
		end
    end
end
local sx, sy = guiGetScreenSize()
local rx, ry = 1920, 1080
function monitorDENjob()
if sx == 800 then
text = 2.00
text2 = 4
elseif sx == 1024 then
text = 1.9
text2 = 3
elseif sx >= 1280 then
text = 1
text2 = 2
end
end
addEventHandler("onClientRender", root, monitorDENjob)

addEvent("forceToExitThePanel",true)
addEventHandler("forceToExitThePanel",localPlayer,function()
closeduelGUI()
end)

addEvent("countDown",true)
addEventHandler("countDown",localPlayer,function(timer)
exports.USGrace_countdown:startCountdown(timer, true)
end)

addEventHandler("onPlayerJoinRoom",localPlayer,
function (room)
if room == "cnr" then
    triggerServerEvent("ForceHimToquitDuel",localPlayer)
    end
end)


addEventHandler("onPlayerExitRoom",localPlayer,
function (room)
if room == "cnr" then
    if getElementData(localPlayer,"Dueler") == true then
	triggerServerEvent("quitDuel2",localPlayer)
    end
    end
end)



addEvent("onPlayerExitRoom", true)
addEventHandler("onPlayerExitRoom", localPlayer,
	function (prevRoom)
		if (prevRoom == "cnr") then
			if getElementData(localPlayer,"Dueler") == true then
            triggerServerEvent("quitDuel",localPlayer)
		    end
		end
	end
)





local objtable = {
{14789,1913.5,1192.3,25.8},
{1536,1932.4,1168,21.5},

}



objects = {}

for i=1,#objtable do
local model,x,y,z,rotx,roty,rotz = objtable[i][1],objtable[i][2],objtable[i][3],objtable[i][4],objtable[i][5],objtable[i][6],objtable[i][7]
object = createObject(model,x,y,z,rotx,roty,rotz)
dim = math.random(1000,9999)
setElementDimension(object,dim)
table.insert(objects,object)
end



addEvent("syncDuel",true)
addEventHandler("syncDuel",root,function(dimension)
for k,v in pairs(objects) do
    setElementDimension(v,dimension)
	end
end)





function removeLetters(element)
	local txts2 = noob:getText(duelGUI.money)
	local removed = string.gsub(txts2, "[^0-9]", "")
	if (removed ~= txts2) then
		noob:setText(duelGUI.money, removed)
	end
end


local antiSpamer = false
function send(button)
if source == duelGUI.invite then
if getElementData(localPlayer,"Dueler") == true then return false end
    if antiSpamer == false then
	            local guiGrid = noob:gridlistGetSelectedItem(duelGUI.grid)
	                if guiGrid then
	                    local playerName = noob:gridlistGetItemText(duelGUI.grid, guiGrid, 1)
                            local am = exports.USGGUI:getText(duelGUI.money)
                                local inviter = getLocalPlayer()
                                    if (getPlayerFromName(playerName)) then
                                        if tonumber(am) and tonumber(am) >= 5000 then
                                            if getPlayerWantedLevel() < 1 then
                                                if getPlayerMoney() >= tonumber(am) then
												if getElementData(getPlayerFromName(playerName),"Dueler") == true then exports.USGmsg:msg("This player already in duel",255,0,0) return false end
						                            exports.USGmsg:msg("You have invited "..playerName.." for a duel with a bet of $"..am.."!", 0, 225, 0)
						                                if noob:getCheckBoxState(duelGUI.allowHA) == true then
						                                    armor = true
						                                        hp = true
						                                else
        						                            hp = false
					    	                                    armor = false
						                                end
														antiSpamer = true
					                                        triggerServerEvent("onsend", getPlayerFromName(playerName), inviter, am,armor,hp)
															setTimer(function() antiSpamer = false end,3000,1)
				                                                    else
											                    exports.USGmsg:msg( "You dont have enough money", 0, 225, 0)
                                                            end
                                                        else
					                                exports.USGmsg:msg( "You cant duel if wanted", 0, 225, 0)
                                                end
                                            else
					                    exports.USGmsg:msg( "You need to put the Bet Money, and it should be over $1000", 0, 225, 0)
				                    end
                                else
			                exports.USGmsg:msg( "You need to choose a Player from the list", 0, 225, 0)
                        end
		            end
		        else
	  	    exports.USGmsg:msg( "Wait 5 seconds for spamming the button!!", 255, 0, 0)
        end
    end
end




function check()
    if source == duelGUI.available then
        if noob:getCheckBoxState(duelGUI.available) == true then
			setElementData(getLocalPlayer(), "wanttoduel", true)
			fillPlayerGrid()
        elseif noob:getCheckBoxState(duelGUI.available) == false then
			setElementData(getLocalPlayer(), "wanttoduel", false)
			fillPlayerGrid()
			exports.USGGUI:gridlistClear(duelGUI.duelgrid)
        end
    end
end


function check2()
    if source == duelGUI.refresh then
        if getElementData(getLocalPlayer(), "wanttoduel") == true then
			fillPlayerGrid()
        else
		exports.USGmsg:msg("Mark yourself available first!",255,0,0)
        end
    end
end


function noExplosives(attacker, weapon, bodypart, loss)
if attacker and source and getElementType(attacker) == "player" and getElementType(source) == "player" then
	if getElementData(attacker,"Dueler") == true and getElementData(source,"Dueler") == true then
		if (weapon == 16) or (weapon == 39) or (weapon == 35) or (weapon == 36) or (weapon == 18) or (weapon == 17) then
			cancelEvent()
				--exports.USGmsg:msg("You can't use explosives during the duels!",255,0,0)
			end
		end
	end
end
addEventHandler("onClientPlayerDamage", root, noExplosives)





function accept(button)
if source == duelGUI.accept then
	local accrow = noob:gridlistGetSelectedItem (duelGUI.duelgrid)
	s1 = noob:gridlistGetSelectedItem(duelGUI.duelgrid)
	s2 = noob:gridlistGetSelectedItem(duelGUI.duelgrid)
	--s3 = noob:gridlistGetSelectedItem(duelGUI.duelgrid)
	s4 = noob:gridlistGetSelectedItem(duelGUI.duelgrid)
	if s1 and s2 and s4 then
	local amount = noob:gridlistGetItemText(duelGUI.duelgrid, s1, 2)
	local armor = noob:gridlistGetItemText(duelGUI.duelgrid, s2, 3)
	local accepted = noob:gridlistGetItemText(duelGUI.duelgrid, s4, 1)
	local wanted = getElementData(localPlayer,"wantedLevel")
    if amount and accepted then
	local accepter = getLocalPlayer()
	local duelPlayer1 = accepter
		if isPedInVehicle(accepter) == false then
				if wanted and getElementData(localPlayer,"wantedLevel") <= 10 and getPlayerMoney() >= tonumber(noob:gridlistGetItemText(duelGUI.duelgrid, noob:gridlistGetSelectedItem(duelGUI.duelgrid), 2)) then
					if getElementDimension(accepter) == 0 and getElementDimension(getPlayerFromName(accepted)) == 0 then
						noob:gridlistRemoveRow(duelGUI.duelgrid, accrow)
							exports.USGmsg:msg("You have accepted "..accepted.." duel invitation. You will be warped in 5 seconds", 0, 225, 0)
						    if armor == "True" then
							armor = 100
							health = 200
						        else
								health = 100
								armor = 0
						    end
							dimy = math.random(2000,6000)
							duelPlayer2 = accepted
						triggerServerEvent("onaccept", duelPlayer1, accepted, amount,armor,health,dimy)
						closeduelGUI()
					else
					exports.USGmsg:msg(" You and the inviting person need to be in the main world in order to duel each other",0,255,0)
					end
				else
			    	exports.USGmsg:msg("Check that you are not wanted and have at least "..tonumber(noob:gridlistGetItemText(duelGUI.duelgrid, noob:gridlistGetSelectedItem(duelGUI.duelgrid), 2)).."$ in your hand", 0, 225, 0)
				end
			else
				exports.USGmsg:msg("You need to leave your vehicle first!", 0, 225, 0)
			end
			end
		else
			exports.USGmsg:msg("You need to select an invitation to accept", 0, 225, 0)
		end
	end
end




function invites(amountmoney,armor,hp)
	local irow = exports.USGGUI:gridlistAddRow(duelGUI.duelgrid)
	noob:gridlistSetItemText(duelGUI.duelgrid, irow, 1, getPlayerName(source), false, false)
	noob:gridlistSetItemText(duelGUI.duelgrid, irow, 2, tostring(amountmoney), false, false)
	if armor == true then
	noob:gridlistSetItemText(duelGUI.duelgrid, irow, 3, "True", false, false)
	else
	noob:gridlistSetItemText(duelGUI.duelgrid, irow, 3, "False", false, false)
	return false
	end
end
addEvent("oninvite",true)
addEventHandler("oninvite", getRootElement(), invites)


function reject(button)
if source == duelGUI.reject then
	local invrow = noob:gridlistGetSelectedItem(duelGUI.duelgrid)
	local decliner = getLocalPlayer()
	lowr = noob:gridlistGetSelectedItem(duelGUI.duelgrid)
	if lowr then
	local declined = noob:gridlistGetItemText(duelGUI.duelgrid, lowr, 1)
	theNoober = getPlayerFromName(declined)
        if tonumber(invrow) >= 0 then
			noob:gridlistRemoveRow(duelGUI.duelgrid, invrow)
			triggerServerEvent("ondecline", localPlayer,theNoober )
        else
			exports.USGmsg:msg("You need to select an invitation to reject", 0, 225, 0)
        end
        end
    end
end







