-- Tables
local theMarkerID = {}
local intMarkers = getInteriorMarkers ()
tick=getTickCount()
-- When you hit a marker
function onMarkerHitInterior ( hitElement, mathchingDimension )
	if ( theMarkerID[source] ) then
		local markerID = theMarkerID[source]
		if ( getElementType( hitElement ) == "player") and ( mathchingDimension ) then
			local x, y, z = getElementPosition( hitElement )
			if ( z-3 < intMarkers[markerID][3] ) and ( z+3 > intMarkers[markerID][3] ) then
				if not ( getPedOccupiedVehicle( hitElement ) ) then
					if (intMarkers[markerID][12] == "All") or ( ( getPlayerTeam( hitElement ) ) and ( getTeamName( getPlayerTeam( hitElement ) ) == "SWAT" ) or ( getTeamName( getPlayerTeam( hitElement ) ) == "Armed Divisions" ) or ( getTeamName( getPlayerTeam( hitElement ) ) == "Staff" ) or ( getTeamName( getPlayerTeam( hitElement ) ) == intMarkers[markerID][13] ) ) or ( exports.USGcnr_groups:getPlayerGroupName(hitElement ) ) and ( exports.USGcnr_groups:getPlayerGroupName(hitElement ) == intMarkers[markerID][12] ) then
						if getTickCount()-tick <= 500 then return end
						tick = getTickCount()
						setElementPosition( hitElement, intMarkers[markerID][6], intMarkers[markerID][7], intMarkers[markerID][8] )
						setPedRotation( hitElement, intMarkers[markerID][9] )
						setElementDimension( hitElement, intMarkers[markerID][11] )
						if ( getElementInterior( hitElement ) ~= intMarkers[markerID][10] ) then setElementInterior( hitElement, intMarkers[markerID][10], intMarkers[markerID][6], intMarkers[markerID][7], intMarkers[markerID][8] ) end
					end
				end
			end
		end
	end
end

-- Create the markers
for i=1,#intMarkers do
	local x, y, z, int, dim = intMarkers[i][1], intMarkers[i][2], intMarkers[i][3], intMarkers[i][4], intMarkers[i][5]
    local theMarker = createMarker( x, y, z +1, "arrow", 1.5, 255, 165, 0 )
	setElementInterior( theMarker, int, x, y, z +1 )
	setElementDimension( theMarker, dim )
    theMarkerID[theMarker] = i
	addEventHandler( "onMarkerHit", theMarker, onMarkerHitInterior )
end
