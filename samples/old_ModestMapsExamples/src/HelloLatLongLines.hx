
import com.adobe.viewsource.ViewSource;
import com.modestmaps.Map;
import com.modestmaps.TweenMap;
import com.modestmaps.extras.MapControls;
import com.modestmaps.extras.MapCopyright;
import com.modestmaps.extras.ZoomSlider;
import com.modestmaps.mapproviders.microsoft.MicrosoftHybridMapProvider;

import flash.display.Sprite;
import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.events.Event;
import flash.events.MouseEvent;

@:meta(SWF(backgroundColor="#ffffff"))



import flash.display.Shape;

import com.modestmaps.events.MapEvent;
import com.modestmaps.core.MapExtent;
import flash.geom.Point;
import com.modestmaps.geo.Location;

class HelloLatLongLines extends Sprite
{
    public var map : Map;
    
    public function new()
    {
        super();
        stage.align = StageAlign.TOP_LEFT;
        stage.scaleMode = StageScaleMode.NO_SCALE;
        
        ViewSource.addMenuItem(this, "srcview/index.html", true);
        
        map = new TweenMap(stage.stageWidth, stage.stageHeight, true, new MicrosoftHybridMapProvider());
        map.addEventListener(MouseEvent.DOUBLE_CLICK, map.onDoubleClick);
        addChild(map);
        
        map.addChild(new LatLongOverlay(map));
        map.addChild(new MapControls(map));
        map.addChild(new ZoomSlider(map));
        map.addChild(new MapCopyright(map));
        
        // make sure the map fills the screen:
        stage.addEventListener(Event.RESIZE, onStageResize);
    }
    
    public function onStageResize(event : Event) : Void
    {
        map.setSize(stage.stageWidth, stage.stageHeight);
    }
}



class LatLongOverlay extends Sprite
{
    public var map : Map;
    public var lines : Array<Dynamic> = [];
    
    public function new(map : Map)
    {
        super();
        this.mouseEnabled = false;
        this.map = map;
        map.addEventListener(MapEvent.RENDERED, onMapRendered);
    }
    
    public function onMapRendered(event : MapEvent) : Void
    {
        var lineCount : Int = 0;
        
        var extent : MapExtent = map.getExtent();
        
        var latSpan : Float = Math.abs(extent.north - extent.south);
        var lonSpan : Float = Math.abs(extent.west - extent.east);
        
        var step : Float = 10.0;
        
        var minLat : Float = Math.max(-80, Math.floor(extent.south / step) * step);
        var maxLat : Float = Math.min(80, Math.ceil(extent.north / step) * step);
        var minLon : Float = Math.floor(extent.west / step) * step;
        var maxLon : Float = Math.ceil(extent.east / step) * step;
        
        var line : Line;
        var p1 : Point;
        var p2 : Point;
        
        var lat : Float = minLat;
        while (lat <= maxLat){
            p1 = map.locationPoint(new Location(lat, minLon));
            p2 = map.locationPoint(new Location(lat, maxLon));
            line = getLine(lineCount);
            line.x = p1.x;
            line.y = p1.y;
            line.width = p2.x - p1.x;
            line.height = 0.01;
            lineCount++;
            lat += step;
        }
        
        var lon : Float = minLon;
        while (lon <= maxLon){
            p1 = map.locationPoint(new Location(maxLat, lon));
            p2 = map.locationPoint(new Location(minLat, lon));
            line = getLine(lineCount);
            line.x = p1.x;
            line.y = p1.y;
            line.width = 0.1;
            line.height = p2.y - p1.y;
            lineCount++;
            lon += step;
        }
        
        while (numChildren > lineCount){
            lines.pop();
            removeChildAt(numChildren - 1);
        }
    }
    
    private function getLine(num : Int) : Line
    {
        while (lines.length < num + 1){
            lines.push(addChild(new Line()));
        }
        return lines[num];
    }
}

class Line extends Shape
{
    public function new()
    {
        super();
        graphics.lineStyle(0, 0xffffff, 0.2, false);
        graphics.moveTo(0, 0);
        graphics.lineTo(1, 1);
    }
}
