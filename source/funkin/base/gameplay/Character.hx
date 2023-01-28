package funkin.base.gameplay;

import lime.math.Vector2;
import flixel.math.FlxPoint;
import engine.scripting.Hscript;
import flixel.util.FlxTimer;
import flixel.math.FlxMath;
import flixel.FlxSprite;
import flixel.animation.FlxBaseAnimation;
import flixel.graphics.frames.FlxAtlasFrames;

using StringTools;

typedef CharacterAnimData = {
	var name:String;
	var nameinAtlas:String;
	var fps:Int;
	var looped:Bool;
	var offset:Array<Float>;
}

typedef CharacterData = {
	var flipX:Bool;
	var icon:String;
	var anims:Array<CharacterAnimData>;
	var healthColor:String;
}

class Character extends FlxSprite {
	public var animOffsets:Map<String, Array<Dynamic>>;
	public var canDance:Bool = true;
	public var isPlayer:Bool = false;
	public var curCharacter:String = 'bf';
	public var danceSteps:Array<String> = ["idle"];
	public var danceIndex:Int = 0;
	public var dances:Int = 0;
	public var holdTimer:Float = 0;
	public var singDur:Float = 4;
	public var script:Hscript = new Hscript();
	public var camOffset:Vector2 = new Vector2(-150, -150);

	public function new(x:Float, y:Float, ?character:String = "dad", ?isPlayer:Bool = false) {
		animOffsets = new Map<String, Array<Float>>();
		super(x, y);

		curCharacter = character;
		this.isPlayer = isPlayer;
		antialiasing = true;
		script.interp.scriptObject = this;
		script.loadScript('images/characters/$character/character');
		script.call("new");
		script.call("create");
		loadCharacter();
		if (isPlayer) {
			flipX = !flipX;

			// Doesn't flip for BF, since his are already in the right place???
			if (!curCharacter.startsWith('bf')) {
				// var animArray
				var oldRight = animation.getByName('singRIGHT').frames;
				animation.getByName('singRIGHT').frames = animation.getByName('singLEFT').frames;
				animation.getByName('singLEFT').frames = oldRight;

				// IF THEY HAVE MISS ANIMATIONS??
				if (animation.getByName('singRIGHTmiss') != null) {
					var oldMiss = animation.getByName('singRIGHTmiss').frames;
					animation.getByName('singRIGHTmiss').frames = animation.getByName('singLEFTmiss').frames;
					animation.getByName('singLEFTmiss').frames = oldMiss;
				}
			}
		}
	}

	override function update(elapsed:Float) {
		if (animation.curAnim == null)
			return;
		script.call('update', [elapsed]);

		if (animation.curAnim.name.startsWith('sing')) {
			holdTimer += elapsed;
		}
		if (holdTimer >= Conductor.stepCrochet * singDur * 0.001) {
			dance();
			holdTimer = 0;
		}

		super.update(elapsed);
	}

	/**
	 * idle bumping shit
	 */
	public function dance(force:Bool = false) {
		if (!canDance)
			return;
		script.call('onDance');
		script.call('dance');
		// danceIndex = FlxMath.wrap(danceIndex + 1, 0, danceSteps.length);
		playAnim('${danceSteps[danceIndex]}', force);
		danceIndex++;
		if (danceIndex >= danceSteps.length)
			danceIndex = 0;
	}

	public function playAnim(AnimName:String, Force:Bool = false, time:Float = 0, Reversed:Bool = false, Frame:Int = 0):Void {
		animation.play(AnimName, Force, Reversed, Frame);
		if (time > 0)
			canDance = false;
		new FlxTimer().start(time, function(tmr) {
			canDance = true;
		});

		var daOffset = animOffsets.get(animation.curAnim.name);
		if (animOffsets.exists(animation.curAnim.name)) {
			offset.set(daOffset[0], daOffset[1]);
		} else
			offset.set(0, 0);
	}

	public function loadCharacter() {
		var json:CharacterData = Assets.load(JSON, Paths.json('images/characters/${curCharacter}/character'));
		if (json == null)
			return;
		trace(json);
	}

	public function addOffset(name:String, x:Float = 0, y:Float = 0) {
		animOffsets[name] = [x, y];
	}
}
