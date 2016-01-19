#include "mta-helper.fx"

float4 newColor = float4(0, 0, 0, 1);

sampler MainSampler = sampler_state
{
    Texture = <gTexture0>;
};

struct VertexShaderInput
{
    float3 Position				: POSITION; 
    float2 TextureCoordinate	: TEXCOORD0;
	float4 Color 				: COLOR0;
};

struct VertexShaderOutput
{
	float4 Position				: POSITION;
	float2 TextureCoordinate	: TEXCOORD0;
	float4 Color 				: COLOR0;
};

VertexShaderOutput VertexShaderFunction(VertexShaderInput input)
{
    VertexShaderOutput output;

	output.Position = MTACalcScreenPosition(input.Position);
    output.TextureCoordinate = input.TextureCoordinate;
	output.Color = MTACalcGTABuildingDiffuse(input.Color);

    return output;
}

float4 PixelShaderFunction(VertexShaderOutput input) : COLOR0
{	
	float4 color = tex2D(MainSampler, input.TextureCoordinate);
	float4 diffuse = input.Color;
	float4 coloration = newColor;
	float4 finalColor = diffuse * color;
	
	float colorVar = (finalColor.r + finalColor.g + finalColor.b)/3;
	finalColor.r = colorVar * newColor.r;
	finalColor.g = colorVar * newColor.g;
	finalColor.b = colorVar * newColor.b;
	
    return finalColor;
}
 
technique ChangeModelColor
{
    pass Pass0
    {
        VertexShader = compile vs_2_0 VertexShaderFunction();
        PixelShader = compile ps_2_0 PixelShaderFunction();
    }
}

// Fallback
technique fallback
{
    pass P0
    {
        // Just draw normally
    }
}