package funkin.base.gameplay;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
class Strum extends FlxTypedSpriteGroup<FNFSprite> {
    public function new(keys:Int = 4) {
        super();
        for(i in 0...keys){
            var dirs:Array<String> = ["LEFT","DOWN","UP","RIGHT"];
            var key = new FNFSprite();
            key.frames = Assets.load(SPARROW,Paths.image('NOTE_assets'));
            key.animation.addByPrefix("idle",'arrow${dirs[i]}');
            key.animation.addByPrefix("pressed",'${dirs[i].toLowerCase()} press',24,false);
            key.animation.addByPrefix("confirm",'${dirs[i].toLowerCase()} confirm',24,false);
            key.setOffset('confirm',60,60);
            key.animation.play('idle',true);
            key.ID = i;
            key.scale.set(0.7,0.7);
            key.updateHitbox();
            key.antialiasing = true;
            add(key);
            key.x = 110*i;
        }
    }
}