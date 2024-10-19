package;

#if sys
import sys.FileSystem;
import sys.io.File;
#end

using StringTools;
using flixel.util.FlxArrayUtil;

/**
 * Crash Handler.
 * @author YoshiCrafter29, Ne_Eo, MAJigsaw77 and Lily Ross (mcagabe19)
 */
class CrashHandler
{
	public static function init():Void
	{
		openfl.Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(openfl.events.UncaughtErrorEvent.UNCAUGHT_ERROR, onUncaughtError);
		#if cpp
		untyped __global__.__hxcpp_set_critical_error_handler(onError);
		#elseif hl
		hl.Api.setErrorHandler(onError);
		#end
	}

	#if (cpp || hl)
	private static function onError(message:Dynamic):Void
		__onError(message, true);
	#end

	private static function onUncaughtError(message:Dynamic):Void
		__onError(message);

	private static function __onError(message:Dynamic, ?isCritical:Bool = false):Void
	{
		final log:Array<String> = [];

		if (message != null && message.length > 0)
			log.push(message);

		log.push(haxe.CallStack.toString(haxe.CallStack.exceptionStack(true)));

		#if sys
		saveErrorMessage(log.join('\n'));
		#end

		Utils.showPopUp(log.join('\n'), (isCritical) ? "Critical Error!" : "Error!");
		lime.system.System.exit(1);
	}

	#if sys
	private static function saveErrorMessage(message:String):Void
	{
		try
		{
			if (!FileSystem.exists('logs'))
				FileSystem.createDirectory('logs');

			File.saveContent('logs/'
				+ Date.now().toString().replace(' ', '-').replace(':', "'")
				+ '.txt', message);
		}
		catch (e:haxe.Exception)
			trace('Couldn\'t save error message. (${e.message})');
	}
	#end
}
