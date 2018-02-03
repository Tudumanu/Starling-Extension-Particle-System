package 
{
	import com.funkypandagame.stardustplayer.SimPlayer;
	import starling.animation.IAnimatable;
	
	public class AnimatableSimPlayer extends SimPlayer implements IAnimatable
	{
		public function advanceTime(time:Number):void {
			stepSimulation(time);
		}
		
	}

}