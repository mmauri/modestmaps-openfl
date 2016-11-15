import flash.display.MovieClip;import flash.text.TextField;import flash.text.TextFieldAutoSize;  /**     * @author David Knape     */  class Tooltip extends MovieClip
{
    public var label(never, set) : String;
public var background : MovieClip;public var label_txt : TextField;public function new()
    {
        super();visible = false;
    }private function set_Label(s : String) : String{label_txt.autoSize = TextFieldAutoSize.LEFT;label_txt.width = 200;label_txt.multiline = label_txt.wordWrap = true;label_txt.text = s;background.width = Math.max(100, label_txt.textWidth + 10);background.height = label_txt.textHeight + 18;background.y = Math.round(-background.height - 16);label_txt.y = background.y + 2;
        return s;
    }
}