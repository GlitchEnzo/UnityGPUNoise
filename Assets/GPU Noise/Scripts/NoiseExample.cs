using UnityEngine;
using System.Collections;

public enum Mode
{
    Displacement3D,
    Animation2D
}

public class NoiseExample : MonoBehaviour
{
    public Mode currentMode = Mode.Displacement3D;

    // 3D Displacement Materials
    public Material currentDisplacementMaterial;
    public Material perlinDisplacementMaterial;
    public Material fBmDisplacementMaterial;
    public Material turbulenceDisplacementMaterial;
    public Material ridgedDisplacementMaterial;
    public Material voronoiDisplacementMaterial;
    public Material F2DisplacementMaterial;
    public Material F2MinusF1DisplacementMaterial;
    public Material F1PlusF2DisplacementMaterial;
    public Material craterDisplacementMaterial;

    // 2D Animation Materials
    public Material currentMaterial;
    public Material perlinMaterial;
    public Material fBmMaterial;
    public Material turbulenceMaterial;
    public Material ridgedMaterial;
    public Material voronoiMaterial;
    public Material F2Material;
    public Material F2MinusF1Material;
    public Material F1PlusF2Material;
    public Material craterMaterial;

    // GLSL 3D Displacement Materials
    public Material currentGLSLDisplacementMaterial;
    public Material GLSLPerlinDisplacementMaterial;
    public Material GLSLfBmDisplacementMaterial;
    public Material GLSLTurbulenceDisplacementMaterial;
    public Material GLSLRidgedDisplacementMaterial;
    public Material GLSLVoronoiDisplacementMaterial;
    public Material GLSLF2DisplacementMaterial;
    public Material GLSLF2MinusF1DisplacementMaterial;
    public Material GLSLF1PlusF2DisplacementMaterial;
    public Material GLSLCraterDisplacementMaterial;

    // GLSL 2D Animation Materials
    public Material currentGLSLMaterial;
    public Material GLSLPerlinMaterial;
    public Material GLSLfBmMaterial;
    public Material GLSLTurbulenceMaterial;
    public Material GLSLRidgedMaterial;
    public Material GLSLVoronoiMaterial;
    public Material GLSLF2Material;
    public Material GLSLF2MinusF1Material;
    public Material GLSLF1PlusF2Material;
    public Material GLSLCraterMaterial;

    private float time = 0;
    private float heightScale = 0.05f;
    private float noiseScale = 5;
    private bool animate = true;
    private string[] noiseTypes = { "Perlin", "fBm", "Turbulence", "Ridged", "Voronoi", "F2", "F2 - F1", "(F1 + F2) / 2", "Crater" };
    private int currentNoiseSelection = 0;
    private int previousNoiseSelection = 0;

    private Rect lowColorWindow;
    private float lowRed = 0;
    private float lowGreen = 0;
    private float lowBlue = 1;

    private Rect highColorWindow;
    private float highRed = 0;
    private float highGreen = 1;
    private float highBlue = 0;

    private Rect shaderLevelWindow;

    private Mesh sphereMesh;
    private Mesh quadMesh;

    private bool useGLSL;

    void Start()
    {
        // force it to Landscape on mobile (can be set in the Player Settings, too)
        Screen.orientation = ScreenOrientation.Landscape;

        // procedurally build the sphere mesh (for 3D Displacement)
        sphereMesh = Shape3D.CreateSphereMesh(0.5f, 100, 100); // highly tessellated sphere
        //sphereMesh = Shape3D.CreateSphereMesh(0.5f, 10, 10); // low poly sphere

        // use the sphere mesh built-in to Unity
        //GameObject sphere = GameObject.CreatePrimitive(PrimitiveType.Sphere);
        //sphereMesh = sphere.GetComponent<MeshFilter>().mesh;
        //GameObject.DestroyImmediate(sphere);

        // build the mesh (full screen quad) in clip-space (for 2D Animation)
        quadMesh = new Mesh();
        quadMesh.vertices = new Vector3[] { new Vector3(-1, 1), new Vector3(1, 1), new Vector3(-1, -1), new Vector3(1, -1) };
        quadMesh.uv = new Vector2[] { new Vector2(0, 1), new Vector2(1, 1), new Vector2(0, 0), new Vector2(1, 0) };
        quadMesh.triangles = new int[] { 0, 1, 2, 1, 3, 2 };

        // if not on Windows, default to use the GLSL version of noise
        if (!SystemInfo.operatingSystem.ToLower().Contains("windows"))
        {
            Debug.Log("Detected " + SystemInfo.operatingSystem + ". Using GLSL...");
            useGLSL = true;
        }
        else
        {
            Debug.Log("Detected " + SystemInfo.operatingSystem + ". Using Cg...");
        }
    }

