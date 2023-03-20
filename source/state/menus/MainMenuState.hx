package state.menus;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import meta.MusicBeat.MusicBeatState;
import meta.data.dependency.Discord;

using StringTools;

/**
	This is the main menu state! Not a lot is going to change about it so it'll remain similar to the original, but I do want to condense some code and such.
	Get as expressive as you can with this, create your own menu!
**/
class MainMenuState extends MusicBeatState
{
	var optionShit:Array<String> = ['story mode', 'freeplay', "credits", 'options'];
	var menuItems:FlxTypedGroup<FlxSprite>;
	var curSelected:Int = 0;

	var bg:FlxSprite; // the background has been separated for more control
	var magenta:FlxSprite;
	var camFollow:FlxObject;
	var canFollow:Bool = true;

	// the create 'state'
	override function create()
	{
		super.create();

		// set the transitions to the previously set ones
		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		// make sure the music is playing
		ForeverTools.resetMenuMusic();

		#if DISCORD_RPC
		Discord.changePresence('MENU SCREEN', 'Main Menu');
		#end

		// uh
		persistentUpdate = persistentDraw = true;

		// background
		bg = new FlxSprite(-85);
		bg.loadGraphic(Paths.image('menus/base/menuBG'));
		bg.scrollFactor.x = 0;
		bg.scrollFactor.y = 0.18;
		bg.setGraphicSize(Std.int(bg.width * 1.1));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = true;
		add(bg);

		magenta = new FlxSprite(-85).loadGraphic(Paths.image('menus/base/menuDesat'));
		magenta.scrollFactor.x = 0;
		magenta.scrollFactor.y = 0.18;
		magenta.setGraphicSize(Std.int(magenta.width * 1.1));
		magenta.updateHitbox();
		magenta.screenCenter();
		magenta.visible = false;
		magenta.antialiasing = true;
		magenta.color = 0xFFfd719b;
		add(magenta);

		// add the camera
		camFollow = new FlxObject(0, 0, 1, 1);
		add(camFollow);

		// add the menu items
		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		// create the menu items themselves
		var tex = Paths.getSparrowAtlas('menus/main/FNF_main_menu_assets');

		// loop through the menu options
		for (i in 0...optionShit.length)
		{
			var menuItem:FlxSprite = new FlxSprite();
			menuItem.frames = (optionShit[i] == "credits" ? Paths.getSparrowAtlas('menus/main/menu_credits') : tex);
			// add the animations in a cool way (real)
			menuItem.animation.addByPrefix('idle', optionShit[i] + " basic", 24);
			menuItem.animation.addByPrefix('selected', optionShit[i] + " white", 24);
			menuItem.animation.play('idle');
			menuItem.ID = i;
			menuItem.screenCenter(X);
			menuItems.add(menuItem);
			menuItem.scrollFactor.set();
			menuItem.antialiasing = true;
			menuItem.updateHitbox();
			menuItem.y = 8000;
			canFollow = false;
			camFollow.y += 75;
			FlxTween.tween(menuItem, {y: 15 + (i * 175)}, 0.75, {ease: FlxEase.quartOut, onComplete: function (_) {
				canFollow = canSelect = true;
				changeSelection();
			}});
		}

		// set the camera to actually follow the camera object that was created before
		var camLerp = Main.framerateAdjust(0.10);
		FlxG.camera.follow(camFollow, null, camLerp);

		// from the base game lol

		var versionShit:FlxText = new FlxText(5, FlxG.height - 18, 0, "Forever Engine Plus v" + Main.engineVersion, 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);

		//
	}

	// var colorTest:Float = 0;
	var selectedSomethin:Bool = false;
	var canSelect:Bool = false;

	override function update(elapsed:Float)
	{
		// colorTest += 0.125;
		// bg.color = FlxColor.fromHSB(colorTest, 100, 100, 0.5);

		if(!selectedSomethin)
		{
			if(canSelect)
			{
				if (controls.UI_DOWN_P)
					changeSelection(1);
				else if (controls.UI_UP_P)
					changeSelection(-1);
			}

			if (controls.ACCEPT)
			{
				//
				selectedSomethin = true;
				FlxG.sound.play(Paths.sound('confirmMenu'));

				if (Init.trueSettings.get('Flashing Lights'))
					FlxFlicker.flicker(magenta, 0.8, 0.1, false);

				menuItems.forEach(function(spr:FlxSprite)
				{
					if (curSelected != spr.ID)
					{
						FlxTween.tween(spr, {alpha: 0, x: FlxG.width * 2}, 0.4, {
							ease: FlxEase.quadOut,
							onComplete: function(twn:FlxTween)
							{
								spr.kill();
							}
						});
					}
					else
					{
						new flixel.util.FlxTimer().start(0.8, function(_)
						{
							switch (optionShit[curSelected])
							{
								case 'story mode':
									Main.switchState(this, new StoryMenuState());
								case 'freeplay':
									Main.switchState(this, new FreeplayState());
								case 'credits':
									Main.switchState(this, new state.menus.CreditsState());
								case 'options':
									transIn = FlxTransitionableState.defaultTransIn;
									transOut = FlxTransitionableState.defaultTransOut;
									Main.switchState(this, new OptionsMenuState());
							}
						});
					}
				});
			}
		}

		super.update(elapsed);

		menuItems.forEach(function(menuItem:FlxSprite)
		{
			menuItem.screenCenter(X);
		});

		if(FlxG.keys.justPressed.SEVEN && Main.debugTools) Main.switchState(this, new state.editors.EditorSelectorState());
	}

	private function changeSelection(change:Int = 0)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'));
		
		curSelected += change;
		if (curSelected < 0)
			curSelected = optionShit.length - 1;
		else if (curSelected >= optionShit.length)
			curSelected = 0;

		// reset all selections
		menuItems.forEach(function(spr:FlxSprite)
		{
			spr.animation.play('idle');
			spr.updateHitbox();
		});

		// set the sprites and all of the current selection
		var sprite = menuItems.members[curSelected];
		if(canFollow) camFollow.setPosition(sprite.getGraphicMidpoint().x, sprite.getGraphicMidpoint().y + (curSelected == 0 ? 55 : (curSelected == 3 ? -5 : 0)));

		if (sprite.animation.curAnim.name == 'idle')
			sprite.animation.play('selected');

		sprite.updateHitbox();
	}
}
