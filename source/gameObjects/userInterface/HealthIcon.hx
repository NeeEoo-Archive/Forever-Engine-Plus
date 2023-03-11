package gameObjects.userInterface;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.FlxGraphic;
import meta.data.dependency.FNFSprite;
import sys.FileSystem;

using StringTools;

typedef IconJson =
{
	var anims:Array<AnimatedIconAnimation>;
	var offsets:Array<Float>;
	var flipX:Bool;
}

typedef AnimatedIconAnimation =
{
	var animation_name:String;
	var animation_prefix:String;
	var fps:Int;
	var offsets:Array<Float>;
}

class HealthIcon extends FNFSprite
{
	// rewrite using da new icon system as ninjamuffin would say it
	public var sprTracker:FlxSprite;
	public var initialWidth:Float = 0;
	public var initialHeight:Float = 0;
	public var animatedIcon:Bool = false;
	public var iconData:IconJson = null;

	public function new(char:String = 'bf', isPlayer:Bool = false)
	{
		super();
		animatedIcon = false;
		changeIcon(char, isPlayer);
	}

	public function changeIcon(char:String = 'bf', isPlayer:Bool = false)
	{
		var icon:String = '';
		if (FileSystem.exists(Paths.getPath('images/icons/$char/$char.json', TEXT)))
		{
			animatedIcon = true;
			icon = '$char/$char';
		}
		else
		{
			if(FileSystem.exists(Paths.getPath('images/icons/$char.png', IMAGE)))
			{
				icon = '$char';
			}
			else
			{
				icon = 'face';
				trace('$char icon not found, using face instead');
			}
		}

		antialiasing = true;
		initialWidth = width;
		initialHeight = height;

		if(animatedIcon)
		{
			iconData = haxe.Json.parse(openfl.Assets.getText(Paths.getPath('images/icons/$icon.json', TEXT)));
			frames = Paths.getSparrowAtlas('icons/$icon');
			flipX = iconData.flipX;
			for(anim in iconData.anims)
			{
				animation.addByPrefix(anim.animation_name, anim.animation_prefix, anim.fps);
				addOffset(anim.animation_name, anim.offsets[0], anim.offsets[1]);
			}
			playAnim("idle");
		}
		else
		{
			var iconGraphic:FlxGraphic = Paths.image('icons/$icon');
			loadGraphic(iconGraphic, true, Std.int(iconGraphic.width / 2), iconGraphic.height);
			animation.add('icon', [0, 1], 0, false, isPlayer);
			animation.play('icon');
		}

		scrollFactor.set();
	}

	public function repositionIcon()
	{
		if(iconData != null)
		{
			x += iconData.offsets[0];
			y += iconData.offsets[1];
		}
	}

	public function updateIcon(health:Float)
	{
		if (!animatedIcon)
		{
			if (health < 20)
				animation.curAnim.curFrame = 1;
			else
				animation.curAnim.curFrame = 0;
		}
		else
		{
			playAnim(health < 20 ? "loss" : "idle", true);
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (sprTracker != null)
			setPosition(sprTracker.x + sprTracker.width + 10, sprTracker.y - 30);
	}
}
