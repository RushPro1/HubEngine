package 
{
	import bbGameObjects.*;
	import HubGraphics.*;
	import HubAudio.*;
	import HubMath.*;
	import flash.geom.*;
	
	public class BrickBreakerGame 
	{
		public var _Ball:Ball;
		public var _Paddle:Paddle;
		public var _Blocks:Array;
		public var _Cursor:Cursor;
		public var _ActiveBlocks:Number;

		public var _BrickBounceSound:hSound;
		public var _PaddleBounceSound:hSound;
		public var _FailSound:hSound;
		public var _Music:hSound;
		
      	public function BrickBreakerGame()
        {
			_Music = hGlobalAudio.SoundLibrary.AddSoundFromFile("fractal.mp3?n=12f34");
			_BrickBounceSound = hGlobalAudio.SoundLibrary.AddSoundFromFile("button-29.mp3?n=12f34");
			_PaddleBounceSound = hGlobalAudio.SoundLibrary.AddSoundFromFile("ballpaddle.mp3?n=34f534");
			_FailSound = hGlobalAudio.SoundLibrary.AddSoundFromFile("button-10.mp3?n=2");
			
			_Cursor = new Cursor("cursor.png");
			_Ball = new Ball("ball.png");
			_Paddle = new Paddle("paddle.png");

			_Blocks = new Array();
			for (var i:uint = 0; i < 15; i++)
			{
				for (var j:uint = 0; j < 15; j++)
				{
					var newBlock:Block = new Block("brick.png?n=2");
					newBlock.Translate(20 + i*40, 20 + j*15);
					_Blocks.push(newBlock);
				}				
			}
			_ActiveBlocks = _Blocks.length;
        }

		public function Update(elapsedTime:Number):void
		{
//			_Music.PlayOnlyOne(999);
			_Ball.Update(elapsedTime);
			_Paddle.Update(elapsedTime);

			// Collide Ball with Blocks
			var blocksLength:uint = _Blocks.length;
			for (var i:uint = 0; i < blocksLength; i++) {
				if (!_Blocks[i] || !_Blocks[i] is Block || !_Blocks[i].Active)
					continue;
				_Blocks[i].Update(elapsedTime);
				
				if (hCollision.PointInAlignedRect(_Ball.Center, _Blocks[i].Left, _Blocks[i].Top, _Blocks[i].Right, _Blocks[i].Bottom, _Ball.Width * 0.5)) {
					var TopLeft:Point = new Point(_Blocks[i].Left, _Blocks[i].Top);
					var TopRight:Point = new Point(_Blocks[i].Right, _Blocks[i].Top);
					var BottomLeft:Point = new Point(_Blocks[i].Left, _Blocks[i].Bottom);
					var BottomRight:Point = new Point(_Blocks[i].Right, _Blocks[i].Bottom);

					var intersect:Point;
					var collided:Boolean = false;
					// Bottom Side
					if (_Ball.Velocity.y < 0) {
						intersect = hCollision.LineSegmentIntersectionPoint(_Ball.PreviousCenter, _Ball.Center, BottomLeft, BottomRight);
						if (intersect != null && intersect.x >= _Blocks[i].Left && intersect.x <= _Blocks[i].Right && _Ball.PreviousCenter.y > _Blocks[i].Bottom && _Ball.Center.y < _Blocks[i].Bottom) {
							_Ball.ResetTranslation(intersect.x - _Ball.Width * 0.5, intersect.y - _Ball.Height * 0.5);
//							_Ball.ResetTranslation(_Ball.Position.x, 2 * _Blocks[i].Bottom - _Ball.Position.y);
							_Ball.ResetVelocity(_Ball.Velocity.x, Math.abs(_Ball.Velocity.y));
							collided = true;
						}
					}
					// Top Side
					else if (_Ball.Velocity.y > 0) {
						intersect = hCollision.LineSegmentIntersectionPoint(_Ball.PreviousCenter, _Ball.Center, TopLeft, TopRight);
						if (intersect != null && intersect.x >= _Blocks[i].Left && intersect.x <= _Blocks[i].Right && _Ball.PreviousCenter.y < _Blocks[i].Top && _Ball.Center.y > _Blocks[i].Top) {
							_Ball.ResetTranslation(intersect.x - _Ball.Width * 0.5, intersect.y - _Ball.Height * 0.5);
//							_Ball.ResetTranslation(_Ball.Position.x, 2 * _Blocks[i].Top + _Ball.Position.y);
							_Ball.ResetVelocity(_Ball.Velocity.x, -Math.abs(_Ball.Velocity.y));
							collided = true;
						}
					}
					// Right Side
					if (_Ball.Velocity.x < 0) {
						intersect = hCollision.LineSegmentIntersectionPoint(_Ball.PreviousCenter, _Ball.Center, TopRight, BottomRight);
						if (intersect != null && intersect.y >= _Blocks[i].Top && intersect.y <= _Blocks[i].Bottom && _Ball.PreviousCenter.x > _Blocks[i].Right && _Ball.Center.x < _Blocks[i].Right) {
							_Ball.ResetTranslation(intersect.x - _Ball.Width * 0.5, intersect.y - _Ball.Height * 0.5);
							_Ball.ResetVelocity(Math.abs(_Ball.Velocity.x), _Ball.Velocity.y);
							collided = true;
						}
					}
					// Left Side
					else if (_Ball.Velocity.x > 0) {
						intersect = hCollision.LineSegmentIntersectionPoint(_Ball.PreviousCenter, _Ball.Center, TopLeft, BottomLeft);
						if (intersect != null && intersect.y >= _Blocks[i].Top && intersect.y <= _Blocks[i].Bottom && _Ball.PreviousCenter.x < _Blocks[i].Left && _Ball.Center.x > _Blocks[i].Left) {
							_Ball.ResetTranslation(intersect.x - _Ball.Width * 0.5, intersect.y - _Ball.Height * 0.5);
							_Ball.ResetVelocity(-Math.abs(_Ball.Velocity.x), _Ball.Velocity.y);
							collided = true;
						}
					}
					
					if (collided == true) {
						_Blocks[i].Active = false;
						_Blocks[i].Visible = false;
						_BrickBounceSound.Play();
						_ActiveBlocks--;
						break;
					}
				}
			}
			
			//Collide Ball With Paddle
			if (hCollision.PointInAlignedRect(_Ball.Center, _Paddle.Left, _Paddle.Top, _Paddle.Right, _Paddle.Bottom))
			{
				_Ball.Position.y = _Paddle.Position.y - _Ball.Height;
				
				_Ball.AddVelocity((_Ball.Center.x - _Paddle.Center.x) * 8, 0);
				if (_Ball.Velocity.x > 400)
					_Ball.ResetVelocity(400, _Ball.Velocity.y);
				_Ball.Velocity.normalize(_Ball.Speed);
				_Ball.ResetVelocity(_Ball.Velocity.x, -Math.abs(_Ball.Velocity.y));
				_PaddleBounceSound.Play();
			}
			
			//Reset if Ball Hits Bottom
			if (_Ball.Bottom > hGlobalGraphics.View.Height) {
				_Ball.Reset();
				Reset();
				_FailSound.Play();	
			}
						
			if (_ActiveBlocks < 1)
				Reset();			
		}
		
		public function Reset():void
		{
			var blocksLength:uint = _Blocks.length;
			for (var i:uint = 0; i < blocksLength; i++) {
				if (!_Blocks[i] || !_Blocks[i] is Block)
					continue;
				_Blocks[i].Active = true;
				_Blocks[i].Visible = true;
			}
			
			_Ball.ResetTranslation(hGlobalGraphics.View.Width * 0.5 - _Ball.Width * 0.5, 400);
			_Ball.ResetVelocity(205, -200);
			_Paddle.ResetTranslation(hGlobalGraphics.View.Width * 0.5 - _Paddle.Width * 0.5, _Paddle.DefaultYPosition)
			_ActiveBlocks = _Blocks.length;
		}
		
		public function Render():void
		{
			_Cursor.Update(0);
			
			var blocksLength:uint = _Blocks.length;
			for (var i:uint = 0; i < blocksLength; i++) {
				if (_Blocks[i] && _Blocks[i] is Block)
					_Blocks[i].Render();
			}
			_Ball.Render();
			_Paddle.Render();
			_Cursor.Render();
		}
	}
}