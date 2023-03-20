package;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxState;
import flixel.addons.transition.FlxTransitionableState;
import haxe.CallStack;
import haxe.io.Path;
import lime.app.Application;
import meta.data.dependency.Discord;
import meta.data.dependency.FNFTransition;
import openfl.Lib;
import openfl.display.Sprite;
import openfl.events.UncaughtErrorEvent;
import sys.FileSystem;
import sys.io.File;
import sys.io.Process;

// Here we actually import the states and metadata, and just the metadata.
// It's nice to have modularity so that we don't have ALL elements loaded at the same time.
// at least that's how I think it works. I could be stupid!
class Main extends Sprite
{
	// class action variables
	public static var gameWidth:Int = 1280; // Width of the game in pixels (might be less / more in actual pixels depending on your zoom).
	public static var gameHeight:Int = 720; // Height of the game in pixels (might be less / more in actual pixels depending on your zoom).

	public static var mainClassState:Class<FlxState> = Init; // Determine the main class state of the game
	public static var framerate:Int = 120; // How many frames per second the game should run at.

	public static var engineVersion:String = '0.2.0'; // the engine version of this source
	public static var debugTools:Bool = true; // set this to false to disable the chart editor and editors

	var zoom:Float = -1; // If -1, zoom is automatically calculated to fit the window dimensions.
	var skipSplash:Bool = true; // Whether to skip the flixel splash screen that appears in release mode.

	// most of these variables are just from the base game!
	// be sure to mess around with these if you'd like.

	public static function main():Void
	{
		Lib.current.addChild(new Main());
	}

	// calls a function to set the game up
	public function new()
	{
		super();

		/**
			ok so, haxe html5 CANNOT do 120 fps. it just cannot.
			so here i just set the framerate to 60 if its complied in html5.
			reason why we dont just keep it because the game will act as if its 120 fps, and cause
			note studders and shit its weird.
		**/

		Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, onCrash);

		#if (html5 || neko)
		framerate = 60;
		#end

		// simply said, a state is like the 'surface' area of the window where everything is drawn.
		// if you've used gamemaker you'll probably understand the term surface better
		// this defines the surface bounds

		var stageWidth:Int = Lib.current.stage.stageWidth;
		var stageHeight:Int = Lib.current.stage.stageHeight;

		if (zoom == -1)
		{
			var ratioX:Float = stageWidth / gameWidth;
			var ratioY:Float = stageHeight / gameHeight;
			zoom = Math.min(ratioX, ratioY);
			gameWidth = Math.ceil(stageWidth / zoom);
			gameHeight = Math.ceil(stageHeight / zoom);
			// this just kind of sets up the camera zoom in accordance to the surface width and camera zoom.
			// if set to negative one, it is done so automatically, which is the default.
		}

		FlxTransitionableState.skipNextTransIn = true;

		// here we set up the base game
		var gameCreate:FlxGame;
		gameCreate = new FlxGame(gameWidth, gameHeight, mainClassState, #if (flixel < "5.0.0") zoom, #end framerate, framerate, skipSplash);
		addChild(gameCreate); // and create it afterwards
		addChild(new base.Overlay(8, 6)); // adding the fps overlay
		FlxG.signals.gameResized.add(onGameResized); // fixes for shader coords when resizing the window

		// begin the discord rich presence
		#if DISCORD_RPC
		Discord.initializeRPC();
		Discord.changePresence('');
		#end
	}

    function onGameResized(w:Int, h:Int)
	{
		if(FlxG.cameras == null) return;

		for(cam in FlxG.cameras.list)
		{
			@:privateAccess
			if(cam != null && (cam._filters != null || cam._filters != []))
				fixShaderSize(cam);
		}
	}

	function fixShaderSize(cam:FlxCamera)
	{
		@:privateAccess {
			var sprite:Sprite = cam.flashSprite;

			if(sprite != null)
			{
				sprite.__cacheBitmap = null;
				sprite.__cacheBitmapData = null;
				sprite.__cacheBitmapData2 = null;
				sprite.__cacheBitmapData3 = null;
				sprite.__cacheBitmapColorTransform = null;
			}
		}
	}

	public static function framerateAdjust(input:Float)
	{
		return input * (60 / FlxG.drawFramerate);
	}

	/*  This is used to switch "rooms," to put it basically. Imagine you are in the main menu, and press the freeplay button.
		That would change the game's main class to freeplay, as it is the active class at the moment.
	 */
	public static var lastState:FlxState;

	public static function switchState(curState:FlxState, target:FlxState)
	{
		// Custom made Trans in
		mainClassState = Type.getClass(target);
		if (!FlxTransitionableState.skipNextTransIn)
		{
			curState.openSubState(new FNFTransition(0.35, false));
			FNFTransition.finishCallback = function()
			{
				FlxG.switchState(target);
			};
			return trace('changed state');
		}
		FlxTransitionableState.skipNextTransIn = false;
		// load the state
		FlxG.switchState(target);
	}

	public static function updateFramerate(newFramerate:Int)
	{
		// flixel will literally throw errors at me if I dont separate the orders
		if (newFramerate > FlxG.updateFramerate)
		{
			FlxG.updateFramerate = newFramerate;
			FlxG.drawFramerate = newFramerate;
		}
		else
		{
			FlxG.drawFramerate = newFramerate;
			FlxG.updateFramerate = newFramerate;
		}
	}

	function onCrash(e:UncaughtErrorEvent):Void
	{
		var errMsg:String = "";
		var path:String;
		var callStack:Array<StackItem> = CallStack.exceptionStack(true);
		var dateNow:String = Date.now().toString();

		dateNow = StringTools.replace(dateNow, " ", "_");
		dateNow = StringTools.replace(dateNow, ":", "'");

		path = "crash/" + "FEP_" + dateNow + ".txt";

		for (stackItem in callStack)
		{
			switch (stackItem)
			{
				case FilePos(s, file, line, column):
					errMsg += file + " (line " + line + ")\n";
				default:
					Sys.println(stackItem);
			}
		}

		errMsg += "\nUncaught Error: " + e.error + "\nPlease report this to the GitHub page: https://github.com/Sword352/Forever-Engine-Plus";

		if (!FileSystem.exists("crash/"))
			FileSystem.createDirectory("crash/");

		File.saveContent(path, errMsg + "\n");

		Sys.println(errMsg);
		Sys.println("Crash dump saved in " + Path.normalize(path));

		var crashDialoguePath:String = "FEP-CrashDialog";

		#if windows
		crashDialoguePath += ".exe";
		#end

		if (FileSystem.exists(crashDialoguePath))
		{
			Sys.println("Found crash dialog: " + crashDialoguePath);
			new Process(crashDialoguePath, [path]);
		}
		else
		{
			Sys.println("No crash dialog found! Making a simple alert instead...");
			Application.current.window.alert(errMsg, "Error!");
		}

		Sys.exit(1);
	}
}
