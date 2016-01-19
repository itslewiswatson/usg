function getIRC()
	outputChatBox("Hey, "..getPlayerName(localPlayer).."! USG's IRC is irc.usgmta.co (port 6667) :)", math.random(0, 255), math.random(0, 255), math.random(255, 0))
end
addCommandHandler("irc", getIRC, false, false)

function getForum()
	outputChatBox("Hey, "..getPlayerName(localPlayer).."! USG's forum is usgmta.co :)", math.random(0, 255), math.random(0, 255), math.random(255, 0))
end
addCommandHandler("forum", getForum, false, false)
addCommandHandler("website", getForum, false, false)
addCommandHandler("site", getForum, false, false)

local staff = engineLoadTXD( "AsunaSAO.txd", true )
engineImportTXD(staff, 211)
local staff = engineLoadDFF( "AsunaSAO.dff", 211 )
engineReplaceModel( staff, 211 )