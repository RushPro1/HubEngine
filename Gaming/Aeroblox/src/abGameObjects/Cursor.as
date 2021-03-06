package abGameObjects
{
	import HubGaming.*;
	import HubGraphics.*;
	import HubInput.*;
	import flash.ui.*;
	
	public class Cursor extends hGameObject
	{
		public function Cursor()
		{
			super();
			//Mouse.hide();
		}
		
		public override function Update(elapsedTime:Number):void
		{
			ResetTranslation(hGlobalInput.Mouse.X, hGlobalInput.Mouse.Y);
		}

		public override function Render():void
		{
			if (hGlobalInput.Mouse.MouseOver)
				super.Render();
		}

	}
}