    void OnGUI()
    {
        lowColorWindow = new Rect(5, Screen.height - 100 - 5, 200, 100);
        highColorWindow = new Rect(Screen.width - 200 - 5, Screen.height - 100 - 5, 200, 100);
        shaderLevelWindow = new Rect(Screen.width / 2 - 350 / 2, Screen.height / 2 - 100 / 2, 350, 100);

        GUI.Label(new Rect(25, 45, 100, 30), "Noise Scale");
        noiseScale = GUI.HorizontalSlider(new Rect(25, 70, 100, 20), noiseScale, 1.0f, 20.0f);
        animate = GUI.Toggle(new Rect(25, 90, 100, 30), animate, " Animate");
        useGLSL = GUI.Toggle(new Rect(25, 120, 100, 30), useGLSL, " Use GLSL");
        GUI.Label(new Rect(25, 150, 100, 30), "Noise Type");
        currentNoiseSelection = GUI.SelectionGrid(new Rect(25, 170, 100, 200), previousNoiseSelection, noiseTypes, 1);

        if (currentNoiseSelection != previousNoiseSelection)
        {
            switch (currentNoiseSelection)
            {
                case 0: 
                    currentDisplacementMaterial = perlinDisplacementMaterial;
                    currentGLSLDisplacementMaterial = GLSLPerlinDisplacementMaterial;
                    currentMaterial = perlinMaterial;
                    currentGLSLMaterial = GLSLPerlinMaterial; 
                    break;
                case 1: 
                    currentDisplacementMaterial = fBmDisplacementMaterial;
                    currentGLSLDisplacementMaterial = GLSLfBmDisplacementMaterial;
                    currentMaterial = fBmMaterial;
                    currentGLSLMaterial = GLSLfBmMaterial; 
                    break;
                case 2: 
                    currentDisplacementMaterial = turbulenceDisplacementMaterial;
                    currentGLSLDisplacementMaterial = GLSLTurbulenceDisplacementMaterial;
                    currentMaterial = turbulenceMaterial;
                    currentGLSLMaterial = GLSLTurbulenceMaterial; 
                    break;
                case 3: 
                    currentDisplacementMaterial = ridgedDisplacementMaterial;
                    currentGLSLDisplacementMaterial = GLSLRidgedDisplacementMaterial;
                    currentMaterial = ridgedMaterial;
                    currentGLSLMaterial = GLSLRidgedMaterial; 
                    break;
                case 4: 
                    currentDisplacementMaterial = voronoiDisplacementMaterial;
                    currentGLSLDisplacementMaterial = GLSLVoronoiDisplacementMaterial;
                    currentMaterial = voronoiMaterial;
                    currentGLSLMaterial = GLSLVoronoiMaterial; 
                    break;
                case 5: 
                    currentDisplacementMaterial = F2DisplacementMaterial;
                    currentGLSLDisplacementMaterial = GLSLF2DisplacementMaterial;
                    currentMaterial = F2Material;
                    currentGLSLMaterial = GLSLF2Material; 
                    break;
                case 6: 
                    currentDisplacementMaterial = F2MinusF1DisplacementMaterial;
                    currentGLSLDisplacementMaterial = GLSLF2MinusF1DisplacementMaterial;
                    currentMaterial = F2MinusF1Material;
                    currentGLSLMaterial = GLSLF2MinusF1Material; 
                    break;
                case 7: 
                    currentDisplacementMaterial = F1PlusF2DisplacementMaterial;
                    currentGLSLDisplacementMaterial = GLSLF1PlusF2DisplacementMaterial;
                    currentMaterial = F1PlusF2Material;
                    currentGLSLMaterial = GLSLF1PlusF2Material; 
                    break;
                case 8: 
                    currentDisplacementMaterial = craterDisplacementMaterial;
                    currentGLSLDisplacementMaterial = GLSLCraterDisplacementMaterial;
                    currentMaterial = craterMaterial;
                    currentGLSLMaterial = GLSLCraterMaterial; 
                    break;
            }

            Debug.Log("Selecting " + noiseTypes[currentNoiseSelection]);
            previousNoiseSelection = currentNoiseSelection;
        }

        lowColorWindow = GUI.Window(0, lowColorWindow, LowColorWindowFunction, "Low Color");
        highColorWindow = GUI.Window(1, highColorWindow, HighColorWindowFunction, "High Color");

        if (currentMode == Mode.Displacement3D)
        {
            GUI.Label(new Rect(Screen.width / 2 - 250 / 2, 0, 250, 30), "Use mouse buttons to rotate view.");

            GUI.Label(new Rect(25, 0, 100, 30), "Height Scale");
            heightScale = GUI.HorizontalSlider(new Rect(25, 25, 100, 30), heightScale, 0.0f, 1.0f);

            if (GUI.Button(new Rect(Screen.width - 150 - 5, 5, 150, 30), "2D Animation"))
                currentMode = Mode.Animation2D;

            if (useGLSL)
            {
                if (SystemInfo.graphicsShaderLevel < 30 || !currentGLSLDisplacementMaterial.shader.isSupported)
                    shaderLevelWindow = GUI.Window(2, shaderLevelWindow, ShaderLevelWindowFunction, "Shader Error");
            }
            else
            {
                if (SystemInfo.graphicsShaderLevel < 30 || !currentDisplacementMaterial.shader.isSupported)
                    shaderLevelWindow = GUI.Window(2, shaderLevelWindow, ShaderLevelWindowFunction, "Shader Error");
            }
        }
        else // Animation2D
        {
            if (GUI.Button(new Rect(Screen.width - 150 - 5, 5, 150, 30), "3D Displacement"))
                currentMode = Mode.Displacement3D;

            if (useGLSL)
            {
                if (SystemInfo.graphicsShaderLevel < 30 || !currentGLSLMaterial.shader.isSupported)
                    shaderLevelWindow = GUI.Window(2, shaderLevelWindow, ShaderLevelWindowFunction, "Shader Error");
            }
            else
            {
                if (SystemInfo.graphicsShaderLevel < 30 || !currentMaterial.shader.isSupported)
                    shaderLevelWindow = GUI.Window(2, shaderLevelWindow, ShaderLevelWindowFunction, "Shader Error");
            }
        }
    }

