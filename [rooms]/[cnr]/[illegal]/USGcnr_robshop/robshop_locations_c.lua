local burgerSkin = 205
local cluckinSkin = 167
local pizzaSkin = 155

local locations = {
	-- burger
	{x = 377.443359375, y = -65.5146484375, z = 1001.5078125, rz = 180, skin = burgerSkin, int = 10, intIDPart = "FDBURG"},
	-- clucking
	{x = 369.384765625, y = -4.3486328125, z = 1001.8515625, rz = 180, skin = cluckinSkin, int = 9, intIDPart = "FDCHICK"},
	-- pizza
	{x = 375.4169921875, y = -117.0751953125, z = 1001.4921875, rz = 180, skin = pizzaSkin, int = 5, intIDPart = "FDPIZA"},
}
pedLocation = {}

local locationsLoaded = false

addEvent("onClientInteriorWarped", true)
function initLocations()
	if(not locationsLoaded) then
		locationsLoaded = true
		local pInt = getElementInterior(localPlayer)
		local pDim = getElementDimension(localPlayer)
		for i, location in ipairs(locations) do
			local ped = createPed(location.skin, location.x, location.y, location.z)
			setElementFrozen(ped, true)
			if(pInt == location.int) then
				setElementDimension(ped, pDim)
			else
				setElementDimension(ped, 0)
			end
			setElementRotation(ped, 0, 0, location.rz)
			addEventHandler("onClientPedDamage", ped, onPedDamage)
			setElementInterior(ped, location.int)
			pedLocation[ped] = location
			location.ped = ped
		end
		addEventHandler("onClientInteriorWarped", root, onInteriorWarped)
	end
end


function removeLocations()
	if(locationsLoaded) then
		locationsLoaded = false
		removeEventHandler("onClientInteriorWarped", root, onInteriorWarped)
		for i, location in ipairs(locations) do
			if(isElement(location.ped)) then 
				destroyElement(location.ped)
			end
		end
	end
	pedLocation = {}
end

function onPedDamage()
	cancelEvent()
end

function onInteriorWarped()
	if(getElementType(source) == "interiorReturn") then return end -- exiting a shop
	local id = exports.USGcnr_interiors:getInteriorName(source)
	local dimension = getElementDimension(localPlayer)
	if(id) then
		for i, location in ipairs(locations) do
			if(id:find(location.intIDPart)) then
				setElementDimension(location.ped, dimension)
				break
			end
		end
	end
end
