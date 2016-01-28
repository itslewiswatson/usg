local currentRank = "Current rank"
local nextRank = "Next Rank"
local currentJobExp = 0
local totalExpRequired = 0

--Tables
local jobRanks = false
local jobBonus = false
local jobRewards = false

-- -------------------------------
-- Job Progress UI
-- -------------------------------
function createGUI()
	local sX, sY = guiGetScreenSize()

	window = guiCreateWindow((sX - 570) / 2, (sY - 260) / 2, 503, 393, "USG ~ Job Progress", false)

	tabPanel = guiCreateTabPanel(9, 21, 484, 318, false, window)

	currentJobTab = guiCreateTab("Current Job Progress", tabPanel)

	jobNameLabel = guiCreateLabel(12, 4, 464, 18, "jobName", false, currentJobTab)
	guiLabelSetColor(jobNameLabel, 203, 216, 56)
	guiLabelSetHorizontalAlign(jobNameLabel, "center", false)
	guiLabelSetVerticalAlign(jobNameLabel, "center")

	expProgBar = guiCreateProgressBar(11, 26, 465, 49, false, currentJobTab)
	guiProgressBarSetProgress(expProgBar, 50)

	expProBarLabel = guiCreateLabel(10, 10, 446, 26, "", false, expProgBar)
	guiLabelSetColor(expProBarLabel, 30, 148, 33)
	guiLabelSetHorizontalAlign(expProBarLabel, "center", false)
	guiLabelSetVerticalAlign(expProBarLabel, "center")

	currentRankDetailsLabel = guiCreateLabel(11, 103, 464, 50, "Current Rank: Nothing\n\nNext Rank: Nothing", false, currentJobTab)
	guiLabelSetHorizontalAlign(currentRankDetailsLabel, "center", false)
	guiLabelSetVerticalAlign(currentRankDetailsLabel, "center")
	line01 = guiCreateLabel(11, 85, 464, 18, "---------------------------------------------------------------------------------------------------------------------------", false, currentJobTab)
	line02 = guiCreateLabel(11, 153, 464, 18, "---------------------------------------------------------------------------------------------------------------------------", false, currentJobTab)

	jobRanksGridlist = guiCreateGridList(10, 173, 215, 110, false, currentJobTab)
	rankNameCol = guiGridListAddColumn(jobRanksGridlist, "Rank", 0.9)

	jobRanksTitleLabel = guiCreateLabel(235, 171, 240, 20, "Job ranks", false, currentJobTab)
	guiLabelSetHorizontalAlign(jobRanksTitleLabel, "center", false)
	guiLabelSetVerticalAlign(jobRanksTitleLabel, "center")

	jobRanksRankNameLabel = guiCreateLabel(234, 191, 240, 20, "Rank Name: King of the Quarry", false, currentJobTab)
	guiLabelSetVerticalAlign(jobRanksRankNameLabel, "center")

	jobRanksNeededExpLabel = guiCreateLabel(234, 211, 240, 20, "Needed EXP: 100,000", false, currentJobTab)
	guiLabelSetVerticalAlign(jobRanksNeededExpLabel, "center")

	jobRanksMoneyBonusLabel = guiCreateLabel(234, 231, 240, 20, "Money bonus: $100,000", false, currentJobTab)
	guiLabelSetVerticalAlign(jobRanksMoneyBonusLabel, "center")

	jobRanksJobBonusLabel = guiCreateLabel(234, 251, 240, 20, "Job Bonus: $1,000", false, currentJobTab)
	guiLabelSetVerticalAlign(jobRanksJobBonusLabel, "center")


	closeBtn = guiCreateButton(370, 349, 123, 34, "Close", false, window)
	guiSetProperty(closeBtn, "NormalTextColour", "FFAAAAAA")

	addEventHandler("onClientGUIDoubleClick", jobRanksGridlist, selectedGridListRank)
	addEventHandler("onClientGUIClick", closeBtn, closeGUI)
	--GUIEditor.button[2] = guiCreateButton(10, 349, 123, 34, "Quit Job", false, GUIEditor.window[1])
	--guiSetProperty(GUIEditor.button[2], "NormalTextColour", "FFAAAAAA")    
end
-- ------------------

function showJobUI()
	if (exports.USGrooms:getPlayerRoom(localPlayer) == "cnr") then
		triggerServerEvent("getJobStats", localPlayer)
	end
end
addCommandHandler("jr", showJobUI)

function closeGUI()
	guiSetVisible(window, false)
	showCursor(false, false)
end

function clientData(currentPlrJobName, currentPlrExp, jobRanksTable)
	if (currentPlrJobName and currentPlrExp and jobRanksTable) then
		if (not isElement(window)) then
			createGUI()
			showCursor(true, true)
		elseif (not guiGetVisible(window)) then
			guiSetVisible(window, true)
			showCursor(true, true)
		end

		currentJobExp = currentPlrExp
		jobRanks = jobRanksTable
		guiSetText(jobNameLabel, currentPlrJobName)
		guiSetText(expProBarLabel, currentJobExp .. "/1 exp")

		--local invertedTable = table_invert(jobRanksTable)

		--[[for k,v in pairs(jobRanksTable) do
			outputChatBox(#k .. ", " .. v)
		end]]
	else
		outputChatBox("Something is missing on sendDataToClient")
	end
end
addEvent("sendDataToClient", true)
addEventHandler("sendDataToClient", root, clientData)

function setGridListData(ranksTable, bonusTable, rewardsTable)
	if (ranksTable) then
		jobBonus = bonusTable
		jobRewards = rewardsTable

		for k,v in pairs(ranksTable) do
			local row = guiGridListAddRow(jobRanksGridlist)

			guiGridListSetItemText(jobRanksGridlist, row, rankNameCol, v.rankName, false, false)
			guiGridListSetItemData(jobRanksGridlist, row, rankNameCol, k)
		end
	end
end
addEvent("populateRankGridList", true)
addEventHandler("populateRankGridList", root, setGridListData)

function selectedGridListRank()
	local selectedItemRow, selectedItemCol = guiGridListGetSelectedItem(jobRanksGridlist)
	local rankName = guiGridListGetItemText(jobRanksGridlist, selectedItemRow, selectedItemCol)
	local neededExp = guiGridListGetItemData(jobRanksGridlist, selectedItemRow, selectedItemCol)

	guiSetText(jobRanksRankNameLabel, "Rank Name: " .. rankName)
	guiSetText(jobRanksNeededExpLabel, "Needed EXP: " .. neededExp)

	if (jobBonus[rankName]) then
		guiSetText(jobRanksMoneyBonusLabel, "Money bonus: " .. exports.USGmisc:convertNumber(jobBonus[rankName]))
	end

	if (jobRewards[rankName]) then
		guiSetText(jobRanksJobBonusLabel, "Job Bonus: " .. exports.USGmisc:convertNumber(jobRewards[rankName]))
	end
end

function table_invert(t)
  local u = { }
  for k, v in pairs(t) do u[v] = k end
  return u
end