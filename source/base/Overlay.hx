package base;

import external.memory.Memory;
import haxe.Timer;
import openfl.events.Event;
import openfl.system.System;
import openfl.text.TextField;
import openfl.text.TextFormat;

/**
	Overlay that displays FPS and memory usage.

	Based on this tutorial:
	https://keyreal-code.github.io/haxecoder-tutorials/17_displaying_fps_and_memory_usage_using_openfl.html
**/
class Overlay extends TextField
{
	var times:Array<Float> = [];
	var memPeak:UInt = 0;

	// display info
	static var displayFps = true;
	static var displayMemory = true;
	static var displayExtra = true;

	public function new(x:Float, y:Float)
	{
		super();

		this.x = x;
		this.y = x;

		autoSize = LEFT;
		selectable = false;

		defaultTextFormat = new TextFormat(Paths.font("vcr.ttf"), 14, 0xFFFFFF);
		text = "";

		addEventListener(Event.ENTER_FRAME, update);
	}

	static final intervalArray:Array<String> = ['B', 'KB', 'MB', 'GB', 'TB'];

	public static function getInterval(num:Dynamic):String
	{
		var size:Float = num;
		var data = 0;
		while (size > 1000 && data < intervalArray.length - 1)
		{
			data++;
			size = size / 1000;
		}

		size = Math.round(size * 100) / 100;
		return size + " " + intervalArray[data];
	}

	function update(_:Event)
	{
		var now:Float = Timer.stamp();
		times.push(now);
		while (times[0] < now - 1)
			times.shift();

		var trueFPS:Float = 0;
		if (Init.trueSettings.get('Accurate Fps')) trueFPS = times.length;
		else
		{
			if (times.length > Init.trueSettings.get('Framerate Cap'))
				trueFPS = Init.trueSettings.get('Framerate Cap');
			else
				trueFPS = times.length;
		}

		var mem = System.totalMemory;
		if (mem > memPeak)
			memPeak = mem;

		var trueMemory = Init.trueSettings.get('Accurate Memory') ? getInterval(Memory.getCurrentUsage()) : getInterval(mem);
		var trueMemPeak = Init.trueSettings.get('Accurate Memory') ? getInterval(Memory.getPeakUsage()) : getInterval(memPeak);

		if (visible)
		{
			text = '' // set up the text itself
			+ (displayFps ? 'FPS: $trueFPS\n' : '') // Framerate
			+ (displayMemory ? 'Memory: $trueMemory\nMemory Peak: $trueMemPeak\n' : '') // Current and Total Memory Usage
			#if !neko + (displayExtra ? 'State: ${Main.mainClassState}' : ''); #else ; #end // Current Game State
		}
	}

	public static function updateDisplayInfo(shouldDisplayFps:Bool, shouldDisplayExtra:Bool, shouldDisplayMemory:Bool)
	{
		displayFps = shouldDisplayFps;
		displayExtra = shouldDisplayExtra;
		displayMemory = shouldDisplayMemory;
	}
}
