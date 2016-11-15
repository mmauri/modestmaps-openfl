import flash.display.Shape;import flash.display.Sprite;import flash.text.TextField;import flash.text.TextFieldAutoSize;import flash.text.TextFormat;  /**
     * @author David Knape
     */  
class Tooltip extends Sprite
{
    public var label(never, set) : String;
	public var background : Shape;
	public var label_txt : TextField;
	public function new()
    {
        super();background = new Shape();background.graphics.beginFill(0xffffff);background.graphics.drawRect(0, 0, 100, 20);background.graphics.endFill();addChild(background);label_txt = new TextField();label_txt.selectable = false;label_txt.defaultTextFormat = new TextFormat("Verdana", 10, 0x000000);addChild(label_txt);visible = false;mouseEnabled = false;
    }private function set_label(s : String) : String{label_txt.autoSize = TextFieldAutoSize.LEFT;label_txt.width = 200;label_txt.multiline = label_txt.wordWrap = true;label_txt.text = s;background.width = Math.max(100, label_txt.textWidth + 10);background.height = label_txt.textHeight + 18;background.y = Math.round(-background.height - 16);background.x = 1;label_txt.y = background.y + 2;graphics.clear();graphics.lineStyle(0, 0x000000);graphics.beginFill(0xffffff);graphics.moveTo(0, 0);graphics.lineTo(background.x - 1, background.y + background.height + 1);graphics.lineTo(background.x - 1, background.y - 1);graphics.lineTo(background.x + background.width + 1, background.y - 1);graphics.lineTo(background.x + background.width + 1, background.y + background.height + 1);graphics.lineTo(background.x + 10, background.y + background.height + 1);graphics.lineTo(0, 0);
        return s;
    }
}