package funkin.base.gameplay;

import openfl.media.Sound;
import lime.media.openal.AL;
import flixel.util.FlxStringUtil;
import haxe.io.Encoding;
import haxe.crypto.BaseCode;
import haxe.io.Bytes;
import haxe.crypto.Base64;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.ui.FlxBar;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import flixel.system.FlxSound;
import flixel.math.FlxMath;
import flixel.group.FlxSpriteGroup;

class HUD extends FlxSpriteGroup {
	public static var COUNT:Int = 0;

	public var notes = new FlxTypedSpriteGroup<Note>();
	public var dadStrum = new Strum();
	public var playerStrum = new Strum();

	public function new() {
		super();
		MusicBeatState.onFixedUpdate.add(fixedUpdate);
		dadStrum.screenCenter(X);
		playerStrum.screenCenter(X);
		dadStrum.x -= 350;
		playerStrum.x += 350;
		dadStrum.y = playerStrum.y = 25;
		add(dadStrum);
		add(playerStrum);
		add(notes);
		genChart();
	}

	function getNoteDiff(note:Note) {
		return Conductor.songPosition - note.strumTime;
	}

	/**spawns the notes and adds them to a array**/
	public function genChart() {
		var oldTime = Sys.cpuTime();
		var CHART = PlayState.SONG;
		for (section in CHART.notes)
			for (note in section.sectionNotes) {
				var stumtime = note[0];
				var direction = note[1];
				var suslen = note[2] / Conductor.stepCrochet;
				var sus:Bool = false;
				var hitDaNote:Bool = section.mustHitSection;
				var lastNote:Note = null;
				if (direction >= 4)
					hitDaNote = !hitDaNote;
				var theNote = new Note(stumtime, direction % 4, lastNote, false);
				theNote.mustPress = hitDaNote;
				theNote.x = dadStrum.members[theNote.noteData].x;
				if (hitDaNote)
					theNote.x = playerStrum.members[theNote.noteData].x;
				lastNote = note;
				for (sus in 0...Math.floor(suslen)) {
					lastNote = notes.members[notes.members.length - 1];
					var susNote:Note = new Note(stumtime + (Conductor.stepCrochet * sus) + 50, direction % 4, lastNote, true);
					susNote.mustPress = hitDaNote;
					lastNote = susNote;
					notes.add(susNote);
					susNote.x = dadStrum.members[theNote.noteData].x + 35;
					if (hitDaNote)
						susNote.x = playerStrum.members[theNote.noteData].x + 35;
				}
				notes.add(theNote);
			}
		var oldNote:Note = null;
		for (note in notes.members) {
			if (oldNote != null && oldNote.noteData == note.noteData && oldNote.strumTime == note.strumTime) {
				trace("stack Note");
				notes.remove(note, true);
				note.kill();
				note.destroy();
			}
			oldNote = note;
		}
		trace("parsed chart in " + Std.string(Sys.cpuTime() - oldTime));
		for (section in PlayState.SONG.notes)
			section.sectionNotes = null;
		CHART = null;
	}

	function fixedUpdate(elapsed:Float) {
		Conductor.songPosition += elapsed * 1000;
		FlxG.watch.addQuick("SongPosition", Conductor.songPosition);
		notes.forEach(function(note:Note) {
			if (Math.abs(getNoteDiff(note)) >= 1000)
				note.kill();
			else
				note.revive();
		},true);
		notes.forEachAlive(function(note:Note) {
			note.y = dadStrum.y - (Conductor.songPosition - note.strumTime) * (0.45 * FlxMath.roundDecimal(PlayState.SONG.speed, 2));
			if (note.mustPress) note.y = dadStrum.y - (Conductor.songPosition - note.strumTime) * (0.45 * FlxMath.roundDecimal(PlayState.SONG.speed, 2));
			if(!note.mustPress && getNoteDiff(note) >= 0)
				PlayState.CURRENT.dadNoteHit(note);
		},true);
	}

	public function countDown() {
		var imageMap:Map<Int, String> = [1 => "ready", 2 => "set", 3 => "go"];
		var soundMap:Map<Int, String> = [0 => "intro3", 1 => "intro2", 2 => "intro1", 3 => "introGo"];

		new FlxTimer().start(Conductor.crochet / 1000, function(timer:FlxTimer) {
			var CountDownSprite = new FNFSprite();
			if (soundMap.exists(COUNT))
				FlxG.sound.play(Paths.sound('countdown/${soundMap.get(COUNT)}'));
			if (imageMap.exists(COUNT))
				CountDownSprite.loadGraphic(Assets.load(IMAGE, Paths.image('ui/countdown/${imageMap.get(COUNT)}')));
			CountDownSprite.screenCenter();
			if (CountDownSprite.graphic != null)
				add(CountDownSprite);
			FlxTween.tween(CountDownSprite, {alpha: 0}, Conductor.crochet / 1000, {
				ease: FlxEase.cubeInOut,
				onComplete: function(tween:FlxTween) {
					CountDownSprite.kill();
					CountDownSprite.destroy();
					remove(CountDownSprite, true);
				}
			});

			COUNT++;
		}, 5);
	}
}
