root = getRootElement()
resourceRoot = getResourceRootElement(getThisResource())

local colorShader, colorTec
local red = 255
local green = 255
local blue = 255

function initShader()

	colorShader, colorTec = dxCreateShader("shaders/coloration.fx")

	if (not colorShader) then
		outputChatBox("Could not create model coloration shader. Please use debugscript 3")
	else
		engineApplyShaderToWorldTexture(colorShader, "ballywall01_64")
	end

end
addEventHandler("onClientResourceStart", resourceRoot, initShader)

function updateShader()
	dxSetShaderValue(colorShader, "newColor", {red/255, green/255, blue/255, 1})
end
addEventHandler("onClientHUDRender", root, updateShader)

function stopShader()
	if (colorShader) then
		destroyElement(colorShader)
		colorShader = nil
	end
end
addEventHandler("onClientResourceStop", resourceRoot, stopShader)