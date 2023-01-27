package;

import flixel.util.FlxSignal.FlxTypedSignal;
import Song.SwagSong;

/**
 * ...
 * @author
 */
typedef BPMChangeEvent = {
	var stepTime:Int;
	var songTime:Float;
	var bpm:Int;
}

class Conductor {
	public static var bpm:Int = 100;
	public static var crochet:Float = ((60 / bpm) * 1000); // beats in milliseconds
	public static var stepCrochet:Float = crochet / 4; // steps in milliseconds
	public static var songPosition:Float; // the song time in milliseconds
	public static var lastSongPos:Float;
	public static var offset:Float = 0; // song offset
	public static var curStep:Int = 0;
	public static var curBeat:Int = 0;
	public static var curDecStep:Float = 0;
	public static var curDecSection:Float = 0;
	public static var curSection:Int = 0;
	public static var curDecBeat:Float = 0;
	public static var sectionStepLength = 16;

	public static var onBeat:FlxTypedSignal<Int->Void> = new FlxTypedSignal();
	public static var onStep:FlxTypedSignal<Int->Void> = new FlxTypedSignal();
	public static var onSection:FlxTypedSignal<Int->Void> = new FlxTypedSignal();

	public static var safeFrames:Int = 10;
	public static var safeZoneOffset:Float = (safeFrames / 60) * 1000; // is calculated in create(), is safeFrames in milliseconds
	static var lastStep:Int = -1;
	public static var bpmChangeMap:Array<BPMChangeEvent> = [];

	public static function init() {
		FlxG.signals.preUpdate.add(update);
	}

	public static function reset() {
		onSection.removeAll();
		onBeat.removeAll();
		onStep.removeAll();
	}

	public static function update() {
		updateCurStep();
		updateBeat();
		updateSection();

		if (lastStep != curStep && curStep > 0)
			onStep.dispatch(curStep);
		if (lastStep != curStep && curStep % 4 == 0){
			onBeat.dispatch(curBeat);
		}
		if (lastStep != curStep && curStep % 16 == 0)
			onSection.dispatch(curSection);

		lastStep = curStep;
	}

	static function updateBeat():Void {
		curDecBeat = curDecStep / 4;
		curBeat = Math.floor(curDecBeat);
	}

	static function updateSection():Void {
		curDecSection = curDecStep / 16;
		curSection = Math.floor(curDecSection);
	}

	static function updateCurStep():Void {
		var lastChange:BPMChangeEvent = {
			stepTime: 0,
			songTime: 0,
			bpm: 0
		}
		for (i in 0...Conductor.bpmChangeMap.length) {
			if (Conductor.songPosition >= Conductor.bpmChangeMap[i].songTime)
				lastChange = Conductor.bpmChangeMap[i];
		}

		curDecStep = lastChange.stepTime + (Conductor.songPosition - lastChange.songTime) / Conductor.stepCrochet;
		curStep = Math.floor(curDecStep);
	}

	public static function mapBPMChanges(song:SwagSong) {
		bpmChangeMap = [];

		var curBPM:Int = song.bpm;
		var totalSteps:Int = 0;
		var totalPos:Float = 0;
		for (i in 0...song.notes.length) {
			if (song.notes[i].changeBPM && song.notes[i].bpm != curBPM) {
				curBPM = song.notes[i].bpm;
				var event:BPMChangeEvent = {
					stepTime: totalSteps,
					songTime: totalPos,
					bpm: curBPM
				};
				bpmChangeMap.push(event);
			}

			var deltaSteps:Int = song.notes[i].lengthInSteps;
			totalSteps += deltaSteps;
			totalPos += ((60 / curBPM) * 1000 / 4) * deltaSteps;
		}
		trace("new BPM map BUDDY " + bpmChangeMap);
	}

	public static function changeBPM(newBpm:Int) {
		bpm = newBpm;

		crochet = ((60 / bpm) * 1000);
		stepCrochet = crochet / 4;
	}
}
