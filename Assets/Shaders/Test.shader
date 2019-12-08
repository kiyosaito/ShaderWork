// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Shaders101/Basic"
{
	Properties
	{
		_MainTex("Texture",2D) = "White"{}
		_Color("Color",Color) = (1,1,1,1)
		_SecondTex("Second Texture", 2D) = "white" {}
		_Tween("Tween", Range(0, 1)) = 0
    }
    SubShader
    {
		Tags
		{
		"Queue" = "Transparent"
		"PreviewType" = "Plane"
		}
        Pass
        {
			Blend SrcAlpha OneMinusSrcAlpha
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };


            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
                return o;
            }
			sampler2D _MainTex;

			fixed4 frag(v2f i) : SV_Target
			{
				float4 color = tex2D(_MainTex,i.uv)*float4(i.uv.r,i.uv.g,1,1);
                return color;
            }
            ENDCG
        }
    }
}
