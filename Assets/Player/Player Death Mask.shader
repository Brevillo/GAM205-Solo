Shader "Shader Graphs/Player Death"
    {
        Properties
        {
            [NoScaleOffset]_MainTex("MainTex", 2D) = "white" {}
            _Center("Center", Vector) = (0, 0, 0, 0)
            _Animation("Animation", Range(0, 1)) = 0
            _Scale("Scale", Vector) = (0, 0, 0, 0)
            _Color("Color", Color) = (0, 0, 0, 0)
            _Noise_Scale("Noise Scale", Float) = 0
            _Noise_Edge("Noise Edge", Float) = 0
            _MaxDistance("MaxDistance", Float) = 0
            _Distance_Density("Distance Density", Float) = 0
            [HideInInspector][NoScaleOffset]unity_Lightmaps("unity_Lightmaps", 2DArray) = "" {}
            [HideInInspector][NoScaleOffset]unity_LightmapsInd("unity_LightmapsInd", 2DArray) = "" {}
            [HideInInspector][NoScaleOffset]unity_ShadowMasks("unity_ShadowMasks", 2DArray) = "" {}

            _StencilComp ("Stencil Comparison", Float) = 8
            _Stencil ("Stencil ID", Float) = 0
            _StencilOp ("Stencil Operation", Float) = 0
            _StencilWriteMask ("Stencil Write Mask", Float) = 255
            _StencilReadMask ("Stencil Read Mask", Float) = 255
            _ColorMask ("Color Mask", Float) = 15

        }
        SubShader
        {
            Tags
            {
                "RenderPipeline"="UniversalPipeline"
                "RenderType"="Transparent"
                "UniversalMaterialType" = "Unlit"
                "Queue"="Transparent"
                // DisableBatching: <None>
                "ShaderGraphShader"="true"
                "ShaderGraphTargetId"="UniversalSpriteUnlitSubTarget"
            }
            Pass
            {
                Name "Sprite Unlit"
                Tags
                {
                    "LightMode" = "Universal2D"
                }
            
            // Render State
            Cull Off
                Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
                ZTest LEqual
                ZTest [unity_GUIZTestMode]
                ZWrite Off

                Stencil
                {
                    Ref [_Stencil]
                    Comp [_StencilComp]
                    Pass [_StencilOp]
                    ReadMask [_StencilReadMask]
                    WriteMask [_StencilWriteMask]
                }
                ColorMask [_ColorMask]
            
            // Debug
            // <None>
            
            // --------------------------------------------------
            // Pass
            
            HLSLPROGRAM
            
            // Pragmas
            #pragma target 2.0
                #pragma exclude_renderers d3d11_9x
                #pragma vertex vert
                #pragma fragment frag
            
            // Keywords
            #pragma multi_compile_fragment _ DEBUG_DISPLAY
            // GraphKeywords: <None>
            
            // Defines
            
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define ATTRIBUTES_NEED_TEXCOORD0
            #define ATTRIBUTES_NEED_COLOR
            #define VARYINGS_NEED_POSITION_WS
            #define VARYINGS_NEED_TEXCOORD0
            #define VARYINGS_NEED_COLOR
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_SPRITEUNLIT
            
            
            // custom interpolator pre-include
            /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
            
            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
            #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
            
            // --------------------------------------------------
            // Structs and Packing
            
            // custom interpolators pre packing
            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
            
            struct Attributes
                {
                     float3 positionOS : POSITION;
                     float3 normalOS : NORMAL;
                     float4 tangentOS : TANGENT;
                     float4 uv0 : TEXCOORD0;
                     float4 color : COLOR;
                    #if UNITY_ANY_INSTANCING_ENABLED
                     uint instanceID : INSTANCEID_SEMANTIC;
                    #endif
                };
                struct Varyings
                {
                     float4 positionCS : SV_POSITION;
                     float3 positionWS;
                     float4 texCoord0;
                     float4 color;
                    #if UNITY_ANY_INSTANCING_ENABLED
                     uint instanceID : CUSTOM_INSTANCE_ID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                    #endif
                };
                struct SurfaceDescriptionInputs
                {
                     float2 NDCPosition;
                     float2 PixelPosition;
                     float4 uv0;
                };
                struct VertexDescriptionInputs
                {
                     float3 ObjectSpaceNormal;
                     float3 ObjectSpaceTangent;
                     float3 ObjectSpacePosition;
                };
                struct PackedVaryings
                {
                     float4 positionCS : SV_POSITION;
                     float4 texCoord0 : INTERP0;
                     float4 color : INTERP1;
                     float3 positionWS : INTERP2;
                    #if UNITY_ANY_INSTANCING_ENABLED
                     uint instanceID : CUSTOM_INSTANCE_ID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                    #endif
                };
            
            PackedVaryings PackVaryings (Varyings input)
                {
                    PackedVaryings output;
                    ZERO_INITIALIZE(PackedVaryings, output);
                    output.positionCS = input.positionCS;
                    output.texCoord0.xyzw = input.texCoord0;
                    output.color.xyzw = input.color;
                    output.positionWS.xyz = input.positionWS;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    output.instanceID = input.instanceID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    output.cullFace = input.cullFace;
                    #endif
                    return output;
                }
                
                Varyings UnpackVaryings (PackedVaryings input)
                {
                    Varyings output;
                    output.positionCS = input.positionCS;
                    output.texCoord0 = input.texCoord0.xyzw;
                    output.color = input.color.xyzw;
                    output.positionWS = input.positionWS.xyz;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    output.instanceID = input.instanceID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    output.cullFace = input.cullFace;
                    #endif
                    return output;
                }
                
            
            // --------------------------------------------------
            // Graph
            
            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
                float2 _Center;
                float4 _MainTex_TexelSize;
                float _Animation;
                float4 _Color;
                float2 _Scale;
                float _Noise_Scale;
                float _Noise_Edge;
                float _MaxDistance;
                float _Distance_Density;
                CBUFFER_END
                
                
                // Object and Global properties
                TEXTURE2D(_MainTex);
                SAMPLER(sampler_MainTex);
            
            // Graph Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Hashes.hlsl"
            
            // -- Property used by ScenePickingPass
            #ifdef SCENEPICKINGPASS
            float4 _SelectionID;
            #endif
            
            // -- Properties used by SceneSelectionPass
            #ifdef SCENESELECTIONPASS
            int _ObjectId;
            int _PassValue;
            #endif
            
            // Graph Functions
            
                void Unity_OneMinus_float(float In, out float Out)
                {
                    Out = 1 - In;
                }
                
                void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
                {
                    Out = A * B;
                }
                
                void Unity_Add_float2(float2 A, float2 B, out float2 Out)
                {
                    Out = A + B;
                }
                
                void Unity_Distance_float2(float2 A, float2 B, out float Out)
                {
                    Out = distance(A, B);
                }
                
                void Unity_Multiply_float_float(float A, float B, out float Out)
                {
                    Out = A * B;
                }
                
                void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
                {
                    Out = UV * Tiling + Offset;
                }
                
                float2 Unity_GradientNoise_Deterministic_Dir_float(float2 p)
                {
                    float x; Hash_Tchou_2_1_float(p, x);
                    return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
                }
                
                void Unity_GradientNoise_Deterministic_float (float2 UV, float3 Scale, out float Out)
                {
                    float2 p = UV * Scale.xy;
                    float2 ip = floor(p);
                    float2 fp = frac(p);
                    float d00 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip), fp);
                    float d01 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
                    float d10 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
                    float d11 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
                    fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
                    Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
                }
                
                void Unity_Clamp_float(float In, float Min, float Max, out float Out)
                {
                    Out = clamp(In, Min, Max);
                }
                
                void Unity_Subtract_float(float A, float B, out float Out)
                {
                    Out = A - B;
                }
                
                void Unity_Step_float(float Edge, float In, out float Out)
                {
                    Out = step(Edge, In);
                }
            
            // Custom interpolators pre vertex
            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
            
            // Graph Vertex
            struct VertexDescription
                {
                    float3 Position;
                    float3 Normal;
                    float3 Tangent;
                };
                
                VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                {
                    VertexDescription description = (VertexDescription)0;
                    description.Position = IN.ObjectSpacePosition;
                    description.Normal = IN.ObjectSpaceNormal;
                    description.Tangent = IN.ObjectSpaceTangent;
                    return description;
                }
            
            // Custom interpolators, pre surface
            #ifdef FEATURES_GRAPH_VERTEX
            Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
            {
            return output;
            }
            #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
            #endif
            
            // Graph Pixel
            struct SurfaceDescription
                {
                    float3 BaseColor;
                    float Alpha;
                };
                
                SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                {
                    SurfaceDescription surface = (SurfaceDescription)0;
                    float4 _Property_31fa3ca5c21247c58931198e538f9548_Out_0_Vector4 = _Color;
                    float _Property_c8c6cb5d1f6c41fa8b25f535c6111186_Out_0_Float = _Animation;
                    float _OneMinus_ef2cc62e079f42ec82c6810f7c97a5d8_Out_1_Float;
                    Unity_OneMinus_float(_Property_c8c6cb5d1f6c41fa8b25f535c6111186_Out_0_Float, _OneMinus_ef2cc62e079f42ec82c6810f7c97a5d8_Out_1_Float);
                    float _Property_4805fd71a92845fbaca70709851d5aed_Out_0_Float = _Distance_Density;
                    float2 _Property_6da876a80b994009b42383095f32687e_Out_0_Vector2 = _Center;
                    float2 _Vector2_97499ae5dbf3460ea237a9122958e1e6_Out_0_Vector2 = float2(unity_OrthoParams.x, unity_OrthoParams.y);
                    float4 _ScreenPosition_d125c5d185ed4633abe9ab57dff69ae9_Out_0_Vector4 = float4(IN.NDCPosition.xy * 2 - 1, 0, 0);
                    float2 _Multiply_a0e66ce548f8481fb06f4eac25891c2b_Out_2_Vector2;
                    Unity_Multiply_float2_float2(_Vector2_97499ae5dbf3460ea237a9122958e1e6_Out_0_Vector2, (_ScreenPosition_d125c5d185ed4633abe9ab57dff69ae9_Out_0_Vector4.xy), _Multiply_a0e66ce548f8481fb06f4eac25891c2b_Out_2_Vector2);
                    float2 _Add_3748a9f4971040b0b227ad01316552ae_Out_2_Vector2;
                    Unity_Add_float2((_WorldSpaceCameraPos.xy), _Multiply_a0e66ce548f8481fb06f4eac25891c2b_Out_2_Vector2, _Add_3748a9f4971040b0b227ad01316552ae_Out_2_Vector2);
                    float _Distance_bc17edee1caf467a998bd71927c0dd44_Out_2_Float;
                    Unity_Distance_float2(_Property_6da876a80b994009b42383095f32687e_Out_0_Vector2, _Add_3748a9f4971040b0b227ad01316552ae_Out_2_Vector2, _Distance_bc17edee1caf467a998bd71927c0dd44_Out_2_Float);
                    float _Multiply_b3eef78f4142463fb47cfa53c4fe6409_Out_2_Float;
                    Unity_Multiply_float_float(_Property_4805fd71a92845fbaca70709851d5aed_Out_0_Float, _Distance_bc17edee1caf467a998bd71927c0dd44_Out_2_Float, _Multiply_b3eef78f4142463fb47cfa53c4fe6409_Out_2_Float);
                    float _Multiply_04a5b6c4c97b4716aed63582d640672c_Out_2_Float;
                    Unity_Multiply_float_float(_OneMinus_ef2cc62e079f42ec82c6810f7c97a5d8_Out_1_Float, _Multiply_b3eef78f4142463fb47cfa53c4fe6409_Out_2_Float, _Multiply_04a5b6c4c97b4716aed63582d640672c_Out_2_Float);
                    float2 _Property_a2bd4e2030504a5ea02dcfbeadfe7094_Out_0_Vector2 = _Scale;
                    float2 _TilingAndOffset_17a6db1f92244f87b4c48536c062f286_Out_3_Vector2;
                    Unity_TilingAndOffset_float(IN.uv0.xy, _Property_a2bd4e2030504a5ea02dcfbeadfe7094_Out_0_Vector2, _Add_3748a9f4971040b0b227ad01316552ae_Out_2_Vector2, _TilingAndOffset_17a6db1f92244f87b4c48536c062f286_Out_3_Vector2);
                    float _Property_eff07c21e1354ba4a867a22aeb3e1066_Out_0_Float = _Noise_Scale;
                    float _GradientNoise_38e8376d700b40e4bc7b28256572aeb3_Out_2_Float;
                    Unity_GradientNoise_Deterministic_float(_TilingAndOffset_17a6db1f92244f87b4c48536c062f286_Out_3_Vector2, _Property_eff07c21e1354ba4a867a22aeb3e1066_Out_0_Float, _GradientNoise_38e8376d700b40e4bc7b28256572aeb3_Out_2_Float);
                    float _Clamp_196709ebdc7c4dad9b8c0aaee3e71a4d_Out_3_Float;
                    Unity_Clamp_float(_GradientNoise_38e8376d700b40e4bc7b28256572aeb3_Out_2_Float, float(0), float(1), _Clamp_196709ebdc7c4dad9b8c0aaee3e71a4d_Out_3_Float);
                    float _Property_65a49687b3b9484994d48ce8f6bf0de1_Out_0_Float = _Animation;
                    float _Property_70c8f13347e748f5a8719244cc2675bc_Out_0_Float = _MaxDistance;
                    float _Multiply_ca660498efff4e73b473e201edb21c95_Out_2_Float;
                    Unity_Multiply_float_float(_Property_65a49687b3b9484994d48ce8f6bf0de1_Out_0_Float, _Property_70c8f13347e748f5a8719244cc2675bc_Out_0_Float, _Multiply_ca660498efff4e73b473e201edb21c95_Out_2_Float);
                    float _Subtract_0b96d4f0f38f4d089c76ef3a3f9bd965_Out_2_Float;
                    Unity_Subtract_float(_Multiply_ca660498efff4e73b473e201edb21c95_Out_2_Float, _Distance_bc17edee1caf467a998bd71927c0dd44_Out_2_Float, _Subtract_0b96d4f0f38f4d089c76ef3a3f9bd965_Out_2_Float);
                    float _Clamp_37d5b241fae743379d1fb7c0367d971c_Out_3_Float;
                    Unity_Clamp_float(_Subtract_0b96d4f0f38f4d089c76ef3a3f9bd965_Out_2_Float, float(0), float(1), _Clamp_37d5b241fae743379d1fb7c0367d971c_Out_3_Float);
                    float _Multiply_8b0e8b89377d46d58fa0bfa3ff629752_Out_2_Float;
                    Unity_Multiply_float_float(_Clamp_196709ebdc7c4dad9b8c0aaee3e71a4d_Out_3_Float, _Clamp_37d5b241fae743379d1fb7c0367d971c_Out_3_Float, _Multiply_8b0e8b89377d46d58fa0bfa3ff629752_Out_2_Float);
                    float _Step_6c5aceaba33e44cf8ecc90357a07c1de_Out_2_Float;
                    Unity_Step_float(_Multiply_04a5b6c4c97b4716aed63582d640672c_Out_2_Float, _Multiply_8b0e8b89377d46d58fa0bfa3ff629752_Out_2_Float, _Step_6c5aceaba33e44cf8ecc90357a07c1de_Out_2_Float);
                    surface.BaseColor = (_Property_31fa3ca5c21247c58931198e538f9548_Out_0_Vector4.xyz);
                    surface.Alpha = _Step_6c5aceaba33e44cf8ecc90357a07c1de_Out_2_Float;
                    return surface;
                }
            
            // --------------------------------------------------
            // Build Graph Inputs
            #ifdef HAVE_VFX_MODIFICATION
            #define VFX_SRP_ATTRIBUTES Attributes
            #define VFX_SRP_VARYINGS Varyings
            #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
            #endif
            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                {
                    VertexDescriptionInputs output;
                    ZERO_INITIALIZE(VertexDescriptionInputs, output);
                
                    output.ObjectSpaceNormal =                          input.normalOS;
                    output.ObjectSpaceTangent =                         input.tangentOS.xyz;
                    output.ObjectSpacePosition =                        input.positionOS;
                
                    return output;
                }
                
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                {
                    SurfaceDescriptionInputs output;
                    ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
                
                #ifdef HAVE_VFX_MODIFICATION
                #if VFX_USE_GRAPH_VALUES
                    uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
                    /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
                #endif
                    /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
                
                #endif
                
                    
                
                
                
                
                
                
                    #if UNITY_UV_STARTS_AT_TOP
                    output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x < 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
                    #else
                    output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x > 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
                    #endif
                
                    output.NDCPosition = output.PixelPosition.xy / _ScaledScreenParams.xy;
                    output.NDCPosition.y = 1.0f - output.NDCPosition.y;
                
                    output.uv0 = input.texCoord0;
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                #else
                #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                #endif
                #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                
                        return output;
                }
                
            
            // --------------------------------------------------
            // Main
            
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Editor/2D/ShaderGraph/Includes/SpriteUnlitPass.hlsl"
            
            // --------------------------------------------------
            // Visual Effect Vertex Invocations
            #ifdef HAVE_VFX_MODIFICATION
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
            #endif
            
            ENDHLSL
            }
            Pass
            {
                Name "SceneSelectionPass"
                Tags
                {
                    "LightMode" = "SceneSelectionPass"
                }
            
            // Render State
            Cull Off
            
            // Debug
            // <None>
            
            // --------------------------------------------------
            // Pass
            
            HLSLPROGRAM
            
            // Pragmas
            #pragma target 2.0
                #pragma exclude_renderers d3d11_9x
                #pragma vertex vert
                #pragma fragment frag
            
            // Keywords
            // PassKeywords: <None>
            // GraphKeywords: <None>
            
            // Defines
            
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define ATTRIBUTES_NEED_TEXCOORD0
            #define VARYINGS_NEED_TEXCOORD0
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_DEPTHONLY
                #define SCENESELECTIONPASS 1
                
            
            
            // custom interpolator pre-include
            /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
            
            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
            #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
            #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
            
            // --------------------------------------------------
            // Structs and Packing
            
            // custom interpolators pre packing
            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
            
            struct Attributes
                {
                     float3 positionOS : POSITION;
                     float3 normalOS : NORMAL;
                     float4 tangentOS : TANGENT;
                     float4 uv0 : TEXCOORD0;
                    #if UNITY_ANY_INSTANCING_ENABLED
                     uint instanceID : INSTANCEID_SEMANTIC;
                    #endif
                };
                struct Varyings
                {
                     float4 positionCS : SV_POSITION;
                     float4 texCoord0;
                    #if UNITY_ANY_INSTANCING_ENABLED
                     uint instanceID : CUSTOM_INSTANCE_ID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                    #endif
                };
                struct SurfaceDescriptionInputs
                {
                     float2 NDCPosition;
                     float2 PixelPosition;
                     float4 uv0;
                };
                struct VertexDescriptionInputs
                {
                     float3 ObjectSpaceNormal;
                     float3 ObjectSpaceTangent;
                     float3 ObjectSpacePosition;
                };
                struct PackedVaryings
                {
                     float4 positionCS : SV_POSITION;
                     float4 texCoord0 : INTERP0;
                    #if UNITY_ANY_INSTANCING_ENABLED
                     uint instanceID : CUSTOM_INSTANCE_ID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                    #endif
                };
            
            PackedVaryings PackVaryings (Varyings input)
                {
                    PackedVaryings output;
                    ZERO_INITIALIZE(PackedVaryings, output);
                    output.positionCS = input.positionCS;
                    output.texCoord0.xyzw = input.texCoord0;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    output.instanceID = input.instanceID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    output.cullFace = input.cullFace;
                    #endif
                    return output;
                }
                
                Varyings UnpackVaryings (PackedVaryings input)
                {
                    Varyings output;
                    output.positionCS = input.positionCS;
                    output.texCoord0 = input.texCoord0.xyzw;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    output.instanceID = input.instanceID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    output.cullFace = input.cullFace;
                    #endif
                    return output;
                }
                
            
            // --------------------------------------------------
            // Graph
            
            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
                float2 _Center;
                float4 _MainTex_TexelSize;
                float _Animation;
                float4 _Color;
                float2 _Scale;
                float _Noise_Scale;
                float _Noise_Edge;
                float _MaxDistance;
                float _Distance_Density;
                CBUFFER_END
                
                
                // Object and Global properties
                TEXTURE2D(_MainTex);
                SAMPLER(sampler_MainTex);
            
            // Graph Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Hashes.hlsl"
            
            // -- Property used by ScenePickingPass
            #ifdef SCENEPICKINGPASS
            float4 _SelectionID;
            #endif
            
            // -- Properties used by SceneSelectionPass
            #ifdef SCENESELECTIONPASS
            int _ObjectId;
            int _PassValue;
            #endif
            
            // Graph Functions
            
                void Unity_OneMinus_float(float In, out float Out)
                {
                    Out = 1 - In;
                }
                
                void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
                {
                    Out = A * B;
                }
                
                void Unity_Add_float2(float2 A, float2 B, out float2 Out)
                {
                    Out = A + B;
                }
                
                void Unity_Distance_float2(float2 A, float2 B, out float Out)
                {
                    Out = distance(A, B);
                }
                
                void Unity_Multiply_float_float(float A, float B, out float Out)
                {
                    Out = A * B;
                }
                
                void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
                {
                    Out = UV * Tiling + Offset;
                }
                
                float2 Unity_GradientNoise_Deterministic_Dir_float(float2 p)
                {
                    float x; Hash_Tchou_2_1_float(p, x);
                    return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
                }
                
                void Unity_GradientNoise_Deterministic_float (float2 UV, float3 Scale, out float Out)
                {
                    float2 p = UV * Scale.xy;
                    float2 ip = floor(p);
                    float2 fp = frac(p);
                    float d00 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip), fp);
                    float d01 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
                    float d10 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
                    float d11 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
                    fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
                    Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
                }
                
                void Unity_Clamp_float(float In, float Min, float Max, out float Out)
                {
                    Out = clamp(In, Min, Max);
                }
                
                void Unity_Subtract_float(float A, float B, out float Out)
                {
                    Out = A - B;
                }
                
                void Unity_Step_float(float Edge, float In, out float Out)
                {
                    Out = step(Edge, In);
                }
            
            // Custom interpolators pre vertex
            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
            
            // Graph Vertex
            struct VertexDescription
                {
                    float3 Position;
                    float3 Normal;
                    float3 Tangent;
                };
                
                VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                {
                    VertexDescription description = (VertexDescription)0;
                    description.Position = IN.ObjectSpacePosition;
                    description.Normal = IN.ObjectSpaceNormal;
                    description.Tangent = IN.ObjectSpaceTangent;
                    return description;
                }
            
            // Custom interpolators, pre surface
            #ifdef FEATURES_GRAPH_VERTEX
            Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
            {
            return output;
            }
            #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
            #endif
            
            // Graph Pixel
            struct SurfaceDescription
                {
                    float Alpha;
                };
                
                SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                {
                    SurfaceDescription surface = (SurfaceDescription)0;
                    float _Property_c8c6cb5d1f6c41fa8b25f535c6111186_Out_0_Float = _Animation;
                    float _OneMinus_ef2cc62e079f42ec82c6810f7c97a5d8_Out_1_Float;
                    Unity_OneMinus_float(_Property_c8c6cb5d1f6c41fa8b25f535c6111186_Out_0_Float, _OneMinus_ef2cc62e079f42ec82c6810f7c97a5d8_Out_1_Float);
                    float _Property_4805fd71a92845fbaca70709851d5aed_Out_0_Float = _Distance_Density;
                    float2 _Property_6da876a80b994009b42383095f32687e_Out_0_Vector2 = _Center;
                    float2 _Vector2_97499ae5dbf3460ea237a9122958e1e6_Out_0_Vector2 = float2(unity_OrthoParams.x, unity_OrthoParams.y);
                    float4 _ScreenPosition_d125c5d185ed4633abe9ab57dff69ae9_Out_0_Vector4 = float4(IN.NDCPosition.xy * 2 - 1, 0, 0);
                    float2 _Multiply_a0e66ce548f8481fb06f4eac25891c2b_Out_2_Vector2;
                    Unity_Multiply_float2_float2(_Vector2_97499ae5dbf3460ea237a9122958e1e6_Out_0_Vector2, (_ScreenPosition_d125c5d185ed4633abe9ab57dff69ae9_Out_0_Vector4.xy), _Multiply_a0e66ce548f8481fb06f4eac25891c2b_Out_2_Vector2);
                    float2 _Add_3748a9f4971040b0b227ad01316552ae_Out_2_Vector2;
                    Unity_Add_float2((_WorldSpaceCameraPos.xy), _Multiply_a0e66ce548f8481fb06f4eac25891c2b_Out_2_Vector2, _Add_3748a9f4971040b0b227ad01316552ae_Out_2_Vector2);
                    float _Distance_bc17edee1caf467a998bd71927c0dd44_Out_2_Float;
                    Unity_Distance_float2(_Property_6da876a80b994009b42383095f32687e_Out_0_Vector2, _Add_3748a9f4971040b0b227ad01316552ae_Out_2_Vector2, _Distance_bc17edee1caf467a998bd71927c0dd44_Out_2_Float);
                    float _Multiply_b3eef78f4142463fb47cfa53c4fe6409_Out_2_Float;
                    Unity_Multiply_float_float(_Property_4805fd71a92845fbaca70709851d5aed_Out_0_Float, _Distance_bc17edee1caf467a998bd71927c0dd44_Out_2_Float, _Multiply_b3eef78f4142463fb47cfa53c4fe6409_Out_2_Float);
                    float _Multiply_04a5b6c4c97b4716aed63582d640672c_Out_2_Float;
                    Unity_Multiply_float_float(_OneMinus_ef2cc62e079f42ec82c6810f7c97a5d8_Out_1_Float, _Multiply_b3eef78f4142463fb47cfa53c4fe6409_Out_2_Float, _Multiply_04a5b6c4c97b4716aed63582d640672c_Out_2_Float);
                    float2 _Property_a2bd4e2030504a5ea02dcfbeadfe7094_Out_0_Vector2 = _Scale;
                    float2 _TilingAndOffset_17a6db1f92244f87b4c48536c062f286_Out_3_Vector2;
                    Unity_TilingAndOffset_float(IN.uv0.xy, _Property_a2bd4e2030504a5ea02dcfbeadfe7094_Out_0_Vector2, _Add_3748a9f4971040b0b227ad01316552ae_Out_2_Vector2, _TilingAndOffset_17a6db1f92244f87b4c48536c062f286_Out_3_Vector2);
                    float _Property_eff07c21e1354ba4a867a22aeb3e1066_Out_0_Float = _Noise_Scale;
                    float _GradientNoise_38e8376d700b40e4bc7b28256572aeb3_Out_2_Float;
                    Unity_GradientNoise_Deterministic_float(_TilingAndOffset_17a6db1f92244f87b4c48536c062f286_Out_3_Vector2, _Property_eff07c21e1354ba4a867a22aeb3e1066_Out_0_Float, _GradientNoise_38e8376d700b40e4bc7b28256572aeb3_Out_2_Float);
                    float _Clamp_196709ebdc7c4dad9b8c0aaee3e71a4d_Out_3_Float;
                    Unity_Clamp_float(_GradientNoise_38e8376d700b40e4bc7b28256572aeb3_Out_2_Float, float(0), float(1), _Clamp_196709ebdc7c4dad9b8c0aaee3e71a4d_Out_3_Float);
                    float _Property_65a49687b3b9484994d48ce8f6bf0de1_Out_0_Float = _Animation;
                    float _Property_70c8f13347e748f5a8719244cc2675bc_Out_0_Float = _MaxDistance;
                    float _Multiply_ca660498efff4e73b473e201edb21c95_Out_2_Float;
                    Unity_Multiply_float_float(_Property_65a49687b3b9484994d48ce8f6bf0de1_Out_0_Float, _Property_70c8f13347e748f5a8719244cc2675bc_Out_0_Float, _Multiply_ca660498efff4e73b473e201edb21c95_Out_2_Float);
                    float _Subtract_0b96d4f0f38f4d089c76ef3a3f9bd965_Out_2_Float;
                    Unity_Subtract_float(_Multiply_ca660498efff4e73b473e201edb21c95_Out_2_Float, _Distance_bc17edee1caf467a998bd71927c0dd44_Out_2_Float, _Subtract_0b96d4f0f38f4d089c76ef3a3f9bd965_Out_2_Float);
                    float _Clamp_37d5b241fae743379d1fb7c0367d971c_Out_3_Float;
                    Unity_Clamp_float(_Subtract_0b96d4f0f38f4d089c76ef3a3f9bd965_Out_2_Float, float(0), float(1), _Clamp_37d5b241fae743379d1fb7c0367d971c_Out_3_Float);
                    float _Multiply_8b0e8b89377d46d58fa0bfa3ff629752_Out_2_Float;
                    Unity_Multiply_float_float(_Clamp_196709ebdc7c4dad9b8c0aaee3e71a4d_Out_3_Float, _Clamp_37d5b241fae743379d1fb7c0367d971c_Out_3_Float, _Multiply_8b0e8b89377d46d58fa0bfa3ff629752_Out_2_Float);
                    float _Step_6c5aceaba33e44cf8ecc90357a07c1de_Out_2_Float;
                    Unity_Step_float(_Multiply_04a5b6c4c97b4716aed63582d640672c_Out_2_Float, _Multiply_8b0e8b89377d46d58fa0bfa3ff629752_Out_2_Float, _Step_6c5aceaba33e44cf8ecc90357a07c1de_Out_2_Float);
                    surface.Alpha = _Step_6c5aceaba33e44cf8ecc90357a07c1de_Out_2_Float;
                    return surface;
                }
            
            // --------------------------------------------------
            // Build Graph Inputs
            #ifdef HAVE_VFX_MODIFICATION
            #define VFX_SRP_ATTRIBUTES Attributes
            #define VFX_SRP_VARYINGS Varyings
            #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
            #endif
            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                {
                    VertexDescriptionInputs output;
                    ZERO_INITIALIZE(VertexDescriptionInputs, output);
                
                    output.ObjectSpaceNormal =                          input.normalOS;
                    output.ObjectSpaceTangent =                         input.tangentOS.xyz;
                    output.ObjectSpacePosition =                        input.positionOS;
                
                    return output;
                }
                
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                {
                    SurfaceDescriptionInputs output;
                    ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
                
                #ifdef HAVE_VFX_MODIFICATION
                #if VFX_USE_GRAPH_VALUES
                    uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
                    /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
                #endif
                    /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
                
                #endif
                
                    
                
                
                
                
                
                
                    #if UNITY_UV_STARTS_AT_TOP
                    output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x < 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
                    #else
                    output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x > 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
                    #endif
                
                    output.NDCPosition = output.PixelPosition.xy / _ScaledScreenParams.xy;
                    output.NDCPosition.y = 1.0f - output.NDCPosition.y;
                
                    output.uv0 = input.texCoord0;
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                #else
                #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                #endif
                #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                
                        return output;
                }
                
            
            // --------------------------------------------------
            // Main
            
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/SelectionPickingPass.hlsl"
            
            // --------------------------------------------------
            // Visual Effect Vertex Invocations
            #ifdef HAVE_VFX_MODIFICATION
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
            #endif
            
            ENDHLSL
            }
            Pass
            {
                Name "ScenePickingPass"
                Tags
                {
                    "LightMode" = "Picking"
                }
            
            // Render State
            Cull Back
            
            // Debug
            // <None>
            
            // --------------------------------------------------
            // Pass
            
            HLSLPROGRAM
            
            // Pragmas
            #pragma target 2.0
                #pragma exclude_renderers d3d11_9x
                #pragma vertex vert
                #pragma fragment frag
            
            // Keywords
            // PassKeywords: <None>
            // GraphKeywords: <None>
            
            // Defines
            
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define ATTRIBUTES_NEED_TEXCOORD0
            #define VARYINGS_NEED_TEXCOORD0
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_DEPTHONLY
                #define SCENEPICKINGPASS 1
                
            
            
            // custom interpolator pre-include
            /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
            
            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
            #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
            #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
            
            // --------------------------------------------------
            // Structs and Packing
            
            // custom interpolators pre packing
            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
            
            struct Attributes
                {
                     float3 positionOS : POSITION;
                     float3 normalOS : NORMAL;
                     float4 tangentOS : TANGENT;
                     float4 uv0 : TEXCOORD0;
                    #if UNITY_ANY_INSTANCING_ENABLED
                     uint instanceID : INSTANCEID_SEMANTIC;
                    #endif
                };
                struct Varyings
                {
                     float4 positionCS : SV_POSITION;
                     float4 texCoord0;
                    #if UNITY_ANY_INSTANCING_ENABLED
                     uint instanceID : CUSTOM_INSTANCE_ID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                    #endif
                };
                struct SurfaceDescriptionInputs
                {
                     float2 NDCPosition;
                     float2 PixelPosition;
                     float4 uv0;
                };
                struct VertexDescriptionInputs
                {
                     float3 ObjectSpaceNormal;
                     float3 ObjectSpaceTangent;
                     float3 ObjectSpacePosition;
                };
                struct PackedVaryings
                {
                     float4 positionCS : SV_POSITION;
                     float4 texCoord0 : INTERP0;
                    #if UNITY_ANY_INSTANCING_ENABLED
                     uint instanceID : CUSTOM_INSTANCE_ID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                    #endif
                };
            
            PackedVaryings PackVaryings (Varyings input)
                {
                    PackedVaryings output;
                    ZERO_INITIALIZE(PackedVaryings, output);
                    output.positionCS = input.positionCS;
                    output.texCoord0.xyzw = input.texCoord0;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    output.instanceID = input.instanceID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    output.cullFace = input.cullFace;
                    #endif
                    return output;
                }
                
                Varyings UnpackVaryings (PackedVaryings input)
                {
                    Varyings output;
                    output.positionCS = input.positionCS;
                    output.texCoord0 = input.texCoord0.xyzw;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    output.instanceID = input.instanceID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    output.cullFace = input.cullFace;
                    #endif
                    return output;
                }
                
            
            // --------------------------------------------------
            // Graph
            
            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
                float2 _Center;
                float4 _MainTex_TexelSize;
                float _Animation;
                float4 _Color;
                float2 _Scale;
                float _Noise_Scale;
                float _Noise_Edge;
                float _MaxDistance;
                float _Distance_Density;
                CBUFFER_END
                
                
                // Object and Global properties
                TEXTURE2D(_MainTex);
                SAMPLER(sampler_MainTex);
            
            // Graph Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Hashes.hlsl"
            
            // -- Property used by ScenePickingPass
            #ifdef SCENEPICKINGPASS
            float4 _SelectionID;
            #endif
            
            // -- Properties used by SceneSelectionPass
            #ifdef SCENESELECTIONPASS
            int _ObjectId;
            int _PassValue;
            #endif
            
            // Graph Functions
            
                void Unity_OneMinus_float(float In, out float Out)
                {
                    Out = 1 - In;
                }
                
                void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
                {
                    Out = A * B;
                }
                
                void Unity_Add_float2(float2 A, float2 B, out float2 Out)
                {
                    Out = A + B;
                }
                
                void Unity_Distance_float2(float2 A, float2 B, out float Out)
                {
                    Out = distance(A, B);
                }
                
                void Unity_Multiply_float_float(float A, float B, out float Out)
                {
                    Out = A * B;
                }
                
                void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
                {
                    Out = UV * Tiling + Offset;
                }
                
                float2 Unity_GradientNoise_Deterministic_Dir_float(float2 p)
                {
                    float x; Hash_Tchou_2_1_float(p, x);
                    return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
                }
                
                void Unity_GradientNoise_Deterministic_float (float2 UV, float3 Scale, out float Out)
                {
                    float2 p = UV * Scale.xy;
                    float2 ip = floor(p);
                    float2 fp = frac(p);
                    float d00 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip), fp);
                    float d01 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
                    float d10 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
                    float d11 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
                    fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
                    Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
                }
                
                void Unity_Clamp_float(float In, float Min, float Max, out float Out)
                {
                    Out = clamp(In, Min, Max);
                }
                
                void Unity_Subtract_float(float A, float B, out float Out)
                {
                    Out = A - B;
                }
                
                void Unity_Step_float(float Edge, float In, out float Out)
                {
                    Out = step(Edge, In);
                }
            
            // Custom interpolators pre vertex
            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
            
            // Graph Vertex
            struct VertexDescription
                {
                    float3 Position;
                    float3 Normal;
                    float3 Tangent;
                };
                
                VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                {
                    VertexDescription description = (VertexDescription)0;
                    description.Position = IN.ObjectSpacePosition;
                    description.Normal = IN.ObjectSpaceNormal;
                    description.Tangent = IN.ObjectSpaceTangent;
                    return description;
                }
            
            // Custom interpolators, pre surface
            #ifdef FEATURES_GRAPH_VERTEX
            Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
            {
            return output;
            }
            #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
            #endif
            
            // Graph Pixel
            struct SurfaceDescription
                {
                    float Alpha;
                };
                
                SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                {
                    SurfaceDescription surface = (SurfaceDescription)0;
                    float _Property_c8c6cb5d1f6c41fa8b25f535c6111186_Out_0_Float = _Animation;
                    float _OneMinus_ef2cc62e079f42ec82c6810f7c97a5d8_Out_1_Float;
                    Unity_OneMinus_float(_Property_c8c6cb5d1f6c41fa8b25f535c6111186_Out_0_Float, _OneMinus_ef2cc62e079f42ec82c6810f7c97a5d8_Out_1_Float);
                    float _Property_4805fd71a92845fbaca70709851d5aed_Out_0_Float = _Distance_Density;
                    float2 _Property_6da876a80b994009b42383095f32687e_Out_0_Vector2 = _Center;
                    float2 _Vector2_97499ae5dbf3460ea237a9122958e1e6_Out_0_Vector2 = float2(unity_OrthoParams.x, unity_OrthoParams.y);
                    float4 _ScreenPosition_d125c5d185ed4633abe9ab57dff69ae9_Out_0_Vector4 = float4(IN.NDCPosition.xy * 2 - 1, 0, 0);
                    float2 _Multiply_a0e66ce548f8481fb06f4eac25891c2b_Out_2_Vector2;
                    Unity_Multiply_float2_float2(_Vector2_97499ae5dbf3460ea237a9122958e1e6_Out_0_Vector2, (_ScreenPosition_d125c5d185ed4633abe9ab57dff69ae9_Out_0_Vector4.xy), _Multiply_a0e66ce548f8481fb06f4eac25891c2b_Out_2_Vector2);
                    float2 _Add_3748a9f4971040b0b227ad01316552ae_Out_2_Vector2;
                    Unity_Add_float2((_WorldSpaceCameraPos.xy), _Multiply_a0e66ce548f8481fb06f4eac25891c2b_Out_2_Vector2, _Add_3748a9f4971040b0b227ad01316552ae_Out_2_Vector2);
                    float _Distance_bc17edee1caf467a998bd71927c0dd44_Out_2_Float;
                    Unity_Distance_float2(_Property_6da876a80b994009b42383095f32687e_Out_0_Vector2, _Add_3748a9f4971040b0b227ad01316552ae_Out_2_Vector2, _Distance_bc17edee1caf467a998bd71927c0dd44_Out_2_Float);
                    float _Multiply_b3eef78f4142463fb47cfa53c4fe6409_Out_2_Float;
                    Unity_Multiply_float_float(_Property_4805fd71a92845fbaca70709851d5aed_Out_0_Float, _Distance_bc17edee1caf467a998bd71927c0dd44_Out_2_Float, _Multiply_b3eef78f4142463fb47cfa53c4fe6409_Out_2_Float);
                    float _Multiply_04a5b6c4c97b4716aed63582d640672c_Out_2_Float;
                    Unity_Multiply_float_float(_OneMinus_ef2cc62e079f42ec82c6810f7c97a5d8_Out_1_Float, _Multiply_b3eef78f4142463fb47cfa53c4fe6409_Out_2_Float, _Multiply_04a5b6c4c97b4716aed63582d640672c_Out_2_Float);
                    float2 _Property_a2bd4e2030504a5ea02dcfbeadfe7094_Out_0_Vector2 = _Scale;
                    float2 _TilingAndOffset_17a6db1f92244f87b4c48536c062f286_Out_3_Vector2;
                    Unity_TilingAndOffset_float(IN.uv0.xy, _Property_a2bd4e2030504a5ea02dcfbeadfe7094_Out_0_Vector2, _Add_3748a9f4971040b0b227ad01316552ae_Out_2_Vector2, _TilingAndOffset_17a6db1f92244f87b4c48536c062f286_Out_3_Vector2);
                    float _Property_eff07c21e1354ba4a867a22aeb3e1066_Out_0_Float = _Noise_Scale;
                    float _GradientNoise_38e8376d700b40e4bc7b28256572aeb3_Out_2_Float;
                    Unity_GradientNoise_Deterministic_float(_TilingAndOffset_17a6db1f92244f87b4c48536c062f286_Out_3_Vector2, _Property_eff07c21e1354ba4a867a22aeb3e1066_Out_0_Float, _GradientNoise_38e8376d700b40e4bc7b28256572aeb3_Out_2_Float);
                    float _Clamp_196709ebdc7c4dad9b8c0aaee3e71a4d_Out_3_Float;
                    Unity_Clamp_float(_GradientNoise_38e8376d700b40e4bc7b28256572aeb3_Out_2_Float, float(0), float(1), _Clamp_196709ebdc7c4dad9b8c0aaee3e71a4d_Out_3_Float);
                    float _Property_65a49687b3b9484994d48ce8f6bf0de1_Out_0_Float = _Animation;
                    float _Property_70c8f13347e748f5a8719244cc2675bc_Out_0_Float = _MaxDistance;
                    float _Multiply_ca660498efff4e73b473e201edb21c95_Out_2_Float;
                    Unity_Multiply_float_float(_Property_65a49687b3b9484994d48ce8f6bf0de1_Out_0_Float, _Property_70c8f13347e748f5a8719244cc2675bc_Out_0_Float, _Multiply_ca660498efff4e73b473e201edb21c95_Out_2_Float);
                    float _Subtract_0b96d4f0f38f4d089c76ef3a3f9bd965_Out_2_Float;
                    Unity_Subtract_float(_Multiply_ca660498efff4e73b473e201edb21c95_Out_2_Float, _Distance_bc17edee1caf467a998bd71927c0dd44_Out_2_Float, _Subtract_0b96d4f0f38f4d089c76ef3a3f9bd965_Out_2_Float);
                    float _Clamp_37d5b241fae743379d1fb7c0367d971c_Out_3_Float;
                    Unity_Clamp_float(_Subtract_0b96d4f0f38f4d089c76ef3a3f9bd965_Out_2_Float, float(0), float(1), _Clamp_37d5b241fae743379d1fb7c0367d971c_Out_3_Float);
                    float _Multiply_8b0e8b89377d46d58fa0bfa3ff629752_Out_2_Float;
                    Unity_Multiply_float_float(_Clamp_196709ebdc7c4dad9b8c0aaee3e71a4d_Out_3_Float, _Clamp_37d5b241fae743379d1fb7c0367d971c_Out_3_Float, _Multiply_8b0e8b89377d46d58fa0bfa3ff629752_Out_2_Float);
                    float _Step_6c5aceaba33e44cf8ecc90357a07c1de_Out_2_Float;
                    Unity_Step_float(_Multiply_04a5b6c4c97b4716aed63582d640672c_Out_2_Float, _Multiply_8b0e8b89377d46d58fa0bfa3ff629752_Out_2_Float, _Step_6c5aceaba33e44cf8ecc90357a07c1de_Out_2_Float);
                    surface.Alpha = _Step_6c5aceaba33e44cf8ecc90357a07c1de_Out_2_Float;
                    return surface;
                }
            
            // --------------------------------------------------
            // Build Graph Inputs
            #ifdef HAVE_VFX_MODIFICATION
            #define VFX_SRP_ATTRIBUTES Attributes
            #define VFX_SRP_VARYINGS Varyings
            #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
            #endif
            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                {
                    VertexDescriptionInputs output;
                    ZERO_INITIALIZE(VertexDescriptionInputs, output);
                
                    output.ObjectSpaceNormal =                          input.normalOS;
                    output.ObjectSpaceTangent =                         input.tangentOS.xyz;
                    output.ObjectSpacePosition =                        input.positionOS;
                
                    return output;
                }
                
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                {
                    SurfaceDescriptionInputs output;
                    ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
                
                #ifdef HAVE_VFX_MODIFICATION
                #if VFX_USE_GRAPH_VALUES
                    uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
                    /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
                #endif
                    /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
                
                #endif
                
                    
                
                
                
                
                
                
                    #if UNITY_UV_STARTS_AT_TOP
                    output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x < 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
                    #else
                    output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x > 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
                    #endif
                
                    output.NDCPosition = output.PixelPosition.xy / _ScaledScreenParams.xy;
                    output.NDCPosition.y = 1.0f - output.NDCPosition.y;
                
                    output.uv0 = input.texCoord0;
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                #else
                #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                #endif
                #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                
                        return output;
                }
                
            
            // --------------------------------------------------
            // Main
            
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/SelectionPickingPass.hlsl"
            
            // --------------------------------------------------
            // Visual Effect Vertex Invocations
            #ifdef HAVE_VFX_MODIFICATION
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
            #endif
            
            ENDHLSL
            }
            Pass
            {
                Name "Sprite Unlit"
                Tags
                {
                    "LightMode" = "UniversalForward"
                }
            
            // Render State
            Cull Off
                Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
                ZTest LEqual
                ZWrite Off
            
            // Debug
            // <None>
            
            // --------------------------------------------------
            // Pass
            
            HLSLPROGRAM
            
            // Pragmas
            #pragma target 2.0
                #pragma exclude_renderers d3d11_9x
                #pragma vertex vert
                #pragma fragment frag
            
            // Keywords
            #pragma multi_compile_fragment _ DEBUG_DISPLAY
            // GraphKeywords: <None>
            
            // Defines
            
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define ATTRIBUTES_NEED_TEXCOORD0
            #define ATTRIBUTES_NEED_COLOR
            #define VARYINGS_NEED_POSITION_WS
            #define VARYINGS_NEED_TEXCOORD0
            #define VARYINGS_NEED_COLOR
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_SPRITEFORWARD
            
            
            // custom interpolator pre-include
            /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
            
            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
            #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
            
            // --------------------------------------------------
            // Structs and Packing
            
            // custom interpolators pre packing
            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
            
            struct Attributes
                {
                     float3 positionOS : POSITION;
                     float3 normalOS : NORMAL;
                     float4 tangentOS : TANGENT;
                     float4 uv0 : TEXCOORD0;
                     float4 color : COLOR;
                    #if UNITY_ANY_INSTANCING_ENABLED
                     uint instanceID : INSTANCEID_SEMANTIC;
                    #endif
                };
                struct Varyings
                {
                     float4 positionCS : SV_POSITION;
                     float3 positionWS;
                     float4 texCoord0;
                     float4 color;
                    #if UNITY_ANY_INSTANCING_ENABLED
                     uint instanceID : CUSTOM_INSTANCE_ID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                    #endif
                };
                struct SurfaceDescriptionInputs
                {
                     float2 NDCPosition;
                     float2 PixelPosition;
                     float4 uv0;
                };
                struct VertexDescriptionInputs
                {
                     float3 ObjectSpaceNormal;
                     float3 ObjectSpaceTangent;
                     float3 ObjectSpacePosition;
                };
                struct PackedVaryings
                {
                     float4 positionCS : SV_POSITION;
                     float4 texCoord0 : INTERP0;
                     float4 color : INTERP1;
                     float3 positionWS : INTERP2;
                    #if UNITY_ANY_INSTANCING_ENABLED
                     uint instanceID : CUSTOM_INSTANCE_ID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                    #endif
                };
            
            PackedVaryings PackVaryings (Varyings input)
                {
                    PackedVaryings output;
                    ZERO_INITIALIZE(PackedVaryings, output);
                    output.positionCS = input.positionCS;
                    output.texCoord0.xyzw = input.texCoord0;
                    output.color.xyzw = input.color;
                    output.positionWS.xyz = input.positionWS;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    output.instanceID = input.instanceID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    output.cullFace = input.cullFace;
                    #endif
                    return output;
                }
                
                Varyings UnpackVaryings (PackedVaryings input)
                {
                    Varyings output;
                    output.positionCS = input.positionCS;
                    output.texCoord0 = input.texCoord0.xyzw;
                    output.color = input.color.xyzw;
                    output.positionWS = input.positionWS.xyz;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    output.instanceID = input.instanceID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    output.cullFace = input.cullFace;
                    #endif
                    return output;
                }
                
            
            // --------------------------------------------------
            // Graph
            
            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
                float2 _Center;
                float4 _MainTex_TexelSize;
                float _Animation;
                float4 _Color;
                float2 _Scale;
                float _Noise_Scale;
                float _Noise_Edge;
                float _MaxDistance;
                float _Distance_Density;
                CBUFFER_END
                
                
                // Object and Global properties
                TEXTURE2D(_MainTex);
                SAMPLER(sampler_MainTex);
            
            // Graph Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Hashes.hlsl"
            
            // -- Property used by ScenePickingPass
            #ifdef SCENEPICKINGPASS
            float4 _SelectionID;
            #endif
            
            // -- Properties used by SceneSelectionPass
            #ifdef SCENESELECTIONPASS
            int _ObjectId;
            int _PassValue;
            #endif
            
            // Graph Functions
            
                void Unity_OneMinus_float(float In, out float Out)
                {
                    Out = 1 - In;
                }
                
                void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
                {
                    Out = A * B;
                }
                
                void Unity_Add_float2(float2 A, float2 B, out float2 Out)
                {
                    Out = A + B;
                }
                
                void Unity_Distance_float2(float2 A, float2 B, out float Out)
                {
                    Out = distance(A, B);
                }
                
                void Unity_Multiply_float_float(float A, float B, out float Out)
                {
                    Out = A * B;
                }
                
                void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
                {
                    Out = UV * Tiling + Offset;
                }
                
                float2 Unity_GradientNoise_Deterministic_Dir_float(float2 p)
                {
                    float x; Hash_Tchou_2_1_float(p, x);
                    return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
                }
                
                void Unity_GradientNoise_Deterministic_float (float2 UV, float3 Scale, out float Out)
                {
                    float2 p = UV * Scale.xy;
                    float2 ip = floor(p);
                    float2 fp = frac(p);
                    float d00 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip), fp);
                    float d01 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
                    float d10 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
                    float d11 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
                    fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
                    Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
                }
                
                void Unity_Clamp_float(float In, float Min, float Max, out float Out)
                {
                    Out = clamp(In, Min, Max);
                }
                
                void Unity_Subtract_float(float A, float B, out float Out)
                {
                    Out = A - B;
                }
                
                void Unity_Step_float(float Edge, float In, out float Out)
                {
                    Out = step(Edge, In);
                }
            
            // Custom interpolators pre vertex
            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
            
            // Graph Vertex
            struct VertexDescription
                {
                    float3 Position;
                    float3 Normal;
                    float3 Tangent;
                };
                
                VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                {
                    VertexDescription description = (VertexDescription)0;
                    description.Position = IN.ObjectSpacePosition;
                    description.Normal = IN.ObjectSpaceNormal;
                    description.Tangent = IN.ObjectSpaceTangent;
                    return description;
                }
            
            // Custom interpolators, pre surface
            #ifdef FEATURES_GRAPH_VERTEX
            Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
            {
            return output;
            }
            #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
            #endif
            
            // Graph Pixel
            struct SurfaceDescription
                {
                    float3 BaseColor;
                    float Alpha;
                };
                
                SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                {
                    SurfaceDescription surface = (SurfaceDescription)0;
                    float4 _Property_31fa3ca5c21247c58931198e538f9548_Out_0_Vector4 = _Color;
                    float _Property_c8c6cb5d1f6c41fa8b25f535c6111186_Out_0_Float = _Animation;
                    float _OneMinus_ef2cc62e079f42ec82c6810f7c97a5d8_Out_1_Float;
                    Unity_OneMinus_float(_Property_c8c6cb5d1f6c41fa8b25f535c6111186_Out_0_Float, _OneMinus_ef2cc62e079f42ec82c6810f7c97a5d8_Out_1_Float);
                    float _Property_4805fd71a92845fbaca70709851d5aed_Out_0_Float = _Distance_Density;
                    float2 _Property_6da876a80b994009b42383095f32687e_Out_0_Vector2 = _Center;
                    float2 _Vector2_97499ae5dbf3460ea237a9122958e1e6_Out_0_Vector2 = float2(unity_OrthoParams.x, unity_OrthoParams.y);
                    float4 _ScreenPosition_d125c5d185ed4633abe9ab57dff69ae9_Out_0_Vector4 = float4(IN.NDCPosition.xy * 2 - 1, 0, 0);
                    float2 _Multiply_a0e66ce548f8481fb06f4eac25891c2b_Out_2_Vector2;
                    Unity_Multiply_float2_float2(_Vector2_97499ae5dbf3460ea237a9122958e1e6_Out_0_Vector2, (_ScreenPosition_d125c5d185ed4633abe9ab57dff69ae9_Out_0_Vector4.xy), _Multiply_a0e66ce548f8481fb06f4eac25891c2b_Out_2_Vector2);
                    float2 _Add_3748a9f4971040b0b227ad01316552ae_Out_2_Vector2;
                    Unity_Add_float2((_WorldSpaceCameraPos.xy), _Multiply_a0e66ce548f8481fb06f4eac25891c2b_Out_2_Vector2, _Add_3748a9f4971040b0b227ad01316552ae_Out_2_Vector2);
                    float _Distance_bc17edee1caf467a998bd71927c0dd44_Out_2_Float;
                    Unity_Distance_float2(_Property_6da876a80b994009b42383095f32687e_Out_0_Vector2, _Add_3748a9f4971040b0b227ad01316552ae_Out_2_Vector2, _Distance_bc17edee1caf467a998bd71927c0dd44_Out_2_Float);
                    float _Multiply_b3eef78f4142463fb47cfa53c4fe6409_Out_2_Float;
                    Unity_Multiply_float_float(_Property_4805fd71a92845fbaca70709851d5aed_Out_0_Float, _Distance_bc17edee1caf467a998bd71927c0dd44_Out_2_Float, _Multiply_b3eef78f4142463fb47cfa53c4fe6409_Out_2_Float);
                    float _Multiply_04a5b6c4c97b4716aed63582d640672c_Out_2_Float;
                    Unity_Multiply_float_float(_OneMinus_ef2cc62e079f42ec82c6810f7c97a5d8_Out_1_Float, _Multiply_b3eef78f4142463fb47cfa53c4fe6409_Out_2_Float, _Multiply_04a5b6c4c97b4716aed63582d640672c_Out_2_Float);
                    float2 _Property_a2bd4e2030504a5ea02dcfbeadfe7094_Out_0_Vector2 = _Scale;
                    float2 _TilingAndOffset_17a6db1f92244f87b4c48536c062f286_Out_3_Vector2;
                    Unity_TilingAndOffset_float(IN.uv0.xy, _Property_a2bd4e2030504a5ea02dcfbeadfe7094_Out_0_Vector2, _Add_3748a9f4971040b0b227ad01316552ae_Out_2_Vector2, _TilingAndOffset_17a6db1f92244f87b4c48536c062f286_Out_3_Vector2);
                    float _Property_eff07c21e1354ba4a867a22aeb3e1066_Out_0_Float = _Noise_Scale;
                    float _GradientNoise_38e8376d700b40e4bc7b28256572aeb3_Out_2_Float;
                    Unity_GradientNoise_Deterministic_float(_TilingAndOffset_17a6db1f92244f87b4c48536c062f286_Out_3_Vector2, _Property_eff07c21e1354ba4a867a22aeb3e1066_Out_0_Float, _GradientNoise_38e8376d700b40e4bc7b28256572aeb3_Out_2_Float);
                    float _Clamp_196709ebdc7c4dad9b8c0aaee3e71a4d_Out_3_Float;
                    Unity_Clamp_float(_GradientNoise_38e8376d700b40e4bc7b28256572aeb3_Out_2_Float, float(0), float(1), _Clamp_196709ebdc7c4dad9b8c0aaee3e71a4d_Out_3_Float);
                    float _Property_65a49687b3b9484994d48ce8f6bf0de1_Out_0_Float = _Animation;
                    float _Property_70c8f13347e748f5a8719244cc2675bc_Out_0_Float = _MaxDistance;
                    float _Multiply_ca660498efff4e73b473e201edb21c95_Out_2_Float;
                    Unity_Multiply_float_float(_Property_65a49687b3b9484994d48ce8f6bf0de1_Out_0_Float, _Property_70c8f13347e748f5a8719244cc2675bc_Out_0_Float, _Multiply_ca660498efff4e73b473e201edb21c95_Out_2_Float);
                    float _Subtract_0b96d4f0f38f4d089c76ef3a3f9bd965_Out_2_Float;
                    Unity_Subtract_float(_Multiply_ca660498efff4e73b473e201edb21c95_Out_2_Float, _Distance_bc17edee1caf467a998bd71927c0dd44_Out_2_Float, _Subtract_0b96d4f0f38f4d089c76ef3a3f9bd965_Out_2_Float);
                    float _Clamp_37d5b241fae743379d1fb7c0367d971c_Out_3_Float;
                    Unity_Clamp_float(_Subtract_0b96d4f0f38f4d089c76ef3a3f9bd965_Out_2_Float, float(0), float(1), _Clamp_37d5b241fae743379d1fb7c0367d971c_Out_3_Float);
                    float _Multiply_8b0e8b89377d46d58fa0bfa3ff629752_Out_2_Float;
                    Unity_Multiply_float_float(_Clamp_196709ebdc7c4dad9b8c0aaee3e71a4d_Out_3_Float, _Clamp_37d5b241fae743379d1fb7c0367d971c_Out_3_Float, _Multiply_8b0e8b89377d46d58fa0bfa3ff629752_Out_2_Float);
                    float _Step_6c5aceaba33e44cf8ecc90357a07c1de_Out_2_Float;
                    Unity_Step_float(_Multiply_04a5b6c4c97b4716aed63582d640672c_Out_2_Float, _Multiply_8b0e8b89377d46d58fa0bfa3ff629752_Out_2_Float, _Step_6c5aceaba33e44cf8ecc90357a07c1de_Out_2_Float);
                    surface.BaseColor = (_Property_31fa3ca5c21247c58931198e538f9548_Out_0_Vector4.xyz);
                    surface.Alpha = _Step_6c5aceaba33e44cf8ecc90357a07c1de_Out_2_Float;
                    return surface;
                }
            
            // --------------------------------------------------
            // Build Graph Inputs
            #ifdef HAVE_VFX_MODIFICATION
            #define VFX_SRP_ATTRIBUTES Attributes
            #define VFX_SRP_VARYINGS Varyings
            #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
            #endif
            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                {
                    VertexDescriptionInputs output;
                    ZERO_INITIALIZE(VertexDescriptionInputs, output);
                
                    output.ObjectSpaceNormal =                          input.normalOS;
                    output.ObjectSpaceTangent =                         input.tangentOS.xyz;
                    output.ObjectSpacePosition =                        input.positionOS;
                
                    return output;
                }
                
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                {
                    SurfaceDescriptionInputs output;
                    ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
                
                #ifdef HAVE_VFX_MODIFICATION
                #if VFX_USE_GRAPH_VALUES
                    uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
                    /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
                #endif
                    /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
                
                #endif
                
                    
                
                
                
                
                
                
                    #if UNITY_UV_STARTS_AT_TOP
                    output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x < 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
                    #else
                    output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x > 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
                    #endif
                
                    output.NDCPosition = output.PixelPosition.xy / _ScaledScreenParams.xy;
                    output.NDCPosition.y = 1.0f - output.NDCPosition.y;
                
                    output.uv0 = input.texCoord0;
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                #else
                #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                #endif
                #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                
                        return output;
                }
                
            
            // --------------------------------------------------
            // Main
            
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Editor/2D/ShaderGraph/Includes/SpriteUnlitPass.hlsl"
            
            // --------------------------------------------------
            // Visual Effect Vertex Invocations
            #ifdef HAVE_VFX_MODIFICATION
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
            #endif
            
            ENDHLSL
            }
        }
        CustomEditor "UnityEditor.ShaderGraph.GenericShaderGraphMaterialGUI"
        FallBack "Hidden/Shader Graph/FallbackError"
    }