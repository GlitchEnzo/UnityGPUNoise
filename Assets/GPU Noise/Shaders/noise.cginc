//----------------------------------------
// 2D Perlin Noise 
//----------------------------------------

float2 mod289(float2 x) 
{
  return x - floor(x * (1.0 / 289.0)) * 289.0;
}

float3 mod289(float3 x) 
{
  return x - floor(x * (1.0 / 289.0)) * 289.0;
}

// Permutation polynomial: (34x^2 + x) mod 289
float3 permute(float3 x) 
{
  return mod289(((x*34.0)+1.0)*x);
}

float perlin(float2 v)
{
  const float4 C = float4(0.211324865405187,  // (3.0-sqrt(3.0))/6.0
                          0.366025403784439,  // 0.5*(sqrt(3.0)-1.0)
                         -0.577350269189626,  // -1.0 + 2.0 * C.x
                          0.024390243902439); // 1.0 / 41.0
  // First corner
  float2 i  = floor(v + dot(v, C.yy) );
  float2 x0 = v -   i + dot(i, C.xx);

  // Other corners
  float2 i1;
  //i1.x = step( x0.y, x0.x ); // x0.x > x0.y ? 1.0 : 0.0
  //i1.y = 1.0 - i1.x;
  i1 = (x0.x > x0.y) ? float2(1.0, 0.0) : float2(0.0, 1.0);
  // x0 = x0 - 0.0 + 0.0 * C.xx ;
  // x1 = x0 - i1 + 1.0 * C.xx ;
  // x2 = x0 - 1.0 + 2.0 * C.xx ;
  float4 x12 = x0.xyxy + C.xxzz;
  x12.xy -= i1;

  // Permutations
  i = mod289(i); // Avoid truncation effects in permutation
  float3 p = permute( permute( i.y + float3(0.0, i1.y, 1.0 ))
		+ i.x + float3(0.0, i1.x, 1.0 ));

  float3 m = max(0.5 - float3(dot(x0,x0), dot(x12.xy,x12.xy), dot(x12.zw,x12.zw)), 0.0);
  m = m*m ;
  m = m*m ;

  // Gradients: 41 points uniformly over a line, mapped onto a diamond.
  // The ring size 17*17 = 289 is close to a multiple of 41 (41*7 = 287)

  float3 x = 2.0 * frac(p * C.www) - 1.0;
  float3 h = abs(x) - 0.5;
  float3 ox = floor(x + 0.5);
  float3 a0 = x - ox;

  // Normalise gradients implicitly by scaling m
  // Approximation of: m *= inversesqrt( a0*a0 + h*h );
  m *= 1.79284291400159 - 0.85373472095314 * ( a0*a0 + h*h );

  // Compute final noise value at P
  float3 g;
  g.x  = a0.x  * x0.x  + h.x  * x0.y;
  g.yz = a0.yz * x12.xz + h.yz * x12.yw;
  return 130.0 * dot(m, g);
}

//----------------------------------------
// 3D Perlin Noise 
//----------------------------------------

float4 mod289(float4 x) 
{
  return x - floor(x * (1.0 / 289.0)) * 289.0;
}

float4 permute(float4 x) 
{
  return mod289(((x*34.0)+1.0)*x);
}

//float4 taylorInvSqrt(float4 r)
//{
//  return 1.79284291400159 - 0.85373472095314 * r;
//}

