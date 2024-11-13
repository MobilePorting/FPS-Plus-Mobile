package sys;

import cpp.NativeSys;

using StringTools;

@:buildXml('<include name="${HXCPP}/src/hx/libs/std/Build.xml"/>')
@:coreApi
class FileSystem
{
	public static function exists(path:String):Bool
		return NativeSys.sys_exists(makeCompatiblePath(path));

	public static function rename(path:String, newPath:String):Void
		NativeSys.sys_rename(#if mobile Sys.getCwd() + #end path, #if mobile Sys.getCwd() + #end newPath);

	public static function stat(path:String):FileStat
	{
		var s:FileStat = NativeSys.sys_stat(makeCompatiblePath(path));
		if (s == null)
			return {
				gid: 0,
				uid: 0,
				atime: Date.fromTime(0),
				mtime: Date.fromTime(0),
				ctime: Date.fromTime(0),
				dev: 0,
				ino: 0,
				nlink: 0,
				rdev: 0,
				size: 0,
				mode: 0
			};
		s.atime = Date.fromTime(1000.0 * (untyped s.atime));
		s.mtime = Date.fromTime(1000.0 * (untyped s.mtime));
		s.ctime = Date.fromTime(1000.0 * (untyped s.ctime));
		return s;
	}

	public static function fullPath(relPath:String):String
		return NativeSys.file_full_path(relPath);

	public static function absolutePath(relPath:String):String
	{
		if (haxe.io.Path.isAbsolute(relPath))
			return relPath;
		return haxe.io.Path.join([Sys.getCwd(), relPath]);
	}

	inline static function kind(path:String):String
		return NativeSys.sys_file_type(makeCompatiblePath(path));

	public static function isDirectory(path:String):Bool
		return kind(path) == "dir";

	public static function createDirectory(path:String):Void
	{
		var path = haxe.io.Path.addTrailingSlash(#if mobile Sys.getCwd() + #end path);
		var _p = null;
		var parts = [];
		while (path != (_p = haxe.io.Path.directory(path)))
		{
			parts.unshift(path);
			path = _p;
		}
		for (part in parts)
			if (part.charCodeAt(part.length - 1) != ":".code && !exists(part) && !NativeSys.sys_create_dir(part, 493))
				throw "Could not create directory:" + part;
	}

	public static function deleteFile(path:String):Void
		NativeSys.file_delete(#if mobile Sys.getCwd() + #end path);

	public static function deleteDirectory(path:String):Void
		NativeSys.sys_remove_dir(#if mobile Sys.getCwd() + #end path);

	public static function readDirectory(path:String):Array<String>
		return NativeSys.sys_read_dir(#if mobile Sys.getCwd() + #end path);

	private static function makeCompatiblePath(path:String):String
	{
		var normalizedPath = if (path.charCodeAt(1) == ":".code && path.length <= 3) haxe.io.Path.addTrailingSlash(path); else if (path == "/") "/"; else
			haxe.io.Path.removeTrailingSlashes(path);

		#if mobile
		if (!normalizedPath.startsWith(Sys.getCwd()))
			normalizedPath = Sys.getCwd() + "/" + normalizedPath;
		#end

		return normalizedPath;
	}
}
