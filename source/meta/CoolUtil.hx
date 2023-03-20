package meta;

import lime.utils.Assets;
import state.PlayState;

using StringTools;

#if sys
import sys.FileSystem;
#end
typedef WeekFile =
{
	var songs:Array<String>;
	var icons:Array<String>;
	var colors:Array<Array<Int>>;
	var characters:Array<String>;
	var week_image:String;
	var week_bg:String;
	var difficulties:Array<String>;
	var expression:String;
	var hide_from_freeplay:Bool;
	var hide_from_story:Bool;
}

typedef PlayStateEvent =
{
	var curStep:Int;
	var event:String;
	var values:Array<String>;
}

class CoolUtil
{
	public static var difficultyArray:Array<String> = ['EASY', "NORMAL", "HARD"];
	public static var difficultyLength = difficultyArray.length;
	public static var customDifficulties:Array<String> = difficultyArray;
	public static var weeks:Array<WeekFile>;

	public static function loadWeeks()
	{
		weeks = haxe.Json.parse(openfl.Assets.getText(Paths.data('weeks.json')));

		for(i in 0...weeks.length)
		{
			if(weeks[i].difficulties == null)
				weeks[i].difficulties = difficultyArray;
		}
	}

	public static function dashToSpace(string:String):String
	{
		return string.replace("-", " ");
	}

	public static function spaceToDash(string:String):String
	{
		return string.replace(" ", "-");
	}

	public static function swapSpaceDash(string:String):String
	{
		return StringTools.contains(string, '-') ? dashToSpace(string) : spaceToDash(string);
	}

	public static function coolTextFile(path:String):Array<String>
	{
		var daList:Array<String> = Assets.getText(path).trim().split('\n');

		for (i in 0...daList.length)
		{
			daList[i] = daList[i].trim();
		}

		return daList;
	}

	public static function returnAssetsLibrary(library:String, ?subDir:String = 'assets/images'):Array<String>
	{
		var libraryArray:Array<String> = [];

		#if sys
		var unfilteredLibrary = FileSystem.readDirectory('$subDir/$library');

		for (folder in unfilteredLibrary)
		{
			if (!folder.contains('.'))
				libraryArray.push(folder);
		}
		trace(libraryArray);
		#end

		return libraryArray;
	}

	public static function numberArray(max:Int, ?min = 0):Array<Int>
	{
		var dumbArray:Array<Int> = [];
		for (i in min...max)
		{
			dumbArray.push(i);
		}
		return dumbArray;
	}

	inline public static function boundTo(value:Float, min:Float, max:Float):Float {
		return Math.max(min, Math.min(max, value));
	}

	public static function browserLoad(site:String)
	{
		#if linux
		Sys.command('/usr/bin/xdg-open', [site]);
		#else
		flixel.FlxG.openURL(site);
		#end
	}

	public static function getOffsetsFromTxt(path:String):Array<Array<String>>
	{
		var fullText:String = Assets.getText(path);

		var firstArray:Array<String> = fullText.split('\n');
		var swagOffsets:Array<Array<String>> = [];

		for (i in firstArray)
			swagOffsets.push(i.split(' '));

		return swagOffsets;
	}

	public static function addTxtOffsetsToObject(path:String, object:Dynamic)
	{
		if (openfl.Assets.exists(path))
		{
			var offsets:Array<String> = coolTextFile(path);
			for (i in 0...offsets.length)
			{
				var getterArray:Array<Array<String>> = getOffsetsFromTxt(path);
				object.addOffset(getterArray[i][0], Std.parseInt(getterArray[i][1]), Std.parseInt(getterArray[i][2]));
			}
		}
	}
}
