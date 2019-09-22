// This section allows for easy sorting of our shader in the shader menu
Shader "Lesson/Normal Albedo Colour Tint"
{
	// Are the public properties seen on a material 
	Properties
	{
		_Texture("Texture",2D) = "black"{}
	// Our Variable name is _Texture 
	// Our Display name is Texture
	// It is of type 2D and the default untextured colour is black
		_NormalMap("Normal",2D)="bump"{}
	//uses rgb colour value to create xyz depth to the material
	//bump tells unity this material needs to be marked as a normal map
	//so that it can be used correctly
		_Colour("Tint",Color)=(0,0,0,0)
			//RGBA Reg Green Blue Alpha
	}
		// You can have multiple subshaders
		// These run at different GPU levels on different platforms
		SubShader
	{
		Tags
		{
			"RenderType" = "Opaque"
			// Tags are basically key-value pairs
			// Inside a SubShader tags are used to determine rendering order and other parameters of a SubShader

			// RenderType tag categorizes
			// Shaders into several predefined groups
		}
		CGPROGRAM // This is the start of our C for Graphic Language
		#pragma surface MainColour Lambert
		// The surface of our model is affected by the mainColour Function 
		// The material type is Lambert
		// Lambert is a flat Material that has no specular
		//(shiny spots)
		sampler2D _Texture;
	// This connects out _Texture Variable that is in the Properties section to our 2D _Texture Variable in CG
	sampler2D _NormalMap; //connects our _ NormalMap variable from the properties to the _NormalMap in CG
	fixed4 _Colour;
	//reference to the input _Colour in the properties section
	//fixed4 is for small decimals
	//allows us to store RGBA
	struct Input
	{
		float2 uv_Texture;
		// This is in reference to our UV map of our model
		//UV maps are wrapping of a model 
		//the letters "U" and "V" denote the acxes of the
		//2D texture because "X", "Y" and "Z" are already used to denote the axes of the 3D object in model space
		float2 uv_NormalMap;
		//UV map link to the _NormalMap image 
	};
	void MainColour(Input IN, inout SurfaceOutput o) 
	{
		o.Albedo = tex2D(_Texture, IN.uv_Texture).rgb * _Colour;
		//albedo is in reference to the surface image and RGB of our model
		//RGB Red Green Blue
		//we are setting the models surface to the colour of ouyr Texture2D
		//and matching the Texture to our models UV mapping
		o.Normal = UnpackNormal(tex2D(_NormalMap, IN.uv_NormalMap));
		//_NormalMap is in reference to the bump map in properties
		//UnpackNormal is required because the file is compressed
		//we need to decompress and get the ture value from the Image
		//Bump maps are visible when light reflects off
		//the light is bounced off at angles according to the images rgb or xyz values
		//this creates the illusion of depth
	}
		ENDCG // This is the end of our C for Graphics Language
	}
		FallBack "Diffuse"//if all else fails standard sahder(Lambert and Texture)
}