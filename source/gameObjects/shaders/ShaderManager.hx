package gameObjects.shaders;

import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxSprite;
import openfl.filters.ShaderFilter;

/**
 * A shader manager to add shaders to your states.
 * @author Sword352
 */
class ShaderManager
{
    public var shaders:Map<String, CustomShader>;

    public function new()
    {
        shaders = new Map<String, CustomShader>();
    }

    /**
	 * Add a new `CustomShader` to the objects of the `applyArray` array and add the shader to the manager.
     * @param name The name of the script file. (assets/data/shader/`name`.hxs)
     * @param applyArray The objects that will have the shader. (FlxSprite / FlxCamera)
     */
    public function addShader(name:String, applyArray:Array<FlxBasic>)
    {
        var newShader:CustomShader = new CustomShader(name);
		shaders[name] = newShader;

		for (object in applyArray)
		{
			if (object is FlxSprite)
			{
				cast(object, FlxSprite).shader = newShader.shader;
			}
			else if (object is FlxCamera)
			{
				cast(object, FlxCamera).filters.push(new ShaderFilter(newShader.shader));
			}
		}
    }

	/**
	 * Update all the shaders from the manager.
	 * @param elapsed The `elapsed` variable.
	 */
	public function update(elapsed:Float)
	{
		for(shader in shaders.keys())
		{
			shaders[shader].update(elapsed);
		}
	}

	/**
	 * Make the shaders from the manager react to the beat.
	 * @param curBeat The `curBeat` variable.
	 */
	public function beatHit(curBeat:Int)
	{
		for (shader in shaders.keys())
		{
			shaders[shader].beatHit(curBeat);
		}
	}
}

/**
 * A shader manager to add shaders to your substates.
 * @author Sword352
 */
class SubstateShaderManager extends ShaderManager
{
	var applyObjects:Array<FlxBasic>;

	public function new()
	{
		super();
		applyObjects = [];
	}

	/**
	 * Add a new `CustomShader` to the objects of the `applyArray` array and add the shader to the manager.
	 * @param name The name of the script file. (assets/data/shader/`name`.hxs)
	 * @param applyArray The objects that will have the shader. (FlxSprite / FlxCamera)
	 */
	override function addShader(name:String, applyArray:Array<FlxBasic>)
	{
		super.addShader(name, applyArray);
		for(object in applyArray) applyObjects.push(object);
	}

	/**
	 * Removes all the shaders from the manager.
	 */
	public function clearShaders()
	{
		shaders.clear();
		for(object in applyObjects)
		{
			if (object is FlxSprite)
			{
				cast(object, FlxSprite).shader = null;
			}
			else if (object is FlxCamera)
			{
				cast(object, FlxCamera).setFilters([]);
			}
		}
	}
}