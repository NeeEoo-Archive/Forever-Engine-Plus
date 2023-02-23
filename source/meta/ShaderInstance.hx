package meta;

import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxSprite;
import flixel.graphics.tile.FlxGraphicsShader;
import openfl.Assets;
import openfl.filters.ShaderFilter;
import sys.io.File;

typedef ShaderJson =
{
    var frag:String;
    var vert:String;
    var variablesToChangeOnCreate:Array<ShaderVariable>;
}

typedef ShaderVariable = 
{
    var variable:String;
    var value:Dynamic;
}

/**
 * The `ShaderInstance` class allow you to make a shader "manager" to load and add shaders into your states and substates.
 * so proud of me lol
 * @author Sword352
 */
class ShaderInstance
{
    public var shaders:Map<String, FlxGraphicsShader>;

    public function new()
    {
		shaders = new Map<String, FlxGraphicsShader>();
    }

    /**
     * Load and add a shader into the objects from the `applyArray` array.
     * @param name The shader to load.
     * @param applyArray An array that contains all the objects.
     */
    public function addShader(name:String, applyArray:Array<FlxBasic>)
    {
        var shader:FlxGraphicsShader = loadSimpleShader(name);
        /*if(loadFromJson) shader = loadShaderFromJson(name);
        else shader = loadSimpleShader(name);*/

        for(object in applyArray)
        {
            if(object is FlxSprite)
            {
                cast(object, FlxSprite).shader = shader;
            }
            else if(object is FlxCamera)
            {
                cast(object, FlxCamera).setFilters([new ShaderFilter(shader)]);
            }
        }
    }

    /**
     * Load a shader from a json file.
     * @param name The name of the json file (without `.json`).
     */
    public function loadShaderFromJson(name:String)
    {
        var shaderFile:ShaderJson = haxe.Json.parse(Paths.jsonShader(name));
        var frag:String = File.getContent(Paths.shaderFragment(shaderFile.frag));
		var vert:String = File.getContent(Paths.shaderVertex(shaderFile.vert));

        var newShader:FlxGraphicsShader = new FlxGraphicsShader(vert, frag);

        if(shaderFile.variablesToChangeOnCreate != null && shaderFile.variablesToChangeOnCreate.length > 0)
        {
            for(i in 0...shaderFile.variablesToChangeOnCreate.length)
            {
                var daVariable = shaderFile.variablesToChangeOnCreate[i];
				switch(Type.getClass(daVariable.value))
				{
                    case Bool: newShader.setBool(daVariable.variable, daVariable.value);
					case Int: newShader.setInt(daVariable.variable, daVariable.value);
					case Float: newShader.setFloat(daVariable.variable, daVariable.value);
					/*case Array<Bool>: newShader.setBool(daVariable.variable, daVariable.value);
					case Array<Int>: newShader.setInt(daVariable.variable, daVariable.value);
					case Array<Float>: newShader.setFloat(daVariable.variable, daVariable.value);*/
                }
			}
        }

        shaders[name] = newShader;
        return shaders[name];
    }

	/**
	 * Make a simple shader.
	 * @param name The name of the frag/vert file. If the shader uses both files, make sure to name them with the same name!
	 */
    public function loadSimpleShader(name:String):FlxGraphicsShader
    {
		var frag:String = '';
		var vert:String = '';
        var paths = [Paths.shaderFragment(name), Paths.shaderVertex(name)];
		if(Assets.exists(paths[0])) frag = File.getContent(paths[0]);
		if(Assets.exists(paths[1])) vert = File.getContent(paths[1]);

        var newShader:FlxGraphicsShader = new FlxGraphicsShader(vert, frag);
        shaders[name] = newShader;
		return newShader;
    }

    /**
     * Set a uniform variable from a loaded shader.
     * @param name The shader name.
     * @param variable The variable to modify, as a string.
     * @param value The new value to set to the variable.
     */
    public function setShaderVariable(name:String, variable:String, value:Dynamic)
    {
        var shader = shaders[name];

		switch(Type.getClass(value))
		{
			case Bool: shader.setBool(variable, value);
			case Int: shader.setInt(variable, value);
			case Float: shader.setFloat(variable, value);
				/*case Array<Bool>: shader.setBoolArray(variable, value);
					case Array<Int>: shader.setIntArray(variable, value);
					case Array<Float>: shader.setFloatArray(variable, value); */
		}
    }
}