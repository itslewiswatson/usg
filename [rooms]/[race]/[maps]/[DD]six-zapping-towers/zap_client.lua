------------------------------------------------------------------------------------
-- PROJECT: Towers Mania DD
-- VERSION: 1.0
-- DATE: June 2013
-- DEVELOPERS: JR10
-- RIGHTS: All rights reserved by developers
------------------------------------------------------------------------------------

function playExplosionSound()
	exports.towers:playExplosionSound()
end
addEvent("tower.playExplosionSound", true)
addEventHandler("tower.playExplosionSound", root, playExplosionSound)