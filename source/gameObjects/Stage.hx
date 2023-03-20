package gameObjects;

import base.scripting.HScript;
import flixel.FlxBasic;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import state.PlayState;

using StringTools;

class Stage extends FlxTypedGroup<FlxBasic>
{
	public var foreground:FlxTypedGroup<FlxBasic>;
	public var script:HScript;

	public function new(curStage:String = "stage")
	{
		super();

		// to apply to foreground use foreground.add(); instead of add();
		foreground = new FlxTypedGroup<FlxBasic>();

		script = new HScript(Paths.data('stages/$curStage.hxs'));
		script.set_script_object(this);
		script.set("daPixelZoom", PlayState.daPixelZoom);
		script.set("BackgroundDancer", gameObjects.background.BackgroundDancer);
		script.set("BackgroundGirls", gameObjects.background.BackgroundGirls);
		script.set("game", PlayState.instance);
		script.set("PlayState", PlayState);
		script.set("curStage", curStage);
		script.set("add", PlayState.instance.add);
		script.set("foreground", foreground);
		script.set("addShader", PlayState.instance.shaders.addShader);
		script.call("onCreate");
	}

	public function createPost()
	{
		if(script.exists("onCreatePost"))
			script.call("onCreatePost");
	}

	public function addLayers()
	{
		if (script.exists("addLayers"))
			script.call("addLayers");
	}

	public function repositionCharacters(boyfriend:Character, dad:Character, gf:Character)
	{
		if(script.exists("repositionCharacters"))
			script.call("repositionCharacters", [boyfriend, dad, gf]);
	}

	public function fixGirlfriend() // if dad's or bf's curCharacter is equal to gf's curCharacter, hide gf and place dad at gf's place (think of Tutorial)
	{
		for (char in [PlayState.boyfriend, PlayState.dadOpponent])
		{
			if (char.curCharacter == PlayState.gf.curCharacter)
			{
				char.setPosition(PlayState.gf.x, PlayState.gf.y);
				PlayState.gf.visible = false;
			}
		}
	}

	public function updateStage(elapsed:Float)
	{
		if(script.exists("onUpdate"))
			script.call("onUpdate", [elapsed]);
	}

	public function updateStagePost(elapsed:Float)
	{
		if(script.exists("onUpdatePost"))
			script.call("onUpdatePost", [elapsed]);
	}

	public function stepHit(curStep:Int)
	{
		if(script.exists("onStep"))
			script.call("onStep", [curStep]);
	}

	public function beatHit(curBeat:Int)
	{
		if(script.exists("onBeat"))
			script.call("onBeat", [curBeat]);
	}

	public function dispatchEvent(event:String, values:Array<String>)
	{
		if (script.exists("dispatchEvent"))
			script.call("dispatchEvent", [event, values]);
	}
	
	override function add(Object:FlxBasic):FlxBasic
	{
		if (Init.trueSettings.get('Disable Antialiasing') && Std.isOfType(Object, FlxSprite))
			cast(Object, FlxSprite).antialiasing = false;
		return super.add(Object);
	}
}
