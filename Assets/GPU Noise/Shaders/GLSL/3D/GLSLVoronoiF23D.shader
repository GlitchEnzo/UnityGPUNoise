Shader "GPU Noise/GLSL/Voronoi F2 3D" 
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
                float result = voronoif2(vec3(TextureCoordinate * vec2(noiseScale, noiseScale), time));
                gl_FragColor = mix(lowColor, highColor, result);
            }

            #endif

            ENDGLSL
        }
    }
    Fallback "Unlit/Texture"
}