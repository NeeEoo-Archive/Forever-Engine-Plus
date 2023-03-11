package meta.data.dependency;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxTileFrames;
import flixel.math.FlxPoint;
import flixel.system.FlxAssets.FlxGraphicAsset;

/**
	Global FNF sprite utilities, all in one parent class!
	You'll be able to easily edit functions and such that are used by sprites
**/
class FNFSprite extends FlxSprite
{
	public var animOffsets:Map<String, Array<Dynamic>>;

	public function new(x:Float = 0, y:Float = 0)
	{
		super(x, y);

		animOffsets = new Map<String, Array<Dynamic>>();
	}

	/**
	 * Play an the animation `animName`.
	 * @param AnimName The animation to play.
	 * @param Force Should force the animation? (optional).
	 * @param Reversed Should reverse the animation? (optional).
	 * @param Frame Specific frame of the animation (optional).
	 */
	public function playAnim(AnimName:String, Force:Bool = false, Reversed:Bool = false, Frame:Int = 0):Void
	{
		animation.play(AnimName, Force, Reversed, Frame);

		var daOffset = animOffsets.get(AnimName);
		if (animOffsets.exists(AnimName))
		{
			offset.set(daOffset[0], daOffset[1]);
		}
		else
			offset.set(0, 0);
	}

	/**
	 * Add an offset to the animation `name`.
	 * @param name The animation
	 * @param x X value of the offset
	 * @param y Y value of the offset
	 */
	public function addOffset(name:String, x:Float = 0, y:Float = 0)
	{
		animOffsets[name] = [x, y];
	}

	/**
	 * Handy function to repair offsets if they broke by resizing `this`.
	 */
	public function resizeOffsets()
	{
		for (i in animOffsets.keys())
			animOffsets[i] = [animOffsets[i][0] * scale.x, animOffsets[i][1] * scale.y];
	}

	override public function loadGraphic(Graphic:FlxGraphicAsset, Animated:Bool = false, Width:Int = 0, Height:Int = 0, Unique:Bool = false,
			?Key:String):FNFSprite
	{
		var graph:FlxGraphic = (FlxG.bitmap.add(Graphic, Unique, Key));
		if (graph == null)
			return this;

		if (Width == 0)
		{
			Width = Animated ? graph.height : graph.width;
			Width = (Width > graph.width) ? graph.width : Width;
		}

		if (Height == 0)
		{
			Height = Animated ? Width : graph.height;
			Height = (Height > graph.height) ? graph.height : Height;
		}

		if (Animated)
			frames = FlxTileFrames.fromGraphic(graph, FlxPoint.get(Width, Height));
		else
			frames = graph.imageFrame;

		return this;
	}

	override public function destroy()
	{
		// dump cache stuffs
		if (graphic != null)
			graphic.dump();

		super.destroy();
	}
}
