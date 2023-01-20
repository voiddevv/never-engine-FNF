package engine;

import openfl.events.Event;
import openfl.events.KeyboardEvent;
import flixel.util.FlxSignal.FlxTypedSignal;
class Controls
{
	public static var onPress:FlxTypedSignal<Int->Void> = new FlxTypedSignal();
	public static var onRelsase:FlxTypedSignal<Int->Void> = new FlxTypedSignal();
	public static var onJustPress:FlxTypedSignal<Int->Void> = new FlxTypedSignal();

	public function init()
	{
		FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, press);
		FlxG.stage.addEventListener(KeyboardEvent.KEY_UP, justrelsese);
	}

	function press(event:KeyboardEvent)
	{
		onPress.dispatch(event.keyCode);
	}

	function justPress()
	{
	}

	function justrelsese(event:KeyboardEvent)
	{
        onRelsase.dispatch(event.keyCode);
	}
}
