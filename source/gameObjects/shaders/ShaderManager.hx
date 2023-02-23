package gameObjects.shaders;

import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxSprite;
import openfl.filters.ShaderFilter;

/**
 * A wip shader manager to add shaders to your states and substates.
 */
class ShaderManager
{
    public var shaders:Map<String, CustomShader>;

    public function new()
    {
        shaders = new Map<String, CustomShader>();
    }

    public function addShader(name:String, applyArray:Array<FlxBasic>)
    {
        var newShader:CustomShader = new CustomShader(name);

		for (object in applyArray)
		{
			if (object is FlxSprite)
			{
				cast(object, FlxSprite).shader = newShader.shader;
			}
			else if (object is FlxCamera)
			{
				cast(object, FlxCamera).setFilters([new ShaderFilter(newShader.shader)]);
			}
		}
    }

	public function update(elapsed:Float)
	{
		for(shader in shaders.keys())
		{
			shaders[shader].update(elapsed);
		}
	}

	public function beatHit(curBeat:Int)
	{
		for (shader in shaders.keys())
		{
			shaders[shader].beatHit(curBeat);
		}
	}
}