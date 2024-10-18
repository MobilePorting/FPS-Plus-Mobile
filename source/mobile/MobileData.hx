package mobile;

import haxe.ds.Map;
import haxe.Json;
import haxe.io.Path;
import openfl.utils.Assets;
import flixel.util.FlxSave;

/**
 * ...
 * @author: Karim Akra
 */
class MobileData
{
	public static var actionModes:Map<String, TouchButtonsData> = new Map();
	public static var dpadModes:Map<String, TouchButtonsData> = new Map();

	public static var save:FlxSave;

	public static function init()
	{
		save = new FlxSave();
		save.bind('MobileControls', "Rozebud/FunkinFPSPlus");

		readDirectory('assets/mobile/DPadModes', dpadModes);
		readDirectory('assets/mobile/ActionModes', actionModes);
	}

	public static function setButtonsColors(buttonsInstance:Dynamic):Dynamic
	{
		buttonsInstance.buttonLeft.color = 0xFFC24B99;
		buttonsInstance.buttonDown.color = 0xFF00FFFF;
		buttonsInstance.buttonUp.color = 0xFF12FA05;
		buttonsInstance.buttonRight.color = 0xFFFF884E;

		return buttonsInstance;
	}

	public static function readDirectory(folder:String, map:Dynamic)
	{
		folder = folder.contains(':') ? folder.split(':')[1] : folder;

		if (FileSystem.exists(folder))
		for (file in FileSystem.readDirectory(folder))
		{
			var fileWithNoLib:String = file.contains(':') ? file.split(':')[1] : file;
			if (Path.extension(fileWithNoLib) == 'json')
			{
				file = Path.join([folder, Path.withoutDirectory(file)]);
				var str = File.getContent(file);
				var json:TouchButtonsData = cast Json.parse(str);
				var mapKey:String = Path.withoutDirectory(Path.withoutExtension(fileWithNoLib));
				map.set(mapKey, json);
			}
		}
	}
}

typedef TouchButtonsData =
{
	buttons:Array<ButtonsData>
}

typedef ButtonsData =
{
	button:String, // what TouchButton should be used, must be a valid TouchButton var from TouchPad as a string.
	graphic:String, // the graphic of the button, usually can be located in the TouchPad xml .
	x:Float, // the button's X position on screen.
	y:Float, // the button's Y position on screen.
	color:String // the button color, default color is white.
}
