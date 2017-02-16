package;
import com.modestmaps.TweenMap;
import com.modestmaps.geo.Location;
import com.modestmaps.mapproviders.BlankProvider;
import com.modestmaps.core.Tile;
import haxe.ds.StringMap;
import openfl.display.Bitmap;
import openfl.display.BitmapData;

/**
 * ...
 * @author mmp
 */
class DemoMandel
{

	public function new(map : TweenMap) 
	{
		map.setMapProvider(new BlankProvider());
		map.grid.setTileClass(CustomTile);
        
        map.grid.enforceBoundsEnabled = false;
        
        // add some basic controls
        // you're free to use these, but I'd make my own if I was a Flash coder :)
        //map.addChild(new MapControls(map));
        //map.addChild(new ZoomSlider(map));
        
        // start at 0,0
        // 0 seems like a good zoom level...
        map.setCenterZoom(new Location(0, 0), 0);
	}
	
}
class CustomTile extends Tile
{
    public static var bmds = new Array<BitmapData>();
    public static var bmdKeyToIndex = new StringMap<Int>();
    
    public function new(column : Int, row : Int, zoom : Int)
    {
        super(column, row, zoom);
    }
    
    // http://blogs.msdn.com/mikeormond/archive/2008/08/22/deep-zoom-multiscaletilesource-and-the-mandelbrot-set.aspx
    override public function init(tilePosX : Int, tilePosY : Int, tileLevel : Int) : Void
    {
        super.init(tilePosX, tilePosY, tileLevel);
        
        while (numChildren>0) removeChildAt(0);
        
        var tileWidth : Int = 128;
        var tileHeight : Int = 128;
        
        var key : String = tilePosX + ":" + tilePosY + ":" + tileLevel;
        
        var bmd : BitmapData;
        
        if ( bmdKeyToIndex.get(key)!=null) {
            trace("using cached", key);
            bmd = bmds[bmdKeyToIndex.get(key)];
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
			bmdKeyToIndex[key] = bmds.length;
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
