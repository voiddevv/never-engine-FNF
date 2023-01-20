package engine.utills;
class Paths {
    public static var CURRENT_MOD:String = "Funkin'";
    public static function getPath(path:String) {
        return 'mods/$CURRENT_MOD/$path';
    }
    public static function image(file:String) {
        return getPath('images/$file.png');
    }
    public static function sound(file:String) {
        return getPath('sounds/$file.ogg');
    }
    public static function music(file:String) {
        return getPath('music/$file.ogg');
    }
    public static function json(file:String) {
        return getPath('$file.json');
    }
    public static function xml(file:String) {
        return getPath('$file.xml');
    }
    public static function ini(file:String) {
        return getPath('$file.ini');
    }
    public static function getScript(file:String) {
        return getPath('$file.hx');
    }
    public static function getCharacter(name:String) {
        return image('characters/$name/character');
    }
    public static function inst(song:String) {
        song = song.toLowerCase();
        return getPath('songs/$song/Inst.ogg');
    }
    public static function voices(song:String) {
        song = song.toLowerCase();
        return getPath('songs/$song/Voices.ogg');
    }
    public static function font(path:String) {
        return getPath('fonts/$path');
    }


}