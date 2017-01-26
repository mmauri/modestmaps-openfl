import openfl.display.Sprite;
import openfl.events.MouseEvent;

class SampleMarker extends Sprite
{
	public var title(get, set) : String;
	private var _title : String;
	public function new()
	{
		super();
		buttonMode = true;
		mouseChildren = false;
		tabEnabled = false;
		//cacheAsBitmap = true;
		mouseEnabled = true;
		// David's Flash example draws the marker
		// in the Flash environment
		// but need to draw something:
		// first a zero-alpha circle so the filter's bitmap cache doesn't mess things up
		graphics.beginFill(0xff0000, 0);
		graphics.drawCircle(0, 0, 11);
		graphics.endFill();
		// now a red circle
		graphics.beginFill(0xff0000);
		graphics.drawCircle(0, 0, 10);
		graphics.endFill();
		//todo filters = [new BevelFilter(1, 45, 0xffffff, 0.35, 0x000000, 0.35, 2, 2, 1, 1)];
		addEventListener(MouseEvent.MOUSE_OVER, mouseOver);
	}
	private function get_title() : String
	{

		return _title;
	}
	private function set_title(s : String) : String
	{
		_title = s;
		return s;
	}
	private function mouseOver(e : MouseEvent) : Void
	{
		parent.swapChildrenAt(parent.getChildIndex(this), parent.numChildren - 1);
	}
	override public function toString() : String
	{
		return "[SampleMarker] " + title;
	}
}