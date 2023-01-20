package;

import engine.FPS;
import flixel.FlxGame;
import openfl.display.Sprite;

class Main extends Sprite
{
	public function new()
	{
		super();
		addChild(new FlxGame(0, 0, TitleState));
		FlxG.fixedTimestep = false;

		#if !mobile
		addChild(new FPS(10, 3, 0xFFFFFF));
		#end
	}
}