float perlin(float3 v)
{ 
  const float2  C = float2(1.0/6.0, 1.0/3.0) ;
  const float4  D = float4(0.0, 0.5, 1.0, 2.0);

// First corner
  float3 i  = floor(v + dot(v, C.yyy) );
  float3 x0 =   v - i + dot(i, C.xxx) ;

// Other corners
  float3 g = step(x0.yzx, x0.xyz);
  float3 l = 1.0 - g;
  float3 i1 = min( g.xyz, l.zxy );
  float3 i2 = max( g.xyz, l.zxy );

  //   x0 = x0 - 0.0 + 0.0 * C.xxx;
  //   x1 = x0 - i1  + 1.0 * C.xxx;
  //   x2 = x0 - i2  + 2.0 * C.xxx;
  //   x3 = x0 - 1.0 + 3.0 * C.xxx;
  float3 x1 = x0 - i1 + C.xxx;
  float3 x2 = x0 - i2 + C.yyy; // 2.0*C.x = 1/3 = C.y
  float3 x3 = x0 - D.yyy;      // -1.0+3.0*C.x = -0.5 = -D.y

// Permutations
  i = mod289(i); 
  float4 p = permute( permute( permute( 
             i.z + float4(0.0, i1.z, i2.z, 1.0 ))
           + i.y + float4(0.0, i1.y, i2.y, 1.0 )) 
           + i.x + float4(0.0, i1.x, i2.x, 1.0 ));

// Gradients: 7x7 points over a square, mapped onto an octahedron.
// The ring size 17*17 = 289 is close to a multiple of 49 (49*6 = 294)
  float n_ = 0.142857142857; // 1.0/7.0
  float3  ns = n_ * D.wyz - D.xzx;

  float4 j = p - 49.0 * floor(p * ns.z * ns.z);  //  mod(p,7*7)

  float4 x_ = floor(j * ns.z);
  float4 y_ = floor(j - 7.0 * x_ );    // mod(j,N)

  float4 x = x_ *ns.x + ns.yyyy;
  float4 y = y_ *ns.x + ns.yyyy;
  float4 h = 1.0 - abs(x) - abs(y);

  float4 b0 = float4( x.xy, y.xy );
  float4 b1 = float4( x.zw, y.zw );

  //float4 s0 = float4(lessThan(b0,0.0))*2.0 - 1.0;
  //float4 s1 = float4(lessThan(b1,0.0))*2.0 - 1.0;
  float4 s0 = floor(b0)*2.0 + 1.0;
  float4 s1 = floor(b1)*2.0 + 1.0;
  float4 sh = -step(h, float4(0, 0, 0, 0));

  float4 a0 = b0.xzyw + s0.xzyw*sh.xxyy ;
  float4 a1 = b1.xzyw + s1.xzyw*sh.zzww ;

  float3 p0 = float3(a0.xy,h.x);
  float3 p1 = float3(a0.zw,h.y);
  float3 p2 = float3(a1.xy,h.z);
  float3 p3 = float3(a1.zw,h.w);

//Normalise gradients
  //float4 norm = taylorInvSqrt(float4(dot(p0,p0), dot(p1,p1), dot(p2, p2), dot(p3,p3)));
  float4 norm = rsqrt(float4(dot(p0,p0), dot(p1,p1), dot(p2, p2), dot(p3,p3)));
  p0 *= norm.x;
  p1 *= norm.y;
  p2 *= norm.z;
  p3 *= norm.w;

// Mix final noise value
  float4 m = max(0.6 - float4(dot(x0,x0), dot(x1,x1), dot(x2,x2), dot(x3,x3)), 0.0);
  m = m * m;
  return 42.0 * dot( m*m, float4( dot(p0,x0), dot(p1,x1), 
                                dot(p2,x2), dot(p3,x3) ) );
  }

// 3D Perlin Utility Functions

// calculate gradient of noise (expensive!)
float3 perlinGradient(float3 p, float d = 0.000001)
{
	float f0 = perlin(p);
	float fx = perlin(p + float3(d, 0, 0));	
	float fy = perlin(p + float3(0, d, 0));
	float fz = perlin(p + float3(0, 0, d));
	return float3(fx - f0, fy - f0, fz - f0) / d;
}

float fBm(float3 p, int octaves)
{
    float lacunarity = 2.0;
    float gain = 0.5;
	float freq = 1.0;
	float amp = 0.5;
	float sum = 0.0;	
	for(int i = 0.0; i < octaves; i++) 
	{
		sum += perlin(p * freq) * amp;
		freq *= lacunarity;
		amp *= gain;
	}
	return sum;
}

