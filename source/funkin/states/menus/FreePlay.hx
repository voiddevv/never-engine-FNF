package funkin.states.menus;
import flixel.math.FlxMath;
import flixel.group.FlxSpriteGroup;

typedef FreePlayList = {
	var songs:Array<SongListData>;
}

typedef SongListData = {
	var name:String;
	var icon:String;
	var bpm:String;
	var diffs:Array<String>;
}

class FreePlay extends MusicBeatState {
	var bg:FNFSprite;
	var songGroup:FlxTypedSpriteGroup<Alphabet> = new FlxTypedSpriteGroup();
	var songs:Array<String> = ["fresh", 'dadbattle'];
	var curSong = 0;
	var curDiff = "hard";

	override function create() {
		super.create();
		bg = new FNFSprite(0, 0, Assets.load(IMAGE, Paths.image('menuDesat')));
		add(bg);
		for (i in 0...songs.length) {
			var item = new Alphabet(0, 110 * i, songs[i], true);
			item.isMenuItem = true;
			item.targetY = i;
			item.ID = i;
			songGroup.add(item);
		}
		add(songGroup);
	}

	override function update(elapsed:Float) {
		super.update(elapsed);
		if (FlxG.keys.justPressed.DOWN)
			changeSong(1);
		if (FlxG.keys.justPressed.UP)
			changeSong(-1);
        if (FlxG.keys.justPressed.ENTER)
            seclect();
	}

	public function changeSong(ass:Int = 0) {
		curSong = FlxMath.wrap(curSong + 1, 0, songs.length - 1);
		songGroup.forEach(function(song) {
			song.targetY = song.ID - curSong;
		});
	}
    public function seclect() {
        var songName = songs[curSong];
        FlxG.sound.music.stop();
        PlayState.SONG = Assets.load(JSON,Paths.json('data/$songName/hard')).song;
        FlxG.switchState(new PlayState());
    }
}
