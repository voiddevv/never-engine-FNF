package funkin.states;

import flixel.math.FlxMath;
import engine.scripting.Hscript;
import sys.FileSystem;
import flixel.FlxSprite;
import flixel.input.keyboard.FlxKeyList;
import flixel.input.keyboard.FlxKeyboard;
import flixel.input.keyboard.FlxKey;
import openfl.events.KeyboardEvent;
import flixel.FlxCamera;
import Song.SwagSong;

using StringTools;

class PlayState extends MusicBeatState {
	public var bf:Character;
	public var dad:Character;
	public var modChart = new Hscript();

	public static var SONG:SwagSong;
	public static var CURRENT:PlayState;

	public var stage:Stage;
	public var camHUD:FlxCamera = new FlxCamera();
	public var camGame:FlxCamera;
	public var UI:HUD;
	public var defaultCamZoom:Float = 1.05;
	// scoreText Shit
	public var combo:Int = 0;
	public var health = 1.0;
	public var minHealth = 0.0;
	public var maxHealth = 2.0;
	public var misses:Int = 0;
	public var songscore:Int = 0;

	// accuracy shit
	public var totalNotes:Int = 0;
	public var totalHit:Float = 0.0;
	public var accuracy(get, null):Float = 0.0;
	public var rank:String = 'N/A';
	public var rankArray:Array<Array<Dynamic>> = [
		[0.0, 'L'],
		[0.5, 'F'],
		[0.6, 'D'],
		[0.7, 'C'],
		[0.8, 'B'],
		[0.9, 'A'],
		[0.95, 'S'],
		[1.0, 'SS']
	];

	function get_accuracy():Float {
		if (totalNotes == 0 || totalHit == 0)
			return 0.0;
		return totalHit / (totalNotes + misses);
	}

	/**preload your shit here**/
	override function preload() {
		super.preload();
		trace("PRELOADING SONG");
		Assets.load(SOUND, Paths.inst(SONG.song));
		Assets.load(SOUND, Paths.voices(SONG.song));
		trace("LOADING... SCRIPTS");
		// for (script in FileSystem.readDirectory(FileSystem.absolutePath(Paths.getPath('data/${SONG.song.toLowerCase()}')))) {
		// 	if (script.endsWith('.hx'))
		// 		modChart.loadScript('data/${SONG.song.toLowerCase()}/${script.replace(".hx", "")}');
		// }
	}

