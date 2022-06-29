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
        spawner = new Alarm(0.07, function() {
            var raindrop = new Raindrop(0, -10);
            raindrop.x = (HXP.width - raindrop.width) * Random.random;
            add(raindrop);
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
