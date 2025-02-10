package extensions.openfl.display;

import flixel.FlxG;
import openfl.text.TextField;
import openfl.text.TextFormat;
import openfl.system.System;

/**
	The FPS class provides an easy-to-use monitor to display
	the current frame rate of an OpenFL project
**/
class FPSExt extends TextField
{
	/**
		The current frame rate, expressed using frames-per-second
	**/
	public var currentFPS(default, null):Int;

	/**
		The current memory usage (WARNING: this is NOT your total program memory usage, rather it shows the garbage collector memory)
	**/
	public var memoryMegas(get, never):Float;

	@:noCompletion private var times:Array<Float>;

	public function new(x:Float = 10, y:Float = 10, color:Int = 0x000000)
	{
		super();

		positionFPS(x, y);

		currentFPS = 0;
		selectable = false;
		mouseEnabled = false;
		defaultTextFormat = new TextFormat("_sans", 14, color);
		autoSize = LEFT;
		multiline = true;
		textColor = 0xFFFFFFFF;
		text = "FPS: ";

		times = [];
	}

	var deltaTimeout:Float = 0.0;

	// Event Handlers
	private override function __enterFrame(deltaTime:Float):Void{

		final now:Float = haxe.Timer.stamp() * 1000;
		times.push(now);
		while (times[0] < now - 1000){ times.shift(); }

		deltaTimeout += deltaTime;
		if (deltaTimeout >= 16) {
			currentFPS = times.length;
			updateText();
			deltaTimeout = 0.0;
			return;
		}

	}

	public dynamic function updateText():Void { // so people can override it in hscript
		text = 'FPS: ${currentFPS}'
		+ '\nMemory: ${flixel.util.FlxStringUtil.formatBytes(memoryMegas)}';
	}

	inline function get_memoryMegas():Float
		return #if cpp cpp.vm.Gc.memInfo64(cpp.vm.Gc.MEM_INFO_USAGE) #else cast(System.totalMemory, UInt) #end;

	public inline function positionFPS(X:Float, Y:Float, ?scale:Float = 1){
		scaleX = scaleY = #if android (scale > 1 ? scale : 1) #else (scale < 1 ? scale : 1) #end;
		x = #if mobile FlxG.game?.x + #end X;
		y = #if mobile FlxG.game?.y + #end Y;
	}
}
