package 
{
	import flash.events.*;
	import flash.geom.*;
	import mGameUI.*;
	import mGameObjects.*;
	import HubGraphics.*;
	import HubAudio.*;
	import HubInput.*;
	import HubMath.*;
	import nl.demonsters.debugger.MonsterDebugger;
	
	public class MeteorGame extends EventDispatcher
	{
		// Static Members : Event Response Strings
		public static var LEVEL_WON:String = "next level";
		public static var GAME_OVER:String = "game over";

		// Private Members
		// Game Objects
		public var _Ship:Ship;

		public var _SmallMeteors:Array = new Array();
		public var _MediumMeteors:Array = new Array();
		public var _LargeMeteors:Array = new Array();
		public var _MegaMeteors:Array = new Array();

		public var _ActiveMeteors:Array = new Array();

		public var _ProjectileTypes:Array = new Array();
		public var _Projectiles:Array = new Array();

		// HUD UI
		public var _HUD:mGameHUD;

		// Game State Vars
		private var _MeteorMaxSpeed:Number = 150;
		private var _SinceLastProjectile:Number = 1000;
		private var _ProjectileTime:Number = 0.25;
		private var _Resources:String = null;
		private var _Score:Number = 0;
		private var _Ships:Number = 1;
		private var _StartingShips:Number = 5;
		private var _Cheating:Boolean = false;
		private var _Invincible:Boolean = false;

		// Cheats
		private var _ExtraLivesCheat:Array = [hKeyCodes.I, hKeyCodes.D, hKeyCodes.K, hKeyCodes.F, hKeyCodes.A];
		private var _InvincibleCheat:Array = [hKeyCodes.I, hKeyCodes.D, hKeyCodes.D, hKeyCodes.Q, hKeyCodes.D];
		private var _NextLevelCheat:Array = [hKeyCodes.I, hKeyCodes.D, hKeyCodes.C, hKeyCodes.L, hKeyCodes.E, hKeyCodes.V];

		// Mutators and Accessors
		public function get Score():Number {return _Score;}
		public function get Ships():Number {return _Ships;}
		public function get Resources():String {return _Resources;}  
		public function set Resources(resources:String):void {_Resources = resources;}
		public function get HUD():mGameHUD {return _HUD;}
		
		public function AddScore(value:Number):Number
		{
			Score = Score + value;
			return Score;
		}

		public function set Score(value:Number):void
		{
			if (!_Cheating)
				_Score = value;
			else
				_Score = 0;
				
			if (_HUD && _HUD.Score) {
				_HUD.Score.text = String(_Score);
			}
		}
		
		public function AddShips(numShips:int):Number
		{
			Ships = Ships + numShips;
			return _Ships;
		}
		
		public function set Ships(numShips:Number):void
		{
			_Ships = numShips;
			
			if (_HUD && _HUD.Ships)
				_HUD.Ships.text = String(_Ships);

			if (_Ships < 0) {
				_Ships = _StartingShips;
				GameOver();
			}
		}

		/////////////////
		// Constructor //
		/////////////////
      	public function MeteorGame()
        {
			_HUD = new mGameHUD();

			Ships = _StartingShips;
			_Ship = new Ship();

			Reset();
        }

		//////////////////////////////////
		// Game State Setting Functions //
		//////////////////////////////////
		public function ClearObjects():void 
		{
			hGlobalGraphics.ParticleSystem.DeactivateAllParticles();			
			_Projectiles.length = 0;
			_ActiveMeteors.length = 0;
		}
		
		public function NewGame():void
		{
			Score = 0;
			Ships = _StartingShips;
			NewLevel();
		}
		
		public function NewLevel():void
		{
			ClearObjects();
			CreateMeteors();
			Reset();
		}
		
		public function CreateMeteors():void
		{
			// Create Some Large Meteors
			if (_LargeMeteors.length) {
				for (var i:uint = 0; i < 5; i++)
				{
					MonsterDebugger.trace(this, _LargeMeteors.length);
					CloneMeteor(_LargeMeteors[uint(Math.random() * (_LargeMeteors.length - 1))], Math.random() * 640, Math.random() * 480, Math.random() * _MeteorMaxSpeed - _MeteorMaxSpeed * 0.5, Math.random() * _MeteorMaxSpeed - _MeteorMaxSpeed * 0.5);
				}
			}
			
			// Create a Mega Meteor
			if (_MegaMeteors.length) {
				MonsterDebugger.trace(this, _MegaMeteors.length);
				CloneMeteor(_MegaMeteors[uint(Math.random() * (_MegaMeteors.length - 1))], Math.random() * 640, Math.random() * 480, Math.random() * _MeteorMaxSpeed - _MeteorMaxSpeed * 0.5, Math.random() * _MeteorMaxSpeed - _MeteorMaxSpeed * 0.5);
			}
		}

		public function SpawnMeteors(typeArray:Array, num:uint, posX:Number, posY:Number):void
		{
			if (typeArray.length) {
				for (var i:uint = 0; i < num; i++)
				{
					MonsterDebugger.trace(this, typeArray.length);
					CloneMeteor(typeArray[uint(Math.random() * (typeArray.length - 1))], posX, posY, Math.random() * _MeteorMaxSpeed - _MeteorMaxSpeed * 0.5, Math.random() * _MeteorMaxSpeed - _MeteorMaxSpeed * 0.5);
				}
			}
		}

		public function Reset():void
		{
			hGlobalGraphics.ParticleSystem.DeactivateAllParticles();			
			_Projectiles.length = 0;
			_Ship.Reset();
		}

		//////////////////////////////////
		// Show and Display the Game UI //
		//////////////////////////////////
		public function ShowHUD():void {if (hGlobalGraphics.View.ViewImage && _HUD) hGlobalGraphics.View.ViewImage.addChild(_HUD);}
        public function HideHUD():void {if (hGlobalGraphics.View.ViewImage && _HUD) hGlobalGraphics.View.ViewImage.removeChild(_HUD);}

		///////////////////////
		// Event Dispatchers //
		///////////////////////
		public function LevelWon():void
		{
			dispatchEvent(new Event(LEVEL_WON));			
		}

		public function GameOver():void
		{
			dispatchEvent(new Event(GAME_OVER));			
		}

		////////////////////////////////////////////
		// Object Creation - Used by Level Loader //
		////////////////////////////////////////////
		public function AddMeteor(imageName:String, shape:String, width:Number, height:Number, currentFrame:uint, powerupName:String = null):void
		{
			var newMeteor:Meteor = new Meteor();
			newMeteor.Shape = shape;
			newMeteor.Width = width;
			newMeteor.Height = height;
			newMeteor.CurrentFrame = currentFrame;
			newMeteor.SetImage(imageName);
			newMeteor.PowerupName = powerupName;
			
			if (newMeteor.Shape == "small")
				_SmallMeteors.push(newMeteor);
			else if (newMeteor.Shape == "medium")
				_MediumMeteors.push(newMeteor);
			else if (newMeteor.Shape == "large")
				_LargeMeteors.push(newMeteor);
			else if (newMeteor.Shape == "mega")
				_MegaMeteors.push(newMeteor);	
		}
		
		public function AddProjectile(imageName:String, type:String, width:Number, height:Number):void
		{
			var newProjectile:Projectile = new Projectile();
			newProjectile.Type = type;
			newProjectile.Width = width;
			newProjectile.Height = height;
			newProjectile.SetImage(imageName);
			_ProjectileTypes.push(newProjectile);
			MonsterDebugger.trace(this, "Projectile " + imageName);
		}
		
		public function AddShip(imageName:String, invincibleImageName:String, width:Number, height:Number):void
		{
			_Ship.SetImage(imageName);
			_Ship.NormalImage = imageName;
			_Ship.InvincibleImage = invincibleImageName;
			_Ship.Width = width;
			_Ship.Height = height;
			_Ship.Translate(hGlobalGraphics.View.Width * 0.5 - width * 0.5, hGlobalGraphics.View.Height * 0.5 - height * 0.5);
			MonsterDebugger.trace(this, "Ship " + imageName);
		}

		//////////////////////
		// Projectile Handling //
		//////////////////////
		public function CloneProjectileByType(type:String, xPos:Number, yPos:Number, velX:Number, velY:Number):void
		{
			var powerupsLength:uint = _ProjectileTypes.length;
			for (var i:uint = 0; i < powerupsLength; i++) {
				if (_ProjectileTypes[i] && _ProjectileTypes[i].Type == type) {
					var newProjectile:Projectile = new Projectile();
					newProjectile.Width = _ProjectileTypes[i].Width;
					newProjectile.Height = _ProjectileTypes[i].Height;
					newProjectile.CurrentFrame = _ProjectileTypes[i].CurrentFrame;
					newProjectile.SetImage(_ProjectileTypes[i].GetImageName());
					newProjectile.Type = type;
					newProjectile.ResetTranslation(xPos, yPos);
					newProjectile.ResetVelocity(velX, velY);
					_Projectiles.push(newProjectile);
					break;
				}
			}
		}
		
		public function CloneMeteor(meteor:Meteor, xPos:Number, yPos:Number, velX:Number, velY:Number):void
		{
			var newMeteor:Meteor = new Meteor();
			newMeteor.Width = meteor.Width;
			newMeteor.Height = meteor.Height;
			newMeteor.CurrentFrame = meteor.CurrentFrame;
			newMeteor.SetImage(meteor.GetImageName());
			newMeteor.Shape = meteor.Shape;
			newMeteor.Translate(xPos, yPos);
			newMeteor.AddVelocity(velX, velY);
			_ActiveMeteors.push(newMeteor);
		}
		
		public function ApplyProjectile(powerup:Projectile):void
		{
			/*if (powerup.Type == "slow_ball") {
				_Ship.SlowDown();
			} else if (powerup.Type == "fast_ball") {
				_Ship.SpeedUp();
			}*/
		}

		public function Update(elapsedTime:Number):void
		{
			var i:uint = 0;
			var j:uint = 0;
			
			hGlobalAudio.PlayMusic();
			
			if (hGlobalInput.Keyboard.KeySequenceEntered(_ExtraLivesCheat)) {
				Ships = Ships + 50;
				_Cheating = true;
			}
			
			if (hGlobalInput.Keyboard.KeySequenceEntered(_InvincibleCheat)) {
				_Invincible = !_Invincible;
				_Cheating = true;
			}

			if (hGlobalInput.Keyboard.KeySequenceEntered(_NextLevelCheat)) {
				LevelWon();
				_Cheating = true;
			}
		
			_SinceLastProjectile += elapsedTime;
			if (hGlobalInput.Keyboard.KeyPressed(hKeyCodes.SPACEBAR))
			{
				if (_SinceLastProjectile > _ProjectileTime) 
				{
					_SinceLastProjectile = 0;
					var ProjVel:Point = new Point(_Ship.Sine, -_Ship.Cosine);
					ProjVel.normalize(400);
					CloneProjectileByType("photon", _Ship.Position.x, _Ship.Position.y, ProjVel.x, ProjVel.y);
				}
			}
			
			
			_Ship.Update(elapsedTime);

			for (i = 0; i < _Projectiles.length; i++) {
				if (!_Projectiles[i] || !_Projectiles[i] is Projectile)
					continue;

				if (!_Projectiles[i].Active) {
					_Projectiles.splice(i, 1);
					i--;
					continue;
				}
				
				for (j = 0; j < _ActiveMeteors.length; j++) {
					if (!_ActiveMeteors[i] || !_ActiveMeteors[i] is Meteor || !_ActiveMeteors[i].Active)
					 	continue;

					if (_Projectiles[i].ObjectRectanglesCollide(_ActiveMeteors[j]))
					{
						// Spawn Smaller and Score
						if (_ActiveMeteors[j].Shape == "small") {
							Score = Score + 250;
						}
						else if (_ActiveMeteors[j].Shape == "medium") {
							SpawnMeteors(_SmallMeteors, 3, _ActiveMeteors[j].Position.x, _ActiveMeteors[j].Position.y);
							Score = Score + 150;
						}
						else if (_ActiveMeteors[j].Shape == "large") {
							SpawnMeteors(_MediumMeteors, 3, _ActiveMeteors[j].Position.x, _ActiveMeteors[j].Position.y);
							Score = Score + 75;
						}
						else if (_ActiveMeteors[j].Shape == "mega") {
							SpawnMeteors(_LargeMeteors, 2, _ActiveMeteors[j].Position.x, _ActiveMeteors[j].Position.y);
							Score = Score + 25;
						}

						_ActiveMeteors.splice(j, 1);
						j--;

						_Projectiles.splice(i, 1);
						i--;
						continue;
					}
				}
				
				_Projectiles[i].Update(elapsedTime);
			}

			var meteorsLength:uint = _ActiveMeteors.length;
			var activeMeteors:uint = 0;
			for (i = 0; i < meteorsLength; i++) {
				if (!_ActiveMeteors[i] || !_ActiveMeteors[i] is Meteor)
				 	continue;
					
				activeMeteors++;
				
				if (_Ship.ObjectRectanglesCollide(_ActiveMeteors[i]))
				{
					if (!_Invincible && !_Ship.Invincible) {
						Ships -= 1;
						Reset();
					}
				}
				
				_ActiveMeteors[i].Update(elapsedTime);
			}

			// End Level if No More Meteors
			if (activeMeteors < 1)
				LevelWon();
			
			hGlobalGraphics.ParticleSystem.Update(elapsedTime);
		}
		
		public function Render():void
		{
			hGlobalGraphics.ParticleSystem.Render();
			
			var meteorsLength:uint = _ActiveMeteors.length;
			for (var i:uint = 0; i < meteorsLength; i++) {
				if (_ActiveMeteors[i] && _ActiveMeteors[i] is Meteor && _ActiveMeteors[i].Visible)
					_ActiveMeteors[i].Render();
			}
			
			for (i = 0; i < _Projectiles.length; i++) {
				if (_Projectiles[i])
					_Projectiles[i].Render();
			}
			
			_Ship.Render();
		}
	}
}