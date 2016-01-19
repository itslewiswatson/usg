function getPunishmentReasons()
	return reasons
end

function getRules(includeInfo)
	if ( includeInfo ) then
		return rules
	elseif rules then
		local compactRules = {}
		for id,rule in ipairs(rules) do
			table.insert(compactRules,rule.text)
		end
		return compactRules
	end
	return false
end
