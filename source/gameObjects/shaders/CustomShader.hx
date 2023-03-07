package gameObjects.shaders;

import base.scripting.HScript;
import flixel.graphics.tile.FlxGraphicsShader;
import openfl.Assets;
import sys.io.File;

/**
 * A shader with a script.
 * @author Sword352
 */
class CustomShader
{
    public var shader:FlxGraphicsShader;
    public var script:HScript;

    public function new(file:String, settings:Array<Dynamic>)
    {
        script = new HScript(Paths.data('shaders/$file.hxs'));
        script.set("loadShader", function(file:String) {
            var frag:String = "";
            var vert:String = "";
            if(Assets.exists(Paths.shaderFragment(file))) frag = File.getContent(Paths.shaderFragment(file));
			if(Assets.exists(Paths.shaderVertex(file))) vert = File.getContent(Paths.shaderVertex(file));

            shader = new FlxGraphicsShader(vert, frag);
			script.set("shaderData", shader.data);
        });
        script.call("initShader", [settings]);
    }

    public function update(elapsed:Float)
    {
        if(script.exists("onUpdate"))
            script.call("onUpdate", [elapsed]);
    }

	public function beatHit(curBeat:Int)
	{
		if (script.exists("onBeat"))
			script.call("onBeat", [curBeat]);
	}

	public function stepHit(curStep:Int)
	{
		if (script.exists("onStep"))
			script.call("onStep", [curStep]);
	}
}