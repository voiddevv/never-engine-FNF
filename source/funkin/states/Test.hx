package funkin.states;

import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxButton;

class Test extends MusicBeatState {
    var buttin:FlxButton;
    var tweening:Bool = false;
    override function create() {
        super.create();
       buttin = new FlxButton(0,0,"test",function () {
        if(tweening)
            return;
        // tweening = true;
        FlxTween.tween(FlxG.camera,{angle: FlxG.camera.angle + 90},1/30);
       });
       add(buttin);
       FlxG.stage.opaqueBackground = 0xFFD000;
       FlxG.camera.zoom = 2;
       FlxG.mouse.visible = true;
       buttin.screenCenter();
    }
}