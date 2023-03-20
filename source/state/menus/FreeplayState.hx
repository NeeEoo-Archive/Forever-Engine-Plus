package state.menus;

import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.tweens.misc.ColorTween;
import flixel.util.FlxColor;
import gameObjects.userInterface.HealthIcon;
import lime.utils.Assets;
import meta.CoolUtil.CoolUtil;
import meta.CoolUtil.WeekFile;
import meta.MusicBeat.MusicBeatState;
import meta.data.*;
import meta.data.Song.SwagSong;
import meta.data.dependency.Discord;
import meta.data.font.Alphabet;
import openfl.media.Sound;
import sys.FileSystem;
import sys.thread.Mutex;
import sys.thread.Thread;

using StringTools;

class FreeplayState extends MusicBeatState
{
	var songs:Array<SongMetadata> = [];
	var curSelected:Int = 0;
	var curWeek:Int = 0;
	var curSongPlaying:Int = -1;
	var curDifficulty:Int = 1;

	var scoreText:FlxText;
	var diffText:FlxText;
	var lerpScore:Int = 0;
	var intendedScore:Int = 0;

	var songThread:Thread;
	var threadActive:Bool = true;
	var mutex:Mutex;
	var songToPlay:Sound = null;
	var vocalsToPlay:Sound = null;
	var daVocals:FlxSound;

	private var grpSongs:FlxTypedGroup<Alphabet>;
	private var curPlaying:Bool = false;

	private var iconArray:Array<HealthIcon> = [];

	private var mainColor = FlxColor.WHITE;
	private var bg:FlxSprite;
	private var scoreBG:FlxSprite;

	private var songsList:Array<meta.CoolUtil.WeekFile>;
	private var existingDifficulties:Array<Array<String>> = [];

	override function create()
	{
		super.create();

		mutex = new Mutex();

		// reloading weeks
		CoolUtil.loadWeeks(); 
		
		// and adding the songs that are not hidden in freeplay
		songsList = [];
		for(week in CoolUtil.weeks)
		{
			if(!week.hide_from_freeplay) songsList.push(week);
		}

		for(i in 0...songsList.length)
		{
			for(j in 0...songsList[i].songs.length)
			{
				addSong(songsList[i], songsList[i].songs[j], i, songsList[i].icons[j], songsList[i].colors[j]);
			}
		}

		#if DISCORD_RPC
		Discord.changePresence('FREEPLAY MENU', 'Main Menu');
		#end

		bg = new FlxSprite().loadGraphic(Paths.image('menus/base/menuDesat'));
		add(bg);

		grpSongs = new FlxTypedGroup<Alphabet>();
		add(grpSongs);

		for (i in 0...songs.length)
		{
			var songText:Alphabet = new Alphabet(0, (70 * i) + 30, songs[i].songName, true, false);
			songText.isMenuItem = true;
			songText.targetY = i;
			grpSongs.add(songText);

			var icon:HealthIcon = new HealthIcon(songs[i].songCharacter);
			icon.sprTracker = songText;
			icon.repositionIcon();

			// using a FlxGroup is too much fuss!
			iconArray.push(icon);
			add(icon);

			// songText.x += 40;
			// DONT PUT X IN THE FIRST PARAMETER OF new ALPHABET() !!
			// songText.screenCenter(X);
		}

		scoreText = new FlxText(FlxG.width * 0.7, 5, 0, "", 32);
		scoreText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, RIGHT);

		scoreBG = new FlxSprite(scoreText.x - scoreText.width, 0).makeGraphic(Std.int(FlxG.width * 0.35), 66, 0xFF000000);
		scoreBG.alpha = 0.6;
		add(scoreBG);

		diffText = new FlxText(scoreText.x, scoreText.y + 36, 0, "", 24);
		diffText.alignment = CENTER;
		diffText.font = scoreText.font;
		diffText.x = scoreBG.getGraphicMidpoint().x;
		add(diffText);

		add(scoreText);

		daVocals = new FlxSound();
		daVocals.persist = true;
		
		FlxG.signals.focusLost.add(daVocals.pause); // vocals playing on auto-pause fix
		FlxG.signals.focusGained.add(restartVocals);

		var vocalsText = new FlxText(0, 475, 0, null, 17).setFormat(Paths.font('vcr.ttf'), 15, FlxColor.WHITE, RIGHT);
		vocalsText.text = "Press P to play the voices.";
		vocalsText.setPosition(FlxG.width - vocalsText.width, FlxG.height - 15);

