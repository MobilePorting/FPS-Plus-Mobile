package;

import Conductor.BPMChangeEvent;
import flixel.FlxG;
import flixel.FlxSubState;
import flixel.FlxCamera;
import flixel.util.FlxDestroyUtil;
import mobile.TouchPad;
import mobile.Hitbox;
import mobile.MobileData;

class MusicBeatSubstate extends FlxSubState
{
	public function new(){
		super();
	}

	private var lastBeat:Float = 0;
	private var lastStep:Float = 0;

	private var totalBeats:Int = 0;
	private var totalSteps:Int = 0;

	private var curStep:Int = 0;
	private var curBeat:Int = 0;
	
	public var touchPad:TouchPad;
	public var tpadCam:FlxCamera;
	public var hitbox:Hitbox;
	public var hboxCam:FlxCamera;

	public function addTouchPad(DPad:String, Action:String)
	{
		touchPad = new TouchPad(DPad, Action);
		add(touchPad);
	}

	public function removeTouchPad()
	{
		if (touchPad != null)
		{
			remove(touchPad);
			touchPad = FlxDestroyUtil.destroy(touchPad);
		}

		if(tpadCam != null)
		{
			FlxG.cameras.remove(tpadCam);
			tpadCam = FlxDestroyUtil.destroy(tpadCam);
		}
	}

	public function addHitbox(defaultDrawTarget:Bool = false):Void
	{
		hitbox = new Hitbox();
		hitbox = MobileData.setButtonsColors(hitbox);

		hboxCam = new FlxCamera();
		hboxCam.bgColor.alpha = 0;
		FlxG.cameras.add(hboxCam, defaultDrawTarget);

		hitbox.cameras = [hboxCam];
		hitbox.visible = false;
		add(hitbox);
	}

	public function removeHitbox()
	{
		if (hitbox != null)
		{
			remove(hitbox);
			hitbox = FlxDestroyUtil.destroy(hitbox);
			hitbox = null;
		}

		if(hboxCam != null)
		{
			FlxG.cameras.remove(hboxCam);
			hboxCam = FlxDestroyUtil.destroy(hboxCam);
		}
	}

	public function addTouchPadCamera(defaultDrawTarget:Bool = false):Void
	{
		if (touchPad != null)
		{
			tpadCam = new FlxCamera();
			tpadCam.bgColor.alpha = 0;
			FlxG.cameras.add(tpadCam, defaultDrawTarget);
			touchPad.cameras = [tpadCam];
		}
	}

	override function destroy()
	{
		removeTouchPad();
		removeHitbox();
		
		super.destroy();
	}

	override function create(){
		super.create();
	}

	override function update(elapsed:Float){

		everyStep();

		updateCurStep();

		updateBeat();

		super.update(elapsed);
	}

	private function updateBeat():Void{

		// Needs to be ROUNED, rather than ceil or floor
		curBeat = Math.round(curStep / 4);
	}

	/**
	 * CHECKS EVERY FRAME
	 */
	private function everyStep():Void{

		if (Conductor.songPosition > lastStep + Conductor.stepCrochet - Conductor.safeZoneOffset
			|| Conductor.songPosition < lastStep + Conductor.safeZoneOffset)
		{
			if (Conductor.songPosition > lastStep + Conductor.stepCrochet)
			{
				stepHit();
			}
		}
	}

	private function updateCurStep():Void{

		var lastChange:BPMChangeEvent = {
			stepTime: 0,
			songTime: 0,
			bpm: 0
		}
		for (i in 0...Conductor.bpmChangeMap.length)
		{
			if (Conductor.songPosition >= Conductor.bpmChangeMap[i].songTime)
				lastChange = Conductor.bpmChangeMap[i];
		}

		curStep = lastChange.stepTime + Math.floor((Conductor.songPosition - lastChange.songTime) / Conductor.stepCrochet);
	}

	public function stepHit():Void{

		totalSteps += 1;
		lastStep += Conductor.stepCrochet;

		// If the song is at least 3 steps behind
		if (Conductor.songPosition > lastStep + (Conductor.stepCrochet * 3))
		{
			lastStep = Conductor.songPosition;
			totalSteps = Math.ceil(lastStep / Conductor.stepCrochet);
		}

		if (totalSteps % 4 == 0)
			beatHit();
	}

	public function beatHit():Void{

		lastBeat += Conductor.crochet;
		totalBeats += 1;
	}
}
