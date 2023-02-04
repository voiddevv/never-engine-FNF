package engine.utills;

import flixel.FlxG;

class Mem {
    public static function clearAll():Void {
        Assets.cache.clear();
        lime.utils.Assets.cache.clear();
        openfl.utils.Assets.cache.clear();
        FlxG.bitmap.dumpCache();
        FlxG.bitmap.clearCache();
        openfl.system.System.gc();
    }
}