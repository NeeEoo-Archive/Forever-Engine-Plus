package gameObjects.userInterface;

import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import flixel.util.FlxStringUtil;
import meta.CoolUtil;
import meta.data.Conductor;
import meta.data.Timings;
import state.PlayState;

using StringTools;

class ClassHUD extends FlxTypedGroup<FlxBasic>
{
	// set up variables and stuff here
	public var scoreBar:FlxText;
	public var centerMark:FlxText; // song display name and difficulty at the center
	public var cornerMark:FlxText; // engine mark at the upper right corner
	public var autoplayMark:FlxText; // autoplay indicator at the center
	public var healthBarBG:FlxSprite;
	public var healthBar:FlxBar;
	public var timeBarBG:FlxSprite;
	public var timeBar:FlxBar;
	public var iconP1:HealthIcon;
	public var iconP2:HealthIcon;

	// some variables
	public var autoplaySine:Float = 0;
	var scoreDisplay:String = 'beep bop bo skdkdkdbebedeoop brrapadop'; // fnf mods
	var centerMarkText:String;

	var songPercent:Float = 0;
	var curTime:Float = 0;
	var daTime:Float = 0;

	private var SONG = PlayState.SONG;
	private var scoreBarTween:FlxTween;

	private var timingsMap:Map<String, FlxText> = [];

	var infoDisplay:String = CoolUtil.dashToSpace(PlayState.SONG.song);
	var diffDisplay:String = CoolUtil.customDifficulties[PlayState.storyDifficulty];
	var engineDisplay:String = "FOREVER ENGINE PLUS v" + Main.engineVersion;

