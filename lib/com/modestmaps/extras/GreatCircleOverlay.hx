package com.modestmaps.extras;

import com.modestmaps.extras.LineStyle;
import com.modestmaps.extras.Overlay;

import com.modestmaps.Map;
import com.modestmaps.core.MapExtent;
import com.modestmaps.geo.Location;

import openfl.display.Sprite;
//import openfl.filters.DropShadowFilter;
import openfl.geom.Point;
import openfl.utils.Dictionary;

/** 
* a subclass of overlay that will render dashed great-circle arcs
*/
class GreatCircleOverlay extends Overlay
{
    public var lines : Array<Array<Location>> = [];
    private var styles : Dictionary = new Dictionary();
    
    public function new(map : Map)
    {
        super(map);
    }
    
    override public function redraw(sprite : Sprite) : Void
    {
        sprite.graphics.clear();
        for (line in lines){
            var lineStyle : LineStyle = cast(styles[line],lineStyle));
            var p : Point = map.locationPoint(cast(line[0], Location), sprite);
            sprite.graphics.moveTo(p.x, p.y);
            var i : Int = 0;
            var prev : Location;
            for (location in line.substring(1)){
                var thickness : Float = Math.min(1, 1 - Math.abs(i - (line.length / 2)) / (line.length / 3));
                /*                     if (i % 4 == 0 && i != line.length-1) {
                sprite.graphics.lineStyle();
                }
                else {
                lineStyle.apply(sprite.graphics, 1+thickness);
                }            */
                lineStyle.apply(sprite.graphics, 1 + thickness);
                p = map.locationPoint(location, sprite);
                if (prev != null && (Math.abs(prev.lat - location.lat) > 10 || Math.abs(prev.lon - location.lon) > 10)) {
                    sprite.graphics.moveTo(p.x, p.y);
                }
                else {
                    sprite.graphics.lineTo(p.x, p.y);
                }
                i++;
                prev = location;
            }
        }
    }
    
    public function addGreatCircle(start : Location, end : Location, lineStyle : LineStyle = null) : MapExtent
    {
        
        var extent : MapExtent = new MapExtent();
        var latlngs : Array<Location> = [];
        
        with(Math);{
            
            var lat1 : Float = start.lat * PI / 180.0;
            var lon1 : Float = start.lon * PI / 180.0;
            var lat2 : Float = end.lat * PI / 180.0;
            var lon2 : Float = end.lon * PI / 180.0;
            
            var d : Float = 2 * asin(sqrt(pow((sin((lat1 - lat2) / 2)), 2) + cos(lat1) * cos(lat2) * pow((sin((lon1 - lon2) / 2)), 2)));
            var bearing : Float = atan2(sin(lon1 - lon2) * cos(lat2), cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(lon1 - lon2)) / -(PI / 180);
            bearing = bearing < (0) ? 360 + bearing : bearing;
            
            var numSegments : Int = as3hx.Compat.parseInt(40 + (400 * Distance.approxDistance(start, end) / (Math.PI * 2 * 6378000)));
            for (n in 0...numSegments){
                var f : Float = (1 / (numSegments - 1)) * n;
                var A : Float = sin((1 - f) * d) / sin(d);
                var B : Float = sin(f * d) / sin(d);
                var x : Float = A * cos(lat1) * cos(lon1) + B * cos(lat2) * cos(lon2);
                var y : Float = A * cos(lat1) * sin(lon1) + B * cos(lat2) * sin(lon2);
                var z : Float = A * sin(lat1) + B * sin(lat2);
                
                var latN : Float = atan2(z, sqrt(pow(x, 2) + pow(y, 2)));
                var lonN : Float = atan2(y, x);
                var l : Location = new Location(latN / (PI / 180), lonN / (PI / 180));
                latlngs.push(l);
                extent.enclose(l);
            }
        }
        
        lines.push(latlngs);
        
        styles.set(latlngs, (lineStyle != null ? lineStyle : new LineStyle()));
        
        refresh();
        
        return extent;
    }
}

