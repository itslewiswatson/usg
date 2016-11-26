-- FUNCTIONS

function getPlayerChatZone(player)
	if ( isElement(player or getLocalPlayer()) ) then -- if player OR we are clientside
		local city = "LV"
		for i=1,#chatZoneCols do
			if ( isElementWithinColShape(player or getLocalPlayer(),chatZoneCols[i]) ) then
				city = chatZonesData[i].name
				break
			end
		end
		return city
	end
	return false
end

function getPlayersInChatZone(zone)
	if ( zone ~= "LV" ) then
		for i=1,#chatZonesData do
			if ( zone == chatZonesData[i].name ) then
				return getElementsWithinColShape(chatZoneCols[i])
			end
		end
	else
		
	end
end

function getPlayerTeamColor(player)
	local pTeam = getPlayerTeam(player)
	local r,g,b = 100,100,100
	if(pTeam) then
		r,g,b = getTeamColor(pTeam)
	end
	return r,g,b
end

function getPlayerColoredName(player,restoreHex)
	if(not isElement(player)) then return false end
	local phex
	if(exports.USGrooms:getPlayerRoom(player) == "cnr") then
		phex = exports.USG:convertRGBToHEX(getPlayerTeamColor(player))
	else
		if(exports.USGadmin:isPlayerStaff(player)) then
			phex = "#0BFF0B"
		else
			phex = "#FFFFFF"
		end
	end
	return phex..getPlayerName(player)..(restoreHex or "#FFFFFF")
end

function getPedMaxHealth(ped)
	if(not isElement(ped) or ( getElementType(ped) ~= "player" and getElementType(ped) ~= "ped")) then return false end
	return 100 + ( 100 / 431 * ( getPedStat(ped, 24) - 569 ) )
end

function validateMarkerZ(marker, element)
	if(not element and localPlayer) then element = localPlayer end
	if(not isElement(element)) then
		error("Invalid element!")
	elseif(not isElement(marker)) then
		error("Invalid marker!")
	end
	local _,_,mz = getElementPosition(marker)
	local _,_,ez = getElementPosition(element)
	return math.abs(mz-ez) <= 3
end

-- UTILITY

function convertRGBToHSV(r, g, b)
  r, g, b = r / 255, g / 255, b / 255
  local max, min = math.max(r, g, b), math.min(r, g, b)
  local h, s, v
  v = max

  local d = max - min
  if max == 0 then s = 0 else s = d / max end

  if max == min then
    h = 0 -- achromatic
  else
    if max == r then
    h = (g - b) / d
    if g < b then h = h + 6 end
    elseif max == g then h = (b - r) / d + 2
    elseif max == b then h = (r - g) / d + 4
    end
    h = h / 6
  end

  return h, s, v
end

function convertHSVToRGB(h, s, v)
  local r, g, b

  local i = math.floor(h * 6);
  local f = h * 6 - i;
  local p = v * (1 - s);
  local q = v * (1 - f * s);
  local t = v * (1 - (1 - f) * s);

  i = i % 6

  if i == 0 then r, g, b = v, t, p
  elseif i == 1 then r, g, b = q, v, p
  elseif i == 2 then r, g, b = p, v, t
  elseif i == 3 then r, g, b = p, q, v
  elseif i == 4 then r, g, b = t, p, v
  elseif i == 5 then r, g, b = v, p, q
  end

  return r * 255, g * 255, b * 255
end

function convertRGBToHEX(red, green, blue, alpha)
	if((red < 0 or red > 255 or green < 0 or green > 255 or blue < 0 or blue > 255) or (alpha and (alpha < 0 or alpha > 255))) then
		return nil
	end
	if(alpha) then
		return string.format("#%.2X%.2X%.2X%.2X", red,green,blue,alpha)
	else
		return string.format("#%.2X%.2X%.2X", red,green,blue)
	end
end

function formatMoney(money)
	local formatted = money
	while true do
		formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
		if (k==0) then break end
	end
	return "$"..formatted
end

local getFormatTime = function (seconds)
	local theTime = getRealTime(seconds or nil )
	theTime.year = theTime.year + 1900
	theTime.month = theTime.month + 1
	
	for k,v in pairs(theTime) do
		if ( tonumber(v) and tonumber(v) < 10 ) then
			theTime[k] = "0"..tostring(v)
		end
	end
	return theTime
end

function getDateTimeString(seconds)
	local theTime = getFormatTime(seconds)
	return theTime.year.."-"..theTime.month.."-"..theTime.monthday.." "..theTime.hour..":"..theTime.minute..":"..theTime.second
end

function getTimeString(seconds)
	local theTime = getFormatTime(seconds)
	return theTime.hour..":"..theTime.minute..":"..theTime.second
end

function getDateString(seconds)
	local theTime = getFormatTime(seconds)
	return theTime.year..":"..theTime.month..":"..theTime.monthday
end

local matches = { ["^"] = "%^"; ["$"] = "%$"; ["("] = "%("; [")"] = "%)"; ["%"] = "%%"; ["."] = "%.";
	["["] = "%["; ["]"] = "%]"; ["*"] = "%*"; ["+"] = "%+"; ["-"] = "%-"; ["?"] = "%?"; ["\0"] = "%z"; }
 
function escapeString(s)
    return (s:gsub(".", matches))
end

function trimString(s)
  return (s:gsub("^%s*(.-)%s*$", "%1"))
end