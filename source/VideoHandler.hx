package;

import flixel.util.FlxSignal;
import flixel.FlxSprite;
import flixel.FlxG;
import openfl.Assets;
import flixel.util.FlxColor;

#if hxvlc
import flixel.util.FlxTimer;
import hxvlc.flixel.FlxVideoSprite;
#elseif web
import openfl.media.SoundTransform;
import openfl.media.Video;
import openfl.net.NetConnection;
import openfl.net.NetStream;
#end

/**
	An adaptation of MAJigsaw77's OpenFL desktop MP4 code to not only make         
	work as a Flixel Sprite, but also allow it to work with standard OpenFL               
	on Web builds as well.     

	Quick Side Note: Rozebud if you seeing this, I'm sorry but screw you man
	@author Rozebud
	@author Lily Ross
**/

#if hxvlc
class VideoHandler extends FlxVideoSprite
{
	public static var MAX_FPS = 60;
	public var muted(get, never):Bool;
	public var volume(get, never):Float;
	public var length(get, never):Float;
	public var onStart:FlxSignal = new FlxSignal();
	public var onEnd:FlxSignal = new FlxSignal();

	/*override public function new(?x:Float = 0, ?y:Float = 0)
		super(x, y);*/

	public function playMP4(videoPath:String, callback:Void->Void, ?repeat:Bool = false):Void
		playDesktopMP4(videoPath, callback, repeat);

	public function playDesktopMP4(videoPath:String, callback:Void->Void, ?repeat:Bool = false):Void
	{
		this.bitmap.onFormatSetup.add(function():Void
		{
    		if (this.bitmap != null && this.bitmap.bitmapData != null)
    		{
        		final scale:Float = Math.min(FlxG.width / this.bitmap.bitmapData.width, FlxG.height / this.bitmap.bitmapData.height);

        		this.setGraphicSize(this.bitmap.bitmapData.width * scale, this.bitmap.bitmapData.height * scale);
        		this.updateHitbox();
        		this.screenCenter();
    		}
		});
		this.bitmap.onEndReached.add(function()
		{
			this.destroy();
			onEnd.dispatch();
			callback();
		});
		this.bitmap.onOpening.add(()-> onStart.dispatch());

		if (this.load(videoPath))
			FlxTimer.wait(0.001, () -> this.play());
	}

	public function skip():Void
		this.bitmap.onEndReached.dispatch();

	private function get_muted():Bool
		return FlxG.sound.muted;

	private function get_volume():Float
		return FlxG.sound.volume;

	private function get_length():Float
		return haxe.io.FPHelper.i64ToDouble(this.bitmap.time.low, this.bitmap.time.high) / 1000;
}
#elseif web
class VideoHandler extends FlxSprite
{
	/**
		Sets the maximum framerate that the video object will be to the sprite at.
		Helps increase performance on lower end machines and web builds.
	**/
	public static var MAX_FPS = 60;

	/**
		Determines whether the video plays auido. 
	**/
	public var muted(get, set):Bool;
	public var volume:Float = 1;

	public var length(get, never):Float;

	var __muted:Bool = false;
	var paused:Bool = false;
	var finishCallback:Void->Void;
	var waitingStart:Bool = false;
	var startDrawing:Bool = false;
	var frameTimer:Float = 0;
	var completed:Bool = false;
	var destroyed:Bool = false;

	public var onStart:FlxSignal = new FlxSignal();
	public var onEnd:FlxSignal = new FlxSignal();

	var video:Video;
	var netStream:NetStream;
	var netPath:String;
	var netLoop:Bool;

	public function new(?x:Float = 0, ?y:Float = 0){
		super(x, y);
		makeGraphic(1, 1, FlxColor.TRANSPARENT);
	}

	/**
		Generic play function. 
		Works with both desktop and web builds.
	**/
	public function playMP4(videoPath:String, callback:Void->Void, ?repeat:Bool = false){

		playWebMP4(videoPath, callback, repeat);

	}

