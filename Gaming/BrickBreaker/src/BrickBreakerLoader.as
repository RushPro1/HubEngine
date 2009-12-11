package  
{
	import HubGaming.*;
	import HubGraphics.*;
	import HubAudio.*;

	public class BrickBreakerLoader extends hGameLoader
	{
		private var _Game:BrickBreakerGame;

		public function get Game():BrickBreakerGame {return _Game;}
		public function set Game(game:BrickBreakerGame):void {_Game = game;}

		public function BrickBreakerLoader()
		{
			super();
		}
		
		protected override function LoadData(hubGame:XML):void
		{
			super.LoadData(hubGame);
			
			if (!_Game)
				return;
			
			for each (var newBlock:XML in hubGame..block ) {
				_Game.AddBlock(newBlock["@image"], newBlock["@shape"], Number(newBlock["@x"]), Number(newBlock["@y"]), Number(newBlock["@width"]), Number(newBlock["@height"]));
			}
			for each (var newBall:XML in hubGame..ball ) {
				_Game.AddBall(newBall["@image"], Number(newBall["@width"]), Number(newBall["@height"]));
			}
			for each (var newPaddle:XML in hubGame..paddle ) {
				_Game.AddPaddle(newPaddle["@image"], Number(newPaddle["@width"]), Number(newPaddle["@height"]));
			}
			for each (var newBackground:XML in hubGame..background ) {
				hGlobalGraphics.BackgroundImage = newBackground["@image"];
			}
		}
		
	}
}
