package state.editors;

import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxG;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.addons.display.FlxGridOverlay;
import flixel.graphics.FlxGraphic;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxSave;
import flixel.util.FlxTimer;
import haxe.Json;
import lime.utils.Assets;
import meta.data.font.Alphabet;

using StringTools;


class EditorSelectorState extends meta.MusicBeat.MusicBeatState
{
	var options:Array<String> = ["Modchart Editor", "Character Offset Editor", "Chart Editor"];
	private var grpOptions:FlxTypedGroup<Alphabet>;
	private static var curSelected:Int = 0;
	private var menuBG:FlxSprite;

	override function create()
	{
		super.create();
        
		#if desktop
		meta.data.dependency.Discord.changePresence("Editor Selector");
        #end

		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menus/base/menuBG'));
		bg.color = 0xFFea71fd;
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = !Init.trueSettings.get('Disable Antialiasing');
		add(bg);

		grpOptions = new FlxTypedGroup<Alphabet>();
		add(grpOptions);

		for (i in 0...options.length)
		{
			var optionText:Alphabet = new Alphabet(0, 0, options[i], true);
			optionText.screenCenter();
			optionText.y += (100 * (i - (options.length / 2))) + 50;
			grpOptions.add(optionText);
		}

		changeSelection();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (controls.UI_UP_P)
		{
			changeSelection(-1);
		}
		if (controls.UI_DOWN_P)
		{
			changeSelection(1);
		}

		if (controls.BACK)
		{
			FlxG.sound.play(Paths.sound('cancelMenu'));
            Main.switchState(this, new state.menus.MainMenuState());
		}

		if (controls.ACCEPT)
		{
			switch(options[curSelected])
			{
				case "Modchart Editor":
					ForeverTools.killMusic([FlxG.sound.music]);
					Main.switchState(this, new modcharting.ModchartEditorState());
				case "Character Offset Editor":
					ForeverTools.killMusic([FlxG.sound.music]);
					Main.switchState(this, new state.editors.CharacterOffset());
				case "Chart Editor":
					ForeverTools.killMusic([FlxG.sound.music]);
					Main.switchState(this, new state.charting.OriginalChartingState());
			}
		}
	}

	function changeSelection(change:Int = 0)
	{
		curSelected += change;
		if (curSelected < 0)
			curSelected = options.length - 1;
		if (curSelected >= options.length)
			curSelected = 0;

		var bullShit:Int = 0;

		for (item in grpOptions.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			if (item.targetY == 0)
				item.alpha = 1;
		}
		FlxG.sound.play(Paths.sound('scrollMenu'));
	}
}