Shader "GPU Noise/GLSL/Turbulence Displacement" 
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
            GLSLPROGRAM
            #include "../mobilenoise.glslinc";
            
            precision mediump float;
            
            uniform float time;
			uniform float heightScale;
			uniform float noiseScale;
			uniform vec4 lowColor;
			uniform vec4 highColor;
			
            varying vec3 Normal;

            #ifdef VERTEX

			// displaces the vertex based upon the noise result
            void main()
            { 
				float heightValue = turbulence(vec4(gl_Normal * noiseScale, time)) * heightScale;
				
				// displace the vertex in the direction of its normal
				vec4 vertex = gl_Vertex; // can't modify an attribute in GLSL, so we must copy it
				vertex.xyz += gl_Normal * heightValue;
				gl_Position = gl_ModelViewProjectionMatrix * vertex;
				Normal = gl_Normal;
            }

            #endif

            #ifdef FRAGMENT

            void main()
            {                
                float result = turbulence(vec4(Normal * noiseScale, time)) * 0.5 + 0.5;
				gl_FragColor = mix(lowColor, highColor, result);
            }

            #endif

            ENDGLSL
        }
    }
    Fallback "Unlit/Texture"
}