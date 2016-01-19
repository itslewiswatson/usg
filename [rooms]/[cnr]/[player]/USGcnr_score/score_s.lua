function givePlayerScore(player, score)
	if(not isElement(player)) then return false end
	local pScore = getElementData(player, "score")
	if(pScore) then
		setElementData(player, "score", pScore+score)
		return true
	else
		return false
	end
end
function takePlayerScore(player, score)
	if(not isElement(player)) then return false end
	local pScore = getElementData(player, "score")
	if(pScore) then
		setElementData(player, "score", pScore-score)
		return true
	else
		return false
	end
end