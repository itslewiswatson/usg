-- *** initializing and unloading ***
function initJob()
    exports.USGcnr_jobs:addJob(jobID, jobType, occupation)
end

addEventHandler("onResourceStart", resourceRoot,
    function () -- init job if thisResource started, or if USGcnr_jobs (re)started
        initJob()
    end
)

addEvent("payPlayer", true)
addEventHandler("payPlayer", root, 
	function(rocksCollected)
		if (isElement(client)) then
			--Temporary payment
			local payment = 400 * rocksCollected 
			outputChatBox("Payment: $" .. payment, client, 0, 255, 0)
		end
	end
)