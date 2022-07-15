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

    public var hasMoved(default, null):Bool;
    public var isDead(default, null):Bool;
    private var sprite:Image;
    private var velocity:Vector2;

    public function new(x:Float, y:Float) {
        super(x, y);
        mask = new Hitbox(5, 10);
        sprite = new Image("graphics/player.png");
        sprite.centerOrigin();
        sprite.x += width / 2;
        sprite.y += height / 2;
        graphic = sprite;
        velocity = new Vector2();
        hasMoved = false;
        isDead = false;
    }

    override public function update() {
        if(isDead) {
            return;
        }

        if(Input.check("up")) {
            velocity.y -= BOOST_POWER * HXP.elapsed;

            if(!hasMoved) {
                cast(HXP.scene, GameScene).onStart();
                hasMoved = true;
            }
        }

        if(!hasMoved) {
            return;
        }

        velocity.y += GRAVITY * HXP.elapsed;
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

        velocity.x = MathUtil.clamp(velocity.x, -MAX_SPEED, MAX_SPEED);
        velocity.y = MathUtil.clamp(velocity.y, -MAX_SPEED, MAX_FALL_SPEED);

        moveBy(velocity.x * HXP.elapsed, velocity.y * HXP.elapsed);
        if(collide("hazard", x, y) != null) {
            die(false);
        }
        if(x < -width || x > HXP.width || y < -height || y > HXP.height) {
            die(true);
        }

        if(Input.check("up")) {
            var particleVelocity = new Vector2(0.5 - Math.random(), 1);
            particleVelocity.normalize(0.1);
            var particle = new Particle(
                centerX,
                bottom - 2,
                particleVelocity,
                MathUtil.lerp(0.5, 1, Math.random()),
                MathUtil.lerp(0.5, 1, Math.random())
            );
            HXP.scene.add(particle);
        }

        super.update();
    }

    public function die(quiet:Bool) {
        isDead = true;
        visible = false;
        if(!quiet) {
            explode();
            //sfx["die"].play(0.5);
        }
        cast(HXP.scene, GameScene).onDeath();
    }

    private function explode() {
        var numExplosions = 50;
        var directions = new Array<Vector2>();
        for(i in 0...numExplosions) {
            var angle = (2/numExplosions) * i;
            directions.push(new Vector2(Math.cos(angle), Math.sin(angle)));
            directions.push(new Vector2(-Math.cos(angle), Math.sin(angle)));
            directions.push(new Vector2(Math.cos(angle), -Math.sin(angle)));
            directions.push(new Vector2(-Math.cos(angle), -Math.sin(angle)));
        }
        var count = 0;
        for(direction in directions) {
            direction.scale(0.8 * Math.random());
            direction.normalize(
                Math.max(0.1 + 0.2 * Math.random(), direction.length)
            );
            var explosion = new Particle(
                centerX, centerY, directions[count], 1, 1
            );
            explosion.layer = -99;
            HXP.scene.add(explosion);
            count++;
        }

#if desktop
        Sys.sleep(0.02);
#end
        HXP.scene.camera.shake(1, 4);
    }
}
