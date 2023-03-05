package gameObjects.userInterface.menu;

import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;

typedef JsonMenuChar =
{
	var name:String;
	var anim:String;
	var confirmAnim:String;
	var fps:Int;
	var scale:Float;
	var offsets:Array<Float>;
	var flipX:Bool;
}

class MenuCharacter extends FlxSprite
{
	public var character:String = '';
	var baseX:Float = 0;
	var baseY:Float = 0;

	public function new(x:Float, newCharacter:String = 'bf')
	{
		super(x);
		y += 70;

		baseX = x;
		baseY = y;

		createCharacter(newCharacter);
		updateHitbox();
	}

	public function createCharacter(newCharacter:String)
	{
		if(newCharacter == "NONE")
		{
			character = "NONE";
			visible = false;
		}
		else if(character == newCharacter) return;
		else
		{
			var data:JsonMenuChar = haxe.Json.parse(openfl.Assets.getText(Paths.getPath('images/menus/base/storymenu/characters/$newCharacter/$newCharacter.json',
				TEXT)));
			frames = Paths.getSparrowAtlas('menus/base/storymenu/characters/$newCharacter/${data.name}');
			visible = true;

			animation.addByPrefix("idle", data.anim, data.fps, true);
			animation.addByPrefix("confirm", data.confirmAnim, data.fps, false);
			animation.play("idle");

			setGraphicSize(Std.int(width * data.scale));
			updateHitbox();
			setPosition(baseX + data.offsets[0], baseY + data.offsets[1]);
			flipX = data.flipX;

			character = newCharacter;
		}
	}
}
