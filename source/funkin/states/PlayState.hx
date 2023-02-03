package funkin.states;

import cpp.Native;
import flixel.system.FlxSound;
import flixel.input.FlxInput.FlxInputState;
import openfl.events.KeyboardEvent;
import flixel.input.keyboard.FlxKey;
import flixel.FlxCamera;
import Song.SwagSong;

class PlayState extends MusicBeatState {
	public static var SONG:SwagSong;
	public static var CURRENT:PlayState;

	public var UI:HUD;
	public var camHUD = new FlxCamera();
	public var combo:Int = 0;
	public var voice = new FlxSound();
	public var musicStarted:Bool = false;

	override function preload() {
		super.preload();

		FlxG.sound.playMusic(Assets.load(SOUND, Paths.inst(SONG.song)), 0, false);
		Assets.load(SOUND, Paths.voices(SONG.song));
	}

	override function create() {
		super.create();
		CURRENT = this;
		UI = new HUD();
		add(UI);
		camHUD.bgColor = 0;
		UI.cameras = [camHUD];
		FlxG.cameras.add(camHUD);

		FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, handleInput);
		FlxG.stage.addEventListener(KeyboardEvent.KEY_UP, onRelese);

		Conductor.onStep.add(stepHit);
	}

	public function dadNoteHit(note:Note) {
		UI.dadStrum.members[note.noteData].playAnim("confirm", true);
		UI.dadStrum.members[note.noteData].animation.finishCallback = function name(name:String) {
			UI.dadStrum.members[note.noteData].playAnim("idle");
			note = null;
		};
		note.kill();
		note.destroy();
		UI.notes.remove(note, true);
	}

	public function playerNoteHit(note:Note) {
		UI.playerStrum.members[note.noteData].playAnim("confirm", true);
		note.wasGoodHit = true;
		UI.popupScore(note);
		note.kill();
		note.destroy();
		UI.notes.remove(note, true);
		closeNotes.remove(note);
	}

	var binds:Array<String> = ["A", "S", "K", "L"];
	var keys:Array<Bool> = [false, false, false, false];

	var closeNotes:Array<Note> = [];

	private function releaseInput(evt:KeyboardEvent):Void // handles releases
	{
		@:privateAccess
		var key = FlxKey.toStringMap.get(evt.keyCode);

		var binds:Array<String> = [
			FlxG.save.data.leftBind,
			FlxG.save.data.downBind,
			FlxG.save.data.upBind,
			FlxG.save.data.rightBind
		];

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

	public var closestNotes:Array<Note> = [];

	private function handleInput(evt:KeyboardEvent):Void { // this actually handles press inputs
		// first convert it from openfl to a flixel key code
		// then use FlxKey to get the key's name based off of the FlxKey dictionary
		// this makes it work for special characters

		@:privateAccess
		var key = FlxKey.toStringMap.get(evt.keyCode);

		var binds:Array<String> = ["A","S","K","L"];

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
			trace("ur already holding " + key);
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

		trace("notes able to hit for " + key.toString() + " " + dataNotes.length);

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

			// boyfriend.holdTimer = 0;
			playerNoteHit(coolNote);
			var noteDiff:Float = -(coolNote.strumTime - Conductor.songPosition);
		}
	}

	public function onRelese(event:KeyboardEvent) {
		var data = -1;
		data = binds.indexOf(FlxKey.toStringMap.get(event.keyCode));
		if (data == -1)
			return;
		keys[data] = false;
	}

	override function update(elapsed:Float) {
		super.update(elapsed);
		keysShit();
	}

	public function syncMusic() {
		FlxG.sound.music.pause();
		voice.pause();
		Conductor.songPosition = FlxG.sound.music.time;
		voice.time = FlxG.sound.music.time;
		FlxG.sound.music.resume();
		voice.resume();
	}

	public function stepHit(step:Int) {
		if (musicStarted && Math.abs(Conductor.songPosition - FlxG.sound.music.time) >= 20)
			syncMusic();
	}

	public function startMusic() {
		FlxG.sound.playMusic(Assets.load(SOUND, Paths.inst(SONG.song)), 1, false);
		voice.loadEmbedded(Paths.voices(SONG.song), false, false);
		FlxG.sound.list.add(voice);
		voice.play();
		syncMusic();
		musicStarted = true;
	}

	var susNotes:Array<Note> = [];

	function keysShit() {
		// sort shit
		susNotes = [];
		for (note in UI.notes)
			if (note.canBeHit && note.mustPress && !note.tooLate && note.isSustainNote)
				susNotes.push(note);
		susNotes.sort((a, b) -> Std.int(a.strumTime - b.strumTime));
		// da sus shit
		var keys:Array<FlxKey> = [];

		for (bind in binds)
			keys.push(FlxKey.fromString(bind));
		var keysPressed:Array<Bool> = [
			FlxG.keys.checkStatus(keys[0], PRESSED),
			FlxG.keys.checkStatus(keys[1], PRESSED),
			FlxG.keys.checkStatus(keys[2], PRESSED),
			FlxG.keys.checkStatus(keys[3], PRESSED)
		];
		var keysRelsesed:Array<Bool> = [
			FlxG.keys.checkStatus(keys[0], RELEASED),
			FlxG.keys.checkStatus(keys[1], RELEASED),
			FlxG.keys.checkStatus(keys[2], RELEASED),
			FlxG.keys.checkStatus(keys[3], RELEASED)
		];
		FlxG.watch.addQuick("Keys Pressed", keysPressed);
		UI.playerStrum.forEach(function(spr) {
			if (keysPressed[spr.ID] && spr.animation.curAnim.name != 'confirm')
				spr.playAnim('pressed', true);
			if (keysRelsesed[spr.ID])
				spr.playAnim('idle');
		});

		if (susNotes.length > 0
			&& susNotes[0].isSustainNote
			&& keysPressed[susNotes[0].noteData] == true
			&& Conductor.songPosition - susNotes[0].strumTime >= 0)
			playerNoteHit(susNotes[0]);
	}
}
