
import com.adobe.viewsource.ViewSource;
import com.modestmaps.Map;
import com.modestmaps.TweenMap;
import com.modestmaps.core.MapExtent;
import com.modestmaps.extras.MapControls;
import com.modestmaps.geo.Location;
import com.modestmaps.mapproviders.IMapProvider;

import flash.display.Sprite;
import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.events.Event;
import flash.events.MouseEvent;

@:meta(SWF(backgroundColor="#eeeeee"))


import com.modestmaps.core.Coordinate;
import com.modestmaps.mapproviders.AbstractMapProvider;

import com.modestmaps.geo.LinearProjection;
import com.modestmaps.geo.Transformation;
import flash.display.Shape;

class HelloESRI extends Sprite
{
    public var map : Map;
    
    public function new()
    {
        super();
        stage.align = StageAlign.TOP_LEFT;
        stage.scaleMode = StageScaleMode.NO_SCALE;
        
        ViewSource.addMenuItem(this, "srcview/index.html", true);
        
        map = new TweenMap(stage.stageWidth, stage.stageHeight, true, new EsriMapProvider(), new MapExtent(48.383, 43.300, 5.367, -4.500));
        map.addEventListener(MouseEvent.DOUBLE_CLICK, map.onDoubleClick);
        addChild(map);
        
        map.putMarker(new Location(51.50757, -0.1078), new Marker());
        map.putMarker(new Location(50.4363, 30.5390), new Marker());
        map.putMarker(new Location(37.47794, -122.15110), new Marker());
        
        map.addChild(new MapControls(map));
        
        stage.addEventListener(Event.RESIZE, onStageResize);
    }
    
    private function onStageResize(event : Event) : Void
    {
        map.setSize(stage.stageWidth, stage.stageHeight);
    }
}



class Marker extends Shape
{
    public function new()
    {
        super();
        graphics.beginFill(0xff0000);
        graphics.drawCircle(0, 0, 10);
        graphics.endFill();
    }
}

class EsriMapProvider extends AbstractMapProvider implements IMapProvider
{
    public function new(minZoom : Int = MIN_ZOOM, maxZoom : Int = MAX_ZOOM)
    {
        super(0, Math.min(14, maxZoom));
        
        var t : Transformation = new Transformation(0.3183098861837907, 0, 1, 
        0, -0.3183098861837907, 0.5);
        
        __projection = new LinearProjection(0, t);
    }
    
    public function toString() : String
    {
        return "ESRI";
    }
    
    public function getTileUrls(coord : Coordinate) : Array<Dynamic>
    {
        return ["http://server.arcgisonline.com/ArcGIS/rest/services/ESRI_StreetMap_World_2D/MapServer/tile/" + getZoomString(coord)];
    }
    
    private function getZoomString(coord : Coordinate) : String
    {
        var sourceCoord : Coordinate = sourceCoordinate(coord);
        return (sourceCoord.zoom) + "/" + (sourceCoord.row) + "/" + (sourceCoord.column);
    }
    
    override public function sourceCoordinate(coord : Coordinate) : Coordinate
    {
        var tilesWide : Int = Math.pow(2, coord.zoom + 1);
        
        var wrappedColumn : Float = coord.column % tilesWide;
        
        while (wrappedColumn < 0)
        {
            wrappedColumn += tilesWide;
        }  // we don't wrap rows here because the map/grid should be enforcing outerLimits :)  
        
        
        
        
        return new Coordinate(coord.row, wrappedColumn, coord.zoom);
    }
    
    override private function get_TileWidth() : Float
    {
        return 512;
    }
    
    override private function get_TileHeight() : Float
    {
        return 512;
    }
}