float turbulence(float3 p, int octaves)
{
    float lacunarity = 2.0;
    float gain = 0.5;
	float sum = 0.0;
	float freq = 1.0;
	float amp = 1.0;
	for(int i = 0.0; i < octaves; i++) 
	{
		sum += abs(perlin(p * freq)) * amp;
		freq *= lacunarity;
		amp *= gain;
	}
	return sum;
}

// Ridged multifractal
// See "Texturing & Modeling, A Procedural Approach", Chapter 12
float ridge(float h, float offset)
{
    h = abs(h);
    h = offset - h;
    h = h * h;
    return h;
}

float ridged(float3 p, int octaves)
{
    float lacunarity = 2.0;
    float gain = 0.5;
    float offset = 1.0;
	float sum = 0.0;
	float freq = 1.0;
	float amp = 0.5;
	float prev = 1.0;
	for(int i = 0.0; i < octaves; i++) 
	{
		float n = ridge(perlin(p * freq), offset);
		sum += n * amp * prev;
		prev = n;
		freq *= lacunarity;
		amp *= gain;
	}
	return sum;
}

//----------------------------------------
// 4D Perlin Noise 
//----------------------------------------

float mod289(float x) 
{
  return x - floor(x * (1.0 / 289.0)) * 289.0; 
}

float permute(float x) 
{
  return mod289(((x*34.0)+1.0)*x);
}

//float taylorInvSqrt(float r)
//{
//  return 1.79284291400159 - 0.85373472095314 * r;
//}

float4 grad4(float j, float4 ip)
{
  const float4 ones = float4(1.0, 1.0, 1.0, -1.0);
  float4 p,s;

  p.xyz = floor( frac(float3(j, j, j) * ip.xyz) * 7.0) * ip.z - 1.0;
  p.w = 1.5 - dot(abs(p.xyz), ones.xyz);
  s = float4(p < float4(0, 0, 0, 0));  //TODO: VERIFY THAT THIS WORKS!!!!
  p.xyz = p.xyz + (s.xyz*2.0 - 1.0) * s.www;

  return p;
}

// (sqrt(5) - 1)/4 = F4, used once below
#define F4 0.309016994374947451

