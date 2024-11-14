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

#if android
import android.Permissions as AndroidPermissions;
import android.Settings as AndroidSettings;
import android.content.Context as AndroidContext;
import android.os.Build.VERSION as AndroidVersion;
import android.os.Build.VERSION_CODES as AndroidVersionCode;
import android.os.Environment as AndroidEnvironment;
#end
#if sys
import sys.FileSystem;
import sys.io.File;
#end

using StringTools;

/**
 * ...
 * @author Lily Ross (mcagabe19)
 */
class MobileUtil
{
	public static final rootDir:String = lime.system.System.applicationStorageDirectory;

	public static function getStorageDirectory(?force:Bool = false):String
	{
		var path:String = '';
		#if android
		if (!FileSystem.exists(rootDir + 'storagetype.txt'))
			File.saveContent(rootDir + 'storagetype.txt', "EXTERNAL_DATA");
		var curStorageType:String = File.getContent(rootDir + 'storagetype.txt');
		path = force ? StorageType.fromStrForce(curStorageType) : StorageType.fromStr(curStorageType);
		path = haxe.io.Path.addTrailingSlash(path);
		#elseif ios
		path = lime.system.System.documentsDirectory;
		#elseif sys
		path = Sys.getCwd();
		#end

		return path;
	}

    #if android
	public static function requestPermsFromUser():Void
	{
		if (AndroidVersion.SDK_INT >= AndroidVersionCode.TIRAMISU)
			AndroidPermissions.requestPermissions(['READ_MEDIA_IMAGES', 'READ_MEDIA_VIDEO', 'READ_MEDIA_AUDIO']);
		else
			AndroidPermissions.requestPermissions(['READ_EXTERNAL_STORAGE', 'WRITE_EXTERNAL_STORAGE']);

		if (!AndroidEnvironment.isExternalStorageManager())
		{
			if (AndroidVersion.SDK_INT >= AndroidVersionCode.S)
				AndroidSettings.requestSetting('REQUEST_MANAGE_MEDIA');
			AndroidSettings.requestSetting('MANAGE_APP_ALL_FILES_ACCESS_PERMISSION');
		}

		if ((AndroidVersion.SDK_INT >= AndroidVersionCode.TIRAMISU
			&& !AndroidPermissions.getGrantedPermissions().contains('android.permission.READ_MEDIA_IMAGES'))
			|| (AndroidVersion.SDK_INT < AndroidVersionCode.TIRAMISU
				&& !AndroidPermissions.getGrantedPermissions().contains('android.permission.READ_EXTERNAL_STORAGE')))
                Utils.showPopUp('If you accepted the permissions you are all good!' + '\nIf you didn\'t then expect a crash' + '\nPress OK to see what happens',
				'Notice!');

		try
		{
			if (!FileSystem.exists(MobileUtil.getStorageDirectory()))
				FileSystem.createDirectory(MobileUtil.getStorageDirectory());
		}
		catch (e:Dynamic)
		{
			Utils.showPopUp('Please create directory to\n' + MobileUtil.getStorageDirectory() + '\nPress OK to close the game', 'Error!');
		    Sys.exit(1);
		}
	}
	#end

	public static function readDirectory(directory:String):Array<String>
	{
		#if desktop
		return FileSystem.readDirectory(directory);
		#else
		var dirs:Array<String> = [];
		for(dir in openfl.Assets.list().filter(folder -> folder.startsWith(directory)))
		{
			if(openfl.Assets.exists(dir) && !dirs.contains(dir))
				dirs.push(dir);
		}
		return dirs.map(dir -> dir.substr(dir.lastIndexOf("/") + 1));
		#end
	}
}

#if android
@:runtimeValue
enum abstract StorageType(String) from String to String
{
	final forcedPath = '/storage/emulated/0/';
	final packageNameLocal = 'com.Rozebud.FPSPlus';
	final fileLocal = 'FunkinFPSPlus';

	var EXTERNAL_DATA = "EXTERNAL_DATA";
	var EXTERNAL_OBB = "EXTERNAL_OBB";
	var EXTERNAL_MEDIA = "EXTERNAL_MEDIA";
	var EXTERNAL = "EXTERNAL";

	public static function fromStr(str:String):StorageType
	{
		final EXTERNAL_DATA = AndroidContext.getExternalFilesDir();
		final EXTERNAL_OBB = AndroidContext.getObbDir();
		final EXTERNAL_MEDIA = AndroidEnvironment.getExternalStorageDirectory() + '/Android/media/' + lime.app.Application.current.meta.get('packageName');
		final EXTERNAL = AndroidEnvironment.getExternalStorageDirectory() + '/.' + lime.app.Application.current.meta.get('file');

		return switch (str)
		{
			case "EXTERNAL_OBB": EXTERNAL_OBB;
			case "EXTERNAL_MEDIA": EXTERNAL_MEDIA;
			case "EXTERNAL": EXTERNAL;
			default: EXTERNAL_DATA;
		}
	}

	public static function fromStrForce(str:String):StorageType
	{
		final EXTERNAL_DATA = forcedPath + 'Android/data/' + packageNameLocal + '/files';
		final EXTERNAL_OBB = forcedPath + 'Android/obb/' + packageNameLocal;
		final EXTERNAL_MEDIA = forcedPath + 'Android/media/' + packageNameLocal;
		final EXTERNAL = forcedPath + '.' + fileLocal;

		return switch (str)
		{
			case "EXTERNAL_OBB": EXTERNAL_OBB;
			case "EXTERNAL_MEDIA": EXTERNAL_MEDIA;
			case "EXTERNAL": EXTERNAL;
			default: EXTERNAL_DATA;
		}
	}
}
#end