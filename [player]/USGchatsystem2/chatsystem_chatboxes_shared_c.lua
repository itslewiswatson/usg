local showArabic = false
local showFrench = false
local showRussian = false
local showSpanish = false

function toggleAR ()
	if (showArabic == false) then 
		showArabic = true
	else 
		showArabic = false
	end
end
addCommandHandler("showar", toggleAR)
addCommandHandler("showarabic", toggleAR)

function toggleFR ()
	if (showFrench == false) then 
		showFrench = true
	else 
		showFrench = false
	end
end
addCommandHandler("showfr", toggleFR)
addCommandHandler("showfrench", toggleFR)

function toggleRU ()
	if (showRussian == false) then 
		showRussian = true
	else 
		showRussian = false
	end
end
addCommandHandler("showru", toggleRU)
addCommandHandler("showrussian", toggleRU)

function toggleES ()
	if (showSpanish == false) then 
		showSpanish = true
	else 
		showSpanish = false
	end
end
addCommandHandler("showes", toggleES)
addCommandHandler("showspanish", toggleES)

function outputArabicChat (finalString)
	if (showArabic == true) then
		outputChatBox(finalString,255,255,255,true)
	end
end
addEvent ("USGchatsystem.onArabic", true)
addEventHandler ("USGchatsystem.onArabic", localPlayer, outputArabicChat, finalString)

function outputFrenchChat (finalString)
	if (showFrench == true) then
		outputChatBox(finalString,255,255,255,true)
	end
end
addEvent ("USGchatsystem.onFrench", true)
addEventHandler ("USGchatsystem.onFrench", localPlayer, outputFrenchChat, finalString)

function outputRussianChat (finalString)
	if (showRussian == true) then
		outputChatBox(finalString,255,255,255,true)
	end
end
addEvent ("USGchatsystem.onRussian", true)
addEventHandler ("USGchatsystem.onRussian", localPlayer, outputRussianChat, finalString)

function outputSpanishChat (finalString)
	if (showSpanish == true) then
		outputChatBox(finalString,255,255,255,true)
	end
end
addEvent ("USGchatsystem.onSpanish", true)
addEventHandler ("USGchatsystem.onSpanish", localPlayer, outputSpanishChat, finalString)