package engine.utills;

import openfl.system.System;
class Mem {
    public static function clearAll() {
        Assets.cache.clear();
        lime.utils.Assets.cache.clear();
        openfl.utils.Assets.cache.clear();
        FlxG.bitmap.dumpCache();
        FlxG.bitmap.clearCache();
        System.gc();
    }
}