package funkin.base.gameplay;

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
	public var dadStrum:Strum;
	public var playerStrum:Strum;
	public var notes:FlxTypedSpriteGroup<Note> = new FlxTypedSpriteGroup();
	public var voice:FlxSound = new FlxSound();
	public var songStarted:Bool = false;
	public var COUNT:Int = 0;
	public var healthBarBG = new FNFSprite(0, FlxG.height * 0.9, Assets.load(IMAGE, Paths.image("ui/healthBar")));
	public var healthBar:FlxBar;
	public var dadIcon:HealthIcon;
	public var bfIcon:HealthIcon;
	public var scoreText:FlxText;
	public var GAME = PlayState.CURRENT;
	public var ratingGroup:FlxSpriteGroup = new FlxSpriteGroup();
	public var comboGroup:FlxSpriteGroup = new FlxSpriteGroup();
	public var timeText:FlxText;

	public function new() {
		super();
		Conductor.changeBPM(PlayState.SONG.bpm);
		Conductor.mapBPMChanges(PlayState.SONG);
		dadIcon = new HealthIcon("dad");
		bfIcon = new HealthIcon("bf", true);
		dadIcon.y = bfIcon.y = FlxG.height * 0.8;
		playerStrum = new Strum();
		dadStrum = new Strum();
		healthBarBG.screenCenter(X);
		healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8),
			PlayState.CURRENT, "health", PlayState.CURRENT.minHealth, PlayState.CURRENT.maxHealth);
		healthBar.createFilledBar(FlxColor.RED, FlxColor.LIME);
		scoreText = new FlxText(0, FlxG.height * 0.95, 0, '< Misses: N/A ~ Score: ${PlayState.CURRENT.songscore} ~ Accureac: NO WOEK ~ Rank: N/A >');
		scoreText.setFormat(Paths.font('vcr.ttf'), 16, 0xFFFFFFFF, CENTER, OUTLINE, 0xFF000000, true);
		timeText = new FlxText(0, FlxG.height * 0.1, 0, 'Time Left ?:??');
		timeText.setFormat(Paths.font('vcr.ttf'), 28, 0xFFFFFFFF, CENTER, OUTLINE, 0xFF000000, true);
		add(healthBarBG);
		add(healthBar);
		add(dadIcon);
		add(bfIcon);
		add(dadStrum);
		add(playerStrum);
		add(notes);
		add(comboGroup);
		add(ratingGroup);
		ratingGroup.scale.set(0.7, 0.7);
		add(scoreText);
		add(timeText);
		scoreText.screenCenter(X);
		dadStrum.screenCenter(X);
		playerStrum.screenCenter(X);
		dadStrum.x -= 350;
		playerStrum.x += 350;
		dadStrum.y = playerStrum.y = 25;
		genChart();
		Conductor.songPosition = -Conductor.crochet * 5;
		countDown();
		timeText.alpha = 0;
		Conductor.onBeat.add(iconBounce);
		Conductor.onSection.add(sectionHit);
	}

	public function iconBounce(a) {
		bfIcon.scale.set(1.2, 1.2);
		dadIcon.scale.set(1.2, 1.2);
		bfIcon.updateHitbox();
		dadIcon.updateHitbox();
	}

	function getNoteDiff(note:Note) {
		return Math.abs(Conductor.songPosition - note.strumTime);
	}

	public var ratings:Array<Int> = [135, 90, 45, 0];

	public function getRating(note:Note):Int {
		for (rating in ratings)
			if (!note.isSustainNote && getNoteDiff(note) >= rating)
				return rating;
		return 180;
	}

	var ratmap = [0 => "sick", 45 => "good", 90 => "bad", 135 => "shit"];

	public function popUpScore(note:Note) {
		if (note.isSustainNote)
			return;
		GAME.combo++;
		var rating = getRating(note);
		var hitTime = getNoteDiff(note);
		var ratingName:String = ratmap.get(rating);
		trace(rating);
		trace("hit time is " + hitTime);
		switch (ratingName) {
			case "sick":
				var splash = new NoteSplash(note.noteData);
				add(splash);
				PlayState.CURRENT.songscore += 300;
			case "good":
				PlayState.CURRENT.songscore += 200;
			case "bad":
				PlayState.CURRENT.songscore += 50;
			case "shit":
				GAME.health -= 0.1;
				PlayState.CURRENT.songscore -= 10;
		}
		var ratingSprite = new FlxSprite(400, 400).loadGraphic(Assets.load(IMAGE, Paths.image('ui/ratings/$ratingName')));
		ratingSprite.screenCenter();
		ratingSprite.x = FlxG.width * 0.55 - 40;
		ratingSprite.y -= 60;
		ratingGroup.add(ratingSprite);
		ratingSprite.acceleration.y = 550;
		ratingSprite.velocity.y -= FlxG.random.int(140, 175);
		ratingSprite.velocity.x -= FlxG.random.int(0, 10);
		var comboNums:Array<Int> = [];
		for (num in Std.string(GAME.combo).split(""))
			comboNums.push(Std.parseInt(num));
		trace(comboNums);
		FlxTween.tween(ratingSprite, {alpha: 0}, 0.2, {
			startDelay: Conductor.crochet / 1000,
			onComplete: function(twe) {
				remove(ratingSprite, true);
				ratingSprite.kill();
				ratingSprite.destroy();

			}
		});
		var comboSpr:FlxSprite = new FlxSprite().loadGraphic(Paths.image('combo'));
		comboSpr.screenCenter();
		comboSpr.x = FlxG.width * 0.55;
		comboSpr.acceleration.y = 600;
		comboSpr.velocity.y -= 150;
		ratingGroup.add(comboSpr);
		FlxTween.tween(comboSpr, {alpha: 0}, 0.2, {
			startDelay: Conductor.crochet / 1000,
			onComplete: function(twe) {
				remove(comboSpr, true);
				comboSpr.kill();
				comboSpr.destroy();
			}
		});

		comboSpr.velocity.x += FlxG.random.int(1, 10);
		var i = 0;
		for (num in comboNums) {
			var numScore:FlxSprite = new FlxSprite().loadGraphic(Paths.image('num' + Std.int(num)));
			numScore.screenCenter();
			numScore.x = FlxG.width * 0.55 + (45 * i) - 90;
			numScore.y += 70;
			comboGroup.add(numScore);
			i++;
			numScore.acceleration.y = 600;
			numScore.velocity.y -= 150;
			FlxTween.tween(numScore, {alpha: 0}, 0.2, {
				startDelay: Conductor.crochet / 1000,
				onComplete: function(twe) {
					remove(numScore, true);
					numScore.kill();
					numScore.destroy();
				}
			});
		}
		ratingGroup.scale.set(0.7, 0.7);
		comboGroup.scale.set(0.5, 0.5);
		scoreText.text = 'Misses: ${GAME.misses} | Score: ${GAME.songscore} | Accureac: NO WOEK | Rank: N/A';
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
					susNote.x = dadStrum.members[theNote.noteData].x + 33;
					if (hitDaNote)
						susNote.x = playerStrum.members[theNote.noteData].x + 33;
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
		trace(PlayState.SONG.notes);
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

	public function resyncVocals():Void {
		voice.pause();

		FlxG.sound.music.play();
		Conductor.songPosition = FlxG.sound.music.time;
		voice.time = Conductor.songPosition;
		voice.play();
	}

	public function startSong() {
		voice.loadEmbedded(Assets.load(SOUND, Paths.voices(PlayState.SONG.song)), false, false, endsong);
		FlxG.sound.list.add(voice);
		voice.play();
		FlxG.sound.playMusic(Assets.load(SOUND, Paths.inst(PlayState.SONG.song)), 1, false);
		FlxG.sound.music.onComplete = endsong;
		songStarted = true;
	}

	override function update(elapsed:Float) {
		super.update(elapsed);
		dadIcon.scale.set(FlxMath.lerp(dadIcon.scale.x, 1, FlxG.elapsed / (1 / 60) * 0.2), FlxMath.lerp(dadIcon.scale.y, 1, FlxG.elapsed / (1 / 60) * 0.2));
		bfIcon.scale.set(FlxMath.lerp(bfIcon.scale.x, 1, FlxG.elapsed / (1 / 60) * 0.2), FlxMath.lerp(bfIcon.scale.y, 1, FlxG.elapsed / (1 / 60) * 0.2));
		var iconOffset:Int = 26;
		if (voice != null && voice.length > 1000) {
			timeText.text = 'Time Left: ${FlxStringUtil.formatTime(Math.abs(Conductor.songPosition - voice.length) / 1000)}';
			timeText.screenCenter(X);
		}
		if (timeText.alpha <= 0)
			FlxTween.tween(timeText, {alpha: 1}, Conductor.crochet / 1000 * 5, {ease: FlxEase.circOut, startDelay: Conductor.crochet / 1000 * 5});

		bfIcon.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01) - iconOffset);
		dadIcon.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - (dadIcon.width - iconOffset);
		dadIcon.scale.set(FlxMath.lerp(dadIcon.scale.x, 1, FlxG.elapsed / (1 / 60) * 0.1), FlxMath.lerp(dadIcon.scale.y, 1, FlxG.elapsed / (1 / 60) * 0.1));
		bfIcon.scale.set(FlxMath.lerp(bfIcon.scale.x, 1, FlxG.elapsed / (1 / 60) * 0.1), FlxMath.lerp(bfIcon.scale.y, 1, FlxG.elapsed / (1 / 60) * 0.1));
		bfIcon.updateHitbox();
		dadIcon.updateHitbox();
		if (Conductor.songPosition >= 0 && !songStarted)
			startSong();
		notes.forEach(function(note) {
			if (getNoteDiff(note) >= 1000)
				note.kill();
			else
				note.revive();
		}, true);
		notes.forEachAlive(function(note) {
			note.y = dadStrum.y - (Conductor.songPosition - note.strumTime) * (0.45 * FlxMath.roundDecimal(PlayState.SONG.speed, 2));
			if (note.mustPress) {
				note.y = playerStrum.y - (Conductor.songPosition - note.strumTime) * (0.45 * FlxMath.roundDecimal(PlayState.SONG.speed, 2));
				if (note.tooLate)
					PlayState.CURRENT.NoteMiss(note.noteData, note);
			}
			if (Conductor.songPosition - note.strumTime >= 0 && !note.mustPress)
				PlayState.CURRENT.dadNoteHit(note);
		}, true);
		Conductor.songPosition += elapsed * 1000;
		if (songStarted && Conductor.songPosition >= voice.length)
			endsong();
	}

	public function sectionHit(section:Int) {
		if (PlayState.SONG.notes[section] != null && PlayState.SONG.notes[section].changeBPM)
			Conductor.changeBPM(PlayState.SONG.notes[section].bpm);
	}

	public function endsong() {
		trace("ENDING SONG");
		FlxG.sound.music.stop();
		FlxG.sound.music.kill();
		voice.destroy();
		FlxG.switchState(new MainMenu());
	}
}
