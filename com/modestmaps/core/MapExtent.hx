/*
 * $Id$
 */

package com.modestmaps.core;


import com.modestmaps.geo.Location;
import haxe.ds.StringMap;

import openfl.geom.Rectangle;

class MapExtent
{
    public var northWest(get, set) : Location;
    public var southWest(get, set) : Location;
    public var northEast(get, set) : Location;
    public var southEast(get, set) : Location;
    public var center(get, set) : Location;

    // TODO: OK for rectangular projections, but we need a better way for other projections
    public var north : Float;
    public var south : Float;
    public var east : Float;
    public var west : Float;
    
    /** @param n the most northerly latitude
		 *  @param s the southern latitude
		 *  @param e the eastern-most longitude
		 *  @param w the westest longitude */
    public function new(n : Float = 0, s : Float = 0, e : Float = 0, w : Float = 0)
    {
        north = Math.max(n, s);
        south = Math.min(n, s);
        east = Math.max(e, w);
        west = Math.min(e, w);
    }
    
    public function clone() : MapExtent
    {
        return new MapExtent(north, south, east, west);
    }
    
    /** enlarges this extent so that the given extent is inside it */
    public function encloseExtent(extent : MapExtent) : Void
    {
        north = Math.max(extent.north, north);
        south = Math.min(extent.south, south);
        east = Math.max(extent.east, east);
        west = Math.min(extent.west, west);
    }
    
    /** enlarges this extent so that the given location is inside it */
    public function enclose(location : Location) : Void
    {
        north = Math.max(location.lat, north);
        south = Math.min(location.lat, south);
        east = Math.max(location.lon, east);
        west = Math.min(location.lon, west);
    }
    
    private function get_northWest() : Location
    {
        return new Location(north, west);
    }
    
    private function get_southWest() : Location
    {
        return new Location(south, west);
    }
    
    private function get_northEast() : Location
    {
        return new Location(north, east);
    }
    
    private function get_southEast() : Location
    {
        return new Location(south, east);
    }
    
    private function set_northWest(nw : Location) : Location
    {
        north = nw.lat;
        west = nw.lon;
        return nw;
    }
    
    private function set_southWest(sw : Location) : Location
    {
        south = sw.lat;
        west = sw.lon;
        return sw;
    }
    
    private function set_northEast(ne : Location) : Location
    {
        north = ne.lat;
        east = ne.lon;
        return ne;
    }
    
    private function set_southEast(se : Location) : Location
    {
        south = se.lat;
        east = se.lon;
        return se;
    }
    
    private function get_center() : Location
    {
        return new Location(south + (north - south) / 2, east + (west - east) / 2);
    }
    
    private function set_center(location : Location) : Location
    {
        var w : Float = east - west;
        var h : Float = north - south;
        north = location.lat - h / 2;
        south = location.lat + h / 2;
        east = location.lon + w / 2;
        west = location.lon - w / 2;
        return location;
    }
    
    public function inflate(lat : Float, lon : Float) : Void
    {
        north += lat;
        south -= lat;
        west -= lon;
        east += lon;
    }
    
    public function getRect() : Rectangle
    {
        var rect : Rectangle = new Rectangle(Math.min(east, west), Math.min(north, south));
        rect.right = Math.max(east, west);
        rect.bottom = Math.max(north, south);
        return rect;
    }
    
    public function contains(location : Location) : Bool
    {
        return getRect().contains(location.lon, location.lat);
    }
    
    public function containsExtent(extent : MapExtent) : Bool
    {
        return getRect().containsRect(extent.getRect());
    }
    
    /** @return "north, south, east, west" */
    public function toString() : String
    {
        return [north, south, east, west].join(", ");
    }
    
    /** Creates a new MapExtent from the given String.
		 * @param str "north, south, east, west"
		 * @return a new MapExtent from the given string */
    public static function fromString(str : String) : MapExtent
    {
        //var parts : Array<String> = str.split(new EReg("\\s*,\\s*", ""), 4);
		var parts : Array<String> = str.split(",");
        return new MapExtent(Std.parseFloat(parts[0]), 
        Std.parseFloat(parts[1]), 
        Std.parseFloat(parts[2]), 
        Std.parseFloat(parts[3]));
    }
    
    /** calculate the north/south/east/west extremes of the given array of locations */
    public static function fromLocations(locations : Array<Location>) : MapExtent
    {
        if (locations == null || locations.length == 0)             return new MapExtent();
        
        var extent : MapExtent=null;
        
        for (location in locations)
        {
            if (extent == null) {
                if (location != null && !Math.isNaN(location.lat) && !Math.isNaN(location.lon)) {
                    extent = new MapExtent(location.lat, location.lat, location.lon, location.lon);
                }
            }
            else {
                if (location != null && !Math.isNaN(location.lat) && !Math.isNaN(location.lon)) {
                    extent.enclose(location);
                }
            }
        }
        
        if (extent == null) {
            extent = new MapExtent();
        }
        
        return extent;
    }
    
    public static function fromLocation(location : Location) : MapExtent
    {
        return new MapExtent(location.lat, location.lat, location.lon, location.lon);
    }
    
    public static function fromLocationProperties(objects:StringMap<Location>, locationProp:String = "location"):MapExtent
	{
		var fromLocationProp : Location = objects.get(locationProp);
		return fromLocations([fromLocationProp]);
	}
}