	override function create() {
		super.create();
		camGame = FlxG.camera;
		modChart.interp.scriptObject = this;
		FlxG.cameras.add(camHUD, false);
		camHUD.bgColor = 0;
		CURRENT = this;
		bf = new Character(800, 430, "bf", true);
		dad = new Character(100, 100, "dad");
		stage = new Stage();
		UI = new HUD();
		modChart.call('create');
		add(stage);
		add(bf);
		add(dad);
		add(UI);
		UI.cameras = [camHUD];
		FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, onPress);
		FlxG.stage.addEventListener(KeyboardEvent.KEY_UP, onRelease);
		Conductor.onBeat.add(beatHit);
		Conductor.onStep.add(stepHit);
		modChart.call("createPost");
	}

	function beatHit(curBeat) {
		modChart.call("beatHit", [curBeat]);
		if (curBeat % 4 == 0) {
			FlxG.camera.zoom += 0.015;
			camHUD.zoom += 0.03;
		}
		if (!dad.animation.name.startsWith("sing"))
			dad.dance();
		if (!bf.animation.name.startsWith("sing"))
			bf.dance();
		// if (!gf.animation.name.startsWith("sing"))
		// 	dad.dance();
	}

	function stepHit(curStep) {
		modChart.call("stepHit", [curStep]);
		if (UI.songStarted && FlxG.sound.music.time > Conductor.songPosition + 20 || FlxG.sound.music.time < Conductor.songPosition - 20) {
			UI.resyncVocals();
		}
	}

	override function update(elapsed:Float) {
		super.update(elapsed);
		if (camGame != null)
			camGame.zoom = FlxMath.lerp(camGame.zoom, defaultCamZoom, FlxG.elapsed / (1 / 60) * 0.05);
		if (camHUD != null)
			camHUD.zoom = FlxMath.lerp(camHUD.zoom, 1, FlxG.elapsed / (1 / 60) * 0.05);
		if (UI != null)
			keyShit();
	}

	public function dadNoteHit(note:Note) {
		if (note == null)
			return;
		dad.holdTimer = 0;
		var dirs:Array<String> = ['LEFT', 'DOWN', 'UP', 'RIGHT'];
		dad.playAnim('sing${dirs[note.noteData]}', true);
		UI.notes.remove(note, true);
		note.kill();
		note.destroy();
		UI.dadStrum.members[note.noteData].playAnim("confirm");
		UI.dadStrum.members[note.noteData].animation.finishCallback = function(name) {
			if (name == "confirm")
				UI.dadStrum.members[note.noteData].playAnim('idle');
		}
	}

	public function playerNoteHit(note:Note) {
		if (note == null)
			return;
		bf.holdTimer = 0;
		health += 0.023;
		var dirs:Array<String> = ['LEFT', 'DOWN', 'UP', 'RIGHT'];
		bf.playAnim('sing${dirs[note.noteData]}', true);
		UI.playerStrum.members[note.noteData].playAnim("confirm", true);
		UI.notes.remove(note, true);
		note.wasGoodHit = true;
		UI.popUpScore(note);
		note.kill();
		note.destroy();
	}

	public function NoteMiss(direction:Int, note:Note) {
		if (note == null)
			return;
		health -= 0.046;

		var dirs:Array<String> = ['LEFT', 'DOWN', 'UP', 'RIGHT'];
		misses++;
		UI.scoreText.text = 'Misses: $misses | Score: ${PlayState.CURRENT.songscore} | Accureac: NO WOEK | Rank: N/A';
		bf.playAnim('sing${dirs[direction]}miss');
		UI.notes.remove(note, true);
		note.kill();
		note.destroy();
	}

	var keys = [false, false, false, false];

	public var closestNotes:Array<Note> = [];

	private function onRelease(evt:KeyboardEvent):Void // handles releases
	{
		@:privateAccess
		var key = FlxKey.toStringMap.get(evt.keyCode);
		var binds:Array<String> = ["A", "S", "K", "L"];

		var data = -1;

		switch (evt.keyCode) // arrow keys
		{
			case 37:
				data = 0;
			case 40:
				data = 1;
			case 38:
				data = 2;
			case 39:
				data = 3;
		}

		for (i in 0...binds.length) // binds
		{
			if (binds[i].toLowerCase() == key.toLowerCase())
				data = i;
		}

		if (data == -1)
			return;
		keys[data] = false;
	}

	private function onPress(evt:KeyboardEvent):Void { // this actually handles press inputs

		if (UI == null)
			return;

		// first convert it from openfl to a flixel key code
		// then use FlxKey to get the key's name based off of the FlxKey dictionary
		// this makes it work for special characters

		@:privateAccess
		var key = FlxKey.toStringMap.get(evt.keyCode);

		var binds:Array<String> = ["A", "S", "K", "L"];

		var data = -1;

		switch (evt.keyCode) // arrow keys
		{
			case 37:
				data = 0;
			case 40:
				data = 1;
			case 38:
				data = 2;
			case 39:
				data = 3;
		}

		for (i in 0...binds.length) // binds
		{
			if (binds[i].toLowerCase() == key.toLowerCase())
				data = i;
		}
		if (data == -1) {
			trace("couldn't find a keybind with the code " + key);
			return;
		}
		if (keys[data]) {
			return;
		}

		keys[data] = true;
		closestNotes = [];

		UI.notes.forEachAlive(function(daNote:Note) {
			if (daNote.canBeHit && daNote.mustPress && !daNote.wasGoodHit)
				closestNotes.push(daNote);
		}); // Collect notes that can be hit

		closestNotes.sort((a, b) -> Std.int(a.strumTime - b.strumTime));

		var dataNotes = [];
		for (i in closestNotes)
			if (i.noteData == data && !i.isSustainNote)
				dataNotes.push(i);
		if (dataNotes.length != 0) {
			var coolNote = null;

			for (i in dataNotes) {
				coolNote = i;
				break;
			}

			if (dataNotes.length > 1) // stacked notes or really close ones
			{
				for (i in 0...dataNotes.length) {
					if (i == 0) // skip the first note
						continue;

					var note = dataNotes[i];

					if (!note.isSustainNote && ((note.strumTime - coolNote.strumTime) < 2) && note.noteData == data) {
						trace('found a stacked/really close note ' + (note.strumTime - coolNote.strumTime));
						// just fuckin remove it since it's a stacked note and shouldn't be there
						note.kill();
						UI.notes.remove(note, true);
						note.destroy();
					}
				}
			}

			bf.holdTimer = 0;
			playerNoteHit(coolNote);
			var noteDiff:Float = -(coolNote.strumTime - Conductor.songPosition);
		}
	}

	var possibleNotes:Array<Note> = []; // copypasted but you already know that

	private function keyShit():Void // I've invested in emma stocks
	{
		// control arrays, order L D R U
		var holdArray:Array<Bool> = [
			FlxG.keys.pressed.A,
			FlxG.keys.pressed.S,
			FlxG.keys.pressed.K,
			FlxG.keys.pressed.L
		];
		var pressArray:Array<Bool> = [
			FlxG.keys.justPressed.A,
			FlxG.keys.justPressed.S,
			FlxG.keys.justPressed.K,
			FlxG.keys.justPressed.L
		];
		var releaseArray:Array<Bool> = [
			FlxG.keys.justReleased.A,
			FlxG.keys.justReleased.S,
			FlxG.keys.justReleased.K,
			FlxG.keys.justReleased.L
		];
		var keynameArray:Array<String> = ['left', 'down', 'up', 'right'];

		// Prevent player input if botplay is on
		// HOLDS, check for sustain notes
		if (holdArray.contains(true) && UI.songStarted) {
			UI.notes.forEachAlive(function(daNote:Note) {
				if (daNote.prevNote.wasGoodHit
					&& Conductor.songPosition - daNote.strumTime >= 0
					&& daNote.isSustainNote
					&& daNote.canBeHit
					&& daNote.mustPress
					&& holdArray[daNote.noteData]) {
					playerNoteHit(daNote);
				}
			});
		}

		if ((!FlxG.keys.justPressed.ANY)) {
			// PRESSES, check for note hits
			if (pressArray.contains(true) && UI.songStarted) {
				bf.holdTimer = 0;

				var possibleNotes:Array<Note> = []; // notes that can be hit
				var directionList:Array<Int> = []; // directions that can be hit
				var dumbNotes:Array<Note> = []; // notes to kill later
				var directionsAccounted:Array<Bool> = [false, false, false, false]; // we don't want to do judgments for more than one presses

				UI.notes.forEachAlive(function(daNote:Note) {
					if (daNote.canBeHit && daNote.mustPress && !daNote.wasGoodHit && !directionsAccounted[daNote.noteData]) {
						if (directionList.contains(daNote.noteData)) {
							directionsAccounted[daNote.noteData] = true;
							for (coolNote in possibleNotes) {
								if (coolNote.noteData == daNote.noteData
									&& Math.abs(daNote.strumTime - coolNote.strumTime) < 10) { // if it's the same note twice at < 10ms distance, just delete it
									// EXCEPT u cant delete it in this loop cuz it fucks with the collection lol
									dumbNotes.push(daNote);
									break;
								} else if (coolNote.noteData == daNote.noteData
									&& daNote.strumTime < coolNote.strumTime) { // if daNote is earlier than existing note (coolNote), replace
									possibleNotes.remove(coolNote);
									possibleNotes.push(daNote);
									break;
								}
							}
						} else {
							directionsAccounted[daNote.noteData] = true;
							possibleNotes.push(daNote);
							directionList.push(daNote.noteData);
						}
					}
				});

				for (note in dumbNotes) {
					FlxG.log.add("killing dumb ass note at " + note.strumTime);
					note.kill();
					UI.notes.remove(note, true);
					note.destroy();
				}

				possibleNotes.sort((a, b) -> Std.int(a.strumTime - b.strumTime));

				var hit = [false, false, false, false];

				// if (perfectMode)
				// 	goodNoteHit(possibleNotes[0]);
				if (possibleNotes.length > 0) {
					if (!FlxG.save.data.ghost) {
						for (shit in 0...pressArray.length) { // if a direction is hit that shouldn't be
							if (pressArray[shit] && !directionList.contains(shit))
								NoteMiss(shit, null);
						}
					}
					for (coolNote in possibleNotes) {
						if (pressArray[coolNote.noteData] && !hit[coolNote.noteData]) {
							hit[coolNote.noteData] = true;
							var noteDiff:Float = -(coolNote.strumTime - Conductor.songPosition);
							playerNoteHit(coolNote);
						}
					}
				};
				else if (!FlxG.save.data.ghost) {
					for (shit in 0...pressArray.length)
						if (pressArray[shit])
							NoteMiss(shit, null);
				}
			}
			UI.playerStrum.forEach(function(spr:FNFSprite) {
				if (keys[spr.ID] && spr.animation.curAnim.name != 'confirm' && spr.animation.curAnim.name != 'pressed')
					spr.playAnim('pressed', false);
				if (!keys[spr.ID])
					spr.playAnim('idle', false);
			});
		}
		if (bf.holdTimer > Conductor.stepCrochet * bf.singDur * 0.001 && (!holdArray.contains(true))) {
			if (bf.animation.curAnim.name.startsWith('sing') && !bf.animation.curAnim.name.endsWith('miss'))
				bf.dance();
		}
		if (dad.holdTimer > Conductor.stepCrochet * dad.singDur * 0.001 && (!holdArray.contains(true))) {
			if (dad.animation.curAnim.name.startsWith('sing') && !dad.animation.curAnim.name.endsWith('miss'))
				dad.dance();
		}
	}

	override function destroy() {
		FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onPress);
		FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, onRelease);
		super.destroy();
	}
}
