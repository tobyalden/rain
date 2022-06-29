package entities;

import haxepunk.*;
import haxepunk.graphics.*;
import haxepunk.input.*;
import haxepunk.masks.*;
import haxepunk.math.*;
import haxepunk.Tween;
import haxepunk.tweens.misc.*;
import scenes.*;

class Raindrop extends Entity
{
    public static inline var MIN_SPEED = 75;
    public static inline var MAX_SPEED = 125;

    public var sprite:Image;
    public var velocity:Vector2;

    public function new(x:Float, y:Float) {
        super(x, y);
        type = "hazard";
        mask = new Hitbox(5, 10);
        sprite = new Image("graphics/raindrop.png");
        graphic = sprite;
        velocity = new Vector2(HXP.choose(0, 0, -10, 10, -20, 20), MathUtil.lerp(MIN_SPEED, MAX_SPEED, Random.random));
        sprite.angle = velocity.x;
    }

    override public function update() {
        moveBy(
            velocity.x * HXP.elapsed, velocity.y * HXP.elapsed, ["walls"]
        );
        super.update();
    }
}

