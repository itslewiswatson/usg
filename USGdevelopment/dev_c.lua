local startX, startY
local screenWidth, screenHeight = guiGetScreenSize()

function measure1()
    startX,startY = getCursorPosition()
    outputConsole(string.format("%0.4f, %0.4f, %0.0f, %0.0f", startX, startY, startX*screenWidth, startY*screenHeight))
end

function measure2()
    local endX, endY = getCursorPosition()
    outputConsole(string.format("%0.4f, %0.4f, %0.0f, %0.0f", endX, endY, endX*screenWidth, endY*screenHeight))
    local difX, difY = math.abs(endX-startX), math.abs(endY-startY)
    outputConsole(string.format("Difference: %0.4f, %0.4f, %0.0f, %0.0f", difX, difY, difX*screenWidth, difY*screenHeight))
end
addCommandHandler("m1", measure1)
addCommandHandler("m2", measure2)

--[[addEventHandler("onClientDebugMessage", root,
    function (msg,lvl,file, line)
        triggerServerEvent("USGdevelopment.onClientDebugMessage", localPlayer, "["..(lvl or -1).."]"..(file or "")..":"..(line or "").." "..msg)
    end
)
-]]

function convertNumber ( number )  
    local formatted = number  
    while true do      
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')    
        if ( k==0 ) then      
            break   
        end  
    end  
    return formatted
end

function matrix()
outputChatBox(getCameraMatrix())
end 
addCommandHandler("matrix",matrix)