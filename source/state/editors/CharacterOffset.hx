package state.editors;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.addons.ui.FlxUICheckBox;
import flixel.addons.ui.FlxUIDropDownMenu;
import flixel.math.FlxPoint;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import gameObjects.Character;
import meta.CoolUtil;
import meta.data.dependency.FNFSprite;

using Reflect;
using StringTools;

class CharacterOffset extends meta.MusicBeat.MusicBeatState
{
	var character:EditorCharacter;
	var ghostCharacter:EditorCharacter;

	var offsetText:FlxText;
	var curAnimText:FlxText;
	var controlList:FlxText;
	var isPlayerCheck:FlxUICheckBox;
	var alternate:FlxUICheckBox;

	var camGame:FlxCamera;
	var camSettings:FlxCamera;

	var curSelected:Int = 0;
	var curAnim:String = "idle";

	override public function create()
	{
		super.create();
		FlxG.mouse.visible = true;

		camGame = new FlxCamera();
		camSettings = new FlxCamera();
		FlxG.cameras.reset(camSettings);
		FlxG.cameras.add(camGame, false);
		FlxG.cameras.add(camSettings, false);
		FlxG.cameras.setDefaultDrawTarget(camGame, true);
		camGame.bgColor = 0;
		camSettings.bgColor = 0;

		var bg:FNFSprite = new FNFSprite(-600, -200).loadGraphic(Paths.image('backgrounds/stage/stageback'));
		bg.antialiasing = true;
		bg.scrollFactor.set(0.9, 0.9);
		add(bg);
		bg.cameras = [camGame];

		var stageFront:FNFSprite = new FNFSprite(-650, 600).loadGraphic(Paths.image('backgrounds/stage/stagefront'));
		stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
		stageFront.updateHitbox();
		stageFront.antialiasing = true;
		stageFront.scrollFactor.set(0.9, 0.9);
		add(stageFront);
		stageFront.cameras = [camGame];

		var stageCurtains:FNFSprite = new FNFSprite(-500, -300).loadGraphic(Paths.image('backgrounds/stage/stagecurtains'));
		stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
		stageCurtains.updateHitbox();
		stageCurtains.antialiasing = true;
		stageCurtains.scrollFactor.set(1.3, 1.3);
		add(stageCurtains);
		stageCurtains.cameras = [camGame];
		
		character = new EditorCharacter(true, 250, 620, "bf");
		character.cameras = [camGame];

		var characters:Array<String> = CoolUtil.coolTextFile(Paths.data('characterList.txt'));

		var charDropDown = new FlxUIDropDownMenu(10, 100, FlxUIDropDownMenu.makeStrIdLabelArray(characters, true), function(char:String) {
			remove(character);
			character = new EditorCharacter(true, 250, 620, characters[Std.parseInt(char)]);
			trace(character.animArray);
			add(character);
			character.cameras = [camGame];
		});
		charDropDown.cameras = [camSettings];

		curSelected = character.animArray.indexOf(curAnim);
		isPlayerCheck = new FlxUICheckBox(10, 150, null, null, "Flip X?");
		isPlayerCheck.checked = false;
		isPlayerCheck.cameras = [camSettings];
		alternate = new FlxUICheckBox(10, 175, null, null, "Precise Offset Editing");
		alternate.cameras = [camSettings];
		offsetText = new FlxText(10, 225, 0, character.animOffsets.toString(), 25);
		offsetText.cameras = [camSettings];
		curAnimText = new FlxText(10, 200, 0, "ok this is crazy", 15);
		curAnimText.cameras = [camSettings];
		controlList = new FlxText(0, 475, 0, null, 17).setFormat(Paths.font('vcr.ttf'), 15, FlxColor.WHITE, RIGHT);
		controlList.text = "Mouse to move around\nSpace to make a ghost character\nUP and DOWN to shuffle through animations\nWASD or ZQSD to change characters offsets\nSHIFT or CTRL for more precise offset editing";
		controlList.setPosition(FlxG.width - controlList.width, FlxG.height * 0.90);
		controlList.cameras = [camSettings];
		add(controlList);
		add(alternate);
		add(curAnimText);
		add(isPlayerCheck);
		add(offsetText);
		add(character);
		add(charDropDown);
	}
	