float perlin(float4 v)
{
  const float4  C = float4( 0.138196601125011,  // (5 - sqrt(5))/20  G4
                        0.276393202250021,  // 2 * G4
                        0.414589803375032,  // 3 * G4
                       -0.447213595499958); // -1 + 4 * G4

// First corner
  float4 i  = floor(v + dot(v, float4(F4, F4, F4, F4)) );
  float4 x0 = v -   i + dot(i, C.xxxx);

// Other corners

// Rank sorting originally contributed by Bill Licea-Kane, AMD (formerly ATI)
  float4 i0;
  float3 isX = step( x0.yzw, x0.xxx );
  float3 isYZ = step( x0.zww, x0.yyz );
//  i0.x = dot( isX, float3( 1.0 ) );
  i0.x = isX.x + isX.y + isX.z;
  i0.yzw = 1.0 - isX;
//  i0.y += dot( isYZ.xy, float2( 1.0 ) );
  i0.y += isYZ.x + isYZ.y;
  i0.zw += 1.0 - isYZ.xy;
  i0.z += isYZ.z;
  i0.w += 1.0 - isYZ.z;

  // i0 now contains the unique values 0,1,2,3 in each channel
  float4 i3 = clamp( i0, 0.0, 1.0 );
  float4 i2 = clamp( i0-1.0, 0.0, 1.0 );
  float4 i1 = clamp( i0-2.0, 0.0, 1.0 );

  //  x0 = x0 - 0.0 + 0.0 * C.xxxx
  //  x1 = x0 - i1  + 1.0 * C.xxxx
  //  x2 = x0 - i2  + 2.0 * C.xxxx
  //  x3 = x0 - i3  + 3.0 * C.xxxx
  //  x4 = x0 - 1.0 + 4.0 * C.xxxx
  float4 x1 = x0 - i1 + C.xxxx;
  float4 x2 = x0 - i2 + C.yyyy;
  float4 x3 = x0 - i3 + C.zzzz;
  float4 x4 = x0 + C.wwww;

// Permutations
  i = mod289(i); 
  float j0 = permute( permute( permute( permute(i.w) + i.z) + i.y) + i.x);
  float4 j1 = permute( permute( permute( permute (
             i.w + float4(i1.w, i2.w, i3.w, 1.0 ))
           + i.z + float4(i1.z, i2.z, i3.z, 1.0 ))
           + i.y + float4(i1.y, i2.y, i3.y, 1.0 ))
           + i.x + float4(i1.x, i2.x, i3.x, 1.0 ));

// Gradients: 7x7x6 points over a cube, mapped onto a 4-cross polytope
// 7*7*6 = 294, which is close to the ring size 17*17 = 289.
  float4 ip = float4(1.0/294.0, 1.0/49.0, 1.0/7.0, 0.0) ;

  float4 p0 = grad4(j0,   ip);
  float4 p1 = grad4(j1.x, ip);
  float4 p2 = grad4(j1.y, ip);
  float4 p3 = grad4(j1.z, ip);
  float4 p4 = grad4(j1.w, ip);

// Normalise gradients
  //float4 norm = taylorInvSqrt(float4(dot(p0,p0), dot(p1,p1), dot(p2, p2), dot(p3,p3)));
  float4 norm = rsqrt(float4(dot(p0,p0), dot(p1,p1), dot(p2, p2), dot(p3,p3)));
  p0 *= norm.x;
  p1 *= norm.y;
  p2 *= norm.z;
  p3 *= norm.w;
  //p4 *= taylorInvSqrt(dot(p4,p4));
  p4 *= rsqrt(dot(p4,p4));

// Mix contributions from the five corners
  float3 m0 = max(0.6 - float3(dot(x0,x0), dot(x1,x1), dot(x2,x2)), 0.0);
  float2 m1 = max(0.6 - float2(dot(x3,x3), dot(x4,x4)            ), 0.0);
  m0 = m0 * m0;
  m1 = m1 * m1;
  return 49.0 * ( dot(m0*m0, float3( dot( p0, x0 ), dot( p1, x1 ), dot( p2, x2 )))
               + dot(m1*m1, float2( dot( p3, x3 ), dot( p4, x4 ) ) ) ) ;

}

// 4D Perlin Utility Functions

// calculate gradient of noise (expensive!)
float4 perlinGradient(float4 p, float d = 0.000001)
{
	float f0 = perlin(p);
	float fx = perlin(p + float4(d, 0, 0, 0));	
	float fy = perlin(p + float4(0, d, 0, 0));
	float fz = perlin(p + float4(0, 0, d, 0));
	float fw = perlin(p + float4(0, 0, 0, d));
	return float4(fx - f0, fy - f0, fz - f0, fw - f0) / d;
}

float fBm(float4 p, float octaves)
{
    float lacunarity = 2.0;
    float gain = 0.5;
	float freq = 1.0;
	float amp = 0.5;
	float sum = 0.0;	
	for(float i = 0.0; i < octaves; i++) 
	{
		sum += perlin(p * freq) * amp;
		freq *= lacunarity;
		amp *= gain;
	}
	return sum;
}

float turbulence(float4 p, int octaves)
{
    float lacunarity = 2.0;
    float gain = 0.5;
	float sum = 0.0;
	float freq = 1.0;
	float amp = 1.0;
	for(int i = 0.0; i < octaves; i++) 
	{
		sum += abs(perlin(p * freq)) * amp;
		freq *= lacunarity;
		amp *= gain;
	}
	return sum;
}

float ridged(float4 p, int octaves)
{
    float lacunarity = 2.0;
    float gain = 0.5;
    float offset = 1.0;
	float sum = 0.0;
	float freq = 1.0;
	float amp = 0.5;
	float prev = 1.0;
	for(int i = 0.0; i < octaves; i++) 
	{
		float n = ridge(perlin(p * freq), offset);
		sum += n * amp * prev;
		prev = n;
		freq *= lacunarity;
		amp *= gain;
	}
	return sum;
}

