Shader "GPU Noise/Voronoi Displacement" 
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
				float3 texcoord: TEXCOORD1;
			};

            // displaces the vertex based upon the noise result
			v2f vert (appdata_base v)
			{
				v2f o;
				
				// use some "magic" to make the 3D noise displace AND animate
				o.texcoord = v.vertex.xyz * 4.0 + 0.2 * float3(perlin(v.vertex.xyz + float3(0.0, 0.0, time)),
															   perlin(v.vertex.xyz + float3(43.0, 17.0, time)),
															   perlin(v.vertex.xyz + float3(0.0, -43.0, time-17.0)));
															   
				float heightValue = voronoi(float3(o.texcoord * noiseScale)).x * heightScale;
				
				// displace the vertex in the direction of its normal
				v.vertex.xyz += v.normal * heightValue;
				o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
				o.normal = v.normal;
				return o;
			}

            // color the pixel based upon the same noise result
			float4 frag (v2f i) : COLOR
			{
				float result = voronoi(float3(i.texcoord * noiseScale)).x;
				return lerp(lowColor, highColor, result);
			}
			ENDCG

		}
	}
} 
