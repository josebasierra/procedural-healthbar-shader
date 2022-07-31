Shader "Example/HealthBar"
{
    Properties
    {
        _healthNormalized("Health Normalized", Range(0,1)) = 0.0
        
        [Space(10)]
        [KeywordEnum(Circle,Box, Rhombus)] _Shape("Shape",int) = 0
        _lowLifeThreshold("Low Life Threshold", Range(0,1)) = 0.2

        [Space(10)]
        _waveAmp("Fill Wave Amplitude", float) = 0.01
        _waveFreq("Fill Wave Frequency", float) = 8

        [Space(10)]
        _startColor("Fill Start Color", Color) = (1,1,1,1)
        _endColor("Fill End Color", Color) = (1,1,1,1)
        _startThreshold("Start Threshold", Range(0,1)) = 0
        _endThreshold("End Threshold", Range(0,1)) = 1

        [Space(10)]
        _backgroundColor("Background Color", Color) = (0,0,0,0.25)
        _borderWidth("Border Width", Range(0,0.4)) = 0
        _borderColor("Border Color", Color) = (0.1,0.1,0.1,1)       
    }

    SubShader
    {
        Tags { "RenderType" = "Transparent" "RenderPipeline" = "UniversalPipeline" }

        Blend SrcAlpha OneMinusSrcAlpha
        
        Pass
        {
            HLSLPROGRAM

            #pragma multi_compile _SHAPE_CIRCLE _SHAPE_BOX _SHAPE_RHOMBUS

            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "MyFunctions.hlsl"
            
            // write properties here for the shader to be SRP Batcher compatible 
            CBUFFER_START(UnityPerMaterial)
                float _healthNormalized;
                float4 _backgroundColor, _borderColor, _startColor, _endColor;
                float _lowLifeThreshold, _startThreshold, _endThreshold, _borderWidth;
                float _waveAmp, _waveFreq;
            CBUFFER_END

            struct Attributes
            {
                float4 positionOS : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float4 positionOS : TEXCOORD1;
                float2 uv : TEXCOORD0;
            };

            Varyings vert(Attributes IN)
            {
                Varyings OUT;
                OUT.positionHCS = mul(UNITY_MATRIX_MVP, IN.positionOS); // TransformObjectToHClip(IN.positionOS.xyz);
                OUT.uv = IN.uv;
                OUT.positionOS = IN.positionOS;
                return OUT;
            }

            float4 frag(Varyings IN) : SV_Target
            {
                float3 _objectScale = GetObjectScale(); // TODO: Pass as uniform
                
                // leave some margin space
                float minScale = min(_objectScale.x, _objectScale.y);
                float margin = minScale * 0.1;

                // we 'elongate' instead of 'scaling' SDF to keep euclidean distance (so we can apply antialias easily)
                float3 _shapeElongation = (_objectScale - minScale)/2;

                // Apply elongation operation to fragment position
                float3 p = (IN.positionOS) * _objectScale;
                float3 q = Elongate(p, _shapeElongation);

                // CONTAINER
                float halfSize = minScale/2 - margin;

                #if _SHAPE_CIRCLE
                float healthBarSDF = CircleSDF(q, halfSize);
                #endif

                #if _SHAPE_BOX
                float healthBarSDF = BoxSDF(q, halfSize);
                #endif

                #if _SHAPE_RHOMBUS
                float healthBarSDF = RhombusSDF(q, float2(halfSize, halfSize));
                #endif

                float healthBarMask = GetSmoothMask(healthBarSDF);

                // LIQUID/FILLER
                // min(sin) term is used to decrease effect of wave near 0 and 1.
                float waveOffset = _waveAmp*cos(_waveFreq*(IN.uv.x + _Time.y*0.5f)) * min(2*sin(PI * _healthNormalized), 1);
                float marginNormalizedY = margin/_objectScale.y;
                float borderNormalizedY = _borderWidth/_objectScale.y;
                float fillOffset = marginNormalizedY + borderNormalizedY;

                float fillSDF = IN.uv.y - (lerp(fillOffset -0.01f, 1 - fillOffset, _healthNormalized) + waveOffset);
                float fillMask = GetSmoothMask(fillSDF);

                float t = clamp(InverseLerp(_startThreshold, _endThreshold, _healthNormalized), 0, 1);
                float4 fillColor = lerp(_startColor, _endColor, t);

                // BORDER 
                float borderSDF = healthBarSDF + _borderWidth;
                float borderMask =  1 - GetSmoothMask(borderSDF);

                // Get final color by combining masks
                float4 outColor = healthBarMask * (fillMask * (1 - borderMask) * fillColor + (1 - fillMask) * (1 - borderMask) * _backgroundColor + borderMask * _borderColor);
                
                // Highlight center
                outColor *= float4(2 - healthBarSDF/(minScale/2).xxx, 1);

                // Add flash effect on low life
                if (_healthNormalized < _lowLifeThreshold) 
                {
                    float flash = 0.1*cos(6*_Time.y) + 0.1;
                    outColor.xyz += flash;
                } 
                return outColor;
            }
            ENDHLSL
        }
    }
}