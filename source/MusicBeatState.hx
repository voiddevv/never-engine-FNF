package;

import flixel.util.FlxSignal.FlxTypedSignal;
import engine.api.Options;
import Conductor.BPMChangeEvent;
import flixel.FlxG;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.ui.FlxUIState;
import flixel.math.FlxRect;
import flixel.util.FlxTimer;

using StringTools;

class MusicBeatState extends FlxUIState {
	private var controls(get, never):Controls;

	public static var stateName(get, never):String;
	public static var lastStateName:String = "NONE";
	public static var onFixedUpdate:FlxTypedSignal<Float->Void> = new FlxTypedSignal();

	inline function get_controls():Controls
		return PlayerSettings.player1.controls;

	/**function that you can override for preloading**/
	public function preload() {}

	override function create() {
		new FlxTimer().start(1/60,function (timer) {
			onFixedUpdate.dispatch(1/60);
		},0);
		trace(stateName);
		Conductor.reset();

		#if (!web)
		TitleState.soundExt = '.ogg';
		#end
		Mem.clearAll();
		super.create();
		preload();
		FlxG.drawFramerate = FlxG.updateFramerate = Options.GAMEPLAY.get("FRAMERATE");
	}

	override function update(elapsed:Float) {
		super.update(elapsed);
	}

	static function get_stateName():String {
		var daClassPath = Type.getClassName(Type.getClass(FlxG.state));
		return daClassPath.split('.')[daClassPath.split('.').length - 1];
	}
}
