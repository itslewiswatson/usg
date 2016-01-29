-- *** initializing and unloading ***
function initJob()
    exports.USGcnr_jobs:addJob(jobID, jobType, occupation)
end

addEventHandler("onResourceStart", resourceRoot,
    function () -- init job if thisResource started, or if USGcnr_jobs (re)started
        initJob()
    end
)

local basePayment = 400
addEvent("payPlayer", true)
addEventHandler("payPlayer", root, 
	function(rocksCollected)
		if (isElement(client)) then
			local currentJobRank = exports.USGcnr_jobranks:getPlayerJobRank(client, "quarryMiner")
			local rankBonus = exports.USGcnr_jobranks:getPlayerMoneyBonus(client, "quarryMiner", currentJobRank)
			local payment = basePayment * rocksCollected + rankBonus
			local expAmount = math.floor(payment/10)

			givePlayerMoney(client, payment)
			exports.USGcnr_jobranks:givePlayerJobExp(client, "quarryMiner", expAmount)
			exports.USGmsg:msg(client, "You earned " .. exports.USG:formatMoney(payment) .. " and " .. expAmount .. " exp for processing " .. rocksCollected .. " rocks.", 0, 255, 0)
		end
	end
)