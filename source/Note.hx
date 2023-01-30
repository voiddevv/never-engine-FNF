package;

import funkin.base.NoteShader.ColoredNoteShader;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.math.FlxMath;
import flixel.util.FlxColor;

using StringTools;

class Note extends FlxSprite {
	public var strumTime:Float = 0;

	public var mustPress:Bool = false;
	public var noteData:Int = 0;
	public var canBeHit:Bool = false;
	public var tooLate:Bool = false;
	public var wasGoodHit:Bool = false;
	public var prevNote:Note;

	public var sustainLength:Float = 0;
	public var isSustainNote:Bool = false;

	public var noteScore:Float = 1;

	public static var swagWidth:Float = 160 * 0.7;
	public static var PURP_NOTE:Int = 0;
	public static var GREEN_NOTE:Int = 2;
	public static var BLUE_NOTE:Int = 1;
	public static var RED_NOTE:Int = 3;

	public function new(strumTime:Float, noteData:Int, ?prevNote:Note, ?sustainNote:Bool = false) {
		super();

		if (prevNote == null)
			prevNote = this;

		this.prevNote = prevNote;
		isSustainNote = sustainNote;

		this.strumTime = strumTime;

		this.noteData = noteData;
		var noteShader:ColoredNoteShader = new ColoredNoteShader(128, 128, 128, false);

		frames = Assets.load(SPARROW, Paths.image('ui/notes/default/note'));

		animation.addByPrefix('greenScroll', 'green0');
		animation.addByPrefix('redScroll', 'red0');
		animation.addByPrefix('blueScroll', 'blue0');
		animation.addByPrefix('purpleScroll', 'purple0');

		animation.addByPrefix('purpleholdend', 'pruple end hold');
		animation.addByPrefix('greenholdend', 'green hold end');
		animation.addByPrefix('redholdend', 'red hold end');
		animation.addByPrefix('blueholdend', 'blue hold end');

		animation.addByPrefix('purplehold', 'purple hold piece');
		animation.addByPrefix('greenhold', 'green hold piece');
		animation.addByPrefix('redhold', 'red hold piece');
		animation.addByPrefix('bluehold', 'blue hold piece');

		setGraphicSize(Std.int(width * 0.7));
		updateHitbox();
		antialiasing = true;

		switch (noteData) {
			case 0:
				noteShader.setColors(194, 75, 153);
				x += swagWidth * 0;
				animation.play('purpleScroll');
			case 1:
				noteShader.setColors(0, 255, 255);
				x += swagWidth * 1;
				animation.play('blueScroll');
			case 2:
				noteShader.setColors(18, 250, 5);
				x += swagWidth * 2;
				animation.play('greenScroll');
			case 3:
				noteShader.setColors(249, 57, 63);
				x += swagWidth * 3;
				animation.play('redScroll');
		}
		shader = noteShader;

		// trace(prevNote);

		if (isSustainNote && prevNote != null) {
			noteScore * 0.2;
			alpha = 0.6;

			x += width / 2;

			switch (noteData) {
				case 2:
					animation.play('greenholdend');
				case 3:
					animation.play('redholdend');
				case 1:
					animation.play('blueholdend');
				case 0:
					animation.play('purpleholdend');
			}

			updateHitbox();

			x -= width / 2;
			if (prevNote.isSustainNote) {
				switch (prevNote.noteData) {
					case 0:
						prevNote.animation.play('purplehold');
					case 1:
						prevNote.animation.play('bluehold');
					case 2:
						prevNote.animation.play('greenhold');
					case 3:
						prevNote.animation.play('redhold');
				}

				prevNote.scale.y *= Conductor.stepCrochet / 100 * 1.5 * PlayState.SONG.speed;
				prevNote.updateHitbox();
				// prevNote.setGraphicSize();
			}
		}
	}

	override function update(elapsed:Float) {
		if(!exists)
			return;
		super.update(elapsed);

		if (mustPress) {
			// The * 0.5 us so that its easier to hit them too late, instead of too early
			if (strumTime > Conductor.songPosition - Conductor.safeZoneOffset
				&& strumTime < Conductor.songPosition + (Conductor.safeZoneOffset * 1.5)) {
				canBeHit = true;
			} else
				canBeHit = false;

			if (strumTime < Conductor.songPosition - Conductor.safeZoneOffset)
				tooLate = true;
		} else {
			canBeHit = false;

			if (strumTime <= Conductor.songPosition) {
				wasGoodHit = true;
			}
		}

		if (tooLate) {
			if (alpha > 0.3)
				alpha = 0.3;
		}
	}
}
