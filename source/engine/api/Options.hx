package engine.api;

import flixel.FlxG;

class Options
{
	// default shit
	static var _GAMEPLAY:Map<String, Dynamic> = ["FRAMERATE" => 1000, "DOWNSCROLL" => false, "BOTPLAY" => false];
	static var _KEYBINDS:Map<String, String> = ["LEFT" => "A", "DOWN" => "S", "UP" => "K", "RIGHT" => "L"];
	public static var GAMEPLAY:Map<String, Dynamic> = _GAMEPLAY;
	public static var KEYBINDS:Map<String, String> = _KEYBINDS;
	

	public static function resetOptions():Void
	{
		FlxG.save.data.GAMEPLAY = _GAMEPLAY;
		FlxG.save.data.KEYBINDS = _KEYBINDS;
		FlxG.save.flush();
	}

	public static function init():Void
	{
		GAMEPLAY = FlxG.save.data.GAMEPLAY;
		KEYBINDS = FlxG.save.data.KEYBINDS;
	}
}
