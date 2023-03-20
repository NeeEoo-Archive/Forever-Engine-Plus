package gameObjects.userInterface.notes;

import base.scripting.HScript;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.math.FlxMath;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import gameObjects.userInterface.notes.*;
import gameObjects.userInterface.notes.Strumline.UIStaticArrow;
import meta.*;
import meta.data.*;
import meta.data.Section.SwagSection;
import meta.data.dependency.FNFSprite;
import state.PlayState;

using StringTools;

class Note extends FNFSprite
{
	public var strumTime:Float = 0;

	public var mustPress:Bool = false;
	public var noteData:Int = 0;

	public var noteType:String = "";
	public var noteScript:HScript = null;

	public var canBeHit:Bool = false;
	public var tooLate:Bool = false;
	public var wasGoodHit:Bool = false;
	public var prevNote:Note;

	public var followAngle:Bool = true;
	//public var doNormalMiss:Bool = true;

	public var sustainLength:Float = 0;
	public var isSustainNote:Bool = false;

	// only useful for charting stuffs
	public var chartSustain:FlxSprite = null;
	public var rawNoteData:Int;

	// not set initially
	public var noteQuant:Int = -1;
	public var noteVisualOffset:Float = 0;
	public var noteSpeed:Float = 0;
	public var noteDirection:Float = 0;

	public var parentNote:Note;
	public var childrenNotes:Array<Note> = [];

	public static var swagWidth:Float = 160 * 0.7;

	// it has come to this.
	public var endHoldOffset:Float = Math.NEGATIVE_INFINITY;

	// modchart shits
	public var mesh:flixel.FlxStrip = null;
	public var z:Float = 0;

	public function new(strumTime:Float, noteData:Int, ?prevNote:Note, ?sustainNote:Bool = false)
	{
		super(x, y);

		if (prevNote == null)
			prevNote = this;

		this.prevNote = prevNote;
		isSustainNote = sustainNote;

		// oh okay I know why this exists now
		y -= 2000;

		this.strumTime = strumTime;
		this.noteData = noteData;

		// determine parent note
		if (isSustainNote && prevNote != null)
		{
			parentNote = prevNote;
			while (parentNote.parentNote != null)
				parentNote = parentNote.parentNote;
			parentNote.childrenNotes.push(this);
		}
		else if (!isSustainNote)
			parentNote = null;
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (mustPress)
		{
			if (strumTime > Conductor.songPosition - (Timings.msThreshold) && strumTime < Conductor.songPosition + (Timings.msThreshold))
				canBeHit = true;
			else
				canBeHit = false;
		}
		else // make sure the note can't be hit if it's the dad's I guess
			canBeHit = false;

		if (tooLate || (parentNote != null && parentNote.tooLate))
			alpha = 0.3;
	}

