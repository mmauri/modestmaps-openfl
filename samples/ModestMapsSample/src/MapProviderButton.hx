/* Button for use in ModestMaps Sample
 * 
 * @author David Knape
 */  
import openfl.display.Sprite;
import openfl.text.TextField;
import openfl.text.TextFormat;
import com.modestmaps.mapproviders.IMapProvider;
import openfl.geom.ColorTransform;
import openfl.events.MouseEvent;
import openfl.filters.DropShadowFilter;


 
 class MapProviderButton extends Sprite
{
    public var selected(get, set) : Bool;
	private var label : TextField;
	public var mapProvider : IMapProvider;
	private var overTransform : ColorTransform = new ColorTransform(1, 1, 1);
	private var outTransform : ColorTransform = new ColorTransform(1, .9, .6);
	private var normalFormat : TextFormat = new TextFormat("Verdana", 10, 0x000000, false);
	private var selectedFormat : TextFormat = new TextFormat("Verdana", 10, 0x000000, true);
	private var _selected : Bool = false;
	
	public function new(label_text : String, map_provider : IMapProvider, selected : Bool = false)
    {
        super();
		useHandCursor = true;
		mouseChildren = false;
		buttonMode = true;
		addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
		addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
		mapProvider = map_provider;
		filters = [new DropShadowFilter(1, 45, 0, 1, 3, 3, .7, 2)];
		transform.colorTransform = outTransform;  
		// create label  
		label = new TextField();
		label.selectable = false;
		label.defaultTextFormat = normalFormat;
		label.text = label_text;
		label.width = label.textWidth + 8;
		label.height = 18;
		label.x = label.y = 1;
		addChild(label);
		this.selected = selected;  
		// create background  
		graphics.clear();
		graphics.beginFill(0xdddddd);
		graphics.drawRoundRect(0, 0, label.width + 2, 18, 9, 9);
		graphics.beginFill(0xffffff);
		graphics.drawRoundRect(0, 0, label.width, 16, 9, 9);
		graphics.beginFill(0xbbbbbb);
		graphics.drawRoundRect(2, 2, label.width, 16, 9, 9);
		graphics.beginFill(0xdddddd);
		graphics.drawRoundRect(1, 1, label.width, 16, 9, 9);
    }
	
	public function onMouseOver(event : MouseEvent = null) : Void{
		transform.colorTransform = overTransform;
    }
	
	public function onMouseOut(event : MouseEvent = null) : Void{
		transform.colorTransform = outTransform;
    }
	private function set_selected(s : Bool) : Bool{
		_selected = s;
		label.setTextFormat((s) ? selectedFormat : normalFormat);
        return s;
    }
	
	private function get_selected() : Bool
	{
		return _selected;
    }
}