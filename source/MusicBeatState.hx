package;

import engine.api.Options;
import Conductor.BPMChangeEvent;
import flixel.FlxG;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.ui.FlxUIState;
import flixel.math.FlxRect;
import flixel.util.FlxTimer;

class MusicBeatState extends FlxUIState
{
	private var lastBeat:Float = 0;
	private var lastStep:Float = 0;
	//
	private var curStep:Int = 0;
	private var curBeat:Int = 0;
	private var controls(get, never):Controls;

	inline function get_controls():Controls
		return PlayerSettings.player1.controls;
	/**function that you can override for preloading**/
	public function preload() {}
	override function create()
	{
		if (transIn != null)
			trace('reg ' + transIn.region);
		Conductor.reset();

		#if (!web)
		TitleState.soundExt = '.ogg';
		#end

		super.create();
		Mem.clearAll();
		preload();
		FlxG.drawFramerate = FlxG.updateFramerate = Options.GAMEPLAY.get("FRAMERATE");
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
	}
}
