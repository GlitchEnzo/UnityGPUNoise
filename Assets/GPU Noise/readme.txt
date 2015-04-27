GPU Noise
---------------------

Nine different types of noise functions for use in shaders!  Have the power of Perlin Noise and Voronoi Noise (aka Worley Noise, aka Cell Noise) with the blazing fast speed of the GPU!  2D, 3D and 4D Perlin Noise with various summations (fractional Brownian motion, turbulence, ridged mulifractal).  2D and 3D Voronoi Noise (F1) with its variations (F2, F2 - F1, F1 + F2 / 2, Crater).

Use them in a vertex shader to warp/displace a mesh.  Use them in a pixel shader to procedurally texture a mesh.  They can all be animated!

Online Example:
http://re-creationstudios.com/unity/noise/


Example Scenes
---------------------

There are an example scene included in this package to help illustrate how to use the noise functions. (When running the scene, there is a button at the upper right that allows you to toggle between the 2D Animation and 3D Displacement.)

3D Displacement: This mode shows a sphere that is displaced via noise in the vertex shader and then procedurally textured using noise in the pixel shader.
2D Animation: This mode shows the same noise functions but on a 2D screen-space quad to allow closer inpection of the procedurally textured and animated results.

Here are the 9 noise types as used in the example scene:

Perlin        - "Standard" Perlin Noise (1 octave)
fBm           - fractional Brownian motion summation of Perlin Noise (12 octaves)
Turbulence    - fBm variation that sums the absolute value of the noise result (12 octaves)
Ridged        - fBm variation  that performs a special ridge function on the noise result (12 octaves)
Voronoi (F1)  - A "noise" type that uses a field of random 3D points and determines the distance to the closest point
F2            - Voronoi that determines the distance to the second closest point
F2 - F1       - Voronoi that determines the difference between the distances of the first and second closest points
(F1 + F2) / 2 - Voronoi that averages the distance between the two closest points
Crater        - Voronoi variation that makes crater-like structures


Usage
----------------------

The noise functions are implemented as a Cg include file (noise.cginc).  You must include this file in your shader in order to have access to the functions.  You do this by adding the following include line:

#include "noise.cginc" 

This is a relative path, so the example shaders use "../noise.cginc" since the include file is located in one directory above the shaders.

In order to use the functions, you must target Shader Model 3.0 or later in order to have enough instructions available.  This means that you must explicitly state it in your shader code.   You do this by adding the following line:

#pragma target 3.0


Additional Notes
----------------------

While these noise functions are quite fast, they were also designed to be highly cross-platform.  They can be further optimized by utilizing textures containing precomputed data passed into the shaders, however this causes extra complexity in initially setting things up and porting it to other platforms.  Thus, it is more suited for desktop-only type games/applications.  I have already implemented these optimized shaders in Unity (as well as the texture generation functions) and if there is enough demand for them (email me if interested) then I will post them on the Asset Store as well.

Please refer to the comments in the code, as well as the example scene for more information.

Feel free to contact me if you have any questions or issues: mccarthp@gmail.com