    void LowColorWindowFunction(int id)
    {
        GUI.Label(new Rect(5, 20, 100, 30), "R");
        lowRed = GUI.HorizontalSlider(new Rect(25, 25, 150, 20), lowRed, 0.0f, 1.0f);
        GUI.Label(new Rect(5, 45, 100, 30), "G");
        lowGreen = GUI.HorizontalSlider(new Rect(25, 50, 150, 20), lowGreen, 0.0f, 1.0f);
        GUI.Label(new Rect(5, 70, 100, 30), "B");
        lowBlue = GUI.HorizontalSlider(new Rect(25, 75, 150, 20), lowBlue, 0.0f, 1.0f);
    }

    void HighColorWindowFunction(int id)
    {
        GUI.Label(new Rect(5, 20, 100, 30), "R");
        highRed = GUI.HorizontalSlider(new Rect(25, 25, 150, 20), highRed, 0.0f, 1.0f);
        GUI.Label(new Rect(5, 45, 100, 30), "G");
        highGreen = GUI.HorizontalSlider(new Rect(25, 50, 150, 20), highGreen, 0.0f, 1.0f);
        GUI.Label(new Rect(5, 70, 100, 30), "B");
        highBlue = GUI.HorizontalSlider(new Rect(25, 75, 150, 20), highBlue, 0.0f, 1.0f);
    }

