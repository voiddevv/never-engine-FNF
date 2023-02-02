package funkin.states;

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
		UI.playerStrum.members[note.noteData].animation.finishCallback = function name(name:String) {
			UI.playerStrum.members[note.noteData].playAnim("idle");
		};
		note.wasGoodHit = true;
		note.kill();
		note.destroy();
		UI.notes.remove(note, true);
		closeNotes.remove(note);
	}

	var binds:Array<String> = ["A", "S", "K", "L"];
	var closeNotes:Array<Note> = [];
	var keys:Array<Bool> = [false, false, false, false];

	public function onJustPress(key:Int) {
		closeNotes = [];
		var data = -1;

		data = binds.indexOf(FlxKey.toStringMap.get(key));

		for (note in UI.notes)
			if (note.canBeHit && note.mustPress && !note.tooLate)
				closeNotes.push(note);

		closeNotes.sort((a, b) -> Std.int(a.strumTime - b.strumTime));

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
	}

	function keysShit() {
		var keys:Array<FlxKey> = [];
		for (bind in binds)
			keys.push(FlxKey.fromString(bind));
		if (FlxG.keys.anyPressed(keys)) {
			trace(keys);
			if (closeNotes[0] == null)
				return;
		}
	}
}