	//===========================================================================================================//

	/**
		Plays MP4s using OpenFL NetStreams and Videos as the source.
		Only works on web builds.
		It is recommended that you use `playMP4()` instead since that works for desktop and web.
	**/
	@:noCompletion public function playWebMP4(videoPath:String, callback:Void->Void, ?repeat:Bool = false) {

		netLoop = repeat;
		netPath = videoPath;

		if (FlxG.sound.music != null)
		{
			FlxG.sound.music.stop();
		}

		finishCallback = callback;

		video = new Video();
		video.x = -1280;
		video.y = -720;

		FlxG.addChildBelowMouse(video);

		var nc = new NetConnection();
		nc.connect(null);

		netStream = new NetStream(nc);
		netStream.client = {onMetaData: client_onMetaData};

		nc.addEventListener("netStatus", netConnection_onNetStatus);

		if (FlxG.autoPause) {
			FlxG.signals.focusLost.add(pause);
			FlxG.signals.focusGained.add(resume);
		}

		netStream.play(netPath);
	}

	function client_onMetaData(videoPath)
	{
		video.attachNetStream(netStream);

		video.width = FlxG.width;
		video.height = FlxG.height;

		waitingStart = true;
	}

	function netConnection_onNetStatus(videoPath){
		if (videoPath.info.code == "NetStream.Play.Complete")
		{
			if(netLoop){
				netStream.play(netPath);
			}
			else{
				finishVideo();
			}
		}
		if (videoPath.info.code == "NetStream.Play.Start")
		{
			setSoundTransform(__muted);
		}
	}

	function finishVideo(){
		onEnd.dispatch();
		
		if (finishCallback != null){
				finishCallback();
		}
		
		destroy();

	}

	function netClean(){
		
		netStream.dispose();

		completed = true;

		if (FlxG.game.contains(video))
		{
			FlxG.game.removeChild(video);
		}

		trace("Done!");
		completed = true;
	}

	function setSoundTransform(isMuted:Bool){
		if(!isMuted){
			netStream.soundTransform = new SoundTransform(FlxG.sound.volume);
		}
		else{
			netStream.soundTransform = new SoundTransform(0);
		}
	}

	//===========================================================================================================//

	//Basically just grabbing the bitmap data from the video objects and drawing it to the FlxSprite every so often. 
	override function update(elapsed){

		super.update(elapsed);

		if(FlxG.keys.justPressed.MINUS || FlxG.keys.justPressed.PLUS){
			setSoundTransform(__muted);
		}

		if(waitingStart){
			makeGraphic(video.videoWidth, video.videoHeight, FlxColor.TRANSPARENT);
			waitingStart = false;
			startDrawing = true;
			onStart.dispatch();
		}

		if(startDrawing && !paused){

			if(frameTimer >= 1/MAX_FPS){
				pixels.draw(video);
				frameTimer = 0;
			}
			frameTimer += elapsed;

		}

	}

	override function destroy():Void{

		if(destroyed){
			return;
		}
			
		destroyed = true;

		if (FlxG.autoPause) {
			FlxG.signals.focusLost.remove(pause);
			FlxG.signals.focusGained.remove(resume);
		}

		if(!completed){
			netClean();
		}

		super.destroy();
		
	}

	/**
		Pauses playback of the video.
	**/
	public function pause(){

		if(netStream != null && !paused){
			netStream.pause();
		}

		paused = true;
	}

	/**
		Resumes playback of the video.
	**/
	public function resume(){

		if(netStream != null && paused){ 
			netStream.resume();
		}

		paused = false;
	}

	public function skip(){

		finishVideo();

	}

	private function get_muted():Bool{
		return __muted;
	}

	private function set_muted(value:Bool):Bool{

		if(startDrawing){
			setSoundTransform(value);
		}

		return __muted = value;
	}
	

	function get_length():Float {

		@:privateAccess
		return netStream.__video.duration;
	}
}
#end
