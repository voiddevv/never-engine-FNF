package funkin.states.menus;

import flixel.FlxG;
import flixel.system.FlxAssets.FlxShader;
import openfl.utils.ByteArray;
import openfl.display.Shader;
import flixel.text.FlxText;
import flixel.FlxSprite;
import haxe.io.Error;
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
	var songs:Array<String> = [];
	var freePlayData:FreePlayList = Assets.load(JSON, Paths.json("data/FreePlayList"));
	var curSong = 0;
	var curDiff = 0;
	var diffs:Array<String> = [];
	var diffText:FlxText;
	var funnibox:FlxSprite;
	override function create() {
		super.create();
		bg = new FNFSprite(0, 0, Assets.load(IMAGE, Paths.image('menuDesat')));
		add(bg);
		for (song in freePlayData.songs) {
			songs.push(song.name);
		}
		for (i in 0...songs.length) {
			var item = new Alphabet(0, 110 * i, songs[i], true);
			item.isMenuItem = true;
			item.targetY = i;
			item.ID = i;
			songGroup.add(item);
		}
		add(songGroup);
		changeSong();
		funnibox = new FlxSprite(FlxG.width - 300).makeGraphic(300, 100, 0x74000000);
		diffText = new FlxText(0, 0, 0, '< ${diffs[curDiff]} >', 18, true);
		diffText.setFormat(Paths.font('vcr.ttf'), 28, 0xFFFFFFFF, CENTER, OUTLINE, 0xFF000000);
		diffText.setPosition(funnibox.x + (funnibox.width - diffText.width) / 2, funnibox.y + 50);
		add(funnibox);
		add(diffText);
	}

	override function update(elapsed:Float) {
		super.update(elapsed);
		if (FlxG.keys.justPressed.DOWN)
			changeSong(1);
		if (FlxG.keys.justPressed.UP)
			changeSong(-1);
		if (FlxG.keys.justPressed.RIGHT)
			changeDiff(1);
		if (FlxG.keys.justPressed.LEFT)
			changeDiff(-1);
		if (FlxG.keys.justPressed.ENTER)
			seclect();
	}

	public function changeDiff(balls:Int) {
		curDiff = FlxMath.wrap(curDiff + balls, 0, diffs.length - 1);
		diffText.text = '< ${diffs[curDiff]} >';
		diffText.updateHitbox();
		diffText.setPosition(funnibox.x + (funnibox.width - diffText.width) / 2, funnibox.y + 50);
	}

	public function changeSong(ass:Int = 0) {
		curSong = FlxMath.wrap(curSong + ass, 0, songs.length - 1);
		diffs = freePlayData.songs[curSong].diffs;
		songGroup.forEach(function(song) {
			song.targetY = song.ID - curSong;
		});
	}

	public function seclect() {
		trace('LOADING SONG');
		try {
			var songName = songs[curSong];
			PlayState.SONG = Assets.load(JSON, Paths.json('data/$songName/${diffs[curDiff].toLowerCase()}')).song;
			FlxG.sound.music.stop();
			FlxG.switchState(new PlayState());
		} catch (e) {
			Log.error('ERROR FOUND WHILE LOADING SONG 😭');
		}
	}
}
