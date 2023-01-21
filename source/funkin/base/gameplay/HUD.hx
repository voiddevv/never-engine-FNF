package funkin.base.gameplay;

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

class HUD extends FlxSpriteGroup
{
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

	public function new()
	{
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
			PlayState.CURRENT, "health", 0, 2);
		healthBar.createFilledBar(FlxColor.RED, FlxColor.LIME);
		scoreText = new FlxText(0, FlxG.height * 0.95, 0, 'Misses: N/A | Score: ${PlayState.CURRENT.songscore} | Accureac: NO WOEK | Rank: N/A');
		scoreText.setFormat(Paths.font('vcr.ttf'), 18, 0xFFFFFFFF, CENTER, OUTLINE, 0xFF000000, true);
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
		scoreText.screenCenter(X);
		dadStrum.screenCenter(X);
		playerStrum.screenCenter(X);
		dadStrum.x -= 350;
		playerStrum.x += 350;
		dadStrum.y = playerStrum.y = 25;
		genChart();
		Conductor.songPosition = -Conductor.crochet * 3;
		countDown();
	}

	function getNoteDiff(note:Note)
	{
		return Math.abs(Conductor.songPosition - note.strumTime);
	}

	public var ratings:Array<Int> = [135, 90, 45, 0];

	public function getRating(note:Note):Int
	{
		for (rating in ratings)
			if (!note.isSustainNote && getNoteDiff(note) >= rating)
				return rating;
		return 180;
	}

	var ratmap = [0 => "sick", 45 => "good", 90 => "bad", 135 => "shit"];

	public function popUpScore(note:Note)
	{
		if (note.isSustainNote)
			return;
		GAME.combo++;
		var rating = getRating(note);
		var hitTime = getNoteDiff(note);
		var ratingName:String = ratmap.get(rating);
		trace(rating);
		trace("hit time is " + hitTime);
		switch (ratingName)
		{
			case "sick":
				PlayState.CURRENT.songscore += 300;
				health -= 0.023;
			case "good":
				health -= 0.023 * 0.7;
				PlayState.CURRENT.songscore += 200;
			case "bad":
				PlayState.CURRENT.songscore += 50;
			case "shit":
				health -= 0.023;
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
			onComplete: function(twe)
			{
				ratingSprite.kill();
				remove(ratingSprite, true);
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
			onComplete: function(twe)
			{
				ratingSprite.kill();
				remove(comboSpr, true);
			}
		});

		comboSpr.velocity.x += FlxG.random.int(1, 10);
		var i = 0;
		for (num in comboNums)
		{
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
				onComplete: function(twe)
				{
					numScore.kill();
					remove(numScore, true);
				}
			});
		}
		ratingGroup.scale.set(0.7, 0.7);
		comboGroup.scale.set(0.5, 0.5);
		scoreText.text = 'Misses: N/A | Score: ${PlayState.CURRENT.songscore} | Accureac: NO WOEK | Rank: N/A';
	}

	/**spawns the notes and adds them to a array**/
	public function genChart()
	{
		var CHART = PlayState.SONG;
		trace(Assets.load(INI, Paths.ini('data/${CHART.song.toLowerCase()}/hard')));
		for (section in CHART.notes)
			for (note in section.sectionNotes)
			{
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
				for (sus in 0...Math.floor(suslen))
				{
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
	}

	public function countDown()
	{
		var imageMap:Map<Int, String> = [1 => "ready", 2 => "set", 3 => "go"];
		var soundMap:Map<Int, String> = [0 => "intro3", 1 => "intro2", 2 => "intro1", 3 => "introGo"];

		new FlxTimer().start(Conductor.crochet / 1000, function(timer:FlxTimer)
		{
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
				onComplete: function(tween:FlxTween)
				{
					CountDownSprite.kill();
					CountDownSprite.destroy();
					remove(CountDownSprite, true);
				}
			});

			COUNT++;
		}, 5);
	}

	public function resyncVocals():Void
	{
		voice.pause();

		FlxG.sound.music.play();
		Conductor.songPosition = FlxG.sound.music.time;
		voice.time = Conductor.songPosition;
		voice.play();
	}

	public function startSong()
	{
		voice.loadEmbedded(Assets.load(SOUND, Paths.voices(PlayState.SONG.song)));
		FlxG.sound.list.add(voice);
		voice.play();
		FlxG.sound.playMusic(Assets.load(SOUND, Paths.inst(PlayState.SONG.song)), 1, false);
		songStarted = true;
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		var iconOffset:Int = 26;

		bfIcon.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01) - iconOffset);
		dadIcon.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - (dadIcon.width - iconOffset);

		if (Conductor.songPosition >= 0 && !songStarted)
			startSong();
		notes.forEach(function(note)
		{
			if (getNoteDiff(note) >= 900/GAME.camHUD.zoom)
				note.kill();
			else
				note.revive();

			note.y = dadStrum.y - (Conductor.songPosition - note.strumTime) * (0.45 * FlxMath.roundDecimal(PlayState.SONG.speed, 2));
			if (note.mustPress)
				note.y = playerStrum.y - (Conductor.songPosition - note.strumTime) * (0.45 * FlxMath.roundDecimal(PlayState.SONG.speed, 2));
			if (Conductor.songPosition - note.strumTime >= 0 && !note.mustPress)
				PlayState.CURRENT.dadNoteHit(note);
		}, true);
		Conductor.songPosition += elapsed * 1000;
		if (songStarted && voice.playing && Conductor.songPosition >= voice.length)
			endsong();
	}

	public function endsong()
	{
		trace("ENDING SONG");
		FlxG.sound.music.stop();
		voice.destroy();
		FlxG.switchState(new MainMenuState());
	}
}
