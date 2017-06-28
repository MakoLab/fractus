package assets {

	import flash.display.Graphics;
	import mx.skins.ProgrammaticSkin;
	
	public class MyPopUpButtonSkin extends ProgrammaticSkin {
	
	public function MyPopUpButtonSkin() {
		// Set default values here.
	}
	
	override protected function updateDisplayList(w:Number, h:Number):void {
			var g:Graphics = graphics;
			g.clear();
			g.beginFill(0x00ff00,0);
			g.drawRect(0, 0, w, h);
			g.endFill();
			g.beginFill(0x111111,1.0);
			g.moveTo(w - 14.3, h* 0.5 - 3);
			g.lineTo(w-3.7, h* 0.5 - 3);
			g.lineTo(w-4, h* 0.5 - 2);
			g.lineTo(w-9, h* 0.5 + 3);
			g.lineTo(w - 14, h* 0.5 - 2);
			g.endFill();
		}
	}
}