	/**
		Note creation scripts

		these are for all your custom note needs
	**/
	public static function returnDefaultNote(assetModifier, strumTime, noteData, noteType:String, ?isSustainNote:Bool = false, ?prevNote:Note = null):Note
	{
		var newNote:Note = new Note(strumTime, noteData, prevNote, isSustainNote);
		if(noteType != "")
		{
			newNote.noteScript = new HScript(Paths.data('notetypes/$noteType.hxs'));
			newNote.noteScript.set_script_object(newNote);
		    newNote.noteScript.set("PlayState", state.PlayState);
			newNote.noteScript.set("game", state.PlayState.instance);
			newNote.noteScript.set("Conductor", Conductor);
			newNote.noteScript.call("loadNote", [isSustainNote, assetModifier]);
		}
		else
		{
			// frames originally go here
			switch (assetModifier)
			{
				case 'pixel': // pixel arrows default
					if (isSustainNote)
					{
						newNote.loadGraphic(Paths.image(ForeverTools.returnNoteSkin('arrowEnds', assetModifier, Init.trueSettings.get("Note Skin"),
							'noteskins/notes')), true,
							7, 6);
						newNote.animation.add('purpleholdend', [4]);
						newNote.animation.add('greenholdend', [6]);
						newNote.animation.add('redholdend', [7]);
						newNote.animation.add('blueholdend', [5]);
						newNote.animation.add('purplehold', [0]);
						newNote.animation.add('greenhold', [2]);
						newNote.animation.add('redhold', [3]);
						newNote.animation.add('bluehold', [1]);
					}
					else
					{
						newNote.loadGraphic(Paths.image(ForeverTools.returnNoteSkin('arrows-pixels', assetModifier, Init.trueSettings.get("Note Skin"),
							'noteskins/notes')),
							true, 17, 17);
						newNote.animation.add('greenScroll', [6]);
						newNote.animation.add('redScroll', [7]);
						newNote.animation.add('blueScroll', [5]);
						newNote.animation.add('purpleScroll', [4]);
					}
					newNote.antialiasing = false;
					newNote.setGraphicSize(Std.int(newNote.width * PlayState.daPixelZoom));
					newNote.updateHitbox();
				default: // base game arrows for no reason whatsoever
					newNote.frames = Paths.getSparrowAtlas(ForeverTools.returnNoteSkin('NOTE_assets', assetModifier, Init.trueSettings.get("Note Skin"),
						'noteskins/notes'));
					newNote.animation.addByPrefix('greenScroll', 'green0');
					newNote.animation.addByPrefix('redScroll', 'red0');
					newNote.animation.addByPrefix('blueScroll', 'blue0');
					newNote.animation.addByPrefix('purpleScroll', 'purple0');
					newNote.animation.addByPrefix('purpleholdend', 'pruple end hold');
					newNote.animation.addByPrefix('greenholdend', 'green hold end');
					newNote.animation.addByPrefix('redholdend', 'red hold end');
					newNote.animation.addByPrefix('blueholdend', 'blue hold end');
					newNote.animation.addByPrefix('purplehold', 'purple hold piece');
					newNote.animation.addByPrefix('greenhold', 'green hold piece');
					newNote.animation.addByPrefix('redhold', 'red hold piece');
					newNote.animation.addByPrefix('bluehold', 'blue hold piece');
					newNote.setGraphicSize(Std.int(newNote.width * 0.7));
					newNote.updateHitbox();
					newNote.antialiasing = true;
			}
		}
		
		//

		var canPlayAnim:Bool = newNote.noteScript == null ? true : false; // to not play unexisting animations

		if (!isSustainNote && canPlayAnim)
			newNote.animation.play(UIStaticArrow.getColorFromNumber(noteData) + 'Scroll');
		// trace(prevNote);
		if (isSustainNote && prevNote != null)
		{
			newNote.noteSpeed = prevNote.noteSpeed;
			newNote.alpha = (Init.trueSettings.get('Opaque Holds')) ? 1 : 0.6;
			if(canPlayAnim) newNote.animation.play(UIStaticArrow.getColorFromNumber(noteData) + 'holdend');
			newNote.updateHitbox();
			if (prevNote.isSustainNote)
			{
				if(prevNote.noteScript == null) prevNote.animation.play(UIStaticArrow.getColorFromNumber(prevNote.noteData) + 'hold');
				prevNote.scale.y *= Conductor.stepCrochet / 100 * 1.5 * prevNote.noteSpeed;
				prevNote.updateHitbox();
				// prevNote.setGraphicSize();
			}
		}
		return newNote;
	}

