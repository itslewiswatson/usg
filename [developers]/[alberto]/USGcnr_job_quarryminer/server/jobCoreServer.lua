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
			local payment = basePayment * rocksCollected

			givePlayerMoney(client, payment)
			exports.USGmsg:msg(client,"Payment: " .. exports.USG:formatMoney(payment) .. " for processing " .. rocksCollected .. " rocks.", 0, 255, 0)
		end
	end
)