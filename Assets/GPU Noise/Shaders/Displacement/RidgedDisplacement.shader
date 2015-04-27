Shader "GPU Noise/Ridged Displacement" 
{
	Properties 
	{		
		time ("time", float) = 0
		heightScale ("heightScale", float) = 0.5
		noiseScale ("noiseScale", float) = 1
		lowColor ("lowColor", Vector) = (0,0,0,1)
		highColor ("highColor", Vector) = (1,1,1,1)
	}
	SubShader 
	{
		Pass 
		{
			CGPROGRAM
			#pragma target 3.0 // we must target Shadel Model 3.0 hardware or later to have enough intructions
			#pragma glsl
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"
			#include "../noise.cginc"
			
			float time;
			float heightScale;
			float noiseScale;
			float4 lowColor;
			float4 highColor;

			struct v2f 
			{
				float4 pos : SV_POSITION;
				float3 normal : TEXCOORD0;
			};

            // displaces the vertex based upon the noise result
			v2f vert (appdata_base v)
			{
				v2f o;
				float heightValue = ridged(float4(v.normal * noiseScale, time), 8.0) * heightScale; 
				
				// displace the vertex in the direction of its normal
				v.vertex.xyz += v.normal * heightValue;
				o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
				o.normal = v.normal;
				return o;
			}

            // color the pixel based upon the same noise result
			float4 frag (v2f i) : COLOR
			{
				float result = ridged(float4(i.normal * noiseScale, time), 8.0) * 0.5 + 0.5;
				return lerp(lowColor, highColor, result);
			}
			ENDCG

		}
	}
	Fallback "Unlit/Texture"
} 
