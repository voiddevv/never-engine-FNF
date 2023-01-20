package;

import flixel.FlxSprite;

class HealthIcon extends FlxSprite
{
	public function new(char:String = 'bf', isPlayer:Bool = false)
	{
		super();
		loadGraphic(Assets.load(IMAGE,Paths.image('icons/$char')), true, 150, 150);

		antialiasing = true;
		animation.add('icon', [0, 1], 0, false,isPlayer);
		animation.play('icon');
		scrollFactor.set();
	}
}