	public function new()
	{
		// call the initializations and stuffs
		super();
		centerMarkText = '- ${infoDisplay + " [" + diffDisplay}] -';

		// le healthbar setup
		var barY = FlxG.height * 0.875;
		if (Init.trueSettings.get('Downscroll'))
			barY = 64;

		healthBarBG = new FlxSprite(0,
			barY).loadGraphic(Paths.image(ForeverTools.returnSkinAsset('UI', PlayState.assetModifier, 'healthBar')));
		healthBarBG.screenCenter(X);
		healthBarBG.scrollFactor.set();
		add(healthBarBG);

		healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8));
		healthBar.scrollFactor.set();
		healthBar.createFilledBar(PlayState.dadOpponent.characterData.healthbarColor, PlayState.boyfriend.characterData.healthbarColor);
		// healthBar
		add(healthBar);

		iconP1 = new HealthIcon(PlayState.boyfriend.characterData.healthIcon, true);
		iconP1.y = healthBar.y - (iconP1.height / 2);
		iconP1.repositionIcon();
		add(iconP1);

		iconP2 = new HealthIcon(PlayState.dadOpponent.characterData.healthIcon, false);
		iconP2.y = healthBar.y - (iconP2.height / 2);
		iconP2.repositionIcon();
		add(iconP2);

		scoreBar = new FlxText(FlxG.width / 2, Math.floor(healthBarBG.y + 40), 0, scoreDisplay);
		scoreBar.setFormat(Paths.font('vcr.ttf'), 18, FlxColor.WHITE);
		scoreBar.setBorderStyle(OUTLINE, FlxColor.BLACK, 1.5);
		updateScoreText();
		// scoreBar.scrollFactor.set();
		scoreBar.antialiasing = true;
		add(scoreBar);

		cornerMark = new FlxText(0, 0, 0, engineDisplay);
		cornerMark.setFormat(Paths.font('vcr.ttf'), 18, FlxColor.WHITE);
		cornerMark.setBorderStyle(OUTLINE, FlxColor.BLACK, 2);
		cornerMark.setPosition(FlxG.width - (cornerMark.width + 5), 5);
		cornerMark.antialiasing = true;

		centerMark = new FlxText(0, (Init.trueSettings.get('Downscroll') ? FlxG.height - 40 : 10), 0, '00:00 $centerMarkText 00:00');
		centerMark.setFormat(Paths.font('vcr.ttf'), 24, FlxColor.WHITE);
		centerMark.setBorderStyle(OUTLINE, FlxColor.BLACK, 2);
		centerMark.screenCenter(X);
		centerMark.antialiasing = true;
		centerMark.alpha = 0;
		centerMark.visible = Init.trueSettings.get('Show Timebar');

		timeBarBG = new FlxSprite(0, centerMark.y + (centerMark.height / 4)).loadGraphic(Paths.image('UI/base/timeBar'));
		timeBarBG.setGraphicSize(Std.int(centerMark.width));
		timeBarBG.updateHitbox();
		timeBarBG.screenCenter(X);
		timeBarBG.scrollFactor.set();
		timeBarBG.color = FlxColor.BLACK;
		timeBarBG.alpha = 0;
		timeBarBG.visible = Init.trueSettings.get('Show Timebar');
		add(timeBarBG);
		
		timeBar = new FlxBar(timeBarBG.x + 4, timeBarBG.y + 4, LEFT_TO_RIGHT, Std.int(timeBarBG.width - 8), Std.int(timeBarBG.height - 8), this,
			'daTime', 0, PlayState.songMusic.length);
		timeBar.scrollFactor.set();
		timeBar.createFilledBar(FlxColor.BLACK, PlayState.dadOpponent.characterData.healthbarColor);
		timeBar.numDivisions = 400;
		timeBar.alpha = 0;
		timeBar.visible = Init.trueSettings.get('Show Timebar');
		add(timeBar);
		add(centerMark);
		add(cornerMark);

		// counter
		if (Init.trueSettings.get('Counter') != 'None')
		{
			var judgementNameArray:Array<String> = [];
			for (i in Timings.judgementsMap.keys())
				judgementNameArray.insert(Timings.judgementsMap.get(i)[0], i);
			judgementNameArray.sort(sortByShit);
			for (i in 0...judgementNameArray.length)
			{
				var textAsset:FlxText = new FlxText(5
					+ (!left ? (FlxG.width - 10) : 0),
					(FlxG.height / 2)
					- (counterTextSize * (judgementNameArray.length / 2))
					+ (i * counterTextSize), 0, '', counterTextSize);
				if (!left)
					textAsset.x -= textAsset.text.length * counterTextSize;
				textAsset.setFormat(Paths.font("vcr.ttf"), counterTextSize, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
				textAsset.scrollFactor.set();
				timingsMap.set(judgementNameArray[i], textAsset);
				add(textAsset);
			}
		}
		updateScoreText();

		autoplayMark = new FlxText(-5, (Init.trueSettings.get('Downscroll') ? centerMark.y - 60 : centerMark.y + 60), FlxG.width - 800, '[AUTOPLAY]\n', 32);
		autoplayMark.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER);
		autoplayMark.setBorderStyle(OUTLINE, FlxColor.BLACK, 2);
		autoplayMark.screenCenter(X);
		autoplayMark.visible = PlayState.boyfriendStrums.autoplay;

		// repositioning for it to not be covered by the receptors
		if (Init.trueSettings.get('Centered Notefield'))
		{
			if (Init.trueSettings.get('Downscroll'))
				autoplayMark.y = autoplayMark.y - 125;
			else
				autoplayMark.y = autoplayMark.y + 125;
		}

		add(autoplayMark);
	}

	var counterTextSize:Int = 18;

	function sortByShit(Obj1:String, Obj2:String):Int
		return FlxSort.byValues(FlxSort.ASCENDING, Timings.judgementsMap.get(Obj1)[0], Timings.judgementsMap.get(Obj2)[0]);

	var left = (Init.trueSettings.get('Counter') == 'Left');

	override public function update(elapsed:Float)
	{
		healthBar.percent = (PlayState.health * 50);

		for (icon in [iconP1, iconP2])
		{
			var iconLerp = 1 - Main.framerateAdjust(0.15);

			if(Init.trueSettings.get('Psych Icon Bops'))
				icon.scale.set(FlxMath.lerp(icon.scale.x, 1, Main.framerateAdjust(0.15)), FlxMath.lerp(icon.scale.y, 1, Main.framerateAdjust(0.15)));
			else
			{
				icon.scale.set(FlxMath.lerp(1, icon.scale.x, iconLerp), FlxMath.lerp(1, icon.scale.y, iconLerp));
				icon.updateHitbox();
			}
		}

		var iconOffset:Int = 26;
		iconP1.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01) - iconOffset);
		iconP2.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - (iconP2.width - iconOffset);

		iconP1.updateIcon(healthBar.percent);
		iconP2.updateIcon(100 - healthBar.percent);

		if (autoplayMark.visible)
		{
			autoplaySine += 180 * (elapsed / 4);
			autoplayMark.alpha = 1 - Math.sin((Math.PI * autoplaySine) / 80);
		}

		timeBar.update(elapsed);
	}

	public function updateTimebar()
	{
		var curTime = Conductor.songPosition - Init.trueSettings.get('Offset');
		if(curTime < 0) curTime = 0;
		songPercent = (curTime / PlayState.songLength);

		var songCalc:Float = (PlayState.songLength - curTime);
		songCalc = curTime;

		var secondsTotal:Int = Math.floor(songCalc / 1000);
		if(secondsTotal < 0) secondsTotal = 0;

		daTime = PlayState.songMusic.time;

		centerMark.text = FlxStringUtil.formatTime(secondsTotal, false)
			+ ' '
			+ centerMarkText
			+ ' '
			+ FlxStringUtil.formatTime(Math.floor(PlayState.songMusic.length / 1000));
		centerMark.screenCenter(X);
	}

	private final divider:String = " • ";

	public function updateScoreText()
	{
		var importSongScore = PlayState.songScore;
		var comboDisplay:String = (Timings.comboDisplay != null && Timings.comboDisplay != '' ? ' [${Timings.comboDisplay}]' : '');

		scoreBar.text = 'Score: $importSongScore';
		// testing purposes
		var displayAccuracy:Bool = Init.trueSettings.get('Display Accuracy');
		if (displayAccuracy)
		{
			scoreBar.text += divider + 'Accuracy: ' + Std.string(Math.floor(Timings.getAccuracy() * 100) / 100) + '%' + comboDisplay;
			scoreBar.text += divider + 'Combo Breaks: ' + Std.string(PlayState.misses);
			scoreBar.text += divider + 'Rank: ' + Std.string(Timings.returnScoreRating().toUpperCase());
		}
		scoreBar.text += '\n';
		scoreBar.x = Math.floor((FlxG.width / 2) - (scoreBar.width / 2));

		// update counter
		if (Init.trueSettings.get('Counter') != 'None')
		{
			for (i in timingsMap.keys())
			{
				timingsMap[i].text = '${(i.charAt(0).toUpperCase() + i.substring(1, i.length))}: ${Timings.gottenJudgements.get(i)}';
				timingsMap[i].x = (5 + (!left ? (FlxG.width - 10) : 0) - (!left ? (6 * counterTextSize) : 0));
			}
		}

		// update playstate
		PlayState.detailsSub = scoreBar.text;
		PlayState.updateRPC(false);
	}

	public function scoreBarZoom()
	{
		if(Init.trueSettings.get("Score Bar Zoom On Hit"))
		{
			if(scoreBarTween != null)
				scoreBarTween.cancel();

			scoreBar.scale.x = 1.075;
			scoreBar.scale.y = 1.075;

			scoreBarTween = FlxTween.tween(scoreBar.scale, {x: 1, y: 1}, 0.2, {onComplete: function(_) {
				scoreBarTween = null;
			}});
		}
	}

	public function beatHit()
	{
		if (!Init.trueSettings.get('Reduced Movements'))
		{
			for (icon in [iconP1, iconP2])
			{
				if(Init.trueSettings.get('Psych Icon Bops'))
					icon.scale.set(1.2, 1.2);
				else
				{
					icon.setGraphicSize(Std.int(icon.width + 30));
					icon.updateHitbox();
				}
			}
		}
	}
}
