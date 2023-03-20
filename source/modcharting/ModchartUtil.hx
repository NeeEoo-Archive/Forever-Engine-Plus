package modcharting;

import flixel.FlxG;
import flixel.math.FlxAngle;
import flixel.math.FlxMath;
import gameObjects.userInterface.notes.Note;
import openfl.geom.Vector3D;
import state.PlayState;

class ModchartUtil
{
	public static function getDownscroll(instance:ModchartMusicBeatState)
	{
		return Init.trueSettings.get('Downscroll');
	}

	public static function getMiddlescroll(instance:ModchartMusicBeatState)
	{
		return Init.trueSettings.get('Centered Notefield');
	}

	public static function getScrollSpeed(instance:PlayState)
	{
		return PlayState.SONG.speed;
	}

	public static function getIsPixelStage(instance:ModchartMusicBeatState)
	{
		return false;
	}

	public static function getNoteOffsetX(daNote:Note, instance:ModchartMusicBeatState)
	{
		return (daNote.isSustainNote ? 37 : 0);
	}

	static var currentFakeCrochet:Float = -1;
	static var lastBpm:Float = -1;

	public static function getFakeCrochet()
	{
		if (PlayState.SONG.bpm != lastBpm)
		{
			currentFakeCrochet = (60 / PlayState.SONG.bpm) * 1000; // only need to calculate once
			lastBpm = PlayState.SONG.bpm;
		}
		return currentFakeCrochet;
	}

	public static var zNear:Float = 0;
	public static var zFar:Float = 100;
	public static var defaultFOV:Float = 90;

	/**
		Converts a Vector3D to its in world coordinates using perspective math
	**/
	public static function calculatePerspective(pos:Vector3D, FOV:Float, offsetX:Float = 0, offsetY:Float = 0)
	{
		/* math from opengl lol
			found from this website https://ogldev.org/www/tutorial12/tutorial12.html
		 */

		// TODO: maybe try using actual matrix???

		var newz = pos.z - 1;
		var zRange = zNear - zFar;
		var tanHalfFOV = FlxMath.fastSin(FOV * 0.5) / FlxMath.fastCos(FOV * 0.5); // faster tan
		if (pos.z > 1) // if above 1000 z basically
			newz = 0; // should stop weird mirroring with high z values

		// var m00 = 1/(tanHalfFOV);
		// var m11 = 1/tanHalfFOV;
		// var m22 = (-zNear - zFar) / zRange; //isnt this just 1 lol
		// var m23 = 2 * zFar * zNear / zRange;
		// var m32 = 1;

		var xOffsetToCenter = pos.x - (FlxG.width * 0.5); // so the perspective focuses on the center of the screen
		var yOffsetToCenter = pos.y - (FlxG.height * 0.5);

		var zPerspectiveOffset = (newz + (2 * zFar * zNear / zRange));

		// xOffsetToCenter += (offsetX / (1/-zPerspectiveOffset));
		// yOffsetToCenter += (offsetY / (1/-zPerspectiveOffset));
		xOffsetToCenter += (offsetX * -zPerspectiveOffset);
		yOffsetToCenter += (offsetY * -zPerspectiveOffset);

		var xPerspective = xOffsetToCenter * (1 / tanHalfFOV);
		var yPerspective = yOffsetToCenter * tanHalfFOV;
		xPerspective /= -zPerspectiveOffset;
		yPerspective /= -zPerspectiveOffset;

		pos.x = xPerspective + (FlxG.width * 0.5); // offset it back to normal
		pos.y = yPerspective + (FlxG.height * 0.5);
		pos.z = zPerspectiveOffset;

		// pos.z -= 1;
		// pos = perspectiveMatrix.transformVector(pos);

		return pos;
	}

	/**
		Returns in-world 3D coordinates using polar angle, azimuthal angle and a radius.
		(Spherical to Cartesian)

		@param	theta Angle used along the polar axis.
		@param	phi Angle used along the azimuthal axis.
		@param	radius Distance to center.
	**/
	public static function getCartesianCoords3D(theta:Float, phi:Float, radius:Float):Vector3D
	{
		var pos:Vector3D = new Vector3D();
		var rad = FlxAngle.TO_RAD;
		pos.x = FlxMath.fastCos(theta * rad) * FlxMath.fastSin(phi * rad);
		pos.y = FlxMath.fastCos(phi * rad);
		pos.z = FlxMath.fastSin(theta * rad) * FlxMath.fastSin(phi * rad);
		pos.x *= radius;
		pos.y *= radius;
		pos.z *= radius;

		return pos;
	}
}