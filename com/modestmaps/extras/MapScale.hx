package com.modestmaps.extras;


import com.modestmaps.Map;
import com.modestmaps.events.MapEvent;
import com.modestmaps.geo.Location;

import openfl.display.Sprite;
import openfl.geom.Point;
import openfl.text.TextField;
import openfl.text.TextFormat;

class MapScale extends Sprite
{
    private var map : Map;
    
    private var leftField : TextField;
    private var rightField : TextField;
    
    private var offsetX : Float;
    
    public function new(map : Map, offsetX : Float = 0)
    {
        super();
        this.map = map;
        
        this.offsetX = offsetX;
        
        leftField = new TextField();
        leftField.defaultTextFormat = new TextFormat("Arial", 10, 0x000000, false, null, null, null, "_blank");
        leftField.mouseEnabled = leftField.selectable = false;
        addChild(leftField);
        
        rightField = new TextField();
        rightField.defaultTextFormat = new TextFormat("Arial", 10, 0x000000, false, null, null, null, "_blank");
        rightField.mouseEnabled = rightField.selectable = false;
        addChild(rightField);
        
        map.addEventListener(MapEvent.EXTENT_CHANGED, redraw);
        map.addEventListener(MapEvent.STOP_ZOOMING, redraw);
        map.addEventListener(MapEvent.STOP_PANNING, redraw);
        map.addEventListener(MapEvent.RESIZED, onMapResized);
        
        redraw(null);
    }
    
    private function redraw(event : MapEvent) : Void
    {
        var pixelWidth : Float = 100;
        
        // pick two points on the map, 150px apart
        var p1 : Point = new Point(map.getWidth() / 2 - pixelWidth / 2, map.getHeight() / 2);
        var p2 : Point = new Point(map.getWidth() / 2 + pixelWidth / 2, map.getHeight() / 2);
        
        var start : Location = map.pointLocation(p1);
        var end : Location = map.pointLocation(p2);
        
        var barParams : Array<Dynamic> = [
        {
            radius : Distance.R_MILES,
            unit : "mile",
            units : "miles",
            field : leftField,

        }, 
        {
            radius : Distance.R_KM,
            unit : "km",
            units : "km",
            field : rightField,

        }];
        
        graphics.clear();
        for (i in 0...barParams.length){
            
            var d : Float = Distance.approxDistance(start, end, barParams[i].radius);
            
            var metersPerPixel : Float = d / pixelWidth;
            
            // powers of ten, two?
            //var nearestPower:Number = Math.pow(2, Math.round(Math.log(d) / Math.LN2));
            var nearestPower : Float = parseFloat(d.toPrecision(1));
            
            var pixels : Float = nearestPower / metersPerPixel;
            
            graphics.lineStyle(0, 0x000000);
            graphics.beginFill(0xffffff);
            graphics.drawRect(0, i * 12, pixels, 5);
            
            var decDigits : Int = nearestPower < (1) ? 2 : 0;
            var unit : String = nearestPower.toFixed(decDigits) == ("1") ? barParams[i].unit : barParams[i].units;
            
            var field : TextField = barParams[i].field;
            
            field.text = nearestPower.toFixed(decDigits) + " " + unit;
            field.width = field.textWidth + 4;
            field.height = field.textHeight + 4;
            
            field.x = pixels + 2;
            field.y = (i * 12) + 2.5 - field.height / 2;
        }
        
        onMapResized(null);
    }
    
    private function onMapResized(event : MapEvent) : Void
    {
        this.x = 15 + offsetX;
        this.y = map.getHeight() - this.height - 6;
    }
}
