package;

import openfl.filters.GlowFilter;
import openfl.ui.Keyboard;
import openfl.events.KeyboardEvent;
import engine.FPS;
import flixel.FlxGame;
import openfl.display.Sprite;
using StringTools;
class Main extends Sprite
{
	public function new()
	{
		super();
		addChild(new FlxGame(0, 0, TitleState));

		#if !mobile
		addChild(new FPS(10, 3, 0xFFFFFF));
		#end
		FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN,onPress);
	}
	public function onPress(event:KeyboardEvent) {
		switch (event.keyCode){
			case Keyboard.F5:
				FlxG.resetState();
			case Keyboard.F1:
				if(MusicBeatState.stateName.endsWith('PlayState'))
					PlayState.CURRENT.UI.endsong();
		}
	}
}
