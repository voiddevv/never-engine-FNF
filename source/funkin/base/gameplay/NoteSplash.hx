package funkin.base.gameplay;

class NoteSplash extends FNFSprite {
    public function new(direction:Int) {
        var colors:Array<String> = ["purple","blue","green","red"];
        super(0,0);
        alpha = 0.6;
        frames = Assets.load(SPARROW,Paths.image("ui/noteSplashes"));
        animation.addByPrefix("splash",'note impact ${FlxG.random.int(1,2)} ${colors[direction]}',24,false);
        setPosition(PlayState.CURRENT.UI.playerStrum.members[direction].x -75,-50);
        animation.play('splash');
        animation.finishCallback = function (name:String) {
            kill();
        }
    }
}