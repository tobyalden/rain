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

    public var curtain(default, null):Curtain;
    private var player:Player;
    private var spawner:Alarm;
    private var scoreDisplay:Text;
    private var titleDisplay:Text;
    private var tutorialDisplay:Text;
    private var replayPrompt:Text;
    private var colorChanger:ColorTween;
    private var canReset:Bool;
    private var clouds:Backdrop;
    private var cloudsTwo:Backdrop;
    private var lowDroneStarter:Alarm;
    private var highDroneStarter:Alarm;

    override public function begin() {
        Data.load("rain");
        totalTime = 0;
        highScore = Data.read("highscore", 0);

        curtain = add(new Curtain());
        curtain.fadeOut(0.25);

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
        scoreDisplay = new Text("0", 0, 0, 180, 0);
        scoreDisplay.alpha = 0;
        titleDisplay = new Text("RAIN", 0, 60, 180, 0, {align: TextAlignType.CENTER});
        tutorialDisplay = new Text("hold up to fly", 0, 103, 180, 0, {align: TextAlignType.CENTER, size: 12});
        for(display in [scoreDisplay, titleDisplay, tutorialDisplay]) {
            addGraphic(display);
        }

        replayPrompt = new Text("NEW RECORD");
        replayPrompt.x = 10;
        replayPrompt.y = HXP.height - replayPrompt.textHeight - 10;
        replayPrompt.alpha = 0;
        addGraphic(replayPrompt, -10);

        colorChanger = new ColorTween(TweenType.PingPong);
        colorChanger.tween(0.25, 0xFF2000, 0xFFFB6E, Ease.sineInOut);
        addTween(colorChanger, true);

        canReset = false;

        clouds = new Backdrop("graphics/clouds.png");
        clouds.alpha = 0.25;
        addGraphic(clouds, 5);

        cloudsTwo = new Backdrop("graphics/clouds.png");
        cloudsTwo.alpha = 0.2;
        addGraphic(cloudsTwo, 4);

        addGraphic(new Image("graphics/background.png"), 10);

        if(sfx == null) {
            sfx = [
				"drone_high" => new Sfx("audio/drone_high.ogg"),
				"drone_low" => new Sfx("audio/drone_low.ogg"),
				"drop1" => new Sfx("audio/drop1.ogg"),
				"drop2" => new Sfx("audio/drop2.ogg"),
				"drop3" => new Sfx("audio/drop3.ogg"),
				"drop4" => new Sfx("audio/drop4.ogg"),
				"drop5" => new Sfx("audio/drop5.ogg"),
				"drop6" => new Sfx("audio/drop6.ogg"),
				"drop7" => new Sfx("audio/drop7.ogg"),
				"ping1" => new Sfx("audio/ping1.ogg"),
				"ping2" => new Sfx("audio/ping2.ogg"),
				"ping3" => new Sfx("audio/ping3.ogg"),
				"ping4" => new Sfx("audio/ping4.ogg"),
				"ping5" => new Sfx("audio/ping5.ogg"),
				"rain" => new Sfx("audio/rain.ogg"),
				"recordset" => new Sfx("audio/recordset.ogg")
            ];
        }
    }

    override public function update() {
        if(player.isDead) {
            if(Input.pressed("reset") && canReset) {
                reset();
            }
            if(totalTime > highScore) {
                replayPrompt.text = "NEW RECORD";
                replayPrompt.color = colorChanger.color;
            }
            else {
                replayPrompt.text = 'RECORD: ${timeRound(highScore, 2)}';
            }
        }
        else if(player.hasMoved) {
            var oldTotalTime = totalTime;
            totalTime += HXP.elapsed;
            if(totalTime > highScore && oldTotalTime <= highScore && highScore != 0) {
                scoreDisplay.alpha = 1;
                sfx["recordset"].play(0.75);
            }
            scoreDisplay.text = '${timeRound(totalTime, 0)}';
            scoreDisplay.x = HXP.width / 2 - scoreDisplay.textWidth / 2;
        }

        clouds.y += HXP.elapsed * 100;
        cloudsTwo.y += HXP.elapsed * 150;

        super.update();
    }

    public function onStart() {
        spawner.start();
        HXP.tween(scoreDisplay, {"alpha": highScore > 0 ? 0.5 : 1}, 0.5);
        for(display in [titleDisplay, tutorialDisplay]) {
            HXP.tween(display, {"alpha": 0}, 0.5);
        }
        HXP.alarm(0.1, function() {
            for(sfxName in ["rain", "drone_low", "drone_high"]) {
                sfx[sfxName].loop(0);
            }
            HXP.tween(sfx["rain"], {"volume": 0.5}, 2, Ease.sineInOut);
        });
        lowDroneStarter = HXP.alarm(20, function() {
            HXP.tween(sfx["drone_low"], {"volume": 0.33}, 40, Ease.sineIn);
        });
        highDroneStarter = HXP.alarm(40, function() {
            HXP.tween(sfx["drone_high"], {"volume": 0.33}, 40, Ease.sineIn);
        });
    }

    public function onDeath() {
        for(sfxName in ["rain", "drone_low", "drone_high"]) {
            sfx[sfxName].stop();
            lowDroneStarter.active = false;
            highDroneStarter.active = false;
        }
        spawner.active = false;
        HXP.tween(scoreDisplay, {"y": HXP.height / 2 - scoreDisplay.height / 2, "alpha": 1}, 1.5, {ease: Ease.sineInOut, complete: function() {
            scoreDisplay.text = '${timeRound(totalTime, 2)}\n  SECONDS';
            if(totalTime > highScore) {
                replayPrompt.alpha = 1;
                sfx["ping2"].play();
                HXP.alarm(0.25, function() {
                    canReset = true;
                });
            }
            else {
                sfx["ping3"].play();
                HXP.tween(
                    replayPrompt,
                    { "alpha": 1 },
                    0.25,
                    {ease: Ease.sineInOut, complete: function() {
                        canReset = true;
                    }}
                );
            }
        }});
        if(totalTime > highScore) {
            Data.write("highscore", totalTime);
            Data.save("rain");
        }
    }

    public function reset() {
        canReset = false;
        curtain.fadeIn(0.25);
        sfx["ping5"].play();
        HXP.alarm(0.25, function() {
            HXP.scene = new GameScene();
        });
    }

    private function timeRound(number:Float, precision:Int = 2) {
        number *= Math.pow(10, precision);
        return Math.floor(number) / Math.pow(10, precision);
    }
}
