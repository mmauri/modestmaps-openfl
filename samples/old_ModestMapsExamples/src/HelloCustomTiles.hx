
import com.adobe.viewsource.ViewSource;
import com.modestmaps.Map;
import com.modestmaps.TweenMap;
import com.modestmaps.extras.MapControls;
import com.modestmaps.extras.ZoomSlider;
import com.modestmaps.geo.Location;

import flash.display.Sprite;
import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.events.Event;
import flash.events.MouseEvent;

@:meta(SWF(backgroundColor="#808080"))



import com.modestmaps.core.Tile;
import com.modestmaps.core.Coordinate;
import com.modestmaps.mapproviders.IMapProvider;
import com.modestmaps.mapproviders.AbstractMapProvider;

class HelloCustomTiles extends Sprite
{
    public var map : Map;
    
    public function new()
    {
        super();
        stage.align = StageAlign.TOP_LEFT;
        stage.scaleMode = StageScaleMode.NO_SCALE;
        
        ViewSource.addMenuItem(this, "srcview/index.html", true);
        
        // make a draggable TweenMap so that we have smooth zooming and panning animation
        // use our blank provider, defined below:
        map = new TweenMap(stage.stageWidth, stage.stageHeight, true, new BlankProvider());
        map.addEventListener(MouseEvent.DOUBLE_CLICK, map.onDoubleClick);
        addChild(map);
        
        map.addChild(map.grid.debugField);
        
        // tell the map grid to make tiles using our custom class, defined below:
        map.grid.setTileClass(CustomTile);
        
        // add some basic controls
        // you're free to use these, but I'd make my own if I was a Flash coder :)
        map.addChild(new MapControls(map, true, true));
        map.addChild(new ZoomSlider(map));
        
        // start at 0,0
        // 11 seems like a good zoom level...
        map.setCenterZoom(new Location(0, 0), 11);
        
        // make sure the map always fills the screen:
        stage.addEventListener(Event.RESIZE, onStageResize);
    }
    
    public function onStageResize(event : Event) : Void
    {
        map.setSize(stage.stageWidth, stage.stageHeight);
    }
}



class CustomTile extends Tile
{
    public function new(column : Int, row : Int, zoom : Int)
    {
        super(column, row, zoom);
    }
    
    override public function init(column : Int, row : Int, zoom : Int) : Void
    {
        super.init(column, row, zoom);
        
        graphics.clear();
        graphics.beginFill(0xffffff);
        graphics.drawRect(0, 0, 32, 32);
        graphics.endFill();
        
        var r : Int = Math.random() * 255;
        var g : Int = Math.random() * 255;
        var b : Int = Math.random() * 255;
        
        var c : Int = 0xff000000 | r << 16 | g << 8 | b;
        
        graphics.beginFill(c);
        graphics.drawCircle(16, 16, 8);
        graphics.endFill();
    }
}

class BlankProvider extends AbstractMapProvider implements IMapProvider
{
    public function getTileUrls(coord : Coordinate) : Array<Dynamic>
    {
        return [];
    }
    
    public function toString() : String
    {
        return "BLANK_PROVIDER";
    }
    
    override private function get_TileWidth() : Float
    {
        return 32;
    }
    
    override private function get_TileHeight() : Float
    {
        return 32;
    }

    public function new()
    {
        super();
    }
}
