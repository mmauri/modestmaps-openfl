
import com.adobe.viewsource.ViewSource;
import com.modestmaps.Map;
import com.modestmaps.TweenMap;
import com.modestmaps.extras.MapControls;
import com.modestmaps.geo.Location;

import flash.display.Sprite;
import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.events.Event;
import flash.events.MouseEvent;

@:meta(SWF(backgroundColor="#000000"))



import com.modestmaps.core.Tile;
import com.modestmaps.core.Coordinate;
import com.modestmaps.mapproviders.IMapProvider;
import com.modestmaps.mapproviders.AbstractMapProvider;
import flash.display.Bitmap;
import flash.display.BitmapData;

class HelloMandel extends Sprite
{
    public var map : Map;
    
    // TODO: set constants in TileGrid.tilePool to 1 before compiling this!
    
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
        
        // tell the map grid to make tiles using our custom class, defined below:
        map.grid.setTileClass(CustomTile);
        
        map.grid.enforceBoundsEnabled = false;
        
        // add some basic controls
        // you're free to use these, but I'd make my own if I was a Flash coder :)
        map.addChild(new MapControls(map));
        //map.addChild(new ZoomSlider(map));
        
        // start at 0,0
        // 0 seems like a good zoom level...
        map.setCenterZoom(new Location(0, 0), 0);
        
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
    public static var bmds : Array<Dynamic> = [];
    public static var bmdKeyToIndex : Dynamic = { };
    
    public function new(column : Int, row : Int, zoom : Int)
    {
        super(column, row, zoom);
    }
    
    // http://blogs.msdn.com/mikeormond/archive/2008/08/22/deep-zoom-multiscaletilesource-and-the-mandelbrot-set.aspx
    override public function init(tilePosX : Int, tilePosY : Int, tileLevel : Int) : Void
    {
        super.init(tilePosX, tilePosY, tileLevel);
        
        while (numChildren)removeChildAt(0);
        
        var tileWidth : Float = 128;
        var tileHeight : Float = 128;
        
        var key : String = tilePosX + ":" + tilePosY + ":" + tileLevel;
        
        var bmd : BitmapData;
        
        if (Std.is(Reflect.field(bmdKeyToIndex, key), Int)) {
            trace("using cached", key);
            bmd = try cast(bmds[as3hx.Compat.parseInt(Reflect.field(bmdKeyToIndex, key))], BitmapData) catch(e:Dynamic) null;
        }
        else {
            trace("rendering", key);
            
            bmd = new BitmapData(tileWidth, tileHeight, false, 0xffffff);
            bmd.lock();
            
            // this is not quite the same as mike ormond's code:
            var tileCountX : Float = Math.pow(2, tileLevel);
            var tileCountY : Float = Math.pow(2, tileLevel);
            
            tileCountX = tileCountX < (1) ? 1 : tileCountX;
            tileCountY = tileCountY < (1) ? 1 : tileCountY;
            
            var ReStart : Float = -2.0;
            var ReDiff : Float = 3.0;
            
            var MinRe : Float = ReStart + ReDiff * tilePosX / tileCountX;
            var MaxRe : Float = MinRe + ReDiff / tileCountX;
            
            var ImStart : Float = -1.2;
            var ImDiff : Float = 2.4;
            
            var MinIm : Float = ImStart + ImDiff * tilePosY / tileCountY;
            var MaxIm : Float = MinIm + ImDiff / tileCountY;
            
            var Re_factor : Float = (MaxRe - MinRe) / (tileWidth - 1);
            var Im_factor : Float = (MaxIm - MinIm) / (tileHeight - 1);
            
            var MaxIterations : Int = 30;
            
            for (y in 0...tileHeight){
                var c_im : Float = MinIm + y * Im_factor;
                for (x in 0...tileWidth){
                    var c_re : Float = MinRe + x * Re_factor;
                    
                    var Z_re : Float = c_re;
                    var Z_im : Float = c_im;
                    var isInside : Bool = true;
                    var n : Int = 0;
                    for (n in 0...MaxIterations){
                        var Z_re2 : Float = Z_re * Z_re;
                        var Z_im2 : Float = Z_im * Z_im;
                        if (Z_re2 + Z_im2 > 4) 
                        {
                            isInside = false;
                            break;
                        }
                        Z_im = 2 * Z_re * Z_im + c_im;
                        Z_re = Z_re2 - Z_im2 + c_re;
                    }
                    if (isInside) 
                    {
                        bmd.setPixel(x, y, 0x000000);
                    }
                    else 
                    {
                        if (n < MaxIterations / 2) 
                        {
                            bmd.setPixel(x, y, color(255 / (MaxIterations / 2) * n, 0, 0));
                        }
                        else 
                        {
                            bmd.setPixel(x, y, color(255, (n - MaxIterations / 2) * 255 / (MaxIterations / 2), (n - MaxIterations / 2) * 255 / (MaxIterations / 2)));
                        }
                    }
                }
            }
            bmd.unlock();
            
            trace("caching", key);
            Reflect.setField(bmdKeyToIndex, key, bmds.length);
            bmds.push(bmd);
        }
        
        addChild(new Bitmap(bmd));
    }
    
    private function color(r : Int, g : Int, b : Int) : Int
    {
        //if (Math.random() < 0.001) trace(r,g,b, uint(0xff000000 | (r << 16) | (g << 8) | b).toString(16));
        return 0xff000000 | (r << 16) | (g << 8) | b;
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
    
    override private function get_TileHeight() : Float
    {
        return 128;
    }
    
    override private function get_TileWidth() : Float
    {
        return 128;
    }

    public function new()
    {
        super();
    }
}
