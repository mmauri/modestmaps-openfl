/*
 * $Id$
 */

package com.modestmaps.events;


import openfl.events.Event;
import com.modestmaps.geo.Location;
import openfl.display.DisplayObject;

class MarkerEvent extends Event
{
    public var marker(get, never) : DisplayObject;
    public var location(get, never) : Location;

    // these are prefixed marker to avoid conflicts with MouseEvent
    public static inline var MARKER_ROLL_OVER : String = "markerRollOver";
    public static inline var MARKER_ROLL_OUT : String = "markerRollOut";
    public static inline var MARKER_CLICK : String = "markerClick";
    
    private var _marker : DisplayObject;
    private var _location : Location;
    
    public function new(type : String, marker : DisplayObject, location : Location, bubbles : Bool = true, cancelable : Bool = false)
    {
        super(type, bubbles, cancelable);
        _marker = marker;
        _location = location;
    }
    
    private function get_marker() : DisplayObject
    {
        return _marker;
    }
    
    private function get_location() : Location
    {
        return _location;
    }
}
