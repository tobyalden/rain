package scenes;

import entities.*;
import haxepunk.*;
import haxepunk.graphics.*;
import haxepunk.graphics.tile.*;
import haxepunk.input.*;
import haxepunk.masks.*;
import haxepunk.math.*;
import haxepunk.Tween;
import haxepunk.tweens.misc.*;
import haxepunk.utils.*;
import openfl.Assets;

class GameScene extends Scene
{
    private var player:Player;
    private var spawner:Alarm;

    override public function begin() {
        player = add(new Player(HXP.width / 2, HXP.height / 2));
        spawner = new Alarm(0.1, function() {
            var raindrop = new Raindrop(0, -10);
            raindrop.x = (HXP.width - raindrop.width) * Random.random;
            add(raindrop);
            //var aimdrop = new Raindrop(0, -10);
            //aimdrop.x = (HXP.width - aimdrop.width) * Random.random;
            //aimdrop.velocity = new Vector2(player.centerX - aimdrop.centerX, player.centerY - aimdrop.centerY);
            //aimdrop.velocity.normalize(MathUtil.lerp(Raindrop.MIN_SPEED, Raindrop.MAX_SPEED, Random.random));
            //aimdrop.sprite.angle = aimdrop.velocity.x;
            //add(aimdrop);
        }, TweenType.Looping);
        addTween(spawner, true);
    }

    override public function update() {
        super.update();
    }

    public function onDeath() {
        HXP.scene = new GameScene();
    }
}
