package funkin.base.gameplay;

import engine.scripting.Hscript;
import flixel.group.FlxSpriteGroup;

class Stage extends FlxSpriteGroup {
    var foreGround = new FlxSpriteGroup();
    public var script:Hscript = new Hscript();
    public function new(stage:String = "stage") {
        super();
        script.interp.scriptObject = this;
        script.loadScript('stages/$stage');
        script.call("new");
        script.call("create");
    }
}