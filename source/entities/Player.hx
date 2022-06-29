package entities;

import haxepunk.*;
import haxepunk.graphics.*;
import haxepunk.input.*;
import haxepunk.masks.*;
import haxepunk.math.*;
import haxepunk.Tween;
import haxepunk.tweens.misc.*;
import scenes.*;

class Player extends Entity
{
    public static inline var ACCEL = 1200;
    public static inline var MAX_SPEED = 100;
    public static inline var MAX_FALL_SPEED = 80;
    public static inline var BOOST_POWER = 500;
    public static inline var GRAVITY = 300;

    private var sprite:Image;
    private var velocity:Vector2;

    public function new(x:Float, y:Float) {
        super(x, y);
        mask = new Hitbox(1, 2);
        sprite = new Image("graphics/player.png");
        sprite.centerOrigin();
        sprite.x += width / 2;
        sprite.y += height / 2;
        graphic = sprite;
        velocity = new Vector2();
    }

    override public function update() {
        var angleTarget = 0;
        if(Input.check("left")) {
            velocity.x -= ACCEL * HXP.elapsed;
            angleTarget = 25;
        }
        else if(Input.check("right")) {
            velocity.x += ACCEL * HXP.elapsed;
            angleTarget = -25;
        }
        else {
            velocity.x = MathUtil.approach(velocity.x, 0, ACCEL * HXP.elapsed);
        }

        sprite.angle = MathUtil.approach(sprite.angle, angleTarget, HXP.elapsed * 200);

        //if(Input.check("up")) {
            //velocity.y -= ACCEL * HXP.elapsed;
        //}
        //else if(Input.check("down")) {
            //velocity.y += ACCEL * HXP.elapsed;
        //}
        //else {
            //velocity.y = MathUtil.approach(velocity.y, 0, ACCEL * HXP.elapsed);
        //}
        velocity.x = MathUtil.clamp(velocity.x, -MAX_SPEED, MAX_SPEED);
        velocity.y = MathUtil.clamp(velocity.y, -MAX_SPEED, MAX_FALL_SPEED);
        //if(velocity.length > MAX_SPEED) {
            //velocity.normalize(MAX_SPEED);
        //}

        if(Input.check("up")) {
            velocity.y -= BOOST_POWER * HXP.elapsed;
        }
        velocity.y += GRAVITY * HXP.elapsed;
        moveBy(velocity.x * HXP.elapsed, velocity.y * HXP.elapsed);
        x = MathUtil.clamp(x, 0, HXP.width - width);
        y = MathUtil.clamp(y, 0, HXP.height - height);
        if(collide("hazard", x, y) != null) {
            die();
        }
        super.update();
    }

    public function die() {
        cast(HXP.scene, GameScene).onDeath();
    }
}