	public static function returnQuantNote(assetModifier, strumTime, noteData, noteType:String, ?isSustainNote:Bool = false, ?prevNote:Note = null):Note
	{
		if(noteType != "") return returnDefaultNote(assetModifier, strumTime, noteData, noteType, isSustainNote, prevNote);

		var newNote:Note = new Note(strumTime, noteData, prevNote, isSustainNote);

		// actually determine the quant of the note
		if (newNote.noteQuant == -1)
		{
			/*
				I have to credit like 3 different people for these LOL they were a hassle
				but its gede pixl and scarlett, thank you SO MUCH for baring with me
			 */
			final quantArray:Array<Int> = [4, 8, 12, 16, 20, 24, 32, 48, 64, 192]; // different quants

			var curBPM:Float = Conductor.bpm;
			var newTime = strumTime;
			for (i in 0...Conductor.bpmChangeMap.length)
			{
				if (strumTime > Conductor.bpmChangeMap[i].songTime)
				{
					curBPM = Conductor.bpmChangeMap[i].bpm;
					newTime = strumTime - Conductor.bpmChangeMap[i].songTime;
				}
			}

			final beatTimeSeconds:Float = (60 / curBPM); // beat in seconds
			final beatTime:Float = beatTimeSeconds * 1000; // beat in milliseconds
			// assumed 4 beats per measure?
			final measureTime:Float = beatTime * 4;

			final smallestDeviation:Float = measureTime / quantArray[quantArray.length - 1];

			for (quant in 0...quantArray.length)
			{
				// please generate this ahead of time and put into array :)
				// I dont think I will im scared of those
				final quantTime = (measureTime / quantArray[quant]);
				if ((newTime #if !neko + Init.trueSettings['Offset'] #end + smallestDeviation) % quantTime < smallestDeviation * 2)
				{
					// here it is, the quant, finally!
					newNote.noteQuant = quant;
					break;
				}
			}
		}

		// note quants
		switch (assetModifier)
		{
			default:
				// inherit last quant if hold note
				if (isSustainNote && prevNote != null)
					newNote.noteQuant = prevNote.noteQuant;
				// base quant notes
				if (!isSustainNote)
				{
					// in case you're unfamiliar with these, they're ternary operators, I just dont wanna check for pixel notes using a separate statement
					var newNoteSize:Int = (assetModifier == 'pixel') ? 17 : 157;
					newNote.loadGraphic(Paths.image(ForeverTools.returnNoteSkin('NOTE_quants', assetModifier, Init.trueSettings.get("Note Skin"),
						'noteskins/notes', 'quant')),
						true, newNoteSize, newNoteSize);

					newNote.animation.add('leftScroll', [0 + (newNote.noteQuant * 4)]);
					// LOL downscroll thats so funny to me
					newNote.animation.add('downScroll', [1 + (newNote.noteQuant * 4)]);
					newNote.animation.add('upScroll', [2 + (newNote.noteQuant * 4)]);
					newNote.animation.add('rightScroll', [3 + (newNote.noteQuant * 4)]);
				}
				else
				{
					// quant holds
					newNote.loadGraphic(Paths.image(ForeverTools.returnNoteSkin('HOLD_quants', assetModifier, Init.trueSettings.get("Note Skin"),
						'noteskins/notes', 'quant')),
						true, (assetModifier == 'pixel') ? 17 : 109, (assetModifier == 'pixel') ? 6 : 52);
					newNote.animation.add('hold', [0 + (newNote.noteQuant * 4)]);
					newNote.animation.add('holdend', [1 + (newNote.noteQuant * 4)]);
					newNote.animation.add('rollhold', [2 + (newNote.noteQuant * 4)]);
					newNote.animation.add('rollend', [3 + (newNote.noteQuant * 4)]);
				}

				if (assetModifier == 'pixel')
				{
					newNote.antialiasing = false;
					newNote.setGraphicSize(Std.int(newNote.width * PlayState.daPixelZoom));
					newNote.updateHitbox();
				}
				else
				{
					newNote.setGraphicSize(Std.int(newNote.width * 0.7));
					newNote.updateHitbox();
					newNote.antialiasing = true;
				}
		}

		//
		if (!isSustainNote)
			newNote.animation.play(UIStaticArrow.getArrowFromNumber(noteData) + 'Scroll');

		// trace(prevNote);

		if (isSustainNote && prevNote != null)
		{
			newNote.noteSpeed = prevNote.noteSpeed;
			newNote.alpha = (Init.trueSettings.get('Opaque Holds')) ? 1 : 0.6;
			newNote.animation.play('holdend');
			newNote.updateHitbox();

			if (prevNote.isSustainNote)
			{
				prevNote.animation.play('hold');

				prevNote.scale.y *= Conductor.stepCrochet / 100 * (43 / 52) * 1.5 * prevNote.noteSpeed;
				prevNote.updateHitbox();
				// prevNote.setGraphicSize();
			}
		}

		return newNote;
	}
}