    void ShaderLevelWindowFunction(int id)
    {
        GUI.Label(new Rect(5, 20, 350, 30), "Your shader model level is " + SystemInfo.graphicsShaderLevel + ". You need 30 (or higher).");

        if (useGLSL)
            GUI.Label(new Rect(5, 40, 350, 40), "Shader supported = " + currentGLSLDisplacementMaterial.shader.isSupported);
        else
            GUI.Label(new Rect(5, 40, 350, 40), "Shader supported = " + currentDisplacementMaterial.shader.isSupported);

        //GUI.Label(new Rect(5, 60, 350, 40), "This is most likely due to Cg to GLSL cross-compiling bugs in Unity.");

        // Make the windows be draggable.
        GUI.DragWindow(new Rect(0, 0, 10000, 10000));
    }

    void Update()
    {
        // the Back button on Android is mapped to the Escape key
        if (Input.GetKeyDown(KeyCode.Escape)) { Application.Quit(); }

        if (currentMode == Mode.Displacement3D)
        {
            if (useGLSL)
            {
                if (animate)
                {
                    time += Time.deltaTime;
                    currentGLSLDisplacementMaterial.SetFloat("time", time);
                }
                currentGLSLDisplacementMaterial.SetFloat("heightScale", heightScale);
                currentGLSLDisplacementMaterial.SetFloat("noiseScale", noiseScale);
                currentGLSLDisplacementMaterial.SetColor("lowColor", new Color(lowRed, lowGreen, lowBlue));
                currentGLSLDisplacementMaterial.SetColor("highColor", new Color(highRed, highGreen, highBlue));
            }
            else // use Cg
            {
                if (animate)
                {
                    time += Time.deltaTime;
                    currentDisplacementMaterial.SetFloat("time", time);
                }
                currentDisplacementMaterial.SetFloat("heightScale", heightScale);
                currentDisplacementMaterial.SetFloat("noiseScale", noiseScale);
                currentDisplacementMaterial.SetColor("lowColor", new Color(lowRed, lowGreen, lowBlue));
                currentDisplacementMaterial.SetColor("highColor", new Color(highRed, highGreen, highBlue));
            }
        }
        else // Animation2D
        {
            if (useGLSL)
            {
                if (animate)
                {
                    time += Time.deltaTime;
                    currentGLSLMaterial.SetFloat("time", time);
                }
                currentGLSLMaterial.SetFloat("noiseScale", noiseScale);
                currentGLSLMaterial.SetColor("lowColor", new Color(lowRed, lowGreen, lowBlue));
                currentGLSLMaterial.SetColor("highColor", new Color(highRed, highGreen, highBlue));
            }
            else // use Cg
            {
                if (animate)
                {
                    time += Time.deltaTime;
                    currentMaterial.SetFloat("time", time);
                }
                currentMaterial.SetFloat("noiseScale", noiseScale);
                currentMaterial.SetColor("lowColor", new Color(lowRed, lowGreen, lowBlue));
                currentMaterial.SetColor("highColor", new Color(highRed, highGreen, highBlue));
            }
        }
    }

    void OnRenderObject()
    {
        // force the mesh to draw, and bypass the normal Unity rendering (lighting, shadowing, etc)
        if (currentMode == Mode.Displacement3D)
        {
            if (useGLSL)
                currentGLSLDisplacementMaterial.SetPass(0);
            else
                currentDisplacementMaterial.SetPass(0);
            Graphics.DrawMeshNow(sphereMesh, Matrix4x4.identity);
        }
        else
        {
            if (useGLSL)
                currentGLSLMaterial.SetPass(0);
            else
                currentMaterial.SetPass(0);
            Graphics.DrawMeshNow(quadMesh, Matrix4x4.identity);
        }
    }
}
