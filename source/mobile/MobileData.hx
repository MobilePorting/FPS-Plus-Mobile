/*
 * Copyright (C) 2024 Mobile Porting Team
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <https://www.gnu.org/licenses/>.
 */

package mobile;

import haxe.ds.Map;
import haxe.Json;
import haxe.io.Path;
import openfl.utils.Assets;
import flixel.util.FlxSave;
import sys.io.File;
import sys.FileSystem;

using StringTools;

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
		buttonsInstance.buttonLeft.color = 0xC24B99;
		buttonsInstance.buttonDown.color = 0x00FFFF;
		buttonsInstance.buttonUp.color = 0x12FA05;
		buttonsInstance.buttonRight.color = 0xF9393F;

		return buttonsInstance;
	}

	public static function readDirectory(folder:String, map:Dynamic)
	{
		for (file in MobileUtil.readDirectory(folder))
		{
			if (Path.extension(file) == 'json')
			{
				file = Path.join([folder, Path.withoutDirectory(file)]);
				var str = Assets.getText(file);
				var json:TouchButtonsData = cast Json.parse(str);
				var mapKey:String = Path.withoutDirectory(Path.withoutExtension(file));
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
