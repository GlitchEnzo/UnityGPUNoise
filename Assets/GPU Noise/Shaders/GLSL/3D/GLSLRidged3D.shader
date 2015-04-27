Shader "GPU Noise/GLSL/Ridged Multifractal 3D" 
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
            GLSLPROGRAM
            #include "../mobilenoise.glslinc";
            
            uniform float time;
			uniform float noiseScale;
			uniform vec4 lowColor;
			uniform vec4 highColor;
			
            varying vec2 TextureCoordinate;

            #ifdef VERTEX

			// simple pass-through vertex shader (no transformation)
            void main()
            {
                gl_Position = gl_Vertex;
                TextureCoordinate = gl_MultiTexCoord0.xy;
            }

            #endif

            #ifdef FRAGMENT

            void main()
            {				
                float result = ridged(vec3(TextureCoordinate * vec2(noiseScale, noiseScale), time)) * 0.5 + 0.5;
                gl_FragColor = mix(lowColor, highColor, result);
            }

            #endif

            ENDGLSL
        }
    }
    Fallback "Unlit/Texture"
}