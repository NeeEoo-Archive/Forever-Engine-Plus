package gameObjects;

import base.scripting.HScript;
import flixel.addons.effects.FlxTrail;
import flixel.util.FlxColor;
import meta.data.*;
import meta.data.dependency.FNFSprite;
import state.PlayState;

using StringTools;

typedef CharacterData =
{
	var offsetX:Float;
	var offsetY:Float;
	var camOffsetX:Float;
	var camOffsetY:Float;
	var quickDancer:Bool;
	var healthbarColor:FlxColor;
	var healthIcon:String;
	var deathCharacter:String;
	var deathSFX:String;
	var deathMusic:String;
	var deathMusicBPM:Float;
	var deathEndMusic:String;
}

/**
	The character class initialises any and all characters that exist within gameplay.
**/
class Character extends FNFSprite
{
	public var isPlayer:Bool = false;
	public var curCharacter:String = 'bf';

	public var holdTimer:Float = 0;

	public var characterData:CharacterData;
	public var adjustPos:Bool = true;

	public var script:HScript;

	public function new(?isPlayer:Bool = false)
	{
		super(x, y);
		this.isPlayer = isPlayer;
	}

	public function setCharacter(x:Float, y:Float, character:String):Character
	{
		curCharacter = character;
		antialiasing = true;

		characterData = {
			offsetY: 0,
			offsetX: 0,
			camOffsetY: 0,
			camOffsetX: 0,
			quickDancer: false,
			healthIcon: 'face',
			healthbarColor: FlxColor.fromRGB(192, 192, 192),
			deathCharacter: 'bf-dead',
			deathSFX: "fnf_loss_sfx",
			deathMusic: "gameOver",
			deathEndMusic: "gameOverEnd",
			deathMusicBPM: 100
		};

		script = new HScript(Paths.data('characters/$character.hxs'));
		script.set_script_object(this);
		script.set("PlayState", PlayState);
		script.set("game", PlayState.instance);
		script.set("addShader", function(name:String, settings:Array<Dynamic>) {
			PlayState.instance.shaders.addShader(name, settings, [this]);
		});
		script.call("loadCharacter");

		dance();

		if (isPlayer) // fuck you ninjamuffin lmao
		{
			flipX = !flipX;

			// Doesn't flip for BF, since his are already in the right place???
			if (!curCharacter.startsWith('bf'))
				flipLeftRight();
			//
		}
		else if (curCharacter.startsWith('bf'))
			flipLeftRight();

		if (adjustPos)
		{
			x += characterData.offsetX;
			trace('character ${curCharacter} scale ${scale.y}');
			y += (characterData.offsetY - (frameHeight * scale.y));
		}

		this.x = x;
		this.y = y;

		return this;
	}

	public function flipLeftRight():Void
	{
		if(animation.getByName("singRIGHT") != null && animation.getByName("singLEFT") != null)
		{
			// get the old right sprite
			var oldRight = animation.getByName('singRIGHT').frames;
			// set the right to the left
			animation.getByName('singRIGHT').frames = animation.getByName('singLEFT').frames;
			// set the left to the old right
			animation.getByName('singLEFT').frames = oldRight;
		}

		if(animation.getByName("singRIGHTmiss") != null && animation.getByName("singLEFTmiss") != null)
		{
			var oldMiss = animation.getByName('singRIGHTmiss').frames;
			animation.getByName('singRIGHTmiss').frames = animation.getByName('singLEFTmiss').frames;
			animation.getByName('singLEFTmiss').frames = oldMiss;
		}
	}

	override function update(elapsed:Float)
	{
		if (!isPlayer)
		{
			if (animation.curAnim.name.startsWith('sing'))
			{
				holdTimer += elapsed;
			}

			var dadVar:Float = 4;
			if (holdTimer >= Conductor.stepCrochet * dadVar * 0.001)
			{
				dance();
				holdTimer = 0;
			}
		}

		if(script.exists("onUpdate"))
			script.call("onUpdate", [elapsed]);

		super.update(elapsed);
	}

	public function beatHit(curBeat:Int)
	{
		if(script.exists("onBeat"))
			script.call("onBeat", [curBeat]);
	}

	public function stepHit(curStep:Int)
	{
		if (script.exists("onStep"))
			script.call("onStep", [curStep]);
	}

	public function dance(?forced:Bool = false)
	{
		if (script.exists("dance"))
			script.call("dance", [forced]);
		else
			playAnim('idle', forced);
	}

	public function onMiss(?forced:Bool = false)
	{
		if (script.exists("onMiss"))
			script.call("onMiss", [forced]);
	}

	override public function playAnim(AnimName:String, Force:Bool = false, Reversed:Bool = false, Frame:Int = 0):Void
	{
		if (animation.getByName(AnimName) != null)
			super.playAnim(AnimName, Force, Reversed, Frame);

		if(script.exists("onPlayAnim"))
			script.call("onPlayAnim", [AnimName]);
	}
}
