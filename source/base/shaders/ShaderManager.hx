package base.shaders;

import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxSprite;
import openfl.filters.BitmapFilter;
import openfl.filters.ShaderFilter;

/**
 * This class is a manager that manages `CustomShader`s but also update them etc.
 * @author Sword352
 */
class ShaderManager
{
    public var shaders:Map<String, CustomShader>;
	public var shadersBitmap:Map<String, ShaderFilter>;
	public var applyObjects:Array<FlxBasic>;

    public function new()
    {
        shaders = new Map<String, CustomShader>();
		shadersBitmap = new Map<String, ShaderFilter>();
		applyObjects = [];
    }

    /**
	 * Add a new `CustomShader` to the objects of the `applyArray` array and add the shader to the manager.
	 * @param name The name of the hscript file.
	 * @param settings Settings for the shader.
	 * @param applyArray The objects that will have the shader. (FlxSprite / FlxCamera)
	 * @return The shader, added to the manager and applied to the objects of the `applyArray` array.
     */
    public function addShader(name:String, settings:Array<Dynamic>, applyArray:Array<FlxBasic>)
    {
        var newShader:CustomShader = new CustomShader(name, settings);
		shaders[name] = newShader;

		for (object in applyArray)
		{
			applyObjects.push(object);
			if (object is FlxSprite)
			{
				cast(object, FlxSprite).shader = newShader.shader;
			}
			else if (object is FlxCamera)
			{
				var obj = cast(object, FlxCamera);
				var filter = new ShaderFilter(newShader.shader);
				@:privateAccess {
					if(obj._filters == null) obj._filters = [];
					obj._filters.push(filter);
				}
				shadersBitmap[name] = filter;
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
			if(shaders[shader] != null)
				shaders[shader].update(elapsed);
		}
	}

	/**
	 * Update (Post) all the shaders from the manager.
	 * @param elapsed The `elapsed` variable.
	 */
	public function updatePost(elapsed:Float)
	{
		for (shader in shaders.keys())
		{
			if(shaders[shader] != null)
				shaders[shader].updatePost(elapsed);
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
			if(shaders[shader] != null)
				shaders[shader].beatHit(curBeat);
		}
	}

	/**
	 * Make the shaders from the manager react to the step.
	 * @param curStep The `curStep` variable.
	 */
	public function stepHit(curStep:Int)
	{
		for (shader in shaders.keys())
		{
			if(shaders[shader] != null)
				shaders[shader].stepHit(curStep);
		}
	}

	/**
	 * Remove a shader from the manager.
	 * @param shader The shader to remove.
	 */
	public function removeShader(shader:String)
	{
		if(shaders[shader] != null)
		{
			for(object in applyObjects) // on all the objects
			{
				if(object is FlxSprite) // if the object is a FlxSprite
				{
					var obj = cast(object, FlxSprite);
					if(obj.shader == shaders[shader].shader) // and the shader of the sprite is the correct shader
					{
						obj.shader = null; // removing it
						continue;
					}
				}
				else if(object is FlxCamera) // if the object is a FlxCamera
				{
					var obj = cast(object, FlxCamera);
					@:privateAccess {
						if (obj._filters[obj._filters.indexOf(shadersBitmap[shader])] != null) // and the shader of the camera is the correct shader
						{
							cast(object, FlxCamera)._filters.remove(shadersBitmap[shader]); // removing the shader
							continue;
						}
					}
				}
			}

			if(shadersBitmap[shader] != null)
				shadersBitmap[shader] = null;
			shaders[shader].script.destroy(); // destroying the shader script to clear the memory
			shaders[shader].shader = null; // same here with the actual shader
			shaders[shader] = null; // then its fully destroyed
		}
		else
			trace('Error closing the shader $shader! (Null Shader)');
	}

	/**
	 * Removes all the shaders from the manager.
	 */
	public function clearShaders()
	{
		for (object in applyObjects)
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
		for (shader in shaders) {
			shader.script.destroy();
			shader.shader = null;
		}
		shaders.clear();
	}
}