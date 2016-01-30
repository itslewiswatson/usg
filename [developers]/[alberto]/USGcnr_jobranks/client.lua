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

	["Mechanic"] = {
		{expNeeded = 0, rankName = "Trainee Mechanic"},
		{expNeeded = 1000, rankName = "General Mechanic"},
		{expNeeded = 2500, rankName = "Skilled Mechanic"},
		{expNeeded = 5000, rankName = "Elite Mechanic"},
		{expNeeded = 10000, rankName = "Vehicle Engineer I"},
		{expNeeded = 15000, rankName = "Vehicle Engineer II"},
		{expNeeded = 25000, rankName = "Vehicle Engineer III"},
		{expNeeded = 50000, rankName = "Legendary Mechanic"},
		{expNeeded = 100000, rankName = "Master of Engines"},
	},

	["Pizza Delivery"] = {
		{expNeeded = 0, rankName = "Newbie Pizzaboy"},
		{expNeeded = 1000, rankName = "Dominos Pizzaboy"},
		{expNeeded = 2500, rankName = "Pizza Hut Pizzaboy"},
		{expNeeded = 5000, rankName = "Enthusiast Pizzaboy"},
		{expNeeded = 10000, rankName = "Skilled Pizzaboy"},
		{expNeeded = 15000, rankName = "Professional Pizzaboy"},
		{expNeeded = 25000, rankName = "Elite Pizzaboy"},
		{expNeeded = 50000, rankName = "Legendary Pizzaboy"},
		{expNeeded = 100000, rankName = "Master of Pizzas"},
	},

	["Fisherman"] = {
		{expNeeded = 0, rankName = "Newbie Fisherman"},
		{expNeeded = 1000, rankName = "Local Fisherman"},
		{expNeeded = 5000, rankName = "Skilled Fisherman"},
		{expNeeded = 10000, rankName = "Professional Fisherman"},
		{expNeeded = 25000, rankName = "Elite Fisherman"},
		{expNeeded = 50000, rankName = "Legendary Fisherman"},
		{expNeeded = 100000, rankName = "King of the Ocean"},
	},

	["Street Cleaner"] = {
		{expNeeded = 0, rankName = "Trainee Cleaner"},
		{expNeeded = 1000, rankName = "Enthusiast Cleaner"},
		{expNeeded = 5000, rankName = "Skilled Cleaner"},
		{expNeeded = 10000, rankName = "Professional Cleaner"},
		{expNeeded = 15000, rankName = "Elite Cleaner"},
		{expNeeded = 25000, rankName = "Master Cleaner"},
		{expNeeded = 50000, rankName = "Legendary Cleaner"},
		{expNeeded = 100000, rankName = "Mr Shine"},
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
	["Pizza Delivery"] = "Pizza Delivery",
	["Fisherman"] = "Fisherman",
	["Street Cleaner"] = "Street Cleaner",
}

-- -------------------------------
-- Job Progress UI
-- -------------------------------
function createGUI()
	local sX, sY = guiGetScreenSize()

	window = guiCreateWindow((sX - 570) / 2, (sY - 260) / 2, 503, 393, "USG ~ Current Job Progress", false)

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

	jobRanksRankNameLabel = guiCreateLabel(234, 191, 240, 20, "Rank Name:", false, currentJobTab)
	guiLabelSetVerticalAlign(jobRanksRankNameLabel, "center")

	jobRanksNeededExpLabel = guiCreateLabel(234, 211, 240, 20, "Needed EXP:", false, currentJobTab)
	guiLabelSetVerticalAlign(jobRanksNeededExpLabel, "center")

	jobRanksMoneyBonusLabel = guiCreateLabel(234, 231, 240, 20, "Money bonus:", false, currentJobTab)
	guiLabelSetVerticalAlign(jobRanksMoneyBonusLabel, "center")

	jobRanksJobBonusLabel = guiCreateLabel(234, 251, 240, 20, "Job Bonus:", false, currentJobTab)
	guiLabelSetVerticalAlign(jobRanksJobBonusLabel, "center")


	closeBtn = guiCreateButton(370, 349, 123, 34, "Close", false, window)
	guiSetProperty(closeBtn, "NormalTextColour", "FFAAAAAA")

	addEventHandler("onClientGUIDoubleClick", jobRanksGridlist, selectedGridListRank)
	addEventHandler("onClientGUIClick", closeBtn, closeGUI)
	--GUIEditor.button[2] = guiCreateButton(10, 349, 123, 34, "Quit Job", false, GUIEditor.window[1])
	--guiSetProperty(GUIEditor.button[2], "NormalTextColour", "FFAAAAAA")    
end
-- ------------------

function openWindow()
	if (exports.USGrooms:getPlayerRoom(localPlayer) == "cnr") then
		triggerServerEvent("getJobStats", localPlayer)
	end
end
--addCommandHandler("jr", showJobUI)

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
			guiSetText(jobNameLabel, "Current job: " .. jobNameFromDataName[currentPlrJobName])

			for k,v in pairs(jobRankNamesTable[currentPlrJobName]) do
				if (v.rankName == currentPlrRankName) then
					local nextRankText = ""

					if (jobRankNamesTable[currentPlrJobName][k+1].expNeeded) then
						nextRankText = jobRankNamesTable[currentPlrJobName][k+1].rankName
						nextRankExp = jobRankNamesTable[currentPlrJobName][k+1].expNeeded
					else
						nextRankText = "Max rank reached"
						nextRankExp = 0
					end

					guiSetText(expProBarLabel, currentJobExp .. "/" .. nextRankExp .. " exp")
					guiSetText(currentRankDetailsLabel, "Current Rank: L" .. k .. " - " .. currentPlrRankName .. "\n\nNext Rank: L" .. tostring(k+1) .. " - " .. nextRankText)
					
					local progressValue = currentJobExp / jobRankNamesTable[currentPlrJobName][k+1].expNeeded * 100
					guiProgressBarSetProgress(expProgBar, progressValue)

					break
				end
			end
		end
	end
end
addEvent("sendDataToClient", true)
addEventHandler("sendDataToClient", root, clientData)

function setGridListData(currentJobID, bonusTable, rewardsTable)
	guiGridListClear(jobRanksGridlist)
	if (currentJobID and bonusTable and rewardsTable) then
		jobBonus = bonusTable
		jobRewards = rewardsTable

		for k,v in pairs(jobRankNamesTable[currentJobID]) do
			local row = guiGridListAddRow(jobRanksGridlist)

			guiGridListSetItemText(jobRanksGridlist, row, rankNameCol, v.rankName, false, false)
			guiGridListSetItemData(jobRanksGridlist, row, rankNameCol, v.expNeeded)
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
		guiSetText(jobRanksMoneyBonusLabel, "Rank Reward: $" .. exports.USGmisc:convertNumber(jobBonus[rankName]))
	end

	if (jobRewards[rankName]) then
		guiSetText(jobRanksJobBonusLabel, "Job Bonus: $" .. exports.USGmisc:convertNumber(jobRewards[rankName]))
	end
end

function table_invert(t)
  local u = { }
  for k, v in pairs(t) do u[v] = k end
  return u
end