		var overlayThing = new FlxSprite(vocalsText.x, vocalsText.y).makeGraphic(Std.int(vocalsText.width), 15, FlxColor.BLACK);
		overlayThing.alpha = 0.4;
		add(overlayThing);
		add(vocalsText);

		changeSelection();
		changeDiff();
	}

	public function addSong(weekData:meta.CoolUtil.WeekFile, songName:String, weekNum:Int, songCharacter:String, songColor:Array<Int>)
	{
		var coolDifficultyArray = [];
		for (i in weekData.difficulties)
			if (FileSystem.exists(Paths.songJson(songName, songName + '-' + CoolUtil.spaceToDash(i)))
				|| (FileSystem.exists(Paths.songJson(songName, songName)) && i == "NORMAL"))
				coolDifficultyArray.push(i);

		if (coolDifficultyArray.length > 0)
		{ //*/
			songs.push(new SongMetadata(songName, weekNum, songCharacter, FlxColor.fromRGB(songColor[0], songColor[1], songColor[2])));
			existingDifficulties.push(coolDifficultyArray);
		}
	}

	var playVocals:Bool = false;
	override function update(elapsed:Float)
	{
		super.update(elapsed);
		//Conductor.songPosition = FlxG.sound.music.time; // this doesnt work well, i may have to check that again
		Conductor.songPosition += elapsed * 1000;

		bg.scale.x = FlxMath.lerp(bg.scale.x, 1.0, elapsed * 6);
		bg.scale.y = FlxMath.lerp(bg.scale.y, 1.0, elapsed * 6);
		
		var lerpVal = Main.framerateAdjust(0.1);
		lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, lerpVal));

		if (Math.abs(lerpScore - intendedScore) <= 10)
			lerpScore = intendedScore;

		for (icon in iconArray)
		{
			icon.scale.set(FlxMath.lerp(icon.scale.x, 1, Main.framerateAdjust(0.15)), FlxMath.lerp(icon.scale.y, 1, Main.framerateAdjust(0.15)));
		}

		var upP = controls.UI_UP_P;
		var downP = controls.UI_DOWN_P;
		var accepted = controls.ACCEPT;

		if (upP)
			changeSelection(-1);
		else if (downP)
			changeSelection(1);

		if (controls.UI_LEFT_P)
			changeDiff(-1);
		if (controls.UI_RIGHT_P)
			changeDiff(1);

		if (controls.BACK)
		{
			threadActive = false;
			Main.switchState(this, new MainMenuState());
		}

		if (accepted)
		{
			for (x in 0...grpSongs.length)
			{
				if (x == curSelected)
				{
					var selectSong = function()
					{
						FlxG.signals.focusLost.remove(daVocals.pause);
						FlxG.signals.focusGained.remove(restartVocals);
						daVocals.destroy();
						
						// selecting the song
						var daDiff:String = existingDifficulties[curSelected][curDifficulty];
						var poop:String = CoolUtil.spaceToDash('${songs[curSelected].songName.toLowerCase()}' + (daDiff == "NORMAL" ? "" : '-$daDiff'));
						PlayState.SONG = Song.loadFromJson(poop, songs[curSelected].songName.toLowerCase());
						PlayState.isStoryMode = false;
						PlayState.storyDifficulty = curDifficulty;
						CoolUtil.customDifficulties = existingDifficulties[curSelected];
						PlayState.storyWeek = songs[curSelected].week;

						if (FlxG.sound.music != null)
							FlxG.sound.music.stop();

						threadActive = false;
						
						Main.switchState(this, new PlayState());
					}
					
					if(!Init.trueSettings.get('Reduced Movements'))
					{
						FlxG.sound.play(Paths.sound("confirmMenu"));
						flixel.effects.FlxFlicker.flicker(grpSongs.members[x], 1, 0.06, false, false, function(flick:flixel.effects.FlxFlicker)
						{
							selectSong();
						});
					}
					else selectSong();
				}
				else
				{
					if(!Init.trueSettings.get('Reduced Movements'))
					{
						FlxTween.tween(grpSongs.members[x], {x: grpSongs.members[x].x - 400}, 0.4, {ease: FlxEase.backIn});
						for (object in [grpSongs.members[x], iconArray[x]])
							FlxTween.tween(object, {alpha: 0}, 0.4, {ease: FlxEase.quadIn});
					}
				}
			}
		}

		if(FlxG.keys.justPressed.P)
		{
			playVocals = !playVocals;
			daVocals.volume = playVocals ? 1 : 0;
		}

		// Adhere the position of all the things (I'm sorry it was just so ugly before I had to fix it Shubs)
		scoreText.text = "PERSONAL BEST:" + lerpScore;
		scoreText.x = FlxG.width - scoreText.width - 5;
		scoreBG.width = scoreText.width + 8;
		scoreBG.x = FlxG.width - scoreBG.width;
		diffText.x = scoreBG.x + (scoreBG.width / 2) - (diffText.width / 2);

		mutex.acquire();
		if (songToPlay != null)
		{
			FlxG.sound.playMusic(songToPlay);

			if (FlxG.sound.music.fadeTween != null)
				FlxG.sound.music.fadeTween.cancel();

			FlxG.sound.music.volume = 0.0;
			FlxG.sound.music.fadeIn(1.0, 0.0, 1.0);

			songToPlay = null;
		}
		if(vocalsToPlay != null)
		{
			daVocals.loadEmbedded(vocalsToPlay);

			if(daVocals.fadeTween != null)
				daVocals.fadeTween.cancel();
			daVocals.volume = 0.0;
			daVocals.play();
			if(playVocals) daVocals.fadeIn(1.0, 0.0, 1.0);

			vocalsToPlay = null;
		}
		mutex.release();
	}

	var canBeat:Bool = true;
	override function beatHit()
	{
		if(canBeat)
		{
			super.beatHit();

			if (!Init.trueSettings.get('Reduced Movements'))
			{
				iconArray[curSelected].scale.set(1.2, 1.2);
				bg.scale.x = bg.scale.y = 1.015;
			}
		}
	}

	var lastDifficulty:String;

	function changeDiff(change:Int = 0)
	{
		curDifficulty += change;
		if (lastDifficulty != null && change != 0)
			while (existingDifficulties[curSelected][curDifficulty] == lastDifficulty)
				curDifficulty += change;

		if (curDifficulty < 0)
			curDifficulty = existingDifficulties[curSelected].length - 1;
		if (curDifficulty > existingDifficulties[curSelected].length - 1)
			curDifficulty = 0;

		intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);

		diffText.text = '< ' + existingDifficulties[curSelected][curDifficulty] + ' >';
		lastDifficulty = existingDifficulties[curSelected][curDifficulty];
	}

	function changeSelection(change:Int = 0)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		curSelected += change;

		if (curSelected < 0)
			curSelected = songs.length - 1;
		if (curSelected >= songs.length)
			curSelected = 0;

		intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);

		// set up color stuffs
		mainColor = songs[curSelected].songColor;

		// song switching stuffs

		var bullShit:Int = 0;

		for (i in 0...iconArray.length)
		{
			iconArray[i].alpha = 0.6;
		}

		iconArray[curSelected].alpha = 1;

		for (item in grpSongs.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			// item.setGraphicSize(Std.int(item.width * 0.8));

			if (item.targetY == 0)
			{
				item.alpha = 1;
				// item.setGraphicSize(Std.int(item.width));
			}
		}

		FlxTween.cancelTweensOf(bg);
		FlxTween.color(bg, 0.35, bg.color, mainColor);
		
		changeDiff();
		changeSongPlaying();
	}

	function changeSongPlaying()
	{
		canBeat = false;
		if (songThread == null)
		{
			songThread = Thread.create(function()
			{
				while (true)
				{
					if (!threadActive)
					{
						trace("Killing thread");
						return;
					}

					var index:Null<Int> = Thread.readMessage(false);
					if (index != null)
					{
						if (index == curSelected && index != curSongPlaying)
						{
							trace("Loading index " + index);

							var inst:Sound = Paths.inst(songs[curSelected].songName);
							var vocals:Sound = Paths.voices(songs[curSelected].songName);

							if (index == curSelected && threadActive)
							{
								mutex.acquire();
								songToPlay = inst;
								vocalsToPlay = vocals;
								mutex.release();

								curSongPlaying = curSelected;
							}
							else
								trace("Nevermind, skipping " + index);
						}
						else
							trace("Skipping " + index);
					}
				}
			});
		}

		songThread.sendMessage(curSelected);

		var daSong = CoolUtil.spaceToDash(songs[curSelected].songName.toLowerCase());
		Conductor.changeBPM(meta.data.Song.loadFromJson('$daSong-${existingDifficulties[curSelected][0]}', daSong).bpm);
		canBeat = true;
	}

	function restartVocals()
	{
		daVocals.play(); // ironic ig
	}
}

class SongMetadata
{
	public var songName:String = "";
	public var week:Int = 0;
	public var songCharacter:String = "";
	public var songColor:FlxColor = FlxColor.WHITE;

	public function new(song:String, week:Int, songCharacter:String, songColor:FlxColor)
	{
		this.songName = song;
		this.week = week;
		this.songCharacter = songCharacter;
		this.songColor = songColor;
	}
}