	var mouseOffset:FlxPoint = new FlxPoint();
	override public function update(elapsed)
	{
		if (FlxG.mouse.justPressed)
		{
			mouseOffset.x = FlxG.mouse.screenX - camGame.scroll.x;
			mouseOffset.y = FlxG.mouse.screenY - camGame.scroll.y;
		}

		if (FlxG.mouse.pressed)
		{
			camGame.scroll.x = FlxG.mouse.screenX - mouseOffset.x;
			camGame.scroll.y = FlxG.mouse.screenY - mouseOffset.y;
		}

		super.update(elapsed);
		if(controls.BACK) Main.switchState(this, new state.menus.MainMenuState());

		curAnimText.text = "Current Animation: " + curAnim;
		offsetText.text = character.animOffsets.toString().replace("],", "\n").replace("[", "").replace("]", "").replace("=>", ":");
		camGame.zoom += (FlxG.mouse.wheel / 20);
		character.flipX = isPlayerCheck.checked;
		character.isPlayer = true;

		if (FlxG.keys.justPressed.SPACE)
		{
			remove(ghostCharacter);
			ghostCharacter = new EditorCharacter(true, 250, 620, character.curCharacter);
			ghostCharacter.playAnim(curAnim);
			add(ghostCharacter);
			ghostCharacter.cameras = [camGame];
			add(character);
			ghostCharacter.alpha = 0.5;
		}

		if (FlxG.keys.justPressed.UP) changeAnim(-1);
		if (FlxG.keys.justPressed.DOWN) changeAnim(1);
		if (!alternate.checked)
		{
			if (FlxG.keys.pressed.A || FlxG.keys.justPressed.Q) {character.animOffsets[curAnim][0] += (FlxG.keys.pressed.SHIFT ? 10 : (FlxG.keys.pressed.CONTROL ? 0.25 : 1));character.playAnim(curAnim, true);}
			if (FlxG.keys.pressed.D) {character.animOffsets[curAnim][0] -= (FlxG.keys.pressed.SHIFT ? 10 : (FlxG.keys.pressed.CONTROL ? 0.25 : 1));character.playAnim(curAnim, true);}
			if (FlxG.keys.pressed.W || FlxG.keys.pressed.Z) {character.animOffsets[curAnim][1] += (FlxG.keys.pressed.SHIFT ? 10 : (FlxG.keys.pressed.CONTROL ? 0.25 : 1));character.playAnim(curAnim, true);}
			if (FlxG.keys.pressed.S) {character.animOffsets[curAnim][1] -= (FlxG.keys.pressed.SHIFT ? 10 : (FlxG.keys.pressed.CONTROL ? 0.25 : 1));character.playAnim(curAnim, true);}
		}
		else
		{
			if (FlxG.keys.justPressed.A || FlxG.keys.justPressed.Q) {character.animOffsets[curAnim][0] += (FlxG.keys.pressed.SHIFT ? 10 : (FlxG.keys.pressed.CONTROL ? 0.25 : 1));character.playAnim(curAnim, true);}
			if (FlxG.keys.justPressed.D) {character.animOffsets[curAnim][0] -= (FlxG.keys.pressed.SHIFT ? 10 : (FlxG.keys.pressed.CONTROL ? 0.25 : 1));character.playAnim(curAnim, true);}
			if (FlxG.keys.justPressed.W || FlxG.keys.pressed.Z) {character.animOffsets[curAnim][1] += (FlxG.keys.pressed.SHIFT ? 10 : (FlxG.keys.pressed.CONTROL ? 0.25 : 1));character.playAnim(curAnim, true);}
			if (FlxG.keys.justPressed.S) {character.animOffsets[curAnim][1] -= (FlxG.keys.pressed.SHIFT ? 10 : (FlxG.keys.pressed.CONTROL ? 0.25 : 1));character.playAnim(curAnim, true);}
		}
	}

	function changeAnim(e:Int)
	{
		curSelected += e;
		if (curSelected < 0)
			curSelected = character.animArray.length - 1;
		if (curSelected > character.animArray.length - 1)
			curSelected = 0;
		curAnim = character.animArray[curSelected];
		character.playAnim(curAnim, true);
	}
}

class EditorCharacter extends Character
{
	public var animArray:Array<String>;

	public function new(isPlayer:Bool, x:Float, y:Float, char:String)
	{
		super(isPlayer);
		animArray = [];
		setCharacter(x, y, char);
		
		if(animOffsets['idle'] == null)
		{
			addOffset("idle");
			addOffset("singLEFT");
			addOffset("singDOWN");
			addOffset("singUP");
			addOffset("singRIGHT");
		}
	}
		
	override function addOffset(name:String, x:Float = 0, y:Float = 0)
	{
		super.addOffset(name, x, y);
		animArray.push(name);
	}
}