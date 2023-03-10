package funkin.states.menus;

import flixel.FlxG;
import flixel.effects.FlxFlicker;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.addons.ui.FlxUIInputText;
import flixel.addons.display.FlxStarField.FlxStarField2D;
import flixel.math.FlxMath;
import flixel.group.FlxSpriteGroup;
import flixel.FlxSprite;

class MainMenu extends MusicBeatState {
	var bg:FlxSprite;
	var menuGroup:FlxSpriteGroup;
	var items:Array<String> = ['story mode', "freeplay", 'options'];
	var curItem = 0;

	override function create() {
		super.create();

		bg = new FNFSprite(0, 0).loadGraphic(Assets.load(IMAGE, Paths.image("menuBG")));
		add(bg);
		menuGroup = new FlxSpriteGroup();
		for (item in 0...items.length) {
			var newItem = new FlxSprite(0, 0);
			newItem.frames = Assets.load(SPARROW, Paths.image('MainMenu/${items[item]}'));
			newItem.animation.addByPrefix('idle', '${items[item]} basic');
			newItem.animation.addByPrefix('selected', '${items[item]} white');
			newItem.animation.play('idle', true);
			newItem.ID = item;
			newItem.updateHitbox();
			newItem.y = 160 * item;
			newItem.screenCenter(X);
			menuGroup.add(newItem);
		}
		menuGroup.y += 80;
		add(menuGroup);
		changeOption();
		if (!FlxG.sound.music.playing) {
			FlxG.sound.music.kill();
			FlxG.sound.playMusic(Assets.load(SOUND, Paths.music('freakyMenu')));
		}
	}

	override function update(elapsed:Float) {
		super.update(elapsed);
		if (FlxG.keys.justPressed.DOWN)
			changeOption(1);
		if (FlxG.keys.justPressed.UP)
			changeOption(-1);
		if (FlxG.keys.justPressed.ENTER)
			selectItem();
	}

	public function changeOption(sex:Int = 0) {
		curItem = FlxMath.wrap(curItem + sex, 0, items.length - 1);
		menuGroup.forEach(function(item) {
			item.animation.play('idle');
			item.updateHitbox();
			item.screenCenter(X);
		});

		menuGroup.members[curItem].animation.play('selected');
		menuGroup.members[curItem].updateHitbox();
		menuGroup.members[curItem].screenCenter(X);
	}

	public function selectItem() {
		menuGroup.forEach(function(item) {
			if (item.ID != curItem)
				FlxTween.tween(item, {alpha: 0}, 1);
			else
				FlxFlicker.flicker(item, 1.4, 0.06, true, true, function(w) {
					switch (items[curItem]) {
						// working on story mode
						case "story mode":
							FlxG.switchState(new StoryMenuState());
						case 'freeplay':
							FlxG.switchState(new FreePlay());
					}
				});
		});
	}
}
