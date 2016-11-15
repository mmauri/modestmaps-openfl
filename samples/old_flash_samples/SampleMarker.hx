import flash.display.MovieClip;import flash.events.MouseEvent;  /**     * Sample Marker     * @author David Knape     */  class SampleMarker extends MovieClip
{
    public var title(get, set) : String;
private var _title : String;public function new()
    {
        super();stop();buttonMode = true;mouseChildren = false;tabEnabled = false;cacheAsBitmap = true;addEventListener(MouseEvent.ROLL_OVER, bringToFront, true);
    }private function get_Title() : String{return _title;
    }private function set_Title(s : String) : String{_title = s;
        return s;
    }private function bringToFront(e : MouseEvent) : Void{parent.swapChildrenAt(parent.getChildIndex(this), parent.numChildren - 1);
    }override public function toString() : String{return "[SampleMarker] " + title;
    }
}