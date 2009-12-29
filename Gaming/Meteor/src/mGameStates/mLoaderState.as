package mGameStates 
{
	import HubGaming.*;
	import flash.display.BitmapData;
	import flash.geom.*;
	import flash.utils.*;
	import HubGraphics.*;
	import HubAudio.*;
	import flash.events.*;
	import mGameUI.*;
	
	public class mLoaderState extends hGameState
	{
		private var _Complete:Boolean = false;
		private var _LoaderError:Boolean = false;
		
		public var _GameLoader:MeteorLoader;
		private var _LoaderUI:mLoader;
		private var _Game:MeteorGame;

		public function set Game(game:MeteorGame):void {_Game = game;}

		public function mLoaderState(name:String)
		{
			super(name);
			_LoaderUI = new mLoader();
			_GameLoader = new MeteorLoader();
		}

		private function CompleteEvent(event:MouseEvent):void { _Complete = true; }
		private function LoaderErrorClicked(event:MouseEvent):void { _LoaderError = true; }
		
		public override function Start():void
		{
			_Complete = false;
			_LoaderError = false;

			if (_LoaderUI && _LoaderUI.StartGameButton) {
				_LoaderUI.StartGameButton.enabled = false;
				_LoaderUI.StartGameButton.alpha = 50;
			}
			hGlobalGraphics.View.ViewImage.addChild(_LoaderUI);

			if (!_Game) {
				HandleLoaderError(null);
				return;
			}
			
			_Game.ClearObjects();
			_Game.Reset();
			
			_GameLoader.Game = _Game;
			_GameLoader.URL = _Game.Resources;
			_GameLoader.addEventListener(hGameLoader.IO_ERROR, HandleLoaderError);
			_GameLoader.addEventListener(hGameLoader.COMPLETE, HandleXMLComplete)
			_GameLoader.Load();
		}
		
		private function HandleXMLComplete(event:Event):void 
		{
			hGlobalGraphics.ImageLibrary.addEventListener(hImageLibrary.COMPLETE, HandleComplete);
			hGlobalGraphics.ImageLibrary.addEventListener(hImageLibrary.IO_ERROR, HandleLoaderError);
			hGlobalGraphics.ImageLibrary.LoadAllUnloadedImages();
			hGlobalAudio.SoundLibrary.LoadAllUnloadedSounds();
		}
		
		private function HandleLoaderError(event:Event):void
		{
			_LoaderUI.ErrorMessage.text = "Error Loading Required Files!"
			_LoaderUI.StartGameButton.addEventListener(MouseEvent.CLICK, LoaderErrorClicked);
			_LoaderUI.StartGameButton.enabled = true;
			_LoaderUI.StartGameButton.alpha = 100;
		}
		
		public override function Stop():void
		{
			_LoaderUI.StartGameButton.enabled = false;
			_LoaderUI.StartGameButton.alpha = 50;
			_LoaderUI.StartGameButton.removeEventListener(MouseEvent.CLICK, CompleteEvent);
			hGlobalGraphics.View.ViewImage.removeChild(_LoaderUI);
		}
		
		public override function Run(elapsedTime:Number):void
		{
			if (_Complete) {
				_LoaderUI.StartGameButton.enabled = false;
				_LoaderUI.StartGameButton.alpha = 50;
				_Game.Reset();
				ChangeState("GameState");
			}
			if (_LoaderError) {
				_LoaderUI.StartGameButton.enabled = false;
				_LoaderUI.StartGameButton.alpha = 50;
				ChangeState("MenuState");
			}
		}
		
		private function HandleComplete(event:Event):void
		{
			_LoaderUI.StartGameButton.addEventListener(MouseEvent.CLICK, CompleteEvent);
			_LoaderUI.StartGameButton.enabled = true;
			_LoaderUI.StartGameButton.alpha = 100;
			_LoaderUI.Loading.visible = false;
		}
	}
}
