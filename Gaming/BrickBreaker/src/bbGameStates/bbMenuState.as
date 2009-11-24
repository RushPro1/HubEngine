package bbGameStates 
{
	import HubGaming.*;
	import flash.display.BitmapData;
	import flash.geom.*;
	import flash.utils.*;
	import HubGraphics.*;
	
	public class bbMenuState extends hGameState
	{
		private var _CurrentColor:Number = 0;

		public function bbMenuState() 
		{
			super();
		}
		
		public override function Start():void
		{
			_CurrentColor = 0;
			
			hGlobalGraphics.ImageLibrary.AddImageFromFile("http://charting.local/static/images/brickbreaker/ball.png?n=1234")
			hGlobalGraphics.ImageLibrary.LoadAllUnloadedImages();
		}
		
		public override function Stop():void
		{
		}
		
		public override function Run(elapsedTime:uint):String
		{
			_ElapsedTime = elapsedTime;

			_CurrentColor += 0x010101;

			hGlobalGraphics.Canvas.Begin(true, _CurrentColor);
			hGlobalGraphics.Canvas.End();

			if (_CurrentColor > 0xffffff)
				return getQualifiedClassName(bbGameState);
			else
				return Name;
		}
	}
}