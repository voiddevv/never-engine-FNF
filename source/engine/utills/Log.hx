package engine.utills;

import haxe.macro.Type.ClassType;
import hscript.Checker.CClass;

class Log {
	public static function print(data:Dynamic) {
		Console.print(data);
	}

	public static function error(data:Dynamic) {
		Console.error('🟥: ' + data);
    }

	public static function warn(data:Dynamic) {
        Console.warn('🟨: ' + data);

    }
}
