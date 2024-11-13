package sys.io;

import cpp.NativeFile;

@:coreApi
class File
{
	public static function getContent(path:String):String
		return NativeFile.file_contents_string(#if mobile Sys.getCwd() + #end path);

	public static function getBytes(path:String):haxe.io.Bytes
	{
		var data = NativeFile.file_contents_bytes(#if mobile Sys.getCwd() + #end path);
		return haxe.io.Bytes.ofData(data);
	}

	public static function saveContent(path:String, content:String):Void
	{
		var f = write(path);
		f.writeString(content);
		f.close();
	}

	public static function saveBytes(path:String, bytes:haxe.io.Bytes):Void
	{
		var f = write(path);
		f.write(bytes);
		f.close();
	}

	public static function read(path:String, binary:Bool = true):FileInput
		return untyped new FileInput(NativeFile.file_open(#if mobile Sys.getCwd() + #end path, (if (binary) "rb" else "r")));

	public static function write(path:String, binary:Bool = true):FileOutput
		return untyped new FileOutput(NativeFile.file_open(#if mobile Sys.getCwd() + #end path, (if (binary) "wb" else "w")));

	public static function append(path:String, binary:Bool = true):FileOutput
		return untyped new FileOutput(NativeFile.file_open(#if mobile Sys.getCwd() + #end path, (if (binary) "ab" else "a")));

	public static function update(path:String, binary:Bool = true):FileOutput
	{
		if (!FileSystem.exists(path))
			write(path).close();

		return untyped new FileOutput(NativeFile.file_open(#if mobile Sys.getCwd() + #end path, (if (binary) "rb+" else "r+")));
	}

	public static function copy(srcPath:String, dstPath:String):Void
	{
		var s = read(srcPath, true);
		var d = write(dstPath, true);
		d.writeInput(s);
		s.close();
		d.close();
	}
}
