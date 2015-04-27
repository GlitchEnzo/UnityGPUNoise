using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UnityEngine;

/// <summary>
/// If you like this, then check out my "Procedural Primitives" package on the Unity Asset Store, which allows you create
/// spheres, boxes, cylinders, and cones!
/// </summary>
public static class Shape3D
{
    /// <summary>
    /// Creates a <see cref="Mesh"/> filled with vertices forming a sphere.
    /// </summary>
    /// <remarks>
    /// The values are as follows:
    /// Vertex Count   = slices * (stacks - 1) + 2
    /// Triangle Count = slices * (stacks - 1) * 2
    /// 
    /// Default sphere mesh in Unity has a radius of 0.5 with 20 slices and 20 stacks.
    /// </remarks>
    /// <param name="radius">Radius of the sphere. This value should be greater than or equal to 0.0f.</param>
    /// <param name="slices">Number of slices around the Y axis.</param>
    /// <param name="stacks">Number of stacks along the Y axis. Should be 2 or greater. (stack of 1 is just a cylinder)</param>
    public static Mesh CreateSphereMesh(float radius, int slices, int stacks)
    {
        Mesh mesh = new Mesh();
        mesh.name = "SphereMesh";

        float sliceStep = (float)Math.PI * 2.0f / slices;
        float stackStep = (float)Math.PI / stacks;
        int vertexCount = slices * (stacks - 1) + 2;
        int triangleCount = slices * (stacks - 1) * 2;
        int indexCount = triangleCount * 3;

        Vector3[] sphereVertices = new Vector3[vertexCount];
        Vector3[] sphereNormals = new Vector3[vertexCount];
        Vector2[] sphereUVs = new Vector2[vertexCount];

        int currentVertex = 0;
        sphereVertices[currentVertex] = new Vector3(0, -radius, 0);
        sphereNormals[currentVertex] = Vector3.down;
        currentVertex++;
        float stackAngle = (float)Math.PI - stackStep;
        for (int i = 0; i < stacks - 1; i++)
        {
            float sliceAngle = 0;
            for (int j = 0; j < slices; j++)
            {
                //NOTE: y and z were switched from normal spherical coordinates because the sphere is "oriented" along the Y axis as opposed to the Z axis
                float x = (float)(radius * Math.Sin(stackAngle) * Math.Cos(sliceAngle));
                float y = (float)(radius * Math.Cos(stackAngle));
                float z = (float)(radius * Math.Sin(stackAngle) * Math.Sin(sliceAngle));

                Vector3 position = new Vector3(x, y, z);
                sphereVertices[currentVertex] = position;
                sphereNormals[currentVertex] = Vector3.Normalize(position);
                sphereUVs[currentVertex] = new Vector2((float)(Math.Sin(sphereNormals[currentVertex].x) / Math.PI + 0.5f), (float)(Math.Sin(sphereNormals[currentVertex].y) / Math.PI + 0.5f));

                currentVertex++;

                sliceAngle += sliceStep;
            }
            stackAngle -= stackStep;
        }
        sphereVertices[currentVertex] = new Vector3(0, radius, 0);
        sphereNormals[currentVertex] = Vector3.up;

        mesh.vertices = sphereVertices;
        mesh.normals = sphereNormals;
        mesh.uv = sphereUVs;
        mesh.triangles = CreateIndexBuffer(vertexCount, indexCount, slices);

        return mesh;
    }

    /// <summary>
    /// Creates an index buffer for spherical shapes like Spheres, Cylinders, and Cones.
    /// </summary>
    /// <param name="vertexCount">The total number of vertices making up the shape.</param>
    /// <param name="indexCount">The total number of indices making up the shape.</param>
    /// <param name="slices">The number of slices about the Y axis.</param>
    /// <returns>The index buffer containing the index data for the shape.</returns>
    private static int[] CreateIndexBuffer(int vertexCount, int indexCount, int slices)
    {
        int[] indices = new int[indexCount];
        int currentIndex = 0;

        // Bottom circle/cone of shape
        for (int i = 1; i <= slices; i++)
        {
            indices[currentIndex++] = i;
            indices[currentIndex++] = 0;
            if (i - 1 == 0)
                indices[currentIndex++] = i + slices - 1;
            else
                indices[currentIndex++] = i - 1;
        }

        // Middle sides of shape
        for (int i = 1; i < vertexCount - slices - 1; i++)
        {
            indices[currentIndex++] = i + slices;
            indices[currentIndex++] = i;
            if ((i - 1) % slices == 0)
                indices[currentIndex++] = i + slices + slices - 1;
            else
                indices[currentIndex++] = i + slices - 1;

            indices[currentIndex++] = i;
            if ((i - 1) % slices == 0)
                indices[currentIndex++] = i + slices - 1;
            else
                indices[currentIndex++] = i - 1;
            if ((i - 1) % slices == 0)
                indices[currentIndex++] = i + slices + slices - 1;
            else
                indices[currentIndex++] = i + slices - 1;
        }

        // Top circle/cone of shape
        for (int i = vertexCount - slices - 1; i < vertexCount - 1; i++)
        {
            indices[currentIndex++] = i;
            if ((i - 1) % slices == 0)
                indices[currentIndex++] = i + slices - 1;
            else
                indices[currentIndex++] = i - 1;
            indices[currentIndex++] = vertexCount - 1;
        }

        return indices;
    }
}
