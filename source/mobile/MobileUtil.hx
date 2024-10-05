package mobile;

#if android
import android.Permissions as AndroidPermissions;
import android.Settings as AndroidSettings;
import android.Tools as AndroidTools;
import android.content.Context as AndroidContext;
import android.os.Build.VERSION as AndroidVersion;
import android.os.Build.VERSION_CODES as AndroidVersionCode;
import android.os.Environment as AndroidEnvironment;
#end
#if sys
import sys.FileSystem;
#end

/**
 * ...
 * @author Lily Ross (mcagabe19)
 */
class MobileUtil
{
	public static function getStorageDirectory():String
	{
		var path:String = '';
		#if android
		path = AndroidVersion.SDK_INT > AndroidVersionCode.R ? AndroidContext.getObbDir() : AndroidContext.getExternalFilesDir();
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
                showPopUp('If you accepted the permissions you are all good!' + '\nIf you didn\'t then expect a crash' + '\nPress OK to see what happens',
				'Notice!');

		try
		{
			if (!FileSystem.exists(MobileUtil.getStorageDirectory()))
				FileSystem.createDirectory(MobileUtil.getStorageDirectory());
		}
		catch (e:Dynamic)
		{
			showPopUp('Please create directory to\n' + MobileUtil.getStorageDirectory() + '\nPress OK to close the game', 'Error!');
		    Sys.exit(1);
		}
	}
	#end

    public static function showPopUp(message:String, title:String):Void
	{
		#if android
		AndroidTools.showAlertDialog(title, message, {name: "OK", func: null}, null);
		#else
		FlxG.stage.window.alert(message, title);
		#end
	}
}
