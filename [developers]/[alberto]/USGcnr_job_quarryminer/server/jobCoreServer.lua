-- *** initializing and unloading ***
function initJob()
    exports.USGcnr_jobs:addJob(jobID, jobType, occupation)
end

addEventHandler("onResourceStart", resourceRoot,
    function () -- init job if thisResource started, or if USGcnr_jobs (re)started
        initJob()
    end
)

local bonusBasedOnRank = {
	["Trainee Quarry Miner"] = 0,
	["Field Operator I"] = 50,
	["Field Operator II"] = 100,
	["Field Operator III"] = 150,
	["Field Operator IV"] = 200,
	["Mine Engineer I"] = 250,
	["Mine Engineer II"] = 300,
	["Mine Engineer III"] = 350,
	["Mine Engineer IV"] = 400,
	["Geologist I"] = 600,
	["Geologist II"] = 750,
	["King of the Quarry"] = 1000,
}

local basePayment = 400
addEvent("payPlayer", true)
addEventHandler("payPlayer", root, 
	function(rocksCollected)
		if (isElement(client)) then
			local currentJobRank = exports.USGcnr_jobranks:getPlayerJobRank(client, "quarryMiner")
			local rankBonus = bonusBasedOnRank[currentJobRank]
			local moneyBonus = rocksCollected * bonusBasedOnRank[currentJobRank]
			local payment = basePayment * rocksCollected + moneyBonus
			local expAmount = math.floor(payment/10)

			givePlayerMoney(client, payment)
			exports.USGcnr_jobranks:givePlayerJobExp(client, "quarryMiner", expAmount)
			exports.USGmsg:msg(client, "You earned" .. exports.USG:formatMoney(payment) .. " and " .. expAmount .. " exp for processing " .. rocksCollected .. " rocks.", 0, 255, 0)
		end
	end
)