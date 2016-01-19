function loadACL()
	local permissions = groupData.myPermissions
	if(not permissions) then error("no permissions", 2) end
	exports.USGGUI:setEnabled(groupGUI.general.updateInfo, permissions.updateInfo == true)
	exports.USGGUI:setProperty(groupGUI.general.groupinfo,"readOnly", permissions.updateInfo ~= true)	
	
	exports.USGGUI:setEnabled(groupGUI.members.invite, permissions.invite == true)
	exports.USGGUI:setEnabled(groupGUI.members.demote, permissions.ranks == true)
	exports.USGGUI:setEnabled(groupGUI.members.promote, permissions.ranks == true)
	exports.USGGUI:setEnabled(groupGUI.members.kick, permissions.ranks == true)

	exports.USGGUI:setEnabled(groupGUI.management.tab, ( groupData.myRank == 6 ) or ( permissions.customRanks == true ) or ( permissions.setColor == true ))
	exports.USGGUI:setEnabled(groupGUI.management.delete, groupData.myRank == 6)
	exports.USGGUI:setEnabled(groupGUI.management.rename, groupData.myRank == 6)
	exports.USGGUI:setEnabled(groupGUI.management.setColor, permissions.setColor == true)
	exports.USGGUI:setEnabled(groupGUI.management.customRankSelector, permissions.customRanks == true)
	if(permissions.customRanks) then exports.USGGUI:setSliderSelectedOption(groupGUI.management.customRankSelector, 1, false) selectCustomRank(7) end
	exports.USGGUI:setEnabled(groupGUI.management.customRankName, permissions.customRanks == true)
	exports.USGGUI:setEnabled(groupGUI.management.customRankOrder, permissions.customRanks == true)
	exports.USGGUI:setEnabled(groupGUI.management.customRankPermissions, permissions.customRanks == true)
	exports.USGGUI:setEnabled(groupGUI.management.customRankAddPermission, permissions.customRanks == true)
	exports.USGGUI:setEnabled(groupGUI.management.customRankRemovePermission, permissions.customRanks == true)
	
	-- alliance
	local myAlliance = groupData.myAlliance or {}
	exports.USGGUI:setProperty(groupGUI.alliance.allianceinfo, "readOnly", myAlliance.isFounder ~= true)
	exports.USGGUI:setEnabled(groupGUI.alliance.updateInfo, myAlliance.isFounder == true)
	exports.USGGUI:setEnabled(groupGUI.alliance.leaveAlliance, groupData.myRank == 6)
	exports.USGGUI:setEnabled(groupGUI.alliancemanagement.tab, groupData.myRank == 6)
	exports.USGGUI:setEnabled(groupGUI.alliancemanagement.delete, myAlliance.isFounder == true)
	exports.USGGUI:setEnabled(groupGUI.alliancemanagement.rename, myAlliance.isFounder == true)
	exports.USGGUI:setEnabled(groupGUI.alliancemanagement.setColor, myAlliance.isFounder == true)
	exports.USGGUI:setEnabled(groupGUI.alliancemanagement.kick, myAlliance.isFounder == true)
	exports.USGGUI:setEnabled(groupGUI.alliancemanagement.removeInvite, myAlliance.isFounder == true)
	exports.USGGUI:setEnabled(groupGUI.alliancemanagement.invite, myAlliance.isFounder == true)
end