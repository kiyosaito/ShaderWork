﻿Shader "Custom/Outline"
{
	Properties
	{
		_Color("Main Color", Color) = (0.5,0.5,0.5,1)
		_MainTex("Texture", 2D) = "white" {}
		_OutlineColor("Outline Color", Color) = (0,0,0,1)
		_OutlineWidth("Outline Width", Range(1.0,5.0)) = 1.01
	}
		CGINCLUDE
#include "UnityCG.cginc."

			struct appdata {
			float4 vertex : POSITION;
			float3 normal : NORMAL;
		};
		struct v2f {
			float4 pos : POSITION;
			float3 normal : NORMAL;
		};
		float _OutlineWidth;
		float4 _OutlineColor;
		v2f vert(appdata v) {
			v.vertex.xyz *= _OutlineWidth;
			v2f o;
			o.pos = UnityObjectToClipPos(v.vertex);
			return o;
		}
		ENDCG
		SubShader
		{
			Tags{"Queue" = "Transparent+1"}
			pass //render the outline
			{ 
				ZWrite Off
				CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag
				half4 frag(v2f i) : COLOR
				{
					return _OutlineColor;
				}
					ENDCG
			}
			pass //normal render
			{
				ZWrite On

				Material
				{
					Diffuse[_Color]
					Ambient[_Color]
				}

				Lighting On

				SetTexture[_MainTex]
				{
					ConstantColor[_Color]
				}

				SetTexture[_MainTex]
				{
					Combine previous * primary DOUBLE
				}
			}
		}
}
//https://www.youtube.com/watch?v=SlTkBe4YNbo 