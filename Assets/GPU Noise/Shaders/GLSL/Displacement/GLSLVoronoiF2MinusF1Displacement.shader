Shader "GPU Noise/GLSL/Voronoi F2-F1 Displacement" 
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
			
            varying vec3 TexCoord;

            #ifdef VERTEX

			// displaces the vertex based upon the noise result
            void main()
            { 
				vec3 texcoord = gl_MultiTexCoord0.xyz;
				
				// use some "magic" to make the 3D noise displace AND animate
				texcoord = gl_Vertex.xyz * 4.0 + 0.2 * vec3(perlin(gl_Vertex.xyz + vec3(0.0, 0.0, time)),
															perlin(gl_Vertex.xyz + vec3(43.0, 17.0, time)),
															perlin(gl_Vertex.xyz + vec3(0.0, -43.0, time-17.0)));
															   
				float heightValue = voronoif2minusf1(vec3(texcoord * noiseScale)) * heightScale;
				
				// displace the vertex in the direction of its normal
				vec4 vertex = gl_Vertex; // can't modify an attribute in GLSL, so we must copy it
				vertex.xyz += gl_Normal * heightValue;
				gl_Position = gl_ModelViewProjectionMatrix * vertex;
				TexCoord = texcoord;
            }

            #endif

            #ifdef FRAGMENT

            void main()
            {                
                float result = voronoif2minusf1(vec3(TexCoord * noiseScale));
				gl_FragColor = mix(lowColor, highColor, result);
            }

            #endif

            ENDGLSL
        }
    }
    Fallback "Unlit/Texture"
}