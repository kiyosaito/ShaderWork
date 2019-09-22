Shader "Camera Filter/Drawing Paper" 
{
	//Shader declares Material properties in a Properties block. 
	Properties
	{
		//These are the Varibles that are normally visable if the Shader renders on a material
		// Camera Render of the scene
		_MainTex("Base (RGB)", 2D) = "white" {} 
		//Paper Texture Overlay
		_TextureOverlay("Base (RGB)", 2D) = "white" {}
		// time by which the animation element of this shader will flicker and change
		_TimeX("Time", Range(0.0, 1.0)) = 1.0 
	}
	SubShader
	{
	// pass that renders the below elements
		Pass
		{			
			// turn off backface culling
			Cull Off 
			//Controls whether pixels from this object are written to the depth buffer
			ZWrite Off 
			//How should depth testing be performed.
			ZTest Always
			CGPROGRAM
			//Correspond to individual Mesh data elements, like vertex position, normal mesh, and texture coordinates.
			#pragma vertex vert
			//fragment (pixel) shader outputs a color
			#pragma fragment frag
			#pragma fragmentoption ARB_precision_hint_fastest
			//There are limits to how many interpolator variables can be used in total to pass the information from the vertex into the fragment shader. 
			//The limit depends on the platform and GPU
			//Up to 10 interpolators: Direct3D 9 shader model 3.0 (#pragma target 3.0).
			#pragma target 3.0
			#pragma glsl
			//The UnityCG.cginc file contains commonly used declarations and functions so that the shaders can be kept smaller
			#include "UnityCG.cginc"

			//If you want to access some of those properties from the Properties block
			//You need to declare a Cg/HLSL variable with the same name and a matching type. as seen below
			// Camera Render of the scene
			uniform sampler2D _MainTex;
			//Paper Texture Overlay
			uniform sampler2D _TextureOverlay;
			// time by which the animation element of this shader will flicker and change
			uniform float _TimeX;

			//Color of out pencil lines
			uniform float4 _PencilColour;
			//color overlay
			uniform float4 _PaperOverlayColor;
			
			//size of the pencil strokes
			uniform float _PencilSize;
			//detail of the pencil strokes
			uniform float _PencilCorrection;
			//darkness of the pencil strokes
			uniform float _Intensity;
			//speed of animation flicker
			uniform float _AnimationSpeed;
			//fade in of the edges
			uniform float _CornerLoss;
			//amount that _PaperOverlayColor affects the paper texture/screen
			uniform float _PaperFadeColor;
			//amount that the paper vs camera is rendered
			uniform float _PaperToCameraFadeAmount;

			//_TexelSize - a float4 property contains texture size information:
			/*
				x contains 1.0 / width
				y contains 1.0 / height
				z contains width
				w contains height
			*/
			uniform float2 _MainTex_TexelSize;

			//
			struct appdata_t
			{
				// A vertex shader needs to output the final clip space position of a vertex, 
				//so that the GPU knows where on the screen to rasterize it, and at what depth.
				//This output needs to have the SV_POSITION semantic, and be of a float4 type.
				//POSITION is the vertex position, typically a float3 or float4.
				float4 vertex   : POSITION;
				//COLOR is the per-vertex color, typically a float4.
				float4 color    : COLOR;
				//TEXCOORD0, TEXCOORD1 etc are used to indicate arbitrary high precision data such as texture coordinates and positions.
				//TEXCOORD0 is the first UV coordinate, typically float2, float3 or float4.
				float2 texcoord : TEXCOORD0; 
			};

			struct v2f
			{
				//TEXCOORD0, TEXCOORD1 etc are used to indicate arbitrary high precision data such as texture coordinates and positions.
				//TEXCOORD0, TEXCOORD1 etc are used to indicate arbitrary high precision data such as texture coordinates and positions.
				float2 texcoord  : TEXCOORD0;
				// A vertex shader needs to output the final clip space position of a vertex, 
				//so that the GPU knows where on the screen to rasterize it, and at what depth.
				//This output needs to have the SV_POSITION semantic, and be of a float4 type.
				//POSITION is the vertex position, typically a float3 or float4.
				float4 vertex   : SV_POSITION;
				//COLOR is the per-vertex color, typically a float4.
				float4 color    : COLOR;
			};

			v2f vert(appdata_t IN)
			{
				v2f OUT;
				//UnityObjectToClipPos = Transforms a point from object space to the camera’s clip space in equal coordinates.
				OUT.vertex = UnityObjectToClipPos(IN.vertex);
				OUT.texcoord = IN.texcoord;
				OUT.color = IN.color;

				return OUT;
			}

			half4 _MainTex_ST;
			//The function frag has a return type of fixed4 (low precision RGBA color). 
			//As it only returns a single value, the semantic is indicated on the function itself, : SV_Target, : COLOR
			float4 frag(v2f i) : COLOR
			{
				//UnityStereoScreenSpaceUVAdjust, this returns the result of applying the scale and bias in sb to the texture coordinates in uv. Otherwise, 
				//this returns the texture coordinates unmodified. Use this to apply a per-eye scale and bias only when in Single Pass Stereo rendering mode.
				float2 uvst = UnityStereoScreenSpaceUVAdjust(i.texcoord, _MainTex_ST);
				float2 uv = uvst;
				#if UNITY_UV_STARTS_AT_TOP
				if (_MainTex_TexelSize.y < 0)
					uv.y = 1 - uv.y;
				#endif

				float4 f = tex2D(_MainTex, uvst);
				float3 paper = tex2D(_TextureOverlay,uv).rgb;
				float ce = 1;
				float4 tex1[4];
				float4 tex2[4];
				float pencileSize = _PencilSize;
				float animationOverTime = _TimeX * _AnimationSpeed;
				float s = floor(sin(animationOverTime * 10)*0.02) / 12;
				float c = floor(cos(animationOverTime * 10)*0.02) / 12;
				float2 dist = float2(c + paper.b*0.02,s + paper.b*0.02);
				float3 paper2 = tex2D(_TextureOverlay,uvst + dist).rgb;
				tex2[0] = tex2D(_MainTex, uvst + float2(pencileSize,0) + dist / 128);
				tex2[1] = tex2D(_MainTex, uvst + float2(-pencileSize,0) + dist / 128);
				tex2[2] = tex2D(_MainTex, uvst + float2(0, pencileSize) + dist / 128);
				tex2[3] = tex2D(_MainTex, uvst + float2(0,-pencileSize) + dist / 128);

				for (int i = 0; i < 4; i++)
				{
					tex1[i] = saturate(1.0 - distance(tex2[i].r, f.r));
					tex1[i] *= saturate(1.0 - distance(tex2[i].g, f.g));
					tex1[i] *= saturate(1.0 - distance(tex2[i].b, f.b));
					tex1[i] = pow(tex1[i], _PencilCorrection * 25);
					ce *= dot(tex1[i], 1.0);
				}

				ce = saturate(ce);
				float l = 1 - ce;
				float3 ax = l;
				ax *= paper2.b;
				ax = lerp(float3(0.0,0.0,0.0),ax*_Intensity*1.5,1);//adds a foggy element to the Intensity 
				float gg = lerp(1 - paper.g,0,1 - _CornerLoss);
				ax = lerp(ax,float3(0.0,0.0,0.0),gg);
				paper.rgb = float3(paper.r,paper.r,paper.r);// paper.r for all three RGB sections of the colour gives this image a brown red tone from the paper
				paper.rgb *= float3(0.695,0.496,0.3125)*1.2;//applies this colour to the paper material
				paper = lerp(paper.rgb,_PaperOverlayColor.rgb, _PaperFadeColor);//allows us to fade to a solid colour (_PaperFadeColor Color)
				paper = lerp(paper,_PencilColour.rgb,ax*_Intensity);//applies the colour of the pencil and its intensity to the paper
				float pg = gg * 0.2;
				paper -= pg * 0.5;//allows the corner loss to have some of the paper texture affect the corners
				paper = lerp(f,paper, _PaperToCameraFadeAmount);// allows us to fade to the actual camera view
				return float4(paper, 1.0);
			}
		ENDCG
		}

	}
}