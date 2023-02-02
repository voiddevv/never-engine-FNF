package funkin.states;

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

	override function create() {
		super.create();
		CURRENT = this;
		UI = new HUD();
		add(UI);
		camHUD.bgColor = 0;
		UI.cameras = [camHUD];
		FlxG.cameras.add(camHUD);

		engine.Controls.onJustPress.add(onJustPress);
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
		note.kill();
		note.destroy();
		UI.notes.remove(note, true);
		closeNotes.remove(note);
	}

	var binds:Array<String> = ["A", "S", "K", "L"];
	var closeNotes:Array<Note> = [];

	public function onJustPress(key:Int) {
		var data = -1;

		data = binds.indexOf(FlxKey.toStringMap.get(key));

		if (data == -1)
			return;

		if (closeNotes[0] == null)
			return;

		if (data != closeNotes[0].noteData || closeNotes[0].isSustainNote)
			return;

		trace('data: $data');

		playerNoteHit(closeNotes[0]);
	}

	override function update(elapsed:Float) {
		super.update(elapsed);
		keysShit();
	}

	function keysShit() {
		// sort shit
		closeNotes = [];
		for (note in UI.notes)
			if (note.canBeHit && note.mustPress && !note.tooLate)
				closeNotes.push(note);
		closeNotes.sort((a, b) -> Std.int(a.strumTime - b.strumTime));
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
		UI.playerStrum.forEach(function(spr) {
			if (keysPressed[spr.ID] && spr.animation.curAnim.name != 'confirm')
				spr.playAnim('pressed',true);
			if (keysRelsesed[spr.ID])
				spr.playAnim('idle');
		});

		if (closeNotes.length > 0 && closeNotes[0].isSustainNote && Conductor.songPosition - closeNotes[0].strumTime >= 0)
			playerNoteHit(closeNotes[0]);
	}
}
