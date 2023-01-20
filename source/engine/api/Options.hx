package engine.api;

class Options
{
	// default shit
	static var DGAMEPLAY:Map<String, Dynamic> = ["FRAMERATE" => 360, "DOWNSCROLL" => false, "BOTPLAY" => false];
	static var DKEYBINDS:Map<String, String> = ["LEFT" => "A", "DOWN" => "S", "UP" => "K", "RIGHT" => "L"];
	public static var GAMEPLAY:Map<String, Dynamic> = DGAMEPLAY;
	public static var KEYBINDS:Map<String, String> = DKEYBINDS;
	

	public static function resetOptions()
	{
		FlxG.save.data.GAMEPLAY = DGAMEPLAY;
		FlxG.save.data.KEYBINDS = DKEYBINDS;
		FlxG.save.flush();
	}

	public static function init()
	{
		GAMEPLAY = FlxG.save.data.GAMEPLAY;
		KEYBINDS = FlxG.save.data.KEYBINDS;
	}
}
