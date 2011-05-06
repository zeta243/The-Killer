package game 
{
	import net.flashpunk.Entity;
	import net.flashpunk.graphics.Image;
	import net.flashpunk.FP;
	import net.flashpunk.tweens.misc.Alarm;
	import net.flashpunk.utils.Input;
	import net.flashpunk.World;
	import rooms.GameOver;
	import rooms.MyWorld;
	import net.flashpunk.Sfx;
	
	/**
	 * ...
	 * @author Jordan Magnuson
	 */
	public class PlayerShooting extends Entity
	{
		public const MAX_TIME_TILL_KNEEL:Number = 8;
		public const MIN_TIME_TILL_KNEEL:Number = 4;
		
		public var kneelAlarm:Alarm;
		
		public var playMusicAlarm:Alarm = new Alarm(0.00001, playMusic);
		
		public var killVictimAlarm:Alarm = new Alarm(0.00001, killVictim);
		
		public var gameOverAlarm:Alarm = new Alarm(3, gameOver);
		
		/**
		 * Player graphic
		 */
		[Embed(source='../../assets/killer_no_gun.png')] private const SPRITE:Class;
		public var image:Image = new Image(SPRITE);
		
		public var gunshot:Sfx = new Sfx(Assets.GUNSHOT);		
		
		public function PlayerShooting() 
		{
			graphic = image;
			
			// Hit box
			image.originX = 0;
			image.originY = image.height;
			image.x = 0;
			image.y = -image.originY;	
			
			setHitbox(image.width, image.height, image.originX, image.originY);
			
			// Victim kneels
			kneelAlarm = new Alarm(MAX_TIME_TILL_KNEEL * FP.random + MIN_TIME_TILL_KNEEL, makeVictimKneel);
		}
		
		override public function added():void
		{
			FP.world.add(Global.gun = new Gun);
			FP.world.add(Global.crossHair = new Crosshair);
			addTween(kneelAlarm, true);
			addTween(playMusicAlarm);
			addTween(killVictimAlarm);
		}
		
		override public function update():void
		{
			//trace(Global.gun.image.angle);
			
			if (Input.mousePressed && !Global.shotFired)
			{
				Global.shotFired = true;
				gunshot.play(2);
				
				// Stop sounds
				Global.playSounds = false;
				
				// Merciful shot?
				if (Global.gun.image.angle > 8 && Global.gun.image.angle < 348)
				{
					Global.mercifulShot = true;
					(FP.world as MyWorld).soundController.stopSounds();
					addTween(gameOverAlarm, true);
				}
				else 
				{
					// Play music
					playMusicAlarm.start();
				
					killVictimAlarm.start();					 
				}
		
				// get rid of crosshairs
				FP.world.remove(Global.crossHair);
				
				// Slow everything down (clouds)
				FP.rate = 0.4;
			}
			super.update();
		}
		
		public function makeVictimKneel():void
		{
			if (!Global.mercifulShot)
				Global.victim.kneel();
		}
		
		public function playMusic():void
		{
			(FP.world as MyWorld).musicEnd.play();			
		}
		
		public function killVictim():void
		{
			// Kill victim
			FP.world.add(Global.deadVictim = new DeadVictim);
			FP.world.add(Global.deadUnderground = new DeadUnderground);
			Global.deadVictim.x = Global.victim.x;
			Global.deadVictim.y = Global.victim.y;
			FP.world.remove(Global.victim);					
		}
		
		public function gameOver():void
		{
			FP.world.add((FP.world as MyWorld).soundController = new SoundController((FP.world as MyWorld).location));
			Global.playSounds = true;			
			FP.world.add(new FadeOut((GameOver as World), Colors.BLACK, 3, 0));
		}
		
	}

}