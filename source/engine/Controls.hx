package engine;

import flixel.FlxG;
import flixel.input.keyboard.FlxKeyboard;
import openfl.ui.Keyboard;
import openfl.events.KeyboardEvent;
import flixel.util.FlxSignal.FlxTypedSignal;

class Controls {
	public static var onPress:FlxTypedSignal<Int->Void> = new FlxTypedSignal();
	public static var onRelsase:FlxTypedSignal<Int->Void> = new FlxTypedSignal();
	public static var onJustPress:FlxTypedSignal<Int->Void> = new FlxTypedSignal();
	public static var holdTimes:Array<Float> = [];

	public static function init() {
		FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, Press);
		FlxG.stage.addEventListener(KeyboardEvent.KEY_UP, RELESE);

		holdTimes.resize(222);
	}

	static function Press(event:KeyboardEvent) {
		if (holdTimes[event.keyCode] <= 0) {
			onJustPress.dispatch(event.keyCode);
		}
		holdTimes[event.keyCode] += 1;
		onPress.dispatch(event.keyCode);
	}

	static function RELESE(event:KeyboardEvent) {
		holdTimes[event.keyCode] = 0;
		onRelsase.dispatch(event.keyCode);
	}

	public static function getKeyName(keyCode:Int) {
		@:privateAccess {
			var balls:Array<String> = Type.getClassFields(Keyboard);
			var map:Map<String, String> = [];

			for (name in balls) {
				map.set(Std.string(Reflect.getProperty(Keyboard, name)), name);
				trace(Std.string(Reflect.getProperty(Keyboard, name)));
			}
			trace(map);
			return map.get(Std.string(keyCode));
		}
	}
}