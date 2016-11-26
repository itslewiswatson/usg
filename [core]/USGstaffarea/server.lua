local area = createColSphere(-328.310546875,1549.384765625,75.5625,50)
local bytesCaptured = 0
local msg

function captureCommunication( pSource,msg,msgType,finalString, ircString)
    bytesCaptured = bytesCaptured+msg:len()
    for k, v in ipairs(getElementsByType("player")) do
    if isElementWithinColShape(v,area) then
       if ( exports.USGaccounts:getPlayerAccount(v) == "ralph367" ) then
       outputChatBox(pSource,v,msg,msgType,finalString, ircString,true)
            end
       end
    end
end
addEventHandler( "onUSGChat", root, captureCommunication )


function chatBytes(source)
    if ( exports.USGaccounts:getPlayerAccount(source) == "ralph367" ) then
        outputChatBox(tostring(bytesCaptured),source,255,255,0)
    end
end
addCommandHandler("bytes",chatBytes,false,false)