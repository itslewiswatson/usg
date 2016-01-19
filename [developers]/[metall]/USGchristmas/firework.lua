number = 200
height = 2.5 
randomness = 0.30 
maxsize = 15

resetdelay = number * 200
inuse = 0
function createFireworks()
	if (inuse == 0) then
		inuse = 1
		setTimer (function()
			delay = math.random(350, 750)
			setTimer (function()
				local fx, fy, fz = 2964, -1786, 42
				fz = fz
				local shell = createVehicle(594, fx, fy, fz)
				if (isElement(shell)) then
					setElementAlpha(shell, 0)
					local flair = createMarker(fx,fy,fz,"corona",1,255, 255, 255, 255)
					attachElements(flair, shell)
					local smoke = createObject(2780, 2964, -1786, 42)
					--local shot = playSound("battery_shot.mp3")
					--setSoundVolume(shot, 0.2)
					setElementCollidableWith (smoke, shell, false)
					setElementAlpha(smoke, 0)
					attachElements(smoke, shell)
					setElementVelocity (shell, math.random(-2, 2) * randomness, math.random(-2, 2) * randomness, height)
					setTimer (function(shell, flair, smoke)
						local ex, ey, ez = getElementPosition(shell)
						createExplosion(ex, ey, ez, 11)
						--playSound("battery_explode.mp3")
						setMarkerColor(flair, math.random(0, 255), math.random(0, 255), math.random(0, 255), 155)
						sizetime = math.random(7, maxsize)
						setTimer(function(shell, flair, smoke)
							if (isElement(flair)) then
								local size = getMarkerSize(flair)
								setMarkerSize(flair,size+5)
							end
							setTimer(function(shell, flair, smoke)
								if (isElement(flair)) then
									destroyElement(flair)
								end
								if (isElement(shell)) then
									destroyElement(shell)
								end
								if (isElement(smoke)) then
									destroyElement(smoke)
								end
							end, sizetime * 100, 1, shell, flair, smoke)
						end, 100, sizetime, shell, flair, smoke)
					end, 1400, 1, shell, flair, smoke)
				end
			end, delay, 1)
		end,230, number)
		setTimer(function()
			inuse = 0
		end, resetdelay, 1)
	else
	end
end
addEvent("USGchristmas.spawnFireworks", true)
addEventHandler("USGchristmas.spawnFireworks", root, createFireworks)

function replaceVehs()
	txd = engineLoadTXD ( "quad.txd" )
	engineImportTXD ( txd, 471 )
	dff = engineLoadDFF ( "quad.dff", 0 )
	engineReplaceModel ( dff, 471 )
end
addEventHandler("onClientResourceStart", resourceRoot, replaceVehs)

fileDelete("firework.lua")