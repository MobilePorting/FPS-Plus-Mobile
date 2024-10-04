package;

import flixel.system.scaleModes.RatioScaleMode;
import flixel.FlxG;
import flixel.FlxGame;
import openfl.display.FPS;
import openfl.display.Sprite;
import debug.*;

class Main extends Sprite
{

	public static var fpsDisplay:FPS;

	public static var novid:Bool = false;
	public static var flippymode:Bool = false;

	public function new()
	{
		super();

		#if (sys && !mobile)
		novid = Sys.args().contains("-novid");
		flippymode = Sys.args().contains("-flippymode");
		#end

		SaveManager.global();

		fpsDisplay = new FPS(10, 3, 0xFFFFFF);
		fpsDisplay.visible = true;

		addChild(new FlxGame(#if mobile 1280, 720 #else 0, 0 #end, Startup, 60, 60, true));
		addChild(fpsDisplay);

		//On web builds, video tends to lag quite a bit, so this just helps it run a bit faster.
		#if web
		VideoHandler.MAX_FPS = 30;
		#end

		#if mobile
		#if android FlxG.android.preventDefaultKeys = [BACK]; #end

		FlxG.signals.gameResized.add(function (w, h) {
			if(fpsDisplay != null)
				fpsDisplay.positionFPS(10, 3, Math.min(w / FlxG.width, h / FlxG.height));
		}
		#end

		#if (sys && !mobile)
		trace("-=Args=-");
		trace("novid: " + novid);
		trace("flippymode: " + flippymode);
		#end
	}
}
