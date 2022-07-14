package scenes;

import entities.*;
import haxepunk.*;
import haxepunk.graphics.*;
import haxepunk.graphics.text.*;
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
    public static inline var MIN_SPAWN_INTERVAL = 0.1;
    public static inline var MAX_SPAWN_INTERVAL = 0.75;

    public static var totalTime:Float = 0;
    public static var highScore:Float;
    public static var sfx:Map<String, Sfx> = null;

    private var player:Player;
    private var spawner:Alarm;
    private var scoreDisplay:Text;
    private var titleDisplay:Text;
    private var tutorialDisplay:Text;

    override public function begin() {
        Data.load("rain");
        totalTime = 0;
        highScore = Data.read("highscore", 0);
        trace('high score: $highScore');
        player = add(new Player(HXP.width / 2, HXP.height / 2));
        spawner = new Alarm(1, function() {
            var raindrop = new Raindrop(0, -10);
            raindrop.x = (HXP.width - raindrop.width) * Random.random;
            add(raindrop);
            spawner.reset(MathUtil.lerp(
                MAX_SPAWN_INTERVAL,
                MIN_SPAWN_INTERVAL,
                Math.min(Ease.quadOut(totalTime / 60), 1)
            ));
        }, TweenType.Looping);
        addTween(spawner);
        scoreDisplay = new Text("0", 0, 0, 180, 0, {align: TextAlignType.CENTER});
        scoreDisplay.alpha = 0;
        titleDisplay = new Text("Rain", 0, 60, 180, 0, {align: TextAlignType.CENTER});
        tutorialDisplay = new Text("Hold up key to fly", 0, 100, 180, 0, {align: TextAlignType.CENTER});
        for(display in [scoreDisplay, titleDisplay, tutorialDisplay]) {
            addGraphic(display);
        }

        if(sfx == null) {
            sfx = [
				"die" => new Sfx("audio/die.ogg"),
				"drone_high" => new Sfx("audio/drone_high.ogg"),
				"drone_low" => new Sfx("audio/drone_low.ogg"),
				"drop1" => new Sfx("audio/drop1.ogg"),
				"drop2" => new Sfx("audio/drop2.ogg"),
				"drop3" => new Sfx("audio/drop3.ogg"),
				"drop4" => new Sfx("audio/drop4.ogg"),
				"drop5" => new Sfx("audio/drop5.ogg"),
				"drop6" => new Sfx("audio/drop6.ogg"),
				"drop7" => new Sfx("audio/drop7.ogg"),
				"flight" => new Sfx("audio/flight.ogg"),
				"flight_off" => new Sfx("audio/flight_off.ogg"),
				"flight_on" => new Sfx("audio/flight_on.ogg"),
				"ping1" => new Sfx("audio/ping1.ogg"),
				"ping2" => new Sfx("audio/ping2.ogg"),
				"ping3" => new Sfx("audio/ping3.ogg"),
				"ping4" => new Sfx("audio/ping4.ogg"),
				"ping5" => new Sfx("audio/ping5.ogg"),
				"rain" => new Sfx("audio/rain.ogg")
            ];
        }
    }

    override public function update() {
        if(player.hasMoved) {
            scoreDisplay.text = '${timeRound(totalTime, 0)}';
            var oldTotalTime = totalTime;
            totalTime += HXP.elapsed;
            if(totalTime > highScore && oldTotalTime <= highScore && highScore != 0) {
                scoreDisplay.alpha = 1;
                sfx["ping1"].play(0.15);
            }
        }
        super.update();
    }

    public function onStart() {
        spawner.start();
        HXP.tween(scoreDisplay, {"alpha": highScore > 0 ? 0.5 : 1}, 0.5);
        for(display in [titleDisplay, tutorialDisplay]) {
            HXP.tween(display, {"alpha": 0}, 0.5);
        }
    }

    public function onDeath() {
        if(totalTime > highScore) {
            Data.write("highscore", totalTime);
            Data.save("rain");
        }
        HXP.scene = new GameScene();
    }

    private function timeRound(number:Float, precision:Int = 2) {
        number *= Math.pow(10, precision);
        return Math.round(number) / Math.pow(10, precision);
    }
}
