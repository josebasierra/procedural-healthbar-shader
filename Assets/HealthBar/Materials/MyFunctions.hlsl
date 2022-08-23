#ifndef myfunctions_INCLUDED
#define myfunctions_INCLUDED

//#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

float Lerp(float start, float end, float t) 
{
    return (1.0 - t) * start +  t * end;   
}

float InverseLerp(float start, float end, float value)
{
    return (value - start)/(end - start);
}

float Remap(float inValue, float2 inRange, float2 outRange)
{
    float t = InverseLerp(inRange.x, inRange.y, inValue);
    return lerp(outRange.x, outRange.y, t);
}
 
// Create mask from SDF with antialiased border
float GetSmoothMask(float SDF)
{
    float pd = length(float2(ddx(SDF), ddy(SDF)));
    return 1 - clamp(SDF/pd, 0, 1);
}

// Better pass scale as uniform/property (cheaper)
float3 GetObjectScale() 
{
    return float3(
        length(unity_ObjectToWorld._m00_m10_m20),
        length(unity_ObjectToWorld._m01_m11_m21),
        length(unity_ObjectToWorld._m02_m12_m22)
    );
}

// Best SDF reference: https://iquilezles.org/articles
float CircleSDF(float2 p, float radius)
{
    return length(p)-radius;
}  

float BoxSDF(float2 p, float2 halfSize)
{
    float2 d = abs(p)-halfSize;
    return length(max(d,0.0)) + min(max(d.x,d.y),0.0);
}

float ndot(float2 a, float2 b) { return a.x*b.x - a.y*b.y; }

float RhombusSDF(float2 p, float2 b) 
{
    p = abs(p);
    float h = clamp(ndot(b - 2.0 * p,b)/dot(b, b), -1.0, 1.0);
    float d = length(p - 0.5 * b * float2(1.0-h,1.0+h));
    return d * sign(p.x*b.y + p.y*b.x - b.x*b.y );
}

float3 Elongate(float3 p, float3 elongation)
{
    return p - clamp(p, -elongation, elongation);
}

#endif