//----------------------------------------
// 2D Voronoi Noise 
//----------------------------------------

// GLSL-style implementation of mod
// GLSL: mod() = x - y * floor(x/y)
// HLSL: fmod() = x - y * trunc(x/y)
float3 mod(float3 x, float y)
{
  return x - y * floor(x/y);
}

float2 mod(float2 x, float y)
{
  return x - y * floor(x/y);
}

// Permutation polynomial: (34x^2 + x) mod 289
float3 vpermute(float3 x) 
{
  return mod((34.0 * x + 1.0) * x, 289.0);
}

// Standard Voronoi with the distance to the closest point in the X and second closest point in the Y.
float2 voronoi(float2 P) 
{
#define K 0.142857142857 // 1/7
#define Ko 0.428571428571 // 3/7
#define jitter 1.0 // Less gives more regular pattern
	float2 Pi = mod(floor(P), 289.0);
 	float2 Pf = frac(P);
	float3 oi = float3(-1.0, 0.0, 1.0);
	float3 of = float3(-0.5, 0.5, 1.5);
	float3 px = vpermute(Pi.x + oi);
	float3 p = vpermute(px.x + Pi.y + oi); // p11, p12, p13
	float3 ox = frac(p*K) - Ko;
	float3 oy = mod(floor(p*K),7.0)*K - Ko;
	float3 dx = Pf.x + 0.5 + jitter*ox;
	float3 dy = Pf.y - of + jitter*oy;
	float3 d1 = dx * dx + dy * dy; // d11, d12 and d13, squared
	p = vpermute(px.y + Pi.y + oi); // p21, p22, p23
	ox = frac(p*K) - Ko;
	oy = mod(floor(p*K),7.0)*K - Ko;
	dx = Pf.x - 0.5 + jitter*ox;
	dy = Pf.y - of + jitter*oy;
	float3 d2 = dx * dx + dy * dy; // d21, d22 and d23, squared
	p = vpermute(px.z + Pi.y + oi); // p31, p32, p33
	ox = frac(p*K) - Ko;
	oy = mod(floor(p*K),7.0)*K - Ko;
	dx = Pf.x - 1.5 + jitter*ox;
	dy = Pf.y - of + jitter*oy;
	float3 d3 = dx * dx + dy * dy; // d31, d32 and d33, squared
	// Sort out the two smallest distances (F1, F2)
	float3 d1a = min(d1, d2);
	d2 = max(d1, d2); // Swap to keep candidates for F2
	d2 = min(d2, d3); // neither F1 nor F2 are now in d3
	d1 = min(d1a, d2); // F1 is now in d1
	d2 = max(d1a, d2); // Swap to keep candidates for F2
	d1.xy = (d1.x < d1.y) ? d1.xy : d1.yx; // Swap if smaller
	d1.xz = (d1.x < d1.z) ? d1.xz : d1.zx; // F1 is in d1.x
	d1.yz = min(d1.yz, d2.yz); // F2 is now not in d2.yz
	d1.y = min(d1.y, d1.z); // nor in  d1.z
	d1.y = min(d1.y, d2.x); // F2 is in d1.y, we're done.
	return sqrt(d1.xy);
}

//----------------------------------------
// 3D Voronoi Noise 
//----------------------------------------

