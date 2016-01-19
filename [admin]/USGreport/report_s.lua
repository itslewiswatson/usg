
addEvent("USGreport.report", true)
addEventHandler("USGreport.report", root,
    function (name, rule, description, images)
    	local lines = {
    		"REPORT:#FFBBBB[ "..getPlayerName(client).." ] sent a report.",
    		"#FF4444Name: #FFFFFF"..name,
    		"#FF4444Rule: #FFFFFF"..rule,
    		"#FF4444Description: #FFFFFF"..description,
    		"#FF4444Images: #FFFFFF"..images,
			"#FF4444/reports to see the list of reports",
  		}
        for i,player in ipairs(getElementsByType("player")) do
            if(exports.USGadmin:isPlayerStaff(player)) then
            	for _, line in ipairs(lines) do
               		outputChatBox(line, player, 255, 0, 0,  true)
               	end
            end
        end
    end
)
