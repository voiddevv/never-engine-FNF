package funkin.base.gameplay;

import flixel.FlxG;
import flixel.util.FlxTimer;
import flixel.FlxSprite;
import flixel.ui.FlxBar;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.system.FlxSound;
import flixel.math.FlxMath;
import flixel.group.FlxSpriteGroup;

class HUD extends FlxSpriteGroup {
	public static var COUNT:Int = 0;

	public var notes = new FlxTypedSpriteGroup<Note>();
	public var dadStrum = new Strum();
	public var playerStrum = new Strum();
	public var ratingGroup:FlxTypedSpriteGroup<FlxSprite> = new FlxTypedSpriteGroup();

	public function new() {
		super();
		MusicBeatState.onFixedUpdate.add(fixedUpdate);
		dadStrum.screenCenter(X);
		playerStrum.screenCenter(X);
		dadStrum.x -= 350;
		playerStrum.x += 350;
		dadStrum.y = playerStrum.y = 25;
		ratingGroup.scale.set(0.5, 0.5);
		add(ratingGroup);
		add(dadStrum);
		add(playerStrum);
		add(notes);
		genChart();
		countDown();
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
		}, true);
		notes.forEachAlive(function(note:Note) {
			note.y = dadStrum.y - (Conductor.songPosition - note.strumTime) * (0.45 * FlxMath.roundDecimal(PlayState.SONG.speed, 2));
			if (note.mustPress)
				note.y = dadStrum.y - (Conductor.songPosition - note.strumTime) * (0.45 * FlxMath.roundDecimal(PlayState.SONG.speed, 2));
			if (!note.mustPress && getNoteDiff(note) >= 0)
				PlayState.CURRENT.dadNoteHit(note);
		}, true);
	}

	public var ratings:Array<Array<Dynamic>> = [[22.5, "sick"], [45, "sick"], [90, "good"], [135, "bad"]];

	public function getrating(note:Note) {
		for (i in ratings)
			if (Math.abs(getNoteDiff(note)) <= i[0]) {
				return i[1];
				break;
			}
		return "shit";
	}

	public var times:Array<Float> = [];

	public function popupScore(note:Note) {
		if (note.isSustainNote)
			return;
		var ratingName:String = getrating(note);
		var rating = new FlxSprite(0, 0);
		rating.loadGraphic(Assets.load(IMAGE, Paths.image('ui/ratings/funkin/$ratingName')));
		trace(ratingName);
		times.push(Math.abs(getNoteDiff(note)));
		var sum:Float = 0;
		for (i in times) {
			sum += i;
			var avg:Float = 0;
			avg = sum / times.length;
			FlxG.watch.addQuick("avg hitime", avg);
		}
		PlayState.CURRENT.combo++;
		var comboArray = CoolUtil.getcomboArray(PlayState.CURRENT.combo);
		for (i in 0...comboArray.length) {
			var numSprite = new FlxSprite();
			numSprite.loadGraphic(Assets.load(IMAGE, Paths.image('ui/numbers/${comboArray[i]}')));
			numSprite.scale.set(0.5, 0.5);
			numSprite.updateHitbox();
			numSprite.screenCenter();
			numSprite.y += 125;
			numSprite.acceleration.y = FlxG.random.int(200, 300);
			numSprite.velocity.y -= FlxG.random.int(140, 160);
			numSprite.velocity.x = FlxG.random.float(-5, 5);
			add(numSprite);
			numSprite.x += 57 * i;
			FlxTween.tween(numSprite, {alpha: 0}, 0.2, {
				startDelay: Conductor.crochet / 1000,
				onComplete: function(tween) {
					ratingGroup.remove(rating, true);
					rating.kill();
				}
			});
		}
		trace(comboArray);
		rating.scale.set(0.7,0.7);
		rating.updateHitbox();
		rating.screenCenter();
		ratingGroup.add(rating);
		rating.acceleration.y = 550;
		rating.velocity.y -= FlxG.random.int(140, 175);
		rating.velocity.x -= FlxG.random.int(0, 10);

		FlxTween.tween(rating, {alpha: 0}, 0.2, {
			startDelay: Conductor.stepCrochet / 1000,
			onComplete: function(tween) {
				ratingGroup.remove(rating, true);
				rating.kill();
			}
		});
	}

	public function countDown() {
		Conductor.songPosition = -Conductor.crochet * 5;
		var imageMap:Map<Int, String> = [1 => "ready", 2 => "set", 3 => "go"];
		var soundMap:Map<Int, String> = [0 => "intro3", 1 => "intro2", 2 => "intro1", 3 => "introGo"];

		new FlxTimer().start(Conductor.crochet / 1000, function(timer:FlxTimer) {
			var CountDownSprite = new FNFSprite();
			if (soundMap.exists(COUNT))
				FlxG.sound.play( Paths.sound('countdown/${soundMap.get(COUNT)}'));
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
			if (COUNT == 5)
				PlayState.CURRENT.startMusic();
		}, 5);
	}
}
