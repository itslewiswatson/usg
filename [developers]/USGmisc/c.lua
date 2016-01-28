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

function isPlayerInRange(player,x,y,z,range)
	local pX,pY,pZ = getElementPosition(player)
	return ((x-pX)^2+(y-pY)^2+(z-pZ)^2)^0.5<=range
end

addCommandHandler("clearchat", 
	function()
		local chatLength = getChatboxLayout()["chat_lines"]

		for i=1, chatLength do
			outputChatBox("")
		end
	end
)