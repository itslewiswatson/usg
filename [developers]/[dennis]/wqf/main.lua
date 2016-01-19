local trailers = {}
local hooktruck = {}

addCommandHandler ("trailers",
	function (thePlayer, cmd, trailernum)
		if not trailernum then outputChatBox ("* Syntax is: /trailers number", thePlayer, 255, 0, 0) return end
		local num = tonumber (trailernum)
		if type (num) ~= "number" then outputChatBox ("* Invalid trailer number provided", thePlayer, 255, 0, 0) return end
		
		if not trailers[thePlayer] then trailers[thePlayer] = {} end
		if not hooktruck[thePlayer] then hooktruck[thePlayer] = {} end
		
		local myVeh = getPedOccupiedVehicle (thePlayer)
		for i=1, num do
			-- if it's the first trailer, attach it to the original truck
			if i == 1 then
				trailers[thePlayer][1] = createVehicle (591, 0, 0, 10)
				setElementRotation (trailers[thePlayer][1], getElementRotation (myVeh))
				setTimer (attachTrailerToVehicle, 200, 1, myVeh, trailers[thePlayer][1])
				
			-- if it's not then
			else
				-- Here we are creating invisible trucks and attaching them to the back of each trailer so we can have multiple trailers
				hooktruck[thePlayer][i-1] = createVehicle (514, 0, 0, 10)
				setElementAlpha (hooktruck[thePlayer][i-1], 0)
				setElementCollisionsEnabled (hooktruck[thePlayer][i-1], false)
				setVehicleDamageProof (hooktruck[thePlayer][i-1], true)
				setElementRotation (hooktruck[thePlayer][i-1], getElementRotation (myVeh))
				addEventHandler ("onVehicleStartEnter", hooktruck[thePlayer][i-1], cancelRoadtrainEntering)
				setTimer (attachElements, 300 * i, 1, hooktruck[thePlayer][i-1], trailers[thePlayer][i-1], 0, -0.1, 0)
				
				-- Let's create our trailer for attaching to invisible trucks
				trailers[thePlayer][i] = createVehicle (591, 2000, 2000, 500)
				setElementRotation (trailers[thePlayer][i], getElementRotation (myVeh))
				setTimer (attachTrailerToVehicle, 400 * i, 1, hooktruck[thePlayer][i-1], trailers[thePlayer][i])
			end
		end
	end
)

function cancelRoadtrainEntering ()
	cancelEvent()
end