// Standard Voronoi with the distance to the closest point in the X and second closest point in the Y.
float2 voronoi(float3 P) 
{
//#define K 0.142857142857 // 1/7
//#define Ko 0.428571428571 // 1/2-K/2
#define K2 0.020408163265306 // 1/(7*7)
#define Kz 0.166666666667 // 1/6
#define Kzo 0.416666666667 // 1/2-1/6*2=
//#define jitter 1.0 // smaller jitter gives more regular pattern

	float3 Pi = mod(floor(P), 289.0);
 	float3 Pf = frac(P) - 0.5;

	float3 Pfx = Pf.x + float3(1.0, 0.0, -1.0);
	float3 Pfy = Pf.y + float3(1.0, 0.0, -1.0);
	float3 Pfz = Pf.z + float3(1.0, 0.0, -1.0);

	float3 p = vpermute(Pi.x + float3(-1.0, 0.0, 1.0));
	float3 p1 = vpermute(p + Pi.y - 1.0);
	float3 p2 = vpermute(p + Pi.y);
	float3 p3 = vpermute(p + Pi.y + 1.0);

	float3 p11 = vpermute(p1 + Pi.z - 1.0);
	float3 p12 = vpermute(p1 + Pi.z);
	float3 p13 = vpermute(p1 + Pi.z + 1.0);

	float3 p21 = vpermute(p2 + Pi.z - 1.0);
	float3 p22 = vpermute(p2 + Pi.z);
	float3 p23 = vpermute(p2 + Pi.z + 1.0);

	float3 p31 = vpermute(p3 + Pi.z - 1.0);
	float3 p32 = vpermute(p3 + Pi.z);
	float3 p33 = vpermute(p3 + Pi.z + 1.0);

	float3 ox11 = frac(p11*K) - Ko;
	float3 oy11 = mod(floor(p11*K), 7.0)*K - Ko;
	float3 oz11 = floor(p11*K2)*Kz - Kzo; // p11 < 289 guaranteed

	float3 ox12 = frac(p12*K) - Ko;
	float3 oy12 = mod(floor(p12*K), 7.0)*K - Ko;
	float3 oz12 = floor(p12*K2)*Kz - Kzo;

	float3 ox13 = frac(p13*K) - Ko;
	float3 oy13 = mod(floor(p13*K), 7.0)*K - Ko;
	float3 oz13 = floor(p13*K2)*Kz - Kzo;

	float3 ox21 = frac(p21*K) - Ko;
	float3 oy21 = mod(floor(p21*K), 7.0)*K - Ko;
	float3 oz21 = floor(p21*K2)*Kz - Kzo;

	float3 ox22 = frac(p22*K) - Ko;
	float3 oy22 = mod(floor(p22*K), 7.0)*K - Ko;
	float3 oz22 = floor(p22*K2)*Kz - Kzo;

	float3 ox23 = frac(p23*K) - Ko;
	float3 oy23 = mod(floor(p23*K), 7.0)*K - Ko;
	float3 oz23 = floor(p23*K2)*Kz - Kzo;

	float3 ox31 = frac(p31*K) - Ko;
	float3 oy31 = mod(floor(p31*K), 7.0)*K - Ko;
	float3 oz31 = floor(p31*K2)*Kz - Kzo;

	float3 ox32 = frac(p32*K) - Ko;
	float3 oy32 = mod(floor(p32*K), 7.0)*K - Ko;
	float3 oz32 = floor(p32*K2)*Kz - Kzo;

	float3 ox33 = frac(p33*K) - Ko;
	float3 oy33 = mod(floor(p33*K), 7.0)*K - Ko;
	float3 oz33 = floor(p33*K2)*Kz - Kzo;

	float3 dx11 = Pfx + jitter*ox11;
	float3 dy11 = Pfy.x + jitter*oy11;
	float3 dz11 = Pfz.x + jitter*oz11;

	float3 dx12 = Pfx + jitter*ox12;
	float3 dy12 = Pfy.x + jitter*oy12;
	float3 dz12 = Pfz.y + jitter*oz12;

	float3 dx13 = Pfx + jitter*ox13;
	float3 dy13 = Pfy.x + jitter*oy13;
	float3 dz13 = Pfz.z + jitter*oz13;

	float3 dx21 = Pfx + jitter*ox21;
	float3 dy21 = Pfy.y + jitter*oy21;
	float3 dz21 = Pfz.x + jitter*oz21;

	float3 dx22 = Pfx + jitter*ox22;
	float3 dy22 = Pfy.y + jitter*oy22;
	float3 dz22 = Pfz.y + jitter*oz22;

	float3 dx23 = Pfx + jitter*ox23;
	float3 dy23 = Pfy.y + jitter*oy23;
	float3 dz23 = Pfz.z + jitter*oz23;

	float3 dx31 = Pfx + jitter*ox31;
	float3 dy31 = Pfy.z + jitter*oy31;
	float3 dz31 = Pfz.x + jitter*oz31;

	float3 dx32 = Pfx + jitter*ox32;
	float3 dy32 = Pfy.z + jitter*oy32;
	float3 dz32 = Pfz.y + jitter*oz32;

	float3 dx33 = Pfx + jitter*ox33;
	float3 dy33 = Pfy.z + jitter*oy33;
	float3 dz33 = Pfz.z + jitter*oz33;

	float3 d11 = dx11 * dx11 + dy11 * dy11 + dz11 * dz11;
	float3 d12 = dx12 * dx12 + dy12 * dy12 + dz12 * dz12;
	float3 d13 = dx13 * dx13 + dy13 * dy13 + dz13 * dz13;
	float3 d21 = dx21 * dx21 + dy21 * dy21 + dz21 * dz21;
	float3 d22 = dx22 * dx22 + dy22 * dy22 + dz22 * dz22;
	float3 d23 = dx23 * dx23 + dy23 * dy23 + dz23 * dz23;
	float3 d31 = dx31 * dx31 + dy31 * dy31 + dz31 * dz31;
	float3 d32 = dx32 * dx32 + dy32 * dy32 + dz32 * dz32;
	float3 d33 = dx33 * dx33 + dy33 * dy33 + dz33 * dz33;

	// Sort out the two smallest distances (F1, F2)
	float3 d1a = min(d11, d12);
	d12 = max(d11, d12);
	d11 = min(d1a, d13); // Smallest now not in d12 or d13
	d13 = max(d1a, d13);
	d12 = min(d12, d13); // 2nd smallest now not in d13
	float3 d2a = min(d21, d22);
	d22 = max(d21, d22);
	d21 = min(d2a, d23); // Smallest now not in d22 or d23
	d23 = max(d2a, d23);
	d22 = min(d22, d23); // 2nd smallest now not in d23
	float3 d3a = min(d31, d32);
	d32 = max(d31, d32);
	d31 = min(d3a, d33); // Smallest now not in d32 or d33
	d33 = max(d3a, d33);
	d32 = min(d32, d33); // 2nd smallest now not in d33
	float3 da = min(d11, d21);
	d21 = max(d11, d21);
	d11 = min(da, d31); // Smallest now in d11
	d31 = max(da, d31); // 2nd smallest now not in d31
	d11.xy = (d11.x < d11.y) ? d11.xy : d11.yx;
	d11.xz = (d11.x < d11.z) ? d11.xz : d11.zx; // d11.x now smallest
	d12 = min(d12, d21); // 2nd smallest now not in d21
	d12 = min(d12, d22); // nor in d22
	d12 = min(d12, d31); // nor in d31
	d12 = min(d12, d32); // nor in d32
	d11.yz = min(d11.yz,d12.xy); // nor in d12.yz
	d11.y = min(d11.y,d12.z); // Only two more to go
	d11.y = min(d11.y,d11.z); // Done! (Phew!)
	return sqrt(d11.xy); // F1, F2
}

// 3D Voronoi Utility Functions

// F1 = distance to closest point
float voronoif1(float3 pos)
{
	return voronoi(pos).x;
}

// F2 = distance to SECOND closest point
float voronoif2(float3 pos)
{
	return voronoi(pos).y;
}

// F2 - F1
float voronoif2minusf1(float3 pos)
{
	float2 result = voronoi(pos);
	return result.y - result.x;
}

// (F1 + F2) / 2
float voronoif1plusf2(float3 pos)
{
	float2 result = voronoi(pos);
	return (result.x + result.y) / 2;
}

// crater-looking "holes"
float crater(float3 pos)
{
	float result = voronoi(pos).x;
	result = saturate(result.x + 0.5);
	
	if (result > 0.8 && result < 0.9)
		result = result - lerp(0, 0.2, (result - 0.8) * 10);
	if (result > 0.9)
		result = 0.7;
	return result;
}