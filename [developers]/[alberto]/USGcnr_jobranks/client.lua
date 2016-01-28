local currentRank = "Current rank"
local nextRank = "Next Rank"
local currentJobExp = 0
local totalExpRequired = 0

--Tables
local jobRanks = false
local jobBonus = false
local jobRewards = false

local jobRankNamesTable = {
	["pilot"] = {
		--syntax:
		--[exp needed] = {rankName = the rank name},
		{expNeeded = 0, rankName = "Junior Flight Officer"},
		{expNeeded = 1000, rankName = "Flight Officer"},
		{expNeeded = 2500, rankName = "First Officer"},
		{expNeeded = 5000, rankName = "Captain"},
		{expNeeded = 7500, rankName = "Senior Captain"},
		{expNeeded = 10000, rankName = "Commercial First Officer"},
		{expNeeded = 12500, rankName = "Commercial Captain"},
		{expNeeded = 15000, rankName = "Commercial Senior Captain"},
		{expNeeded = 17500, rankName = "Commercial Commander"},
		{expNeeded = 20000, rankName = "Commercial Senior Commander"},
		{expNeeded = 25000, rankName = "ATP First Officer"},
		{expNeeded = 30000, rankName = "ATP Captain"},
		{expNeeded = 50000, rankName = "ATP Senior Captain"},
		{expNeeded = 75000, rankName = "ATP Commander"},
		{expNeeded = 100000, rankName = "ATP Senior Commander"},
	},

	["trucker"] = {
		{expNeeded = 0, rankName = "Trainee Trucker"},
		{expNeeded = 1000, rankName = "Local Trucker"},
		{expNeeded = 2500, rankName = "FedEx Trucker"},
		{expNeeded = 5000, rankName = "UPS Trucker"},
		{expNeeded = 7500, rankName = "Regular Trucker"},
		{expNeeded = 10000, rankName = "Experienced Trucker"},
		{expNeeded = 15000, rankName = "Respected Trucker"},
		{expNeeded = 25000, rankName = "State Trucker"},
		{expNeeded = 50000, rankName = "SA Transportation Trucker"},
		{expNeeded = 75000, rankName = "King of the Road"},
		{expNeeded = 100000, rankName = "Trucking Tycoon"},
	},

	["medic"] = {
		{expNeeded = 0, rankName = "Medical Student"},
		{expNeeded = 1000, rankName = "Cleveland Clinic Doctor"},
		{expNeeded = 2500, rankName = "General Practitioner"},
		{expNeeded = 5000, rankName = "Foundation Medic"},
		{expNeeded = 7500, rankName = "Assistant Doctor"},
		{expNeeded = 10000, rankName = "Consultant"},
		{expNeeded = 25000, rankName = "Middle-grade Doctor"},
		{expNeeded = 50000, rankName = "Specialist"},
		{expNeeded = 75000, rankName = "Surgeon"},
		{expNeeded = 100000, rankName = "Elite Doctor"},
	},

	["quarryMiner"] = {
		{expNeeded = 0, rankName = "Trainee Quarry Miner"},
		{expNeeded = 1000, rankName = "Field Operator I"},
		{expNeeded = 2500, rankName = "Field Operator II"},
		{expNeeded = 5000, rankName = "Field Operator III"},
		{expNeeded = 7500, rankName = "Field Operator IV"},
		{expNeeded = 10000, rankName = "Mine Engineer I"},
		{expNeeded = 15000, rankName = "Mine Engineer II"},
		{expNeeded = 20000, rankName = "Mine Engineer III"},
		{expNeeded = 25000, rankName = "Mine Engineer IV"},
		{expNeeded = 50000, rankName = "Geologist I"},
		{expNeeded = 75000, rankName = "Geologist II"},
		{expNeeded = 100000, rankName = "King of the Quarry"},
	},
}

local jobNameFromDataName = {
	["criminal"] = "Criminal",
	["medic"] = "Paramedic",
	["pilot"] = "Pilot",
	["policeOfficer"] = "Police Officer",
	["quarryMiner"] = "Quarry Miner",
	["trucker"] = "Trucker",
	["Mechanic"] = "Mechanic",
}

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

function clientData(currentPlrJobName, currentPlrExp, jobRanksTable, currentPlrRankName)
	if (currentPlrJobName and currentPlrExp and jobRanksTable and currentPlrRankName) then
		if (not isElement(window)) then
			createGUI()
			showCursor(true, true)
		elseif (not guiGetVisible(window)) then
			guiSetVisible(window, true)
			showCursor(true, true)
		end

		currentJobExp = currentPlrExp
		jobRanks = jobRanksTable

		if (jobNameFromDataName[currentPlrJobName]) then
			guiSetText(jobNameLabel, jobNameFromDataName[currentPlrJobName])

			for k,v in pairs(jobRankNamesTable[currentPlrJobName]) do
				if (v.rankName == currentPlrRankName) then
					--outputChatBox("1: " .. v.rankName .. ", " .. v.expNeeded)
					--outputChatBox("2: " .. jobRankNamesTable[currentPlrJobName][k+1].rankName .. ", " .. jobRankNamesTable[currentPlrJobName][k+1].expNeeded)
					guiSetText(expProBarLabel, currentJobExp .. "/" .. v.expNeeded .. " exp")
					guiSetText(currentRankDetailsLabel, "Current Rank: " .. currentPlrRankName .. "\n\nNext Rank: " .. jobRankNamesTable[currentPlrJobName][k+1].rankName)
				end
			end
		end

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
	guiSetText(jobRanksNeededExpLabel, "Needed EXP: " .. exports.USGmisc:convertNumber(neededExp))

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