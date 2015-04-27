Shader "GPU Noise/Voronoi F2 3D" 
{
	Properties 
	{
		time ("time", float) = 0
		noiseScale ("noiseScale", float) = 1
		lowColor ("lowColor", Vector) = (0,0,0,1)
		highColor ("highColor", Vector) = (1,1,1,1)
	}
	SubShader 
	{
		Pass 
		{
			CGPROGRAM
			#pragma target 3.0 // we must target Shadel Model 3.0 hardware or later to handle the number of instructions
			#pragma glsl
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"
			#include "../noise.cginc"
			
			float time;
			float noiseScale;
			float4 lowColor;
			float4 highColor;

			struct v2f 
			{
				float4 pos : POSITION0;
				float2  uv : TEXCOORD0;
			};

			// simple pass-through vertex shader (no transformation)
			v2f vert (appdata_base v)
			{
				v2f o;
				o.pos = v.vertex;
				o.uv = v.texcoord;

				return o;
			}

			float4 frag (v2f i) : COLOR
			{
				float result = voronoif2(float3(i.uv * noiseScale, time));
				return lerp(lowColor, highColor, result);
			}
			ENDCG

		}
	}
} 
